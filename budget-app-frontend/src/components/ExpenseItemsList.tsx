import React, { useState, useEffect } from 'react';
import { ExpenseItem } from '../types/ExpenseItem';
import { ExpenseCategory } from '../types/ExpenseCategory';
import { fetchExpenseCategories } from '../services/ExpenseCategoryService';
import Modal from 'react-bootstrap/Modal';
import Button from 'react-bootstrap/Button';

interface ExpenseItemsListProps {
  items: ExpenseItem[];
  onDelete: (id: string) => void;
  onEdit: (item: ExpenseItem) => void;
  isLoading: boolean;
}

const ExpenseItemsList: React.FC<ExpenseItemsListProps> = ({ items, onDelete, onEdit, isLoading }) => {
  const [categories, setCategories] = useState<ExpenseCategory[]>([]);
  const [showCommentModal, setShowCommentModal] = useState(false);
  const [currentComment, setCurrentComment] = useState('');
  const [expandedCommentId, setExpandedCommentId] = useState<String | null>(null);

  // TODO Can we load categories only once during the app load?
  useEffect(() => {
    fetchExpenseCategories().then(setCategories);
  }, []);

  const categoryMap = new Map(categories.map(category => [category.id, category]));

  const handleShowCommentClick = (comment: string): void => {
    setCurrentComment(comment);
    setShowCommentModal(true);
  };

  const bgClasses = ['bg-light', 'bg-light'];

  if (isLoading) {
    return (
      <div>
        <h2 className="mt-3">Expense Items</h2>
        <table className="table table-striped mt-3">
          <thead className="thead-dark">
            <tr>
              <th>Description</th>
              <th>Amount</th>
              <th>Date</th>
              <th>Category</th>
              <th>Comment</th>
              <th>Actions</th>
            </tr>
          </thead>
        </table>
        <div>Loading expenses...</div>
      </div>
    );
  }

  return (
    <div>
      <h2>Expense Items</h2>
      <div className="d-none d-md-block"> {/* Table shown only on md screens and up */}
        <div className="table-responsive">
          <table className="table table-striped mt-3">
            <thead className="thead-dark">
              <tr>
                <th>Description</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Category</th>
                <th>Comment</th>
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
                    <button className="btn btn-outline-info" onClick={() => handleShowCommentClick(item.comment || 'No comment available')}>Show Comment</button>
                  </td>
                  <td>
                    <button className="btn btn-outline-warning m-1" onClick={() => onEdit(item)}>Edit</button>
                    <button className="btn btn-outline-danger" onClick={() => onDelete(item.id)}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {items.length === 0 && <p>No expense items found.</p>}
        </div>
      </div>
      <div className="d-md-none"> {/* Cards shown on screens smaller than md */}
        {items.map((item, index) => (
          <div key={item.id} className={`card mb-3 ${bgClasses[index % bgClasses.length]} text-dark`}>
            <div className="card-body">
              <div className="d-flex justify-content-between align-items-center">
                <h5 className="card-title mb-0">{item.description}</h5>
                <span className="text-muted" style={{ fontSize: '1.25rem' }}>${item.amount.toFixed(2)}</span>
              </div>
              <div className="text-muted" style={{ fontSize: '0.875rem' }}>{new Date(item.date).toLocaleDateString()}</div>
              <div className="mb-2 text-muted" style={{ fontSize: '0.875rem' }}>{categoryMap.get(item.categoryId)?.name || 'No Category'}</div>
              <div>
                {/* <button className="btn btn-outline-info btn-sm" onClick={() => handleShowCommentClick(item.comment || 'No comment available')}>
                  Show Comment
                </button> */}
                <button
                  className="btn btn-link"
                  onClick={(e) => {
                    e.preventDefault(); // Prevent default if using <a>
                    setExpandedCommentId(expandedCommentId === item.id ? null : item.id);
                  }}
                >
                  {expandedCommentId === item.id ? 'Hide Comment' : 'Show Comment'}
                </button>

                {expandedCommentId === item.id && (
                  <div className="mt-2">
                    <p className="card-text">{item.comment || 'No comment available'}</p>
                  </div>
                )}
                <button className="btn btn-outline-warning btn-sm m-1" onClick={() => onEdit(item)}>Edit</button>
                <button className="btn btn-outline-danger btn-sm" onClick={() => onDelete(item.id)}>Delete</button>
                {/* <button className="btn btn-warning btn-sm m-1" onClick={() => onEdit(item)}><i className="bi bi-pencil"></i></button> */}
                {/* <button className="btn btn-danger btn-sm" onClick={() => onDelete(item.id)}><i className="bi bi-trash"></i></button> */}
              </div>
            </div>
          </div>
        ))}
      </div>


      <Modal show={showCommentModal} onHide={() => setShowCommentModal(false)}>
        <Modal.Header closeButton>
          <Modal.Title>Comment</Modal.Title>
        </Modal.Header>
        <Modal.Body>{currentComment}</Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setShowCommentModal(false)}>
            Close
          </Button>
        </Modal.Footer>
      </Modal>
    </div>
  );
};

export default ExpenseItemsList;
