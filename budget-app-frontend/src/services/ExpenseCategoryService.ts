import axios from 'axios';

import { ExpenseCategory } from '../types/ExpenseCategory';

interface Window {
  config: {
    apiUrl: string;
    apiKey: string;
  };
}

declare const window: Window;

const API_BASE_URL = window.config.apiUrl; // Adjust this URL to your actual API base URL


export const fetchExpenseCategories = async (): Promise<ExpenseCategory[]> => {
  try {
    const response = await axios.get<ExpenseCategory[]>(`${API_BASE_URL}/expenseCategories`);
    return response.data;
  } catch (error) {
    console.error('Failed to fetch expense categories:', error);
    throw error;
  }
};
