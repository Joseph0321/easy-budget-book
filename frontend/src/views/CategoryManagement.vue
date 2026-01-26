<template>
  <div class="category-management">
    <div class="page-header">
      <h1 class="page-title">카테고리 관리</h1>
      <p class="page-subtitle">수입/지출 카테고리를 확인하세요</p>
    </div>

    <el-row :gutter="20">
      <el-col :span="12">
        <div class="card">
          <div class="card-title">
            <span class="title-icon">💰</span>
            수입 카테고리
          </div>
          <div class="category-list">
            <div v-for="cat in incomeCategories" :key="cat.categoryId" class="category-item">
              <div class="category-info">
                <span class="category-emoji">{{ cat.icon }}</span>
                <span class="category-name">{{ cat.name }}</span>
              </div>
              <div class="category-color" :style="{ background: cat.color }"></div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :span="12">
        <div class="card">
          <div class="card-title">
            <span class="title-icon">💸</span>
            지출 카테고리
          </div>
          <div class="category-list">
            <div v-for="cat in expenseCategories" :key="cat.categoryId" class="category-item">
              <div class="category-info">
                <span class="category-emoji">{{ cat.icon }}</span>
                <span class="category-name">{{ cat.name }}</span>
              </div>
              <div class="category-color" :style="{ background: cat.color }"></div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <div class="card" style="margin-top: 20px;">
      <div class="card-title">
        <span class="title-icon">💳</span>
        결제수단
      </div>
      <div class="payment-methods">
        <el-tag v-for="pm in paymentMethods" :key="pm.value" size="large" class="payment-tag">
          {{ pm.label }}
        </el-tag>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import categoryService, { paymentMethods } from '../services/categoryService'

const incomeCategories = ref([])
const expenseCategories = ref([])

onMounted(async () => {
  try {
    const incomeRes = await categoryService.getIncomeCategories()
    incomeCategories.value = incomeRes.data
    const expenseRes = await categoryService.getExpenseCategories()
    expenseCategories.value = expenseRes.data
  } catch (error) {
    console.error('Failed to load categories:', error)
  }
})
</script>

<style scoped>
.category-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.category-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #f8f9fa;
  border-radius: 8px;
  transition: background 0.2s;
}

.category-item:hover {
  background: #f0f2f5;
}

.category-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.category-emoji {
  font-size: 24px;
}

.category-name {
  font-size: 15px;
  font-weight: 500;
}

.category-color {
  width: 24px;
  height: 24px;
  border-radius: 6px;
}

.title-icon {
  font-size: 20px;
  margin-right: 8px;
}

.payment-methods {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.payment-tag {
  font-size: 14px;
  padding: 12px 20px;
}
</style>
