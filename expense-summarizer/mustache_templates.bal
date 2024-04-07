
string dailySummaryTemplate = string `<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4; color: #333; }
        h2, h3 { color: #0073e6; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); }
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; color: #333; }
        td { color: #555; }
        .summary-header { margin-top: 40px; color: #0056b3; }
        .overall-total { text-align: right; padding-right: 20px; font-weight: bold; margin-top: 10px; color: #0073e6; }
        ul { list-style-type: none; padding: 0; }
        li { padding: 8px; }
        .category-total { background-color: #e8f0fe; margin-bottom: 2px; border-left: 4px solid #0073e6; padding-left: 8px; }
    </style>
</head>
<body>
    <h3>Today's Expenses</h3>
    <table>
        <thead>
            <tr>
                <th>Description</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Category</th>
            </tr>
        </thead>
        <tbody>
            {{#todayExpenses}}
            <tr>
                <td>{{description}}</td>
                <td>{{amount}}</td>
                <td>{{date}}</td>
                <td>{{category}}</td>
            </tr>
            {{/todayExpenses}}
        </tbody>
    </table>

    {{#todaySummary}}
    <h3 class="summary-header">Today's Summary</h3>
    <table>
        <thead>
            <tr>
                <th>Category</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            {{#categoryTotals}}
            <tr>
                <td>{{category}}</td>
                <td>{{total}}</td>
            </tr>
            {{/categoryTotals}}
        </tbody>
    </table>
    <p class="overall-total">Overall Total: {{total}}</p>
    {{/todaySummary}}

    {{#yesterdaySummary}}
    <h3 class="summary-header">Yesterday's Summary</h3>
    <table>
        <thead>
            <tr>
                <th>Category</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            {{#categoryTotals}}
            <tr>
                <td>{{category}}</td>
                <td>{{total}}</td>
            </tr>
            {{/categoryTotals}}
        </tbody>
    </table>
    <p class="overall-total">Overall Total: {{total}}</p>
    {{/yesterdaySummary}}

    {{#pastSevenDaysSummary}}
    <h3 class="summary-header">Past Seven Days Summary ({{startDate}} - {{endDate}})</h3>
    <table>
        <thead>
            <tr>
                <th>Category</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            {{#categoryTotals}}
            <tr>
                <td>{{category}}</td>
                <td>{{total}}</td>
            </tr>
            {{/categoryTotals}}
        </tbody>
    </table>
    {{/pastSevenDaysSummary}}

    {{#pastThirtyDaysSummary}}
    <h3 class="summary-header">Past Thirty Days Summary ({{startDate}} - {{endDate}})</h3>
    <table>
        <thead>
            <tr>
                <th>Category</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            {{#categoryTotals}}
            <tr>
                <td>{{category}}</td>
                <td>{{total}}</td>
            </tr>
            {{/categoryTotals}}
        </tbody>
    </table>
    {{/pastThirtyDaysSummary}}
</body>
</html>
`;


string emailTemplate = string `<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4; color: #333; }
        h2, h3 { color: #0073e6; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); }
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; color: #333; }
        td { color: #555; }
        .summary-header { margin-top: 40px; color: #0056b3; }
        .overall-total { text-align: right; padding-right: 20px; font-weight: bold; margin-top: 10px; color: #0073e6; }
        ul { list-style-type: none; padding: 0; }
        li { padding: 8px; }
        .category-total { background-color: #e8f0fe; margin-bottom: 2px; border-left: 4px solid #0073e6; padding-left: 8px; }
    </style>
</head>
<body>
    <h2>Expense Summary for {{todaySummary.date}}</h2>
    <h3>Today's Expenses</h3>
    <table>
        <thead>
            <tr>
                <th>Description</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Category</th>
            </tr>
        </thead>
        <tbody>
            {{#todayExpenses}}
            <tr>
                <td>{{description}}</td>
                <td>{{amount}}</td>
                <td>{{date}}</td>
                <td>{{category}}</td>
            </tr>
            {{/todayExpenses}}
        </tbody>
    </table>

    <!-- Today's Summary -->
    <h3 class="summary-header">Today's Summary</h3>
    {{> summaryTable summary=todaySummary}}

    <!-- Yesterday's Summary -->
    <h3 class="summary-header">Yesterday's Summary</h3>
    {{> summaryTable summary=yesterdaySummary}}

    <!-- Past Seven Days Summary -->
    <h3 class="summary-header">Past Seven Days Summary</h3>
    {{> aggregatedSummary summary=pastSevenDaysSummary}}

    <!-- Past Thirty Days Summary -->
    <h3 class="summary-header">Past Thirty Days Summary</h3>
    {{> aggregatedSummary summary=pastThirtyDaysSummary}}
</body>
</html>
`;

string summaryTable = string `<table>
    <thead>
        <tr>
            <th>Category</th>
            <th>Total</th>
        </tr>
    </thead>
    <tbody>
        {{#summary.categoryTotals}}
        <tr>
            <td>{{category}}</td>
            <td>{{total}}</td>
        </tr>
        {{/summary.categoryTotals}}
    </tbody>
</table>
<p class="overall-total">Overall Total: {{summary.total}}</p>
`;
string aggregatedSummary = string `<table>
    <thead>
        <tr>
            <th>Category</th>
            <th>Total</th>
        </tr>
    </thead>
    <tbody>
        {{#categoryTotals}}
        <tr>
            <td>{{category}}</td>
            <td>{{total}}</td>
        </tr>
        {{/categoryTotals}}
    </tbody>
</table>
`;