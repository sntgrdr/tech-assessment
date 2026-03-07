import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import DashboardHeader from '../components/dashboard/DashboardHeader';
import StatsGrid from '../components/dashboard/StatsGrid';
import OrdersList from '../components/dashboard/OrdersList';
import Modal from '../components/ui/Modal';
import CreateOrderForm from '../components/orders/CreateOrderForm';

const DashboardPage = () => {
  const { logout } = useAuth();
  const [stats, setStats] = useState({});
  const [orders, setOrders] = useState([]);
  const [statsLoading, setStatsLoading] = useState(true);
  const [ordersLoading, setOrdersLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [error, setError] = useState(null);

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

  const fetchOrders = async () => {
    try {
      setOrdersLoading(true);
      const ordersData = await api.getOrders();
      setOrders(ordersData);
    } catch (error) {
      console.error('Failed to fetch orders:', error);
      setError('Failed to load orders');
    } finally {
      setOrdersLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
    fetchOrders();
  }, []);

  const handleCreateOrder = () => {
    setShowCreateModal(true);
  };

  const handleOrderCreated = () => {
    // Refresh both stats and orders when a new order is created
    fetchStats();
    fetchOrders();
  };

  const handleLogout = async () => {
    await logout();
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <DashboardHeader 
        onCreateOrder={handleCreateOrder}
        onLogout={handleLogout}
      />
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {error && (
          <div className="mb-6 rounded-md bg-red-50 p-4">
            <div className="flex">
              <div className="flex-shrink-0">
                <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                </svg>
              </div>
              <div className="ml-3">
                <h3 className="text-sm font-medium text-red-800">Error</h3>
                <div className="mt-2 text-sm text-red-700">
                  {error}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Stats Grid */}
        <div className="mb-8">
          <StatsGrid stats={stats} loading={statsLoading} />
        </div>

        {/* Orders List */}
        <div>
          <OrdersList orders={orders} loading={ordersLoading} />
        </div>
      </main>

      {/* Create Order Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        title="Create New Order"
        size="md"
      >
        <CreateOrderForm
          onClose={() => setShowCreateModal(false)}
          onOrderCreated={handleOrderCreated}
        />
      </Modal>
    </div>
  );
};

export default DashboardPage;
