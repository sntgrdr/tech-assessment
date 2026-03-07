const API_BASE_URL = 'http://localhost:3000/api/v1';

// Get token from localStorage
const getToken = () => {
  return localStorage.getItem('authToken');
};

// Set token in localStorage
const setToken = (token) => {
  localStorage.setItem('authToken', token);
};

// Remove token from localStorage
const removeToken = () => {
  localStorage.removeItem('authToken');
};

// Create axios instance with base configuration
const api = {
  // Login
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

  // Logout
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

  // Get current user
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
      // Only remove token for 401 errors, not network errors
      if (error.message.includes('No token found')) {
        removeToken();
      }
      throw error;
    }
  },

  // Get orders
  getOrders: async () => {
    try {
      const token = getToken();
      if (!token) throw new Error('No token found');

      const response = await fetch(`${API_BASE_URL}/orders`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to fetch orders');
      }

      return await response.json();
    } catch (error) {
      throw error;
    }
  },

  // Create order
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

  // Get dashboard stats
  getStats: async () => {
    try {
      const token = getToken();
      if (!token) throw new Error('No token found');

      const response = await fetch(`${API_BASE_URL}/orders/stats`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to fetch stats');
      }

      return await response.json();
    } catch (error) {
      throw error;
    }
  },
};

export default api;
