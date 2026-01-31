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
--
-- PostgreSQL database dump
--


-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (user_id, created_at, email, name, provider, provider_id, updated_at) VALUES (9, '2026-01-22 08:12:07.033467', 'demo@easybook.com', '홍길동', 'demo', 'demo2026', '2026-01-22 08:12:07.033659');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (74, '#FF6B6B', '2026-01-24 11:10:59.165548', '📚', '도서', 'EXPENSE', 9);
INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (75, '#4ECDC4', '2026-01-24 11:10:59.165548', '🛒', '비품', 'EXPENSE', 9);
INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (76, '#FFE66D', '2026-01-24 11:10:59.165548', '🍔', '식비', 'EXPENSE', 9);
INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (77, '#95E1D3', '2026-01-24 11:10:59.165548', '☕', '음료', 'EXPENSE', 9);
INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (78, '#F38181', '2026-01-24 11:10:59.165548', '🚗', '교통', 'EXPENSE', 9);
INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (79, '#AA96DA', '2026-01-24 11:10:59.165548', '📦', '기타', 'EXPENSE', 9);
INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (80, '#4ECDC4', '2026-01-24 11:10:59.165548', '💰', '급여', 'INCOME', 9);
INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (81, '#45B7D1', '2026-01-24 11:10:59.165548', '💼', '사업', 'INCOME', 9);
INSERT INTO public.categories (category_id, color, created_at, icon, name, type, user_id) VALUES (82, '#96CEB4', '2026-01-24 11:10:59.165548', '💵', '기타', 'INCOME', 9);


