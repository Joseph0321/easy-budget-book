<template>
  <div class="transaction-list">
    <div class="page-header">
      <h1>거래내역</h1>
      <div class="actions">
        <button class="btn primary" @click="showAddDialog">+ 추가</button>
        <button class="btn" @click="handleExport">Excel 다운로드</button>
        <label class="btn upload-btn">
          Excel 업로드
          <input type="file" accept=".xlsx,.xls" @change="handleImportChange" hidden />
        </label>
      </div>
    </div>

    <div class="filter-form">
      <div class="date-range">
        <span>기간</span>
        <input type="date" v-model="startDate" @change="loadTransactions" />
        <span>~</span>
        <input type="date" v-model="endDate" @change="loadTransactions" />
      </div>
      <select v-model="filterType" @change="loadTransactions" class="filter-select">
        <option value="ALL">전체</option>
        <option value="INCOME">수입</option>
        <option value="EXPENSE">지출</option>
      </select>
      <select v-model="filterCategory" @change="loadTransactions" class="filter-select">
        <option :value="null">카테고리 전체</option>
        <option v-for="cat in categories" :key="cat.categoryId" :value="cat.categoryId">
          {{ cat.name }}
        </option>
      </select>
    </div>

    <div class="transactions-table">
      <div class="table-header">
        <div class="col-date">날짜</div>
        <div class="col-type">구분</div>
        <div class="col-category">카테고리</div>
        <div class="col-amount">금액</div>
        <div class="col-payment">결제수단</div>
        <div class="col-memo">메모</div>
        <div class="col-actions">작업</div>
      </div>
      <div v-for="tx in paginatedTransactions" :key="tx.id" class="table-row">
        <div class="col-date">{{ formatDate(tx.transactionDate) }}</div>
        <div class="col-type">
          <span :class="['type-badge', tx.type === 'INCOME' ? 'income' : 'expense']">
            {{ tx.type === 'INCOME' ? '수입' : '지출' }}
          </span>
        </div>
        <div class="col-category">{{ tx.categoryName || tx.category }}</div>
        <div class="col-amount" :class="tx.type === 'INCOME' ? 'income' : 'expense'">
          {{ formatCurrency(tx.amount) }}
        </div>
        <div class="col-payment">{{ tx.paymentMethod || '-' }}</div>
        <div class="col-memo">{{ tx.memo || tx.description || '-' }}</div>
        <div class="col-actions">
          <button class="action-btn" @click="editTransaction(tx)">✏️</button>
          <button class="action-btn" @click="deleteTransaction(tx)">🗑️</button>
        </div>
      </div>
    </div>

    <div class="pagination">
      <span class="total">총 {{ total }}건</span>
      <div class="page-buttons">
        <button @click="currentPage = Math.max(1, currentPage - 1)" :disabled="currentPage === 1">이전</button>
        <span class="page-info">{{ currentPage }} / {{ totalPages }}</span>
        <button @click="currentPage = Math.min(totalPages, currentPage + 1)" :disabled="currentPage === totalPages">다음</button>
      </div>
    </div>

    <TransactionForm
      v-model="dialogVisible"
      :transaction="selectedTransaction"
      :categories="categories"
      @save="handleSave"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import transactionService from '../services/transactionService';
import categoryService from '../services/categoryService';
import TransactionForm from '../components/TransactionForm.vue';
import dayjs from 'dayjs';
import { saveAs } from 'file-saver';

const transactions = ref([]);
const categories = ref([]);
const startDate = ref('2026-01-01');
const endDate = ref('2026-01-31');
const filterType = ref('ALL');
const filterCategory = ref(null);
const currentPage = ref(1);
const pageSize = ref(20);
const total = ref(0);

const dialogVisible = ref(false);
const selectedTransaction = ref(null);

const totalPages = computed(() => Math.ceil(total.value / pageSize.value) || 1);

const paginatedTransactions = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return transactions.value.slice(start, start + pageSize.value);
});

const loadTransactions = async () => {
  try {
    const res = await transactionService.getTransactionsByPeriod(
      startDate.value,
      endDate.value
    );
    
    let filtered = res.data;
    if (filterType.value !== 'ALL') {
      filtered = filtered.filter(t => t.type === filterType.value);
    }
    if (filterCategory.value) {
      filtered = filtered.filter(t => t.categoryId === filterCategory.value);
    }
    
    transactions.value = filtered;
    total.value = filtered.length;
    currentPage.value = 1;
  } catch (error) {
    ElMessage.error('거래 내역을 불러오는데 실패했습니다.');
  }
};

const loadCategories = async () => {
  try {
    const res = await categoryService.getCategories();
    categories.value = res.data;
  } catch (error) {
    console.error('Failed to load categories:', error);
  }
};

const showAddDialog = () => {
  selectedTransaction.value = null;
  dialogVisible.value = true;
};

