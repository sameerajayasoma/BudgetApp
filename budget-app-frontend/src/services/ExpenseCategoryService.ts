import axios from 'axios';
import { ExpenseCategory } from '../types/ExpenseCategory';

const API_BASE_URL = 'http://localhost:8081/budgetapp'; // Adjust this URL to your actual API base URL

export const fetchExpenseCategories = async (): Promise<ExpenseCategory[]> => {
  try {
    const response = await axios.get<ExpenseCategory[]>(`${API_BASE_URL}/expenseCategories`);
    return response.data;
  } catch (error) {
    console.error('Failed to fetch expense categories:', error);
    // Handle or throw error appropriately
    throw error;
  }
};
