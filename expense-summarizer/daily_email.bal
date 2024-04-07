import ballerina/time;
import ballerinax/googleapis.gmail;

import samjs/expensetracker.dbmodel;
import samjs/mustache;

configurable string emailAddresses = ?;
configurable string gmailClientId = ?;
configurable string gmailClientSecret = ?;
configurable string gmailRefreshToken = ?;

type EmailData record {
    ExpenseItemData[] todayExpenses;
    DailySummaryData todaySummary;
    DailySummaryData yesterdaySummary;
    AggregatedData pastSevenDaysSummary;
    AggregatedData pastThirtyDaysSummary;
};

type DailySummaryData record {
    string date;
    decimal total;
    CategoryTotalData[] categoryTotals;
};

type AggregatedData record {
    string startDate;
    string endDate;
    CategoryTotalData[] categoryTotals;
};

type CategoryTotalData record {
    string category;
    decimal total;
};

type ExpenseItemData record {|
    string description;
    decimal amount;
    string date;
    string category;
|};

function sendDailySummaryEmail(dbmodel:Client expenseAppDb) returns error? {
    EmailData emailData = check loadEmailData(expenseAppDb);
    string emailContent = check generateEmailBody(emailData);

    gmail:Client gmail = check new gmail:Client(
        config = {
            auth: {
                refreshToken: gmailRefreshToken,
                clientId: gmailClientId,
                clientSecret: gmailClientSecret
            }
        }
    );

    gmail:MessageRequest message = {
        to: [emailAddresses],
        subject: string `Expense Summary for ${emailData.todaySummary.date}`,
        bodyInHtml: emailContent
    };

    _ = check gmail->/users/me/messages/send.post(message);
}

function generateEmailBody(EmailData emailData) returns string|error {
    // TODO Write duplicates with partial templates
    mustache:Mustache mustache = check mustache:compileTemplateString(dailySummaryTemplate);
    return mustache.execute(check emailData.cloneWithType());
}

function loadEmailData(dbmodel:Client expenseAppDb) returns EmailData|error {
    map<string> categoryIdToNameMap = check getCategoryIdToNameMap(expenseAppDb);

    time:Utc todayInUtc = check getTodayStartTime();
    time:Civil todayCivil = time:utcToCivil(todayInUtc);

    time:Utc tomorrowInUtc = time:utcAddSeconds(todayInUtc, 60 * 60 * 24);
    time:Civil tomorrowCivil = time:utcToCivil(tomorrowInUtc);

    time:Utc yesterdaryInUtc = time:utcAddSeconds(todayInUtc, -60 * 60 * 24);
    time:Civil yesterdayCivil = time:utcToCivil(yesterdaryInUtc);

    time:Utc sevenDaysAgoInUtc = time:utcAddSeconds(todayInUtc, -60 * 60 * 24 * 7);
    time:Civil sevenDaysAgoCivil = time:utcToCivil(sevenDaysAgoInUtc);

    time:Utc thirtyDaysAgoInUtc = time:utcAddSeconds(todayInUtc, -60 * 60 * 24 * 30);
    time:Civil thirtyDaysAgoCivil = time:utcToCivil(thirtyDaysAgoInUtc);

    dbmodel:ExpenseItem[] expenseItems = check getExpenseItemsInDateRange(expenseAppDb, todayCivil, tomorrowCivil);
    ExpenseItemData[] todayExpenses = from var {description, amount, categoryId, dateTime} in expenseItems
        select {description, amount, date: getDateString(dateTime), category: categoryIdToNameMap.get(categoryId)};

    dbmodel:DailyExpenseSummary[] todayExpenseSummary = check getDailyCategorySummaryInRange(expenseAppDb, todayCivil, tomorrowCivil);
    DailySummaryData todaySummary = {
        date: getDateString(todayCivil),
        total: from var {totalAmount} in todayExpenseSummary
            collect sum(totalAmount),
        categoryTotals: calculateCategoryTotalData(calculateCategoryIdTotals(todayExpenseSummary), categoryIdToNameMap)
    };

    dbmodel:DailyExpenseSummary[] yesterdayExpenseSummary = check getDailyCategorySummaryInRange(expenseAppDb, yesterdayCivil, todayCivil);
    DailySummaryData yesterdaySummary = {
        date: getDateString(yesterdayCivil),
        total: from var {totalAmount} in yesterdayExpenseSummary
            collect sum(totalAmount),
        categoryTotals: calculateCategoryTotalData(calculateCategoryIdTotals(yesterdayExpenseSummary), categoryIdToNameMap)
    };

    dbmodel:DailyExpenseSummary[] pastSevenDaysExpenseSummary = check getDailyCategorySummaryInRange(expenseAppDb, sevenDaysAgoCivil, todayCivil);
    AggregatedData pastSevenDaysSummary = {
        startDate: getDateString(sevenDaysAgoCivil),
        endDate: getDateString(todayCivil),
        categoryTotals: calculateCategoryTotalData(calculateCategoryIdTotals(pastSevenDaysExpenseSummary), categoryIdToNameMap)
    };

    dbmodel:DailyExpenseSummary[] pastThirtyDaysExpenseSummary = check getDailyCategorySummaryInRange(expenseAppDb, thirtyDaysAgoCivil, todayCivil);
    AggregatedData pastThirtyDaysSummary = {
        startDate: getDateString(thirtyDaysAgoCivil),
        endDate: getDateString(todayCivil),
        categoryTotals: calculateCategoryTotalData(calculateCategoryIdTotals(pastThirtyDaysExpenseSummary), categoryIdToNameMap)
    };

    return {
        todayExpenses,
        todaySummary,
        yesterdaySummary,
        pastSevenDaysSummary,
        pastThirtyDaysSummary
    };
}

