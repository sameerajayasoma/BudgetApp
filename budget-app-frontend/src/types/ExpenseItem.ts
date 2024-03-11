import { ExpenseCategory } from './ExpenseCategory';

export interface ExpenseItem {
    id: string;
    description: string;
    amount: number;
    date: string;
    comment?: string;
    categoryId: string;
    category?: ExpenseCategory;
  }
  