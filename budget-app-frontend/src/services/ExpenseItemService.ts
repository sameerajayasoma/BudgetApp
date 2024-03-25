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

// Function to convert local date to UTC date string in RFC 3339 format
const toUTCDateString = (localDate: string): string => {
  // Create a Date object for the user-entered date in the user's local timezone
  const dateInLocalTimeZone = new Date(localDate);

  // Convert the local Date object to a UTC string in RFC 3339 format
  const dateInUTC = dateInLocalTimeZone.toISOString();
  return dateInUTC;
};

export const fetchExpenseItems = async (): Promise<ExpenseItem[]> => {
  const response = await axios.get<ExpenseItem[]>(API_URL);
  // Assuming the dates are returned as UTC, consider converting them to the user's local timezone if needed
  return response.data.map(item => ({
    ...item,
  }));
};

export const createExpenseItem = async (expenseItem: NewExpenseItem): Promise<ExpenseItem> => {
  // Convert date to RFC 3339 UTC format before sending
  let newExpenseItem = {
    description: expenseItem.description,
    comment: expenseItem.comment,
    categoryId: expenseItem.categoryId,
    amount: parseFloat(expenseItem.amount),
    dateTime: toUTCDateString(expenseItem.dateTime),
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
  // Convert date to RFC 3339 UTC format before sending
  let newExpenseItem = {
    ...expenseItem,
    id: id,
    amount: parseFloat(expenseItem.amount),
    dateTime: toUTCDateString(expenseItem.dateTime),
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
