import axios from 'axios';
import { ExpenseItem } from '../types/ExpenseItem';
import { NewExpenseItem } from '../types/NewExpenseItem';


const API_URL = 'http://localhost:8081/budgetapp/expenses'; // Adjust this URL to your API's actual endpoint

export const fetchExpenseItems = async (): Promise<ExpenseItem[]> => {
  const response = await axios.get<ExpenseItem[]>(API_URL);
  return response.data;
};

export const createExpenseItem = async (expenseItem: NewExpenseItem): Promise<ExpenseItem> => {
  console.log(expenseItem);
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