--
-- Data for Name: receipts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (564, 320000.00, '2026-01-25 03:20:42.439072', '아웃백스테이크하우스', '2025-01-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (565, 45000.00, '2026-01-25 03:20:42.439072', '스타벅스 신년모임', '2025-01-05', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (566, 180000.00, '2026-01-25 03:20:42.439072', '한우명가 가족식사', '2025-01-08', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (567, 35000.00, '2026-01-25 03:20:42.439072', '이디야커피', '2025-01-10', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (568, 28000.00, '2026-01-25 03:20:42.439072', '빽다방', '2025-01-12', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (569, 850000.00, '2026-01-25 03:20:42.439072', '월세', '2025-01-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (570, 125000.00, '2026-01-25 03:20:42.439072', 'SK주유소', '2025-01-18', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (571, 89000.00, '2026-01-25 03:20:42.439072', '본죽&비빔밥', '2025-01-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (572, 156000.00, '2026-01-25 03:20:42.439072', '다이소', '2025-01-22', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (573, 42000.00, '2026-01-25 03:20:42.439072', '교보문고', '2025-01-23', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (574, 230000.00, '2026-01-25 03:20:42.439072', 'CJ더마켓', '2025-01-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (575, 67000.00, '2026-01-25 03:20:42.439072', '맥도날드', '2025-01-25', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (576, 320000.00, '2026-01-25 03:20:42.439072', 'SKT 통신비', '2025-01-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (577, 98000.00, '2026-01-25 03:20:42.439072', '카카오T택시', '2025-01-27', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (578, 145000.00, '2026-01-25 03:20:42.439072', '이마트', '2025-01-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (579, 38000.00, '2026-01-25 03:20:42.439072', '공차', '2025-01-29', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (580, 420000.00, '2026-01-25 03:20:42.439072', '국민건강보험', '2025-01-30', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (581, 75000.00, '2026-01-25 03:20:42.439072', '쿠팡', '2025-01-30', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (582, 56000.00, '2026-01-25 03:20:42.439072', 'BBQ치킨', '2025-01-30', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (583, 680000.00, '2026-01-25 03:20:42.439072', '아파트관리비', '2025-01-31', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (584, 285000.00, '2026-01-25 03:20:42.439072', 'VIPS', '2025-02-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (585, 52000.00, '2026-01-25 03:20:42.439072', '김밥천국', '2025-02-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (586, 195000.00, '2026-01-25 03:20:42.439072', '설빙 발렌타인', '2025-02-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (587, 32000.00, '2026-01-25 03:20:42.439072', '메가커피', '2025-02-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (588, 850000.00, '2026-01-25 03:20:42.439072', '월세', '2025-02-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (589, 118000.00, '2026-01-25 03:20:42.439072', 'GS칼텍스', '2025-02-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (590, 78000.00, '2026-01-25 03:20:42.439072', '파리바게뜨', '2025-02-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (591, 165000.00, '2026-01-25 03:20:42.439072', '이케아', '2025-02-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (592, 55000.00, '2026-01-25 03:20:42.439072', '알라딘', '2025-02-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (593, 210000.00, '2026-01-25 03:20:42.439072', '홈플러스', '2025-02-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (594, 48000.00, '2026-01-25 03:20:42.439072', '써브웨이', '2025-02-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (595, 320000.00, '2026-01-25 03:20:42.439072', 'KT 통신비', '2025-02-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (596, 85000.00, '2026-01-25 03:20:42.439072', '서울지하철', '2025-02-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (597, 138000.00, '2026-01-25 03:20:42.439072', '롯데마트', '2025-02-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (598, 42000.00, '2026-01-25 03:20:42.439072', '스타벅스', '2025-02-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (599, 420000.00, '2026-01-25 03:20:42.439072', '국민연금', '2025-02-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (600, 92000.00, '2026-01-25 03:20:42.439072', '네이버쇼핑', '2025-02-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (601, 63000.00, '2026-01-25 03:20:42.439072', '교촌치킨', '2025-02-27', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (602, 680000.00, '2026-01-25 03:20:42.439072', '아파트관리비', '2025-02-28', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (603, 28000.00, '2026-01-25 03:20:42.439072', '컴포즈커피', '2025-02-28', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (604, 298000.00, '2026-01-25 03:21:06.415816', '애슐리퀸즈', '2025-03-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (605, 48000.00, '2026-01-25 03:21:06.415816', '맘스터치', '2025-03-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (606, 175000.00, '2026-01-25 03:21:06.415816', '한신포차', '2025-03-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (607, 36000.00, '2026-01-25 03:21:06.415816', '할리스커피', '2025-03-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (608, 850000.00, '2026-01-25 03:21:06.415816', '월세', '2025-03-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (609, 132000.00, '2026-01-25 03:21:06.415816', 'SK주유소', '2025-03-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (610, 92000.00, '2026-01-25 03:21:06.415816', '죽이야기', '2025-03-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (611, 178000.00, '2026-01-25 03:21:06.415816', '무신사', '2025-03-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (612, 48000.00, '2026-01-25 03:21:06.415816', '영풍문고', '2025-03-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (613, 245000.00, '2026-01-25 03:21:06.415816', '코스트코', '2025-03-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (614, 52000.00, '2026-01-25 03:21:06.415816', '버거킹', '2025-03-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (615, 320000.00, '2026-01-25 03:21:06.415816', 'LG유플러스', '2025-03-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (616, 72000.00, '2026-01-25 03:21:06.415816', '쏘카', '2025-03-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (617, 152000.00, '2026-01-25 03:21:06.415816', '이마트에브리데이', '2025-03-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (618, 39000.00, '2026-01-25 03:21:06.415816', '투썸플레이스', '2025-03-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (619, 420000.00, '2026-01-25 03:21:06.415816', '건강보험료', '2025-03-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (620, 86000.00, '2026-01-25 03:21:06.415816', 'SSG닷컴', '2025-03-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (621, 58000.00, '2026-01-25 03:21:06.415816', '도미노피자', '2025-03-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (622, 680000.00, '2026-01-25 03:21:06.415816', '아파트관리비', '2025-03-31', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (623, 25000.00, '2026-01-25 03:21:06.415816', '빽다방', '2025-03-30', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (624, 312000.00, '2026-01-25 03:21:06.415816', 'TGI프라이데이스', '2025-04-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (625, 56000.00, '2026-01-25 03:21:06.415816', '롯데리아', '2025-04-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (626, 188000.00, '2026-01-25 03:21:06.415816', '새마을식당', '2025-04-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (627, 34000.00, '2026-01-25 03:21:06.415816', '폴바셋', '2025-04-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (628, 850000.00, '2026-01-25 03:21:06.415816', '월세', '2025-04-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (629, 128000.00, '2026-01-25 03:21:06.415816', 'S-OIL', '2025-04-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (630, 82000.00, '2026-01-25 03:21:06.415816', '신전떡볶이', '2025-04-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (631, 195000.00, '2026-01-25 03:21:06.415816', '올리브영', '2025-04-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (632, 62000.00, '2026-01-25 03:21:06.415816', 'YES24', '2025-04-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (633, 228000.00, '2026-01-25 03:21:06.415816', '트레이더스', '2025-04-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (634, 45000.00, '2026-01-25 03:21:06.415816', 'KFC', '2025-04-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (635, 320000.00, '2026-01-25 03:21:06.415816', 'SKT 통신비', '2025-04-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (636, 95000.00, '2026-01-25 03:21:06.415816', '카카오T택시', '2025-04-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (637, 148000.00, '2026-01-25 03:21:06.415816', '하나로마트', '2025-04-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (638, 38000.00, '2026-01-25 03:21:06.415816', '파스쿠찌', '2025-04-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (639, 420000.00, '2026-01-25 03:21:06.415816', '국민연금', '2025-04-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (640, 78000.00, '2026-01-25 03:21:06.415816', '마켓컬리', '2025-04-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (641, 62000.00, '2026-01-25 03:21:06.415816', '푸라닭치킨', '2025-04-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (642, 680000.00, '2026-01-25 03:21:06.415816', '아파트관리비', '2025-04-30', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (643, 32000.00, '2026-01-25 03:21:06.415816', '엔제리너스', '2025-04-29', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (644, 278000.00, '2026-01-25 03:21:29.081007', '빕스', '2025-05-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (645, 52000.00, '2026-01-25 03:21:29.081007', '파파존스', '2025-05-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (646, 168000.00, '2026-01-25 03:21:29.081007', '명동교자', '2025-05-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (647, 38000.00, '2026-01-25 03:21:29.081007', '더벤티', '2025-05-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (648, 850000.00, '2026-01-25 03:21:29.081007', '월세', '2025-05-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (649, 122000.00, '2026-01-25 03:21:29.081007', 'GS칼텍스', '2025-05-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (650, 88000.00, '2026-01-25 03:21:29.081007', '농협하나로', '2025-05-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (651, 168000.00, '2026-01-25 03:21:29.081007', '지그재그', '2025-05-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (652, 45000.00, '2026-01-25 03:21:29.081007', '인터파크도서', '2025-05-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (653, 235000.00, '2026-01-25 03:21:29.081007', '홈플러스', '2025-05-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (654, 48000.00, '2026-01-25 03:21:29.081007', '피자헛', '2025-05-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (655, 320000.00, '2026-01-25 03:21:29.081007', 'KT 통신비', '2025-05-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (656, 68000.00, '2026-01-25 03:21:29.081007', '타다', '2025-05-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (657, 142000.00, '2026-01-25 03:21:29.081007', '이마트24', '2025-05-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (658, 42000.00, '2026-01-25 03:21:29.081007', '커피빈', '2025-05-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (659, 420000.00, '2026-01-25 03:21:29.081007', '건강보험료', '2025-05-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (660, 82000.00, '2026-01-25 03:21:29.081007', '11번가', '2025-05-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (661, 55000.00, '2026-01-25 03:21:29.081007', '멕시카나치킨', '2025-05-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (662, 680000.00, '2026-01-25 03:21:29.081007', '아파트관리비', '2025-05-31', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (663, 28000.00, '2026-01-25 03:21:29.081007', '탐앤탐스', '2025-05-30', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (664, 305000.00, '2026-01-25 03:21:29.081007', '마장동소고기', '2025-06-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (665, 58000.00, '2026-01-25 03:21:29.081007', '엽기떡볶이', '2025-06-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (666, 182000.00, '2026-01-25 03:21:29.081007', '놀부부대찌개', '2025-06-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (667, 35000.00, '2026-01-25 03:21:29.081007', '이디야커피', '2025-06-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (668, 850000.00, '2026-01-25 03:21:29.081007', '월세', '2025-06-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (669, 135000.00, '2026-01-25 03:21:29.081007', 'SK에너지', '2025-06-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (670, 95000.00, '2026-01-25 03:21:29.081007', '봉구스밥버거', '2025-06-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (671, 188000.00, '2026-01-25 03:21:29.081007', '에이블리', '2025-06-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (672, 52000.00, '2026-01-25 03:21:29.081007', '북센', '2025-06-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (673, 248000.00, '2026-01-25 03:21:29.081007', '롯데마트', '2025-06-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (674, 45000.00, '2026-01-25 03:21:29.081007', '롯데리아', '2025-06-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (675, 320000.00, '2026-01-25 03:21:29.081007', 'LG유플러스', '2025-06-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (676, 78000.00, '2026-01-25 03:21:29.081007', '카카오T택시', '2025-06-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (677, 155000.00, '2026-01-25 03:21:29.081007', 'GS더프레시', '2025-06-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (678, 40000.00, '2026-01-25 03:21:29.081007', '메가커피', '2025-06-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (679, 420000.00, '2026-01-25 03:21:29.081007', '국민연금', '2025-06-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (680, 95000.00, '2026-01-25 03:21:29.081007', '티몬', '2025-06-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (681, 62000.00, '2026-01-25 03:21:29.081007', '피자마루', '2025-06-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (682, 680000.00, '2026-01-25 03:21:29.081007', '아파트관리비', '2025-06-30', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (683, 30000.00, '2026-01-25 03:21:29.081007', '공차', '2025-06-29', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (684, 295000.00, '2026-01-25 03:21:51.722721', '팔색삼겹살', '2025-07-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (685, 55000.00, '2026-01-25 03:21:51.722721', '네네치킨', '2025-07-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (686, 175000.00, '2026-01-25 03:21:51.722721', '원할머니보쌈', '2025-07-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (687, 38000.00, '2026-01-25 03:21:51.722721', '스타벅스', '2025-07-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (688, 850000.00, '2026-01-25 03:21:51.722721', '월세', '2025-07-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (689, 128000.00, '2026-01-25 03:21:51.722721', 'S-OIL', '2025-07-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (690, 85000.00, '2026-01-25 03:21:51.722721', '이삭토스트', '2025-07-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (691, 172000.00, '2026-01-25 03:21:51.722721', '오늘의집', '2025-07-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (692, 48000.00, '2026-01-25 03:21:51.722721', '반디앤루니스', '2025-07-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (693, 238000.00, '2026-01-25 03:21:51.722721', '이마트', '2025-07-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (694, 52000.00, '2026-01-25 03:21:51.722721', '굽네치킨', '2025-07-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (695, 320000.00, '2026-01-25 03:21:51.722721', 'SKT 통신비', '2025-07-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (696, 82000.00, '2026-01-25 03:21:51.722721', '서울지하철', '2025-07-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (697, 148000.00, '2026-01-25 03:21:51.722721', 'CU편의점', '2025-07-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (698, 42000.00, '2026-01-25 03:21:51.722721', '빽다방', '2025-07-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (699, 420000.00, '2026-01-25 03:21:51.722721', '건강보험료', '2025-07-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (700, 88000.00, '2026-01-25 03:21:51.722721', 'G마켓', '2025-07-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (701, 58000.00, '2026-01-25 03:21:51.722721', '자담치킨', '2025-07-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (702, 680000.00, '2026-01-25 03:21:51.722721', '아파트관리비', '2025-07-31', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (703, 32000.00, '2026-01-25 03:21:51.722721', '컴포즈커피', '2025-07-30', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (704, 288000.00, '2026-01-25 03:21:51.722721', '철판스테이크', '2025-08-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (705, 48000.00, '2026-01-25 03:21:51.722721', '모스버거', '2025-08-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (706, 178000.00, '2026-01-25 03:21:51.722721', '청기와타운', '2025-08-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (707, 36000.00, '2026-01-25 03:21:51.722721', '투썸플레이스', '2025-08-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (708, 850000.00, '2026-01-25 03:21:51.722721', '월세', '2025-08-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (709, 125000.00, '2026-01-25 03:21:51.722721', 'SK주유소', '2025-08-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (710, 92000.00, '2026-01-25 03:21:51.722721', '교동짬뽕', '2025-08-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (711, 185000.00, '2026-01-25 03:21:51.722721', '브랜디', '2025-08-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (712, 55000.00, '2026-01-25 03:21:51.722721', '리디북스', '2025-08-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (713, 242000.00, '2026-01-25 03:21:51.722721', '코스트코', '2025-08-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (714, 45000.00, '2026-01-25 03:21:51.722721', '파파이스', '2025-08-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (715, 320000.00, '2026-01-25 03:21:51.722721', 'KT 통신비', '2025-08-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (716, 75000.00, '2026-01-25 03:21:51.722721', '쏘카', '2025-08-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (717, 152000.00, '2026-01-25 03:21:51.722721', '세븐일레븐', '2025-08-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (718, 40000.00, '2026-01-25 03:21:51.722721', '할리스커피', '2025-08-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (719, 420000.00, '2026-01-25 03:21:51.722721', '국민연금', '2025-08-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (720, 92000.00, '2026-01-25 03:21:51.722721', '위메프', '2025-08-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (721, 55000.00, '2026-01-25 03:21:51.722721', '호식이두마리치킨', '2025-08-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (722, 680000.00, '2026-01-25 03:21:51.722721', '아파트관리비', '2025-08-31', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (723, 28000.00, '2026-01-25 03:21:51.722721', '엔제리너스', '2025-08-30', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (724, 302000.00, '2026-01-25 03:22:13.708354', '황소곱창', '2025-09-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (725, 52000.00, '2026-01-25 03:22:13.708354', '버거킹', '2025-09-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (726, 185000.00, '2026-01-25 03:22:13.708354', '본가', '2025-09-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (727, 35000.00, '2026-01-25 03:22:13.708354', '폴바셋', '2025-09-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (728, 850000.00, '2026-01-25 03:22:13.708354', '월세', '2025-09-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (729, 130000.00, '2026-01-25 03:22:13.708354', 'GS칼텍스', '2025-09-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (730, 88000.00, '2026-01-25 03:22:13.708354', '삼첩분식', '2025-09-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (731, 178000.00, '2026-01-25 03:22:13.708354', '29CM', '2025-09-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (732, 58000.00, '2026-01-25 03:22:13.708354', '밀리의서재', '2025-09-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (733, 248000.00, '2026-01-25 03:22:13.708354', '트레이더스', '2025-09-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (734, 48000.00, '2026-01-25 03:22:13.708354', '쉐이크쉑', '2025-09-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (735, 320000.00, '2026-01-25 03:22:13.708354', 'LG유플러스', '2025-09-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (736, 85000.00, '2026-01-25 03:22:13.708354', '카카오T택시', '2025-09-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (737, 145000.00, '2026-01-25 03:22:13.708354', 'GS25', '2025-09-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (738, 42000.00, '2026-01-25 03:22:13.708354', '파스쿠찌', '2025-09-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (739, 420000.00, '2026-01-25 03:22:13.708354', '건강보험료', '2025-09-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (740, 85000.00, '2026-01-25 03:22:13.708354', '인터파크', '2025-09-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (741, 58000.00, '2026-01-25 03:22:13.708354', '60계치킨', '2025-09-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (742, 680000.00, '2026-01-25 03:22:13.708354', '아파트관리비', '2025-09-30', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (743, 32000.00, '2026-01-25 03:22:13.708354', '더벤티', '2025-09-29', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (744, 315000.00, '2026-01-25 03:22:13.708354', '서래갈비', '2025-10-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (745, 48000.00, '2026-01-25 03:22:13.708354', '맥도날드', '2025-10-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (746, 192000.00, '2026-01-25 03:22:13.708354', '한촌설렁탕', '2025-10-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (747, 38000.00, '2026-01-25 03:22:13.708354', '커피빈', '2025-10-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (748, 850000.00, '2026-01-25 03:22:13.708354', '월세', '2025-10-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (749, 135000.00, '2026-01-25 03:22:13.708354', 'SK에너지', '2025-10-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (750, 82000.00, '2026-01-25 03:22:13.708354', '이디야분식', '2025-10-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (751, 182000.00, '2026-01-25 03:22:13.708354', '쿠팡', '2025-10-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (752, 52000.00, '2026-01-25 03:22:13.708354', '교보문고', '2025-10-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (753, 252000.00, '2026-01-25 03:22:13.708354', '홈플러스', '2025-10-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (754, 55000.00, '2026-01-25 03:22:13.708354', 'BBQ치킨', '2025-10-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (755, 320000.00, '2026-01-25 03:22:13.708354', 'SKT 통신비', '2025-10-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (756, 72000.00, '2026-01-25 03:22:13.708354', '타다', '2025-10-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (757, 158000.00, '2026-01-25 03:22:13.708354', '미니스톱', '2025-10-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (758, 40000.00, '2026-01-25 03:22:13.708354', '이디야커피', '2025-10-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (759, 420000.00, '2026-01-25 03:22:13.708354', '국민연금', '2025-10-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (760, 95000.00, '2026-01-25 03:22:13.708354', 'SSG닷컴', '2025-10-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (761, 62000.00, '2026-01-25 03:22:13.708354', '교촌치킨', '2025-10-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (762, 680000.00, '2026-01-25 03:22:13.708354', '아파트관리비', '2025-10-31', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (763, 28000.00, '2026-01-25 03:22:13.708354', '빽다방', '2025-10-30', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (764, 325000.00, '2026-01-25 03:22:35.748763', '한우마을', '2025-11-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (765, 55000.00, '2026-01-25 03:22:35.748763', 'KFC', '2025-11-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (766, 188000.00, '2026-01-25 03:22:35.748763', '전주비빔밥', '2025-11-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (767, 36000.00, '2026-01-25 03:22:35.748763', '스타벅스', '2025-11-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (768, 850000.00, '2026-01-25 03:22:35.748763', '월세', '2025-11-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (769, 128000.00, '2026-01-25 03:22:35.748763', 'S-OIL', '2025-11-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (770, 92000.00, '2026-01-25 03:22:35.748763', '김가네김밥', '2025-11-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (771, 175000.00, '2026-01-25 03:22:35.748763', '마켓컬리', '2025-11-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (772, 48000.00, '2026-01-25 03:22:35.748763', '알라딘', '2025-11-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (773, 245000.00, '2026-01-25 03:22:35.748763', '이마트', '2025-11-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (774, 52000.00, '2026-01-25 03:22:35.748763', '도미노피자', '2025-11-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (775, 320000.00, '2026-01-25 03:22:35.748763', 'KT 통신비', '2025-11-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (776, 88000.00, '2026-01-25 03:22:35.748763', '서울지하철', '2025-11-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (777, 148000.00, '2026-01-25 03:22:35.748763', 'CU편의점', '2025-11-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (778, 42000.00, '2026-01-25 03:22:35.748763', '투썸플레이스', '2025-11-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (779, 420000.00, '2026-01-25 03:22:35.748763', '건강보험료', '2025-11-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (780, 88000.00, '2026-01-25 03:22:35.748763', '네이버쇼핑', '2025-11-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (781, 58000.00, '2026-01-25 03:22:35.748763', '푸라닭치킨', '2025-11-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (782, 680000.00, '2026-01-25 03:22:35.748763', '아파트관리비', '2025-11-30', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (783, 35000.00, '2026-01-25 03:22:35.748763', '메가커피', '2025-11-29', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (784, 380000.00, '2026-01-25 03:22:35.748763', '정식당', '2025-12-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (785, 65000.00, '2026-01-25 03:22:35.748763', '피자헛', '2025-12-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (786, 210000.00, '2026-01-25 03:22:35.748763', '연말회식 삼겹살', '2025-12-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (787, 42000.00, '2026-01-25 03:22:35.748763', '엔제리너스', '2025-12-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (788, 850000.00, '2026-01-25 03:22:35.748763', '월세', '2025-12-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (789, 145000.00, '2026-01-25 03:22:35.748763', 'SK주유소', '2025-12-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (790, 98000.00, '2026-01-25 03:22:35.748763', '떡볶이천국', '2025-12-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (791, 195000.00, '2026-01-25 03:22:35.748763', '무신사', '2025-12-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (792, 65000.00, '2026-01-25 03:22:35.748763', '교보문고', '2025-12-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (793, 285000.00, '2026-01-25 03:22:35.748763', '연말장보기 코스트코', '2025-12-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (794, 58000.00, '2026-01-25 03:22:35.748763', '자담치킨', '2025-12-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (795, 320000.00, '2026-01-25 03:22:35.748763', 'LG유플러스', '2025-12-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (796, 95000.00, '2026-01-25 03:22:35.748763', '카카오T택시', '2025-12-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (797, 168000.00, '2026-01-25 03:22:35.748763', '이마트24', '2025-12-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (798, 48000.00, '2026-01-25 03:22:35.748763', '스타벅스 크리스마스', '2025-12-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (799, 420000.00, '2026-01-25 03:22:35.748763', '국민연금', '2025-12-26', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (800, 120000.00, '2026-01-25 03:22:35.748763', '연말선물 구매', '2025-12-27', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (801, 68000.00, '2026-01-25 03:22:35.748763', 'BBQ치킨', '2025-12-28', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (802, 680000.00, '2026-01-25 03:22:35.748763', '아파트관리비', '2025-12-31', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (803, 38000.00, '2026-01-25 03:22:35.748763', '할리스커피', '2025-12-30', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (804, 298000.00, '2026-01-25 03:22:51.776457', '신년회식 한우마을', '2026-01-02', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (805, 52000.00, '2026-01-25 03:22:51.776457', '버거킹', '2026-01-04', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (806, 185000.00, '2026-01-25 03:22:51.776457', '송년모임 횟집', '2026-01-06', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (807, 38000.00, '2026-01-25 03:22:51.776457', '투썸플레이스', '2026-01-08', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (808, 850000.00, '2026-01-25 03:22:51.776457', '월세', '2026-01-15', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (809, 132000.00, '2026-01-25 03:22:51.776457', 'GS칼텍스', '2026-01-12', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (810, 88000.00, '2026-01-25 03:22:51.776457', '김밥천국', '2026-01-14', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (811, 178000.00, '2026-01-25 03:22:51.776457', '쿠팡', '2026-01-16', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (812, 55000.00, '2026-01-25 03:22:51.776457', 'YES24', '2026-01-18', NULL, 74, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (813, 248000.00, '2026-01-25 03:22:51.776457', '홈플러스', '2026-01-20', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (814, 48000.00, '2026-01-25 03:22:51.776457', '도미노피자', '2026-01-21', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (815, 320000.00, '2026-01-25 03:22:51.776457', 'SKT 통신비', '2026-01-22', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (816, 82000.00, '2026-01-25 03:22:51.776457', '쏘카', '2026-01-23', NULL, 78, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (817, 152000.00, '2026-01-25 03:22:51.776457', 'GS더프레시', '2026-01-24', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (818, 40000.00, '2026-01-25 03:22:51.776457', '스타벅스', '2026-01-25', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (819, 420000.00, '2026-01-25 03:22:51.776457', '건강보험료', '2026-01-20', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (820, 92000.00, '2026-01-25 03:22:51.776457', '11번가', '2026-01-19', NULL, 75, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (821, 58000.00, '2026-01-25 03:22:51.776457', '교촌치킨', '2026-01-17', NULL, 76, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (822, 680000.00, '2026-01-25 03:22:51.776457', '아파트관리비', '2026-01-25', NULL, 79, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (823, 32000.00, '2026-01-25 03:22:51.776457', '빽다방', '2026-01-10', NULL, 77, 9, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (824, 19700.00, '2026-01-26 04:40:32.951776', '개인택시', '2026-01-11', '2026-01-26 04:40:32.951845', 78, 9, NULL, '사회보장정보원 미팅', '신용카드', NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (825, 19000.00, '2026-01-26 04:47:24.368174', '청년가', '2026-01-16', '2026-01-26 04:47:24.368196', 76, 9, NULL, '점심 안중현연구원 외 1명', '신용카드', NULL, NULL);
INSERT INTO public.expenses (expense_id, amount, created_at, description, expense_date, updated_at, category_id, user_id, receipt_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (826, 19000.00, '2026-01-26 06:12:16.945315', '청년가', '2026-01-16', '2026-01-26 06:13:33.66113', 79, 9, NULL, '삭제 대상', '신용카드', NULL, NULL);


--
-- Data for Name: incomes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (399, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-01-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (400, 350000.00, '2026-01-25 03:20:17.751875', '프리랜서 웹개발 프로젝트', '2025-01-15', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (401, 50000.00, '2026-01-25 03:20:17.751875', '당근마켓 중고거래', '2025-01-10', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (402, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-02-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (403, 420000.00, '2026-01-25 03:20:17.751875', '앱 유지보수 계약', '2025-02-18', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (404, 30000.00, '2026-01-25 03:20:17.751875', '번개장터 판매', '2025-02-05', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (405, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-03-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (406, 280000.00, '2026-01-25 03:20:17.751875', 'UI디자인 외주', '2025-03-12', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (407, 80000.00, '2026-01-25 03:20:17.751875', '주식 배당금', '2025-03-20', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (408, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-04-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (409, 500000.00, '2026-01-25 03:20:17.751875', '컨설팅 수수료', '2025-04-08', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (410, 25000.00, '2026-01-25 03:20:17.751875', '캐시백 적립금', '2025-04-15', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (411, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-05-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (412, 380000.00, '2026-01-25 03:20:17.751875', '랜딩페이지 제작', '2025-05-22', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (413, 45000.00, '2026-01-25 03:20:17.751875', '당근마켓 판매', '2025-05-10', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (414, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-06-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (415, 620000.00, '2026-01-25 03:20:17.751875', '모바일앱 외주', '2025-06-14', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (416, 35000.00, '2026-01-25 03:20:17.751875', '포인트 환전', '2025-06-28', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (417, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-07-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (418, 450000.00, '2026-01-25 03:20:17.751875', '홈페이지 리뉴얼', '2025-07-05', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (419, 60000.00, '2026-01-25 03:20:17.751875', '중고나라 판매', '2025-07-18', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (420, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-08-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (421, 320000.00, '2026-01-25 03:20:17.751875', 'SEO 최적화 작업', '2025-08-11', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (422, 40000.00, '2026-01-25 03:20:17.751875', '주식 배당금', '2025-08-22', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (423, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-09-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (424, 550000.00, '2026-01-25 03:20:17.751875', '쇼핑몰 구축', '2025-09-08', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (425, 55000.00, '2026-01-25 03:20:17.751875', '당근마켓 판매', '2025-09-15', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (426, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-10-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (427, 480000.00, '2026-01-25 03:20:17.751875', 'API 개발 외주', '2025-10-18', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (428, 70000.00, '2026-01-25 03:20:17.751875', '캐시백 리워드', '2025-10-05', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (429, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-11-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (430, 390000.00, '2026-01-25 03:20:17.751875', '관리자 페이지 제작', '2025-11-12', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (431, 85000.00, '2026-01-25 03:20:17.751875', '번개장터 판매', '2025-11-28', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (432, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2025-12-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (433, 750000.00, '2026-01-25 03:20:17.751875', '연말 프로젝트 보너스', '2025-12-20', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (434, 100000.00, '2026-01-25 03:20:17.751875', '연말 배당금', '2025-12-10', NULL, 82, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (435, 4200000.00, '2026-01-25 03:20:17.751875', '(주)테크솔루션 월급', '2026-01-25', NULL, 80, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (436, 420000.00, '2026-01-25 03:20:17.751875', '신년 웹사이트 리뉴얼', '2026-01-15', NULL, 81, 9, NULL, NULL, NULL, NULL);
INSERT INTO public.incomes (income_id, amount, created_at, description, income_date, updated_at, category_id, user_id, memo, payment_method, receipt_image_path, merchant_name) VALUES (437, 45000.00, '2026-01-25 03:20:17.751875', '당근마켓 판매', '2026-01-08', NULL, 82, 9, NULL, NULL, NULL, NULL);


--
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 82, true);


--
-- Name: expenses_expense_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.expenses_expense_id_seq', 826, true);


--
-- Name: incomes_income_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.incomes_income_id_seq', 437, true);


--
-- Name: receipts_receipt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.receipts_receipt_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 9, true);


--
-- PostgreSQL database dump complete
--



-- ============================================
-- SEQUENCE VALUES UPDATE (데이터 삽입 후 실행)
-- ============================================
SELECT setval('public.users_user_id_seq', (SELECT COALESCE(MAX(user_id), 1) FROM public.users));
SELECT setval('public.categories_category_id_seq', (SELECT COALESCE(MAX(category_id), 1) FROM public.categories));
SELECT setval('public.receipts_receipt_id_seq', (SELECT COALESCE(MAX(receipt_id), 1) FROM public.receipts));
SELECT setval('public.incomes_income_id_seq', (SELECT COALESCE(MAX(income_id), 1) FROM public.incomes));
SELECT setval('public.expenses_expense_id_seq', (SELECT COALESCE(MAX(expense_id), 1) FROM public.expenses));
