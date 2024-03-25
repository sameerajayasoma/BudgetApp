// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.
import ballerina/time;

public type ExpenseItem record {|
    readonly string id;
    string description;
    decimal amount;
    string date;
    time:Civil? dateTime;
    string? comment;
    time:Utc? createdAt;
    time:Utc? updatedAt;
    string categoryId;
|};

public type ExpenseItemOptionalized record {|
    string id?;
    string description?;
    decimal amount?;
    string date?;
    time:Civil? dateTime?;
    string? comment?;
    time:Utc? createdAt?;
    time:Utc? updatedAt?;
    string categoryId?;
|};

public type ExpenseItemWithRelations record {|
    *ExpenseItemOptionalized;
    ExpenseCategoryOptionalized category?;
|};

public type ExpenseItemTargetType typedesc<ExpenseItemWithRelations>;

public type ExpenseItemInsert ExpenseItem;

public type ExpenseItemUpdate record {|
    string description?;
    decimal amount?;
    string date?;
    time:Civil? dateTime?;
    string? comment?;
    time:Utc? createdAt?;
    time:Utc? updatedAt?;
    string categoryId?;
|};

public type ExpenseCategory record {|
    readonly string id;
    string name;
    string description;
|};

public type ExpenseCategoryOptionalized record {|
    string id?;
    string name?;
    string description?;
|};

public type ExpenseCategoryWithRelations record {|
    *ExpenseCategoryOptionalized;
    CategoryBudgetOptionalized categoryBudget?;
    ExpenseItemOptionalized[] expenseItems?;
|};

public type ExpenseCategoryTargetType typedesc<ExpenseCategoryWithRelations>;

public type ExpenseCategoryInsert ExpenseCategory;

public type ExpenseCategoryUpdate record {|
    string name?;
    string description?;
|};

public type CategoryBudget record {|
    readonly string id;
    string categorybudgetId;
    decimal amount;
    string year;
    string month;
|};

public type CategoryBudgetOptionalized record {|
    string id?;
    string categorybudgetId?;
    decimal amount?;
    string year?;
    string month?;
|};

public type CategoryBudgetWithRelations record {|
    *CategoryBudgetOptionalized;
    ExpenseCategoryOptionalized category?;
|};

public type CategoryBudgetTargetType typedesc<CategoryBudgetWithRelations>;

public type CategoryBudgetInsert CategoryBudget;

public type CategoryBudgetUpdate record {|
    string categorybudgetId?;
    decimal amount?;
    string year?;
    string month?;
|};

