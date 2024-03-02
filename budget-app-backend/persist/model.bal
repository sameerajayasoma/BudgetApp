import ballerina/persist as _;

type ExpenseItem record {|
    readonly string id;
    string description;
    decimal amount;
    string date;
    ExpenseCategory category;
    // User user;
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

// type User record {|
//     readonly string id;
//     string email;
// 	ExpenseItem[] expenseItems;
// |};