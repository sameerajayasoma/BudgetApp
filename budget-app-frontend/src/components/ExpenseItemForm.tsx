import React, { useState, useEffect } from 'react';
import { NewExpenseItem } from '../types/NewExpenseItem';
import { ExpenseCategory } from '../types/ExpenseCategory';
import { fetchExpenseCategories } from '../services/ExpenseCategoryService';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

interface ExpenseItemFormProps {
    onSave: (item: NewExpenseItem) => void;
    itemToEdit?: NewExpenseItem; // Optional prop for editing an existing item
}

const ExpenseItemForm: React.FC<ExpenseItemFormProps> = ({ onSave, itemToEdit }) => {
    const [item, setItem] = useState<NewExpenseItem>({
        id: '',
        description: '', amount: '', date: '', categoryId: ''
    });
    const [categories, setCategories] = useState<ExpenseCategory[]>([]);
    const [errors, setErrors] = useState({
        description: '',
        amount: '',
        date: '',
        comment: '',
        categoryId: '',
    });

    useEffect(() => {
        // If itemToEdit changes and is not undefined, set it as the current item
        fetchExpenseCategories().then(setCategories);
        if (itemToEdit) {
            setItem(itemToEdit);
        }
    }, [itemToEdit]);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;

        // Update form field value
        setItem({ ...item, [name]: value });

        // Reset error for current field
        const newErrors = { ...errors, [name]: '' };

        // Field-specific validation
        if (name === 'amount') {
            // General number structure check, including negative numbers and decimal points
            if (!value.trim() || !/^-?\d*\.?\d*$/.test(value)) {
                newErrors[name] = 'Please enter a valid number.';
            } else if (value.endsWith('.')) { // Specific check for trailing decimal point
                // If you want to allow a trailing dot as a valid input, remove this condition
                newErrors[name] = 'The number cannot end with a decimal point.';
            } else if (parseFloat(value) <= 0) {
                newErrors[name] = 'Amount must be greater than 0.';
            }
        } else if (name === 'description' && !value.trim()) {
            newErrors[name] = 'Description is required.';
        } else if (name === 'date' && !value) {
            newErrors[name] = 'Date is required.';
        } else if (name === 'categoryId' && !value) {
            newErrors[name] = 'Category is required.';
        }

        // Update errors state
        setErrors(newErrors);
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();

        // Check if there are any errors
        const hasErrors = Object.values(errors).some(error => error !== '');
        if (hasErrors) {
            toast.error("Please correct the errors before submitting.");
            return;
        }

        if (!item.description || !item.amount || !item.date || !item.categoryId) {
            toast.error("Please fill in all fields before submitting.");
            return;
        }

        onSave(item);
        // Reset form to initial state
        setItem({ id: '', description: '', amount: '', date: '', categoryId: '' });
    };

    const handleReset = () => {
        // Reset the item state to initial form values
        setItem({ id: '', description: '', amount: '', date: '', categoryId: '' });
    };

    return (
        <div>
            <form onSubmit={handleSubmit} className="mt-4">
                <div className="form-group">
                    <label htmlFor="description">Description</label>
                    <input
                        type="text"
                        className={`form-control ${errors.description ? 'is-invalid' : ''}`}
                        id="description"
                        name="description"
                        value={item.description}
                        onChange={handleChange}
                    />
                    {errors.description && <div className="invalid-feedback">{errors.description}</div>}
                </div>
                <div className="form-group">
                    <label htmlFor="amount">Amount</label>
                    <input
                        type="text"
                        className={`form-control ${errors.amount ? 'is-invalid' : ''}`}
                        id="amount"
                        name="amount"
                        value={item.amount}
                        onChange={handleChange}
                        step="0.01"
                    />
                    {errors.amount && <div className="invalid-feedback">{errors.amount}</div>}
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
                        className={`form-control ${errors.date ? 'is-invalid' : ''}`}
                        id="date"
                        name="date"
                        value={item.date}
                        onChange={handleChange}
                    />
                    {errors.date && <div className="invalid-feedback">{errors.date}</div>}
                </div>
                <div className="form-group">
                    <label htmlFor="category">Category</label>
                    <select
                        className={`form-control ${errors.categoryId ? 'is-invalid' : ''}`}
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
                    {errors.categoryId && <div className="invalid-feedback">{errors.categoryId}</div>}
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
        </div>
    );
};

export default ExpenseItemForm;
