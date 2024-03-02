import { ExpenseCategory } from './ExpenseCategory';

export interface NewExpenseItem {
    description: string;
    amount: number;
    date: string;
    categoryId: string;
  }
  