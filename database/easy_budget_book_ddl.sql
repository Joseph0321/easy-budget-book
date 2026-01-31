-- ============================================
-- Easy Budget Book - PostgreSQL DDL
-- PostgreSQL Version: 16.10
-- Generated: 2026-01-28
-- ============================================

-- ============================================
-- 1. DROP TABLES (순서 주의: FK 역순)
-- ============================================
DROP TABLE IF EXISTS public.expenses CASCADE;
DROP TABLE IF EXISTS public.incomes CASCADE;
DROP TABLE IF EXISTS public.receipts CASCADE;
DROP TABLE IF EXISTS public.categories CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- ============================================
-- 2. CREATE SEQUENCES
-- ============================================
CREATE SEQUENCE public.users_user_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.categories_category_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.receipts_receipt_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.incomes_income_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.expenses_expense_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

-- ============================================
-- 3. CREATE TABLES (컬럼 순서 정확히 일치)
-- ============================================

-- Users 테이블
CREATE TABLE public.users (
    user_id BIGINT NOT NULL DEFAULT nextval('public.users_user_id_seq'::regclass),
    created_at TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    provider VARCHAR(50),
    provider_id VARCHAR(255),
    updated_at TIMESTAMP(6) WITHOUT TIME ZONE,
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email)
);

-- Categories 테이블
CREATE TABLE public.categories (
    category_id BIGINT NOT NULL DEFAULT nextval('public.categories_category_id_seq'::regclass),
    color VARCHAR(7),
    created_at TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    icon VARCHAR(50),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL,
    user_id BIGINT NOT NULL,
    CONSTRAINT categories_pkey PRIMARY KEY (category_id)
);

-- Receipts 테이블
CREATE TABLE public.receipts (
    receipt_id BIGINT NOT NULL DEFAULT nextval('public.receipts_receipt_id_seq'::regclass),
    image_url TEXT,
    ocr_result TEXT,
    original_filename VARCHAR(255),
    processed_at TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    user_id BIGINT NOT NULL,
    CONSTRAINT receipts_pkey PRIMARY KEY (receipt_id)
);

-- Incomes 테이블
CREATE TABLE public.incomes (
    income_id BIGINT NOT NULL DEFAULT nextval('public.incomes_income_id_seq'::regclass),
    amount NUMERIC(15,2) NOT NULL,
    created_at TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    description TEXT,
    income_date DATE NOT NULL,
    updated_at TIMESTAMP(6) WITHOUT TIME ZONE,
    category_id BIGINT,
    user_id BIGINT NOT NULL,
    memo TEXT,
    payment_method VARCHAR(50),
    receipt_image_path VARCHAR(500),
    merchant_name VARCHAR(200),
    CONSTRAINT incomes_pkey PRIMARY KEY (income_id)
);

-- Expenses 테이블
CREATE TABLE public.expenses (
    expense_id BIGINT NOT NULL DEFAULT nextval('public.expenses_expense_id_seq'::regclass),
    amount NUMERIC(15,2) NOT NULL,
    created_at TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    description TEXT,
    expense_date DATE NOT NULL,
    updated_at TIMESTAMP(6) WITHOUT TIME ZONE,
    category_id BIGINT,
    user_id BIGINT NOT NULL,
    receipt_id BIGINT,
    memo TEXT,
    payment_method VARCHAR(50),
    receipt_image_path VARCHAR(500),
    merchant_name VARCHAR(200),
    CONSTRAINT expenses_pkey PRIMARY KEY (expense_id)
);

-- ============================================
-- 4. CREATE INDEXES
-- ============================================
CREATE INDEX idx_user_email ON public.users(email);
CREATE INDEX idx_user_provider ON public.users(provider, provider_id);
CREATE INDEX idx_category_user ON public.categories(user_id);
CREATE INDEX idx_category_user_type ON public.categories(user_id, type);
CREATE INDEX idx_receipt_user ON public.receipts(user_id);
CREATE INDEX idx_receipt_processed ON public.receipts(processed_at);
CREATE INDEX idx_income_user ON public.incomes(user_id);
CREATE INDEX idx_income_user_date ON public.incomes(user_id, income_date);
CREATE INDEX idx_income_category ON public.incomes(category_id);
CREATE INDEX idx_expense_user ON public.expenses(user_id);
CREATE INDEX idx_expense_user_date ON public.expenses(user_id, expense_date);
CREATE INDEX idx_expense_category ON public.expenses(category_id);

-- ============================================
-- 5. ADD FOREIGN KEY CONSTRAINTS
-- ============================================
ALTER TABLE public.categories ADD CONSTRAINT fk_categories_user 
    FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

ALTER TABLE public.receipts ADD CONSTRAINT fk_receipts_user 
    FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

ALTER TABLE public.incomes ADD CONSTRAINT fk_incomes_user 
    FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

ALTER TABLE public.incomes ADD CONSTRAINT fk_incomes_category 
    FOREIGN KEY (category_id) REFERENCES public.categories(category_id);

ALTER TABLE public.expenses ADD CONSTRAINT fk_expenses_user 
    FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

ALTER TABLE public.expenses ADD CONSTRAINT fk_expenses_category 
    FOREIGN KEY (category_id) REFERENCES public.categories(category_id);

ALTER TABLE public.expenses ADD CONSTRAINT fk_expenses_receipt 
    FOREIGN KEY (receipt_id) REFERENCES public.receipts(receipt_id);

-- ============================================
-- 6. SET SEQUENCE VALUES (데이터 삽입 후 실행)
-- ============================================
-- SELECT setval('public.users_user_id_seq', (SELECT COALESCE(MAX(user_id), 1) FROM public.users));
-- SELECT setval('public.categories_category_id_seq', (SELECT COALESCE(MAX(category_id), 1) FROM public.categories));
-- SELECT setval('public.receipts_receipt_id_seq', (SELECT COALESCE(MAX(receipt_id), 1) FROM public.receipts));
-- SELECT setval('public.incomes_income_id_seq', (SELECT COALESCE(MAX(income_id), 1) FROM public.incomes));
-- SELECT setval('public.expenses_expense_id_seq', (SELECT COALESCE(MAX(expense_id), 1) FROM public.expenses));
