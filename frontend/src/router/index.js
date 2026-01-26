import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../views/Dashboard.vue'
import TransactionList from '../views/TransactionList.vue'
import Statistics from '../views/Statistics.vue'
import CategoryManagement from '../views/CategoryManagement.vue'

const routes = [
  { path: '/', name: 'Dashboard', component: Dashboard },
  { path: '/transactions', name: 'TransactionList', component: TransactionList },
  { path: '/statistics', name: 'Statistics', component: Statistics },
  { path: '/categories', name: 'CategoryManagement', component: CategoryManagement }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
