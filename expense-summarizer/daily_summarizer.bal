import ballerina/log;
import ballerina/time;
import ballerina/uuid;

import samjs/expensetracker.dbmodel;

# This function is used to summarize the daily expenses
# It will summarize the expenses from the day after the last summarized date to yesterday(inclusive)
# + expenseAppDb - The database client
# + return - error if there is an error in the process
function summarizeDailyExpenses(dbmodel:Client expenseAppDb) returns error? {
    // Current time in UTC 2024-04-05 19:20:00 UTC
    // Current time in PDT 2024-04-05 12:20:00 PDT
    // My idea is to summarize the complete days from the day after the last summarized date to the yesterday(inclusive)
    // Say, the last summarized date is 2024-04-01. That means all expense of that day is summarized.
    // We need to start the summary from 2024-04-02 00:00:00 UTC to yesterday 2024-04-04 23:59:59 UTC

    // 2024-04-04 08:00:00 UTC ==> 2024-04-04 00:00:00 PDT
    // Hard coding the time to 8:00:00 for now 
    // TODO we need the users time zone to calculate the start of the day

    // Get the last summarized date
    time:Date|error lastSummarizedDate = getLastSummarizedDate(expenseAppDb);
    if lastSummarizedDate is error {
        log:printError("Error in getting the last summarized date ", 'error = lastSummarizedDate);
        return lastSummarizedDate;
    }

    time:Utc startDateInUtc = check getStartDateInUtc(lastSummarizedDate);
    time:Utc todayInUtc = check getTodayPDTStartTimeInUtc();

    time:Utc currentDateInUtc = startDateInUtc;
    while currentDateInUtc < todayInUtc {
        time:Civil currentDateInCivil = time:utcToCivil(currentDateInUtc);

        // Get the next date
        time:Utc nextDateInUtc = time:utcAddSeconds(currentDateInUtc, 60 * 60 * 24);
        time:Civil nextDateInCivil = time:utcToCivil(nextDateInUtc);
        dbmodel:DailyExpenseSummary[] summaryItems = check getSummarizedExpensesInDateRange(expenseAppDb, currentDateInCivil, nextDateInCivil);

        // Insert the summary to the database
        if summaryItems.length() == 0 {
            continue;
        }

        // TODO IF this fails, do not contine to the next date. Log the error and return
        _ = check expenseAppDb->/dailyexpensesummaries.post(summaryItems);
        // TODO Update the last summarized date in SummaryCalculationTracker

        currentDateInUtc = nextDateInUtc;
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
    string startDateStr = string `${startDate.year}-${startDate.month}-${startDate.day} 08:00:00`;
    string endDateStr = string `${endDate.year}-${endDate.month}-${endDate.day} 08:00:00`;
    stream<dbmodel:ExpenseItem, error?> queryNativeSQL = expenseAppDb->queryNativeSQL(`SELECT * FROM ExpenseItem WHERE dateTime >= ${startDateStr} AND dateTime < ${endDateStr}`);
    return from var item in queryNativeSQL
        select item;
}

function getSummarizedExpensesInDateRange(dbmodel:Client expenseAppDb, time:Civil startDate, time:Civil endDate) returns dbmodel:DailyExpenseSummary[]|error {
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

function getTodayPDTStartTimeInUtc() returns time:Utc|error {
    time:Civil todayInCivil = time:utcToCivil(time:utcNow());
    time:Civil todayStartTimeInCivil = {
        year: todayInCivil.year,
        month: todayInCivil.month,
        day: todayInCivil.day,
        hour: 8,
        minute: 0,
        second: 0,
        utcOffset: time:Z
    };
    return time:utcFromCivil(todayStartTimeInCivil);
}

function getStartDateInUtc(time:Date lastSummarizedDate) returns time:Utc|error {
    time:Civil lastSummarizedCivilDate = {
        year: lastSummarizedDate.year,
        month: lastSummarizedDate.month,
        day: lastSummarizedDate.day,
        hour: 8,
        minute: 0,
        second: 0,
        utcOffset: time:Z
    };
    time:Utc lastSummarizedDateinUtc = check time:utcFromCivil(lastSummarizedCivilDate);
    return time:utcAddSeconds(lastSummarizedDateinUtc, 60 * 60 * 24);
}
