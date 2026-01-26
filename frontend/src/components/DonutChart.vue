<template>
  <div class="donut-chart">
    <Doughnut :data="chartData" :options="chartOptions" />
    <div class="center-text">
      <div class="total-label">Total</div>
      <div class="total-amount">₩{{ formatTotalK }}</div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { Doughnut } from 'vue-chartjs';
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js';

ChartJS.register(ArcElement, Tooltip, Legend);

const props = defineProps({
  chartData: {
    type: Object,
    required: true
  },
  total: {
    type: Number,
    default: 0
  },
  chartType: {
    type: String,
    default: 'income'
  }
});

const formatTotalK = computed(() => {
  return new Intl.NumberFormat('ko-KR').format(props.total);
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  cutout: '70%',
  plugins: {
    legend: {
      display: false
    },
    tooltip: {
      backgroundColor: '#1a1a2e',
      titleColor: '#fff',
      bodyColor: '#fff',
      borderColor: '#2a2a4a',
      borderWidth: 1,
      padding: 12,
      callbacks: {
        label: function(context) {
          const value = context.parsed;
          const total = context.dataset.data.reduce((a, b) => a + b, 0);
          const percentage = Math.round((value / total) * 100);
          return `${context.label}: ${value.toLocaleString()}원 (${percentage}%)`;
        }
      }
    }
  }
};
</script>

<style scoped>
.donut-chart {
  position: relative;
  width: 100%;
  height: 100%;
}

.center-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}

.total-label {
  font-size: 8px;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.total-percent {
  display: none;
}

.total-amount {
  font-size: 11px;
  font-weight: 700;
  color: #fff;
  margin-top: 2px;
}
</style>
