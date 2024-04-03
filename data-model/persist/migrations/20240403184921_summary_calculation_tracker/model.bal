import ballerina/persist as _;
import ballerina/time;

type ExpenseItem record {|
    readonly string id;
    string description;
    decimal amount;
    time:Civil dateTime;
    string? comment;
    time:Utc createdAt;
    time:Utc updatedAt;
    ExpenseCategory category;
|};

type ExpenseCategory record {|
    readonly string id;
    string name;
    string description;
	CategoryBudget? categoryBudget;
	ExpenseItem[] expenseItems;
	DailyExpenseSummary[] dailyExpenseSummaryLines;
|};

type CategoryBudget record {|
    readonly string id;
    ExpenseCategory category;
    decimal amount;
    string year;
    string month;
|};


// UNIQUE KEY `unique_category_date` (`categoryId`, `date`)
// A unique constraint ensuring that there's only one entry per category per day.
type DailyExpenseSummary record {|
    readonly string id;
    time:Date date;
    decimal totalAmount;
    ExpenseCategory ExpenseCategory;
    time:Utc createdAt;
    time:Utc updatedAt;
|};

type SummaryCalculationTracker record {|
    readonly string id;
    time:Date lastCalculatedDate;
    time:Utc updatedAt;
|};
