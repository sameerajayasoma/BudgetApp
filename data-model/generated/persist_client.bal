// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.
import ballerina/jballerina.java;
import ballerina/persist;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/persist.sql as psql;

const EXPENSE_ITEM = "expenseitems";
const EXPENSE_CATEGORY = "expensecategories";
const CATEGORY_BUDGET = "categorybudgets";
const DAILY_EXPENSE_SUMMARY = "dailyexpensesummaries";

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final mysql:Client dbClient;

    private final map<psql:SQLClient> persistClients;

    private final record {|psql:SQLMetadata...;|} & readonly metadata = {
        [EXPENSE_ITEM] : {
            entityName: "ExpenseItem",
            tableName: "ExpenseItem",
            fieldMetadata: {
                id: {columnName: "id"},
                description: {columnName: "description"},
                amount: {columnName: "amount"},
                dateTime: {columnName: "dateTime"},
                comment: {columnName: "comment"},
                createdAt: {columnName: "createdAt"},
                updatedAt: {columnName: "updatedAt"},
                categoryId: {columnName: "categoryId"},
                "category.id": {relation: {entityName: "category", refField: "id"}},
                "category.name": {relation: {entityName: "category", refField: "name"}},
                "category.description": {relation: {entityName: "category", refField: "description"}}
            },
            keyFields: ["id"],
            joinMetadata: {category: {entity: ExpenseCategory, fieldName: "category", refTable: "ExpenseCategory", refColumns: ["id"], joinColumns: ["categoryId"], 'type: psql:ONE_TO_MANY}}
        },
        [EXPENSE_CATEGORY] : {
            entityName: "ExpenseCategory",
            tableName: "ExpenseCategory",
            fieldMetadata: {
                id: {columnName: "id"},
                name: {columnName: "name"},
                description: {columnName: "description"},
                "categoryBudget.id": {relation: {entityName: "categoryBudget", refField: "id"}},
                "categoryBudget.categorybudgetId": {relation: {entityName: "categoryBudget", refField: "categorybudgetId"}},
                "categoryBudget.amount": {relation: {entityName: "categoryBudget", refField: "amount"}},
                "categoryBudget.year": {relation: {entityName: "categoryBudget", refField: "year"}},
                "categoryBudget.month": {relation: {entityName: "categoryBudget", refField: "month"}},
                "expenseItems[].id": {relation: {entityName: "expenseItems", refField: "id"}},
                "expenseItems[].description": {relation: {entityName: "expenseItems", refField: "description"}},
                "expenseItems[].amount": {relation: {entityName: "expenseItems", refField: "amount"}},
                "expenseItems[].dateTime": {relation: {entityName: "expenseItems", refField: "dateTime"}},
                "expenseItems[].comment": {relation: {entityName: "expenseItems", refField: "comment"}},
                "expenseItems[].createdAt": {relation: {entityName: "expenseItems", refField: "createdAt"}},
                "expenseItems[].updatedAt": {relation: {entityName: "expenseItems", refField: "updatedAt"}},
                "expenseItems[].categoryId": {relation: {entityName: "expenseItems", refField: "categoryId"}},
                "dailyExpenseSummaryLines[].id": {relation: {entityName: "dailyExpenseSummaryLines", refField: "id"}},
                "dailyExpenseSummaryLines[].date": {relation: {entityName: "dailyExpenseSummaryLines", refField: "date"}},
                "dailyExpenseSummaryLines[].totalAmount": {relation: {entityName: "dailyExpenseSummaryLines", refField: "totalAmount"}},
                "dailyExpenseSummaryLines[].expensecategoryId": {relation: {entityName: "dailyExpenseSummaryLines", refField: "expensecategoryId"}}
            },
            keyFields: ["id"],
            joinMetadata: {
                categoryBudget: {entity: CategoryBudget, fieldName: "categoryBudget", refTable: "CategoryBudget", refColumns: ["categorybudgetId"], joinColumns: ["id"], 'type: psql:ONE_TO_ONE},
                expenseItems: {entity: ExpenseItem, fieldName: "expenseItems", refTable: "ExpenseItem", refColumns: ["categoryId"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE},
                dailyExpenseSummaryLines: {entity: DailyExpenseSummary, fieldName: "dailyExpenseSummaryLines", refTable: "DailyExpenseSummary", refColumns: ["expensecategoryId"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE}
            }
        },
        [CATEGORY_BUDGET] : {
            entityName: "CategoryBudget",
            tableName: "CategoryBudget",
            fieldMetadata: {
                id: {columnName: "id"},
                categorybudgetId: {columnName: "categorybudgetId"},
                amount: {columnName: "amount"},
                year: {columnName: "year"},
                month: {columnName: "month"},
                "category.id": {relation: {entityName: "category", refField: "id"}},
                "category.name": {relation: {entityName: "category", refField: "name"}},
                "category.description": {relation: {entityName: "category", refField: "description"}}
            },
            keyFields: ["id"],
            joinMetadata: {category: {entity: ExpenseCategory, fieldName: "category", refTable: "ExpenseCategory", refColumns: ["id"], joinColumns: ["categorybudgetId"], 'type: psql:ONE_TO_ONE}}
        },
        [DAILY_EXPENSE_SUMMARY] : {
            entityName: "DailyExpenseSummary",
            tableName: "DailyExpenseSummary",
            fieldMetadata: {
                id: {columnName: "id"},
                date: {columnName: "date"},
                totalAmount: {columnName: "totalAmount"},
                expensecategoryId: {columnName: "expensecategoryId"},
                "ExpenseCategory.id": {relation: {entityName: "ExpenseCategory", refField: "id"}},
                "ExpenseCategory.name": {relation: {entityName: "ExpenseCategory", refField: "name"}},
                "ExpenseCategory.description": {relation: {entityName: "ExpenseCategory", refField: "description"}}
            },
            keyFields: ["id"],
            joinMetadata: {ExpenseCategory: {entity: ExpenseCategory, fieldName: "ExpenseCategory", refTable: "ExpenseCategory", refColumns: ["id"], joinColumns: ["expensecategoryId"], 'type: psql:ONE_TO_MANY}}
        }
    };

    public isolated function init(string host = "localhost", string? user = "root", string? password = (), string? database = (),
            int port = 3306, mysql:Options? options = (), sql:ConnectionPool? connectionPool = ()) returns persist:Error? {
        mysql:Client|error dbClient = new (host = host, user = user, password = password, database = database, port = port, options = options);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {
            [EXPENSE_ITEM] : check new (dbClient, self.metadata.get(EXPENSE_ITEM), psql:MYSQL_SPECIFICS),
            [EXPENSE_CATEGORY] : check new (dbClient, self.metadata.get(EXPENSE_CATEGORY), psql:MYSQL_SPECIFICS),
            [CATEGORY_BUDGET] : check new (dbClient, self.metadata.get(CATEGORY_BUDGET), psql:MYSQL_SPECIFICS),
            [DAILY_EXPENSE_SUMMARY] : check new (dbClient, self.metadata.get(DAILY_EXPENSE_SUMMARY), psql:MYSQL_SPECIFICS)
        };
    }

    isolated resource function get expenseitems(ExpenseItemTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get expenseitems/[string id](ExpenseItemTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post expenseitems(ExpenseItemInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(EXPENSE_ITEM);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ExpenseItemInsert inserted in data
            select inserted.id;
    }

    isolated resource function put expenseitems/[string id](ExpenseItemUpdate value) returns ExpenseItem|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(EXPENSE_ITEM);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/expenseitems/[id].get();
    }

    isolated resource function delete expenseitems/[string id]() returns ExpenseItem|persist:Error {
        ExpenseItem result = check self->/expenseitems/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(EXPENSE_ITEM);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get expensecategories(ExpenseCategoryTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get expensecategories/[string id](ExpenseCategoryTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post expensecategories(ExpenseCategoryInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(EXPENSE_CATEGORY);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ExpenseCategoryInsert inserted in data
            select inserted.id;
    }

    isolated resource function put expensecategories/[string id](ExpenseCategoryUpdate value) returns ExpenseCategory|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(EXPENSE_CATEGORY);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/expensecategories/[id].get();
    }

    isolated resource function delete expensecategories/[string id]() returns ExpenseCategory|persist:Error {
        ExpenseCategory result = check self->/expensecategories/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(EXPENSE_CATEGORY);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get categorybudgets(CategoryBudgetTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get categorybudgets/[string id](CategoryBudgetTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post categorybudgets(CategoryBudgetInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(CATEGORY_BUDGET);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from CategoryBudgetInsert inserted in data
            select inserted.id;
    }

    isolated resource function put categorybudgets/[string id](CategoryBudgetUpdate value) returns CategoryBudget|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(CATEGORY_BUDGET);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/categorybudgets/[id].get();
    }

    isolated resource function delete categorybudgets/[string id]() returns CategoryBudget|persist:Error {
        CategoryBudget result = check self->/categorybudgets/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(CATEGORY_BUDGET);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get dailyexpensesummaries(DailyExpenseSummaryTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get dailyexpensesummaries/[string id](DailyExpenseSummaryTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post dailyexpensesummaries(DailyExpenseSummaryInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DAILY_EXPENSE_SUMMARY);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from DailyExpenseSummaryInsert inserted in data
            select inserted.id;
    }

    isolated resource function put dailyexpensesummaries/[string id](DailyExpenseSummaryUpdate value) returns DailyExpenseSummary|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DAILY_EXPENSE_SUMMARY);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/dailyexpensesummaries/[id].get();
    }

    isolated resource function delete dailyexpensesummaries/[string id]() returns DailyExpenseSummary|persist:Error {
        DailyExpenseSummary result = check self->/dailyexpensesummaries/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DAILY_EXPENSE_SUMMARY);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    remote isolated function queryNativeSQL(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) returns stream<rowType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor"
    } external;

    remote isolated function executeNativeSQL(sql:ParameterizedQuery sqlQuery) returns psql:ExecutionResult|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor"
    } external;

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

