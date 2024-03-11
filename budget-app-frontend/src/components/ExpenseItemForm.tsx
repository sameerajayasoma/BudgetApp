import React, { useState, useEffect } from 'react';
import { ExpenseItem } from '../types/ExpenseItem';
import { ExpenseCategory } from '../types/ExpenseCategory';
import { fetchExpenseCategories } from '../services/ExpenseCategoryService';

interface ExpenseItemFormProps {
    onSave: (item: ExpenseItem) => void;
    itemToEdit?: ExpenseItem; // Optional prop for editing an existing item
}

const ExpenseItemForm: React.FC<ExpenseItemFormProps> = ({ onSave, itemToEdit }) => {
    const [item, setItem] = useState<ExpenseItem>({ id: '', description: '', amount: 0, date: '', categoryId: '' });
    const [categories, setCategories] = useState<ExpenseCategory[]>([]);

    useEffect(() => {
        // If itemToEdit changes and is not undefined, set it as the current item
        fetchExpenseCategories().then(setCategories);
        if (itemToEdit) {
            setItem(itemToEdit);
        }
    }, [itemToEdit]);


    // const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    //     const { name, value } = e.target;
    //     setItem({ ...item, [name]: name === 'amount' ? parseFloat(value) || 0 : value });
    // };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
    
        if (name === 'amount') {
            // Regex to check if the value is a valid number (including incomplete decimals)
            const isValidNumber = /^-?\d*\.?\d*$/.test(value);
    
            if (isValidNumber || value === "") {
                // Update state with the string value to preserve user input
                setItem({ ...item, [name]: parseFloat(value) });
            }
        } else {
            // Handle changes for other fields normally
            setItem({ ...item, [name]: value });
        }
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        if (!item.description || !item.amount || !item.date || !item.categoryId) {
            alert('Please fill in all fields');
            return;
        }
        onSave(item);
        // Reset form to initial state
        setItem({ id: '', description: '', amount: 0, date: '', categoryId: '' });
    };

    const handleReset = () => {
        // Reset the item state to initial form values
        setItem({ id: '', description: '', amount: 0, date: '', categoryId: '' });
    };

    return (
        <form onSubmit={handleSubmit} className="mt-4">
            <div className="form-group">
                <label htmlFor="description">Description</label>
                <input
                    type="text"
                    className="form-control"
                    id="description"
                    name="description"
                    value={item.description}
                    onChange={handleChange}
                />
            </div>
            <div className="form-group">
                <label htmlFor="amount">Amount</label>
                <input
                    type="number"
                    className="form-control"
                    id="amount"
                    name="amount"
                    value={item.amount.toString()}
                    onChange={handleChange}
                    step="0.01"
                />
            </div>
            <div className="form-group">
                <label htmlFor="comment">Comment</label>
                <input
                    type="text"
                    className="form-control"
                    id="comment"
                    name="comment"
                    value={item.comment}
                    onChange={handleChange}
                />
            </div>
            <div className="form-group">
                <label htmlFor="date">Date</label>
                <input
                    type="date"
                    className="form-control"
                    id="date"
                    name="date"
                    value={item.date}
                    onChange={handleChange}
                />
            </div>
            <div className="form-group">
                <label htmlFor="category">Category</label>
                <select
                    className="form-control"
                    id="categoryId"
                    value={item.categoryId}
                    onChange={(e) => setItem({ ...item, categoryId: e.target.value })}
                >
                    <option value="" disabled>Select a category</option> {/* Placeholder option */}
                    {categories.map((category) => (
                        <option key={category.id} value={category.id}>
                            {category.name}
                        </option>
                    ))}
                </select>
            </div>
            <div className="form-group d-flex mt-3">
                <button type="submit" className="btn btn-primary m-1">
                    Save
                </button>
                <button type="button" className="btn btn-secondary m-1" onClick={handleReset}>
                    Reset
                </button>
            </div>
        </form>
    );
};

export default ExpenseItemForm;
