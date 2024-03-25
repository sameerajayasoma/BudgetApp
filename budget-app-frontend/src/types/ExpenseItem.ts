import { ExpenseCategory } from './ExpenseCategory';

export interface ExpenseItem {
    id: string;
    description: string;
    amount: number;
    dateTime: string;
    comment?: string;
    categoryId: string;
    category?: ExpenseCategory;
  }
  