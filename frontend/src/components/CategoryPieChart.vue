<template>
  <div class="chart-container">
    <Pie v-if="hasData" :key="chartKey" :data="chartData" :options="chartOptions" />
    <div v-else class="no-data">데이터가 없습니다</div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue';
import { Pie } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from 'chart.js';

ChartJS.register(Title, Tooltip, Legend, ArcElement);

const props = defineProps({
  chartData: {
    type: Object,
    required: true
  },
  chartType: {
    type: String,
    default: 'expense'
  }
});

const chartKey = ref(0);

watch(() => props.chartData, () => {
  chartKey.value++;
}, { deep: true });

const hasData = computed(() => {
  return props.chartData?.datasets?.[0]?.data?.length > 0 &&
         props.chartData.datasets[0].data.some(v => v > 0);
});

const chartOptions = computed(() => {
  const data = props.chartData?.datasets?.[0]?.data || [];
  const total = data.reduce((a, b) => a + b, 0);
  
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'right',
        labels: {
          generateLabels: (chart) => {
            const dataset = chart.data.datasets[0];
            const labels = chart.data.labels;
            return labels.map((label, i) => {
              const value = dataset.data[i];
              const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
              return {
                text: `${label} (${percentage}%)`,
                fillStyle: dataset.backgroundColor[i],
                strokeStyle: dataset.backgroundColor[i],
                hidden: false,
                index: i
              };
            });
          }
        }
      },
      tooltip: {
        callbacks: {
          label: (context) => {
            const label = context.label || '';
            const value = context.parsed || 0;
            const dataTotal = context.dataset.data.reduce((a, b) => a + b, 0);
            if (dataTotal === 0) return `${label}: 0원`;
            const percentage = ((value / dataTotal) * 100).toFixed(1);
            return `${label}: ${new Intl.NumberFormat('ko-KR').format(value)}원 (${percentage}%)`;
          }
        }
      }
    }
  };
});
</script>

<style scoped>
.chart-container {
  height: 350px;
}
.no-data {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #909399;
  font-size: 14px;
}
</style>
