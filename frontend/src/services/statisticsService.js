import api from './api';

export default {
  getMonthlyStats(year) {
    return api.get(`/statistics/monthly/${year}`);
  },
  
  getCategoryStats(startDate, endDate, type) {
    return api.get('/statistics/category', {
      params: { start: startDate, end: endDate, type }
    });
  },

  async getMonthlyStatsFromTransactions(year, userId = 9) {
    const stats = [];
    for (let month = 1; month <= 12; month++) {
      try {
        const { data } = await api.get(`/transactions/monthly/${year}/${month}/summary`, {
          params: { userId }
        });
        stats.push({
          month,
          income: data.totalIncome || 0,
          expense: data.totalExpense || 0,
          balance: data.balance || 0
        });
      } catch {
        stats.push({ month, income: 0, expense: 0, balance: 0 });
      }
    }
    return stats;
  },

  async getCategoryStatsFromTransactions(startDate, endDate, userId = 9) {
    const { data } = await api.get('/transactions/period', {
      params: { userId, start: startDate, end: endDate }
    });

    const categoryMap = {};
    data.filter(t => t.type === 'EXPENSE').forEach(t => {
      const cat = t.categoryName;
      if (!categoryMap[cat]) {
        categoryMap[cat] = { name: cat, total: 0, count: 0 };
      }
      categoryMap[cat].total += t.amount;
      categoryMap[cat].count++;
    });

    return Object.values(categoryMap).sort((a, b) => b.total - a.total);
  },

  async getPaymentMethodStats(startDate, endDate, userId = 9) {
    const { data } = await api.get('/transactions/period', {
      params: { userId, start: startDate, end: endDate }
    });

    const methodMap = {};
    data.filter(t => t.type === 'EXPENSE').forEach(t => {
      const method = t.paymentMethod || '기타';
      if (!methodMap[method]) {
        methodMap[method] = { name: method, total: 0, count: 0 };
      }
      methodMap[method].total += t.amount;
      methodMap[method].count++;
    });

    return Object.values(methodMap).sort((a, b) => b.total - a.total);
  },

  async getIncomeStatsFromTransactions(startDate, endDate, userId = 9) {
    const { data } = await api.get('/transactions/period', {
      params: { userId, start: startDate, end: endDate }
    });

    const categoryMap = {};
    data.filter(t => t.type === 'INCOME').forEach(t => {
      const cat = t.categoryName;
      if (!categoryMap[cat]) {
        categoryMap[cat] = { name: cat, total: 0, count: 0 };
      }
      categoryMap[cat].total += t.amount;
      categoryMap[cat].count++;
    });

    return Object.values(categoryMap).sort((a, b) => b.total - a.total);
  }
};
