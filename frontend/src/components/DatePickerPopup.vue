<template>
  <div class="date-picker-overlay">
    <div class="date-picker-popup">
      <div class="year-row">
        <div class="year-selector">
          <button class="year-arrow" @click="prevYear">&lt;</button>
          <input 
            type="text" 
            class="year-input" 
            v-model="yearInput"
            @blur="validateYear"
            @keyup.enter="validateYear"
          />
          <button class="year-arrow" @click="nextYear">&gt;</button>
        </div>
        <button class="current-btn" @click="goToCurrent">현재</button>
      </div>
      
      <div class="month-grid">
        <button 
          v-for="m in 12" 
          :key="m"
          class="month-btn"
          :class="{ active: m === selectedMonth && parseInt(yearInput) === selectedYear }"
          @click="selectMonth(m)"
        >
          {{ m }}월
        </button>
      </div>
      
      <button class="close-btn" @click="$emit('close')">
        ✕ 닫기
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DatePickerPopup',
  props: {
    year: {
      type: Number,
      required: true
    },
    month: {
      type: Number,
      required: true
    }
  },
  emits: ['close', 'select'],
  data() {
    return {
      yearInput: this.year.toString() + '년',
      selectedYear: this.year,
      selectedMonth: this.month
    };
  },
  watch: {
    year(newVal) {
      this.yearInput = newVal.toString() + '년';
      this.selectedYear = newVal;
    },
    month(newVal) {
      this.selectedMonth = newVal;
    }
  },
  methods: {
    prevYear() {
      const currentYear = parseInt(this.yearInput);
      this.yearInput = (currentYear - 1).toString() + '년';
      this.selectedYear = currentYear - 1;
    },
    nextYear() {
      const currentYear = parseInt(this.yearInput);
      this.yearInput = (currentYear + 1).toString() + '년';
      this.selectedYear = currentYear + 1;
    },
    validateYear() {
      let year = parseInt(this.yearInput.replace(/[^0-9]/g, ''));
      if (isNaN(year) || year < 1900) {
        year = new Date().getFullYear();
      }
      if (year > 2100) {
        year = 2100;
      }
      this.yearInput = year.toString() + '년';
      this.selectedYear = year;
    },
    goToCurrent() {
      const now = new Date();
      this.yearInput = now.getFullYear().toString() + '년';
      this.selectedYear = now.getFullYear();
      this.selectedMonth = now.getMonth() + 1;
      this.$emit('select', { year: this.selectedYear, month: this.selectedMonth });
    },
    selectMonth(month) {
      this.selectedMonth = month;
      this.$emit('select', { year: this.selectedYear, month: month });
    }
  }
};
</script>

<style scoped>
.date-picker-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.date-picker-popup {
  background: #1a2e1a;
  border: 2px solid #4a6a4a;
  border-radius: 12px;
  padding: 14px;
  min-width: 220px;
}

.year-row {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.year-selector {
  display: flex;
  align-items: center;
  background: #d4ff00;
  border-radius: 6px;
  flex: 1;
}

.year-arrow {
  background: transparent;
  border: none;
  color: #1a2e1a;
  font-size: 12px;
  font-weight: bold;
  padding: 8px 10px;
  cursor: pointer;
}

.year-arrow:hover {
  background: rgba(0, 0, 0, 0.1);
}

.year-input {
  background: transparent;
  border: none;
  color: #1a2e1a;
  font-size: 13px;
  font-weight: bold;
  text-align: center;
  width: 100%;
  outline: none;
}

.current-btn {
  background: #fff;
  border: none;
  border-radius: 6px;
  color: #1a2e1a;
  font-size: 11px;
  font-weight: bold;
  padding: 8px 12px;
  cursor: pointer;
}

.current-btn:hover {
  background: #e0e0e0;
}

.month-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
  margin-bottom: 12px;
}

.month-btn {
  background: #2a3a2a;
  border: 2px solid transparent;
  border-radius: 8px;
  color: #ccc;
  font-size: 12px;
  font-weight: 500;
  padding: 10px 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.month-btn:hover {
  background: #3a4a3a;
  color: #fff;
}

.month-btn.active {
  background: #3a5a3a;
  border-color: #d4ff00;
  color: #d4ff00;
}

.close-btn {
  background: transparent;
  border: 1px solid #4a6a4a;
  border-radius: 6px;
  color: #999;
  font-size: 11px;
  padding: 6px 14px;
  cursor: pointer;
  width: 100%;
}

.close-btn:hover {
  background: #2a3a2a;
  color: #fff;
}
</style>
