const API_BASE_URL = 'http://localhost:3000/api/v1';

const getToken = () => localStorage.getItem('authToken');
const setToken = (token) => localStorage.setItem('authToken', token);
const removeToken = () => localStorage.removeItem('authToken');

const api = {
  login: async (email, password) => {
    try {
      const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Login failed');
      }

      const data = await response.json();
      setToken(data.token);
      return data;
    } catch (error) {
      throw error;
    }
  },

  logout: async () => {
    try {
      const token = getToken();
      if (token) {
        await fetch(`${API_BASE_URL}/auth/logout`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
        });
      }
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      removeToken();
    }
  },

  getCurrentUser: async () => {
    try {
      const token = getToken();
      if (!token) throw new Error('No token found');

      const response = await fetch(`${API_BASE_URL}/auth/current_user`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        if (response.status === 401) {
          removeToken();
        }
        throw new Error('Failed to get current user');
      }

      return await response.json();
    } catch (error) {
      if (error.message.includes('No token found')) {
        removeToken();
      }
      throw error;
    }
  },

  getOrders: async (filters = {}) => {
    const { page = 1, status = 'all', email = '', from = '', to = '', number = '' } = filters;
    const token = getToken();

    const query = new URLSearchParams({
      page,
      status,
      email,
      from_date: from,
      to_date: to,
      number
    }).toString();

    const response = await fetch(`${API_BASE_URL}/orders?${query}`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await response.json();
  },

  createOrder: async (orderData) => {
    try {
      const token = getToken();
      if (!token) throw new Error('No token found');

      const response = await fetch(`${API_BASE_URL}/orders`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ order: orderData }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.errors || 'Failed to create order');
      }

      return await response.json();
    } catch (error) {
      throw error;
    }
  },

  updateOrder: async (id, orderParams) => {
    try {
      const token = getToken();
      if (!token) throw new Error('No token found');

      const response = await fetch(`${API_BASE_URL}/orders/${id}`, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ order: orderParams }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.errors || 'Failed to update order');
      }

      return await response.json();
    } catch (error) {
      throw error;
    }
  },

  deleteOrder: async (id) => {
    try {
      const token = getToken();
      if (!token) throw new Error('No token found');

      const response = await fetch(`${API_BASE_URL}/orders/${id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Failed to delete order');
      }

      if (response.status === 204) return true;
      return await response.json();
    } catch (error) {
      throw error;
    }
  }
};

export default api;
