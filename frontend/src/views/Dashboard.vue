<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <div class="welcome-section">
        <h1>Welcome <span class="username">사용자명님</span></h1>
        <p class="subtitle">오늘도 효율적인 자산 관리를 시작해보세요.</p>
      </div>
      <div class="date-selectors">
        <button class="date-picker-btn" @click="showDatePicker = true">
          {{ selectedYear }}년 {{ selectedMonth }}월
        </button>
      </div>
      
      <DatePickerPopup 
        v-if="showDatePicker"
        :year="selectedYear"
        :month="selectedMonth"
        @select="onDateSelect"
        @close="showDatePicker = false"
      />
    </div>

    <div class="summary-cards">
      <div class="summary-card">
        <div class="card-label">수입</div>
        <div class="card-amount income">{{ formatAmount(monthlyIncome) }} <span class="currency">원</span></div>
      </div>
      <div class="summary-card">
        <div class="card-label">지출</div>
        <div class="card-amount expense">{{ formatAmount(monthlyExpense) }} <span class="currency">원</span></div>
      </div>
      <div class="summary-card">
        <div class="card-label">월잔고</div>
        <div class="card-amount balance">{{ formatAmount(balance) }} <span class="currency">원</span></div>
      </div>
      <div class="summary-card">
        <div class="card-label">총잔고</div>
        <div class="card-amount total-balance">{{ formatAmount(cumulativeTotal) }} <span class="currency">원</span></div>
      </div>
    </div>

    <div class="charts-row">
      <div class="chart-section category-section">
        <div class="category-chart-box">
          <div class="chart-title">카테고리별 수입</div>
          <div class="donut-with-legend">
            <div class="donut-container">
              <DonutChart 
                :chart-data="incomeChartData" 
                :total="monthlyIncome"
                chart-type="income"
              />
            </div>
            <div class="chart-legend">
              <div v-for="(item, index) in incomeLegend" :key="index" class="legend-item">
                <span class="legend-dot" :style="{ background: item.color }"></span>
                <span class="legend-name">{{ item.name }}:</span>
                <span class="legend-percent">{{ item.percent }}%</span>
                <span class="legend-amount">({{ item.amount }})</span>
              </div>
            </div>
          </div>
        </div>
        <div class="category-chart-box">
          <div class="chart-title">카테고리별 지출</div>
          <div class="donut-with-legend">
            <div class="donut-container">
              <DonutChart 
                :chart-data="expenseChartData" 
                :total="monthlyExpense"
                chart-type="expense"
              />
            </div>
            <div class="chart-legend">
              <div v-for="(item, index) in expenseLegend" :key="index" class="legend-item">
                <span class="legend-dot" :style="{ background: item.color }"></span>
                <span class="legend-name">{{ item.name }}:</span>
                <span class="legend-percent">{{ item.percent }}%</span>
                <span class="legend-amount">({{ item.amount }})</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="chart-section monthly-section">
        <div class="monthly-header">
          <div class="chart-title">월별 추이</div>
          <div class="cumulative-total">
            <span class="total-label">누적 합계</span>
            <span class="total-amount">₩{{ formatAmount(cumulativeTotal) }}</span>
          </div>
        </div>
        <div class="monthly-subtitle">수입 vs 지출 추이</div>
        <div class="monthly-chart-wrapper">
          <MonthlyBarChart :chart-data="monthlyChartData" />
        </div>
        <div class="chart-legend-inline">
          <span class="legend-item-inline"><span class="legend-bar income"></span> 수입 (Income)</span>
          <span class="legend-item-inline"><span class="legend-bar expense"></span> 지출 (Expenses)</span>
        </div>
      </div>
    </div>

    <div class="transactions-section">
      <div class="section-header">
        <div class="section-title">
          <span class="title-dot">📋</span>
          월별 거래내역
        </div>
        <div class="header-controls">
          <div class="type-filter">
            <button 
              :class="['filter-btn', typeFilter === 'ALL' ? 'active' : '']" 
              @click="typeFilter = 'ALL'"
            >전체</button>
            <button 
              :class="['filter-btn', typeFilter === 'INCOME' ? 'active' : '']" 
              @click="typeFilter = 'INCOME'"
            >수입</button>
            <button 
              :class="['filter-btn', typeFilter === 'EXPENSE' ? 'active' : '']" 
              @click="typeFilter = 'EXPENSE'"
            >지출</button>
          </div>
          <button class="add-btn" @click="openAddModal">+ 거래 추가</button>
        </div>
      </div>
      
      <div class="transactions-table">
        <div class="table-header">
          <div class="col-date sortable" @click="toggleSort('transactionDate')">
            일시
            <span class="sort-icon" v-if="sortKey === 'transactionDate'">{{ sortOrder === 'asc' ? '▲' : '▼' }}</span>
          </div>
          <div class="col-type sortable" @click="toggleSort('type')">
            구분
            <span class="sort-icon" v-if="sortKey === 'type'">{{ sortOrder === 'asc' ? '▲' : '▼' }}</span>
          </div>
          <div class="col-category sortable" @click="toggleSort('categoryName')">
            카테고리
            <span class="sort-icon" v-if="sortKey === 'categoryName'">{{ sortOrder === 'asc' ? '▲' : '▼' }}</span>
          </div>
          <div class="col-amount sortable" @click="toggleSort('amount')">
            금액
            <span class="sort-icon" v-if="sortKey === 'amount'">{{ sortOrder === 'asc' ? '▲' : '▼' }}</span>
          </div>
          <div class="col-payment sortable" @click="toggleSort('paymentMethod')">
            결제수단
            <span class="sort-icon" v-if="sortKey === 'paymentMethod'">{{ sortOrder === 'asc' ? '▲' : '▼' }}</span>
          </div>
          <div class="col-desc">내용(상호)</div>
          <div class="col-actions">작업</div>
        </div>
        <div v-for="tx in filteredTransactions" :key="tx.id" class="table-row">
          <div class="col-date">{{ formatDate(tx.transactionDate) }}</div>
          <div class="col-type">
            <span :class="['type-badge', tx.type === 'INCOME' ? 'income' : 'expense']">
              {{ tx.type === 'INCOME' ? '수입' : '지출' }}
            </span>
          </div>
          <div class="col-category">{{ tx.categoryName || tx.category }}</div>
          <div class="col-amount" :class="tx.type === 'INCOME' ? 'income' : 'expense'">
            {{ formatAmount(tx.amount) }} 원
          </div>
          <div class="col-payment">{{ tx.paymentMethod || '-' }}</div>
          <div class="col-desc">{{ tx.description }}</div>
          <div class="col-actions">
            <button class="action-btn edit" @click="editTransaction(tx)">✏️</button>
            <button class="action-btn delete" @click="deleteTransaction(tx)">🗑️</button>
          </div>
        </div>
        <div class="table-footer">
          <div class="col-date">총합</div>
          <div class="col-type"></div>
          <div class="col-category"></div>
          <div class="col-amount total-amount">{{ formatAmount(filteredTotal) }} 원</div>
          <div class="col-payment"></div>
          <div class="col-desc"></div>
          <div class="col-actions"></div>
        </div>
      </div>
    </div>

    <TransactionModal 
      v-model:visible="showModal"
      :transaction="selectedTransaction"
      :mode="modalMode"
      @saved="onTransactionSaved"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import dayjs from 'dayjs';
