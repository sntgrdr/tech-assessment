import { useState } from 'react';
import api from '../../services/api';
import Button from '../ui/Button';
import Input from '../ui/Input';

const CreateOrderForm = ({ onClose, onOrderCreated }) => {
  const [formData, setFormData] = useState({
    total_amount: '',
    notes: '',
    order_date: new Date().toISOString().split('T')[0],
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));

    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.total_amount) {
      newErrors.total_amount = 'Total amount is required';
    } else if (isNaN(formData.total_amount) || parseFloat(formData.total_amount) <= 0) {
      newErrors.total_amount = 'Total amount must be greater than 0';
    }

    if (!formData.order_date) {
      newErrors.order_date = 'Order date is required';
    }

    return newErrors;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formErrors = validateForm();
    if (Object.keys(formErrors).length > 0) {
      setErrors(formErrors);
      return;
    }

    try {
      setLoading(true);

      const orderData = {
        ...formData,
        total_amount: parseFloat(formData.total_amount),
      };

      await api.createOrder(orderData);

      setFormData({
        total_amount: '',
        notes: '',
        order_date: new Date().toISOString().split('T')[0],
      });

      setErrors({});

      if (onOrderCreated) {
        onOrderCreated();
      }

      onClose();

    } catch (error) {
      setErrors({
        submit: error.message || 'Failed to create order'
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <Input
        label="Total Amount"
        name="total_amount"
        type="number"
        step="0.01"
        min="0.01"
        value={formData.total_amount}
        onChange={handleChange}
        error={errors.total_amount}
        placeholder="0.00"
        required
      />

      <div>
        <label htmlFor="order_date" className="block text-sm font-medium text-gray-700 mb-1">
          Order Date
        </label>
        <input
          type="date"
          id="order_date"
          name="order_date"
          value={formData.order_date}
          onChange={handleChange}
          className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
          required
        />
        {errors.order_date && (
          <p className="mt-1 text-sm text-red-600">
            {errors.order_date}
          </p>
        )}
      </div>

      <div>
        <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-1">
          Notes
        </label>
        <textarea
          id="notes"
          name="notes"
          value={formData.notes}
          onChange={handleChange}
          rows={3}
          className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
          placeholder="Optional notes about this order..."
        />
      </div>

      {errors.submit && (
        <div className="rounded-md bg-red-50 p-4">
          <div className="text-sm text-red-800">
            {errors.submit}
          </div>
        </div>
      )}

      <div className="flex justify-end space-x-3 pt-4">
        <Button
          type="button"
          variant="outline"
          onClick={onClose}
          disabled={loading}
        >
          Cancel
        </Button>
        <Button
          type="submit"
          loading={loading}
          disabled={loading}
        >
          Create Order
        </Button>
      </div>
    </form>
  );
};

export default CreateOrderForm;
