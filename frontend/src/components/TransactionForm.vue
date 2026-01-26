<template>
  <el-form :model="form" label-position="top" @submit.prevent="handleSubmit">
    <el-form-item label="유형">
      <el-radio-group v-model="form.type">
        <el-radio-button value="INCOME">💰 수입</el-radio-button>
        <el-radio-button value="EXPENSE">💸 지출</el-radio-button>
      </el-radio-group>
    </el-form-item>

    <el-form-item label="날짜">
      <input
        type="date"
        v-model="form.transactionDate"
        class="date-input"
      />
    </el-form-item>

    <el-form-item label="카테고리">
      <el-select v-model="form.categoryId" placeholder="카테고리 선택" style="width: 100%">
        <el-option
          v-for="cat in currentCategories"
          :key="cat.categoryId"
          :label="`${cat.icon || '📌'} ${cat.name}`"
          :value="cat.categoryId"
        />
      </el-select>
    </el-form-item>

    <el-form-item label="금액 (원)">
      <el-input-number
        v-model="form.amount"
        :min="0"
        :step="1000"
        :controls="false"
        style="width: 100%"
        placeholder="금액 입력"
      />
    </el-form-item>

    <el-form-item label="결제수단">
      <el-select v-model="form.paymentMethod" placeholder="결제수단 선택" style="width: 100%">
        <el-option
          v-for="pm in paymentMethods"
          :key="pm.value"
          :label="pm.label"
          :value="pm.value"
        />
      </el-select>
    </el-form-item>

    <el-form-item label="메모">
      <el-input
        v-model="form.memo"
        type="textarea"
        :rows="2"
        placeholder="메모를 입력하세요"
      />
    </el-form-item>

    <div class="form-actions">
      <el-button @click="$emit('cancel')">취소</el-button>
      <el-button type="primary" native-type="submit">저장</el-button>
    </div>
  </el-form>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import dayjs from 'dayjs'
import categoryService, { paymentMethods } from '../services/categoryService'

const props = defineProps({
  transaction: { type: Object, default: null }
})

const emit = defineEmits(['submit', 'cancel'])

const incomeCategories = ref([])
const expenseCategories = ref([])

const form = ref({
  type: 'EXPENSE',
  transactionDate: dayjs().format('YYYY-MM-DD'),
  categoryId: null,
  categoryName: '',
  amount: 0,
  paymentMethod: '신용카드',
  memo: '',
  userId: 9
})

const currentCategories = computed(() => {
  return form.value.type === 'INCOME' ? incomeCategories.value : expenseCategories.value
})

const loadCategories = async () => {
  try {
    const incomeRes = await categoryService.getIncomeCategories()
    incomeCategories.value = incomeRes.data
    const expenseRes = await categoryService.getExpenseCategories()
    expenseCategories.value = expenseRes.data
  } catch (error) {
    console.error('Failed to load categories:', error)
  }
}

onMounted(() => {
  loadCategories()
})

watch(() => props.transaction, (newVal) => {
  if (newVal) {
    form.value = {
      type: newVal.type || 'EXPENSE',
      transactionDate: newVal.transactionDate,
      categoryId: newVal.categoryId,
      categoryName: newVal.categoryName,
      amount: newVal.amount,
      paymentMethod: newVal.paymentMethod || '신용카드',
      memo: newVal.memo || '',
      userId: 9
    }
  }
}, { immediate: true })

watch(() => form.value.type, () => {
  form.value.categoryId = null
})

const handleSubmit = () => {
  emit('submit', { ...form.value })
}
</script>

<style scoped>
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.date-input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  font-size: 14px;
}
</style>
