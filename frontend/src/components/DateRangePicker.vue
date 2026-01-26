<template>
  <div class="date-range-picker">
    <input
      type="date"
      v-model="startDate"
      @change="handleChange"
      class="date-input"
    />
    <span class="separator">~</span>
    <input
      type="date"
      v-model="endDate"
      @change="handleChange"
      class="date-input"
    />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  modelValue: { type: Array, default: () => ['2026-01-01', '2026-01-31'] }
})

const emit = defineEmits(['update:modelValue', 'change'])

const startDate = ref(props.modelValue[0])
const endDate = ref(props.modelValue[1])

watch(() => props.modelValue, (newVal) => {
  if (newVal && newVal.length === 2) {
    startDate.value = newVal[0]
    endDate.value = newVal[1]
  }
}, { immediate: true })

const handleChange = () => {
  if (startDate.value && endDate.value) {
    const val = [startDate.value, endDate.value]
    emit('update:modelValue', val)
    emit('change', val)
  }
}
</script>

<style scoped>
.date-range-picker {
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.date-input {
  padding: 8px 12px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.2s;
}

.date-input:focus {
  border-color: #409eff;
}

.separator {
  color: #909399;
  font-weight: 500;
}
</style>
