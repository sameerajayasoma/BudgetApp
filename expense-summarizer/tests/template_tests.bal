import ballerina/test;
import ballerina/io;

@test:Config {}
function testEmailBodyGeneration() returns error? {
    EmailData emailData = {
        todayExpenses: [
            {description: "Lunch", amount: 10.0, date: "2021-09-01", category: "Food"},
            {description: "Dinner", amount: 20.0, date: "2021-09-01", category: "Food"},
            {description: "Fuel", amount: 30.0, date: "2021-09-01", category: "Transport"}
        ],
        todaySummary: {
            date: "2021-09-01",
            total: 60.0,
            categoryTotals: [
                {category: "Food", total: 30.0},
                {category: "Transport", total: 30.0}
            ]
        },
        yesterdaySummary: {
            date: "2021-08-31",
            total: 50.0,
            categoryTotals: [
                {category: "Food", total: 20.0},
                {category: "Transport", total: 30.0}
            ]
        },
        pastSevenDaysSummary: {
            startDate: "2021-08-25",
            endDate: "2021-09-01",
            total: 250.0,
            categoryTotals: [
                {category: "Food", total: 100.0},
                {category: "Transport", total: 150.0}
            ]
        },
        pastThirtyDaysSummary: {
            startDate: "2021-08-25",
            endDate: "2021-09-01",
            total: 750.0,
            categoryTotals: [
                {category: "Food", total: 300.0},
                {category: "Transport", total: 450.0}
            ]
        }
    };

    string emailBody = check generateEmailBody(emailData);
    io:println(emailBody);
}
