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


// const API_URL = 'http://localhost:8081/budgetapp/expenses'; // Adjust this URL to your API's actual endpoint

const API_URL = window.config.apiUrl + '/expenses';

export const fetchExpenseItems = async (): Promise<ExpenseItem[]> => {
  const response = await axios.get<ExpenseItem[]>(API_URL);
  return response.data;
};

export const createExpenseItem = async (expenseItem: ExpenseItem): Promise<ExpenseItem> => {
  let newExpenseItem = {
    description: expenseItem.description,
    amount: expenseItem.amount, 
    date: expenseItem.date, 
    categoryId: expenseItem.categoryId
  };
  console.log(newExpenseItem);
  const response = await axios.post<ExpenseItem>(API_URL, expenseItem);
  return response.data;
};

export const updateExpenseItem = async (id: string, expenseItem: Partial<ExpenseItem>): Promise<ExpenseItem> => {
  const response = await axios.put<ExpenseItem>(`${API_URL}/${id}`, expenseItem);
  return response.data;
};

export const deleteExpenseItem = async (id: string): Promise<void> => {
  await axios.delete(`${API_URL}/${id}`);
};
