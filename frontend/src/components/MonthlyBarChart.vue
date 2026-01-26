<template>
  <div class="chart-container">
    <Bar :data="chartData" :options="chartOptions" :plugins="plugins" />
  </div>
</template>

<script setup>
import { Bar } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale
} from 'chart.js';
import ChartDataLabels from 'chartjs-plugin-datalabels';

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale);

const props = defineProps({
  chartData: {
    type: Object,
    required: true
  }
});

const plugins = [ChartDataLabels];

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    },
    title: {
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
          return `${context.dataset.label}: ${context.parsed.y.toLocaleString()}원`;
        }
      }
    },
    datalabels: {
      display: function(context) {
        return context.dataset.data[context.dataIndex] > 0;
      },
      anchor: 'center',
      align: 'center',
      rotation: -90,
      color: '#fff',
      font: {
        size: 10,
        weight: 'bold'
      },
      formatter: function(value) {
        return new Intl.NumberFormat('ko-KR').format(value) + '원';
      }
    }
  },
  scales: {
    x: {
      grid: {
        display: false
      },
      ticks: {
        color: '#666',
        font: {
          size: 11
        }
      }
    },
    y: {
      beginAtZero: true,
      grid: {
        color: '#2a2a4a'
      },
      ticks: {
        color: '#666',
        font: {
          size: 11
        },
        callback: (value) => {
          return new Intl.NumberFormat('ko-KR').format(value) + '원';
        }
      }
    }
  }
};
</script>

<style scoped>
.chart-container {
  height: 200px;
}
</style>
