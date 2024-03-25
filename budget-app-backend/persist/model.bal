import ballerina/persist as _;
import ballerina/time;

type ExpenseItem record {|
    readonly string id;
    string description;
    decimal amount;
    string date;
    time:Civil? dateTime;
    string? comment;
    time:Utc? createdAt;
    time:Utc? updatedAt;
    ExpenseCategory category;
|};

type ExpenseCategory record {|
    readonly string id;
    string name;
    string description;
	CategoryBudget? categoryBudget;
	ExpenseItem[] expenseItems;
|};

type CategoryBudget record {|
    readonly string id;
    ExpenseCategory category;
    decimal amount;
    string year;
    string month;
|};
