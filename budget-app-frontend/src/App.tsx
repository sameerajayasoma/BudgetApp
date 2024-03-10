import React, { useState, useEffect } from 'react';
import { ExpenseItem } from './types/ExpenseItem';
import { fetchExpenseItems, createExpenseItem, updateExpenseItem, deleteExpenseItem } from './services/ExpenseItemService';
import ExpenseItemsList from './components/ExpenseItemsList';
import ExpenseItemForm from './components/ExpenseItemForm';


const App: React.FC = () => {
  const [expenseItems, setExpenseItems] = useState<ExpenseItem[]>([]);
  const [editingItem, setEditingItem] = useState<ExpenseItem | null>(null);


  useEffect(() => {
    loadExpenseItems();
  }, []);

  const loadExpenseItems = async () => {
    const items = await fetchExpenseItems();
    setExpenseItems(items);
  };

  // const handleSaveExpenseItem1 = async (item: NewExpenseItem) => {
  //   await createExpenseItem(item);
  //   loadExpenseItems();
  //   setEditingItem(null); // Reset editing item after saving
  // };

  const handleSaveExpenseItem = async (item: ExpenseItem) => {
    if (item.id) {
      await updateExpenseItem(item.id, item);
    } else {
      await createExpenseItem(item);
    }
    loadExpenseItems();
    setEditingItem(null); // Reset editing item after saving
  };

  const handleEditExpenseItem = (item: ExpenseItem) => {
    setEditingItem(item);
  };

  const handleDeleteExpenseItem = async (id: string) => {
    await deleteExpenseItem(id);
    loadExpenseItems();
  };

  const handleAddNew = () => {
    setEditingItem({id: '', description: '', amount: 0, date: '', categoryId: '' }); // Reset form for new entry
  };

  // return (
  //   <div className="App">
  //     <h1>Expense Tracker</h1>
  //     {/* Assume ExpenseItemForm is being used here to create or update expense items */}
  //     <ExpenseItemsList items={expenseItems} onDelete={handleDeleteExpenseItem} />
  //   </div>
  // );

  return (
    <div className="container mt-5">
      <h1>Expense Tracker</h1>
      <button className="btn btn-primary mb-3" onClick={handleAddNew}>Add New Expense</button>
      {editingItem && <ExpenseItemForm onSave={handleSaveExpenseItem} itemToEdit={editingItem} />}
      <ExpenseItemsList items={expenseItems} onDelete={handleDeleteExpenseItem} onEdit={handleEditExpenseItem} />
    </div>
  );
};

export default App;
