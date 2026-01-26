import api from './api';

export const defaultColors = {
  income: ['#67c23a', '#95d475', '#b3e19d', '#d1edc4', '#e1f3d8'],
  expense: ['#f56c6c', '#e6a23c', '#409eff', '#909399', '#f78989', '#a0cfff', '#c6e2ff', '#c45656', '#73767a', '#337ecc', '#fab6b6', '#b1b3b8']
};

export const defaultEmojis = {
  income: ['💰', '💵', '📈', '🎁', '✨', '💎', '🏆', '💼'],
  expense: ['🍔', '🚗', '🏠', '📱', '🏥', '🛍️', '🎬', '☕', '📺', '🛡️', '💐', '📦', '🎮', '✈️', '🎓']
};

export const paymentMethods = [
  { value: '현금', label: '💵 현금' },
  { value: '신용카드', label: '💳 신용카드' },
  { value: '체크카드', label: '💳 체크카드' },
  { value: '계좌이체', label: '🏦 계좌이체' }
];

export default {
  getCategories(type = null) {
    const params = type ? { type } : {};
    return api.get('/categories', { params });
  },
  
  getIncomeCategories() {
    return api.get('/categories', { params: { type: 'income' } });
  },
  
  getExpenseCategories() {
    return api.get('/categories', { params: { type: 'expense' } });
  },
  
  createCategory(category) {
    return api.post('/categories', category);
  },
  
  updateCategory(id, category) {
    return api.put(`/categories/${id}`, category);
  },
  
  deleteCategory(id) {
    return api.delete(`/categories/${id}`);
  },
  
  checkCategoryUsage(id) {
    return api.get(`/categories/${id}/check-usage`);
  },

  getPaymentMethods() {
    return paymentMethods;
  }
};
