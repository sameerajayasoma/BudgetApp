import { ExpenseCategory } from "./ExpenseCategory";

export interface NewExpenseItem {
  id: string;
  description: string;
  amount: string;
  date: string;
  comment?: string;
  categoryId: string;
  category?: ExpenseCategory;
}
