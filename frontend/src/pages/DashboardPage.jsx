import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import DashboardHeader from '../components/dashboard/DashboardHeader';
import StatsGrid from '../components/dashboard/StatsGrid';
import OrdersList from '../components/dashboard/OrdersList';
import OrderFilters from '../components/dashboard/OrderFilters';

const DashboardPage = () => {
  const { logout, user } = useAuth();
  const [stats, setStats] = useState({});
  const [orders, setOrders] = useState([]);
  const [pagination, setPagination] = useState(null);
  const [statsLoading, setStatsLoading] = useState(true);
  const [ordersLoading, setOrdersLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [error, setError] = useState(null);
  const [currentFilter, setCurrentFilter] = useState('all');
  const [filters, setFilters] = useState({
    status: 'all',
    email: '',
    from: '',
    to: '',
    number: ''
  });

  const fetchStats = async () => {
    try {
      setStatsLoading(true);
      const statsData = await api.getStats();
      setStats(statsData);
    } catch (error) {
      console.error('Failed to fetch stats:', error);
      setError('Failed to load dashboard statistics');
    } finally {
      setStatsLoading(false);
    }
  };

  const fetchOrders = async (page = 1, newFilters = filters) => {
  try {
    setOrdersLoading(true);
    const data = await api.getOrders({ page, ...newFilters });

    setOrders(data.orders);
    setPagination(data.pagination);
    setStats(data.stats);
    setFilters(newFilters);
  } catch (error) {
    setError('Failed to load data');
  } finally {
    setOrdersLoading(false);
  }
};

  useEffect(() => {
    fetchStats();
    fetchOrders(1, filters);
  }, []);

  const handleFilterClick = (status) => {
    const newStatus = filters.status === status ? 'all' : status;

    const updatedFilters = {
      ...filters,
      status: newStatus
    };

    setFilters(updatedFilters);
    fetchOrders(1, updatedFilters);
  };

  const handlePageChange = (page) => {
    fetchOrders(page, currentFilter);
  };

  const handleFilterChange = (newFilters) => {
    setFilters(newFilters);
    fetchOrders(1, newFilters);
  };

  const handleUpdateStatus = async (id, newStatus) => {
    try {
      setError(null);
      const updatedOrder = await api.updateOrder(id, { status: newStatus });

      setOrders(prevOrders =>
        prevOrders.map(order => order.id === id ? { ...order, status: updatedOrder.status } : order)
      );

      fetchStats();
      // Refetch current view to ensure consistency
      fetchOrders(pagination?.page || 1, currentFilter);
      return true;
    } catch (err) {
      const message = err.response?.data?.errors || 'Failed to update order status';
      setError(message);
      return false;
    }
  };

  const handleDeleteOrder = async (id) => {
    if (!window.confirm('Are you sure you want to delete this order?')) return;

    try {
      setError(null);
      await api.deleteOrder(id);

      setOrders(prevOrders => prevOrders.filter(order => order.id !== id));
      fetchStats();

      fetchOrders(pagination?.page || 1);
    } catch (err) {
      const message = err.response?.data?.error || 'Failed to delete order';
      setError(message);
    }
  };

  const handleCreateOrder = () => {
    setShowCreateModal(true);
  };

  const handleOrderCreated = () => {
    setShowCreateModal(false);
    fetchStats();
    fetchOrders(1);
  };

  const handleLogout = async () => {
    await logout();
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <DashboardHeader onCreateOrder={handleCreateOrder} onLogout={handleLogout} />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Error handling alert remains the same */}

        <OrderFilters
          filters={filters}
          onFilterChange={handleFilterChange}
        />

        <div className="mb-8">
          <StatsGrid
            stats={stats}
            activeFilter={filters.status}
            onFilterClick={handleFilterClick}
            loading={statsLoading}
          />
        </div>

        <div>
          <OrdersList
            orders={orders}
            pagination={pagination}
            loading={ordersLoading}
            onUpdateStatus={handleUpdateStatus}
            onDelete={handleDeleteOrder}
            onPageChange={handlePageChange} // Use the fixed page change handler
            serverError={error}
            currentUser={user}
            clearError={() => setError(null)}
          />
        </div>
      </main>

      {/* Modal remains the same */}
    </div>
  );
};

export default DashboardPage;
