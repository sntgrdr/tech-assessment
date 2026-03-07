import React, { createContext, useContext, useState, useEffect } from 'react';
import api from '../services/api';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Check if user is authenticated on mount
  useEffect(() => {
    let isMounted = true; // Control de montaje

    const checkAuth = async () => {
      try {
        const token = localStorage.getItem('authToken');
        if (token && isMounted) {
          const userData = await api.getCurrentUser();
          if (isMounted) setUser(userData.person);
        }
      } catch (error) {
        // ... tu lógica de error ...
      } finally {
        if (isMounted) setLoading(false);
      }
    };

    checkAuth();

    return () => { isMounted = false; }; // Se ejecuta al desmontar el test
  }, []);

  const login = async (email, password) => {
    try {
      setError(null);
      setLoading(true);
      const data = await api.login(email, password);
      setUser(data.person);
      return data;
    } catch (error) {
      setError(error.message);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const logout = async () => {
    try {
      setLoading(true);
      await api.logout();
      setUser(null);
      setError(null);
    } catch (error) {
      console.error('Logout error:', error);
      // Still logout locally even if API call fails
      setUser(null);
      setError(null);
    } finally {
      setLoading(false);
    }
  };

  const isAuthenticated = !!user;

  const value = {
    user,
    loading,
    error,
    login,
    logout,
    isAuthenticated,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
