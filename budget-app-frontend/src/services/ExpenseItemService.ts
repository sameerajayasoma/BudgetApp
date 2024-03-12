import axios from 'axios';
import { ExpenseItem } from '../types/ExpenseItem';
import { NewExpenseItem } from '../types/NewExpenseItem';

interface Window {
  config: {
    apiUrl: string;
    apiKey: string;
  };
}

declare const window: Window;

const API_URL = window.config.apiUrl + '/expenses';

export const fetchExpenseItems = async (): Promise<ExpenseItem[]> => {
  const response = await axios.get<ExpenseItem[]>(API_URL);
  return response.data;
};

export const createExpenseItem = async (expenseItem: NewExpenseItem): Promise<ExpenseItem> => {
  let newExpenseItem = {
    description: expenseItem.description,
    amount: parseFloat(expenseItem.amount), 
    date: expenseItem.date, 
    comment: expenseItem.comment,
    categoryId: expenseItem.categoryId
  };
  const response = await axios.post<ExpenseItem>(API_URL, newExpenseItem);
  return response.data;
};

export const updateExpenseItem = async (id: string, expenseItem: NewExpenseItem): Promise<ExpenseItem> => {
  let newExpenseItem = {
    id:expenseItem.id,
    description: expenseItem.description,
    amount: parseFloat(expenseItem.amount), 
    date: expenseItem.date, 
    comment: expenseItem.comment || "",
    categoryId: expenseItem.categoryId
  };
  const response = await axios.put<ExpenseItem>(`${API_URL}/${id}`, newExpenseItem);
  return response.data;
};

export const deleteExpenseItem = async (id: string): Promise<void> => {
  await axios.delete(`${API_URL}/${id}`);
};