import transactionService from '../services/transactionService';
import statisticsService from '../services/statisticsService';
import TransactionModal from '../components/TransactionModal.vue';
import DonutChart from '../components/DonutChart.vue';
import MonthlyBarChart from '../components/MonthlyBarChart.vue';
import DatePickerPopup from '../components/DatePickerPopup.vue';
import { ElMessage, ElMessageBox } from 'element-plus';

const today = dayjs();

const selectedYear = ref(today.year());
const selectedMonth = ref(today.month() + 1);
const showDatePicker = ref(false);

const sortKey = ref('transactionDate');
const sortOrder = ref('desc');
const typeFilter = ref('ALL');

const onDateSelect = (selection) => {
  selectedYear.value = selection.year;
  selectedMonth.value = selection.month;
  showDatePicker.value = false;
  loadDashboardData();
};

const toggleSort = (key) => {
  if (sortKey.value === key) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc';
  } else {
    sortKey.value = key;
    sortOrder.value = 'asc';
  }
};

const monthlyIncome = ref(0);
const monthlyExpense = ref(0);
const transactions = ref([]);

const sortedTransactions = computed(() => {
  const sorted = [...transactions.value];
  sorted.sort((a, b) => {
    let aVal = a[sortKey.value];
    let bVal = b[sortKey.value];
    
    if (sortKey.value === 'transactionDate') {
      aVal = new Date(aVal).getTime();
      bVal = new Date(bVal).getTime();
    } else if (sortKey.value === 'amount') {
      aVal = Number(aVal) || 0;
      bVal = Number(bVal) || 0;
    } else if (sortKey.value === 'categoryName') {
      aVal = (a.categoryName || a.category || '').toLowerCase();
      bVal = (b.categoryName || b.category || '').toLowerCase();
    } else {
      aVal = (aVal || '').toString().toLowerCase();
      bVal = (bVal || '').toString().toLowerCase();
    }
    
    if (aVal < bVal) return sortOrder.value === 'asc' ? -1 : 1;
    if (aVal > bVal) return sortOrder.value === 'asc' ? 1 : -1;
    return 0;
  });
  return sorted;
});

