import React, { useState, useEffect } from 'react';
import { ExpenseItem } from '../types/ExpenseItem';
import { ExpenseCategory } from '../types/ExpenseCategory';
import { fetchExpenseCategories } from '../services/ExpenseCategoryService';

interface ExpenseItemsListProps {
  items: ExpenseItem[];
  onDelete: (id: string) => void;
  onEdit: (item: ExpenseItem) => void;
}

const ExpenseItemsList: React.FC<ExpenseItemsListProps> = ({ items, onDelete }) => {
  const [categories, setCategories] = useState<ExpenseCategory[]>([]);

  // TODO Can we load categories only once during the app load?
  useEffect(() => {
    fetchExpenseCategories().then(setCategories);
  }, []);

  const categoryMap = new Map(categories.map(category => [category.id, category]));

  return (
    <div>
      <h2 className="mt-3">Expense Items</h2>
      <table className="table table-striped mt-3">
        <thead className="thead-dark">
          <tr>
            <th>Description</th>
            <th>Amount</th>
            <th>Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={item.id}>
              <td>{item.description}</td>
              <td>{item.amount.toFixed(2)}</td>
              <td>{item.date}</td>
              <td>{categoryMap.get(item.categoryId)?.name || 'No Category'}</td>
              <td>
                <button className="btn btn-danger" onClick={() => onDelete(item.id)}>Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {items.length === 0 && <p>No expense items found.</p>}
    </div>
  );
};

export default ExpenseItemsList;