const editTransaction = (transaction) => {
  selectedTransaction.value = { ...transaction };
  dialogVisible.value = true;
};

const handleSave = async () => {
  dialogVisible.value = false;
  await loadTransactions();
  ElMessage.success('저장되었습니다.');
};

const deleteTransaction = async (row) => {
  try {
    await ElMessageBox.confirm('정말 삭제하시겠습니까?', '확인', {
      type: 'warning'
    });
    
    if (row.type === 'INCOME') {
      await transactionService.deleteIncome(row.id);
    } else {
      await transactionService.deleteExpense(row.id);
    }
    await loadTransactions();
    ElMessage.success('삭제되었습니다.');
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('삭제에 실패했습니다.');
    }
  }
};

const handleExport = async () => {
  try {
    const res = await transactionService.exportToExcel(
      startDate.value,
      endDate.value
    );
    
    const blob = new Blob([res.data], {
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    });
    saveAs(blob, `transactions_${dayjs().format('YYYYMMDD')}.xlsx`);
    ElMessage.success('Excel 파일이 다운로드되었습니다.');
  } catch (error) {
    ElMessage.error('Excel 다운로드에 실패했습니다.');
  }
};

const handleImportChange = async (event) => {
  const file = event.target.files[0];
  if (!file) return;
  
  try {
    const res = await transactionService.importFromExcel(file);
    ElMessage.success(`${res.data.successCount}건이 등록되었습니다.`);
    await loadTransactions();
  } catch (error) {
    ElMessage.error('Excel 업로드에 실패했습니다.');
  }
  event.target.value = '';
};

const formatDate = (date) => dayjs(date).format('YYYY-MM-DD');
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('ko-KR').format(amount) + '원';
};

onMounted(() => {
  loadCategories();
  loadTransactions();
});
</script>

<style scoped>
.transaction-list {
  color: #fff;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-header h1 {
  font-size: 24px;
  font-weight: 600;
}

.actions {
  display: flex;
  gap: 10px;
}

.btn {
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: opacity 0.2s;
  background: #1a1a2e;
  border: 1px solid #2a2a4a;
  color: #fff;
}

.btn:hover {
  opacity: 0.9;
}

.btn.primary {
  background: #d4ff00;
  color: #0d0d1a;
  border: none;
  font-weight: 600;
}

.upload-btn {
  display: inline-block;
}

.filter-form {
  display: flex;
  gap: 16px;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  background: #1a1a2e;
  padding: 16px;
  border-radius: 12px;
}

.date-range {
  display: flex;
  gap: 8px;
  align-items: center;
  color: #888;
}

.date-range input[type="date"] {
  padding: 8px 12px;
  background: #12121f;
  border: 1px solid #2a2a4a;
  border-radius: 6px;
  color: #fff;
  font-size: 14px;
}

.filter-select {
  padding: 8px 12px;
  background: #12121f;
  border: 1px solid #2a2a4a;
  border-radius: 6px;
  color: #fff;
  font-size: 14px;
  cursor: pointer;
}

.transactions-table {
  background: #1a1a2e;
  border-radius: 12px;
  overflow: hidden;
}

.table-header {
  display: grid;
  grid-template-columns: 120px 80px 120px 120px 100px 1fr 80px;
  gap: 12px;
  padding: 14px 16px;
  background: #12121f;
  font-size: 12px;
  color: #666;
  text-transform: uppercase;
}

.table-row {
  display: grid;
  grid-template-columns: 120px 80px 120px 120px 100px 1fr 80px;
  gap: 12px;
  padding: 14px 16px;
  border-bottom: 1px solid #2a2a4a;
  font-size: 13px;
  align-items: center;
}

.table-row:last-child {
  border-bottom: none;
}

.type-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
}

.type-badge.income {
  background: rgba(103, 194, 58, 0.2);
  color: #67C23A;
}

.type-badge.expense {
  background: rgba(245, 108, 108, 0.2);
  color: #F56C6C;
}

.col-amount.income { color: #67C23A; }
.col-amount.expense { color: #F56C6C; }

.col-payment, .col-memo {
  color: #888;
}

.col-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  font-size: 14px;
  opacity: 0.7;
  transition: opacity 0.2s;
}

.action-btn:hover {
  opacity: 1;
}

.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding: 16px;
  background: #1a1a2e;
  border-radius: 12px;
}

.total {
  color: #888;
  font-size: 14px;
}

.page-buttons {
  display: flex;
  gap: 12px;
  align-items: center;
}

.page-buttons button {
  padding: 8px 16px;
  background: #12121f;
  border: 1px solid #2a2a4a;
  border-radius: 6px;
  color: #fff;
  font-size: 13px;
  cursor: pointer;
}

.page-buttons button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  color: #888;
  font-size: 13px;
}
</style>