const filteredTransactions = computed(() => {
  if (typeFilter.value === 'ALL') {
    return sortedTransactions.value;
  }
  return sortedTransactions.value.filter(tx => tx.type === typeFilter.value);
});

const filteredTotal = computed(() => {
  return filteredTransactions.value.reduce((sum, tx) => {
    if (tx.type === 'INCOME') {
      return sum + Number(tx.amount);
    } else {
      return sum - Number(tx.amount);
    }
  }, 0);
});

const cumulativeTotal = ref(0);

const incomeChartData = ref({ labels: [], datasets: [] });
const expenseChartData = ref({ labels: [], datasets: [] });
const monthlyChartData = ref({ labels: [], datasets: [] });

const incomeLegend = ref([]);
const expenseLegend = ref([]);

const showModal = ref(false);
const modalMode = ref('add');
const selectedTransaction = ref(null);

const balance = computed(() => monthlyIncome.value - monthlyExpense.value);

const incomeColors = ['#67C23A', '#a3e635', '#22c55e', '#10b981', '#14b8a6'];
const expenseColors = ['#F56C6C', '#fb7185', '#f472b6', '#a78bfa', '#60a5fa', '#38bdf8', '#2dd4bf', '#fbbf24'];

const formatAmount = (amount) => {
  return new Intl.NumberFormat('ko-KR').format(amount);
};

const formatDate = (date) => {
  const d = dayjs(date);
  const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  return `${d.format('YYYY-MM-DD')} (${weekdays[d.day()]})`;
};

