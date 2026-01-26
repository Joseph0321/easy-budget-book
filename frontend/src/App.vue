<template>
  <div class="app-layout">
    <aside class="sidebar">
      <div class="sidebar-logo">
        <span class="logo-icon">📊</span>
        <span class="logo-text">편리한 가계부</span>
      </div>
      
      <div class="user-info">
        <span class="user-label">USER ACCOUNT</span>
        <span class="user-name">사용자 ID</span>
      </div>
      
      <nav class="sidebar-nav">
        <router-link to="/" class="nav-item" :class="{ active: route.path === '/' }">
          <span class="nav-icon">📊</span>
          <span>대시보드</span>
        </router-link>
        <router-link to="/transactions" class="nav-item" :class="{ active: route.path === '/transactions' }">
          <span class="nav-icon">📋</span>
          <span>거래내역</span>
        </router-link>
        <router-link to="/statistics" class="nav-item" :class="{ active: route.path === '/statistics' }">
          <span class="nav-icon">📈</span>
          <span>통계분석</span>
        </router-link>
        <div class="nav-item">
          <span class="nav-icon">⚙️</span>
          <span>환경설정</span>
        </div>
      </nav>
      
      <div class="sidebar-footer">
        <div class="nav-item">
          <span class="nav-icon">🚪</span>
          <span>로그아웃</span>
        </div>
      </div>
    </aside>
    
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: #0d0d1a;
  color: #ffffff;
}
</style>

<style scoped>
.app-layout {
  display: flex;
  min-height: 100vh;
  background: #0d0d1a;
}

.sidebar {
  width: 220px;
  background: #12121f;
  display: flex;
  flex-direction: column;
  padding: 20px 0;
  border-right: 1px solid #1a1a2e;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  padding: 0 20px;
  margin-bottom: 24px;
}

.logo-icon {
  font-size: 24px;
  margin-right: 10px;
}

.logo-text {
  font-size: 18px;
  font-weight: 700;
  color: #d4ff00;
}

.user-info {
  display: flex;
  flex-direction: column;
  padding: 12px 20px;
  margin: 0 16px 20px;
  background: #1a1a2e;
  border-radius: 8px;
}

.user-label {
  font-size: 10px;
  color: #666;
  margin-bottom: 4px;
  text-transform: uppercase;
}

.user-name {
  font-size: 14px;
  color: #d4ff00;
  font-weight: 600;
}

.sidebar-nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 0 12px;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  color: #888;
  text-decoration: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
}

.nav-item:hover {
  background: #1a1a2e;
  color: #fff;
}

.nav-item.active {
  background: #d4ff00;
  color: #0d0d1a;
  font-weight: 600;
}

.nav-icon {
  font-size: 16px;
  margin-right: 12px;
}

.sidebar-footer {
  padding: 0 12px;
  border-top: 1px solid #1a1a2e;
  padding-top: 16px;
  margin-top: 16px;
}

.main-content {
  flex: 1;
  padding: 24px 32px;
  overflow-y: auto;
  background: #0d0d1a;
}
</style>
