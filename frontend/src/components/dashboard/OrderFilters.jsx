import { useState, useEffect } from 'react';

const OrderFilters = ({ filters, onFilterChange }) => {
  const [searchTerm, setSearchTerm] = useState(filters.email);

  useEffect(() => {
    const delayDebounceFn = setTimeout(() => {
      if (searchTerm !== filters.email) {
        onFilterChange({ ...filters, email: searchTerm });
      }
    }, 500);

    return () => clearTimeout(delayDebounceFn);
  }, [searchTerm]);

  const handleInputChange = (field, value) => {
    onFilterChange({ ...filters, [field]: value });
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-100 mb-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label className="block text-xs font-medium text-gray-500 uppercase mb-1">
            Customer Email
          </label>
          <input
            type="text"
            placeholder="search@example.com"
            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border p-2"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        <div>
        <label className="block text-xs font-medium text-gray-500 uppercase mb-1">
          Order Number
        </label>
        <input
          type="text"
          placeholder="e.g. ORD-123"
          className="w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border p-2"
          value={filters.number || ''}
          onChange={(e) => onFilterChange({ ...filters, number: e.target.value })}
        />
      </div>

        <div>
          <label className="block text-xs font-medium text-gray-500 uppercase mb-1">
            From Date
          </label>
          <input
            type="date"
            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border p-2"
            value={filters.from || ''}
            onChange={(e) => handleInputChange('from', e.target.value)}
          />
        </div>

        <div>
          <label className="block text-xs font-medium text-gray-500 uppercase mb-1">
            To Date
          </label>
          <input
            type="date"
            className="w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border p-2"
            value={filters.to || ''}
            onChange={(e) => handleInputChange('to', e.target.value)}
          />
        </div>
      </div>

      {(filters.email || filters.from || filters.to || filters.status !== 'all') && (
        <div className="mt-3 flex justify-end">
          <button
            onClick={() => {
              setSearchTerm('');
              onFilterChange({ status: 'all', email: '', from: '', to: '' });
            }}
            className="text-xs text-indigo-600 hover:text-indigo-800 font-medium"
          >
            Clear all filters
          </button>
        </div>
      )}
    </div>
  );
};

export default OrderFilters;