const loadDashboardData = async () => {
  try {
    const year = selectedYear.value;
    const month = selectedMonth.value;
    
    const summaryRes = await transactionService.getMonthlySummary(year, month);
    monthlyIncome.value = summaryRes.data.totalIncome;
    monthlyExpense.value = summaryRes.data.totalExpense;
    
    const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
    const endDate = dayjs(`${year}-${month}-01`).endOf('month').format('YYYY-MM-DD');
    const transRes = await transactionService.getTransactionsByPeriod(startDate, endDate);
    transactions.value = transRes.data;
    
    const incomeStats = await statisticsService.getIncomeStatsFromTransactions(startDate, endDate);
    incomeChartData.value = {
      labels: incomeStats.map(s => s.name),
      datasets: [{
        data: incomeStats.map(s => s.total),
        backgroundColor: incomeColors.slice(0, incomeStats.length)
      }]
    };
    
    const totalInc = incomeStats.reduce((sum, s) => sum + s.total, 0);
    incomeLegend.value = incomeStats.map((s, i) => ({
      name: s.name,
      color: incomeColors[i % incomeColors.length],
      percent: totalInc > 0 ? Math.round(s.total / totalInc * 100) : 0,
      amount: new Intl.NumberFormat('ko-KR').format(s.total) + '원'
    }));
    
    const expenseStats = await statisticsService.getCategoryStatsFromTransactions(startDate, endDate);
    expenseChartData.value = {
      labels: expenseStats.map(s => s.name),
      datasets: [{
        data: expenseStats.map(s => s.total),
        backgroundColor: expenseColors.slice(0, expenseStats.length)
      }]
    };
    
    const totalExp = expenseStats.reduce((sum, s) => sum + s.total, 0);
    expenseLegend.value = expenseStats.map((s, i) => ({
      name: s.name,
      color: expenseColors[i % expenseColors.length],
      percent: totalExp > 0 ? Math.round(s.total / totalExp * 100) : 0,
      amount: new Intl.NumberFormat('ko-KR').format(s.total) + '원'
    }));
    
    const monthlyData = await statisticsService.getMonthlyStatsFromTransactions(year);
    monthlyChartData.value = {
      labels: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
      datasets: [
        { label: '수입', data: monthlyData.map(d => d.income), backgroundColor: '#3b82f6' },
        { label: '지출', data: monthlyData.map(d => d.expense), backgroundColor: '#f97316' }
      ]
    };
    
    const totalYearIncome = monthlyData.reduce((sum, d) => sum + d.income, 0);
    const totalYearExpense = monthlyData.reduce((sum, d) => sum + d.expense, 0);
    cumulativeTotal.value = totalYearIncome - totalYearExpense;
  } catch (error) {
    console.error('Dashboard 데이터 로딩 실패:', error);
  }
};

const openAddModal = () => {
  modalMode.value = 'add';
  selectedTransaction.value = null;
  showModal.value = true;
};

const editTransaction = (transaction) => {
  modalMode.value = 'edit';
  selectedTransaction.value = transaction;
  showModal.value = true;
};

const deleteTransaction = async (transaction) => {
  try {
    await ElMessageBox.confirm('이 거래를 삭제하시겠습니까?', '삭제 확인', {
      confirmButtonText: '삭제',
      cancelButtonText: '취소',
      type: 'warning'
    });
    await transactionService.deleteTransaction(transaction.id, transaction.type);
    ElMessage.success('거래가 삭제되었습니다.');
    loadDashboardData();
  } catch (error) {
    if (error !== 'cancel') {
      console.error('삭제 실패:', error);
      ElMessage.error('삭제에 실패했습니다.');
    }
  }
};

const onTransactionSaved = () => {
  showModal.value = false;
  loadDashboardData();
};

onMounted(() => {
  loadDashboardData();
});
</script>

<style scoped>
.dashboard {
  color: #fff;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
}

.welcome-section h1 {
  font-size: 26px;
  font-weight: 600;
  margin: 0;
}

.welcome-section .username {
  color: #d4ff00;
}

.welcome-section .subtitle {
  font-size: 13px;
  color: #666;
  margin-top: 6px;
}

.date-selectors {
  display: flex;
  gap: 8px;
}

.date-picker-btn {
  padding: 12px 24px;
  background: #2a4a2a;
  border: 1px solid #3a5a3a;
  border-radius: 8px;
  color: #fff;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.date-picker-btn:hover {
  background: #3a5a3a;
  border-color: #d4ff00;
}

.date-picker-btn:focus {
  outline: none;
  border-color: #d4ff00;
}

.summary-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 20px;
}

.summary-card {
  background: #1a2e1a;
  border: 1px solid #2a4a2a;
  border-radius: 10px;
  padding: 16px 20px;
}

.card-label {
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 8px;
}

.card-amount {
  font-size: 26px;
  font-weight: 700;
}

.card-amount .currency {
  font-size: 14px;
  font-weight: 400;
  color: #888;
}

