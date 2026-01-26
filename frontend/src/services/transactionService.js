import api from './api';

export default {
  getTransactions(params) {
    return api.get('/transactions', { params });
  },
  
  getTransactionsByPeriod(startDate, endDate, userId = 9) {
    return api.get('/transactions/period', {
      params: { start: startDate, end: endDate, userId }
    });
  },
  
  createTransaction(transaction) {
    return api.post('/transactions', transaction);
  },
  
  updateTransaction(id, transaction) {
    return api.put(`/transactions/${id}`, transaction);
  },
  
  deleteTransaction(id, type, userId = 9) {
    if (type === 'INCOME') {
      return api.delete(`/transactions/income/${id}`, { params: { userId } });
    } else {
      return api.delete(`/transactions/expense/${id}`, { params: { userId } });
    }
  },
  
  exportExcel(startDate, endDate, userId = 9) {
    return api.get('/transactions/export/excel', {
      params: { start: startDate, end: endDate, userId },
      responseType: 'blob'
    }).then(response => {
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `transactions_${startDate}_${endDate}.xlsx`);
      document.body.appendChild(link);
      link.click();
      link.remove();
    });
  },
  
  getMonthlySummary(year, month, userId = 9) {
    return api.get(`/transactions/monthly/${year}/${month}/summary`, {
      params: { userId }
    });
  },
  
  exportToExcel(startDate, endDate, userId = 9) {
    return api.get('/transactions/export/excel', {
      params: { start: startDate, end: endDate, userId },
      responseType: 'blob'
    });
  },
  
  importFromExcel(file, userId = 9) {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('userId', userId);
    return api.post('/transactions/import/excel', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
  },

  createIncome(income, userId = 9) {
    return api.post('/transactions/income', income, { params: { userId } });
  },

  createExpense(expense, userId = 9) {
    return api.post('/transactions/expense', expense, { params: { userId } });
  },

  updateIncome(id, income, userId = 9) {
    return api.put(`/transactions/income/${id}`, income, { params: { userId } });
  },

  updateExpense(id, expense, userId = 9) {
    return api.put(`/transactions/expense/${id}`, expense, { params: { userId } });
  },

  deleteIncome(id, userId = 9) {
    return api.delete(`/transactions/income/${id}`, { params: { userId } });
  },

  deleteExpense(id, userId = 9) {
    return api.delete(`/transactions/expense/${id}`, { params: { userId } });
  }
};
