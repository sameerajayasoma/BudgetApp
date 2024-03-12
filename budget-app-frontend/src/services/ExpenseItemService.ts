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

  try {
    const response = await axios.post<ExpenseItem>(API_URL, newExpenseItem);
    return response.data;
  } catch (error) {
    console.error('Failed to create expense item:', error);
    throw error;
  }
};

export const updateExpenseItem = async (id: string, expenseItem: NewExpenseItem): Promise<ExpenseItem> => {
  let newExpenseItem = {
    id:expenseItem.id,
    description: expenseItem.description,
    amount: parseFloat(expenseItem.amount), 
    date: expenseItem.date, 
    comment: expenseItem.comment || "", // TODO This seems like a bug in the API
    categoryId: expenseItem.categoryId
  };

  try {
    const response = await axios.put<ExpenseItem>(`${API_URL}/${id}`, newExpenseItem);
    return response.data;
  } catch (error) {
    console.error('Failed to update expense item:', error);
    throw error;
  }
};

export const deleteExpenseItem = async (id: string): Promise<void> => {
  try {
    await axios.delete(`${API_URL}/${id}`);
  } catch (error) {
    console.error('Failed to delete expense item:', error);
    throw error;
  } 
};
