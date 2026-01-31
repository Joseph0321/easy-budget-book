-- ============================================
-- Easy Budget Book - DROP DDL
-- PostgreSQL Version: 16.10
-- Generated: 2026-01-28
-- ============================================
-- 주의: 이 스크립트는 모든 테이블과 데이터를 삭제합니다!
-- ============================================

-- ============================================
-- 1. DROP TABLES (FK 역순으로 삭제)
-- ============================================
DROP TABLE IF EXISTS public.expenses CASCADE;
DROP TABLE IF EXISTS public.incomes CASCADE;
DROP TABLE IF EXISTS public.receipts CASCADE;
DROP TABLE IF EXISTS public.categories CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- ============================================
-- 2. DROP SEQUENCES
-- ============================================
DROP SEQUENCE IF EXISTS public.expenses_expense_id_seq CASCADE;
DROP SEQUENCE IF EXISTS public.incomes_income_id_seq CASCADE;
DROP SEQUENCE IF EXISTS public.receipts_receipt_id_seq CASCADE;
DROP SEQUENCE IF EXISTS public.categories_category_id_seq CASCADE;
DROP SEQUENCE IF EXISTS public.users_user_id_seq CASCADE;

-- ============================================
-- 3. DROP INDEXES (테이블 삭제 시 자동 삭제됨)
-- ============================================
-- DROP INDEX IF EXISTS idx_user_email;
-- DROP INDEX IF EXISTS idx_user_provider;
-- DROP INDEX IF EXISTS idx_category_user;
-- DROP INDEX IF EXISTS idx_category_user_type;
-- DROP INDEX IF EXISTS idx_receipt_user;
-- DROP INDEX IF EXISTS idx_receipt_processed;
-- DROP INDEX IF EXISTS idx_income_user;
-- DROP INDEX IF EXISTS idx_income_user_date;
-- DROP INDEX IF EXISTS idx_income_category;
-- DROP INDEX IF EXISTS idx_expense_user;
-- DROP INDEX IF EXISTS idx_expense_user_date;
-- DROP INDEX IF EXISTS idx_expense_category;

-- ============================================
-- 완료: 모든 객체가 삭제되었습니다.
-- ============================================
