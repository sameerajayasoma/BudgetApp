import ballerina/http;
import ballerina/log;
import ballerina/persist;
import ballerina/time;
import ballerina/uuid;

import samjs/expensetracker.dbmodel as db;

final db:Client budgetAppDb = check new (host = host, user = user, password = password,
    database = database, port = port, options = connectionOptions
);

type ExpenseItemWithoutId record {|
    string description;
    decimal amount;
    // RFC 3336
    string dateTime;
    string categoryId;
    string comment?;
|};

public type ExpenseItem record {|
    readonly string id;
    string description;
    decimal amount;
    // RFC 3336 format
    string dateTime;
    string? comment = ();
    string categoryId;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        maxAge: 84900
    }
}
service /budgetapp on new http:Listener(8081) {

    resource function get expenses() returns ExpenseItem[]|http:InternalServerError {
        do {
            // A native SQL query to retrieve the list of expense items
            // Bal persist does not support ordering by a datetime typed column yet
            stream<db:ExpenseItem, error?> dbExpenseItemStream = budgetAppDb->queryNativeSQL(`SELECT * FROM ExpenseItem ORDER BY dateTime DESC`);
            // db:ExpenseItem[]|error dbExpenseItems = from var expense in budgetAppDb->/expenseitems(targetType = db:ExpenseItem)
            //     order by expense.date descending
            //     select expense;
            db:ExpenseItem[] dbExpenseItems = check from var expense in dbExpenseItemStream
                select expense;
            return from var item in dbExpenseItems
                select check toExpenseItem(item);
        } on fail var e {
            log:printError("Error occurred while retrieving the list of expense items.", 'error = e);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get expenses/[string id]() returns ExpenseItem|http:NotFound|http:InternalServerError {
        do {
            db:ExpenseItem dbExpenseItem = check budgetAppDb->/expenseitems/[id]();
            return check toExpenseItem(dbExpenseItem);
        } on fail var e {
            if e is persist:NotFoundError {
                return http:NOT_FOUND;
            } else {
                log:printError("Error occurred while retrieving the expense item.", expenseItemId = id, 'error = e);
                return http:INTERNAL_SERVER_ERROR;
            }
        }
    }

    resource function post expenses(ExpenseItemWithoutId newExpenseItem) returns db:ExpenseItem|http:BadRequest|http:InternalServerError {
        time:Utc|error utcTime = time:utcFromString(newExpenseItem.dateTime);
        if utcTime is error {
            log:printError("Error occurred while parsing the date.", 'error = utcTime);
            return http:BAD_REQUEST;
        }
        time:Civil dateTime = time:utcToCivil(utcTime);

        db:ExpenseItem newExpenseItemRecord = {
            id: uuid:createType4AsString(),
            description: newExpenseItem.description,
            amount: newExpenseItem.amount,
            categoryId: newExpenseItem.categoryId,
            comment: newExpenseItem.comment,
            dateTime: dateTime,
            createdAt: time:utcNow(),
            updatedAt: time:utcNow()
        };
        string[]|persist:Error insertedIds = budgetAppDb->/expenseitems.post([newExpenseItemRecord]);
        if insertedIds is string[] {
            return newExpenseItemRecord;
        } else {
            log:printError("Error occurred while adding the expense item.", 'error = insertedIds);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function put expenses/[string id](ExpenseItem updatedExpenseItem) returns http:Ok|http:NotFound|http:BadRequest|http:InternalServerError {
        time:Utc|error utcTime = time:utcFromString(updatedExpenseItem.dateTime);
        if utcTime is error {
            log:printError("Error occurred while parsing the date.", 'error = utcTime);
            return http:BAD_REQUEST;
        }
        time:Civil dateTime = time:utcToCivil(utcTime);

        db:ExpenseItemUpdate expenseItemUpdate = {
            description: updatedExpenseItem.description,
            amount: updatedExpenseItem.amount,
            dateTime: dateTime,
            categoryId: updatedExpenseItem.categoryId,
            comment: updatedExpenseItem.comment,
            updatedAt: time:utcNow()
        };
        db:ExpenseItem|persist:Error updatedItem = budgetAppDb->/expenseitems/[id].put(expenseItemUpdate);
        if updatedItem is db:ExpenseItem {
            return http:OK;
        } else if updatedItem is persist:NotFoundError {
            return http:NOT_FOUND;
        } else {
            log:printError("Error occurred while updating the expense item.", expenseItemId = id, 'error = updatedItem);
        }
        return http:INTERNAL_SERVER_ERROR;
    }

    resource function delete expenses/[string id]() returns http:Ok|http:NotFound|http:InternalServerError {
        db:ExpenseItem|persist:Error deletedItem = budgetAppDb->/expenseitems/[id].delete;
        if deletedItem is db:ExpenseItem {
            return http:OK;
        } else if deletedItem is persist:NotFoundError {
            return http:NOT_FOUND;
        } else {
            log:printError("Error occurred while deleting the expense item.", expenseItemId = id, 'error = deletedItem);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function get expenseCategories() returns db:ExpenseCategory[]|http:InternalServerError {
        db:ExpenseCategory[]|error expenseCategories = from var expenseCategory in budgetAppDb->/expensecategories(targetType = db:ExpenseCategory)
            select expenseCategory;
        if expenseCategories is error {
            log:printError("Error occurred while retrieving the list of expense categories.", 'error = expenseCategories);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            return expenseCategories;
        }
    }

    resource function get health/readiness() returns http:Ok|http:InternalServerError {
        return http:OK;
    }
}

isolated function toExpenseItem(db:ExpenseItem expenseItem) returns ExpenseItem|error =>
{
    id: expenseItem.id,
    description: expenseItem.description,
    amount: expenseItem.amount,
    dateTime: check civilToRFC3339(expenseItem.dateTime),
    categoryId: expenseItem.categoryId,
    comment: expenseItem.comment
};

isolated function civilToRFC3339(time:Civil dateTime) returns string|error {
    dateTime.utcOffset = time:Z;
    string|error rfc3339 = time:civilToString(dateTime);
    if rfc3339 is error {
        log:printError("Error occurred while converting the civil time to RFC 3339.", 'error = rfc3339);
        return "1800-01-02T00:00:00Z";
    }

    return rfc3339;
}

