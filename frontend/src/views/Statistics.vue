<template>
  <div class="statistics">
    <div class="page-header">
      <h1>통계분석</h1>
      <select v-model="selectedYear" @change="loadStatistics" class="year-select">
        <option v-for="year in years" :key="year" :value="year">{{ year }}년</option>
      </select>
    </div>

    <div class="stats-grid">
      <div class="chart-card monthly-chart">
        <div class="card-header">
          <span class="card-title">📊 월별 수입/지출</span>
        </div>
        <MonthlyBarChart :chart-data="monthlyChartData" />
      </div>

      <div class="chart-card">
        <div class="card-header">
          <span class="card-title">💰 카테고리별 수입</span>
        </div>
        <div class="donut-wrapper">
          <DonutChart :chart-data="incomeChartData" :total="totalIncome" chart-type="income" />
        </div>
        <div class="chart-legend">
          <div v-for="(item, index) in incomeLegend" :key="index" class="legend-item">
            <span class="legend-dot" :style="{ background: item.color }"></span>
            <span class="legend-name">{{ item.name }}</span>
            <span class="legend-value">{{ formatAmount(item.value) }}원</span>
          </div>
        </div>
      </div>

      <div class="chart-card">
        <div class="card-header">
          <span class="card-title">💸 카테고리별 지출</span>
        </div>
        <div class="donut-wrapper">
          <DonutChart :chart-data="expenseChartData" :total="totalExpense" chart-type="expense" />
        </div>
        <div class="chart-legend">
          <div v-for="(item, index) in expenseLegend" :key="index" class="legend-item">
            <span class="legend-dot" :style="{ background: item.color }"></span>
            <span class="legend-name">{{ item.name }}</span>
            <span class="legend-value">{{ formatAmount(item.value) }}원</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import statisticsService from '../services/statisticsService';
import MonthlyBarChart from '../components/MonthlyBarChart.vue';
import DonutChart from '../components/DonutChart.vue';

const years = Array.from({ length: 10 }, (_, i) => 2020 + i);
const selectedYear = ref(2026);
const monthlyChartData = ref({ labels: [], datasets: [] });
const incomeChartData = ref({ labels: [], datasets: [] });
const expenseChartData = ref({ labels: [], datasets: [] });
const incomeLegend = ref([]);
const expenseLegend = ref([]);
const totalIncome = ref(0);
const totalExpense = ref(0);

const incomeColors = ['#67C23A', '#a3e635', '#22c55e', '#10b981', '#14b8a6'];
const expenseColors = ['#F56C6C', '#fb7185', '#f472b6', '#a78bfa', '#60a5fa', '#38bdf8', '#2dd4bf', '#fbbf24'];

const formatAmount = (amount) => {
  return new Intl.NumberFormat('ko-KR').format(amount);
};

const loadStatistics = async () => {
  try {
    const year = selectedYear.value;
    
    const monthlyData = await statisticsService.getMonthlyStatsFromTransactions(year);
    monthlyChartData.value = {
      labels: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
      datasets: [
        { label: 'INCOME', data: monthlyData.map(d => d.income), backgroundColor: '#67C23A' },
        { label: 'EXPENSE', data: monthlyData.map(d => d.expense), backgroundColor: '#F56C6C' }
      ]
    };
    
    const startDate = `${year}-01-01`;
    const endDate = `${year}-12-31`;
    
    const incomeStats = await statisticsService.getIncomeStatsFromTransactions(startDate, endDate);
    incomeChartData.value = {
      labels: incomeStats.map(s => s.name),
      datasets: [{
        data: incomeStats.map(s => s.total),
        backgroundColor: incomeColors.slice(0, incomeStats.length)
      }]
    };
    totalIncome.value = incomeStats.reduce((sum, s) => sum + s.total, 0);
    incomeLegend.value = incomeStats.map((s, i) => ({
      name: s.name,
      color: incomeColors[i % incomeColors.length],
      value: s.total
    }));
    
    const expenseStats = await statisticsService.getCategoryStatsFromTransactions(startDate, endDate);
    expenseChartData.value = {
      labels: expenseStats.map(s => s.name),
      datasets: [{
        data: expenseStats.map(s => s.total),
        backgroundColor: expenseColors.slice(0, expenseStats.length)
      }]
    };
    totalExpense.value = expenseStats.reduce((sum, s) => sum + s.total, 0);
    expenseLegend.value = expenseStats.map((s, i) => ({
      name: s.name,
      color: expenseColors[i % expenseColors.length],
      value: s.total
    }));
  } catch (error) {
    console.error('통계 데이터 로딩 실패:', error);
  }
};

onMounted(() => {
  loadStatistics();
});
</script>

<style scoped>
.statistics {
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

.year-select {
  padding: 10px 16px;
  background: #1a1a2e;
  border: 1px solid #2a2a4a;
  border-radius: 8px;
  color: #fff;
  font-size: 14px;
  cursor: pointer;
}

.stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.chart-card {
  background: #1a1a2e;
  border-radius: 12px;
  padding: 20px;
}

.chart-card.monthly-chart {
  grid-column: 1 / -1;
}

.card-header {
  margin-bottom: 16px;
}

.card-title {
  font-size: 14px;
  font-weight: 600;
}

.donut-wrapper {
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-legend {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 16px;
}

.legend-item {
  display: flex;
  align-items: center;
  font-size: 12px;
  gap: 8px;
}

.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.legend-name {
  flex: 1;
  color: #aaa;
}

.legend-value {
  color: #fff;
}
</style>
