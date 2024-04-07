import ballerina/log;
import ballerina/time;

import samjs/expensetracker.dbmodel;

type LatestDateEntry record {|
    time:Date latestDate;
|};

type CategoryTotal record {
    readonly string categoryId;
    decimal total;
    time:Date date;
};

public function main() returns error? {
    dbmodel:Client|error expenseAppDb = new (host = host, user = user, password = password,
        database = database, port = port, options = connectionOptions
    );
    if expenseAppDb is error {
        log:printError("Error in connecting to the database.", 'error = expenseAppDb);
        return expenseAppDb;
    }

    error? summarizationError = summarizeDailyExpenses(expenseAppDb);
    if summarizationError is error {
        log:printError("Error in summarizing daily expenses.", 'error = summarizationError);
        return summarizationError;
    }

    error? sendEmailError =  sendDailySummaryEmail(expenseAppDb);
    if sendEmailError is error {
        log:printError("Error in sending daily summary email.", 'error = sendEmailError);
        return sendEmailError;
    }
}

