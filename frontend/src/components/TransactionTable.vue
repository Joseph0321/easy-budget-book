<template>
  <div class="transaction-table">
    <el-table :data="transactions" stripe style="width: 100%" v-if="transactions.length">
      <el-table-column prop="transactionDate" label="날짜" width="120">
        <template #default="{ row }">
          {{ formatDate(row.transactionDate) }}
        </template>
      </el-table-column>
      <el-table-column label="구분" width="80">
        <template #default="{ row }">
          <el-tag :type="row.type === 'INCOME' ? 'success' : 'danger'" size="small">
            {{ row.type === 'INCOME' ? '수입' : '지출' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="categoryName" label="카테고리" width="140">
        <template #default="{ row }">
          <span class="category-tag">
            {{ row.categoryIcon || '📌' }}
            {{ row.categoryName }}
          </span>
        </template>
      </el-table-column>
      <el-table-column prop="amount" label="금액" width="140" align="right">
        <template #default="{ row }">
          <span :class="row.type === 'INCOME' ? 'amount-income' : 'amount-expense'">
            {{ row.type === 'INCOME' ? '+' : '-' }}{{ formatMoney(row.amount) }}
          </span>
        </template>
      </el-table-column>
      <el-table-column prop="paymentMethod" label="결제수단" width="100" v-if="!compact">
        <template #default="{ row }">
          {{ row.paymentMethod || '-' }}
        </template>
      </el-table-column>
      <el-table-column prop="memo" label="메모" min-width="180" v-if="!compact">
        <template #default="{ row }">
          <span class="memo-text">{{ row.memo || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="" width="100" align="right" v-if="!compact">
        <template #default="{ row }">
          <el-button-group size="small">
            <el-button @click="$emit('edit', row)">
              <el-icon><Edit /></el-icon>
            </el-button>
            <el-button type="danger" @click="$emit('delete', row)">
              <el-icon><Delete /></el-icon>
            </el-button>
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>
    <div v-else class="empty-state">
      <div class="icon">📭</div>
      <p>거래내역이 없습니다</p>
    </div>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'

defineProps({
  transactions: { type: Array, default: () => [] },
  compact: { type: Boolean, default: false }
})

defineEmits(['edit', 'delete'])

const formatDate = (date) => dayjs(date).format('MM/DD (ddd)')

const formatMoney = (value) => {
  return new Intl.NumberFormat('ko-KR').format(value)
}
</script>

<style scoped>
.memo-text {
  color: #909399;
  font-size: 13px;
}
</style>
