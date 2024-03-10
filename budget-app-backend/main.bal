import budget_app_backend.db;

import ballerina/http;
import ballerina/log;
import ballerina/persist;
import ballerina/uuid;

final db:Client budgetAppDb = check new ();

type ExpenseItemWithoutId record {|
    string description;
    decimal amount;
    string date;
    string categoryId;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        // allowCredentials: true,
        // allowHeaders: ["CORELATION_ID", "Authorization", "Content-Type", "ngrok-skip-browser-warning"],
        // exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service /budgetapp on new http:Listener(8081) {

    resource function get expenses() returns db:ExpenseItem[]|http:InternalServerError {
        db:ExpenseItem[]|error expenseItems = from var expense in budgetAppDb->/expenseitems(targetType = db:ExpenseItem)
            select expense;
        if expenseItems is error {
            log:printError("Error occurred while retrieving the list of expense items.", 'error = expenseItems);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            return expenseItems;
        }
    }

    resource function get expenses/[string id]() returns db:ExpenseItem|http:NotFound|http:InternalServerError {
        db:ExpenseItem|persist:Error expenseItem = budgetAppDb->/expenseitems/[id]();
        if expenseItem is persist:NotFoundError {
            return http:NOT_FOUND;
        } else if expenseItem is persist:Error {
            log:printError("Error occurred while retrieving the expense item.", expenseItemId = id, 'error = expenseItem);
            return http:INTERNAL_SERVER_ERROR;
        } else {
            return expenseItem;
        }
    }

    resource function post expenses(ExpenseItemWithoutId newExpenseItem) returns db:ExpenseItem|http:InternalServerError {
        db:ExpenseItem newExpenseItemRecord = {id: uuid:createType4AsString(), ...newExpenseItem};
        string[]|persist:Error insertedIds = budgetAppDb->/expenseitems.post([newExpenseItemRecord]);
        if insertedIds is string[] {
            return newExpenseItemRecord;
        } else {
            log:printError("Error occurred while adding the expense item.", 'error = insertedIds);
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    resource function put expenses/[string id](db:ExpenseItem updatedExpenseItem) returns http:Ok|http:NotFound|http:InternalServerError {
        db:ExpenseItemUpdate expenseItemUpdate = {description: updatedExpenseItem.description, amount: updatedExpenseItem.amount, date: updatedExpenseItem.date, categoryId: updatedExpenseItem.categoryId};
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
}

