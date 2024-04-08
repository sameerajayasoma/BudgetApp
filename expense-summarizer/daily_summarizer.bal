import ballerina/log;
import ballerina/time;
import ballerina/uuid;

import samjs/expensetracker.dbmodel;

// Assume that the last summarized date is 2024-04-02.
// This means that all the expenses of 2024-04-02 and before are summarized.
// There is a catch, this is in UTC. We need to convert this to the user's time zone
// I am using PDT for now.
// Which means that expenses before 2024-04-03 00:00:00 PDT are summarized.
// The same value in UTC is 2024-04-03 07:00:00 UTC. 
// Becuase expense dataTime is in UTC, we need to convert the user's time to UTC. 

// For the next summarization:
// StatDateTime is 2024-04-03 07:00:00 UTC. 
// If the current time is 2024-04-07 04:00:00 UTC. 
// Then we need to loop through the days from 2024-04-03 07:00:00 UTC to 2024-04-06 07:00:00 UTC
// We need to summarize the expenses of 2024-04-03, 2024-04-04, 2024-04-05, 2024-04-06
// The expenses of 2024-04-07 are not summarized.
// When a day is summarized insert the summary to the database as well as the last summarized date.

# This function is used to summarize the daily expenses
# It will summarize the expenses from the day after the last summarized date to yesterday(inclusive)
# + expenseAppDb - The database client
# + return - error if there is an error in the process
function summarizeDailyExpenses(dbmodel:Client expenseAppDb) returns error? {
    // Get the last summarized date
    time:Date|error lastSummarizedDate = getLastSummarizedDate(expenseAppDb);
    if lastSummarizedDate is error {
        log:printError("Error in getting the last summarized date ", 'error = lastSummarizedDate);
        return lastSummarizedDate;
    }

    time:Utc startDateInUtc = check getStartDateInUtc(lastSummarizedDate);
    log:printInfo("Start date in UTC: ", startDate = time:utcToString(startDateInUtc));
    time:Utc todayInUtc = check getTodayTimeInUtc();
    log:printInfo("Today in UTC: ", today = time:utcToString(todayInUtc));

    time:Utc currentDateInUtc = startDateInUtc;
    time:Utc nextDateInUtc = time:utcAddSeconds(currentDateInUtc, 60 * 60 * 24);
    while nextDateInUtc <= todayInUtc {
        time:Civil currentDateInCivil = time:utcToCivil(currentDateInUtc);
        log:printInfo("Current date in civil: ", currentDate = time:utcToString(currentDateInUtc));
        time:Civil nextDateInCivil = time:utcToCivil(nextDateInUtc);
        log:printInfo("Next date in civil: ", nextDate = time:utcToString(nextDateInUtc));

        // Get the expenses of the current date range
        dbmodel:DailyExpenseSummary[] summaryItems = check summarizeExpensesInDateRange(expenseAppDb, currentDateInCivil, nextDateInCivil);
        if summaryItems.length() != 0 {
            // Ff this fails, do not contine to the next date. Log the error and return
            _ = check expenseAppDb->/dailyexpensesummaries.post(summaryItems);

            // Update the last summarized date in SummaryCalculationTracker
            time:Date newLastSummarizedDate = {year: currentDateInCivil.year, month: currentDateInCivil.month, day: currentDateInCivil.day};
            _ = check expenseAppDb->/summarycalculationtrackers.post([
                {
                    id: uuid:createType4AsString(),
                    lastCalculatedDate: newLastSummarizedDate,
                    updatedAt: time:utcNow()
                }
            ]);
        }

        currentDateInUtc = nextDateInUtc;
        nextDateInUtc = time:utcAddSeconds(currentDateInUtc, 60 * 60 * 24);
    }
}

function calculateCategoryTotals(dbmodel:ExpenseItem[] expenseItems, time:Date date) returns table<CategoryTotal> key(categoryId) {
    table<CategoryTotal> key(categoryId) categoryIdToTotal = table [];
    foreach var {categoryId, amount} in expenseItems {
        if categoryIdToTotal.hasKey(categoryId) {
            CategoryTotal categoryTotal = categoryIdToTotal.get(categoryId);
            decimal total = categoryIdToTotal.get(categoryId).total;
            categoryTotal.total = total + amount;
        } else {
            CategoryTotal categoryTotal = {categoryId: categoryId, total: amount, date: date};
            categoryIdToTotal.put(categoryTotal);
        }
    }

    return categoryIdToTotal;
}

function getLastSummarizedDate(dbmodel:Client expenseAppDb) returns time:Date|error {
    stream<LatestDateEntry, error?> latestDateStream = expenseAppDb->queryNativeSQL(`SELECT MAX(lastCalculatedDate) AS latestDate
FROM SummaryCalculationTracker;`);

    LatestDateEntry[]|error lastSummarizedDateRow = from var row in latestDateStream
        limit 1
        select row;
    if lastSummarizedDateRow is error {
        log:printError("Error in getting the last summarized date ", 'error = lastSummarizedDateRow);
        return lastSummarizedDateRow;
    }

    // JBUG: If I combine the following if with above if as an else if, it gives a compilation error
    if lastSummarizedDateRow.length() == 0 {
        log:printError("No data found in the SummaryCalculationTracker table");
        return error("No data found in the SummaryCalculationTracker table");
    }

    time:Date lastSummarizedDate = lastSummarizedDateRow[0].latestDate;
    return lastSummarizedDate;
}

function getExpenseItemsInDateRange(dbmodel:Client expenseAppDb, time:Civil startDate, time:Civil endDate) returns dbmodel:ExpenseItem[]|error {
    // Using PDT time zone for now. We need to get user's time zone
    string startDateStr = string `${startDate.year}-${startDate.month}-${startDate.day} 07:00:00`;
    string endDateStr = string `${endDate.year}-${endDate.month}-${endDate.day} 07:00:00`;
    stream<dbmodel:ExpenseItem, error?> queryNativeSQL = expenseAppDb->queryNativeSQL(`SELECT * FROM ExpenseItem WHERE dateTime >= ${startDateStr} AND dateTime < ${endDateStr}`);
    return from var item in queryNativeSQL
        select item;
}

function summarizeExpensesInDateRange(dbmodel:Client expenseAppDb, time:Civil startDate, time:Civil endDate) returns dbmodel:DailyExpenseSummary[]|error {
    dbmodel:ExpenseItem[] expenseItems = check getExpenseItemsInDateRange(expenseAppDb, startDate, endDate);
    table<CategoryTotal> key(categoryId) categoryIdToTotal = calculateCategoryTotals(expenseItems, {year: startDate.year, month: startDate.month, day: startDate.day});

    dbmodel:DailyExpenseSummary[] summaryItems = [];
    foreach var catagoryTotal in categoryIdToTotal {
        dbmodel:DailyExpenseSummary dailyExpenseSummary = {
            id: uuid:createType4AsString(),
            date: catagoryTotal.date,
            expensecategoryId: catagoryTotal.categoryId,
            totalAmount: catagoryTotal.total,
            createdAt: time:utcNow(),
            updatedAt: time:utcNow()
        };
        summaryItems.push(dailyExpenseSummary);
    }

    return summaryItems;
}

function getTodayTimeInUtc() returns time:Utc|error {
    // time:Civil todayInCivil = time:utcToCivil(time:utcNow());
    // time:Civil todayStartTimeInCivil = {
    //     year: todayInCivil.year,
    //     month: todayInCivil.month,
    //     day: todayInCivil.day,
    //     hour: 7,
    //     minute: 0,
    //     second: 0,
    //     utcOffset: time:Z
    // };
    // return time:utcFromCivil(todayStartTimeInCivil);
    return time:utcNow();
}

function getStartDateInUtc(time:Date lastSummarizedDate) returns time:Utc|error {
    // Convert to the user's time zone. Hard coding PDT for now. 
    // TODO: Get the user's time zone
    // TODO: Use proper time zone conversion
    time:Civil lastSummarizedCivilDate = {
        year: lastSummarizedDate.year,
        month: lastSummarizedDate.month,
        day: lastSummarizedDate.day,
        hour: 7,
        minute: 0,
        second: 0,
        utcOffset: time:Z
    };
    time:Utc lastSummarizedDateinUtc = check time:utcFromCivil(lastSummarizedCivilDate);
    return time:utcAddSeconds(lastSummarizedDateinUtc, 60 * 60 * 24);
}