.card-amount.income { color: #fff; }
.card-amount.expense { color: #f97316; }
.card-amount.balance { color: #d4ff00; }
.card-amount.total-balance { color: #a78bfa; }

.charts-row {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: 16px;
  margin-bottom: 20px;
}

.chart-section {
  background: #1a2e1a;
  border: 1px solid #2a4a2a;
  border-radius: 10px;
  padding: 16px;
}

.category-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.category-chart-box {
  background: #0d1f0d;
  border-radius: 8px;
  padding: 14px;
}

.chart-title {
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 12px;
}

.donut-with-legend {
  display: flex;
  align-items: center;
  gap: 16px;
}

.donut-container {
  width: 120px;
  height: 120px;
  flex-shrink: 0;
}

.chart-legend {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.legend-item {
  display: flex;
  align-items: center;
  font-size: 11px;
  gap: 6px;
}

.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.legend-name {
  color: #aaa;
}

.legend-percent {
  color: #fff;
  margin-left: 2px;
}

.legend-amount {
  color: #888;
  margin-left: 4px;
}

.monthly-section {
  display: flex;
  flex-direction: column;
}

.monthly-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.cumulative-total {
  text-align: right;
}

.cumulative-total .total-label {
  font-size: 11px;
  color: #888;
  display: block;
}

.cumulative-total .total-amount {
  font-size: 20px;
  font-weight: 700;
  color: #d4ff00;
}

.monthly-subtitle {
  font-size: 12px;
  color: #666;
  margin-bottom: 12px;
}

.monthly-chart-wrapper {
  flex: 1;
  min-height: 200px;
}

.chart-legend-inline {
  display: flex;
  gap: 20px;
  justify-content: center;
  margin-top: 12px;
}

.legend-item-inline {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  color: #888;
}

.legend-bar {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.legend-bar.income { background: #3b82f6; }
.legend-bar.expense { background: #f97316; }

.transactions-section {
  background: #1a2e1a;
  border: 1px solid #2a4a2a;
  border-radius: 10px;
  padding: 16px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 16px;
}

.type-filter {
  display: flex;
  gap: 4px;
  background: #1a2e1a;
  border-radius: 8px;
  padding: 4px;
}

.filter-btn {
  background: transparent;
  border: none;
  color: #888;
  padding: 6px 14px;
  font-size: 13px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.filter-btn:hover {
  color: #fff;
  background: #2a4a2a;
}

.filter-btn.active {
  background: #d4ff00;
  color: #1a2e1a;
  font-weight: 600;
}

.section-title {
  font-size: 15px;
  font-weight: 600;
}

.add-btn {
  background: transparent;
  color: #d4ff00;
  border: 1px solid #d4ff00;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}

.add-btn:hover {
  background: #d4ff00;
  color: #0d0d1a;
}

.transactions-table {
  width: 100%;
}

.table-header {
  display: grid;
  grid-template-columns: 120px 70px 90px 130px 90px 1fr 80px;
  gap: 10px;
  padding: 10px 14px;
  background: #0d1f0d;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 6px;
}

.table-header .sortable {
  cursor: pointer;
  user-select: none;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: color 0.2s;
}

.table-header .sortable:hover {
  color: #d4ff00;
}

.sort-icon {
  font-size: 10px;
  color: #d4ff00;
}

.table-row {
  display: grid;
  grid-template-columns: 120px 70px 90px 130px 90px 1fr 80px;
  gap: 10px;
  padding: 12px 14px;
  border-bottom: 1px solid #2a4a2a;
  font-size: 13px;
  align-items: center;
}

.table-footer {
  display: grid;
  grid-template-columns: 120px 70px 90px 130px 90px 1fr 80px;
  gap: 10px;
  padding: 14px;
  background: #0d1f0d;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  margin-top: 8px;
}

.total-amount {
  color: #d4ff00;
  font-weight: 700;
}

.type-badge {
  display: inline-block;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
}

.type-badge.income {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.type-badge.expense {
  background: rgba(249, 115, 22, 0.2);
  color: #f97316;
}

.col-amount.income { color: #3b82f6; text-decoration: underline; }
.col-amount.expense { color: #f97316; }

.table-row .col-desc {
  color: #fff;
}

.col-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 2px 6px;
  font-size: 12px;
  color: #3b82f6;
  text-decoration: underline;
}

.action-btn.delete {
  color: #888;
}

.action-btn:hover {
  opacity: 0.8;
}
</style>