function getTodayStartTime() returns time:Utc|error {
    time:Utc utcNow = time:utcNow();
    time:Civil civilNow = time:utcToCivil(utcNow);
    civilNow = {
        year: civilNow.year,
        month: civilNow.month,
        day: civilNow.day,
        hour: 0,
        minute: 0,
        second: 0,
        utcOffset: time:Z
    };
    return check time:utcFromCivil(civilNow);
}

function getDailyCategorySummaryInRange(dbmodel:Client expenseAppDb, time:Civil startDate, time:Civil endDate) returns dbmodel:DailyExpenseSummary[]|error {
    string startDateStr = getDateString(startDate);
    string endDateStr = getDateString(endDate);
    stream<dbmodel:DailyExpenseSummary, error?> dailySummaryStream = expenseAppDb->queryNativeSQL(`SELECT * FROM DailyExpenseSummary WHERE date >= ${startDateStr} AND date < ${endDateStr}`);
    return from var dailySummary in dailySummaryStream
        select dailySummary;
}

function getDateString(time:Civil date) returns string {
    return string `${date.year}-${date.month}-${date.day} `;
}

function calculateCategoryIdTotals(dbmodel:DailyExpenseSummary[] summaryItems) returns map<decimal> {
    map<decimal> categoryTotals = {};
    foreach var summaryItem in summaryItems {
        string categoryId = summaryItem.expensecategoryId;
        if categoryTotals.hasKey(categoryId) {
            decimal total = categoryTotals.get(categoryId);
            total = total + summaryItem.totalAmount;
            categoryTotals[categoryId] = total;
        } else {
            categoryTotals[categoryId] = summaryItem.totalAmount;
        }
    }
    return categoryTotals;
}

function calculateCategoryTotalData(map<decimal> categoryTotals, map<string> categoryIdToNameMap) returns CategoryTotalData[] {
    CategoryTotalData[] categoryTotalData = [];
    foreach var [categoryId, total] in categoryTotals.entries() {
        string categoryName = categoryIdToNameMap.get(categoryId);
        CategoryTotalData categoryTotal = {category: categoryName, total: total};
        categoryTotalData.push(categoryTotal);
    }
    return categoryTotalData;
}

function getCategoryIdToNameMap(dbmodel:Client expenseAppDb) returns map<string>|error {
    dbmodel:ExpenseCategory[] expenseCategories = check from var category in expenseAppDb->/expensecategories(targetType = dbmodel:ExpenseCategory)
        select category;
    map<string> categoryIdToNameMap = {};
    foreach var category in expenseCategories {
        categoryIdToNameMap[category.id] = category.name;
    }
    return categoryIdToNameMap;
}
