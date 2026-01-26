# Easy Budget Book

## Overview
Personal budget management application built with Spring Boot 3.2.0, PostgreSQL, and Vue.js 3. Features Korean language UI with income/expense tracking, categories, receipts, Excel import/export, and statistics.

## Project Details
- **Backend**: Spring Boot 3.2.0 (Java 17, Maven)
- **Frontend**: Vue.js 3 with Vite, Element Plus, Chart.js
- **Database**: PostgreSQL
- **Language**: Korean (한국어)

## Architecture
```
├── src/main/java/com/budget/easybook/   # Spring Boot Backend (Port 8080)
│   ├── EasyBudgetApplication.java
│   ├── config/                           # CORS, Test Controllers
│   ├── auth/                             # User authentication
│   ├── income/                           # Income CRUD
│   ├── expense/                          # Expense CRUD
│   ├── category/                         # Categories
│   ├── transaction/                      # Unified transaction API
│   └── excel/                            # Excel import/export
│
└── frontend/                             # Vue.js 3 Frontend (Port 5000)
    ├── src/
    │   ├── views/                        # Dashboard, TransactionList, Statistics, CategoryManagement
    │   ├── components/                   # TransactionForm, TransactionTable, Charts, DateRangePicker
    │   ├── services/                     # API layer (axios)
    │   └── router/                       # Vue Router
    └── vite.config.js                    # Proxy /api to backend
```

## API Endpoints
- `GET /api/transactions/period?userId=9&start=2026-01-01&end=2026-01-31` - Get transactions
- `GET /api/transactions/monthly/{year}/{month}/summary?userId=9` - Monthly summary
- `GET /api/transactions/export/excel` - Export Excel
- `POST /api/transactions/import/excel` - Import Excel

## Sample Data
- User ID 9 has 40 sample transactions for January 2026
- Categories: 급여💰, 부수입💵, 식비🍔, 교통비🚗, 주거비🏠, etc.
- Payment methods: 현금, 신용카드, 체크카드, 계좌이체

## Running the Application
- Backend: `mvn spring-boot:run` (runs on port 8080)
- Frontend: `cd frontend && npm run dev` (runs on port 5000, proxies /api to backend)

## UI Design
- **Theme**: Dark theme with dark navy background (#0d0d1a)
- **Accent Color**: Yellow/lime (#d4ff00) for highlights and active states
- **Layout**: Left sidebar navigation + main content area
- **Sidebar**: 편리한 가계부 logo, user account section, navigation menu
- **Dashboard**: Welcome header, summary cards, donut charts with center totals, monthly bar chart, transactions table
- **Charts**: Donut charts with TOTAL display in center, bar charts with dark grid styling

## Recent Changes
- 2026-01-24: Redesigned entire UI with dark theme matching new design specification
- 2026-01-24: Changed layout from top navigation to left sidebar navigation
- 2026-01-24: Converted pie charts to donut charts with center total display
- 2026-01-24: Updated all views (Dashboard, Statistics, TransactionList) with dark theme styling
- 2026-01-22: Created Vue.js 3 frontend with Element Plus UI
- 2026-01-22: Added CORS configuration for frontend-backend integration
- 2026-01-22: Implemented Dashboard, TransactionList, Statistics, CategoryManagement views
- 2026-01-22: Added Chart.js charts (pie chart, bar chart) for statistics
- 2026-01-22: Excel download/upload functionality integrated
