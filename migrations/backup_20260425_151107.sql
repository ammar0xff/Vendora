--
-- PostgreSQL database dump
--

\restrict FNqkJVaDpMYB89oi1Abb7gUi54FhraxqiKOd5H55dAgQPVGRXQwfSoJWtn5bgJN

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

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
-- Name: doc_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.doc_type_enum AS ENUM (
    'sale_invoice',
    'purchase_order',
    'shift_report',
    'inventory_report',
    'other',
    'quotation',
    'dispatch_order',
    'goods_receipt',
    'stock_request',
    'shift_handover',
    'purchase_invoice',
    'safe_deposit'
);


ALTER TYPE public.doc_type_enum OWNER TO postgres;

--
-- Name: drawer_tx_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.drawer_tx_type_enum AS ENUM (
    'sale',
    'return_',
    'expense',
    'deposit',
    'withdrawal'
);


ALTER TYPE public.drawer_tx_type_enum OWNER TO postgres;

--
-- Name: movement_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.movement_type_enum AS ENUM (
    'opening_stock',
    'purchase',
    'return_in',
    'adjustment_in',
    'transfer_in',
    'sale',
    'damage',
    'adjustment_out',
    'transfer_out'
);


ALTER TYPE public.movement_type_enum OWNER TO postgres;

--
-- Name: po_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.po_status_enum AS ENUM (
    'draft',
    'received',
    'partial',
    'cancelled'
);


ALTER TYPE public.po_status_enum OWNER TO postgres;

--
-- Name: sale_mode_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.sale_mode_enum AS ENUM (
    'retail',
    'wholesale'
);


ALTER TYPE public.sale_mode_enum OWNER TO postgres;

--
-- Name: sale_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.sale_status_enum AS ENUM (
    'draft',
    'confirmed',
    'returned',
    'cancelled',
    'quotation'
);


ALTER TYPE public.sale_status_enum OWNER TO postgres;

--
-- Name: shift_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.shift_status_enum AS ENUM (
    'open',
    'closed'
);


ALTER TYPE public.shift_status_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archived_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.archived_documents (
    id uuid NOT NULL,
    doc_number character varying(64) NOT NULL,
    doc_type public.doc_type_enum NOT NULL,
    customer_name character varying(128),
    amount numeric(12,2),
    file_path character varying(512),
    storage_key character varying(512),
    metadata jsonb,
    ref_id uuid,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.archived_documents OWNER TO postgres;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid,
    action text NOT NULL,
    user_id uuid,
    user_name text,
    changes jsonb,
    note text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id uuid NOT NULL,
    name character varying(128) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: collection_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    collection_id uuid NOT NULL,
    product_id uuid NOT NULL,
    qty numeric(12,3) DEFAULT 1 NOT NULL
);


ALTER TABLE public.collection_items OWNER TO postgres;

--
-- Name: customer_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_payments (
    id uuid NOT NULL,
    customer_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL,
    note text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.customer_payments OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id uuid NOT NULL,
    name character varying(128) NOT NULL,
    phone character varying(32),
    address text,
    is_cash boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    balance numeric(14,2) DEFAULT 0 NOT NULL
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: dispatch_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dispatch_seq
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dispatch_seq OWNER TO postgres;

--
-- Name: drawer_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drawer_transactions (
    id uuid NOT NULL,
    shift_id uuid NOT NULL,
    type public.drawer_tx_type_enum NOT NULL,
    amount numeric(12,2) NOT NULL,
    ref_id uuid,
    note text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    category_id uuid,
    payment_method text DEFAULT 'cash'::text,
    wallet_id uuid
);


ALTER TABLE public.drawer_transactions OWNER TO postgres;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id uuid NOT NULL,
    user_id uuid,
    full_name character varying(128) NOT NULL,
    national_id character varying(32),
    phone character varying(32),
    base_salary numeric(12,2) NOT NULL,
    hire_date date NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: financial_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(16) DEFAULT 'expense'::character varying NOT NULL,
    color character varying(16) DEFAULT '#64748b'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.financial_categories OWNER TO postgres;

--
-- Name: hr_advances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_advances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    note text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    record_type character varying(16) DEFAULT 'سلفة'::character varying
);


ALTER TABLE public.hr_advances OWNER TO postgres;

--
-- Name: hr_attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_attendance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    work_date date NOT NULL,
    check_in timestamp with time zone,
    check_out timestamp with time zone,
    status character varying(16) DEFAULT 'present'::character varying,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    edited boolean DEFAULT false,
    edited_by character varying(128),
    edit_reason text,
    excuse_no_late boolean DEFAULT false,
    excuse_no_early boolean DEFAULT false,
    excuse_allow_overtime boolean DEFAULT false,
    shift_override character varying(32)
);


ALTER TABLE public.hr_attendance OWNER TO postgres;

--
-- Name: hr_audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    action_type character varying(32) NOT NULL,
    entity_type character varying(32) NOT NULL,
    entity_id character varying(64),
    performed_by uuid,
    reason text,
    details jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.hr_audit_log OWNER TO postgres;

--
-- Name: hr_employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_employees (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    emp_code character varying(32),
    name character varying(128) NOT NULL,
    "position" character varying(64),
    monthly_salary numeric(12,2) DEFAULT 0 NOT NULL,
    shift_schedule character varying(64),
    hire_date date,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    shift_id character varying(32),
    max_lateness_before_overtime_cancellation integer DEFAULT 30,
    ignore_lateness boolean DEFAULT false
);


ALTER TABLE public.hr_employees OWNER TO postgres;

--
-- Name: hr_payroll; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_payroll (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    month character varying(7) NOT NULL,
    base_salary numeric(12,2) NOT NULL,
    working_days smallint DEFAULT 0,
    absent_days smallint DEFAULT 0,
    overtime_hours numeric(6,2) DEFAULT 0,
    overtime_pay numeric(12,2) DEFAULT 0,
    bonus numeric(12,2) DEFAULT 0,
    deductions numeric(12,2) DEFAULT 0,
    advances numeric(12,2) DEFAULT 0,
    drawer_variance numeric(12,2) DEFAULT 0,
    net_salary numeric(12,2) DEFAULT 0 NOT NULL,
    status character varying(16) DEFAULT 'draft'::character varying,
    notes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    actual_working_days smallint DEFAULT 0,
    vacation_days smallint DEFAULT 0,
    total_hours numeric(8,2) DEFAULT 0,
    lateness_minutes integer DEFAULT 0,
    early_leave_minutes integer DEFAULT 0,
    missing_scan_minutes integer DEFAULT 0,
    lateness_deduction numeric(12,2) DEFAULT 0,
    bonus_days smallint DEFAULT 0,
    bonus_payment numeric(12,2) DEFAULT 0,
    hourly_rate numeric(10,4) DEFAULT 0,
    daily_breakdown jsonb
);


ALTER TABLE public.hr_payroll OWNER TO postgres;

--
-- Name: hr_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_settings (
    key character varying(64) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.hr_settings OWNER TO postgres;

--
-- Name: hr_shifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_shifts (
    id character varying(32) NOT NULL,
    name character varying(128) NOT NULL,
    start_time character varying(8) NOT NULL,
    end_time character varying(8) NOT NULL,
    description text DEFAULT ''::text
);


ALTER TABLE public.hr_shifts OWNER TO postgres;

--
-- Name: hr_sync_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_sync_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    synced_at timestamp with time zone DEFAULT now(),
    status text NOT NULL,
    fetched integer DEFAULT 0,
    added integer DEFAULT 0,
    updated integer DEFAULT 0,
    message text
);


ALTER TABLE public.hr_sync_log OWNER TO postgres;

--
-- Name: invoice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoice_seq
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoice_seq OWNER TO postgres;

--
-- Name: payment_wallets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_wallets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    phone text,
    balance numeric(14,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT payment_wallets_type_check CHECK ((type = ANY (ARRAY['vodafone_cash'::text, 'instapay'::text, 'cash'::text])))
);


ALTER TABLE public.payment_wallets OWNER TO postgres;

--
-- Name: payroll_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll_entries (
    id uuid NOT NULL,
    period_id uuid NOT NULL,
    employee_id uuid NOT NULL,
    base_salary numeric(12,2) NOT NULL,
    bonuses numeric(12,2) NOT NULL,
    deductions numeric(12,2) NOT NULL,
    notes text
);


ALTER TABLE public.payroll_entries OWNER TO postgres;

--
-- Name: payroll_periods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll_periods (
    id uuid NOT NULL,
    month smallint NOT NULL,
    year smallint NOT NULL,
    status character varying(16) NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payroll_periods OWNER TO postgres;

--
-- Name: product_collections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_collections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    retail_price numeric(12,2) DEFAULT 0,
    wholesale_price numeric(12,2) DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.product_collections OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid NOT NULL,
    subcategory_id uuid NOT NULL,
    name character varying(256) NOT NULL,
    barcode character varying(64),
    unit character varying(32) NOT NULL,
    retail_price numeric(12,2) NOT NULL,
    wholesale_price numeric(12,2) NOT NULL,
    cost_price numeric(12,2) NOT NULL,
    company character varying(128),
    size character varying(64),
    type character varying(64),
    material character varying(64),
    image_url character varying(512),
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    reorder_point numeric(12,3) DEFAULT 0,
    reorder_qty numeric(12,3) DEFAULT 0,
    stock_status text DEFAULT 'tracked'::text NOT NULL,
    CONSTRAINT products_stock_status_check CHECK ((stock_status = ANY (ARRAY['tracked'::text, 'untracked'::text])))
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: purchase_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_order_items (
    id uuid NOT NULL,
    po_id uuid NOT NULL,
    product_id uuid NOT NULL,
    qty_ordered numeric(12,3) NOT NULL,
    qty_received numeric(12,3) NOT NULL,
    unit_cost numeric(12,2) NOT NULL,
    notes text
);


ALTER TABLE public.purchase_order_items OWNER TO postgres;

--
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_orders (
    id uuid NOT NULL,
    po_number character varying(32) NOT NULL,
    supplier_id uuid,
    warehouse_id uuid NOT NULL,
    created_by uuid NOT NULL,
    status public.po_status_enum NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    received_at timestamp with time zone,
    amount_paid numeric(14,2) DEFAULT 0,
    received_by_name text,
    invoice_image_url text
);


ALTER TABLE public.purchase_orders OWNER TO postgres;

--
-- Name: purchase_price_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_price_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    po_id uuid,
    supplier_id uuid,
    old_cost numeric(12,2),
    new_cost numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.purchase_price_history OWNER TO postgres;

--
-- Name: purchase_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_seq
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_seq OWNER TO postgres;

--
-- Name: quotation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quotation_seq
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quotation_seq OWNER TO postgres;

--
-- Name: safe_deposits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.safe_deposits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    safe_id uuid NOT NULL,
    shift_id uuid,
    warehouse_id uuid,
    amount numeric(14,2) NOT NULL,
    received_by uuid,
    received_by_name text,
    deposited_by uuid,
    deposited_by_name text,
    notes text,
    doc_number text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.safe_deposits OWNER TO postgres;

--
-- Name: safe_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.safe_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    safe_id uuid NOT NULL,
    tx_type text NOT NULL,
    amount numeric(14,2) NOT NULL,
    balance_after numeric(14,2) NOT NULL,
    note text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT safe_transactions_tx_type_check CHECK ((tx_type = ANY (ARRAY['deposit'::text, 'withdraw'::text])))
);


ALTER TABLE public.safe_transactions OWNER TO postgres;

--
-- Name: safes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.safes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    location text,
    balance numeric(14,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    safe_type text DEFAULT 'permanent'::text NOT NULL
);


ALTER TABLE public.safes OWNER TO postgres;

--
-- Name: sale_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sale_items (
    id uuid NOT NULL,
    sale_id uuid NOT NULL,
    product_id uuid NOT NULL,
    qty numeric(12,3) NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    unit_cost numeric(12,2) NOT NULL,
    discount numeric(12,2) NOT NULL
);


ALTER TABLE public.sale_items OWNER TO postgres;

--
-- Name: sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales (
    id uuid NOT NULL,
    invoice_number character varying(32) NOT NULL,
    customer_id uuid,
    warehouse_id uuid NOT NULL,
    cashier_id uuid NOT NULL,
    shift_id uuid,
    sale_mode public.sale_mode_enum NOT NULL,
    status public.sale_status_enum NOT NULL,
    discount_amount numeric(12,2) NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_credit boolean DEFAULT false NOT NULL,
    created_by uuid,
    payment_method text DEFAULT 'cash'::text,
    wallet_id uuid
);


ALTER TABLE public.sales OWNER TO postgres;

--
-- Name: shifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shifts (
    id uuid NOT NULL,
    cashier_id uuid,
    status public.shift_status_enum NOT NULL,
    initial_amount numeric(12,2) NOT NULL,
    closing_balance numeric(12,2),
    next_day_drawer numeric(12,2),
    closed_by uuid,
    notes text,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    closed_at timestamp with time zone,
    warehouse_id uuid,
    supervisor_id uuid,
    deposit_received_by uuid,
    deposit_amount numeric(12,2)
);


ALTER TABLE public.shifts OWNER TO postgres;

--
-- Name: stock_movements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_movements (
    id uuid NOT NULL,
    product_id uuid NOT NULL,
    warehouse_id uuid NOT NULL,
    movement_type public.movement_type_enum NOT NULL,
    qty numeric(12,3) NOT NULL,
    unit_cost numeric(12,2) NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    ref_id uuid,
    ref_type character varying(32),
    note text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.stock_movements OWNER TO postgres;

--
-- Name: store_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store_settings (
    key character varying(64) NOT NULL,
    value text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.store_settings OWNER TO postgres;

--
-- Name: subcategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subcategories (
    id uuid NOT NULL,
    category_id uuid NOT NULL,
    name character varying(128) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.subcategories OWNER TO postgres;

--
-- Name: supplier_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid NOT NULL,
    amount numeric(14,2) NOT NULL,
    type text NOT NULL,
    reference_doc text,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT supplier_transactions_type_check CHECK ((type = ANY (ARRAY['debit'::text, 'credit'::text])))
);


ALTER TABLE public.supplier_transactions OWNER TO postgres;

--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    id uuid NOT NULL,
    name character varying(128) NOT NULL,
    phone character varying(32),
    address text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    type text DEFAULT 'supplier'::text NOT NULL,
    balance numeric(14,2) DEFAULT 0 NOT NULL,
    notes text
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    username character varying(64) NOT NULL,
    full_name character varying(128) NOT NULL,
    role character varying(32) NOT NULL,
    password_hash character varying(256) NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    permissions jsonb DEFAULT '["pos", "inventory", "reports", "archive", "settings"]'::jsonb,
    is_manager boolean DEFAULT false NOT NULL,
    default_warehouse_id uuid
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: wallet_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallet_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    wallet_id uuid NOT NULL,
    amount numeric(14,2) NOT NULL,
    tx_type text NOT NULL,
    ref_id uuid,
    note text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.wallet_transactions OWNER TO postgres;

--
-- Name: warehouse_product_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouse_product_status (
    warehouse_id uuid NOT NULL,
    product_id uuid NOT NULL,
    status text DEFAULT 'untracked'::text NOT NULL
);


ALTER TABLE public.warehouse_product_status OWNER TO postgres;

--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouses (
    id uuid NOT NULL,
    code character varying(32) NOT NULL,
    name character varying(128) NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    warehouse_type character varying(20) DEFAULT 'warehouse'::character varying NOT NULL
);


ALTER TABLE public.warehouses OWNER TO postgres;

--
-- Data for Name: archived_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.archived_documents (id, doc_number, doc_type, customer_name, amount, file_path, storage_key, metadata, ref_id, created_by, created_at) FROM stdin;
87adffa7-fb7a-5e63-baa2-b6efa7daa071	INV-03112837	sale_invoice	عميل نقدي	\N	INV-03112837_2026-03-24_11-28-37.pdf	\N	{"total": 0.0, "metadata": {"mode": "retail", "customer": "عميل نقدي", "employee": "عمار محمد السيد"}, "products": [{"name": "خلاط وش اليريا (الكوك)", "unit": "عدد", "price": 0.0, "quantity": 15.0}]}	\N	\N	2026-03-24 11:28:37.890514+00
16f43e7f-fd32-5507-992a-f12300662bfb	INV-03105608	sale_invoice	ابو ادم	\N	INV-03105608_2026-03-24_10-56-10.pdf	\N	{"total": 0.0, "metadata": {"mode": "wholesale", "customer": "ابو ادم", "employee": "عمار محمد السيد"}, "products": [{"name": "محبس بلية 2\\" جويل (ادهم)", "unit": "عدد", "price": 0.0, "quantity": 5.0}, {"name": "حنفية كوبشة شجرة", "unit": "عدد", "price": 0.0, "quantity": 2.0}]}	\N	\N	2026-03-24 10:56:10.182723+00
8292c990-181a-5676-a9cb-2da73ac1af9e	INV-02124801	sale_invoice	عميل نقدي	\N	INV-02124801_2026-02-10_12-48-02.pdf	\N	{"total": 0.0, "metadata": {"mode": "retail", "customer": "عميل نقدي", "employee": "عمار محمد السيد"}, "products": [{"name": "قنطرة وش هاند ميكسر طويلة", "unit": "عدد", "price": 0.0, "quantity": 15.0}, {"name": "قنطرة هاند ميكسر مطبخ", "unit": "عدد", "price": 0.0, "quantity": 15.0}, {"name": "قنطرة هاند ميكسر غكاز مطبخ", "unit": "عدد", "price": 0.0, "quantity": 1.0}]}	\N	\N	2026-02-10 12:48:02.516113+00
6d4ff74c-a56e-50ef-abec-32335f3f9a5c	INV-02202539	sale_invoice	عميل نقدي	14.00	INV-02202539_2026-02-09_20-25-40.pdf	\N	{"total": 14.0, "metadata": {"mode": "retail", "customer": "عميل نقدي", "employee": "عمار محمد السيد"}, "products": [{"name": "hhhhhhhhhhh", "unit": "عدد", "price": 7.0, "quantity": 2.0}]}	\N	\N	2026-02-09 20:25:40.113514+00
1e719b32-4018-4f57-a085-cc0b6c60bf5c	DSP-0325204931	dispatch_order	\N	5.00	\N	\N	{"to": "المعرض الرئيسي", "from": "المخزن الأول", "items": [{"qty": 5.0, "name": "محبس بالأكور سالمكو محمل بوصة (ادهم)", "product_id": "c8b78e53-a457-4b32-8897-c449f3fe1e4f"}], "notes": "صرف للمعرض", "employee": "عمار محمد السيد"}	9238cc9e-ab78-4676-8cff-79228ddc1f1c	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:49:31.492925+00
8c1c2302-74d2-4fc9-bb10-52fe31c3f466	GR-0325204931	goods_receipt	\N	1550.00	\N	\N	{"items": [{"qty": 100.0, "name": "محبس بالأكور سالمكو محمل بوصة (ادهم)", "unit_cost": 15.5, "product_id": "c8b78e53-a457-4b32-8897-c449f3fe1e4f"}], "notes": "فاتورة 1234", "employee": "عمار محمد السيد", "supplier": "شركة الأنابيب المصرية", "warehouse": "المخزن الأول"}	96df7161-c316-4e54-93f7-853861ccbc36	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:49:31.620689+00
1dd5af12-0220-44fd-92b9-4f8d6d0ac1cb	REQ-0325204931	stock_request	\N	0.00	\N	\N	{"to": "المعرض الرئيسي", "from": "المخزن الأول", "items": [{"qty": 20.0, "name": "محبس بالأكور سالمكو محمل بوصة (ادهم)", "product_id": "c8b78e53-a457-4b32-8897-c449f3fe1e4f"}], "notes": "نواقص المعرض", "status": "pending", "employee": "عمار محمد السيد"}	7e00c6a1-5657-4967-8ff3-3e3abf2939d2	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:49:31.70496+00
a121077d-7f13-44a8-9ce3-23eb12b8bde8	QUO-0325205705	quotation	\N	\N	\N	\N	{"mode": "wholesale", "items_count": 1}	057b59b5-9e08-4411-bf43-6b75dd16f914	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:57:05.501256+00
cb0a58ea-6060-45c9-a587-53b87880adfb	INV-0325220821	sale_invoice	\N	320.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	59b9226f-dfaa-462f-ba0c-f821151888d9	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:08:21.448315+00
7ad19f7d-7d28-4fb0-8aa9-38efe9194a1c	INV-0325220854	sale_invoice	\N	215.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 3}	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:08:54.072689+00
9b393d9c-d7ec-4485-bd6b-ecefdd66ad09	INV-0325221111	sale_invoice	\N	60.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	8ffd2445-36b9-4860-b005-711c418cc856	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:11:11.259283+00
35befb19-4034-4fca-963b-4cd15f217399	INV-0326053034	sale_invoice	\N	5250.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	de55ead7-27bd-4e29-ad9a-e7aef4b74978	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 05:30:34.348101+00
596a51b0-1125-4e6b-a05a-722d06ae17ba	INV-0326095143	sale_invoice	\N	400.00	\N	\N	{"mode": "SaleMode.wholesale", "items_count": 1}	15bf83d7-f130-4bce-a71b-e4587d7d9b62	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 09:51:43.619985+00
3e790f87-31a0-4099-bed3-a4980cd62590	INV-0326095144	sale_invoice	\N	100.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	8292cd3e-da80-4675-b002-c4e398917432	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 09:51:44.114358+00
b8d6049e-00e6-440f-a936-d76325b9ebc4	INV-0326104103	sale_invoice	\N	90.00	\N	\N	{"mode": "SaleMode.wholesale", "items_count": 2}	6dda74b4-cb34-4648-8f6e-44fb7a3672b5	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:41:03.844594+00
bd2d5970-b28d-4e83-9b19-edcb2eb97001	INV-0326104521	sale_invoice	\N	500.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	6348d7f3-012a-4b73-bfec-2fdf78efdc93	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:45:21.104278+00
2aa2a89a-948e-45dc-8f43-ac9817051f66	RET-0326104521	sale_invoice	\N	200.00	\N	\N	{"type": "partial_return", "original_invoice": "INV-0326104521"}	48c0fe08-ef76-49d1-bb60-040e3cf6199d	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:45:21.226507+00
8b6aa296-319f-44f4-9bef-0a378e3de8b3	RET-0326125337	sale_invoice	\N	200.00	\N	\N	{"type": "partial_return", "original_invoice": "INV-0326095143"}	884ae1ed-8143-4046-8fa4-0d857306db9a	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 12:53:37.629082+00
1955425b-3eb1-4078-b0a8-c03885e4178a	INV-0327151000	sale_invoice	\N	100.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	0dce5e50-b8c5-4941-a0f6-cf5a48fd046a	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 15:10:00.625953+00
c3a794d4-71dc-456f-a410-9b08cc92bc78	QUO-0327151000	quotation	\N	\N	\N	\N	{"mode": "wholesale", "items_count": 1}	60741e19-f2c2-4e79-abc7-8f6c53055111	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 15:10:00.796871+00
e991fc1b-3642-463d-824d-dae7e3e661dd	QUO-0327151032	quotation	\N	\N	\N	\N	{"mode": "wholesale", "items_count": 1}	569525ba-651e-4f5c-897d-aa471449308b	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 15:10:32.703657+00
dd47fe81-b1bf-4a67-b633-57385f101782	INV-0328120249	sale_invoice	\N	300.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	7189b418-dcf5-4925-ae01-eee514901aa4	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:49.595964+00
d6e5559b-2cd4-472f-927d-c01e3809f90c	DSP-0328141733	dispatch_order	\N	7.00	\N	\N	{"to": "معرض المؤمن", "from": "البادروم", "items": [{"qty": 7.0, "name": "كوع عاده 1\\"", "product_id": "7c033855-5e8a-44e7-a03a-c91729b55080"}], "notes": "احا", "employee": "عمار محمد السيد"}	37566316-bffe-4b80-8e23-c8f905921fd6	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 14:17:33.501816+00
e0fce10e-4191-43b9-a55b-39c41353ce58	HND-0325224735	shift_handover	\N	500.00	\N	\N	{"notes": "", "amount": 500.0, "to_user": "6a11d77b-24cc-577e-9ec3-4b0088eb7585", "from_user": "f00d039c-caa7-5b00-adba-365ed90c5f10", "to_user_name": "ندا خالد احمد النجار", "from_user_name": "عمار محمد السيد"}	d139d108-aea2-4725-b5f1-6c8f6f6975f1	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:47:35.377359+00
23bc564f-9ee2-4720-a683-9541e5af75a3	HND-0326031201	shift_handover	\N	400.00	\N	\N	{"notes": "", "amount": 400.0, "to_user": "6a11d77b-24cc-577e-9ec3-4b0088eb7585", "from_user": "f00d039c-caa7-5b00-adba-365ed90c5f10", "to_user_name": "ندا خالد احمد النجار", "from_user_name": "عمار محمد السيد"}	9e39f741-2b38-4eb2-aa6d-f65300b06713	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 03:12:01.571392+00
3636e2d9-cebf-4644-9c5c-6843d9497059	HND-0326044924	shift_handover	\N	400.00	\N	\N	{"notes": "", "amount": 400.0, "to_user": "f00d039c-caa7-5b00-adba-365ed90c5f10", "from_user": "6a11d77b-24cc-577e-9ec3-4b0088eb7585", "to_user_name": "عمار محمد السيد", "from_user_name": "ندا خالد احمد النجار"}	dff47b8d-f7d1-444e-8b80-79bb0c0d0c8f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-03-26 04:49:24.436858+00
2f2984c4-be24-4d97-a95d-3da45165e401	INV-0329165628	sale_invoice	\N	50.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	24d4ae60-0bf1-4056-a83c-a5faa958d10b	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 16:56:30.315438+00
7cd8ef66-21f8-48ca-ab5d-3bf5231f1254	INV-001025	sale_invoice	\N	250.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	75e919da-7d78-4dbe-ac0b-3ca8abb7407f	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:18:47.601787+00
8c565a7a-328e-4e01-8c7e-a96bec887a61	INV-001026	sale_invoice	\N	90.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	678a4d14-d028-4c24-a72f-0dbaa1bbb258	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:18:55.765584+00
0ec5bfa2-4f7c-4fde-9990-30096e45c9d6	HND-0329172024	shift_handover	\N	190.00	\N	\N	{"notes": "", "amount": 190.0, "to_user": "7ef659d3-53f7-48b1-aca3-538ef5a1b3cd", "from_user": "f00d039c-caa7-5b00-adba-365ed90c5f10", "to_user_name": "احمد الكوك", "from_user_name": "عمار محمد السيد"}	4a7dd547-9642-4562-a0a8-1fa55de24162	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:20:24.162693+00
ac9f4171-bbea-4cfe-ac1a-5897725fac78	PO-001004	purchase_invoice	\N	50.00	\N	\N	{"supplier": "", "items_count": 1, "received_by": "", "warehouse_id": "59a2b8d7-e26b-4979-ae0e-3984f1b711b2"}	362b6e0d-4f17-4662-875b-1e63005a2d44	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-30 04:16:19.209469+00
1ea1f8db-992a-4710-8b6f-c4cda1450292	INV-001027	sale_invoice	\N	50.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	deec8934-2282-4a63-bff3-44e6123420fb	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-03-30 13:33:52.647447+00
25795185-18e2-4d2c-ab96-c2d59220a765	INV-001028	sale_invoice	\N	250.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	199a9759-0bc7-467e-9689-5b55ed482852	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-03-31 11:42:55.888868+00
14b03de8-b455-4842-a14b-0574314c6655	DEP-001031	safe_deposit	\N	1500.00	\N	\N	{"notes": "توريد يومي", "safe_name": "الخزنة الرئيسية", "warehouse": "معرض المؤمن", "received_by": "عمار محمد السيد", "deposited_by": "عمار محمد السيد"}	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-31 16:50:27.998146+00
f1175329-d720-4983-aa95-c98cfc7ac72a	INV-001040	sale_invoice	\N	150.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 4}	f8b9bade-e1b5-4251-b0d3-7591bcfda080	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-04-03 15:49:11.784652+00
19d5a301-118e-4740-8997-c70f5d9589f5	HND-0403173423	shift_handover	\N	640.00	\N	\N	{"notes": "", "amount": 640.0, "to_user": "6a11d77b-24cc-577e-9ec3-4b0088eb7585", "from_user": "7ef659d3-53f7-48b1-aca3-538ef5a1b3cd", "to_user_name": "ندا خالد احمد النجار", "from_user_name": "احمد الكوك"}	a4a070b3-e6f5-499f-9940-dcd41fcc2188	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-04-03 17:34:23.430458+00
1957d1d1-da40-434c-9fbd-ab02c52d6e15	INV-001041	sale_invoice	\N	355.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 5}	690521f4-ada7-4ea6-8959-eb911552ce17	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-03 18:44:06.105389+00
97f31067-ebdb-469f-9b9a-9c692bad9645	INV-001042	sale_invoice	\N	3045.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 39}	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-03 18:46:32.436043+00
eafd16d9-10ba-48a7-a492-4cca255110dc	DEP-001043	safe_deposit	\N	530.00	\N	\N	{"notes": "تسليم الدرج عند إغلاق الوردية", "safe_name": "الخزنة الرئيسية", "warehouse": "معرض المؤمن", "received_by": "مؤمن محمد", "deposited_by": "ندا خالد احمد النجار"}	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-04 09:38:10.606645+00
e37e5830-885c-4d01-a944-dca1a5bf72b3	INV-001044	sale_invoice	\N	35.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	fb0d3cd9-8c58-4c27-9c88-ff369e9c759d	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 11:53:01.230235+00
c9865998-215d-4a30-8975-0dde5dd39e86	INV-001045	sale_invoice	\N	120.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	79c8f84d-d6c2-479e-aba9-59e3a2399e83	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 11:54:22.612996+00
d3f339b2-6f80-4412-9c01-86b1264ce84d	INV-001046	sale_invoice	\N	40.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	b7093033-af31-4495-94af-1afbd0f7d6a2	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 11:56:25.482376+00
902e756b-8622-40a6-b247-36ca59416e1e	INV-001047	sale_invoice	\N	35.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	8c57aaa4-0af7-4158-b602-dd8154a31ac5	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 11:56:48.203195+00
bbc44dd4-1e08-47a5-8b8a-988e10274ec8	INV-001048	sale_invoice	\N	40.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 2}	722ae65a-8e33-4c67-a60e-ce7f3641e55a	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:01:01.907972+00
54b9cfa9-b5cf-4e6f-b1bd-2b1cd09a0e77	INV-001049	sale_invoice	\N	25.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	6658a571-8f6f-4346-8a00-e273453fd0e8	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:01:17.3806+00
8e32030e-d122-4706-b804-9e0df034a258	INV-001050	sale_invoice	\N	150.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	4324a1c7-c9a5-428c-9caa-80721faddd2a	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:10:43.191476+00
a5b80cd6-a939-480b-93f6-2839258df939	INV-001051	sale_invoice	\N	40.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	0c357ce9-3d1a-4b61-9284-54a9c0135182	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:45:43.688025+00
9c9a42ac-cde2-4da3-b606-5f2b5080416e	INV-001052	sale_invoice	\N	25.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	43d22f28-e464-4738-997e-14fda425b9d4	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:59:03.564888+00
e0f2c5c4-b087-485b-96b8-271773ddb64f	INV-001053	sale_invoice	\N	120.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	ada7f1f3-5d72-49cd-87c1-ec845fbf8c06	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 14:35:02.924989+00
1793979e-1122-4539-b8d6-842ae1183f99	INV-001054	sale_invoice	\N	190.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	ccafcf2e-b171-4468-99f3-7f14e1484684	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 16:02:35.424419+00
413c3ac6-54ce-4e33-892c-7c07a5e551e3	HND-0404163347	shift_handover	\N	3665.00	\N	\N	{"notes": "", "amount": 3665.0, "to_user": "6a11d77b-24cc-577e-9ec3-4b0088eb7585", "from_user": "ee31f134-c885-42b4-950b-53284e09a25b", "to_user_name": "ندا خالد احمد النجار", "from_user_name": "داليا السيد"}	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 16:33:47.332736+00
63d711a2-dbfb-460e-acb5-ae8bbc1129bf	INV-001055	sale_invoice	\N	150.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	68a5d40a-dc4a-48b9-8153-bf4b82af7bb6	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-04 17:12:59.672601+00
92643e85-623c-4dcf-839d-bae067fb71be	DEP-001056	safe_deposit	\N	4715.00	\N	\N	{"notes": "تسليم الدرج عند إغلاق الوردية", "safe_name": "الخزنة الرئيسية", "warehouse": "معرض المؤمن", "received_by": "محمد احمد", "deposited_by": "ندا خالد احمد النجار"}	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-05 08:48:51.430216+00
6fe95017-b814-4b5d-8402-c32fe32cff47	DEP-001057	safe_deposit	\N	3400.00	\N	\N	{"notes": "تسليم الدرج عند إغلاق الوردية", "safe_name": "الخزنة الرئيسية", "warehouse": "معرض العبور", "received_by": "محمد احمد", "deposited_by": "عمار محمد السيد"}	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-09 17:00:21.77481+00
886204eb-d53a-4e2b-8c32-15577722f930	INV-001058	sale_invoice	\N	750.00	\N	\N	{"mode": "SaleMode.wholesale", "items_count": 1}	55b0b4c8-2057-42d0-a306-eac87d4bb0bc	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:04:52.612661+00
0b2e1293-634e-45f2-b074-de2a13c1125d	INV-001059	sale_invoice	\N	460.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 5}	164ada49-92bf-47e1-a2a3-c62f5d09da58	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:29:17.610451+00
fa3a675a-3e0b-4b91-b1c7-3f5c9c2732db	HND-0409173043	shift_handover	\N	1810.00	\N	\N	{"notes": "", "amount": 1810.0, "to_user": "85ba0e1f-040c-44b2-90a3-0afcaa30178b", "from_user": "85ba0e1f-040c-44b2-90a3-0afcaa30178b", "to_user_name": "الشيخ ابراهيم", "from_user_name": "الشيخ ابراهيم"}	81d0c548-0de6-4773-9630-f001207f5598	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:30:43.720821+00
36c693e3-e953-4dd7-b264-db89c8c298b8	INV-001060	sale_invoice	\N	685.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 4}	d007be7b-6a2f-47a2-87fd-41493daf268b	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:39:33.71147+00
c723a11e-4085-499a-b9d2-385770a308ca	HND-0409193220	shift_handover	\N	2295.00	\N	\N	{"notes": "", "amount": 2295.0, "to_user": "85ba0e1f-040c-44b2-90a3-0afcaa30178b", "from_user": "85ba0e1f-040c-44b2-90a3-0afcaa30178b", "to_user_name": "الشيخ ابراهيم", "from_user_name": "الشيخ ابراهيم"}	1a61e024-d1fe-4627-89c1-d587bd2bfab0	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 19:32:20.791263+00
872a6304-728d-47c3-afec-eae72fa81ebf	DEP-001061	safe_deposit	\N	2275.00	\N	\N	{"notes": "تسليم الدرج عند إغلاق الوردية", "safe_name": "الخزنة الرئيسية", "warehouse": "معرض العبور", "received_by": "محمد احمد", "deposited_by": "الشيخ ابراهيم"}	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-11 11:34:04.50237+00
66b232a7-f2a3-4448-b7de-b51323d0a793	INV-001062	sale_invoice	\N	140.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 3}	c7710e3c-facb-4ed0-9ffe-9f80a23823df	658196d5-857d-493c-94e4-e604b01764ab	2026-04-11 11:36:03.592031+00
0dd75fca-625c-4556-ae60-f32a1df56256	INV-001063	sale_invoice	\N	35.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	01bfe807-abfb-4b40-b2ba-91cdf635e8b1	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-11 16:57:50.072725+00
6fcf895e-ebdd-4d2c-889c-8a9d5b7cda6f	INV-001064	sale_invoice	\N	150.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	9a7319e2-31a4-4753-abc2-bb92bbe01f07	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-15 13:33:13.916618+00
6a06922d-f3f4-4b2a-93a4-2dbfc2d2e939	DEP-001065	safe_deposit	\N	140.00	\N	\N	{"notes": "تسليم الدرج عند إغلاق الوردية", "safe_name": "خزنة معرض المؤمن", "warehouse": "معرض المؤمن", "received_by": "محمد احمد", "deposited_by": "داليا السيد"}	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 13:39:50.882578+00
58fcba65-7c91-4392-a502-51fa9192f623	INV-001066	sale_invoice	\N	150.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	1ff4ccc4-5613-4a7a-ba95-5ac080aeef04	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 13:53:44.545965+00
aaa58cdd-e553-4b04-8df4-6578daf3a69f	INV-001067	sale_invoice	\N	150.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	ca4ea6f5-82ca-4f96-bed8-a5b2a2a1b3c1	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:13:25.907046+00
dedff28e-4081-41a2-bdfb-cc482a874654	INV-001068	sale_invoice	\N	35.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	a5d2f6e4-34ea-46ae-a671-2a779e4d8cc5	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:15:34.35083+00
02c0a13d-2acb-46d1-8b70-72e61489f3dc	INV-001069	sale_invoice	\N	180.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	191377d0-0506-4cd5-bf1d-fc3fd65bac11	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 15:22:30.450281+00
8db262c6-bc53-4761-b95c-762803e93ebf	INV-001070	sale_invoice	\N	230.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	bb784b10-07c3-4a93-b36e-eb72a3c50a82	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 16:49:51.002724+00
15602ddc-263a-44a2-b7b4-ae8dded1a836	HND-0415165222	shift_handover	\N	800.00	\N	\N	{"notes": "", "amount": 800.0, "to_user": "6a11d77b-24cc-577e-9ec3-4b0088eb7585", "from_user": "ee31f134-c885-42b4-950b-53284e09a25b", "to_user_name": "ندا خالد احمد النجار", "from_user_name": "داليا السيد"}	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 16:52:22.005738+00
917ef197-5540-49c7-a0fc-424bdc98cc6e	INV-001071	sale_invoice	\N	150.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	8f3d7790-b687-4008-a659-9876db7ff7f7	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 19:24:13.344175+00
88d2e8c0-98ca-44ff-91ad-74d57ed7e1ca	INV-001072	sale_invoice	\N	100.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	68de17de-7680-4292-9603-8cacab936e2d	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 19:33:10.869155+00
0dbb7187-9217-4ea5-a7c3-fb7c01580774	INV-001073	sale_invoice	\N	20.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	9962c7e8-8e13-4754-bb24-3dd9c434b4b9	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 17:48:17.758709+00
dfde9247-8586-4169-b248-54417daf2eb5	INV-001074	sale_invoice	\N	45.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	3bc55c39-04c5-4c70-a956-54e262642e52	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 17:53:59.206425+00
06aab812-8a43-4240-9071-50477ad6537f	INV-001075	sale_invoice	\N	85.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	8c5491cc-a19c-40f6-ae95-53ce44f08a0a	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:09:21.750237+00
40047988-c822-46d0-a709-07e131998494	INV-001076	sale_invoice	\N	35.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	c9bd780c-9eb4-4ee1-a7ac-8f21fa7293b4	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:12:40.962362+00
113cff9f-731a-4bd9-bb47-132f8d136b6d	INV-001077	sale_invoice	\N	5.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	3de73516-254f-47b6-89d4-3e4b9a289e6b	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:13:09.32519+00
156bdaa9-f762-447f-adc6-22942fd06c6b	INV-001078	sale_invoice	\N	35.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	12c64805-0c9e-41b1-8a35-e0faede4dfee	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:16:59.065465+00
b4c7f824-2f64-451c-91f4-2c8989a8e9f4	INV-001079	sale_invoice	\N	50.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	149faca0-30a9-465e-9a18-10cd67c71a23	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:19:38.150542+00
b8543d18-22df-44d8-ac8d-e266aa78fd91	INV-001080	sale_invoice	\N	120.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	641a91af-fb3a-4ba0-90b1-3d78f6db15ee	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:46:52.366899+00
253e73ea-4d77-4bcd-82aa-b13b7f3631d7	DEP-001081	safe_deposit	\N	3040.00	\N	\N	{"notes": "تسليم الدرج عند إغلاق الوردية", "safe_name": "خزنة معرض المؤمن", "warehouse": "معرض المؤمن", "received_by": "محمد احمد", "deposited_by": "ندا خالد احمد النجار"}	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 10:57:44.950293+00
b724b1a9-a8b6-4111-a3c7-bd92251bac45	INV-001082	sale_invoice	\N	30.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	9cfee519-9104-4f79-8523-9849182a4951	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:00:38.990837+00
431c34f1-05eb-47d1-96f6-ced668a4838d	INV-001083	sale_invoice	\N	2000.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	a19b0900-0496-40c2-8d39-e4efc6a33a63	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-18 20:01:20.495729+00
73d7062d-f5b3-4d9b-98bb-ade1e73e397e	HND-0419212427	shift_handover	\N	2035.00	\N	\N	{"notes": "", "amount": 2035.0, "to_user": "658196d5-857d-493c-94e4-e604b01764ab", "from_user": "f00d039c-caa7-5b00-adba-365ed90c5f10", "to_user_name": "حبيبة عماد", "from_user_name": "عمار محمد السيد"}	7827d0d8-ad02-4b7b-8b54-cb9f7c3ab997	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-19 21:24:27.964614+00
4eeac5e4-82a0-4b4b-a04f-a9a5c0a3b165	INV-001084	sale_invoice	\N	1650.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	bf0089c4-e0b3-4ec0-9573-1d60d3ca8c56	658196d5-857d-493c-94e4-e604b01764ab	2026-04-20 16:43:05.185328+00
bba7ea3f-607d-4967-b198-001f226109b2	HND-0420164730	shift_handover	\N	3985.00	\N	\N	{"notes": "", "amount": 3985.0, "to_user": "f00d039c-caa7-5b00-adba-365ed90c5f10", "from_user": "658196d5-857d-493c-94e4-e604b01764ab", "to_user_name": "عمار محمد السيد", "from_user_name": "حبيبة عماد"}	9caef843-cb34-4aab-b867-e0b32e96d2ab	658196d5-857d-493c-94e4-e604b01764ab	2026-04-20 16:47:30.029154+00
913260ab-61dd-4588-8ebb-0e3192b82caa	DEP-001085	safe_deposit	\N	3980.00	\N	\N	{"notes": "تسليم الدرج عند إغلاق الوردية", "safe_name": "الخزنة الرئيسية", "warehouse": "معرض العبور", "received_by": "محمد احمد", "deposited_by": "عمار محمد السيد"}	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-21 13:24:00.216201+00
80881d7e-80e9-41c7-9b60-c3332184e408	INV-001086	sale_invoice	\N	100.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	3f6c0df5-9b7e-4f8c-a56c-a70e50ab37a8	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-21 19:52:09.989469+00
a68434c7-096d-4b87-8efd-e9e494794a5a	INV-001087	sale_invoice	\N	75.00	\N	\N	{"mode": "SaleMode.retail", "items_count": 1}	c95cc1a0-f6ed-4990-9837-99f0ac15effc	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-22 13:32:01.743177+00
95ff337a-0cf4-4b4d-b599-940ca16c3ee0	HND-0422152656	shift_handover	\N	180.00	\N	\N	{"notes": "", "amount": 180.0, "to_user": "85ba0e1f-040c-44b2-90a3-0afcaa30178b", "from_user": "85ba0e1f-040c-44b2-90a3-0afcaa30178b", "to_user_name": "الشيخ ابراهيم", "from_user_name": "الشيخ ابراهيم"}	1cfd81c6-cd5d-4c58-ac06-b77e9cf9c167	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-22 15:26:56.853341+00
ed291028-6fe3-4c38-918e-e5a437cdd474	HND-0422170730	shift_handover	\N	180.00	\N	\N	{"notes": "", "amount": 180.0, "to_user": "658196d5-857d-493c-94e4-e604b01764ab", "from_user": "85ba0e1f-040c-44b2-90a3-0afcaa30178b", "to_user_name": "حبيبة عماد", "from_user_name": "الشيخ ابراهيم"}	4293a80b-6b43-4b79-ba90-26f734f28377	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-22 17:07:30.35048+00
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_log (id, entity_type, entity_id, action, user_id, user_name, changes, note, created_at) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, created_at) FROM stdin;
8dc1113a-8ef3-56e8-8db4-44dea8b73394	لزق وتفلون وشكرتون	2026-03-25 18:13:41.323568+00
e11d248d-8083-5c8a-bd3d-93737603b2ce	مستلزمات صرف وغطيان	2026-03-25 18:13:41.323568+00
eec4c28c-ac4c-5e78-9157-be2158226a37	مكنة ولوازمها	2026-03-25 18:13:41.323568+00
becef785-9b1d-5b14-91b4-bebe341c2642	اطقم صيني ولوازمها	2026-03-25 18:13:41.323568+00
0c34aec3-607f-51b8-b032-2e83ada6c584	فلاتر ولوازمها	2026-03-25 18:13:41.323568+00
5bf1090c-ae87-5030-98a7-2ed1cc793377	مواتير ولوازمها	2026-03-25 18:13:41.323568+00
71396019-5291-58c6-99a2-eb79cc120767	قطع حديد	2026-03-25 18:13:41.323568+00
d5752969-164e-5001-a888-c76bc3c19642	روك ابيض	2026-03-25 18:13:41.323568+00
8d82283e-d183-5952-ba2a-aec1f42e5342	روك بولي	2026-03-25 18:13:41.323568+00
36d7143c-b44f-5970-9c9e-a3b8b80c13e5	كيسل	2026-03-25 18:13:41.323568+00
b86aa34e-a4b5-51fc-a973-96f428d82fc0	الشريف ابيض	2026-03-25 18:13:41.323568+00
07c411fb-ecef-5022-a228-9e6d5e8db604	الشريف بولي	2026-03-25 18:13:41.323568+00
76c1c9a0-8b8d-5958-8a14-3dc2f241a635	خزانات ولوازمها	2026-03-25 18:13:41.323568+00
2e9e355b-440a-5364-92ba-33d303c6039f	سيفونات وشطافات	2026-03-25 18:13:41.323568+00
f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	المصرية الالمانية بولي	2026-03-25 18:13:41.323568+00
cf660238-35ef-5656-a4f0-6d569293dfd8	المصرية الالمانية ابيض	2026-03-25 18:13:41.323568+00
1dcb7c7b-7c65-5765-933e-0331c121e032	خلاطات ولوازمها	2026-03-25 18:13:41.323568+00
e2cee846-5949-507b-8625-012eec13a6e6	مؤقت	2026-03-25 18:13:41.323568+00
9e478fd3-55ff-5125-8409-0047688d6453	حلة 	2026-03-25 18:13:41.323568+00
4caac7b8-13eb-53e5-a4d7-c28059165c3b	نواكل	2026-03-25 18:13:41.323568+00
4237ec93-d9b7-4061-877c-d866a6565576	كهرباء 	2026-04-13 14:19:18.155874+00
c61407e7-6f34-507e-b401-9e28544c6ffc	BR بولي 	2026-03-25 18:13:41.323568+00
b26ef2bd-07b9-54a8-8d2e-3371535208ea	ابيض BR	2026-03-25 18:13:41.323568+00
752b064e-82fe-4680-b581-8654da63bfca	بولي معزول BR 	2026-04-22 14:04:23.487938+00
\.


--
-- Data for Name: collection_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_items (id, collection_id, product_id, qty) FROM stdin;
3287a5c1-68e6-4f16-8e05-a54bb9c2651b	b933c689-75e2-426d-9cb2-a7729c8f0679	ca3d769f-2e88-4ab4-a664-10168fd3f444	1.000
a77b1830-067a-457e-92fc-db253497b731	b933c689-75e2-426d-9cb2-a7729c8f0679	3ccc958f-8b6a-4bd8-a9d0-47bba9de7485	1.000
007bf561-6479-47fd-ae53-95e74c80d2a2	b933c689-75e2-426d-9cb2-a7729c8f0679	cbb6ab60-767c-4ddb-be13-89063020cabc	1.000
9200e6b6-e338-4029-a0b4-e8ef2e310491	5c5959cf-c559-4737-b478-ff20a99508dc	6d5bbad0-e533-497c-8378-2be2633b1b49	1.000
09fc9934-f8f0-4c61-bcc6-ede163bbc5fd	5c5959cf-c559-4737-b478-ff20a99508dc	5e9e99fb-95ac-4298-a437-570417737d44	1.000
b80c4f3c-6ff7-4447-ae9f-66c87ecbe965	5c5959cf-c559-4737-b478-ff20a99508dc	1e873951-947e-47f7-88cf-26dfb861ec7d	1.000
\.


--
-- Data for Name: customer_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_payments (id, customer_id, amount, note, created_by, created_at) FROM stdin;
96d1fd93-5fa6-4c9a-87d3-8ee48a29f089	ea70b37f-e40d-4d13-a014-52ed6cc34d9e	500.00	دفعة أولى	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 00:07:37.172484+00
4a323df6-9c14-4034-acc6-404f28f53071	9338ff3f-c554-4648-9965-0b49d68aa7db	350.00	دفعة من شركة الاختبار	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:00:43.503152+00
da3845dd-f10f-45b9-887a-ab867e490491	ea70b37f-e40d-4d13-a014-52ed6cc34d9e	-600.00	دفعة من شركة النيل للتجارة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:01:55.803776+00
a9bfa8a8-b7f9-4d14-9da8-9cbc37756650	ea70b37f-e40d-4d13-a014-52ed6cc34d9e	100.00	دفعة من شركة النيل للتجارة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:02.085509+00
9ef33e75-2544-4888-a0f2-58ba1dbb5a77	9338ff3f-c554-4648-9965-0b49d68aa7db	25.00	دفعة من شركة الاختبار	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:19:20.882728+00
af90a688-0a03-41fc-8903-54be440d66df	d5b26988-5de6-44bb-8761-7a0963be4ad3	200.00	دفعة من ابو شهاب	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:05:27.226248+00
c42adf19-c499-4d06-9dcb-7c10fbc6d6d4	d5b26988-5de6-44bb-8761-7a0963be4ad3	400.00	دفعة من ابو شهاب	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:06:36.622524+00
bdf2efe0-f1da-4897-bd04-d7dee2fc0183	973fbcf1-c2b3-450e-8584-a63cf0885350	500.00	دفعة من ابو يوسف	658196d5-857d-493c-94e4-e604b01764ab	2026-04-20 16:46:05.8371+00
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, name, phone, address, is_cash, created_at, balance) FROM stdin;
ea70b37f-e40d-4d13-a014-52ed6cc34d9e	شركة النيل للتجارة	01012345678	\N	f	2026-03-26 00:07:36.965671+00	0.00
9338ff3f-c554-4648-9965-0b49d68aa7db	شركة الاختبار	\N	\N	f	2026-03-26 09:51:42.641516+00	25.00
d5b26988-5de6-44bb-8761-7a0963be4ad3	ابو شهاب	054656465	\N	f	2026-04-09 17:04:50.565889+00	150.00
973fbcf1-c2b3-450e-8584-a63cf0885350	ابو يوسف	010757557554	\N	f	2026-03-26 04:02:34.168886+00	1400.00
\.


--
-- Data for Name: drawer_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drawer_transactions (id, shift_id, type, amount, ref_id, note, created_by, created_at, category_id, payment_method, wallet_id) FROM stdin;
11ca6cd2-d9c0-42e1-a9e8-e80ccc08978c	609eedda-701a-4531-abb5-91467eacc595	sale	385.00	\N	\N	\N	2026-02-07 16:52:08.542826+00	\N	cash	\N
dde7e4a2-9b04-4145-824e-84ff0d2ca246	609eedda-701a-4531-abb5-91467eacc595	sale	700.00	\N	\N	\N	2026-02-07 16:55:31.453133+00	\N	cash	\N
894e7f55-5ba3-41da-8c6a-7025199aa9ca	609eedda-701a-4531-abb5-91467eacc595	sale	7.00	\N	\N	\N	2026-02-07 16:57:59.61598+00	\N	cash	\N
668fb2c6-cf8c-4b27-b5c2-c7a34be44a18	609eedda-701a-4531-abb5-91467eacc595	sale	7.00	\N	\N	\N	2026-02-07 16:58:17.525194+00	\N	cash	\N
14228221-bee0-4b31-b8b4-73eb2312072e	609eedda-701a-4531-abb5-91467eacc595	sale	350.00	\N	\N	\N	2026-02-07 17:06:01.758293+00	\N	cash	\N
d4e5d205-7e8d-4a88-b42e-5e0382077ad9	609eedda-701a-4531-abb5-91467eacc595	sale	7.00	\N	\N	\N	2026-02-07 17:09:35.129109+00	\N	cash	\N
30bf98d5-11db-4cf1-bdd0-54a30f15612f	609eedda-701a-4531-abb5-91467eacc595	sale	350.00	\N	\N	\N	2026-02-07 17:11:12.810263+00	\N	cash	\N
8c918676-b2f7-4127-9799-9cfe2fa62fd2	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-07 17:53:43.235896+00	\N	cash	\N
521a1b8a-845e-4363-a3b0-348ec660fc0a	609eedda-701a-4531-abb5-91467eacc595	sale	42.00	\N	\N	\N	2026-02-07 17:54:44.926386+00	\N	cash	\N
4af1999b-0961-4258-8330-44635b2d0b60	609eedda-701a-4531-abb5-91467eacc595	sale	1400.00	\N	\N	\N	2026-02-07 21:13:33.603046+00	\N	cash	\N
3325b520-5299-4238-98b7-573f4c80b2e0	609eedda-701a-4531-abb5-91467eacc595	sale	35.00	\N	\N	\N	2026-02-07 21:18:42.656092+00	\N	cash	\N
e097cf01-e343-420e-a315-41a910c4dfad	609eedda-701a-4531-abb5-91467eacc595	sale	21.00	\N	\N	\N	2026-02-07 21:23:31.463665+00	\N	cash	\N
1941d12e-e2cd-4f49-a5b6-7e5243712275	609eedda-701a-4531-abb5-91467eacc595	sale	35.00	\N	\N	\N	2026-02-07 21:26:28.836201+00	\N	cash	\N
e9cf5315-8eb9-43b8-baca-3df26b991ccb	609eedda-701a-4531-abb5-91467eacc595	sale	21.00	\N	\N	\N	2026-02-07 22:00:16.807736+00	\N	cash	\N
22dca9c9-b7c1-4739-b160-1f6baf9990e6	609eedda-701a-4531-abb5-91467eacc595	sale	28.00	\N	\N	\N	2026-02-08 11:26:52.992775+00	\N	cash	\N
7f4aac5c-1879-45c1-920e-ec1c4a41427e	609eedda-701a-4531-abb5-91467eacc595	sale	15.00	\N	\N	\N	2026-02-08 16:24:37.558158+00	\N	cash	\N
647859d1-ab4f-42d9-92ba-49d965304a27	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-08 16:46:31.133491+00	\N	cash	\N
4ca676d9-3f99-4583-9261-d7aa17f982e9	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-08 19:26:37.773692+00	\N	cash	\N
dc352780-4fce-4bbc-90e7-5f3eb4978019	609eedda-701a-4531-abb5-91467eacc595	sale	14.00	\N	\N	\N	2026-02-09 20:25:39.354709+00	\N	cash	\N
42e5a111-3054-428c-98b8-0b1efa9de40f	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-10 12:48:01.763736+00	\N	cash	\N
5d5bd60b-fb9b-4ed3-86fb-8bcf36a989ba	609eedda-701a-4531-abb5-91467eacc595	sale	5.00	\N	\N	\N	2026-02-10 15:43:16.757607+00	\N	cash	\N
2816a774-2051-4861-8113-e230a126b397	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-10 15:44:38.091412+00	\N	cash	\N
8211f75a-7af9-49c0-b174-44524c677168	609eedda-701a-4531-abb5-91467eacc595	sale	680.00	\N	\N	\N	2026-02-10 15:58:08.454527+00	\N	cash	\N
4564566f-6679-4286-98c2-8d2aa38f4bfc	8fb616cd-cbf6-4587-9eed-36cba02101b4	sale	0.00	\N	\N	\N	2026-03-24 10:56:08.703+00	\N	cash	\N
246f19d8-fe50-4724-a103-86a23ab8b082	8fb616cd-cbf6-4587-9eed-36cba02101b4	sale	0.00	\N	\N	\N	2026-03-24 11:28:37.026919+00	\N	cash	\N
2105487b-f540-4c57-b1b0-9cb23aacaa11	8fb616cd-cbf6-4587-9eed-36cba02101b4	expense	75.00	\N	مصروف	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:23:44.409309+00	\N	cash	\N
0510177b-8b00-4608-9acd-b07e73f34241	8fb616cd-cbf6-4587-9eed-36cba02101b4	sale	340.00	fa635f6f-c835-40ac-a8e0-d17436acc603	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 19:18:12.618104+00	\N	cash	\N
b566d987-1496-439e-84d6-a654be26ce52	8fb616cd-cbf6-4587-9eed-36cba02101b4	expense	25.00	\N	مصروف شاي وقهوة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 21:32:56.322235+00	\N	cash	\N
cb6280da-1016-44c6-ad53-f9e3d34f866d	ba06a6e8-ef0b-405f-99ca-3870cef7ab96	expense	20.00	\N	مصروف	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 21:34:40.213108+00	\N	cash	\N
142e639b-369c-4ff1-ba71-4eb4045ef602	55cbdec7-b42c-4183-b251-53aaa8f07c1b	sale	215.00	beea6ccd-679c-413a-8a04-5b820ff8df8f	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:02:06.343297+00	\N	cash	\N
a031b8fd-00c2-4ed8-9088-1ef890933923	55cbdec7-b42c-4183-b251-53aaa8f07c1b	sale	215.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:08:53.994403+00	\N	cash	\N
6cd6cf86-260c-4eb5-8b86-b0e9cc19d97f	55cbdec7-b42c-4183-b251-53aaa8f07c1b	expense	30.00	\N	عيش	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:09:13.29495+00	\N	cash	\N
501a87f8-cae0-4bc3-ad8e-0c55154c8335	55cbdec7-b42c-4183-b251-53aaa8f07c1b	return_	215.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:09:25.975637+00	\N	cash	\N
3065be2d-c6df-4f75-b1c2-8522feaa23ca	55cbdec7-b42c-4183-b251-53aaa8f07c1b	sale	60.00	8ffd2445-36b9-4860-b005-711c418cc856	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:11:11.184759+00	\N	cash	\N
f7bb0cc2-5789-44e8-8025-87d6e380b61e	55cbdec7-b42c-4183-b251-53aaa8f07c1b	return_	60.00	8ffd2445-36b9-4860-b005-711c418cc856	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:11:24.303735+00	\N	cash	\N
d675ae27-53b6-43c7-a63b-2bf3498ab60b	ff1dbe65-5402-4af3-a0c4-4b130ef8b11e	expense	10.00	\N	test	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 04:25:11.454619+00	\N	cash	\N
ba0c10aa-1cd5-4ef9-a1ee-d5b2fa916e6e	1dc0d5f0-327a-4708-aff9-26c483ab313b	deposit	500.00	\N	مواصلات	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 05:29:48.274283+00	\N	cash	\N
9a1b7c66-ff1e-4383-bb2e-ed834be6be8f	1dc0d5f0-327a-4708-aff9-26c483ab313b	sale	5250.00	de55ead7-27bd-4e29-ad9a-e7aef4b74978	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 05:30:34.229674+00	\N	cash	\N
63970c64-7987-4053-9560-90b8c3c11a42	1dc0d5f0-327a-4708-aff9-26c483ab313b	deposit	350.00	\N	دفعة من شركة الاختبار	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:00:43.503152+00	\N	cash	\N
ae9a6cc7-05e9-4c6f-b0f9-84bf7ab1e024	1dc0d5f0-327a-4708-aff9-26c483ab313b	sale	90.00	6dda74b4-cb34-4648-8f6e-44fb7a3672b5	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:41:03.717603+00	\N	cash	\N
c058fa85-19c2-4ff6-82c4-e80784d4e7d7	3dcf287f-653a-4299-b80d-c840e1503e2b	sale	100.00	0dce5e50-b8c5-4941-a0f6-cf5a48fd046a	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 15:10:00.472241+00	\N	cash	\N
6bf5cd59-49b8-4f5e-9116-2f97bf7303e0	3dcf287f-653a-4299-b80d-c840e1503e2b	expense	150.00	\N	إيجار شهر مارس	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 12:06:35.936893+00	\N	cash	\N
ecf09251-185b-4fe6-854c-de55a0f260ed	3dcf287f-653a-4299-b80d-c840e1503e2b	deposit	-600.00	\N	دفعة من شركة النيل للتجارة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:01:55.803776+00	\N	cash	\N
9d1acab4-58a7-408e-b4a1-41820237f565	3dcf287f-653a-4299-b80d-c840e1503e2b	deposit	100.00	\N	دفعة من شركة النيل للتجارة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:02.085509+00	\N	cash	\N
a8ed6d06-04e0-4b59-a42a-9b06e65676ad	3dcf287f-653a-4299-b80d-c840e1503e2b	deposit	30.00	\N	عيش	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:23.484892+00	\N	cash	\N
6024021a-b6d7-4a24-8502-97858928c199	3dcf287f-653a-4299-b80d-c840e1503e2b	sale	300.00	7189b418-dcf5-4925-ae01-eee514901aa4	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:49.494187+00	\N	cash	\N
3c5aa4c7-2b63-4ec4-a4c1-45fae4c20c6a	4a7dd547-9642-4562-a0a8-1fa55de24162	sale	50.00	24d4ae60-0bf1-4056-a83c-a5faa958d10b	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 16:56:28.947849+00	\N	cash	\N
3e5ff3ce-ee59-4b0b-982a-3423ab266a82	4a7dd547-9642-4562-a0a8-1fa55de24162	sale	250.00	75e919da-7d78-4dbe-ac0b-3ca8abb7407f	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:18:47.390297+00	\N	cash	\N
6282a980-e92f-442f-b5e7-8057ff8a2a9f	4a7dd547-9642-4562-a0a8-1fa55de24162	sale	90.00	678a4d14-d028-4c24-a72f-0dbaa1bbb258	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:18:55.672741+00	\N	cash	\N
fe76de03-c9d8-44ab-825e-a96391ab4f8f	4a7dd547-9642-4562-a0a8-1fa55de24162	deposit	25.00	\N	دفعة من شركة الاختبار	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:19:20.882728+00	\N	cash	\N
fc5e3d3f-011d-462a-8c40-fee6af6920f1	4a7dd547-9642-4562-a0a8-1fa55de24162	deposit	550.00	\N	مواصلات	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:19:39.619664+00	\N	cash	\N
34c2659b-d774-495e-8e92-bfdfffc8c693	4a7dd547-9642-4562-a0a8-1fa55de24162	expense	200.00	\N	تفويل فطوطة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:20:02.008717+00	\N	cash	\N
e5696e65-bac1-4f81-a379-7b7c67f1392a	a4a070b3-e6f5-499f-9940-dcd41fcc2188	sale	50.00	deec8934-2282-4a63-bff3-44e6123420fb	\N	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-03-30 13:33:52.40389+00	\N	cash	\N
14f68ae2-6c12-4767-97af-9e46cf762bb1	a4a070b3-e6f5-499f-9940-dcd41fcc2188	sale	250.00	199a9759-0bc7-467e-9689-5b55ed482852	\N	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-03-31 11:42:55.471697+00	\N	cash	\N
bcb7cc69-50f6-4e5c-b056-1a64c6ef10d2	a4a070b3-e6f5-499f-9940-dcd41fcc2188	sale	150.00	f8b9bade-e1b5-4251-b0d3-7591bcfda080	\N	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-04-03 15:49:11.728512+00	\N	cash	\N
235deca9-59b4-4aed-9de4-db50ab0cb5b7	900146ce-a935-43ea-a6d4-647276e80612	sale	355.00	690521f4-ada7-4ea6-8959-eb911552ce17	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-03 18:44:06.036492+00	\N	cash	\N
b2e29ef3-8459-4293-a919-af409b4b9bd8	900146ce-a935-43ea-a6d4-647276e80612	sale	3045.00	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-03 18:46:32.357587+00	\N	cash	\N
ce259729-ad07-4a0e-8b70-b7d8a19e0de5	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	deposit	10.00	\N	فرق حساب ابو يوسف	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 10:25:31.050525+00	\N	cash	\N
456c27e8-f328-454a-bcf8-3de07a5de5c9	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	deposit	300.00	\N	توريد تاكسي	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 10:25:50.121274+00	\N	cash	\N
1121796e-df78-4c14-a88f-b35474e272e9	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	35.00	fb0d3cd9-8c58-4c27-9c88-ff369e9c759d	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 11:53:01.188877+00	\N	cash	\N
708eb584-9bb8-4cfb-bdb7-f5c40244acbe	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	120.00	79c8f84d-d6c2-479e-aba9-59e3a2399e83	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 11:54:22.580318+00	\N	cash	\N
3cea2e7f-6dfb-4d3f-ad28-48684eb2fe67	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	40.00	b7093033-af31-4495-94af-1afbd0f7d6a2	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 11:56:25.460384+00	\N	cash	\N
9d9e2690-b57e-4db1-b209-b654c064531e	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	35.00	8c57aaa4-0af7-4158-b602-dd8154a31ac5	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 11:56:48.185288+00	\N	cash	\N
3a0a5b0a-1ae5-46c7-aebe-ba03f2d1a22b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	40.00	722ae65a-8e33-4c67-a60e-ce7f3641e55a	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:01:01.87457+00	\N	cash	\N
79c7d343-d104-40c4-9fe6-130246ce0d8f	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	25.00	6658a571-8f6f-4346-8a00-e273453fd0e8	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:01:17.361055+00	\N	cash	\N
9f39cfba-2106-429c-9067-6357a650aca5	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	expense	40.00	\N	عيش	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:02:01.404945+00	\N	cash	\N
338902ff-f1bd-4915-9b1c-8fdf9c977615	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	expense	70.00	\N	برسيم	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:02:22.284353+00	\N	cash	\N
23ac971a-9d87-46ee-8228-8e76b12ae5e4	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	expense	35.00	\N	مرتجع	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:03:04.319054+00	\N	cash	\N
b7874da9-5b58-4be9-a0eb-8606b4565779	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	expense	120.00	\N	مرتجع	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:03:18.173563+00	\N	cash	\N
28349827-ced3-4124-b9d6-4fa059e8b9c3	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	expense	20.00	\N	مرتجع	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:03:36.648001+00	\N	cash	\N
a159d858-9fa4-44a3-86f6-de00d92d5022	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	150.00	4324a1c7-c9a5-428c-9caa-80721faddd2a	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:10:43.167716+00	\N	cash	\N
17557fbb-8e12-44b0-ac7c-e66576240163	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	deposit	80.00	\N	خرطوم شطاف خارجي (جلد )	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:34:38.661104+00	\N	cash	\N
e9df4c7b-1018-4cc4-aa42-354333746448	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	40.00	0c357ce9-3d1a-4b61-9284-54a9c0135182	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:45:43.620612+00	\N	cash	\N
965293fb-d85f-40c9-83fa-9b6733708350	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	25.00	43d22f28-e464-4738-997e-14fda425b9d4	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 12:59:03.526909+00	\N	cash	\N
73ebc644-cf0d-4cab-85e5-c8a3532eae9a	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	120.00	ada7f1f3-5d72-49cd-87c1-ec845fbf8c06	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 14:35:02.868867+00	\N	cash	\N
5a2a335e-ed6a-4b8b-bd9f-a073263b693f	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	expense	40.00	\N	مفتاح	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 14:36:08.931762+00	\N	cash	\N
d85c82ff-78ec-4414-8e0b-18a20ad77f41	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	deposit	770.00	\N	فاتورة ابو يوسف 	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 14:36:35.554279+00	\N	cash	\N
09b30b97-dd40-45a3-b635-320cf26d5183	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	deposit	2040.00	\N	محمود بدروم 	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 16:01:01.215567+00	\N	cash	\N
17fc49c9-2c1d-472e-bdd2-2afb630d89b3	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	sale	190.00	ccafcf2e-b171-4468-99f3-7f14e1484684	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 16:02:35.379898+00	\N	cash	\N
dbc23997-3a41-4b4b-89a9-e72368e7f2a2	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	expense	140.00	\N	فطار (مصطفي + حماده ) الي الكوك	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-04 16:33:15.025501+00	\N	cash	\N
fa36bb85-ee62-4f6a-aa0e-456a14dd9669	e5355dec-89d0-445f-9fc7-85065801c28c	sale	150.00	68a5d40a-dc4a-48b9-8153-bf4b82af7bb6	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-04 17:12:59.620644+00	\N	cash	\N
b6ebed92-f83c-46dc-a293-94a8de05ba2d	e5355dec-89d0-445f-9fc7-85065801c28c	deposit	1000.00	\N	lljolj	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-04 18:20:08.378552+00	\N	wallet	72811e0c-c360-4309-b85e-7973691e6069
675555d6-480f-4949-8bb2-a43ba70e4652	6f43b59c-48b9-4220-a9ad-c0348cad9197	expense	10.00	\N	عيش	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-05 13:18:53.209837+00	\N	cash	\N
d8965ea4-6535-4ee8-8d07-7d33ea22b1bd	6f43b59c-48b9-4220-a9ad-c0348cad9197	expense	10.00	\N	مؤمن: زجاجة مياه	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-05 13:19:19.151806+00	\N	cash	\N
db333338-1599-4530-9d2b-594dc31023cb	81d0c548-0de6-4773-9630-f001207f5598	sale	750.00	55b0b4c8-2057-42d0-a306-eac87d4bb0bc	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:04:52.567672+00	\N	cash	\N
c4e04507-362d-4099-8562-1084ec1b43e6	81d0c548-0de6-4773-9630-f001207f5598	deposit	200.00	\N	دفعة من ابو شهاب	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:05:27.226248+00	\N	cash	\N
3c4e48b8-2326-419c-b4db-3dbb0ff96cc7	81d0c548-0de6-4773-9630-f001207f5598	deposit	400.00	\N	دفعة من ابو شهاب	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:06:36.622524+00	\N	cash	\N
4a325504-e132-43ac-afa7-3fc63bfd3756	81d0c548-0de6-4773-9630-f001207f5598	sale	460.00	164ada49-92bf-47e1-a2a3-c62f5d09da58	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:29:17.580966+00	\N	cash	\N
26d5ad2a-6742-4627-a3d9-ed9b7b9f45d7	1a61e024-d1fe-4627-89c1-d587bd2bfab0	sale	685.00	d007be7b-6a2f-47a2-87fd-41493daf268b	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:39:33.67449+00	\N	cash	\N
6d3e7c97-f005-4cf3-8157-fe834ced6bab	1a61e024-d1fe-4627-89c1-d587bd2bfab0	expense	200.00	\N	منظفات	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:49:53.402234+00	\N	cash	\N
71cfccd5-ae7d-48cd-9d28-823ac0103ff3	7fc6e86e-a0b6-462c-814e-1f5c04397f36	sale	140.00	c7710e3c-facb-4ed0-9ffe-9f80a23823df	\N	658196d5-857d-493c-94e4-e604b01764ab	2026-04-11 11:36:03.539892+00	\N	cash	\N
f2500820-c7bc-428f-8420-e2cccead7201	7827d0d8-ad02-4b7b-8b54-cb9f7c3ab997	sale	35.00	01bfe807-abfb-4b40-b2ba-91cdf635e8b1	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-11 16:57:50.030337+00	\N	cash	\N
f4f7b075-ba6a-441e-b658-54455b2fcc16	6f43b59c-48b9-4220-a9ad-c0348cad9197	sale	150.00	9a7319e2-31a4-4753-abc2-bb92bbe01f07	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-15 13:33:13.852725+00	\N	cash	\N
18a58b95-d80d-4b11-a31b-840c935d544f	f7bebd31-df98-4b71-8a19-e4daead03400	sale	150.00	1ff4ccc4-5613-4a7a-ba95-5ac080aeef04	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 13:53:44.52708+00	\N	cash	\N
52884562-e450-4893-aa77-efda17f2383e	f7bebd31-df98-4b71-8a19-e4daead03400	return_	150.00	1ff4ccc4-5613-4a7a-ba95-5ac080aeef04	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:02:35.285845+00	\N	cash	\N
3a1e9f01-1d86-4817-b409-b5256e748b45	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	sale	150.00	ca4ea6f5-82ca-4f96-bed8-a5b2a2a1b3c1	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:13:25.866305+00	\N	cash	\N
012892a6-604b-48d9-ab60-805021311385	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	deposit	75.00	\N	ماسورة 1" ابيض 175سم 	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:14:53.55127+00	\N	cash	\N
296c7948-2766-43ca-9d6f-545939186935	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	sale	35.00	a5d2f6e4-34ea-46ae-a671-2a779e4d8cc5	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:15:34.328059+00	\N	cash	\N
1370a158-088d-45ef-aad4-2bcdfa1e6109	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	expense	40.00	\N	عيش	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:16:10.374669+00	\N	cash	\N
a32a7bfa-8332-4c12-b0d7-cbd9f9b8ff22	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	sale	180.00	191377d0-0506-4cd5-bf1d-fc3fd65bac11	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 15:22:30.433226+00	\N	cash	\N
076f0fc3-dfac-4814-ac4b-10cbc4757340	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	sale	230.00	bb784b10-07c3-4a93-b36e-eb72a3c50a82	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 16:49:50.980428+00	\N	cash	\N
ce1d5cd5-833c-4069-8b2c-8f852f2184f1	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	deposit	80.00	\N	تي حديد 1"	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 16:50:39.170894+00	\N	cash	\N
cab8d318-1544-4022-b2ff-c76405db1703	0dbb0981-7969-4775-8d06-123a461e83e0	sale	150.00	8f3d7790-b687-4008-a659-9876db7ff7f7	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 19:24:13.33222+00	\N	cash	\N
569be03e-09bc-44eb-b57d-e43a1338055c	0dbb0981-7969-4775-8d06-123a461e83e0	sale	100.00	68de17de-7680-4292-9603-8cacab936e2d	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 19:33:10.850009+00	\N	cash	\N
72e5f232-c566-4344-93a9-8c1379de40f4	0dbb0981-7969-4775-8d06-123a461e83e0	expense	800.00	\N	مستر حماده	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-15 19:34:57.595173+00	\N	cash	\N
67b13ea8-5a93-4adf-83ac-86099474ab12	73bdd2e6-f881-4dd1-9631-250e247abf6f	expense	150.00	\N	استلم	916e8dbf-c920-4cfd-a9af-f2f76d16417b	2026-04-15 21:00:41.68721+00	\N	cash	\N
024a41eb-4b77-4dc9-ad7c-767783fa03a4	638065e8-f2e9-4435-b0eb-9cbfef60a771	sale	20.00	9962c7e8-8e13-4754-bb24-3dd9c434b4b9	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 17:48:17.701328+00	\N	cash	\N
6b74be29-79bb-42f2-a1c7-7e2b85370559	638065e8-f2e9-4435-b0eb-9cbfef60a771	deposit	80.00	\N	فاتورة ابو يوسف	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 17:53:16.588023+00	\N	cash	\N
9b1cc6fa-26ec-4e20-a579-e7ef8ba1904a	638065e8-f2e9-4435-b0eb-9cbfef60a771	deposit	500.00	\N	فاتورة ا/عمر 	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 17:53:42.471357+00	\N	cash	\N
29f76ffa-9fb4-4406-8227-22cf49ce9d30	638065e8-f2e9-4435-b0eb-9cbfef60a771	sale	45.00	3bc55c39-04c5-4c70-a956-54e262642e52	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 17:53:59.149494+00	\N	cash	\N
790a793e-64f5-467e-9073-ba9366b80fa9	638065e8-f2e9-4435-b0eb-9cbfef60a771	sale	85.00	8c5491cc-a19c-40f6-ae95-53ce44f08a0a	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:09:21.705211+00	\N	cash	\N
a61acde4-5a19-4a1f-809f-c864fe6e59d3	638065e8-f2e9-4435-b0eb-9cbfef60a771	sale	35.00	c9bd780c-9eb4-4ee1-a7ac-8f21fa7293b4	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:12:40.942116+00	\N	cash	\N
92427871-27af-43fd-aa4f-8849997e09cc	638065e8-f2e9-4435-b0eb-9cbfef60a771	sale	5.00	3de73516-254f-47b6-89d4-3e4b9a289e6b	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:13:09.28253+00	\N	cash	\N
e1e9250b-03fe-40e9-bcf7-de8df56b320a	638065e8-f2e9-4435-b0eb-9cbfef60a771	deposit	1700.00	\N	فاتورة هبه محمد 	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:16:35.28476+00	\N	cash	\N
6bc19dc4-502d-485c-b466-b3629921791e	638065e8-f2e9-4435-b0eb-9cbfef60a771	sale	35.00	12c64805-0c9e-41b1-8a35-e0faede4dfee	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:16:59.030531+00	\N	cash	\N
8d9253a0-602b-47e4-84e1-fb35dc2f0c98	638065e8-f2e9-4435-b0eb-9cbfef60a771	deposit	8800.00	\N	فاتورة محمد الصلب	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:17:24.244033+00	\N	cash	\N
e47a217a-7737-49f2-a052-ed4e46926646	638065e8-f2e9-4435-b0eb-9cbfef60a771	sale	50.00	149faca0-30a9-465e-9a18-10cd67c71a23	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:19:38.130327+00	\N	cash	\N
a4c75240-e67a-4532-82e1-8938a3a02b70	638065e8-f2e9-4435-b0eb-9cbfef60a771	expense	20.00	\N	ا/مؤمن (حاجه ساقعة )	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:20:31.674471+00	\N	cash	\N
d7079988-5ec2-40c7-8c78-8340c4ac9cab	638065e8-f2e9-4435-b0eb-9cbfef60a771	expense	160.00	\N	ا/حماده	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:21:01.12428+00	\N	cash	\N
3b9b9f8e-71ab-4301-8f93-bf68ed5ac5c0	638065e8-f2e9-4435-b0eb-9cbfef60a771	expense	1500.00	\N	سلفة عم عاطف	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:21:25.271195+00	\N	cash	\N
5e607790-258f-4f96-9a84-c16c96f17a71	638065e8-f2e9-4435-b0eb-9cbfef60a771	expense	175.00	\N	لبن ا/مؤمن 	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:22:40.44814+00	\N	cash	\N
9c7ba1af-d71e-429b-96ad-668cc2a9ff1f	638065e8-f2e9-4435-b0eb-9cbfef60a771	expense	140.00	\N	مرتجع	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:22:58.075663+00	\N	cash	\N
11eb38cd-43c1-4745-8454-546e5d23e8a7	638065e8-f2e9-4435-b0eb-9cbfef60a771	sale	120.00	641a91af-fb3a-4ba0-90b1-3d78f6db15ee	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:46:52.341965+00	\N	cash	\N
024f0ae1-e3f6-4f14-a85a-48df7f2ed319	638065e8-f2e9-4435-b0eb-9cbfef60a771	deposit	60.00	\N	سوستة 3/8*1/2	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:53:57.026035+00	\N	cash	\N
56ec7a1b-dcea-49d5-8e53-a6028d6e057f	638065e8-f2e9-4435-b0eb-9cbfef60a771	expense	9000.00	\N	ا/حماده	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 19:00:53.100852+00	\N	cash	\N
e329dd3b-3dbe-4dca-953a-b7217423c70b	638065e8-f2e9-4435-b0eb-9cbfef60a771	expense	35.00	\N	مرتجع	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 19:01:15.647463+00	\N	cash	\N
ea596e78-ab13-488a-9814-72425e8e538c	638065e8-f2e9-4435-b0eb-9cbfef60a771	deposit	2500.00	\N	كرم القاضي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 19:23:46.594039+00	\N	cash	\N
df7a2d0d-854c-4e7c-a998-6c47194a6591	638065e8-f2e9-4435-b0eb-9cbfef60a771	deposit	200.00	\N	زيادة	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 10:56:28.609001+00	\N	cash	\N
22540df8-543c-4630-9cf7-c0d668c2574e	114bc5a4-76e6-4f4b-a8f8-33244c6a3469	deposit	50.00	\N	سيفون 2" رمادي 	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:00:18.666716+00	\N	cash	\N
3e0e91c4-323c-4e5b-951b-3b5f26715bf0	114bc5a4-76e6-4f4b-a8f8-33244c6a3469	sale	30.00	9cfee519-9104-4f79-8523-9849182a4951	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:00:38.94932+00	\N	cash	\N
b4120be4-abf6-443f-9670-42cd2c5f4956	114bc5a4-76e6-4f4b-a8f8-33244c6a3469	expense	100.00	\N	مرتجع	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:01:04.730202+00	\N	cash	\N
970a07ef-03a0-46f3-b9d4-e89434993b3d	7827d0d8-ad02-4b7b-8b54-cb9f7c3ab997	sale	2000.00	a19b0900-0496-40c2-8d39-e4efc6a33a63	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-18 20:01:20.449249+00	\N	cash	\N
92edf9aa-f332-447f-968c-3b6831316589	9caef843-cb34-4aab-b867-e0b32e96d2ab	sale	1650.00	bf0089c4-e0b3-4ec0-9573-1d60d3ca8c56	\N	658196d5-857d-493c-94e4-e604b01764ab	2026-04-20 16:43:05.129604+00	\N	cash	\N
683fc5f4-b7c0-4666-8028-45c10eaa6d79	9caef843-cb34-4aab-b867-e0b32e96d2ab	expense	200.00	\N	\N	658196d5-857d-493c-94e4-e604b01764ab	2026-04-20 16:44:46.228371+00	\N	cash	\N
2e01c662-51fd-4470-b3de-92a08a34405a	9caef843-cb34-4aab-b867-e0b32e96d2ab	deposit	500.00	\N	دفعة من ابو يوسف	658196d5-857d-493c-94e4-e604b01764ab	2026-04-20 16:46:05.8371+00	\N	cash	\N
064fe9b7-cedb-4bd8-beec-c8dfc2bffb6c	1cfd81c6-cd5d-4c58-ac06-b77e9cf9c167	sale	100.00	3f6c0df5-9b7e-4f8c-a56c-a70e50ab37a8	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-21 19:52:09.950176+00	\N	cash	\N
b3e6cc7a-5dca-45ca-a29b-6c268a5f59ff	1cfd81c6-cd5d-4c58-ac06-b77e9cf9c167	sale	75.00	c95cc1a0-f6ed-4990-9837-99f0ac15effc	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-22 13:32:01.704837+00	\N	cash	\N
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, user_id, full_name, national_id, phone, base_salary, hire_date, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: financial_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.financial_categories (id, name, type, color, created_at) FROM stdin;
\.


--
-- Data for Name: hr_advances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_advances (id, employee_id, amount, date, note, created_by, created_at, record_type) FROM stdin;
b562a7bd-2e0a-4f19-bea0-3d45b61abd96	8547bd33-4c1f-4939-a460-f42beec6d360	1000.00	2026-02-22		\N	2026-03-27 05:47:42.800418+00	سلفة
21806bc1-8380-45c3-b5e9-171b3eb97e3e	6fcefb3d-7918-4118-9633-b74c21c0dd0f	1000.00	2026-02-27		\N	2026-03-27 05:47:42.800418+00	سلفة
45bce3e3-ad76-46a5-9a6b-e9495181b2b9	1c2e1861-ef74-46d8-9a77-ed741494a29a	500.00	2026-02-28		\N	2026-03-27 05:47:42.800418+00	سلفة
01e84b57-75e2-45e2-a44a-ecb1f1f03140	dedc4608-da7e-4935-99c0-669c48d2a895	1500.00	2026-02-28		\N	2026-03-27 05:47:42.800418+00	سلفة
320041d8-b637-4172-9cbf-e7077b35808a	ba82ba38-633f-4633-849f-b2458ad2952f	800.00	2026-02-28		\N	2026-03-27 05:47:42.800418+00	سلفة
a583faad-4633-4eaa-a423-fe294bdd6a6e	8547bd33-4c1f-4939-a460-f42beec6d360	1000.00	2026-03-14		\N	2026-03-27 05:47:42.800418+00	سلفة
658faa29-eed1-444f-9ef8-d226c367893e	1c2e1861-ef74-46d8-9a77-ed741494a29a	3000.00	2026-03-18		\N	2026-03-27 05:47:42.800418+00	سلفة
9ba9043d-24e0-48ba-a2b7-0d3a742f6e70	8547bd33-4c1f-4939-a460-f42beec6d360	500.00	2026-03-19	 	\N	2026-03-27 05:47:42.800418+00	سلفة
8d94537b-e6ad-448d-8e25-6b0fc0c3582a	8547bd33-4c1f-4939-a460-f42beec6d360	500.00	2026-02-14		\N	2026-03-27 05:50:20.983336+00	سلفة
b7553eeb-eb77-46f5-b294-e9230aeaeb40	8547bd33-4c1f-4939-a460-f42beec6d360	400.00	2026-02-28		\N	2026-03-27 05:50:20.983336+00	سلفة
7eceb514-e17c-4a4e-b890-15903cfa25b2	1c2e1861-ef74-46d8-9a77-ed741494a29a	200.00	2026-03-14		\N	2026-03-27 05:50:20.983336+00	سلفة
c68786a1-5341-4e41-993e-1dfa956a204c	6fcefb3d-7918-4118-9633-b74c21c0dd0f	1000.00	2026-03-14		\N	2026-03-27 05:50:20.983336+00	سلفة
080b86e7-4fa4-441d-8f39-7652cc72ffa0	dedc4608-da7e-4935-99c0-669c48d2a895	1000.00	2026-03-18		\N	2026-03-27 05:50:20.983336+00	سلفة
4217e66f-2f7b-4d7d-8b52-9d13bccb5bc7	ba82ba38-633f-4633-849f-b2458ad2952f	535.00	2026-03-18	خلاط + طبة حوض	\N	2026-03-27 05:50:20.983336+00	سلفة
\.


--
-- Data for Name: hr_attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_attendance (id, employee_id, work_date, check_in, check_out, status, notes, created_at, edited, edited_by, edit_reason, excuse_no_late, excuse_no_early, excuse_allow_overtime, shift_override) FROM stdin;
0b4d9e9c-f530-4bf5-a058-4dc44fa50053	8547bd33-4c1f-4939-a460-f42beec6d360	2025-08-27	2025-08-27 19:26:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2282bb73-c1f3-4caf-a76a-153b91036e91	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-08-27	2025-08-27 19:37:03+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b6edbb1c-be6e-45fd-88d2-9f4668de4e26	ba82ba38-633f-4633-849f-b2458ad2952f	2025-08-27	2025-08-27 19:48:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
68235b6e-8353-473e-bc35-0f192982f161	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-08-28	2025-08-28 06:44:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9ee04962-3ce8-48ac-a579-fa8b288448cd	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-08-28	2025-08-28 07:13:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b723ea69-255b-4bd2-92c7-995224ab8d23	dedc4608-da7e-4935-99c0-669c48d2a895	2025-08-28	2025-08-28 07:14:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2e992326-0c38-4863-8aed-85df9a6761af	ba82ba38-633f-4633-849f-b2458ad2952f	2025-08-28	2025-08-28 10:35:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
47eaf821-7947-4706-bbf6-5f94906ae6b3	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-08-29	2025-08-29 06:36:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6b542141-7648-4ff1-af2b-41efffb2cae2	ba82ba38-633f-4633-849f-b2458ad2952f	2025-08-29	2025-08-29 08:39:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5dbc2182-804e-41f2-bc2c-7559e671ba61	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-08-30	2025-08-30 06:10:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
df472aa4-dbdf-45f8-a3df-0c61689e65c8	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-08-30	2025-08-30 08:26:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
33f265bc-6371-4380-8086-d008c59ad767	dedc4608-da7e-4935-99c0-669c48d2a895	2025-08-30	2025-08-30 10:13:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
81c7703e-774e-4c4b-8eec-eb120abb142c	ba82ba38-633f-4633-849f-b2458ad2952f	2025-08-30	2025-08-30 10:28:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1d2530a9-dfba-4ba1-8d2a-e7a1d01a33c8	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-08-31	2025-08-31 06:41:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cd0de769-4cef-444d-8549-6dc934ca0520	dedc4608-da7e-4935-99c0-669c48d2a895	2025-08-31	2025-08-31 06:59:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2e61c5da-b6b4-4cc0-a0d1-7ad6320591c0	ba82ba38-633f-4633-849f-b2458ad2952f	2025-08-31	2025-08-31 10:26:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e5e92960-2195-472e-854f-e2610defccac	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-01	2025-09-01 07:01:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
75491f14-c0bb-45b7-965e-a2695267ae76	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-01	2025-09-01 07:58:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
170ba276-ed78-407d-9803-bb9038f73a38	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-01	2025-09-01 09:28:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
48315d95-6be5-4ab5-bb7e-9b0d33dff2e6	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-02	2025-09-02 07:52:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
87d318fc-5508-4fa0-862e-97b85518f265	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-02	2025-09-02 08:20:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8d3cdd1f-89a0-405c-ac97-795dc0a58004	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-02	2025-09-02 08:33:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
43051e0e-8d4d-4f53-b539-3b7ade8854a2	dedc4608-da7e-4935-99c0-669c48d2a895	2025-09-02	2025-09-02 08:42:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
850797d2-4976-478c-b657-fe369c575543	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-03	2025-09-03 05:29:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
53f28583-9fdd-4df5-b731-c5809741a98a	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-03	2025-09-03 08:13:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ff2d2190-fc00-4810-9c85-2ef272c15c21	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-03	2025-09-03 08:45:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
fe7c7351-27ef-43c5-bfab-cca7cee684f6	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-04	2025-09-04 05:57:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
87f4a592-b847-4747-97aa-b4ba3acdb794	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-04	2025-09-04 08:20:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
41288e65-ab22-4417-8562-07a1b515577a	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-04	2025-09-04 08:56:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ec0ce728-a603-4f09-bd57-d3add8956cee	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-05	2025-09-05 08:15:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
14cb6d50-2888-4373-b333-9d1e7d370489	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-05	2025-09-05 09:55:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8c8a4cbf-8232-4ad1-b498-31db9d868cb8	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-06	2025-09-06 07:29:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5300c208-093b-41b7-a953-b6af5e2b6c8a	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-06	2025-09-06 08:42:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1fc69b2d-4110-4a6e-b8de-dc9bb21679a8	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-06	2025-09-06 10:35:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2dab7419-085a-4e82-869c-44c62373a8be	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-07	2025-09-07 05:52:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
159b66e6-9958-4e80-b389-04fe0dff7f7e	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-07	2025-09-07 08:47:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4dd6c608-cf0f-4f84-a3f8-f0a79fa4cdf2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-07	2025-09-07 09:11:09+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
65cff63f-f7d2-4a94-a95d-b5998a116cbe	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-08	2025-09-08 06:18:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
709d1f35-b6ff-4850-a23f-307bc67c4b53	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-08	2025-09-08 08:12:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
404e55c9-d51c-418f-a817-d39ec40a57dc	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-08	2025-09-08 14:27:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
de6a1769-17aa-46ce-b95d-7040b6b6a0f2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-09	2025-09-09 07:19:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5c7c7ca4-6cc2-4202-9cb1-f5a66a9b2871	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-09	2025-09-09 08:07:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
765bddf8-036a-41ad-83bb-0071a5d171bb	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-09	2025-09-09 10:28:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0cfad0e8-557d-4202-891f-aaaf24dc1fa1	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-10	2025-09-10 09:36:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0bf371df-7af4-4804-8a30-8c588823e0a5	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-11	2025-09-11 06:22:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2dd4ad0f-d800-4704-a123-deaec45f2f73	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-11	2025-09-11 10:26:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
fbcfd42e-2072-4df2-9cbc-621b9ca99009	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-12	2025-09-12 04:30:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
25dfe0df-c51f-4f48-aad5-c398fef8df1b	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-12	2025-09-12 07:36:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2e80068c-e4cd-4a55-8518-1842ceee3b3d	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-13	2025-09-13 06:34:03+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
34ada374-823d-499f-9e8e-9ea1d3ba00b3	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-13	2025-09-13 06:52:45+00	2025-09-13 18:09:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
30c101f5-1b55-4e0d-b9a5-ef1577102731	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-13	2025-09-13 10:55:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5c886197-125a-4c89-be4e-69c289f939e6	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-14	2025-09-14 06:20:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
925f32d9-cd38-4578-87c4-a13d66c76f16	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-14	2025-09-14 10:05:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
81621e99-e281-4180-af6b-2f20e5dd9c29	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-14	2025-09-14 10:39:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
36f18448-01e9-465f-a42b-5658f761de78	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-15	2025-09-15 06:34:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
12b6735d-32ac-4b9e-887f-570682930fb6	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-15	2025-09-15 09:42:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c72f7b38-382f-48c9-8ec6-0e0663d0d550	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-16	2025-09-16 06:45:08+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
36574495-ab19-4fe9-ad7b-717740107042	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-16	2025-09-16 08:46:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2fd31c08-15e0-4f92-beac-1c37f6eb067a	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-16	2025-09-16 09:30:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8ec75e2b-b60c-4900-abf7-9e17acf4f58c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-17	2025-09-17 06:34:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4eaeb32e-8f8a-45d6-a235-71ac1d59c440	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-17	2025-09-17 21:10:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7050c820-7644-48f3-a47d-63f65408d79c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-18	2025-09-18 07:51:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
725b0d0c-707f-4180-b71e-001fc3e27075	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-18	2025-09-18 07:59:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3340830d-5ced-4569-b2ee-b93b4eae0e16	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-18	2025-09-18 10:10:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
99fa33aa-b050-4727-82a0-405b9f05272d	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-19	2025-09-19 09:08:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2d6c260a-3800-411f-982e-3feef7bb49a7	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-19	2025-09-19 09:08:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
af3c2ac7-04a4-430d-931d-52c0742c4763	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-20	2025-09-20 06:55:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f22aed79-6cbc-42a8-a870-e75337347604	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-20	2025-09-20 19:42:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f05e8670-ba8b-433a-8687-27d1c348286d	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-21	2025-09-21 05:16:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7b551aad-1616-4232-824a-3434d7193d8c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-21	2025-09-21 06:41:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
53a0895b-2515-4739-88f8-a23c36e70c3a	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-21	2025-09-21 19:58:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
935006a6-23ce-4d90-893e-38dd50ef7448	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-22	2025-09-22 06:49:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ed414899-af41-43bc-97b5-f7cc78b5e5d1	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-22	2025-09-22 07:16:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b72c6ddc-a2ea-4424-b020-21f4e2fd058c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-23	2025-09-23 06:20:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b36a8617-f168-4ad6-8e0a-206a622b7455	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-23	2025-09-23 07:54:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
62988d45-324d-4607-8a42-adcda2334962	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-25	2025-09-25 06:22:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5c160219-ec82-4cdb-8191-8212efd4ae6a	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-25	2025-09-25 09:32:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
220393cc-0b3b-4dc5-80be-641fc72d2955	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-26	2025-09-26 05:47:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
716d4fa5-58d7-4013-8e9e-b5baeb73bc92	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-26	2025-09-26 07:18:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ccea4d57-5b4b-4f3f-9ab2-7f609efe4575	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-27	2025-09-27 06:21:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7b2dd49c-afd6-4326-89e6-44cd840b73d8	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-27	2025-09-27 06:24:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4bd175d3-2257-46b8-abec-76812e4b3707	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-27	2025-09-27 07:38:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
646ce6de-c7a8-4026-847f-ecc8e016ad38	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-28	2025-09-28 07:11:09+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a9a27890-a68e-4108-bde0-7bd87bb995a6	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-28	2025-09-28 07:11:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e8e1b487-7825-41dd-ae43-28d803e6598e	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-28	2025-09-28 08:57:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6482b0d5-d0dd-4402-9308-273e0074b4c1	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-29	2025-09-29 07:17:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a361b80b-a55b-44ce-9b9c-fbbd60bfcc3f	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-09-29	2025-09-29 07:17:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e0098462-3a6d-463d-9c34-522dc7662bea	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-29	2025-09-29 10:18:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7fe7be83-2e9e-4686-a91f-15efa0e9eaf3	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-09-30	2025-09-30 06:44:48+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d1d54232-66f7-4a85-bb9e-40848ca98231	ba82ba38-633f-4633-849f-b2458ad2952f	2025-09-30	2025-09-30 07:05:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
32e7ea84-be27-47cd-b9d2-2139a62311f2	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-01	2025-10-01 07:25:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
36e55311-1252-40d8-b73a-fc056518ab32	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-01	2025-10-01 07:25:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0a9b7100-3add-4094-93a2-34563aa7eac0	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-02	2025-10-02 06:44:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a1a32cd3-6d3b-4764-9ad4-ce52cfba1874	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-03	2025-10-03 07:19:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0e58e95b-6ed8-4967-958a-71cf65e369db	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-04	2025-10-04 07:02:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
33c9c90e-b09c-43de-a0a1-09ab698ade1b	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-05	2025-10-05 13:41:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
848b9ea1-9d0b-4f24-92b9-4c0e51305757	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-06	2025-10-06 07:32:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2d71f566-9cd0-414b-acab-fd8d24fffe79	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-07	2025-10-07 07:03:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
25b651c1-fb7c-4253-b829-c0d8dba0bae6	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-07	2025-10-07 07:04:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
26bb87d8-ba87-4fae-8c6f-227ecb75bc5d	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-08	2025-10-08 07:28:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
35d860a3-799f-4ff9-b006-2a85f992e525	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-08	2025-10-08 07:30:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7ac1e950-b6f9-47e2-adce-7e2b28ed544d	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-09	2025-10-09 07:41:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8cda92d3-406d-458d-a284-7c004666caaa	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-09	2025-10-09 07:44:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
afcd6ed8-4468-4c60-97ac-3ad33f7694ca	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-10	2025-10-10 07:42:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0c6f55b9-9c66-4e03-b0ce-0c2730ba3e81	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-11	2025-10-11 07:25:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
163e837c-9208-4fcb-b8e5-d950683bbd48	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-12	2025-10-12 07:20:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
881cdf18-30e5-4111-a0ff-bc9b072505b7	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-12	2025-10-12 08:33:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4c93b7c4-1afc-437c-b869-e80526693ff7	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-13	2025-10-13 06:40:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a5456092-c566-4156-bf5a-2321e3bedc20	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-14	2025-10-14 06:26:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4c63caeb-c8bb-4431-b302-04b65eb739c7	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-14	2025-10-14 07:50:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
00137f0b-5159-449b-b08a-fb832957b2d6	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-15	2025-10-15 06:56:13+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ebd2fdc3-d7d5-4c39-9fd9-4954bf52e2d8	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-16	2025-10-16 07:11:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b338c87f-16aa-47bd-98ad-960f28643ce5	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-10-17	2025-10-17 07:12:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4fb88c67-4272-4933-bc60-7bf6c7969eb1	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-18	2025-10-18 07:09:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f3815a96-d24d-4c51-bc14-c2015b9f8515	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-18	2025-10-18 08:47:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
82a3a19e-d5fa-4745-b8b2-e0430d6cb87b	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-10-18	2025-10-18 08:47:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e06d008d-66af-448e-bc8d-0d2d0740ef89	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-20	2025-10-20 07:16:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
23edae1c-d1f3-4d8e-91d4-d2477ba0dbe5	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-20	2025-10-20 07:49:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
275ab3cc-5ad7-4b80-9998-c92b10e5b8c1	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-21	2025-10-21 07:20:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2fbc1d58-aad1-48ef-9896-e5f206fae7ef	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-21	2025-10-21 07:21:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ad96d22e-7e2c-4702-bed8-ddab642d0fe4	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-22	2025-10-22 06:32:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6343599a-a6d6-4935-91b1-d38047ac8f00	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-22	2025-10-22 06:41:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d5541067-2c2e-497d-9e33-00e7b8c91035	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-23	2025-10-23 07:19:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
625c2cf0-43b5-4323-9dbd-b43f83a0c1d2	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-25	2025-10-25 06:08:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7d60e832-8a73-4294-8a96-aa809c74ede9	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-10-25	2025-10-25 08:59:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5eef4ae2-f2b7-4bbf-859d-a3cf1d986aa7	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-26	2025-10-26 06:53:03+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c7b1faad-ee35-4fea-b46b-bcc85bce5fa4	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-26	2025-10-26 06:55:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
889483bd-be24-44f4-9a81-7cedcabc3cda	dedc4608-da7e-4935-99c0-669c48d2a895	2025-10-26	2025-10-26 13:15:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d7194799-910e-42ce-a3c9-b365c0752c34	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-10-26	2025-10-26 19:40:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9a20992c-2273-4444-89b7-3579dd9ae09c	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-27	2025-10-27 08:59:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
df02f2e3-b358-468a-927e-9a158f567c57	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-10-27	2025-10-27 09:06:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
67a9bc45-8c41-403d-9482-eafb44835cde	dedc4608-da7e-4935-99c0-669c48d2a895	2025-10-27	2025-10-27 12:34:03+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
40b1fb93-ec5f-48b3-84df-b9a9df340fda	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-28	2025-10-28 06:57:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
05b2ee0a-aafb-409f-9c0f-4a4d064a6873	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-10-28	2025-10-28 07:00:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
30c4bc8a-64c8-40d3-a5bf-b635386af369	dedc4608-da7e-4935-99c0-669c48d2a895	2025-10-28	2025-10-28 13:35:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d7c1e5d5-f1f2-4be4-8e6f-8cb3f86817ff	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-29	2025-10-29 07:01:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
afe3ea40-36f8-434d-a815-b4261f953141	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-29	2025-10-29 07:10:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e0baf019-e60b-40b5-ba34-788a7fdd90e7	dedc4608-da7e-4935-99c0-669c48d2a895	2025-10-29	2025-10-29 08:20:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8c0741bd-c839-43b6-8163-410a7e7d3320	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-10-29	2025-10-29 19:57:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ee17d54f-a052-4b6d-99f7-88ee3fda3b3f	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-30	2025-10-30 06:28:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
be7f6fd8-60a7-464b-a7eb-a27199bfe03f	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-30	2025-10-30 07:21:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
85811fd8-9856-4250-be51-bfbdfade10d2	dedc4608-da7e-4935-99c0-669c48d2a895	2025-10-30	2025-10-30 10:23:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f4fece17-8dd3-4394-844a-ff56fc596d28	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-10-31	2025-10-31 08:32:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
27062fb7-42c1-44f7-a5ca-b9203e4e3689	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-10-31	2025-10-31 08:58:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
96cd0134-f42f-4e59-99ad-c94f2f5eebba	ba82ba38-633f-4633-849f-b2458ad2952f	2025-10-31	2025-10-31 09:06:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cd309c88-a62e-4466-9717-3a9f1a9979bd	dedc4608-da7e-4935-99c0-669c48d2a895	2025-10-31	2025-10-31 10:30:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3613051c-beda-4954-9901-1271831e6d64	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-11-01	2025-11-01 08:09:08+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f3463252-249f-4f13-aefa-25d9dd820721	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-01	2025-11-01 11:53:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1af1bcb2-b33f-41d8-b43b-7a33587e232c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-11-02	2025-11-02 07:00:09+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3d1d9ca4-8805-467d-8ef1-e71d45b734df	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-02	2025-11-02 11:20:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4a5fe1b8-6cf6-4891-9420-23b139b74e22	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-02	2025-11-02 11:36:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9e40522e-57ee-4852-bc2b-4abbafbcdd5e	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-02	2025-11-02 13:26:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
bfc5e88a-0db8-437e-9aff-76ffd30bbeeb	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-11-03	2025-11-03 07:03:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e1b39f0b-6431-48ad-a864-88e576b2a067	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-03	2025-11-03 08:28:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2c54359a-301d-4aa5-90ee-1886a9dad9b6	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-03	2025-11-03 09:10:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
806e5b65-d23f-440d-89b9-6f019b79992b	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-03	2025-11-03 14:49:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
86d11cf1-1c62-456f-b4eb-48a5fa03c5bb	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-11-04	2025-11-04 07:05:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9070de2a-8214-4725-bb70-167345e6ae7e	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-04	2025-11-04 07:51:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6ab8690f-eefa-4530-9bd9-a1bf71f47674	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-04	2025-11-04 10:38:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f6e155a0-d434-45b3-a8d6-b04af4cfe35e	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-04	2025-11-04 15:38:03+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f9e848c5-5002-451f-9274-dc004b7f4f1a	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-11-05	2025-11-05 07:17:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ef5e4be7-5905-4c58-bd1c-777834c89513	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-05	2025-11-05 07:43:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a971b1db-7bed-40a1-95d3-7706b6c397a2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-05	2025-11-05 09:02:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
758d0234-9ac7-40ac-9c6a-7675cb1b0374	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-05	2025-11-05 11:27:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
813b9282-01d6-4aa3-8fcc-deb57e286abe	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-11-06	2025-11-06 07:19:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2b8ed780-98d7-4b34-a9ca-8c104403cad3	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-06	2025-11-06 07:35:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7c86391c-9578-47e7-9e06-209dc1e6f44c	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-06	2025-11-06 08:52:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
125cd39d-ff2c-40bb-9440-047803537b55	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-06	2025-11-06 11:42:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1507c14a-a56a-4e27-a23b-dac9093d1067	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-11-07	2025-11-07 08:00:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7bef20db-986b-408f-be76-707555214967	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-07	2025-11-07 08:27:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d5057cd6-9aec-493c-b1d0-66a9931a7d6e	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-07	2025-11-07 09:30:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
51b662ee-7a7f-4596-a141-4ab7b654b9b4	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-07	2025-11-07 10:08:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ffc776f6-f84a-426d-8c1a-017ffdbabc22	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-08	2025-11-08 08:28:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7265d585-de93-4b84-a8e5-c3b7cf9d475c	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-08	2025-11-08 09:37:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
79d6e590-b16c-4dd3-9f0d-28e13f1213c1	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-08	2025-11-08 09:41:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
68c1b0f4-5ee6-4a41-a9c9-14aeaac46aae	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-09	2025-11-09 08:35:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
de5d5c62-016c-4b17-b074-25fe76d0ea9d	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-09	2025-11-09 09:37:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
93df9e1f-0cb0-4532-aa67-f9ed04e658a9	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-09	2025-11-09 12:50:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9b0f1376-a729-4713-86a8-039583ddac34	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-10	2025-11-10 07:40:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e6ec86e9-991c-48e1-aa9a-d3e981435698	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-10	2025-11-10 15:20:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2c623218-b33a-4420-8f5e-96598cd9ed9f	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-11	2025-11-11 07:45:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
19f925cc-20c8-4c09-a2b4-9742351cd1db	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-11	2025-11-11 10:48:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dec0008c-415e-4cfd-be85-bb0cab6e296e	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-11	2025-11-11 17:49:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
eaf5910b-5ded-4e24-a403-6045d704cd9d	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-12	2025-11-12 07:14:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2a6cbb65-dff6-44c1-805a-c7f128812408	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-12	2025-11-12 11:28:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f857a772-6d39-4ede-9b27-c8b78c536fa8	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-13	2025-11-13 08:08:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0003a947-6aee-41ea-b50c-84d46fdc2eed	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-13	2025-11-13 09:33:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
907b37a7-923d-446b-a6dc-7232ceffec13	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-13	2025-11-13 11:10:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0f9f838b-5d21-435b-b6cc-02435a1269d4	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-14	2025-11-14 09:01:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f5b95456-b75f-4283-82a5-f18b103b9fe3	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-14	2025-11-14 10:10:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e09b2482-f90d-4e92-956e-254f5c0c574e	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-14	2025-11-14 10:16:13+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0363bacf-24c2-433e-a784-89c3b58c7f80	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-15	2025-11-15 08:21:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
caebc3ff-2b63-4970-9836-b749a2e4079d	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-15	2025-11-15 09:10:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9f50c008-ee53-4e46-b9fc-b9eb7a16ce86	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-15	2025-11-15 09:24:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d1e62afe-c055-4e73-8df7-45a877a638fa	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-16	2025-11-16 07:33:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
243bb0c7-75ed-4d02-a01c-40f7f77c8023	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-16	2025-11-16 13:12:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
611f3675-0a52-4c25-b06e-5730f1721efa	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-17	2025-11-17 07:20:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f56b493c-e2e6-44a2-a993-2104387f9e0c	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-17	2025-11-17 07:22:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
556d256c-0777-4fe3-954a-b629c2e6865e	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-18	2025-11-18 05:57:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
76d993f8-145e-4a79-80f5-40bfe9f28486	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-18	2025-11-18 10:51:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
56bff071-e41c-4dcf-a632-6517ed9973b2	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-18	2025-11-18 13:23:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f46dd168-0516-4bb5-95fe-74488c14df40	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-19	2025-11-19 06:59:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
85abbf1a-6120-46ea-8b7a-15ce6ed4b98b	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-19	2025-11-19 09:07:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d2bde4ae-273c-49cd-8656-fdccee03a9ec	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-19	2025-11-19 09:58:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
47b5c9b1-5f36-489c-a143-44e471b86ce8	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-20	2025-11-20 07:47:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
49a28264-e61f-415e-8a45-519dd36c203f	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-20	2025-11-20 10:11:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
52569904-2dcf-45f9-ae13-34e2c6bb9915	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-20	2025-11-20 11:10:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4c421a9c-af26-4c49-8f81-b502e0faa431	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-21	2025-11-21 07:20:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3cd7765e-2a1a-4554-aa8b-91236f8b57bd	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-21	2025-11-21 11:12:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
199d59ca-1cd9-45a8-a7f8-f5926959d0a9	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-21	2025-11-21 12:33:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c43afd0b-a4c7-4303-b055-43ed80eb2e51	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-22	2025-11-22 07:36:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
52c99a4a-81a8-4926-acfa-2e265b3497be	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-22	2025-11-22 09:33:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e2cf9528-6359-45a9-b4bc-e22d9d28d717	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-22	2025-11-22 23:38:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
acf71e79-a36d-4b49-87cd-2140bd1ae418	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-23	2025-11-23 06:58:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3dbbac56-b450-4089-a770-dcdbd903eeb5	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-23	2025-11-23 10:55:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4eadfde8-b7d4-4c01-915e-ed86b779473a	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-23	2025-11-23 19:38:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6c309417-77a5-4a28-b94f-21a33da9653f	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-24	2025-11-24 07:27:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
70f5aad2-78ad-435b-8c01-4cc24ab5d75a	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-24	2025-11-24 12:05:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
88ba6e4d-74f9-453e-a794-3b4440893ffe	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-24	2025-11-24 13:21:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0a326bcd-8b57-4ce2-a8cb-2a7e2a57185b	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-25	2025-11-25 07:17:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
39355e45-e5af-4331-bae5-03ee63b4faec	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-25	2025-11-25 14:44:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8c23728c-da7e-441c-991a-8af12756cbca	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-26	2025-11-26 07:33:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
bef733e0-7ce1-4e0d-9876-bab982269f08	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-26	2025-11-26 07:42:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0f3fc062-def3-45eb-8258-b8fb61912ede	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-26	2025-11-26 11:37:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
10c9c92f-0a7d-4a1f-94a3-39388897f9d7	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-27	2025-11-27 07:03:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
aa91fa0e-39a2-48d7-a3c6-88fa0addd796	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-27	2025-11-27 07:41:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8499ea64-ce01-4493-88ba-4b24719e8f73	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-27	2025-11-27 11:00:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
815ce366-f143-42b1-acd4-dcbb327d3fbe	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-28	2025-11-28 07:50:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a00de547-c183-48b3-9738-34db0d6a5e59	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-28	2025-11-28 08:16:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
92c97bd3-95f2-41b7-8b93-7d4ed2cb085b	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-28	2025-11-28 08:25:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b3fdf915-c681-44e0-9d36-3b740287bfd0	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-29	2025-11-29 07:45:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b3883b02-96fd-4c5b-9df0-977f89f6b18d	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-29	2025-11-29 08:22:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
df49ded7-922b-4a5b-b2df-cf20de819c60	ba82ba38-633f-4633-849f-b2458ad2952f	2025-11-30	2025-11-30 06:57:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1fa22840-87fd-4cb5-a3f5-f8b560b29210	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-11-30	2025-11-30 08:34:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f09187d8-8899-4d4f-863f-d5661d782df6	dedc4608-da7e-4935-99c0-669c48d2a895	2025-11-30	2025-11-30 12:58:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
10a8f00f-7ae7-4633-bef3-fb9af8bea453	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-01	2025-12-01 07:30:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
33797863-c8bc-43da-bae6-2f85c4649220	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-01	2025-12-01 07:33:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5563b162-d0d1-4d8c-9779-c0025200c837	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-01	2025-12-01 08:22:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
28c32cb3-982b-4c7b-a65d-f123bfee02e9	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-01	2025-12-01 14:38:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a677a049-efbf-4144-ad82-dba5fc0b3f93	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-02	2025-12-02 06:59:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6e05f716-d519-48a8-8781-14cdd18e0268	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-02	2025-12-02 09:04:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
eab0c00f-3f45-4a25-934b-3ecd7266d6e4	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-02	2025-12-02 09:09:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
41907917-7114-4db9-b9af-e99ab1d44021	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-02	2025-12-02 15:22:09+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
03d1103f-4fb5-4c7e-8573-d5dc3810bbc2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-03	2025-12-03 07:14:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0401f174-e414-4a8d-866e-0b4acd85477a	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-03	2025-12-03 09:09:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f22d707b-373f-4891-a8f1-326902842e16	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-03	2025-12-03 12:17:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7b9e40e5-e16d-4b2e-9e33-f87b009b9e69	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-04	2025-12-04 07:39:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6c4e9e8f-9e03-46f6-a5fc-90fc54d03a0c	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-04	2025-12-04 10:12:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1ea1ef90-2f8d-41b4-b463-36110c76f766	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-04	2025-12-04 10:22:03+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3b45754a-596a-41b5-b19a-6df684c792e2	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-04	2025-12-04 10:50:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6fa31540-21eb-4e4d-b6df-4283aec57611	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-05	2025-12-05 09:03:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2098c351-4eb2-4066-9426-7b672616761e	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-05	2025-12-05 09:25:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
81ab1582-5443-43ab-a51f-53a7a53649f0	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-05	2025-12-05 10:15:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
530ced53-36b3-40b5-96f4-136d58bb73d3	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-05	2025-12-05 21:08:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2a4f61ea-585b-41a4-bb43-0cd18553634c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-06	2025-12-06 07:57:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4fc348d1-2450-4c6c-845c-e132d6084e69	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-06	2025-12-06 08:24:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
868bf568-6cc0-42cb-9d93-68fcf92cb1b3	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-06	2025-12-06 08:30:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1b6df0ea-e002-4b74-8924-a2172554f0fa	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-06	2025-12-06 09:42:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b706584c-5c57-48b9-808a-c3caa7239c86	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-07	2025-12-07 07:18:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c1006b22-7687-4c93-9e4c-8dc194619a11	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-07	2025-12-07 07:18:13+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ebc14eb4-12b5-437d-a940-00aee02124a0	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-07	2025-12-07 07:49:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
633b0f4d-e063-4b7b-ab10-3e0328dcc0c8	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-07	2025-12-07 11:53:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
05331bd7-8c2c-4f0d-a8ae-1d0d05d23b3e	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-08	2025-12-08 07:39:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f2f38915-dc1e-4631-a5c1-8940278885a5	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-08	2025-12-08 08:20:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6fd7f078-e04d-4ff5-b8da-eb24cee93836	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-08	2025-12-08 08:20:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8decbc13-1924-4ab5-aaf4-aca028416135	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-08	2025-12-08 13:34:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
93df606e-a878-48da-b6ef-be027e682353	ba82ba38-633f-4633-849f-b2458ad2952f	2025-12-09	2025-12-09 07:43:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3e6cda67-da96-40d1-ae7e-19cd98179044	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-09	2025-12-09 07:48:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2ca75b82-2317-4d8b-b711-2bea66f67d21	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-09	2025-12-09 07:53:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0140cfb8-f46c-4cc1-b228-5629331e2cde	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-09	2025-12-09 14:58:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
84796bd6-e3d5-4cb3-9070-2dfb58556ebf	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-10	2025-12-10 07:15:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b7a615b1-4fd2-47bf-aed2-ed4fb8baf096	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-10	2025-12-10 08:31:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
72a88d4c-733a-4467-8522-9f5740ae1123	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-10	2025-12-10 11:18:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c692177e-b219-4f7e-b24f-084ab1a93b14	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-11	2025-12-11 08:00:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
313137cc-7479-46a1-84f4-6dc34c7c4354	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-11	2025-12-11 09:08:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2dd040a5-5005-4de9-8d08-53f5f3bd7d04	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-11	2025-12-11 13:56:08+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5aa1dfda-6d46-43df-aae8-61b350eead72	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-12	2025-12-12 08:29:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b6c13ffd-e114-4ed2-bd7d-e5e74c50e439	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-12	2025-12-12 08:29:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9abc0208-3cb9-405f-a021-075feb03e187	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-13	2025-12-13 08:55:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2c13c203-1fc8-4766-a267-b5b7e7b06759	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-13	2025-12-13 09:33:09+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6b7156dd-b4af-4cc9-b8aa-b15e7ab9676a	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-14	2025-12-14 07:55:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a7a1f981-a7d1-4c9a-98b3-08dc3d77cb50	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-14	2025-12-14 08:25:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c32ffcd9-8857-46cd-a0dc-e596ce75c64f	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-15	2025-12-15 08:05:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4c802477-8d0a-45a5-9996-eab927785219	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-15	2025-12-15 12:11:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b4abf01d-af60-4b32-a302-b149f60c4101	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-16	2025-12-16 06:34:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c2dc45c5-f61c-4528-bc6f-a5388621d3c2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-16	2025-12-16 08:59:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d2f1ae64-d946-4ecf-8444-fc1d62dc420f	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-16	2025-12-16 12:20:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0c7ff15e-8055-4446-8e9e-91521e5c4b4f	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-17	2025-12-17 09:04:09+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
df946440-cb50-45b9-ac33-1a1b1a0c48c4	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-17	2025-12-17 09:27:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
54fd5aca-7aca-4fff-b258-0d1f5fe880ec	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-17	2025-12-17 11:37:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
74c6da5f-4d28-46e8-a787-9beba4f1d674	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-18	2025-12-18 07:30:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
818c20c1-5232-4322-8864-71088d97643f	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-18	2025-12-18 07:37:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
47df7a4e-de90-461e-ae04-cdc0888f4ce8	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-18	2025-12-18 13:25:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
07f17333-6d8f-46b3-ab56-0773f3273d0b	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-19	2025-12-19 06:44:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c6ddaf2a-a88b-4c0e-80d9-78e647adfd03	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-19	2025-12-19 08:15:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dac52d94-7e9c-4be7-a23a-095d63eec6c9	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-19	2025-12-19 08:15:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b78b4dac-509a-4a4c-acb0-e3bc3b473130	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-20	2025-12-20 08:01:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f0dc5344-9ed4-4ff4-a405-a135c87919e0	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-20	2025-12-20 08:01:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
79e84b71-ef8c-48c4-81b7-f7cd67bc0a22	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-20	2025-12-20 08:34:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
af669fbd-3a11-4c2d-bbd5-6a39b982ae43	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-21	2025-12-21 07:38:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
fffb368a-7baa-416d-a00b-09cc0e8a7803	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-21	2025-12-21 07:45:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dd734146-f6d6-4031-92bf-b3ebabbaf7a4	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-21	2025-12-21 07:49:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
54ed11c0-680b-448f-9b8b-7bdbadd81a82	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-22	2025-12-22 07:52:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0b184818-e168-4f50-9ff4-f33ba97dfd3f	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-22	2025-12-22 21:08:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
11edc7dc-3eac-4462-8b65-fef53b62e3da	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-23	2025-12-23 08:14:13+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6eb1c737-0442-4672-9ece-3829bc9d223d	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-23	2025-12-23 09:36:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9f0a8666-47fc-4184-8326-f6491874877b	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-23	2025-12-23 10:08:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2aee6234-3e5a-4a6a-8bb7-6da042094e9c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-24	2025-12-24 08:17:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b44a9e45-4f2f-4349-b329-8e9a56961da2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-24	2025-12-24 08:40:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
08043eb9-2bf2-430c-98d8-10f6077c5e97	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-25	2025-12-25 07:36:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d29275fc-a7fa-4f35-be5a-b81b3d13c496	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-25	2025-12-25 09:59:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2bf54473-71d3-4cb3-8d64-7644e91acf2b	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-26	2025-12-26 09:04:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9e50e9a8-8815-46de-a7f5-52909c35b6d1	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-26	2025-12-26 09:30:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
97038f73-2ece-4fcf-a45e-369b79cc7ef3	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-27	2025-12-27 07:14:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b821b499-f4a1-46c8-abfb-3834df694729	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-27	2025-12-27 07:34:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
964adff9-a871-443c-9823-b15c26475842	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-27	2025-12-27 08:28:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8dccfbfa-16c8-432c-9383-6aadbfef608d	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-28	2025-12-28 06:30:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
68b0d0a5-9125-44e3-8db5-b4322c157526	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-28	2025-12-28 07:57:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
eabe1a97-c9ff-4e0a-b059-5f1671891c0f	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-28	2025-12-28 09:50:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1a91e309-52cc-4446-920d-8a6a54d049ad	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-29	2025-12-29 09:07:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
de5920d0-f904-44f4-bab5-2669a86c2475	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-29	2025-12-29 09:36:08+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b87743db-9626-4b09-b36a-a7b5e56361f5	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-30	2025-12-30 07:40:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6491f3f6-93d0-4da4-8dd4-932f98a3985a	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-30	2025-12-30 07:41:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ba3506d9-7345-4be6-bf56-2fc959b1ba2a	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-30	2025-12-30 09:54:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ca32b366-c5db-446b-9c74-c27b7cb531d5	1c2e1861-ef74-46d8-9a77-ed741494a29a	2025-12-31	2025-12-31 09:10:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f013612a-867c-45c7-8db0-bcd43e39e182	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2025-12-31	2025-12-31 09:11:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6e01a0fa-c402-4439-8d9e-546e644f66b7	dedc4608-da7e-4935-99c0-669c48d2a895	2025-12-31	2025-12-31 11:53:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c7e125e5-61c3-4c8a-98cb-20aa302678d2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-01	2026-01-01 07:00:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
969860bf-48f5-4b2f-bf9a-b9557ddafa71	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-01	2026-01-01 07:32:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c103a0f8-329b-4e1d-9b0b-f4b50d80f326	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-01	2026-01-01 11:42:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
fc1889d4-c957-4a9e-a17d-a7bbcf4b4785	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-02	2026-01-02 07:43:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a66531ec-06bf-43fa-9985-27e81bf711f1	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-02	2026-01-02 08:46:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
608a5a30-761a-43d0-a593-260b9ed1624f	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-02	2026-01-02 09:30:48+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8dd40cfb-f65c-485b-bd3f-ca11ac76ae0c	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-02	2026-01-02 09:38:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1eb5eab1-c7c6-4286-a397-97602ad489b7	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-03	2026-01-03 07:21:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
db1c0421-6c35-4241-8d21-8340809397c9	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-03	2026-01-03 07:40:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d92a21c7-d1ec-490f-be39-9fb127a4e70c	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-03	2026-01-03 09:09:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e1df0771-7138-4316-a606-dc57fe7402a2	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-03	2026-01-03 10:20:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
400b0a7c-b87f-4041-8a52-c179c6c03ba9	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-04	2026-01-04 08:11:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
648d3f47-adff-460a-aa53-3d204e553527	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-04	2026-01-04 09:24:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c272aca5-f4bb-43c4-ae43-7239aeeaa33a	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-04	2026-01-04 09:55:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7ae0ac69-2a1b-476b-9933-8172578288c3	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-04	2026-01-04 10:14:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
defe2011-a949-4584-8414-54eb3ec72fce	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-05	2026-01-05 06:44:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8ffaef5e-e1e2-45f3-96de-c1d690c87c9b	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-05	2026-01-05 08:49:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6c48f4f1-c927-49e1-8a14-6d58ae530934	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-05	2026-01-05 10:02:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4989d82c-d5f2-4698-bbcb-f412e44dd119	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-05	2026-01-05 10:22:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3ffb3770-4469-4149-a9cc-99fbc28d8343	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-06	2026-01-06 06:33:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7413ef6b-807b-4637-bcca-224860db6be9	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-06	2026-01-06 08:12:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b8c1e52f-6a26-406e-9803-6c53afd461c7	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-06	2026-01-06 09:04:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b36cf8ea-58d3-411e-947c-1bedbe7f4526	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-06	2026-01-06 11:15:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
47638f5a-10bc-493d-a0aa-50e8575da5f3	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-07	2026-01-07 06:46:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ca7dc8f9-2f9b-4a4f-bed3-410b26ba8661	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-07	2026-01-07 08:53:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dc8cdb0e-4f20-4423-bc23-2e987494b7fc	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-07	2026-01-07 11:41:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cfd6475c-e586-4d43-b0ab-aca1e51e8c40	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-07	2026-01-07 11:00:00+00	2026-01-07 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9ea04cf3-b3f3-455c-beae-a926c422edd3	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-08	2026-01-08 07:22:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7e0a6c29-10aa-4210-a292-3d2abb9edd9d	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-08	2026-01-08 07:29:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0323d459-c61e-4e8f-b022-357ba385570d	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-08	2026-01-08 09:09:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
870d3f6e-16eb-46fb-af7b-6dff65bd7c10	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-09	2026-01-09 08:04:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
724fe15c-8cb1-46b7-9595-a0725852112e	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-09	2026-01-09 08:19:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0f4236d9-d266-4143-8edf-f9696b2f8077	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-09	2026-01-09 09:14:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ba0dac44-32f0-4ac8-b9bb-f1ca5ac6f396	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-10	2026-01-10 07:07:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a7a9fe03-dbc0-45ef-bcb6-d759df1ac41a	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-10	2026-01-10 08:40:13+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
db4ff3b1-06d4-43f1-a9a2-caf0a0249440	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-10	2026-01-10 10:17:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3d6bdb31-de59-434d-8659-621626188f8c	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-10	2026-01-10 11:05:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
75b66a74-08d1-430f-bd93-ccd2c595073a	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-11	2026-01-11 08:01:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b051a5b3-eb02-4ea3-97db-ca91940d0797	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-11	2026-01-11 08:30:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dfb695c6-3122-49cb-a9e7-49b871e9342b	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-11	2026-01-11 09:03:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f73087bd-88e4-4b7c-ad9d-b9ebdcb66d45	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-11	2026-01-11 09:23:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
23978f4b-1429-4e6c-9076-440fe7239ef5	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-12	2026-01-12 07:57:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
eec84543-8072-4f64-aa26-65fce5281a7b	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-12	2026-01-12 07:59:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ee6db3eb-2dcf-4f6f-8d93-41a381dafbfd	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-12	2026-01-12 09:46:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dabc02ce-899f-47a4-8a0a-4f930958c331	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-12	2026-01-12 11:41:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ba1cfbb4-7e18-4a52-97f3-63777ad44705	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-13	2026-01-13 07:40:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4ee7de26-b5c5-460c-baa2-b0cb0b7ea420	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-13	2026-01-13 08:16:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0f6ad7cf-4f11-4736-826c-bc4d9b718fa8	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-13	2026-01-13 10:20:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
33d3ff1f-bb07-442e-b1cf-75e6a6b7b5c8	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-13	2026-01-13 11:00:00+00	2026-01-13 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6fb07131-f82d-4e8d-8fc3-cf9a51034cd1	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-14	2026-01-14 08:25:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d7ff8868-15aa-4e6d-bf81-c7711f868bb9	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-14	2026-01-14 08:57:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d6a1d9e8-a2de-4293-ab64-6f09304003c7	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-14	2026-01-14 09:23:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
fdc626d7-7968-45d7-9039-ee1f161b1f49	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-14	2026-01-14 08:57:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
10de93c7-74b2-49fb-ab5b-ff7609686a02	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-15	2026-01-15 08:48:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
14c93bb2-1297-49ef-b9bd-a370a0a2bfbd	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-15	2026-01-15 09:05:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7e53fa6b-056f-45ef-bc9c-8652c90e4639	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-15	2026-01-15 10:22:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1dbf972f-fffc-4fb0-a2cd-58301f1a18ab	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-15	2026-01-15 10:31:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2a127ade-31fc-4296-89c9-71b447937f8a	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-15	2026-01-15 15:01:00+00	2026-01-15 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a111cc0f-f25a-4ad3-8170-ea7dcb0a7099	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-16	2026-01-16 07:40:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8ec983fd-1989-49c6-ab6a-bb4874229fc8	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-16	2026-01-16 09:15:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5f01d81b-eeb9-4a99-b882-cfff61d46e04	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-16	2026-01-16 10:00:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0f2d064c-8da9-47d9-8567-e7cdd2201346	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-16	2026-01-16 11:38:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ad67bef4-6d9f-42ed-971c-aeec32f4bc1d	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-17	2026-01-17 08:08:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5b8fc435-e7b3-4259-a128-4c0dedec1d9e	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-17	2026-01-17 09:33:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
10bef08e-668b-4854-87df-9bde2089c1cf	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-17	2026-01-17 11:23:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
48163ecc-34df-437d-9957-a5ae8451f00a	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-17	2026-01-17 12:55:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
97c68178-b36c-4a66-aa95-d16008baa923	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-18	2026-01-18 08:52:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8ac8d483-badc-4b19-aa2c-140553bf1575	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-18	2026-01-18 08:54:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7c161613-5f8f-4218-86f7-6e2094eebb4f	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-18	2026-01-18 10:18:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e5b81c91-2029-42fa-a066-1fe61ec6178c	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-18	2026-01-18 11:42:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9fc03d3c-5887-47a9-be65-32302b2dbae9	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-19	2026-01-19 08:00:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2ad64639-5db3-4b2e-88e8-95538cd32476	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-19	2026-01-19 08:27:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0b31ef7a-28f2-47c2-b2ce-94a7abae565a	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-19	2026-01-19 10:24:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4e6e33a8-43ba-4120-b594-ee85f0f734d3	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-19	2026-01-19 11:22:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d216555e-bf1a-42b5-bb32-21f6e441d2f2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-20	2026-01-20 07:26:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3eacadee-f4de-4a10-8872-d8734ab55fe6	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-20	2026-01-20 07:26:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
daf3df79-6507-410e-a8ef-97f19cfbfb94	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-20	2026-01-20 07:42:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8da8ebf9-c6bd-4998-980a-cc2e811ff035	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-20	2026-01-20 10:37:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9af74e8d-1d45-4ff1-8337-b7845ebda48a	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-20	2026-01-20 11:16:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
60d2dd5d-a682-48b9-9c7c-d71ca7e76ed0	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-21	2026-01-21 07:00:00+00	2026-01-21 20:13:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b70e74e6-5381-44c9-acff-a69efa6e4692	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-21	2026-01-21 07:23:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
403f95f3-5681-4ab7-8279-58667537ec9b	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-21	2026-01-21 08:35:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
662b4afb-7211-4f20-a644-fa6188032f0b	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-21	2026-01-21 09:15:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7075a504-ea23-47ce-b761-a16a2c7668eb	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-21	2026-01-21 09:45:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5823277d-a25a-4009-a797-5486175cf99a	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-21	2026-01-21 10:14:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f5faa51f-d31c-4e4e-8a59-44d133012c96	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-22	2026-01-22 07:00:00+00	2026-01-22 20:16:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b85e3812-aac0-4299-8019-4f4a7421f0ad	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-22	2026-01-22 07:39:03+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
01271d6f-adfb-4c34-9671-ade0e9b71999	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-22	2026-01-22 08:18:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8b9b3ff0-3767-446a-9b75-599f7b257123	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-22	2026-01-22 09:09:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6c539bc2-db4c-49c5-bda8-bf74c949a2ce	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-22	2026-01-22 09:59:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1e3eff41-cd7f-4952-8b8c-24b78a5e3997	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-22	2026-01-22 11:38:48+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
17430b3e-dd9a-4b4e-8322-c4a69e2ca18a	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-23	2026-01-23 07:37:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
81c14276-efe2-4d3a-b6aa-70fe162c1b89	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-23	2026-01-23 07:00:00+00	2026-01-23 19:30:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
fd0856d6-bef4-4514-86bd-f606936670e4	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-23	2026-01-23 08:07:13+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
79c9dd4e-c481-4244-bba4-99f025f396f4	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-23	2026-01-23 09:52:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
09b9fa93-be61-4a42-a688-7fd4dc44f443	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-24	2026-01-24 07:29:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f32ea8b9-94b0-4c12-8589-46e5e5ec98e6	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-24	2026-01-24 07:00:00+00	2026-01-24 19:01:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c12a905f-8466-4ce0-8f6a-e6289ecf9239	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-25	2026-01-25 10:00:00+00	2026-01-25 10:00:00+00	mission	\N	2026-03-27 08:48:30.747484+00	t	admin	سفر	f	f	f	\N
2176971c-78bb-4e23-a17e-df85d28cc83f	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-24	2026-01-24 09:35:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4826b44f-9f78-4311-8872-ecbc5a425811	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-24	2026-01-24 09:35:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2f322cac-7d85-4d8c-a0c9-b74850ece9f2	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-24	2026-01-24 11:14:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
fa255326-464c-4c71-a260-68d8970922d6	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-24	2026-01-24 08:17:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
37515ea9-5063-47c7-836c-f766a186977a	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-25	2026-01-25 07:02:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
02ae85e0-a93f-402d-aa1d-58b41f599f5c	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-25	2026-01-25 07:02:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2cf18dbe-12a4-46ad-95da-84f4b8d13c99	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-25	2026-01-25 07:39:08+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5a0034b0-74ae-4581-8241-120a2c1d0deb	6fbdf70e-9def-4819-ba61-1146768e063e	2026-01-25	2026-01-25 07:42:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0a9eaa0f-d3ed-4688-8bcf-ca6089e25952	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-25	2026-01-25 10:26:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
97a33049-3438-426a-a710-e4b1e82e62f6	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-25	2026-01-25 10:38:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5e9a1bb6-102e-41e3-a540-1efbc60419f1	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-26	2026-01-26 07:00:00+00	2026-01-26 19:04:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2833ace7-600b-411d-bca0-4549f47215a4	6fbdf70e-9def-4819-ba61-1146768e063e	2026-01-26	2026-01-26 07:46:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2d58fb0c-c16b-4d9d-be64-6941509fd477	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-26	2026-01-26 08:02:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d8d1c2f7-abe4-413d-8197-5b1641d9e9e0	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-26	2026-01-26 08:16:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
65e938d1-7359-415f-b627-bb82e727c0d0	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-26	2026-01-26 08:16:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a6c0f398-9212-424d-9dfc-33aab96f97d4	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-26	2026-01-26 10:06:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a4836025-5699-4637-9349-6f72344f320e	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-26	2026-01-26 10:53:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
66032caa-6f1a-4c7d-9e95-48828dfb2faf	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-27	2026-01-27 06:18:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e3c2e31c-ee52-4f51-b163-e496ed650387	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-27	2026-01-27 06:58:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1dda3891-a724-4543-a8f2-e4f6e330302f	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-27	2026-01-27 07:30:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f4e5b6a0-d60e-4d93-b21f-a95592c5e0c3	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-27	2026-01-27 09:32:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9a3fa758-52df-4fe8-a197-5a4c685dccc6	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-27	2026-01-27 11:18:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
57ac27fc-ca4d-43f4-b0eb-0acbd6529f0e	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-27	2026-01-27 11:37:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c5913b74-690f-44a5-8dec-48703f47f905	6fbdf70e-9def-4819-ba61-1146768e063e	2026-01-28	2026-01-28 07:31:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
85a0c981-3cb8-4926-9db9-612afdb986eb	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-28	2026-01-28 07:31:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
acf007f4-33a1-4574-9a06-1b1c2988e95b	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-28	2026-01-28 07:39:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f35dc4b4-6aa5-41af-8343-60fb45ec3dd5	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-28	2026-01-28 08:29:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
97b86771-ec14-4716-95ef-9a8ee07bec72	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-28	2026-01-28 09:57:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
53480229-64ab-4854-9c04-ada0e06329f9	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-28	2026-01-28 11:01:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4c25e598-8058-4da1-9a9d-3a4e46104810	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-28	2026-01-28 11:29:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4fd010b0-dbd3-4ea8-b0d8-15c20f967d76	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-29	2026-01-29 06:47:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a29eac07-ac06-4688-83ee-177af5dfdfd0	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-29	2026-01-29 07:09:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
089eba42-753e-49dd-aa1f-f064c4be8061	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-29	2026-01-29 07:23:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4f2e3351-b646-4747-b744-7fa85ecabde7	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-29	2026-01-29 07:25:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9fc35966-0827-44c3-a76c-8013528fd7db	6fbdf70e-9def-4819-ba61-1146768e063e	2026-01-29	2026-01-29 07:44:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
500f14b6-f378-4980-8aa7-7f816bb89068	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-29	2026-01-29 11:20:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
69692476-2ba4-4ccf-b8d1-424ce82a6687	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-29	2026-01-29 12:27:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
381921a7-8935-418b-a6fa-cbfd5df70191	8547bd33-4c1f-4939-a460-f42beec6d360	2025-12-31	2025-12-31 22:00:00+00	2025-12-31 22:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	t	Admin	إجازة بدون مرتب	f	f	f	\N
4c70488d-8cad-4b98-a920-9a0abd163aed	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-12	2026-01-12 19:00:00+00	2026-01-13 15:00:00+00	excuse	\N	2026-03-27 08:48:30.747484+00	t	admin	لم يتم انشاء بصمة	t	f	f	\N
c178f23d-c17d-4a4f-bcbd-0a5adce5e322	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-30	2026-01-30 07:47:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ac82540a-7d38-455b-805a-9af82dc4c7f6	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-30	2026-01-30 07:47:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dfa1d27b-3e8d-44d6-847a-b546a56b5e46	6fbdf70e-9def-4819-ba61-1146768e063e	2026-01-30	2026-01-30 07:52:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
fbb13813-742a-4a2a-a07d-051919a29cf2	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-30	2026-01-30 07:52:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
09b64c8d-3e37-4475-9d2b-c2ce09a67eee	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-30	2026-01-30 07:55:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
86865e9c-43b6-4b8d-87b9-261eeb11b890	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-13	2026-01-13 19:00:00+00	2026-01-14 15:00:00+00	excuse	\N	2026-03-27 08:48:30.747484+00	t	admin	لم يتم انشاء بصمة	t	f	f	\N
a8821476-993b-4384-953d-18f370c50073	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-14	2026-01-14 19:00:00+00	2026-01-15 15:00:00+00	excuse	\N	2026-03-27 08:48:30.747484+00	t	admin	لم يتم انشاء بصمة	t	f	f	\N
757a5599-cb1f-4150-870a-fecc6796d065	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-30	2026-01-30 09:44:26+00	2026-01-31 19:31:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
998a18cf-de35-4981-9d0f-df70b35f0572	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-30	2026-01-30 10:50:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b573e60b-a0d5-4269-a555-304c0b14f4cb	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-09	2026-01-09 10:00:00+00	2026-01-09 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
b3016572-d947-4494-bff0-d1d98e3f1137	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-23	2026-01-23 10:00:00+00	2026-01-23 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
d92d7173-a6c9-4cba-a613-98733a09d940	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-11	2026-03-11 10:00:00+00	2026-03-11 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
3c8eaf5b-ee0b-4fdb-a9ec-72c803710fe8	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-20	2026-01-20 07:00:00+00	2026-01-20 19:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	t	admin	لم يتم انشاء بصمة	f	f	f	09:00-17:00
d916f355-c103-4ff5-8d4b-bcb8d9b2a944	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-16	2026-01-16 10:00:00+00	2026-01-16 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	مقموص	f	f	f	\N
83c180fa-5ca6-4593-bfd1-b4a149523908	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-17	2026-01-17 10:00:00+00	2026-01-17 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	مقموص	f	f	f	\N
c316cb16-97cb-49b6-985e-9659ca4881a6	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-18	2026-01-18 10:00:00+00	2026-01-18 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	قماصة	f	f	f	09:00-17:00
54a42a49-9954-49b5-979f-9d82d584719f	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-19	2026-01-19 10:00:00+00	2026-01-19 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	قموصتنا	f	f	f	\N
aedd74c7-8e9a-4a53-8ddd-8f1944a27758	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-01-31	2026-01-31 07:08:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
aaa6dce4-2286-41d2-856f-e04efdb960e5	8547bd33-4c1f-4939-a460-f42beec6d360	2026-01-31	2026-01-31 07:08:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9e357e73-5f9b-49ce-8680-13a0652d91d2	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-01-31	2026-01-31 07:14:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8c9e43bd-32b1-46f0-a324-ed3f8f9210ef	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-01-31	2026-01-31 07:23:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b20f7fd3-19df-459f-86db-df872207ec70	6fbdf70e-9def-4819-ba61-1146768e063e	2026-01-31	2026-01-31 07:52:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d0c0bc42-4fc1-45d0-8f4d-49129a303ba8	dedc4608-da7e-4935-99c0-669c48d2a895	2026-01-31	2026-01-31 11:26:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2489a10b-9e8f-4b56-9091-90757cab781e	ba82ba38-633f-4633-849f-b2458ad2952f	2026-01-31	2026-01-31 13:24:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0100693f-ae72-4953-8457-e0c3ecc1901e	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-01	2026-02-01 07:40:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3ed8ac2e-020b-42b0-b0e5-228aed00c7e3	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-01	2026-02-01 07:40:48+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d95f2325-3f5f-416b-8cbc-7406c401886a	6fbdf70e-9def-4819-ba61-1146768e063e	2026-02-01	2026-02-01 07:40:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3d98b1d5-ab39-41c9-8830-bcee70a8b426	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-02-01	2026-02-01 07:41:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
163f8be8-6c42-4d5a-b413-5548db0b190d	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02-01	2026-02-01 08:21:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c2a26225-647f-4ce4-8b06-7b14297d6679	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-01	2026-02-01 11:17:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5117b3ae-5dea-4f0a-8bc5-b3b5bbf8f04d	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-01	2026-02-01 11:18:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7c1dfe7d-19ff-43cb-b5e4-ddcaf45db97f	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-02	2026-02-02 06:45:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
34f724f5-6687-406e-a418-8e06ea737dce	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-02	2026-02-02 06:59:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c296d969-c17f-4d71-b2da-02d50e27c8ff	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-02-02	2026-02-02 07:01:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e6e5b34a-cc35-4782-abf7-2c2b17fcb9b0	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-02	2026-02-02 07:17:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5310a5d4-0b9b-4465-94e5-099c9d2336f6	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-02	2026-02-02 09:28:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
31742156-ca30-41b6-ad0b-4f0392b974b4	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-02	2026-02-02 11:58:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f5ba0bff-0920-49b6-91ee-25e54070e94e	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-02	2026-02-02 07:03:00+00	2026-02-02 15:03:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
308d637e-4e79-44e4-9ab0-0594ccfb65a1	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-02-03	2026-02-03 07:34:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d3f5b397-4f51-4a8e-a34c-264e72025f1d	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-03	2026-02-03 07:34:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e3c27c4c-2280-4cac-82b2-a8ccab225f11	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-03	2026-02-03 07:35:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b89d00bf-af2e-4b32-ae90-d4836c1cef07	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-03	2026-02-03 07:37:16+00	2026-02-03 10:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ef026707-ef2d-41ee-a270-5bbee924110f	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-03	2026-02-03 07:44:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3e2df139-6d00-467c-bdf2-aff8f0f544a5	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-03	2026-02-03 09:44:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
00f5ff48-7415-4f38-ad8c-614ec175e323	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-03	2026-02-03 11:48:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
93e94970-d11c-4a57-906e-74b760a63a6f	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-04	2026-02-04 05:53:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0c7db586-0970-40cf-bb1c-b9f39401e9d8	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-02-04	2026-02-04 07:08:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
95204842-4023-4083-b25e-277bd6a8c29d	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-04	2026-02-04 07:44:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
828cd95d-f0ff-47de-9c65-d2ac383dac4e	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-04	2026-02-04 07:46:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3dc413e7-64ec-4703-a031-11beb343197b	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-04	2026-02-04 08:15:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4dba3f1d-d3be-41e6-8581-ffbcdf31a653	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-04	2026-02-04 21:05:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
06d5790b-7502-4b70-a9df-ed523e17b440	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-05	2026-02-05 07:01:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4a161f24-6198-4b25-a76e-54fc6a73894c	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-05	2026-02-05 07:13:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
85641fac-ccec-4e39-b646-debcf9735de3	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-05	2026-02-05 08:46:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6f17af5b-84df-4a95-a6e3-fa60983196bf	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-05	2026-02-05 10:39:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2546a341-be23-46bd-be94-c898c0fe3cbe	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-05	2026-02-05 10:47:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
075950f3-d5aa-4282-b881-6c6833e104c2	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-06	2026-02-06 06:16:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3e70d71a-e030-4e7d-8f32-df2b7bb66eb8	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-06	2026-02-06 07:28:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
251add56-2058-4196-928d-2252b6d4667a	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-06	2026-02-06 09:19:00+00	2026-02-06 15:56:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e3554529-eba0-43ab-afd5-84346616ead7	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-06	2026-02-06 09:41:29+00	2026-02-06 10:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
97fe1677-d63e-4692-954f-a76d7507ce48	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-06	2026-02-06 10:11:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c2a5caac-ff91-4b69-b052-9f5a43e8f293	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02-06	2026-02-06 08:00:00+00	2026-02-06 20:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d0ea03a0-5b7b-435d-983a-e68b9cf922f7	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-07	2026-02-07 06:59:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d82bc0a5-f0e1-4b21-b642-de381c25dc4a	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-07	2026-02-07 07:17:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8b4506a0-3772-4ace-be34-ff4791c621bb	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-07	2026-02-07 08:38:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7675b452-2518-48be-9300-5e436af8a053	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02-07	2026-02-07 09:16:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a54bf0f9-aa64-4a57-a428-05f709b8f4c5	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-07	2026-02-07 10:29:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
612de391-6df0-46aa-a382-db1704393c7d	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-07	2026-02-07 11:23:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d8100301-8d56-4b61-b605-335d4ca2e34a	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-07	2026-02-07 14:51:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b614c094-9d94-407d-9f51-b4c07fd94632	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-08	2026-02-08 06:59:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
de20bd11-0ce4-4d6e-a72f-d23c8848affc	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-08	2026-02-08 07:07:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
66faf26b-75af-4769-b749-baaba4cb72d4	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-08	2026-02-08 07:23:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e4aa71dd-0b21-4e5a-b520-f3082fcc9175	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-08	2026-02-08 07:27:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b8867cb7-8df9-4dca-9e1a-c2d27711ceae	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-08	2026-02-08 09:01:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c725dd56-510a-41ef-8dbc-81436a04a916	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-08	2026-02-08 10:13:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8d822e69-e090-48ff-a1e0-67b5569aaea1	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-08	2026-02-08 12:08:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1a92757b-256d-4c68-8ab3-1c679a9dca21	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-09	2026-02-09 07:11:26+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
94379fe1-8f79-4b96-b129-0010f2f25045	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-09	2026-02-09 07:11:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
10cfd0f4-65ea-4760-b621-bdcf3de70f7f	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-09	2026-02-09 07:16:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d188b8b8-b1c9-403f-a435-a2dcaf62e663	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-09	2026-02-09 07:31:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c318b8a3-201f-4d9b-b9d0-85ca8fe5bf22	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-09	2026-02-09 08:59:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
29d89b8e-8d38-4bb8-b589-990def8eb526	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-09	2026-02-09 11:40:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c5a5ab85-d1e3-4990-a572-b8b36791c7a9	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-09	2026-02-09 14:02:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d78594ac-9266-432c-8318-b7e5ba0c4eb6	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-10	2026-02-10 05:37:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a42592d6-e98b-4658-b9fd-ee7fb7c773b1	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-10	2026-02-10 07:04:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
980e8c5f-b4cb-4ff3-bf92-9ba332ce273c	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-10	2026-02-10 07:25:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a5522f7e-30f0-4c60-bb6c-9499a5454f8d	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-10	2026-02-10 07:27:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e8fa440d-0358-40e5-8778-5a1031fb3334	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-10	2026-02-10 08:57:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3e810665-1cf0-4fd6-a83b-dfb007421eed	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-10	2026-02-10 11:44:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ae63049c-b774-421b-b958-44d744d00e99	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-10	2026-02-10 10:00:00+00	2026-02-10 10:00:00+00	mission	\N	2026-03-27 08:48:30.747484+00	t	admin	سفر	f	f	f	\N
32db07ec-71c0-4f8d-818d-333011d73b38	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-11	2026-02-11 07:06:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
bdd54a80-a4cc-41f8-959d-a571da520fe1	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-11	2026-02-11 07:13:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
96305e17-889a-4226-9678-3be50620b34e	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-11	2026-02-11 07:21:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a7a9cb56-a27b-4157-8f6e-6c1870180722	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-11	2026-02-11 08:50:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ba91390d-1cce-41fd-841c-3e67330e0f60	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-11	2026-02-11 09:38:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
01992931-0df0-4d82-8ec1-e50633223ed9	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-11	2026-02-11 10:33:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4a7d9c48-29b5-429e-b36d-3838f90e748a	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-12	2026-02-12 07:20:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b14a4c51-2dd3-454f-ae57-3f39f2594457	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-12	2026-02-12 07:22:03+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0707c791-2ab2-47c3-bf6a-9c217286142e	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-12	2026-02-12 07:28:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9ba50006-547a-42ff-a1cd-00011b2e757b	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-12	2026-02-12 07:32:00+00	2026-02-12 19:32:00+00	present	\N	2026-03-27 08:48:30.747484+00	t	admin	مشي مرضي	f	f	f	\N
d9455a49-93fd-4475-a294-75b9907a1193	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-12	2026-02-12 07:58:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f6796ec6-3855-4cbb-938b-01e7958666f9	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-12	2026-02-12 10:24:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8c65da5c-b3a2-4770-902b-3cf256fb8888	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-12	2026-02-12 07:27:00+00	2026-02-12 15:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cba7eee1-1803-463d-bbeb-28656811e4d0	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-13	2026-02-13 05:53:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8a053f46-5ab5-4e0f-b892-75f17d3fa6f2	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-13	2026-02-13 09:20:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
05232449-4529-43e2-81a9-69b9ae93e8c2	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-13	2026-02-13 09:00:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b5c3bba2-e882-4c67-906a-c5cdedbe2904	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-13	2026-02-13 10:59:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6b3e0f80-3eef-4b00-abb1-8ee87c88676b	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-13	2026-02-13 07:05:00+00	2026-02-13 15:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0ce7394b-f650-41a4-af16-b962ccd95d56	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-14	2026-02-14 06:59:00+00	2026-02-14 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
864e0eb6-dde4-4088-b70e-462b37c26ce5	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-14	2026-02-14 07:11:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
75e1544a-32e4-42c4-a683-8ecba0a916d7	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-14	2026-02-14 07:11:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f5cd9a4e-7c54-41d1-b1fd-089de2484429	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-14	2026-02-14 07:21:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1619cbbc-a286-4ea7-bcc4-156c96b8626a	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-14	2026-02-14 07:46:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
662b40c7-ca6c-4398-ba78-838db3620e19	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-14	2026-02-14 10:23:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
35c4f95c-f3e4-41e6-9cfa-2974338b2af3	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-15	2026-02-15 10:00:00+00	2026-02-15 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	تعبااااان	f	f	f	\N
ebf7188c-eaca-4cad-bf87-a7e55e8ddfca	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-15	2026-02-15 07:13:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
96d63a85-9b65-4955-ad9a-756de345bcfe	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-15	2026-02-15 07:14:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9ab40bd7-71fe-4903-87d3-f42f1a03c94d	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-15	2026-02-15 07:22:48+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dcee7c6f-31d5-4743-a5ed-47ad913a43dd	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-15	2026-02-15 07:25:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ec793fe6-f47d-4ca8-bd63-526e8ec31d5a	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-15	2026-02-15 07:30:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a4a7530f-2d57-408d-a738-7b0b51e84215	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-15	2026-02-15 12:37:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0fe95c0d-a96b-472d-8d86-643ca203f4d3	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-16	2026-02-16 06:27:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
39e9db68-e335-46fd-801f-24df12d7ff31	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-16	2026-02-16 07:08:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
14c5c7ca-0565-42b8-8dc5-bc234a430aca	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-16	2026-02-16 07:28:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
16807aca-f710-4ee1-aa64-6d0dfa528369	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-16	2026-02-16 07:39:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5bbee022-ca56-424f-a39a-fde29b91c642	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-16	2026-02-16 11:33:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
adc03823-4d51-4c8e-a805-73b534cf1d46	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-16	2026-02-16 13:44:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6d2e8015-4b46-4f33-961a-6726ca07b1dd	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-16	2026-02-16 14:33:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
eb2a5543-80d7-4d20-b398-08a7d25e9798	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-17	2026-02-17 07:17:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dade94d4-94df-465c-a786-e342c4ad4bc3	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-17	2026-02-17 07:17:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a81803ba-76bb-445d-abe9-85dbbc5f43f2	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-17	2026-02-17 07:24:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
17b0d050-a763-41e1-9f44-72ba17f58600	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-17	2026-02-17 07:29:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4cd795d2-0bed-4ea1-ac4d-459ee8a57ecc	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-17	2026-02-17 09:20:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
14d2416a-aef2-4230-9514-e06ea8f82eee	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-17	2026-02-17 12:36:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
357597dc-b0ac-461d-a628-97d5776b5451	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-18	2026-02-18 07:34:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7d3e0354-2c24-4c98-bd6c-eee335bc1e4e	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-18	2026-02-18 07:34:00+00	2026-02-18 15:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3988be20-c2c5-425b-8f4d-cfa388b5c3b8	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-18	2026-02-18 07:34:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b24984ee-f1d1-4aa1-a5b4-304ec43f46fc	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-18	2026-02-18 07:34:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
df43063f-60bf-4bcd-b256-1fa11fe35678	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-18	2026-02-18 08:55:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ccbf1020-e9b1-47eb-a048-7ca0379d24fd	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-18	2026-02-18 11:02:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0792c6cb-f532-4a58-aa6a-8b172177c3b5	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-18	2026-02-18 12:12:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3e43678a-e06b-4c9a-82f6-9993c940caa4	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-19	2026-02-19 07:26:33+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f180a2a8-4bcf-4587-8f37-9d0c2030aeee	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-19	2026-02-19 07:26:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c4657fef-43e1-48c9-af4a-f28f5fba75c5	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-19	2026-02-19 07:27:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3ea5808e-2666-46a4-9ae1-9ecf90a149e4	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-19	2026-02-19 08:31:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e2a23f2f-e5cc-4554-b0b0-9563668c0a41	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-11	2026-02-11 10:00:00+00	2026-02-11 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	اجازة	f	f	f	\N
1a42b4ab-913b-40b3-ac87-533713ba05e2	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-13	2026-02-13 10:00:00+00	2026-02-13 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	اجازة	f	f	f	\N
84fe24a1-af56-41bc-b1d0-b5749ea70917	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-19	2026-02-19 10:30:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b91964b1-da27-4dec-a515-1fb78509808c	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-19	2026-02-19 11:44:31+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2154fd23-9846-452f-9e9e-7a65000826a2	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-20	2026-02-20 07:19:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
42754062-d088-4ad4-87f1-9d6a04d014dd	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-20	2026-02-20 07:48:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3ddfca2b-3aaa-4f55-9ced-5e036e0351d6	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-20	2026-02-20 08:26:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
644294c0-2991-41d5-90b2-d6f80b0236f2	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-20	2026-02-20 11:07:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
acdf190e-4870-4495-bd23-16f9c6109ccb	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-21	2026-02-21 07:01:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
daa348a9-1802-4206-9c40-1bc663c37c63	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-21	2026-02-21 07:13:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b901861e-8efa-41a5-a285-6dc744c6a094	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-21	2026-02-21 07:24:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6dec4f2a-77dc-4623-aff4-0b190399f588	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-21	2026-02-21 09:59:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f620d0ea-0e0d-4414-be63-bb6d9bff7c29	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-21	2026-02-21 10:39:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7d802174-a36f-4376-9587-8f8c6fcb3f78	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-21	2026-02-21 10:51:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ba6d89e6-9d19-4af6-bd38-99f513d25d06	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-22	2026-02-22 07:32:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d4b72210-4037-40f5-a322-982b9d99343e	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-22	2026-02-22 07:33:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a1d37787-7298-4011-aeee-2501f62a0980	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-22	2026-02-22 07:33:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2cb3a4c1-0ef0-4c52-a487-c5f22b4769d3	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-22	2026-02-22 09:43:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0cba0324-1beb-4078-844e-d2154436d568	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-22	2026-02-22 11:49:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f105e745-df64-407c-93e5-2949063a2378	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-22	2026-02-22 12:12:22+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f07e4469-51d6-48d1-ac55-e367f744d19b	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-22	2026-02-22 10:00:00+00	2026-02-22 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	تعبان	f	f	f	\N
4c9378db-ee4d-45b8-ac49-f8e2c89ed2c6	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-23	2026-02-23 07:00:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
960f348e-d4fd-483e-8485-d2e5bd9d8994	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-23	2026-02-23 07:00:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dd89c5a8-8062-4454-a718-8170add52ac6	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-23	2026-02-23 07:33:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
09e2b70e-db82-405b-bd62-06cf62e61489	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-23	2026-02-23 07:42:09+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
08ca42b4-3e5e-41bd-81a0-41fe55e02290	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-23	2026-02-23 09:42:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
542e8188-57ec-4109-84a2-9f6cc0c4e36e	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-23	2026-02-23 13:11:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8ec13f7f-0115-4d54-93db-3e9781b72b2e	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-24	2026-02-24 07:01:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5f2b002b-1101-463f-bb02-0f4d83641b5c	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-24	2026-02-24 07:16:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
40e8dc7f-9184-46bd-8821-2dca71247043	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-24	2026-02-24 07:18:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0a967ad9-e2c8-4fe9-a351-2a6b4f0813bc	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02-24	2026-02-24 07:38:25+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3b88f0ed-ec84-4f07-9a17-7226c23db7eb	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-24	2026-02-24 09:15:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1e46909c-2fe6-45a2-bd57-9ac87ecd02ef	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02-24	2026-02-24 09:21:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5c9628e1-b9b0-424f-be47-11180bb74e29	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-24	2026-02-24 13:02:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3aca3a8a-51f5-4f25-a1e7-5f1db86aef37	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-25	2026-02-25 07:00:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6875f27a-858d-47f7-8183-23cb4d084b3e	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-25	2026-02-25 07:00:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
bea8b05e-9dc4-4aa6-bec9-794439dd7f7f	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-25	2026-02-25 08:14:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d6b622c6-167f-4396-9e4a-affb06f9099d	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02-25	2026-02-25 10:24:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
38751401-1b89-43a6-a907-6c6c2ba55ec8	6fbdf70e-9def-4819-ba61-1146768e063e	2026-02-25	2026-02-25 10:33:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7d94a67b-eefa-46ba-b61c-e54a96ff541e	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-25	2026-02-25 11:50:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
22bfae7e-8595-4cf6-8641-cb8ee9e643d5	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-25	2026-02-25 11:50:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d73c3ad4-a4cb-4551-92cd-af36e20b05f4	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-26	2026-02-26 07:04:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8117b5ef-a838-472a-8d1a-8c2d4db6beaa	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-26	2026-02-26 07:16:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8f826c06-f6b1-4dbc-8b56-bf0ada8fc2b1	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-26	2026-02-26 07:24:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8e559c30-d5c6-44c0-ba49-0f42a2b500f3	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02-26	2026-02-26 09:47:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6879f763-2889-45dc-937f-c08cc1b48e44	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-26	2026-02-26 09:58:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4fa55256-f2fe-41fa-aee9-7b6de29cba12	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-26	2026-02-26 12:28:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
bb1ab914-b77b-4276-9191-cf9847a331a5	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-26	2026-02-26 11:47:00+00	2026-02-26 18:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5d773236-0a37-4edc-8067-e0d06474ad34	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-27	2026-02-27 08:33:40+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6be6f92c-8722-4a2d-ac4c-2c5c90f03215	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02-27	2026-02-27 10:15:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5abbe1ca-baf3-4279-bbec-d4f91ff884f0	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-27	2026-02-27 10:18:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
66576cb1-07b3-4cbd-8034-61abafc3aa28	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-27	2026-02-27 11:59:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b95a12cc-fd95-4935-a758-87c300e9add6	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-27	2026-02-27 12:22:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
79754851-7e9f-400f-8eca-ac4ba75adbd7	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-20	2026-02-20 10:00:00+00	2026-02-20 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	الجمعة	f	f	f	\N
b3ee2da7-a8a4-4068-aa83-717280a2e485	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-27	2026-02-27 10:00:00+00	2026-02-27 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	الجمعة	f	f	f	\N
63206128-3bdf-4a3f-a3bc-9bb65476fdc3	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-14	2026-02-14 10:00:00+00	2026-02-14 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	مرضي	f	f	f	\N
ce2c2a00-a84d-4de0-adc2-3b13e3f78b83	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-17	2026-02-17 10:00:00+00	2026-02-17 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	مرضي	f	f	f	\N
eba041fa-4bfc-448a-a1de-2f381fcf608a	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-20	2026-02-20 10:00:00+00	2026-02-20 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	مرضي	f	f	f	\N
445ccca3-54fc-4bc2-816f-9f5726ab3935	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02-23	2026-02-23 10:00:00+00	2026-02-23 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	مرضي	f	f	f	\N
56453ea5-5c21-4295-87e6-8da4c78ecd5d	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-19	2026-02-19 10:00:00+00	2026-02-19 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	اجازة	f	f	f	\N
7aba41b2-5452-4c8d-b822-5cefbd0f0d7c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-24	2026-02-24 10:00:00+00	2026-02-24 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	اجازة	f	f	f	\N
4dc76131-24d9-47f8-8d51-8908666eaea3	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-25	2026-02-25 09:00:00+00	2026-02-25 19:30:00+00	present	\N	2026-03-27 08:48:30.747484+00	t	admin	مبصمش	f	f	f	\N
1ac86c90-c3da-4ccd-a35c-bc5e65c870ff	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-20	2026-02-20 10:00:00+00	2026-02-20 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	جمعة	f	f	f	\N
d2177ea3-f81c-4587-abd2-3a6b20a5ff2a	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-27	2026-02-27 10:00:00+00	2026-02-27 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	جمعة	f	f	f	\N
42876071-1124-441b-ad78-f7ec291007f3	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-13	2026-02-13 10:00:00+00	2026-02-13 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	جمعة	f	f	f	\N
dc7d0e14-18e1-4ce1-8c19-c09deb58f97e	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02-28	2026-02-28 07:26:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
28a80d77-3c45-4e64-b8c4-6a2ed2a0fc14	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02-28	2026-02-28 07:27:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8964ec57-648a-479e-a21c-b9b1492b8656	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02-28	2026-02-28 07:27:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d5343304-984c-45e7-9b71-79574a864c1c	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02-28	2026-02-28 10:23:38+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1f494683-59c0-496c-9c98-9b9357138fbf	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02-28	2026-02-28 10:47:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3ae8f1c0-aa40-44cd-95db-89fe19a245e7	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02-28	2026-02-28 11:20:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7bfb1cc4-76ec-45b8-969e-60ca3aa63040	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-01	2026-03-01 07:23:10+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
71941540-4707-47de-be2a-53aac75c58f6	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-01	2026-03-01 07:23:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d0d9fa77-eab9-4f0e-adfa-8ccf0b215386	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-01	2026-03-01 07:25:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
092b1151-840b-4be5-94a5-d90e096ecfc5	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-01	2026-03-01 08:18:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9203b79f-b0cd-4cb7-8838-dc74e0477d12	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-01	2026-03-01 11:32:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cd2427bd-44c9-4b70-be24-d2439db37992	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-01	2026-03-01 11:55:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
33518df2-cf68-45ce-bda3-202704140931	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-01	2026-03-01 15:33:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
bc613ad1-7a9b-4cd8-a8ad-51396a6b9f14	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-01	2026-03-01 22:19:57+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
646d2d02-bfc4-4007-a965-be9b51f8727e	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-02	2026-03-02 06:50:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3d8d385b-ef4f-4305-b9af-9ac6ac9bd22c	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-02	2026-03-02 07:18:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b1df184d-dd44-4262-b7d5-2e8f718743c3	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-02	2026-03-02 07:24:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0fde9974-86df-4b8b-a2c1-2db0b6bbfbbc	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-02	2026-03-02 12:14:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e8ef9e6a-081b-480f-9b65-c8f83bf0a09f	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-02	2026-03-02 12:26:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d0298e99-4888-41cb-a412-98f70655ee99	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-02	2026-03-02 14:14:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0578f413-4d44-4211-a228-8e51bfae84c2	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-03	2026-03-03 07:15:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
05348a6c-ea75-4635-9683-cdb91285e4ea	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-03	2026-03-03 07:46:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
23301022-f8fb-4b48-b6b6-f68db28763b3	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-03	2026-03-03 10:04:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d14b85e7-8b31-496a-85f1-45e3346154f5	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-03	2026-03-03 22:28:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5039f337-a708-4ff2-8cb9-e78405f6a6fa	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-04	2026-03-04 07:39:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
986f0cc8-906e-4753-b0ea-5f32f95b981e	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-04	2026-03-04 07:39:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3ba203c0-c3ea-413b-9872-5a458e8ada5e	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-04	2026-03-04 07:40:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7efad6a6-2795-41bf-8a8b-4882222576b7	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-04	2026-03-04 08:17:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3e99bb69-0be6-441a-a58f-ebae5b14ccab	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-04	2026-03-04 09:16:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
22bd7ebe-9ed6-4548-b27d-b39d2ac32e23	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-04	2026-03-04 11:31:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dba2264d-8e6f-4730-b483-f58510d9f21c	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-04	2026-03-04 12:10:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6483d16d-f528-4791-9cca-c82d2650a712	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-05	2026-03-05 07:18:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7a5e642a-e293-42bf-9114-717d5c40bd24	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-05	2026-03-05 07:18:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
dfcaaf7c-762e-47e1-af18-0b072aa5518d	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-05	2026-03-05 07:27:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b85d1a18-2abf-4544-96c6-1c3470818c45	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-05	2026-03-05 09:37:27+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b8db3287-9ef3-4e90-abb3-e503e8031a01	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-05	2026-03-05 10:20:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a963ef4e-2fcb-4bdc-95e0-25a0df18e94c	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-05	2026-03-05 12:28:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9d7a4e02-01b4-4c93-af32-8277332776e4	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-05	2026-03-05 13:26:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5193cd5d-353c-4d98-8776-803c94ce0aca	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-06	2026-03-06 07:03:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b26d3fda-87b9-4539-b5a6-c43d649fa8f7	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-06	2026-03-06 07:03:59+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f58ea69d-cf2f-46fb-9572-577840d800a0	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-06	2026-03-06 07:55:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
7f0752b8-3b47-4aac-ae5b-12819130ab74	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-06	2026-03-06 09:23:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
005b9e96-6fed-4aaf-88df-21d2206c16f2	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-06	2026-03-06 11:00:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cc9d2f16-6a1a-4607-a0bc-b1e62f9ad169	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-07	2026-03-07 07:18:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1c4238ee-6886-461f-be5c-028f33d3d281	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-07	2026-03-07 07:19:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e16e1415-eb14-4d8b-8353-5f294ca5a0f2	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-07	2026-03-07 07:19:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
356d1022-ba78-4e24-9ff6-82a96cc6fac3	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-07	2026-03-07 09:26:00+00	2026-03-07 15:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	t	admin	هرب	f	f	f	\N
6474b30e-34a6-475f-883c-089bf5699c40	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-07	2026-03-07 10:19:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f900e6a7-b80f-4c05-8d1f-e0f075a64c2f	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-08	2026-03-08 07:27:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e645e506-bc06-4484-9812-f187589e08ec	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-08	2026-03-08 07:27:24+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e283a40b-cdd1-4130-8f76-a1d4e09a7aca	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-08	2026-03-08 07:27:41+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
16533bc7-51aa-4036-bb3d-3f3631a9373f	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-08	2026-03-08 08:31:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
602cfe08-14ff-4308-868e-53aa61cbd56c	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-08	2026-03-08 09:56:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
110b4380-3e7a-431d-ad9e-328a3705db74	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-08	2026-03-08 11:04:54+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b921c2d8-1137-4857-85a5-6ba14dffdeae	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-09	2026-03-09 07:23:23+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9de75798-7c9b-4afa-bb4e-0f0b123665e2	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-09	2026-03-09 07:27:28+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8a3081f5-140e-48ef-9088-53c810bc6990	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-09	2026-03-09 07:38:39+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8adc2659-4f2d-47e7-aba2-0d280b1debe7	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-09	2026-03-09 09:41:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6ccceeb6-4a61-4b0b-9740-83af57473717	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-09	2026-03-09 10:03:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
09ba99ee-228b-458a-8982-3418e7d86102	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-09	2026-03-09 12:20:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8931a810-897e-49d5-8762-78b94738b1f7	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-09	2026-03-09 13:16:14+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a905a4bc-8854-4cc9-8bf4-58703af91b27	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-10	2026-03-10 08:08:00+00	2026-03-10 16:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
0c8a67a6-f75d-4788-ba12-fee61c68aa11	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-10	2026-03-10 07:08:00+00	2026-03-10 15:35:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
70afc7f3-15a0-407c-b6cf-b08d0f5fa5c9	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-10	2026-03-10 08:11:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ef511742-0d3f-46c6-8e23-04710e896c98	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-10	2026-03-10 10:26:09+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
207e91f2-8b5d-410c-af8a-b90420182842	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-10	2026-03-10 10:34:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2476c4cc-8c95-44e1-bead-70923f779ac6	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-10	2026-03-10 12:03:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ff26b9c3-9782-41be-8eb0-e02fcb423c0e	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-11	2026-03-11 07:54:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
035fd1c9-825e-490f-9a59-c3d07fcfe4e6	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-11	2026-03-11 07:54:55+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
08a7ce8e-bafd-4c0c-bcc8-3b40d4721105	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-11	2026-03-11 08:09:48+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
6471b629-be6b-4355-bb2a-6ff8229a22bb	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-11	2026-03-11 11:29:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0192a9fc-a10e-4dd5-a5a0-7429d4cb60a1	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-11	2026-03-11 12:48:58+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3dd6e87c-f200-461b-8434-5a913924dcfd	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-11	2026-03-11 22:32:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4ff82320-08db-4d9f-a572-870d8c627f49	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-12	2026-03-12 07:52:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
ced17586-7a8d-46c9-a94e-630ecfd76ba8	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-12	2026-03-12 07:52:35+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5bd54327-4136-4558-b8f3-7d091319d6e1	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-12	2026-03-12 07:59:02+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e272f7c6-a042-416b-a33a-60a1c3091457	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-12	2026-03-12 07:09:00+00	2026-03-12 15:37:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
487bde9f-e992-4c58-a8ca-0d7362de01d2	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-12	2026-03-12 11:10:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c53cf372-4057-42a6-8ac4-d85bc5e33e13	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-12	2026-03-12 12:59:44+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cd724a0a-e8e8-4ca6-a7dc-3b174ad549fa	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-13	2026-03-13 08:08:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
89eb3d95-88b5-43be-bc23-1e3479f1b380	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-13	2026-03-13 08:21:50+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
25452320-c6b8-4d1e-a81d-153eced8e883	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-13	2026-03-13 08:53:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e02f94b3-db64-40cc-ba08-aeb8fc7eb27f	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-13	2026-03-13 10:57:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b36e2771-c258-401a-873e-22b9e079e7ef	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-13	2026-03-13 11:25:46+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d5474952-675a-4fce-94a6-adf12332b79f	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-14	2026-03-14 05:19:45+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
defaaab8-181f-4c55-9c4b-f1a27068622a	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-14	2026-03-14 07:21:17+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2f491c7c-b522-40df-afc8-b8b526c8dadf	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-14	2026-03-14 07:32:12+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e9d49d45-8510-4de6-8a06-8e93bcea5f11	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-03	2026-03-03 10:00:00+00	2026-03-03 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	اجازة	f	f	f	\N
edeca2bb-c6bd-4e71-8d26-bc9a5ee12876	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-12	2026-03-12 10:00:00+00	2026-03-12 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
45e232d5-7242-4803-b0b2-a37398ab6eef	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-06	2026-03-06 10:00:00+00	2026-03-06 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
dc9edfa1-b94a-442b-a7c4-d6f6f2c694d6	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-13	2026-03-13 10:00:00+00	2026-03-13 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
7c7c85f7-559e-49e1-9cd2-3f36e7cc8476	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-14	2026-03-14 10:41:05+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
bc01ab43-780b-4403-8ef1-61b5e2b68d22	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-14	2026-03-14 11:47:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d8321b0f-9ad6-40da-96c8-2e321670967a	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-14	2026-03-14 11:55:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
13570ab8-bb7c-46bb-a737-f11c6011fb88	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-03	2026-03-03 10:00:00+00	2026-03-03 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
7d8fc32c-83a4-467d-9cf4-7ed8b18cfff0	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-05	2026-03-05 11:00:00+00	2026-03-05 19:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
157313d3-7224-4d84-9238-e125a447b67f	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-06	2026-03-06 10:00:00+00	2026-03-06 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
68290bd1-d6af-4663-bfc4-c4c9ce1f508f	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-07	2026-03-07 10:00:00+00	2026-03-07 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
17cc8271-8e8a-47ff-b259-caba0d1253f4	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-08	2026-03-08 10:00:00+00	2026-03-08 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
e6a18dba-4f60-497a-9353-d416361b8484	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-14	2026-03-15 00:26:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
20debb92-c796-4da1-8574-f36a337899c6	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-15	2026-03-15 07:55:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
0cac080c-7f55-4280-9d3c-d1def2393b73	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-15	2026-03-15 07:15:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
1f7b23ee-c606-4bc8-bec1-757caea67906	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-15	2026-03-15 07:55:43+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
37783db4-438e-4fa0-9542-b3e914cc319e	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03-15	2026-03-15 07:05:00+00	2026-03-15 15:36:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
db571bb0-54f1-4b26-863d-831b23714a85	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-15	2026-03-15 10:33:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b28377a5-e415-42ec-ba75-cd3a99040f88	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-15	2026-03-15 11:00:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5e6a577a-2634-4e04-9a38-c588a0dfc2ac	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-15	2026-03-15 11:57:42+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
2f3f080f-67f3-41ec-95b2-72f7afd816d8	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-16	2026-03-16 07:19:34+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a40ea40e-e6c7-47b4-8da5-0f96c5b4593f	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-16	2026-03-16 07:34:18+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9a9454d2-671a-4deb-867b-c43feb10354a	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03-16	2026-03-16 07:28:00+00	2026-03-16 15:22:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
4259b3cf-94b9-4ec6-ac19-9b342800fa11	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-15	2026-03-15 10:00:00+00	2026-03-15 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
f418db6c-9e4a-4be6-820c-66ca15505e81	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-16	2026-03-16 07:10:20+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cfc7e841-078c-4683-bab9-e0efbf8a34f8	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-16	2026-03-16 10:43:11+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
47fe4201-e629-4e29-b171-c5e0c4f105b5	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-16	2026-03-16 12:01:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
808c35b6-b025-4edd-82f7-b643d111553b	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-16	2026-03-16 12:27:04+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a41c8c6d-fe9f-445f-ab7c-e0b9c2164b12	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03-17	2026-03-17 07:17:00+00	2026-03-17 15:34:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
faaf2f23-aee5-4afa-b008-7409543a6fb0	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-17	2026-03-17 07:06:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
eb844246-7470-468e-9e1e-21a4a1b7ec1e	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-17	2026-03-17 08:06:21+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
d21839d6-e0d4-4303-bf80-6685b43d3f05	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-17	2026-03-17 09:48:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f598a7c8-bc5b-47c2-aa4b-17a6e90e717f	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-17	2026-03-17 10:23:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e0a58785-3139-48fe-ba06-b8c811d0ba45	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-17	2026-03-17 11:18:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
c311d31d-d839-414d-a7a1-c95416fa64b6	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-17	2026-03-17 23:46:07+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a6880a43-54cd-42c0-bf01-aa8464dc904a	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-18	2026-03-18 07:00:00+00	2026-03-18 15:30:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f9c06d24-ad88-4c70-9dfa-bf551bc6d30b	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03-18	2026-03-18 07:00:00+00	2026-03-18 15:30:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
db821a8e-e809-4418-9175-d5c8ee5c9820	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-18	2026-03-18 07:00:00+00	2026-03-18 19:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
15cb80dd-cd20-476e-aec5-0fa8f56f8013	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-18	2026-03-18 08:38:00+00	2026-03-18 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8d255cba-85fe-4e33-9acc-0171a5bc45ed	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-18	2026-03-18 09:42:00+00	2026-03-18 19:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5a098aa7-ed73-44dc-98fb-1a9b47de7315	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-02	2026-03-02 10:00:00+00	2026-03-02 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
88991766-6398-4f39-9f0f-fc75a5daffcd	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-18	2026-03-18 10:00:00+00	2026-03-18 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
5c39415a-ab4e-4b18-b5f7-9a023c382e1b	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-15	2026-03-15 10:00:00+00	2026-03-15 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
9cc4b8d5-8cde-43b2-9fc9-29abe4dff160	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-16	2026-03-16 10:00:00+00	2026-03-16 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
294b9191-8a34-4532-a212-d0fb8fb778bc	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-04	2026-03-04 10:00:00+00	2026-03-04 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
0e2ccf9a-e423-4b40-9c36-dd2a89611c34	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-18	2026-03-18 10:11:00+00	2026-03-18 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f9f052ed-9ca0-4021-aaa7-d6d4d205d791	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-18	2026-03-18 10:26:06+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9dcd41a5-ac96-4b30-8cd7-e4e569e15b91	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-03	2026-03-03 10:00:00+00	2026-03-03 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
88db2264-ef7c-48a8-a38c-da0085c72518	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-07	2026-03-07 10:00:00+00	2026-03-07 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
22ab29c2-a695-4585-868f-8099622b77e5	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-13	2026-03-13 10:00:00+00	2026-03-13 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
3b48ae77-2b65-4441-8d80-3d95c0292f49	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-08	2026-03-08 10:00:00+00	2026-03-08 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
04a69057-2f87-4d73-bf56-f7e458865115	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-06	2026-03-06 10:00:00+00	2026-03-06 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
8414d13d-3783-4695-a13d-f9db20d1f469	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-13	2026-03-13 10:00:00+00	2026-03-13 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
6f9decbc-e13f-4f48-a4b0-8138aa7c6400	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03-19	2026-03-19 07:12:00+00	2026-03-19 15:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
af015e9c-c1fb-48b4-9563-8758a4467372	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-19	2026-03-19 07:13:00+00	2026-03-19 15:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
33928134-26df-4a79-b807-2362842778c3	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-19	2026-03-19 07:20:00+00	2026-03-19 19:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
e47d0fad-34d6-4c6a-b39c-b28ecd8a89a6	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03-19	2026-03-19 09:18:00+00	2026-03-19 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
5a50496d-ec37-48da-a588-a1b979c5bdf5	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-19	2026-03-19 10:04:00+00	2026-03-19 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3bb1efa8-38d5-44d8-96d3-1f26ad0daeec	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-19	2026-03-19 11:09:00+00	2026-03-19 15:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9aacce45-fcf0-4e56-92db-5e5433bbf6cf	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-19	2026-03-19 11:21:00+00	2026-03-19 21:00:00+00	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
b6419d73-9e57-4bc5-8be1-d12c57161924	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-19	2026-03-19 10:00:00+00	2026-03-19 10:00:00+00	leave	\N	2026-03-27 08:48:30.747484+00	t	admin	 	f	f	f	\N
05e0a763-d439-48ef-9f29-cc7d18dcb1fb	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-20	2026-03-20 15:03:16+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
cce956c9-2675-4255-8ab0-61667c447746	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03-23	2026-03-23 07:05:19+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a763bfb2-260c-443e-910c-3b1beab655a0	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-23	2026-03-23 07:28:29+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
02720f68-a11c-4d85-bfb7-bf15ab81d4cc	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03-23	2026-03-23 07:42:13+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
a7bb6372-755c-4f3b-8c70-30deb77e9dd8	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03-23	2026-03-23 08:01:47+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
141bbd32-2654-4a4d-8a74-a938f7170074	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-23	2026-03-23 08:21:56+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
9f9688dd-f4dc-4953-8bf8-60087342a3b3	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-23	2026-03-23 17:14:36+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
8a8e74fa-acbe-459a-858d-20d105f602d6	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03-24	2026-03-24 07:36:52+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
03f4abfb-30db-4563-98f7-4dcf252836a8	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-24	2026-03-24 07:37:01+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
801dafd0-1a24-404c-8115-44e6aa5ef9c8	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-24	2026-03-24 07:37:15+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
f2e12fff-3593-4157-a320-1865f036f558	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03-24	2026-03-24 09:26:37+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
498e7754-fb30-4d52-b86b-87378374526f	6fbdf70e-9def-4819-ba61-1146768e063e	2026-03-24	2026-03-24 12:07:48+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
e5098029-59af-45d5-981b-530c581daaf2	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03-24	2026-03-24 14:08:30+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
3eb47a02-82b9-4e4b-bca9-fa3eecfd996f	6fbdf70e-9def-4819-ba61-1146768e063e	2026-03-25	2026-03-25 07:25:53+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
747acfd9-169b-45e9-add9-d522a066b307	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03-25	2026-03-25 07:26:00+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
698f2051-53a5-46c8-8c35-e360614a3fe2	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03-25	2026-03-25 07:26:49+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
54307869-328f-42aa-be45-ade976ca2370	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03-25	2026-03-25 07:39:51+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
81e4bbc2-70e7-4e39-882a-73e1ca7cc3c7	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03-25	2026-03-25 07:58:32+00	\N	present	\N	2026-03-27 08:48:30.747484+00	f	\N	\N	f	f	f	\N
\.


--
-- Data for Name: hr_audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_audit_log (id, action_type, entity_type, entity_id, performed_by, reason, details, created_at) FROM stdin;
\.


--
-- Data for Name: hr_employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_employees (id, user_id, emp_code, name, "position", monthly_salary, shift_schedule, hire_date, is_active, created_at, shift_id, max_lateness_before_overtime_cancellation, ignore_lateness) FROM stdin;
1c2e1861-ef74-46d8-9a77-ed741494a29a	\N	101	Belal	مشرف	6000.00	11 صباحاً الى 11 مساءً	2026-01-01	t	2026-03-27 05:47:42.800418+00	\N	30	f
ee53776b-70b3-4db1-9b2a-6ab75afe6d93	\N	105	ELCOCK	مشرف	6000.00	11 صباحاً الى 11 مساءً	2025-01-01	t	2026-03-27 05:47:42.800418+00	\N	30	f
ba82ba38-633f-4633-849f-b2458ad2952f	\N	102	Ahmed	مساعد	4500.00	9 صباحا الى 9 مساءً	2025-01-31	t	2026-03-27 05:47:42.800418+00	\N	30	f
dedc4608-da7e-4935-99c0-669c48d2a895	\N	104	Nada	محاسبة	3500.00	1 مساءً الى 9 مساءً	2025-01-31	t	2026-03-27 05:47:42.800418+00	\N	30	f
8547bd33-4c1f-4939-a460-f42beec6d360	\N	2	Ammar	محاسب	6000.00	9 صباحا الى 9 مساءً	2026-01-12	t	2026-03-27 05:47:42.800418+00	\N	30	f
6fcefb3d-7918-4118-9633-b74c21c0dd0f	\N	5	Ateef	سائق	6000.00	9 صباحا الى 9 مساءً	2026-02-08	t	2026-03-27 05:47:42.800418+00	\N	30	f
ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	\N	6	Habiba	مندوبة مبيعات	3000.00	9 صباحاً الى 5 مساءً	2026-02-02	t	2026-03-27 05:47:42.800418+00	\N	30	f
53b8dbd5-735b-4617-bd38-4a7084272fba	\N	7	Dalia	مندوبة مبيعات	3000.00	9 صباحاً الى 5 مساءً	2026-02-08	t	2026-03-27 05:47:42.800418+00	\N	30	f
925f7ec5-0f83-4508-8cda-d7c8174f2990	\N	3	Anas	عامل مناولات	3000.00	9 صباحا الى 9 مساءً	2024-03-18	t	2026-03-27 05:47:42.800418+00	\N	30	f
6fbdf70e-9def-4819-ba61-1146768e063e	\N	4	Abdullateef	مدير مخازن	6000.00	9 صباحاً الى 5 مساءً	\N	t	2026-03-27 05:47:42.800418+00	\N	30	f
\.


--
-- Data for Name: hr_payroll; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_payroll (id, employee_id, month, base_salary, working_days, absent_days, overtime_hours, overtime_pay, bonus, deductions, advances, drawer_variance, net_salary, status, notes, created_by, created_at, actual_working_days, vacation_days, total_hours, lateness_minutes, early_leave_minutes, missing_scan_minutes, lateness_deduction, bonus_days, bonus_payment, hourly_rate, daily_breakdown) FROM stdin;
f45b3e3d-ce8b-4130-9ccc-487d239d3afd	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-03	6000.00	20	6	32.49	624.81	0.00	0.00	3200.00	0.00	704.08	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	17	0	247.28	1148	0	0	851.28	0	0.00	19.2308	[{"date": "2026-03-01", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-01T17:33:59", "check_out": "2026-03-01T23:00:00", "work_hours": 5.43, "late_minutes": 393, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-02", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-02T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-03", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-04T00:28:00", "check_out": "2026-03-04T23:00:00", "work_hours": 22.53, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 10.53}, {"date": "2026-03-04", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-04T11:16:46", "check_out": "2026-03-04T23:00:00", "work_hours": 11.72, "late_minutes": 16, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-05", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-05T12:20:23", "check_out": "2026-03-05T23:00:00", "work_hours": 10.66, "late_minutes": 80, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-06", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-06T09:03:59", "check_out": "2026-03-06T23:00:00", "work_hours": 13.93, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 1.93}, {"date": "2026-03-07", "note": "[هرب]", "status": "present", "check_in": "2026-03-07T11:26:00", "check_out": "2026-03-07T17:00:00", "work_hours": 5.57, "late_minutes": 26, "early_minutes": 360, "overtime_hours": 0.0}, {"date": "2026-03-08", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-08T11:56:02", "check_out": "2026-03-08T23:00:00", "work_hours": 11.07, "late_minutes": 56, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-09", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-09T11:41:56", "check_out": "2026-03-09T23:00:00", "work_hours": 11.3, "late_minutes": 41, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-10", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-10T12:26:09", "check_out": "2026-03-10T23:00:00", "work_hours": 10.56, "late_minutes": 86, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-11", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-12T00:32:50", "check_out": "2026-03-12T23:00:00", "work_hours": 22.45, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 10.45}, {"date": "2026-03-12", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-12T09:59:02", "check_out": "2026-03-12T23:00:00", "work_hours": 13.02, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 1.02}, {"date": "2026-03-13", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-13T13:25:46", "check_out": "2026-03-13T23:00:00", "work_hours": 9.57, "late_minutes": 145, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-14", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-15T02:26:16", "check_out": "2026-03-15T23:00:00", "work_hours": 20.56, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 8.56}, {"date": "2026-03-15", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-15T12:33:15", "check_out": "2026-03-15T23:00:00", "work_hours": 10.45, "late_minutes": 93, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-16", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-16T12:43:11", "check_out": "2026-03-16T23:00:00", "work_hours": 10.28, "late_minutes": 103, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-17", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-17T12:23:06", "check_out": "2026-03-17T23:00:00", "work_hours": 10.62, "late_minutes": 83, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-18", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-18T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-19", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-19T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-24", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-24T11:26:37", "check_out": "2026-03-24T23:00:00", "work_hours": 11.56, "late_minutes": 26, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-25", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
2e606382-5ff4-4342-aabb-452c82412847	dedc4608-da7e-4935-99c0-669c48d2a895	2026-03	3500.00	18	8	1.33	22.38	0.00	0.00	1000.00	0.00	450.70	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	14	0	124.15	1018	0	0	638.30	0	0.00	16.8269	[{"date": "2026-03-01", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-01T13:55:18", "check_out": "2026-03-01T21:00:00", "work_hours": 7.08, "late_minutes": 55, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-02", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-02T14:26:27", "check_out": "2026-03-02T21:00:00", "work_hours": 6.56, "late_minutes": 86, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-03", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-03T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-04", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-04T14:10:42", "check_out": "2026-03-04T21:00:00", "work_hours": 6.82, "late_minutes": 70, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-05", "note": "[ ]", "status": "present", "check_in": "2026-03-05T13:00:00", "check_out": "2026-03-05T21:00:00", "work_hours": 8.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-06", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-06T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-07", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-07T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-08", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-08T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-09", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-10", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-11", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-12", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-12T14:59:44", "check_out": "2026-03-12T21:00:00", "work_hours": 6.0, "late_minutes": 119, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-13", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-13T12:57:56", "check_out": "2026-03-13T21:00:00", "work_hours": 8.03, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.03}, {"date": "2026-03-14", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-14T13:47:11", "check_out": "2026-03-14T21:00:00", "work_hours": 7.21, "late_minutes": 47, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-15", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-15T13:00:34", "check_out": "2026-03-15T21:00:00", "work_hours": 7.99, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-16", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-16T14:01:15", "check_out": "2026-03-16T21:00:00", "work_hours": 6.98, "late_minutes": 61, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-17", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-17T13:18:00", "check_out": "2026-03-17T21:00:00", "work_hours": 7.7, "late_minutes": 18, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-18", "note": "", "status": "present", "check_in": "2026-03-18T11:42:00", "check_out": "2026-03-18T21:00:00", "work_hours": 9.3, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 1.3}, {"date": "2026-03-19", "note": "", "status": "present", "check_in": "2026-03-19T13:09:00", "check_out": "2026-03-19T17:00:00", "work_hours": 3.85, "late_minutes": 0, "early_minutes": 240, "overtime_hours": 0.0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-23T19:14:36", "check_out": "2026-03-23T21:00:00", "work_hours": 1.76, "late_minutes": 374, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-24", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-24T16:08:30", "check_out": "2026-03-24T21:00:00", "work_hours": 4.86, "late_minutes": 188, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-25", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
ae015884-6124-48a1-b4e3-efb6addc0a6d	ba82ba38-633f-4633-849f-b2458ad2952f	2026-03	4500.00	20	6	0.00	0.00	0.00	0.00	535.00	0.00	0.00	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	16	0	168.93	4378	0	0	2104.81	0	0.00	14.4231	[{"date": "2026-03-01", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-01T13:32:43", "check_out": "2026-03-01T21:00:00", "work_hours": 7.45, "late_minutes": 272, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-02", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-02T14:14:06", "check_out": "2026-03-02T21:00:00", "work_hours": 6.76, "late_minutes": 314, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-03", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-03T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-04", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-04T13:31:14", "check_out": "2026-03-04T21:00:00", "work_hours": 7.48, "late_minutes": 271, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-05", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-05T14:28:01", "check_out": "2026-03-05T21:00:00", "work_hours": 6.53, "late_minutes": 328, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-06", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-06T13:00:37", "check_out": "2026-03-06T21:00:00", "work_hours": 7.99, "late_minutes": 240, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-07", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-07T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-08", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-08T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-09", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-09T14:20:47", "check_out": "2026-03-09T21:00:00", "work_hours": 6.65, "late_minutes": 320, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-10", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-10T14:03:00", "check_out": "2026-03-10T21:00:00", "work_hours": 6.95, "late_minutes": 303, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-11", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-11T14:48:58", "check_out": "2026-03-11T21:00:00", "work_hours": 6.18, "late_minutes": 348, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-12", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-12T09:52:35", "check_out": "2026-03-12T21:00:00", "work_hours": 11.12, "late_minutes": 52, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-13", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-13T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-14", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-14T13:55:15", "check_out": "2026-03-14T21:00:00", "work_hours": 7.08, "late_minutes": 295, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-15", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-15T13:57:42", "check_out": "2026-03-15T21:00:00", "work_hours": 7.04, "late_minutes": 297, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-16", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-16T14:27:04", "check_out": "2026-03-16T21:00:00", "work_hours": 6.55, "late_minutes": 327, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-17", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-18", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-18T12:26:06", "check_out": "2026-03-18T21:00:00", "work_hours": 8.56, "late_minutes": 206, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-19", "note": "إلغاء الإضافي", "status": "present", "check_in": "2026-03-19T13:21:00", "check_out": "2026-03-19T23:00:00", "work_hours": 9.65, "late_minutes": 261, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-20", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-20T17:03:16", "check_out": "2026-03-20T21:00:00", "work_hours": 3.95, "late_minutes": 483, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-23T10:01:47", "check_out": "2026-03-23T21:00:00", "work_hours": 10.97, "late_minutes": 61, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-24", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-25", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
d59f0a71-a586-4a0d-9e0f-04ec16365e99	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-03	6000.00	20	6	3.23	62.12	0.00	0.00	0.00	0.00	3367.32	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	17	0	220.47	1361	0	0	872.44	0	0.00	19.2308	[{"date": "2026-03-01", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-01T10:18:57", "check_out": "2026-03-01T23:00:00", "work_hours": 12.68, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.68}, {"date": "2026-03-02", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-02T16:14:32", "check_out": "2026-03-02T23:00:00", "work_hours": 6.76, "late_minutes": 314, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-03", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-03T12:04:51", "check_out": "2026-03-03T23:00:00", "work_hours": 10.92, "late_minutes": 64, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-04", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-04T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-05", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-05T11:37:27", "check_out": "2026-03-05T23:00:00", "work_hours": 11.38, "late_minutes": 37, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-06", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-06T11:23:01", "check_out": "2026-03-06T23:00:00", "work_hours": 11.62, "late_minutes": 23, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-07", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-07T12:19:05", "check_out": "2026-03-07T23:00:00", "work_hours": 10.68, "late_minutes": 79, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-08", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-08T13:04:54", "check_out": "2026-03-08T23:00:00", "work_hours": 9.92, "late_minutes": 124, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-09", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-09T12:03:52", "check_out": "2026-03-09T23:00:00", "work_hours": 10.94, "late_minutes": 63, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-10", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-10T12:34:01", "check_out": "2026-03-10T23:00:00", "work_hours": 10.43, "late_minutes": 94, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-11", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-11T13:29:20", "check_out": "2026-03-11T23:00:00", "work_hours": 9.51, "late_minutes": 149, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-12", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-12T13:10:07", "check_out": "2026-03-12T23:00:00", "work_hours": 9.83, "late_minutes": 130, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-13", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-13T10:21:50", "check_out": "2026-03-13T23:00:00", "work_hours": 12.64, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.64}, {"date": "2026-03-14", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-14T12:41:05", "check_out": "2026-03-14T23:00:00", "work_hours": 10.32, "late_minutes": 101, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-15", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-15T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-16", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-16T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-17", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-17T11:48:37", "check_out": "2026-03-17T23:00:00", "work_hours": 11.19, "late_minutes": 48, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-18", "note": "إلغاء الإضافي", "status": "present", "check_in": "2026-03-18T12:11:00", "check_out": "2026-03-18T23:00:00", "work_hours": 10.82, "late_minutes": 71, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-19", "note": "إلغاء الإضافي", "status": "present", "check_in": "2026-03-19T12:04:00", "check_out": "2026-03-19T23:00:00", "work_hours": 10.93, "late_minutes": 64, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-23T09:05:19", "check_out": "2026-03-23T23:00:00", "work_hours": 13.91, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 1.91}, {"date": "2026-03-24", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-25", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
57fc8096-0e96-4479-9a8e-dec4aedb47e9	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-03	6000.00	22	4	0.00	0.00	0.00	0.00	1000.00	0.00	3381.94	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	20	0	251.86	720	0	0	461.54	0	0.00	19.2308	[{"date": "2026-03-01", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-01T09:23:21", "check_out": "2026-03-01T21:00:00", "work_hours": 11.61, "late_minutes": 23, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-02", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-02T09:24:15", "check_out": "2026-03-02T21:00:00", "work_hours": 11.6, "late_minutes": 24, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-03", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-03T09:46:05", "check_out": "2026-03-03T21:00:00", "work_hours": 11.23, "late_minutes": 46, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-04", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-04T09:39:51", "check_out": "2026-03-04T21:00:00", "work_hours": 11.34, "late_minutes": 39, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-05", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-05T09:27:18", "check_out": "2026-03-05T21:00:00", "work_hours": 11.54, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-06", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-06T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-07", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-07T09:19:53", "check_out": "2026-03-07T21:00:00", "work_hours": 11.67, "late_minutes": 19, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-08", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-08T09:27:24", "check_out": "2026-03-08T21:00:00", "work_hours": 11.54, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-09", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-09T09:27:28", "check_out": "2026-03-09T21:00:00", "work_hours": 11.54, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-10", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-10T10:11:21", "check_out": "2026-03-10T21:00:00", "work_hours": 10.81, "late_minutes": 71, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-11", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-11T09:54:55", "check_out": "2026-03-11T21:00:00", "work_hours": 11.08, "late_minutes": 54, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-12", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-12T09:52:21", "check_out": "2026-03-12T21:00:00", "work_hours": 11.13, "late_minutes": 52, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-13", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-13T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-14", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-14T09:32:12", "check_out": "2026-03-14T21:00:00", "work_hours": 11.46, "late_minutes": 32, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-15", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-15T09:55:43", "check_out": "2026-03-15T21:00:00", "work_hours": 11.07, "late_minutes": 55, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-16", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-16T09:34:18", "check_out": "2026-03-16T21:00:00", "work_hours": 11.43, "late_minutes": 34, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-17", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-17T10:06:21", "check_out": "2026-03-17T21:00:00", "work_hours": 10.89, "late_minutes": 66, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-18", "note": "", "status": "present", "check_in": "2026-03-18T09:00:00", "check_out": "2026-03-18T21:00:00", "work_hours": 12.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-19", "note": "[ ]", "status": "present", "check_in": "2026-03-19T09:20:00", "check_out": "2026-03-19T21:00:00", "work_hours": 11.67, "late_minutes": 20, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-23T09:28:29", "check_out": "2026-03-23T21:00:00", "work_hours": 11.53, "late_minutes": 28, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-24", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-24T09:37:15", "check_out": "2026-03-24T21:00:00", "work_hours": 11.38, "late_minutes": 37, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-25", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-25T09:39:51", "check_out": "2026-03-25T21:00:00", "work_hours": 11.34, "late_minutes": 39, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
af09c8c8-0df4-4059-beef-4beded8a3d30	6fbdf70e-9def-4819-ba61-1146768e063e	2026-03	0.00	2	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	2	0	8.44	452	0	0	0.00	0	0.00	0.0000	[{"date": "2026-03-01", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-02", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-03", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-04", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-05", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-06", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-07", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-08", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-09", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-10", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-11", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-12", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-13", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-14", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-15", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-16", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-17", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-18", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-19", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-24", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-24T14:07:48", "check_out": "2026-03-24T16:00:00", "work_hours": 1.87, "late_minutes": 367, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-25", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-25T09:25:53", "check_out": "2026-03-25T16:00:00", "work_hours": 6.57, "late_minutes": 85, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
0c9a82a5-128a-4b60-a57a-9c83428d9d40	8547bd33-4c1f-4939-a460-f42beec6d360	2026-03	6000.00	17	9	1.83	35.19	0.00	0.00	1500.00	0.00	1972.42	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	13	0	196.23	380	0	0	301.28	0	0.00	19.2308	[{"date": "2026-03-01", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-01T09:23:10", "check_out": "2026-03-01T21:00:00", "work_hours": 11.61, "late_minutes": 23, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-02", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-02T08:50:06", "check_out": "2026-03-02T21:00:00", "work_hours": 12.16, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.16}, {"date": "2026-03-03", "note": "[اجازة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-03T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-04", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-04T09:39:41", "check_out": "2026-03-04T21:00:00", "work_hours": 11.34, "late_minutes": 39, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-05", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-05T09:18:44", "check_out": "2026-03-05T21:00:00", "work_hours": 11.69, "late_minutes": 18, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-06", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-06T09:55:45", "check_out": "2026-03-06T21:00:00", "work_hours": 11.07, "late_minutes": 55, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-07", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-07T09:18:50", "check_out": "2026-03-07T21:00:00", "work_hours": 11.69, "late_minutes": 18, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-08", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-08T09:27:18", "check_out": "2026-03-08T21:00:00", "work_hours": 11.54, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-09", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-09T09:38:39", "check_out": "2026-03-09T21:00:00", "work_hours": 11.36, "late_minutes": 38, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-10", "note": "[ ] / إلغاء الإضافي", "status": "present", "check_in": "2026-03-10T10:08:00", "check_out": "2026-03-10T18:00:00", "work_hours": 7.87, "late_minutes": 68, "early_minutes": 180, "overtime_hours": 0.0}, {"date": "2026-03-11", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-11T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-12", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-12T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-13", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-13T10:08:56", "check_out": "2026-03-13T21:00:00", "work_hours": 10.85, "late_minutes": 68, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-14", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-14T07:19:45", "check_out": "2026-03-14T21:00:00", "work_hours": 13.67, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 1.67}, {"date": "2026-03-15", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-15T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-16", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-16T09:10:20", "check_out": "2026-03-16T21:00:00", "work_hours": 11.83, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-17", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-18", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-19", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-24", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-25", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-25T09:26:49", "check_out": "2026-03-25T21:00:00", "work_hours": 11.55, "late_minutes": 26, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
d23291fa-0edd-4b47-bf7f-e16445ff2eb6	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-03	3000.00	8	18	1.30	18.75	0.00	0.00	0.00	0.00	811.63	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	8	0	62.71	193	0	0	92.79	0	0.00	14.4231	[{"date": "2026-03-01", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-02", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-03", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-04", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-05", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-06", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-07", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-08", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-09", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-10", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-11", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-12", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-13", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-14", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-15", "note": "", "status": "present", "check_in": "2026-03-15T09:05:00", "check_out": "2026-03-15T17:36:00", "work_hours": 8.52, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.52}, {"date": "2026-03-16", "note": "", "status": "present", "check_in": "2026-03-16T09:28:00", "check_out": "2026-03-16T17:22:00", "work_hours": 7.9, "late_minutes": 28, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-17", "note": "", "status": "present", "check_in": "2026-03-17T09:17:00", "check_out": "2026-03-17T17:34:00", "work_hours": 8.28, "late_minutes": 17, "early_minutes": 0, "overtime_hours": 0.28}, {"date": "2026-03-18", "note": "", "status": "present", "check_in": "2026-03-18T09:00:00", "check_out": "2026-03-18T17:30:00", "work_hours": 8.5, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.5}, {"date": "2026-03-19", "note": "", "status": "present", "check_in": "2026-03-19T09:12:00", "check_out": "2026-03-19T17:00:00", "work_hours": 7.8, "late_minutes": 12, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-23T09:42:13", "check_out": "2026-03-23T17:00:00", "work_hours": 7.3, "late_minutes": 42, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-24", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-24T09:36:52", "check_out": "2026-03-24T17:00:00", "work_hours": 7.39, "late_minutes": 36, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-25", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-25T09:58:32", "check_out": "2026-03-25T17:00:00", "work_hours": 7.02, "late_minutes": 58, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
14d305a0-8f23-4e49-8135-d1d683e4361f	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-03	3000.00	22	4	1.42	20.48	0.00	0.00	0.00	0.00	2230.81	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	20	0	169.70	451	0	0	216.83	0	0.00	14.4231	[{"date": "2026-03-01", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-01T09:25:37", "check_out": "2026-03-01T17:00:00", "work_hours": 7.57, "late_minutes": 25, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-02", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-02T09:18:56", "check_out": "2026-03-02T17:00:00", "work_hours": 7.68, "late_minutes": 18, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-03", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-03T09:15:00", "check_out": "2026-03-03T17:00:00", "work_hours": 7.75, "late_minutes": 15, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-04", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-04T09:40:07", "check_out": "2026-03-04T17:00:00", "work_hours": 7.33, "late_minutes": 40, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-05", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-05T09:18:36", "check_out": "2026-03-05T17:00:00", "work_hours": 7.69, "late_minutes": 18, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-06", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-06T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-07", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-07T09:19:05", "check_out": "2026-03-07T17:00:00", "work_hours": 7.68, "late_minutes": 19, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-08", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-08T09:27:41", "check_out": "2026-03-08T17:00:00", "work_hours": 7.54, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-09", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-09T09:23:23", "check_out": "2026-03-09T17:00:00", "work_hours": 7.61, "late_minutes": 23, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-10", "note": "", "status": "present", "check_in": "2026-03-10T09:08:00", "check_out": "2026-03-10T17:35:00", "work_hours": 8.45, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.45}, {"date": "2026-03-11", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-11T09:54:36", "check_out": "2026-03-11T17:00:00", "work_hours": 7.09, "late_minutes": 54, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-12", "note": "", "status": "present", "check_in": "2026-03-12T09:09:00", "check_out": "2026-03-12T17:37:00", "work_hours": 8.47, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.47}, {"date": "2026-03-13", "note": "[ ] / إجازة مدفوعة", "status": "leave", "check_in": "2026-03-13T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-14", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-14T09:21:17", "check_out": "2026-03-14T17:00:00", "work_hours": 7.65, "late_minutes": 21, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-15", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-15T09:15:00", "check_out": "2026-03-15T17:00:00", "work_hours": 7.75, "late_minutes": 15, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-16", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-16T09:19:34", "check_out": "2026-03-16T17:00:00", "work_hours": 7.67, "late_minutes": 19, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-17", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-17T09:06:00", "check_out": "2026-03-17T17:00:00", "work_hours": 7.9, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-18", "note": "", "status": "present", "check_in": "2026-03-18T09:00:00", "check_out": "2026-03-18T17:30:00", "work_hours": 8.5, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.5}, {"date": "2026-03-19", "note": "", "status": "present", "check_in": "2026-03-19T09:13:00", "check_out": "2026-03-19T17:00:00", "work_hours": 7.78, "late_minutes": 13, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-23T10:21:56", "check_out": "2026-03-23T17:00:00", "work_hours": 6.63, "late_minutes": 81, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-24", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-24T09:37:01", "check_out": "2026-03-24T17:00:00", "work_hours": 7.38, "late_minutes": 37, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-25", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-25T09:26:00", "check_out": "2026-03-25T17:00:00", "work_hours": 7.57, "late_minutes": 26, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
fd21b8a8-7555-4243-813d-b77be8270fac	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-03	3000.00	12	14	15.90	152.88	0.00	0.00	0.00	0.00	900.26	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 05:57:40.952049+00	12	0	140.39	1403	0	0	449.68	0	0.00	9.6154	[{"date": "2026-03-01", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-02T00:19:57", "check_out": "2026-03-02T21:00:00", "work_hours": 20.67, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 8.67}, {"date": "2026-03-02", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-03", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-04", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-04T10:17:12", "check_out": "2026-03-04T21:00:00", "work_hours": 10.71, "late_minutes": 77, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-05", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-05T15:26:45", "check_out": "2026-03-05T21:00:00", "work_hours": 5.55, "late_minutes": 386, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-06", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-06T09:03:51", "check_out": "2026-03-06T21:00:00", "work_hours": 11.94, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-07", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-08", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-08T10:31:44", "check_out": "2026-03-08T21:00:00", "work_hours": 10.47, "late_minutes": 91, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-09", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-09T15:16:14", "check_out": "2026-03-09T21:00:00", "work_hours": 5.73, "late_minutes": 376, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-10", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-11", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-11T10:09:48", "check_out": "2026-03-11T21:00:00", "work_hours": 10.84, "late_minutes": 69, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-12", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-13", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-13T10:53:30", "check_out": "2026-03-13T21:00:00", "work_hours": 10.11, "late_minutes": 113, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-14", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-15", "note": "لم يسجل خروج / إلغاء الإضافي", "status": "present", "check_in": "2026-03-15T09:55:16", "check_out": "2026-03-15T21:00:00", "work_hours": 11.08, "late_minutes": 55, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-16", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-17", "note": "لم يسجل خروج", "status": "present", "check_in": "2026-03-18T01:46:07", "check_out": "2026-03-18T21:00:00", "work_hours": 19.23, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 7.23}, {"date": "2026-03-18", "note": "إلغاء الإضافي", "status": "present", "check_in": "2026-03-18T10:38:00", "check_out": "2026-03-18T23:00:00", "work_hours": 12.37, "late_minutes": 98, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-19", "note": "إلغاء الإضافي", "status": "present", "check_in": "2026-03-19T11:18:00", "check_out": "2026-03-19T23:00:00", "work_hours": 11.7, "late_minutes": 138, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-03-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-23", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-24", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-25", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-03-28", "note": "لم يتم تسجيل حضور اليوم", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
930ae8c7-57b8-45ef-b2b2-19889dd2a10a	1c2e1861-ef74-46d8-9a77-ed741494a29a	2026-02	6000.00	8	18	0.00	0.00	0.00	0.00	1000.00	0.00	0.00	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	8	0	76.19	383	60	840	533.97	0	0.00	19.2308	[{"date": "2026-02-01", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-01T10:21:27", "check_out": "2026-02-01T21:00:00", "work_hours": 10.64, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-02", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-03", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-04", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-05", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-06", "note": "", "status": "present", "check_in": "2026-02-06T10:00:00", "check_out": "2026-02-06T22:00:00", "work_hours": 12.0, "late_minutes": 0, "early_minutes": 60, "overtime_hours": 0.0}, {"date": "2026-02-07", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-07T11:16:56", "check_out": "2026-02-07T21:00:00", "work_hours": 9.72, "late_minutes": 16, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-08", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-09", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-10", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-11", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-12", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-13", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-14", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-15", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-16", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-17", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-18", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-19", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-23", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-24", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-24T11:21:45", "check_out": "2026-02-24T21:00:00", "work_hours": 9.64, "late_minutes": 21, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-25", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-25T12:24:39", "check_out": "2026-02-25T21:00:00", "work_hours": 8.59, "late_minutes": 84, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-26", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-26T11:47:28", "check_out": "2026-02-26T21:00:00", "work_hours": 9.21, "late_minutes": 47, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-27", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-27T12:15:55", "check_out": "2026-02-27T21:00:00", "work_hours": 8.73, "late_minutes": 75, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-28", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-28T13:20:12", "check_out": "2026-02-28T21:00:00", "work_hours": 7.66, "late_minutes": 140, "early_minutes": 0, "overtime_hours": 0.0}]
5d1973a2-d048-436c-95f1-cea4cad1745c	ee53776b-70b3-4db1-9b2a-6ab75afe6d93	2026-02	6000.00	27	0	0.25	4.81	0.00	0.00	0.00	0.00	3128.17	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	25	2	259.26	1233	1410	2640	2088.46	1	230.77	19.2308	[{"date": "2026-02-01", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-01T09:40:43", "check_out": "2026-02-01T21:00:00", "work_hours": 11.32, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-02", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-02T08:45:14", "check_out": "2026-02-02T21:00:00", "work_hours": 12.25, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.25}, {"date": "2026-02-03", "note": "", "status": "present", "check_in": "2026-02-03T09:37:16", "check_out": "2026-02-03T12:00:00", "work_hours": 2.38, "late_minutes": 0, "early_minutes": 660, "overtime_hours": 0.0}, {"date": "2026-02-04", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-04T23:05:15", "check_out": "2026-02-04T21:00:00", "work_hours": -2.09, "late_minutes": 725, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-05", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-05T10:46:56", "check_out": "2026-02-05T21:00:00", "work_hours": 10.22, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-06", "note": "إلغاء الإضافي", "status": "present", "check_in": "2026-02-06T11:41:29", "check_out": "2026-02-06T12:00:00", "work_hours": 0.31, "late_minutes": 41, "early_minutes": 660, "overtime_hours": 0.0}, {"date": "2026-02-07", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-07T10:38:30", "check_out": "2026-02-07T21:00:00", "work_hours": 10.36, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-08", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-08T11:01:47", "check_out": "2026-02-08T21:00:00", "work_hours": 9.97, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-09", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-09T10:59:59", "check_out": "2026-02-09T21:00:00", "work_hours": 10.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-10", "note": "[سفر] / مأمورية عمل", "status": "mission", "check_in": "2026-02-10T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-11", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-11T10:50:29", "check_out": "2026-02-11T21:00:00", "work_hours": 10.16, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-12", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-12T09:58:07", "check_out": "2026-02-12T21:00:00", "work_hours": 11.03, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-13", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-13T11:20:12", "check_out": "2026-02-13T21:00:00", "work_hours": 9.66, "late_minutes": 20, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-14", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-14T09:46:16", "check_out": "2026-02-14T21:00:00", "work_hours": 11.23, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-15", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-15T09:30:47", "check_out": "2026-02-15T21:00:00", "work_hours": 11.49, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-16", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-16T09:39:04", "check_out": "2026-02-16T21:00:00", "work_hours": 11.35, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-17", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-17T11:20:55", "check_out": "2026-02-17T21:00:00", "work_hours": 9.65, "late_minutes": 20, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-18", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-18T10:55:19", "check_out": "2026-02-18T21:00:00", "work_hours": 10.08, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-19", "note": "[اجازة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-19T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-20", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-20T10:26:21", "check_out": "2026-02-20T21:00:00", "work_hours": 10.56, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-21", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-21T12:39:56", "check_out": "2026-02-21T21:00:00", "work_hours": 8.33, "late_minutes": 99, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-22", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-22T11:43:18", "check_out": "2026-02-22T21:00:00", "work_hours": 9.28, "late_minutes": 43, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-23", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-23T11:42:05", "check_out": "2026-02-23T21:00:00", "work_hours": 9.3, "late_minutes": 42, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-24", "note": "[اجازة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-24T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-25", "note": "[مبصمش]", "status": "present", "check_in": "2026-02-25T11:00:00", "check_out": "2026-02-25T21:30:00", "work_hours": 10.5, "late_minutes": 0, "early_minutes": 90, "overtime_hours": 0.0}, {"date": "2026-02-26", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-26T11:58:06", "check_out": "2026-02-26T21:00:00", "work_hours": 9.03, "late_minutes": 58, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-27", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-27T12:18:39", "check_out": "2026-02-27T21:00:00", "work_hours": 8.69, "late_minutes": 78, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-28", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-28T12:47:23", "check_out": "2026-02-28T21:00:00", "work_hours": 8.21, "late_minutes": 107, "early_minutes": 0, "overtime_hours": 0.0}]
2a421a29-e91f-4cf2-ba40-bb553f0b4e1f	ba82ba38-633f-4633-849f-b2458ad2952f	2026-02	4500.00	27	0	0.00	0.00	0.00	0.00	1600.00	0.00	0.00	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	23	4	195.18	5111	0	2640	3091.83	1	173.08	14.4231	[{"date": "2026-02-01", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-01T13:17:30", "check_out": "2026-02-01T19:00:00", "work_hours": 5.71, "late_minutes": 257, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-02", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-02T11:28:50", "check_out": "2026-02-02T19:00:00", "work_hours": 7.52, "late_minutes": 148, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-03", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-03T11:44:25", "check_out": "2026-02-03T19:00:00", "work_hours": 7.26, "late_minutes": 164, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-04", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-04T09:44:25", "check_out": "2026-02-04T19:00:00", "work_hours": 9.26, "late_minutes": 44, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-05", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-05T12:39:31", "check_out": "2026-02-05T19:00:00", "work_hours": 6.34, "late_minutes": 219, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-06", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-06T12:11:37", "check_out": "2026-02-06T19:00:00", "work_hours": 6.81, "late_minutes": 191, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-07", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-07T16:51:14", "check_out": "2026-02-07T19:00:00", "work_hours": 2.15, "late_minutes": 471, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-08", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-08T12:13:26", "check_out": "2026-02-08T19:00:00", "work_hours": 6.78, "late_minutes": 193, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-09", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-09T13:40:21", "check_out": "2026-02-09T19:00:00", "work_hours": 5.33, "late_minutes": 280, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-10", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-10T13:44:16", "check_out": "2026-02-10T19:00:00", "work_hours": 5.26, "late_minutes": 284, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-11", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-11T11:38:59", "check_out": "2026-02-11T19:00:00", "work_hours": 7.35, "late_minutes": 158, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-12", "note": "[مشي مرضي] / إلغاء الإضافي", "status": "present", "check_in": "2026-02-12T09:32:00", "check_out": "2026-02-12T21:32:00", "work_hours": 12.0, "late_minutes": 32, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-13", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-13T12:59:36", "check_out": "2026-02-13T19:00:00", "work_hours": 6.01, "late_minutes": 239, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-14", "note": "[مرضي] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-14T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-15", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-15T09:14:39", "check_out": "2026-02-15T19:00:00", "work_hours": 9.76, "late_minutes": 14, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-16", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-16T13:33:19", "check_out": "2026-02-16T19:00:00", "work_hours": 5.44, "late_minutes": 273, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-17", "note": "[مرضي] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-17T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-18", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-18T13:02:41", "check_out": "2026-02-18T19:00:00", "work_hours": 5.96, "late_minutes": 242, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-19", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-19T13:44:31", "check_out": "2026-02-19T19:00:00", "work_hours": 5.26, "late_minutes": 284, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-20", "note": "[مرضي] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-20T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-21", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-21T12:51:01", "check_out": "2026-02-21T19:00:00", "work_hours": 6.15, "late_minutes": 231, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-22", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-22T14:12:22", "check_out": "2026-02-22T19:00:00", "work_hours": 4.79, "late_minutes": 312, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-23", "note": "[مرضي] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-23T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-24", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-24T11:15:02", "check_out": "2026-02-24T19:00:00", "work_hours": 7.75, "late_minutes": 135, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-25", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-25T13:50:29", "check_out": "2026-02-25T19:00:00", "work_hours": 5.16, "late_minutes": 290, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-26", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-26T14:28:30", "check_out": "2026-02-26T19:00:00", "work_hours": 4.53, "late_minutes": 328, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-27", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-27T14:22:42", "check_out": "2026-02-27T19:00:00", "work_hours": 4.62, "late_minutes": 322, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-28", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
a2c2f175-34db-4a10-960f-c4b978c55789	dedc4608-da7e-4935-99c0-669c48d2a895	2026-02	3500.00	28	0	0.78	13.12	0.00	0.00	3000.00	0.00	0.00	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	28	0	158.76	1310	244	3120	1678.21	2	269.23	16.8269	[{"date": "2026-02-01", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-01T13:18:38", "check_out": "2026-02-01T19:00:00", "work_hours": 5.69, "late_minutes": 18, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-02", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-02T13:58:06", "check_out": "2026-02-02T19:00:00", "work_hours": 5.03, "late_minutes": 58, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-03", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-03T13:48:59", "check_out": "2026-02-03T19:00:00", "work_hours": 5.18, "late_minutes": 48, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-04", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-04T10:15:43", "check_out": "2026-02-04T19:00:00", "work_hours": 8.74, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.74}, {"date": "2026-02-05", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-05T12:47:34", "check_out": "2026-02-05T19:00:00", "work_hours": 6.21, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-06", "note": "", "status": "present", "check_in": "2026-02-06T11:19:00", "check_out": "2026-02-06T17:56:00", "work_hours": 6.62, "late_minutes": 0, "early_minutes": 184, "overtime_hours": 0.0}, {"date": "2026-02-07", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-07T12:29:35", "check_out": "2026-02-07T19:00:00", "work_hours": 6.51, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-08", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-08T14:08:57", "check_out": "2026-02-08T19:00:00", "work_hours": 4.85, "late_minutes": 68, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-09", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-09T16:02:18", "check_out": "2026-02-09T19:00:00", "work_hours": 2.96, "late_minutes": 182, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-10", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-10T10:57:42", "check_out": "2026-02-10T19:00:00", "work_hours": 8.04, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.04}, {"date": "2026-02-11", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-11T12:33:23", "check_out": "2026-02-11T19:00:00", "work_hours": 6.44, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-12", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-12T12:24:52", "check_out": "2026-02-12T19:00:00", "work_hours": 6.59, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-13", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-13T11:00:00", "check_out": "2026-02-13T19:00:00", "work_hours": 8.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-14", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-14T12:23:46", "check_out": "2026-02-14T19:00:00", "work_hours": 6.6, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-15", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-15T14:37:16", "check_out": "2026-02-15T19:00:00", "work_hours": 4.38, "late_minutes": 97, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-16", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-16T16:33:57", "check_out": "2026-02-16T19:00:00", "work_hours": 2.43, "late_minutes": 213, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-17", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-17T14:36:59", "check_out": "2026-02-17T19:00:00", "work_hours": 4.38, "late_minutes": 96, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-18", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-18T14:12:28", "check_out": "2026-02-18T19:00:00", "work_hours": 4.79, "late_minutes": 72, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-19", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-19T12:30:30", "check_out": "2026-02-19T19:00:00", "work_hours": 6.49, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-20", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-20T13:07:15", "check_out": "2026-02-20T19:00:00", "work_hours": 5.88, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-21", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-21T11:59:54", "check_out": "2026-02-21T19:00:00", "work_hours": 7.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-22", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-22T13:49:41", "check_out": "2026-02-22T19:00:00", "work_hours": 5.17, "late_minutes": 49, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-23", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-23T15:11:15", "check_out": "2026-02-23T19:00:00", "work_hours": 3.81, "late_minutes": 131, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-24", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-24T15:02:43", "check_out": "2026-02-24T19:00:00", "work_hours": 3.95, "late_minutes": 122, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-25", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-25T13:50:07", "check_out": "2026-02-25T19:00:00", "work_hours": 5.16, "late_minutes": 50, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-26", "note": "إلغاء الإضافي", "status": "present", "check_in": "2026-02-26T13:47:00", "check_out": "2026-02-26T20:00:00", "work_hours": 6.22, "late_minutes": 47, "early_minutes": 60, "overtime_hours": 0.0}, {"date": "2026-02-27", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-27T13:59:05", "check_out": "2026-02-27T19:00:00", "work_hours": 5.02, "late_minutes": 59, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-28", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-28T12:23:38", "check_out": "2026-02-28T19:00:00", "work_hours": 6.61, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}]
82d27a56-97aa-4e14-a62d-3877c4bb6e1e	8547bd33-4c1f-4939-a460-f42beec6d360	2026-02	6000.00	28	0	2.02	38.85	0.00	0.00	3800.00	0.00	877.23	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	26	2	284.75	466	0	3000	1260.26	2	461.54	19.2308	[{"date": "2026-02-01", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-01T09:40:48", "check_out": "2026-02-01T19:00:00", "work_hours": 9.32, "late_minutes": 40, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-02", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-02T08:59:55", "check_out": "2026-02-02T19:00:00", "work_hours": 10.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-03", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-03T09:44:21", "check_out": "2026-02-03T19:00:00", "work_hours": 9.26, "late_minutes": 44, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-04", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-04T07:53:00", "check_out": "2026-02-04T19:00:00", "work_hours": 11.12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-05", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-05T09:01:23", "check_out": "2026-02-05T19:00:00", "work_hours": 9.98, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-06", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-06T08:16:45", "check_out": "2026-02-06T19:00:00", "work_hours": 10.72, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-07", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-07T08:59:25", "check_out": "2026-02-07T19:00:00", "work_hours": 10.01, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-08", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-08T08:59:32", "check_out": "2026-02-08T19:00:00", "work_hours": 10.01, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-09", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-09T09:11:26", "check_out": "2026-02-09T19:00:00", "work_hours": 9.81, "late_minutes": 11, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-10", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-10T07:37:37", "check_out": "2026-02-10T19:00:00", "work_hours": 11.37, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-11", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-11T09:06:59", "check_out": "2026-02-11T19:00:00", "work_hours": 9.88, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-12", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-12T09:20:23", "check_out": "2026-02-12T19:00:00", "work_hours": 9.66, "late_minutes": 20, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-13", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-13T07:53:37", "check_out": "2026-02-13T19:00:00", "work_hours": 11.11, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-14", "note": "", "status": "present", "check_in": "2026-02-14T08:59:00", "check_out": "2026-02-14T23:00:00", "work_hours": 14.02, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 2.02}, {"date": "2026-02-15", "note": "[تعبااااان] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-15T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-16", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-16T08:27:57", "check_out": "2026-02-16T19:00:00", "work_hours": 10.53, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-17", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-17T09:17:06", "check_out": "2026-02-17T19:00:00", "work_hours": 9.71, "late_minutes": 17, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-18", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-18T09:34:23", "check_out": "2026-02-18T19:00:00", "work_hours": 9.43, "late_minutes": 34, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-19", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-19T09:26:33", "check_out": "2026-02-19T19:00:00", "work_hours": 9.56, "late_minutes": 26, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-20", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-20T09:48:41", "check_out": "2026-02-20T19:00:00", "work_hours": 9.19, "late_minutes": 48, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-21", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-21T09:01:42", "check_out": "2026-02-21T19:00:00", "work_hours": 9.97, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-22", "note": "[تعبان] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-22T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-23", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-23T09:33:57", "check_out": "2026-02-23T19:00:00", "work_hours": 9.43, "late_minutes": 33, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-24", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-24T09:01:05", "check_out": "2026-02-24T19:00:00", "work_hours": 9.98, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-25", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-25T10:14:34", "check_out": "2026-02-25T19:00:00", "work_hours": 8.76, "late_minutes": 74, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-26", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-26T09:04:23", "check_out": "2026-02-26T19:00:00", "work_hours": 9.93, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-27", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-27T10:33:40", "check_out": "2026-02-27T19:00:00", "work_hours": 8.44, "late_minutes": 93, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-28", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-28T09:26:51", "check_out": "2026-02-28T19:00:00", "work_hours": 9.55, "late_minutes": 26, "early_minutes": 0, "overtime_hours": 0.0}]
c48f6730-6794-4d38-8d35-fb5bab70cceb	6fcefb3d-7918-4118-9633-b74c21c0dd0f	2026-02	6000.00	21	5	0.00	0.00	0.00	0.00	2000.00	0.00	690.93	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	18	3	202.56	799	0	2160	1204.49	0	0.00	19.2308	[{"date": "2026-02-01", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-02", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-03", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-04", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-05", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-06", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-07", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-08", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-08T09:27:51", "check_out": "2026-02-08T19:00:00", "work_hours": 9.54, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-09", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-09T09:31:07", "check_out": "2026-02-09T19:00:00", "work_hours": 9.48, "late_minutes": 31, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-10", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-10T09:27:15", "check_out": "2026-02-10T19:00:00", "work_hours": 9.55, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-11", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-11T09:21:06", "check_out": "2026-02-11T19:00:00", "work_hours": 9.65, "late_minutes": 21, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-12", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-12T09:28:29", "check_out": "2026-02-12T19:00:00", "work_hours": 9.53, "late_minutes": 28, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-13", "note": "[جمعة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-13T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-14", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-14T09:21:52", "check_out": "2026-02-14T19:00:00", "work_hours": 9.64, "late_minutes": 21, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-15", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-15T09:25:46", "check_out": "2026-02-15T19:00:00", "work_hours": 9.57, "late_minutes": 25, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-16", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-16T15:44:00", "check_out": "2026-02-16T19:00:00", "work_hours": 3.27, "late_minutes": 404, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-17", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-17T09:29:14", "check_out": "2026-02-17T19:00:00", "work_hours": 9.51, "late_minutes": 29, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-18", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-18T09:34:02", "check_out": "2026-02-18T19:00:00", "work_hours": 9.43, "late_minutes": 34, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-19", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-19T09:26:54", "check_out": "2026-02-19T19:00:00", "work_hours": 9.55, "late_minutes": 26, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-20", "note": "[جمعة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-20T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-21", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-21T09:24:50", "check_out": "2026-02-21T19:00:00", "work_hours": 9.59, "late_minutes": 24, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-22", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-22T09:33:57", "check_out": "2026-02-22T19:00:00", "work_hours": 9.43, "late_minutes": 33, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-23", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-23T09:00:00", "check_out": "2026-02-23T19:00:00", "work_hours": 10.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-24", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-24T09:18:00", "check_out": "2026-02-24T19:00:00", "work_hours": 9.7, "late_minutes": 18, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-25", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-25T09:00:00", "check_out": "2026-02-25T19:00:00", "work_hours": 10.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-26", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-26T09:24:43", "check_out": "2026-02-26T19:00:00", "work_hours": 9.59, "late_minutes": 24, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-27", "note": "[جمعة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-27T12:00:00", "check_out": null, "work_hours": 12, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-28", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-28T09:27:12", "check_out": "2026-02-28T19:00:00", "work_hours": 9.55, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}]
5a0306ea-e9af-4777-b53b-4206d7772df5	ddc6b689-f7f8-476a-a6fa-a7cfc05fc045	2026-02	3000.00	22	4	0.00	0.00	0.00	0.00	0.00	0.00	1147.68	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	21	1	132.37	564	0	2040	761.54	0	0.00	14.4231	[{"date": "2026-02-01", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-02", "note": "", "status": "present", "check_in": "2026-02-02T09:03:00", "check_out": "2026-02-02T17:03:00", "work_hours": 8.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-03", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-03T09:34:46", "check_out": "2026-02-03T15:00:00", "work_hours": 5.42, "late_minutes": 34, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-04", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-04T09:46:38", "check_out": "2026-02-04T15:00:00", "work_hours": 5.22, "late_minutes": 46, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-05", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-05T09:13:55", "check_out": "2026-02-05T15:00:00", "work_hours": 5.77, "late_minutes": 13, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-06", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-06T09:28:01", "check_out": "2026-02-06T15:00:00", "work_hours": 5.53, "late_minutes": 28, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-07", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-07T09:17:45", "check_out": "2026-02-07T15:00:00", "work_hours": 5.7, "late_minutes": 17, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-08", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-08T09:23:20", "check_out": "2026-02-08T15:00:00", "work_hours": 5.61, "late_minutes": 23, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-09", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-09T09:16:44", "check_out": "2026-02-09T15:00:00", "work_hours": 5.72, "late_minutes": 16, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-10", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-10T09:25:33", "check_out": "2026-02-10T15:00:00", "work_hours": 5.57, "late_minutes": 25, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-11", "note": "[اجازة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-11T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-12", "note": "", "status": "present", "check_in": "2026-02-12T09:27:00", "check_out": "2026-02-12T17:00:00", "work_hours": 7.55, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-13", "note": "", "status": "present", "check_in": "2026-02-13T09:05:00", "check_out": "2026-02-13T17:00:00", "work_hours": 7.92, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-14", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-14T09:11:47", "check_out": "2026-02-14T15:00:00", "work_hours": 5.8, "late_minutes": 11, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-15", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-15T09:22:48", "check_out": "2026-02-15T15:00:00", "work_hours": 5.62, "late_minutes": 22, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-16", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-16T09:28:42", "check_out": "2026-02-16T15:00:00", "work_hours": 5.52, "late_minutes": 28, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-17", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-17T09:17:30", "check_out": "2026-02-17T15:00:00", "work_hours": 5.71, "late_minutes": 17, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-18", "note": "إلغاء الإضافي", "status": "present", "check_in": "2026-02-18T09:34:00", "check_out": "2026-02-18T17:00:00", "work_hours": 7.43, "late_minutes": 34, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-19", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-19T10:31:14", "check_out": "2026-02-19T15:00:00", "work_hours": 4.48, "late_minutes": 91, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-20", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-20T09:19:05", "check_out": "2026-02-20T15:00:00", "work_hours": 5.68, "late_minutes": 19, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-22", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-22T09:33:17", "check_out": "2026-02-22T15:00:00", "work_hours": 5.45, "late_minutes": 33, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-23", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-23T09:42:09", "check_out": "2026-02-23T15:00:00", "work_hours": 5.3, "late_minutes": 42, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-24", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-24T09:38:25", "check_out": "2026-02-24T15:00:00", "work_hours": 5.36, "late_minutes": 38, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-25", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-28", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
a57bdf2b-e6af-4eb9-9ccd-b9b5169b15ad	53b8dbd5-735b-4617-bd38-4a7084272fba	2026-02	3000.00	21	5	0.00	0.00	0.00	0.00	0.00	0.00	1191.15	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	18	3	127.22	259	0	2160	643.75	0	0.00	14.4231	[{"date": "2026-02-01", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-02", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-03", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-04", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-05", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-06", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-07", "note": "قبل تاريخ التعيين", "status": "pre-hire", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-08", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-08T09:07:06", "check_out": "2026-02-08T15:00:00", "work_hours": 5.88, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-09", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-09T09:11:47", "check_out": "2026-02-09T15:00:00", "work_hours": 5.8, "late_minutes": 11, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-10", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-10T09:04:50", "check_out": "2026-02-10T15:00:00", "work_hours": 5.92, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-11", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-11T09:13:33", "check_out": "2026-02-11T15:00:00", "work_hours": 5.77, "late_minutes": 13, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-12", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-12T09:22:03", "check_out": "2026-02-12T15:00:00", "work_hours": 5.63, "late_minutes": 22, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-13", "note": "[اجازة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-13T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-14", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-14T09:11:55", "check_out": "2026-02-14T15:00:00", "work_hours": 5.8, "late_minutes": 11, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-15", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-15T09:13:54", "check_out": "2026-02-15T15:00:00", "work_hours": 5.77, "late_minutes": 13, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-16", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-16T09:08:23", "check_out": "2026-02-16T15:00:00", "work_hours": 5.86, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-17", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-17T09:24:17", "check_out": "2026-02-17T15:00:00", "work_hours": 5.6, "late_minutes": 24, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-18", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-18T09:34:20", "check_out": "2026-02-18T15:00:00", "work_hours": 5.43, "late_minutes": 34, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-19", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-19T09:27:59", "check_out": "2026-02-19T15:00:00", "work_hours": 5.53, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-20", "note": "[الجمعة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-20T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-21", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-21T09:13:43", "check_out": "2026-02-21T15:00:00", "work_hours": 5.77, "late_minutes": 13, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-22", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-22T09:32:53", "check_out": "2026-02-22T15:00:00", "work_hours": 5.45, "late_minutes": 32, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-23", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-23T09:00:00", "check_out": "2026-02-23T15:00:00", "work_hours": 6.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-24", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-24T09:16:59", "check_out": "2026-02-24T15:00:00", "work_hours": 5.72, "late_minutes": 16, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-25", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-25T09:00:00", "check_out": "2026-02-25T15:00:00", "work_hours": 6.0, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-26", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-26T09:16:07", "check_out": "2026-02-26T15:00:00", "work_hours": 5.73, "late_minutes": 16, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-27", "note": "[الجمعة] / إجازة مدفوعة", "status": "leave", "check_in": "2026-02-27T12:00:00", "check_out": null, "work_hours": 8, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-28", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-28T09:27:01", "check_out": "2026-02-28T15:00:00", "work_hours": 5.55, "late_minutes": 27, "early_minutes": 0, "overtime_hours": 0.0}]
a788e9af-b60b-4b19-8688-05db2b0b74ba	925f7ec5-0f83-4508-8cda-d7c8174f2990	2026-02	3000.00	4	22	0.00	0.00	0.00	0.00	0.00	0.00	269.74	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	4	0	38.55	75	0	480	100.96	0	0.00	9.6154	[{"date": "2026-02-01", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-01T09:41:44", "check_out": "2026-02-01T19:00:00", "work_hours": 9.3, "late_minutes": 41, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-02", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-02T09:01:38", "check_out": "2026-02-02T19:00:00", "work_hours": 9.97, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-03", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-03T09:34:37", "check_out": "2026-02-03T19:00:00", "work_hours": 9.42, "late_minutes": 34, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-04", "note": "افتراض خروج مبكر 2 ساعة", "status": "present", "check_in": "2026-02-04T09:08:49", "check_out": "2026-02-04T19:00:00", "work_hours": 9.85, "late_minutes": 0, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-05", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-06", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-07", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-08", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-09", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-10", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-11", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-12", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-13", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-14", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-15", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-16", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-17", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-18", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-19", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-23", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-24", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-25", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-28", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
6407cacc-e5f6-4882-a50a-2c4dbb527811	6fbdf70e-9def-4819-ba61-1146768e063e	2026-02	0.00	2	24	0.00	0.00	0.00	0.00	0.00	0.00	0.00	draft	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 09:03:50.015497+00	2	0	5.76	373	0	240	0.00	0	0.00	0.0000	[{"date": "2026-02-01", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-01T09:40:52", "check_out": "2026-02-01T14:00:00", "work_hours": 4.32, "late_minutes": 100, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-02", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-03", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-04", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-05", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-06", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-07", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-08", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-09", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-10", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-11", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-12", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-13", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-14", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-15", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-16", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-17", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-18", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-19", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-20", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-21", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-22", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-23", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-24", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-25", "note": "افتراض خروج مبكر 2 ساعة / إلغاء الإضافي", "status": "present", "check_in": "2026-02-25T12:33:19", "check_out": "2026-02-25T14:00:00", "work_hours": 1.44, "late_minutes": 273, "early_minutes": 0, "overtime_hours": 0.0}, {"date": "2026-02-26", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-27", "note": "عطلة أسبوعية", "status": "weekend", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}, {"date": "2026-02-28", "note": "غياب", "status": "absent", "work_hours": 0, "late_minutes": 0, "overtime_hours": 0}]
\.


--
-- Data for Name: hr_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_settings (key, value) FROM stdin;
apply_missing_checkout_penalty	False
device_host	192.168.1.201
device_port	4370
device_timeout	5
\.


--
-- Data for Name: hr_shifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_shifts (id, name, start_time, end_time, description) FROM stdin;
1769691570	9 صباحا الى 9 مساءً	09:00	21:00	
1769691623	9 صباحاً الى 5 مساءً	09:00	17:00	
1769691649	11 صباحاً الى 11 مساءً	11:00	23:00	
1769691680	1 مساءً الى 9 مساءً	13:00	21:00	
1769691772	3 مساءً الى 11 مساءً	15:00	23:00	
1769850410	4 مساءً الى 11 مساءً	16:00	23:00	
1769858164	9 صباحاَ الى 4 مساءً	09:00	16:00	
\.


--
-- Data for Name: hr_sync_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_sync_log (id, synced_at, status, fetched, added, updated, message) FROM stdin;
87369ecc-2914-4c3e-91b6-d51ec8bef1fa	2026-04-08 18:36:49.230223+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
8ed58305-6bc5-401d-b457-e3fbaa64f30a	2026-04-08 18:37:23.072786+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
b50c1f77-93a6-42a3-b904-d70f9e492666	2026-04-08 18:37:23.990301+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
4a02a348-fc17-4ee1-acb0-674c67ace2ae	2026-04-08 18:39:30.619618+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
9a910bcd-acb6-4ece-bf20-cbaf8c71bf9b	2026-04-08 18:51:22.720721+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
86c2a736-8d22-4eb0-8d23-3f88b3cad3c2	2026-04-08 18:51:25.013859+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
cb124cef-b0c5-4f5e-af34-1281c4afc226	2026-04-08 18:53:38.046214+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
d152dc5d-ae88-40f0-bf80-6d51ad9a7d11	2026-04-08 19:48:23.938062+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
7697fd73-6a91-44a3-a18a-a85d9c37cc71	2026-04-08 20:01:12.58908+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
5965016b-d161-4c26-8fcd-2175c525659f	2026-04-08 20:01:30.347914+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
3f6aa836-6700-4fc5-9e16-df58ff5dc636	2026-04-13 06:52:33.768316+00	failure	0	0	0	can't reach device (ping 192.168.1.201)
\.


--
-- Data for Name: payment_wallets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_wallets (id, name, type, phone, balance, is_active, created_at) FROM stdin;
292f39d3-443e-454e-acc8-013a94f7de41	نقدي	cash	\N	0.00	t	2026-03-31 20:34:48.627361+00
65a0fae8-6c96-4094-9545-aa8c0a546806	مؤمن	vodafone_cash	01001179350	0.00	t	2026-04-04 11:48:10.285025+00
1f746ad2-3ce3-4c5b-a584-31a2d9be359f	إنستا باي — الشركة	instapay	01XXXXXXXXX	0.00	f	2026-03-31 20:34:48.627361+00
7dfd5ac6-bf14-48d5-aef9-1217f7144a8f	فودافون كاش — الشركة	vodafone_cash	01XXXXXXXXX	0.00	f	2026-03-31 20:34:48.627361+00
72811e0c-c360-4309-b85e-7973691e6069	حماده 	instapay	01202456394	0.00	t	2026-04-04 11:48:55.994534+00
8168ea3e-3935-477f-a412-9184f9188885	حماده 	vodafone_cash	01000765528	685.00	t	2026-04-04 12:07:01.679689+00
\.


--
-- Data for Name: payroll_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll_entries (id, period_id, employee_id, base_salary, bonuses, deductions, notes) FROM stdin;
\.


--
-- Data for Name: payroll_periods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll_periods (id, month, year, status, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: product_collections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_collections (id, name, description, retail_price, wholesale_price, is_active, created_at) FROM stdin;
b933c689-75e2-426d-9cb2-a7729c8f0679	طقم خلاط روكا		0.00	0.00	t	2026-04-11 16:55:49.217525+00
5c5959cf-c559-4737-b478-ff20a99508dc	طقم بلايا ايديال		8500.00	0.00	t	2026-04-11 17:11:42.047162+00
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, subcategory_id, name, barcode, unit, retail_price, wholesale_price, cost_price, company, size, type, material, image_url, is_active, created_at, updated_at, reorder_point, reorder_qty, stock_status) FROM stdin;
cb81213b-7bb7-4274-abb4-2d974f8a60cb	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	شداد سيفون طويل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:35:28.975017+00	2026-04-13 13:31:55.807119+00	0.000	0.000	tracked
bc28ef2a-26a3-4fa2-9f4e-2b938f776bd4	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	اوكره جمب 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 16:16:32.324037+00	2026-04-13 13:32:09.956769+00	0.000	0.000	tracked
c80f86d8-cb80-465f-ad00-b3583f1c4c40	df634c7a-d345-505a-82a4-2bdc2e899a7b	ضاغط مكنه 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 13:22:38.893496+00	2026-04-13 13:34:16.046008+00	0.000	0.000	tracked
2af69fb2-b207-43c5-9f6d-0fa26b40cf18	1a1d02e5-073c-5e69-ad71-5432e235bfa5	افيز بلاستيك فردي 3/4		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 12:22:18.681624+00	2026-04-13 13:34:22.582064+00	0.000	0.000	tracked
c93e6a11-6694-486c-936c-3208c49f198f	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 70 سم 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 11:26:32.788313+00	2026-04-13 13:34:33.217089+00	0.000	0.000	tracked
70c6a2cb-6643-4373-9e08-da46d851fe2e	7f15ec9b-720f-580d-ad54-61fcb04a20d9	جلبه سماعة نيكل 3/4*1/2(جلبة سماعه)		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:40:39.061436+00	2026-04-13 13:38:06.780947+00	0.000	0.000	tracked
1a03ff11-9bf4-472b-aae3-8734a988747c	db5470af-2e31-4a61-b24c-b2ff749c469b	لفة سلك 2 ملي سويدي 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 14:22:38.879577+00	2026-04-13 14:25:31.334595+00	0.000	0.000	tracked
2fbf13f5-20e4-4d56-a923-31acf00d8e7b	49ebba26-a7d1-42a2-bb7a-850f732f1f78	تي مسلوب 1/2*3/4 بولي		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-17 11:26:07.283615+00	2026-04-17 11:28:51.910724+00	0.000	0.000	tracked
1956ad46-29b3-447e-abd2-de8532dcb0d1	6e5adb99-fc20-4ec3-9366-8427dcc2a094	جلبة 4" بولي		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-17 11:32:34.214445+00	2026-04-17 11:32:42.10405+00	0.000	0.000	tracked
ef7073ab-4d25-442d-8505-6eacd9886f13	df634c7a-d345-505a-82a4-2bdc2e899a7b	مدخنه تركي 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 12:25:30.391051+00	2026-04-18 20:00:32.102193+00	0.000	0.000	untracked
5e9e99fb-95ac-4298-a437-570417737d44	8ee8e20b-ffb9-5b16-96db-954194f2a369	حوض صيني بلابا ايديال		عدد	2000.00	0.00	0.00	ايديال	\N	\N	\N	\N	t	2026-04-11 17:08:31.343708+00	2026-04-18 20:01:07.762326+00	0.000	0.000	untracked
6262274f-c0c8-4a53-84cf-c3977995ddce	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كوع لحام بسن 3/4*1/2 BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:14:05.964832+00	2026-04-22 13:14:16.866753+00	0.000	0.000	tracked
55cc2075-bfe4-4613-91de-05535390b28a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية بلاستيك	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 16:36:03.564033+00	2026-02-21 21:45:13.511767+00	0.000	0.000	untracked
056ef88b-f53d-4806-9e24-f9f931f54dcf	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية 3/4" PG (يوسف)	\N	عدد	280.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 17:57:09.849733+00	2026-02-23 19:46:14.704199+00	0.000	0.000	untracked
0eb4a2fa-6d82-4005-bbb7-c958edcf281a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية نحاس بلية1 بوصة (يوسف)	\N	عدد	380.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 18:00:15.242202+00	2026-02-21 21:44:58.682402+00	0.000	0.000	untracked
6d5bbad0-e533-497c-8378-2be2633b1b49	8ee8e20b-ffb9-5b16-96db-954194f2a369	عامود بلايا ايديال		عدد	0.00	0.00	0.00	ايديال	\N	\N	\N	\N	t	2026-04-11 17:09:39.001435+00	2026-04-11 17:09:39.001435+00	0.000	0.000	untracked
935326ee-fa2f-4434-b571-471f0e996f35	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور عداد 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:35:22.849889+00	2026-04-12 12:13:23.284959+00	0.000	0.000	tracked
8816fa99-fe08-4d0b-ae95-19558eb03a22	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية سما 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 16:19:25.735793+00	2026-04-12 16:21:31.054252+00	0.000	0.000	tracked
e50f6cef-cbd4-4458-97fc-52eb563bc3c5	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامه 1" نحاس		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 13:36:21.352291+00	2026-04-13 13:29:20.755282+00	0.000	0.000	tracked
d87c198f-b9e4-47b3-be1d-ca135da5243a	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامه 3/4 نحاس 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 13:35:56.248622+00	2026-04-13 13:29:23.203545+00	0.000	0.000	tracked
92518465-ec8a-4c4c-8fa9-d7517296ae04	5d243e5e-b20e-5f54-9828-e080a13b0a39	طاسة دش 15*15 استلس 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 15:47:47.895561+00	2026-04-13 13:43:46.517764+00	0.000	0.000	tracked
147e4173-a198-4ef5-b70c-9ed8aa73c872	1a1d02e5-073c-5e69-ad71-5432e235bfa5	افيز بلاستيك فليشر 3/4		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 12:26:40.467551+00	2026-04-13 13:43:53.123535+00	0.000	0.000	tracked
89392aba-aa30-4188-914b-4792ca2815d0	1a1d02e5-073c-5e69-ad71-5432e235bfa5	افيز بلاستيك دولفن (فلشر 1/2)		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 12:19:17.687733+00	2026-04-13 13:43:58.391619+00	0.000	0.000	tracked
e4028986-2cb3-40e0-84e7-6e167bac110d	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب 1/2 لفه جولد ستار 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:28:40.552982+00	2026-04-13 14:08:58.856365+00	0.000	0.000	tracked
3e6b7157-4754-456c-a3ef-63d087e40dd3	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش هاند شاور	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-04-15 14:17:49.140662+00	0.000	0.000	untracked
c120ad01-bbee-4fcf-923a-d30ccd95de43	717cca0e-559c-409e-8623-d47ecff326c6	محبس زاوية BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 15:02:35.179906+00	2026-04-15 14:24:35.305272+00	0.000	0.000	tracked
12496280-b9bd-43e5-882b-8cad7ac41d14	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل نيكل محمل 1*1/4		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:14:13.445436+00	2026-04-15 15:36:55.161795+00	0.000	0.000	tracked
b4792075-b071-4390-8183-b9615ecba622	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل نيكل محمل 1.5		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:11:37.849793+00	2026-04-15 15:36:59.355579+00	0.000	0.000	tracked
9995e6c2-e656-4f06-b7d1-938574985a22	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل 2" نيكل 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:47:42.62131+00	2026-04-15 15:37:04.187324+00	0.000	0.000	tracked
a6443656-c761-4e9b-8d67-7396fe3275a6	49ebba26-a7d1-42a2-bb7a-850f732f1f78	تي مسلوب 1*3/4 بولي		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-17 11:27:14.18323+00	2026-04-17 11:28:58.641362+00	0.000	0.000	tracked
da5bf6fb-6156-445d-a462-809b65e03e52	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	تي بسن 3/4*1/2بولي BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:31:03.845529+00	2026-04-22 13:31:18.120366+00	0.000	0.000	tracked
db12ee40-16a3-42ce-b548-5de14a547b0a	7cb8a098-41ca-53d9-b4e0-cdb8907a18d9	جلبة لحام 1.5 BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:54:42.759967+00	2026-04-22 13:55:06.787269+00	0.000	0.000	tracked
9032580b-60a6-4db2-a363-ab3c8ecdaa84	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كرنك لحام 1/2" قصير بولي BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:31:58.410233+00	2026-04-22 13:56:07.155255+00	0.000	0.000	tracked
f9bb2b67-91f9-4176-a285-ad980d259775	b573fe58-7d47-4e7c-95bc-0494d6a4387a	جلبة لحام معزول 3/4		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:06:28.23447+00	2026-04-22 14:06:38.731122+00	0.000	0.000	tracked
0d71a0fc-2f22-4bef-9038-6b30deeb267a	d0b68374-c340-51f8-8e0b-eab0a823c6f5	مشترك 4" 110 عاده BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 15:14:25.943796+00	2026-04-22 15:14:35.447764+00	0.000	0.000	tracked
1e873951-947e-47f7-88cf-26dfb861ec7d	8ee8e20b-ffb9-5b16-96db-954194f2a369	صندوق وقاعدة صيني بلايا ايديال		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:10:57.686157+00	2026-04-11 17:10:57.686157+00	0.000	0.000	untracked
7ee0b4c1-23e9-4783-b9fe-f148c7606066	7f15ec9b-720f-580d-ad54-61fcb04a20d9	ماسورة دش خفيفه		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:16:18.836817+00	2026-04-11 18:16:18.836817+00	0.000	0.000	untracked
aeb7ad06-7e28-4732-b145-cfef45c9521d	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكنه صندوق ايديال		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:23:50.015498+00	2026-04-11 18:23:50.015498+00	0.000	0.000	untracked
745c9937-e523-400f-8665-dd79e076f39f	df634c7a-d345-505a-82a4-2bdc2e899a7b	عوامة جمب 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 13:26:09.922084+00	2026-04-13 13:29:12.036015+00	0.000	0.000	tracked
18988ac3-83bf-4b07-9bf3-f31dc4810704	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	بالونه عوامه بدون يد 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 13:45:51.951196+00	2026-04-13 13:29:17.821116+00	0.000	0.000	tracked
9c2ccb88-40d9-47de-9b2b-480d82c50e7c	201504f6-3716-569b-9502-2a404a8cbb03	كعب قنطره هاند مكسر 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:18:51.02469+00	2026-04-13 13:44:27.815492+00	0.000	0.000	tracked
0ee2584f-6386-447a-898f-27cd91fa584d	df634c7a-d345-505a-82a4-2bdc2e899a7b	مدخنه مقاس (4)		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 12:29:11.54565+00	2026-04-13 13:44:43.267291+00	0.000	0.000	tracked
3fd2efb0-19b6-470f-9092-dd0823473c82	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	جلبة 4" سيلكون 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 13:16:21.199123+00	2026-04-13 13:44:48.764579+00	0.000	0.000	tracked
91e61835-47cd-4f2b-ab57-012a307a2c79	1a1d02e5-073c-5e69-ad71-5432e235bfa5	افيز مجوز بلاستيك 1"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 12:44:14.476502+00	2026-04-13 13:44:57.141587+00	0.000	0.000	tracked
12a192bf-25f2-43bb-b1e5-94ac6cb5e62b	1a1d02e5-073c-5e69-ad71-5432e235bfa5	افيز فردي بلاستيك 1/2		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 12:21:29.335745+00	2026-04-13 13:45:06.525218+00	0.000	0.000	tracked
98a0d6e7-821f-45f3-8d99-52cd2e6d4699	1a1d02e5-073c-5e69-ad71-5432e235bfa5	افيز بلاستيك مجوز 1/2		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 12:20:28.174336+00	2026-04-13 13:45:11.149592+00	0.000	0.000	tracked
67e52b55-eb97-4426-bf88-5fc459bf9141	f170e76b-4135-5781-b898-91e1259af14f	سوستة دوش 50سم سرديس 		عدد	60.00	45.00	38.00		\N	\N	\N	\N	t	2026-04-12 17:33:33.727029+00	2026-04-13 13:46:56.225539+00	0.000	0.000	tracked
029b8c6c-707a-49a1-be04-96aea6010416	f170e76b-4135-5781-b898-91e1259af14f	سوستة دش 30 سم 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 16:46:06.433355+00	2026-04-13 13:47:01.807425+00	0.000	0.000	tracked
05772215-09f1-41a4-91b3-e56c69ec58db	5d243e5e-b20e-5f54-9828-e080a13b0a39	طاسه دش جوهره 15*15		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 15:45:50.800583+00	2026-04-13 13:47:05.915368+00	0.000	0.000	tracked
61a43033-a203-475e-bfc2-c843163a2756	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعه 15*15تاتش مستورد 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 15:20:53.658416+00	2026-04-13 13:47:09.981495+00	0.000	0.000	tracked
ae6ca5a9-4e53-4085-b698-2f78efea5482	3990e818-7790-55bf-9cf9-6a7e45c45026	صامولة زنق هاند مكسر محمل نحاس		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:27:41.889632+00	2026-04-13 13:47:17.9414+00	0.000	0.000	tracked
e37b5235-d605-445d-93ca-4b6af20f76ac	3990e818-7790-55bf-9cf9-6a7e45c45026	صامولة زنق هاند مكسر نحاس 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:25:48.519315+00	2026-04-13 13:47:22.34238+00	0.000	0.000	tracked
b525a8da-0947-4909-8a88-3ee52b4de015	f0906684-99d3-55aa-9994-9427e941823e	لفة سلك 6 ملي سويدي 		متر	0.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-13 14:08:41.650846+00	2026-04-13 14:21:50.845543+00	0.000	0.000	untracked
437f52ee-b323-4a5b-a6cf-aaac3b2e4691	db5470af-2e31-4a61-b24c-b2ff749c469b	لفة سلك 3 ملي سويدي 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 14:25:00.672588+00	2026-04-13 14:25:34.313574+00	0.000	0.000	tracked
c0bb6a9f-74a3-451e-bbe4-155987c92339	db5470af-2e31-4a61-b24c-b2ff749c469b	لفة سلك 4 ملي سويدي 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 14:25:27.047156+00	2026-04-13 14:25:36.877415+00	0.000	0.000	tracked
0a9b79fd-9500-41b5-bd72-86f8c282ecfb	717cca0e-559c-409e-8623-d47ecff326c6	حنفية غسالة BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 14:30:35.421724+00	2026-04-15 14:18:11.200349+00	0.000	0.000	tracked
567716d2-0cca-4d9d-a291-f5e070c5b0a0	3990e818-7790-55bf-9cf9-6a7e45c45026	بوش 1/2 نحاس		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:34:35.221843+00	2026-04-15 14:18:56.53535+00	0.000	0.000	tracked
999b9700-0527-4039-8d38-cd9b484ccd46	7f15ec9b-720f-580d-ad54-61fcb04a20d9	بوش 1*3/4 نيكل 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:36:39.567556+00	2026-04-15 14:19:00.217298+00	0.000	0.000	tracked
add73888-1d66-435e-bdc6-31e24d57718a	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل 3/4*1/2 نيكل		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:42:00.407498+00	2026-04-15 15:37:09.101104+00	0.000	0.000	tracked
28ef30d2-959f-470e-868c-6d1b638cfeb1	49ebba26-a7d1-42a2-bb7a-850f732f1f78	تي مسلوب 1*3/4 بولي		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-17 11:28:02.213953+00	2026-04-17 11:29:06.496221+00	0.000	0.000	tracked
eb80381b-f03c-4b75-b499-0ce239678953	6e5adb99-fc20-4ec3-9366-8427dcc2a094	جلبة بسن داخلي 4"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-17 11:32:01.142891+00	2026-04-17 11:32:09.065547+00	0.000	0.000	tracked
431857ef-7002-4208-836b-2d92a8b886db	d0b68374-c340-51f8-8e0b-eab0a823c6f5	كوع بباب 4" ابيض BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:41:26.42557+00	2026-04-22 14:41:38.986672+00	0.000	0.000	tracked
fe50fee1-d638-4dbb-9e55-d8ee6d6716ec	5c708129-4240-5f6a-bd5d-7ed1c5434d1e	نقاص 2 * 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:51:54.81516+00	2026-02-08 12:51:54.81516+00	0.000	0.000	untracked
2eeb97e3-ce9d-4ced-ba71-4de536b02669	9a3e6604-1d9e-59a2-9306-b96751e63a08	جلبة بسن 1*1خارجي لحام BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:40:58.41808+00	2026-04-22 13:42:04.372911+00	0.000	0.000	tracked
9e79c962-150d-4880-8b93-31cb260ba8fd	63e2904c-e0db-55e5-9f40-d5f84a85a501	محبس دفن 3/4*3/4 BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:47:02.168488+00	2026-04-22 13:47:14.534042+00	0.000	0.000	tracked
f612c100-6427-4c00-b507-11311a312843	0b85b586-e81d-5b04-866a-afd2726601fc	محبس بلية 2" BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:14:52.201086+00	2026-04-22 14:15:04.576844+00	0.000	0.000	tracked
c28b3b82-82ae-4845-ab2a-4dfd414ee5ca	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	جلبة 3/4 *1/2 بسن داخلي BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:20:14.869067+00	2026-04-22 14:20:27.551504+00	0.000	0.000	tracked
7b0b59ed-bf39-46a2-8e35-e974084cb919	2b737b5c-2894-4b2d-b076-b80d8a50f8a5	نقاص 3/2 ابيض 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:48:41.274701+00	2026-04-22 14:49:09.938423+00	0.000	0.000	tracked
4179d2bc-a6da-476b-aa18-1d919852e3c9	d0b68374-c340-51f8-8e0b-eab0a823c6f5	جلبة 4" 110 BR ابيض 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:50:31.221898+00	2026-04-22 14:50:41.794992+00	0.000	0.000	tracked
b262a202-b104-436c-961b-749be916955c	63e2904c-e0db-55e5-9f40-d5f84a85a501	جلبة بسن 3/4*1/2 BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:37:37.508683+00	2026-04-22 14:22:39.537923+00	0.000	0.000	tracked
da76bac1-e445-4b78-881d-49e35771b067	d0b68374-c340-51f8-8e0b-eab0a823c6f5	مشترك 4*2 بباب BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:26:40.10093+00	2026-04-22 14:26:48.207963+00	0.000	0.000	tracked
68a41885-4ec7-40c5-a891-c45002ddecb9	d0b68374-c340-51f8-8e0b-eab0a823c6f5	مشترك 4" بباب BR ابيض 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:40:23.198547+00	2026-04-22 15:13:56.911781+00	0.000	0.000	tracked
0c08bdc9-fa2c-437e-98df-0b56837b1315	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كرنك لحام 1/2" طويل بولي BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:56:45.845165+00	2026-04-22 13:56:54.345633+00	0.000	0.000	tracked
dc312bb2-984d-4c5b-8f9d-f5a0a165eb78	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية سالمكو 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 16:21:08.240786+00	2026-04-12 16:21:44.447723+00	0.000	0.000	tracked
0a23f4fe-5242-49be-8b49-2618e47be277	1a1d02e5-073c-5e69-ad71-5432e235bfa5	حامل سماعة دش ثابته		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 13:18:26.527241+00	2026-04-13 13:18:37.675978+00	0.000	0.000	tracked
19f9e986-7a6d-43b3-99c8-424277fb7b01	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامه بدون بالونه نحاس 1"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 13:37:06.18429+00	2026-04-13 13:29:25.99081+00	0.000	0.000	tracked
b817632a-1b1c-4494-bbef-2dcc9c54aff5	df634c7a-d345-505a-82a4-2bdc2e899a7b	عوامة جنب كيس		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 13:28:57.351925+00	2026-04-13 13:29:30.758704+00	0.000	0.000	tracked
6c53ac78-8c67-4b7d-9417-fe21bb9cad2c	201504f6-3716-569b-9502-2a404a8cbb03	صامولة كعب هاند ميكسر 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:10:35.219759+00	2026-04-13 13:45:34.095144+00	0.000	0.000	tracked
41fe92be-9e23-406a-90bc-04734c30a5a9	3990e818-7790-55bf-9cf9-6a7e45c45026	جلبة نحاس 3/4*1/2 (جلبة سماعه)		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:38:54.961136+00	2026-04-13 13:45:40.141855+00	0.000	0.000	tracked
8eb4090c-1096-43f2-acd8-31efcbd7e315	1a1d02e5-073c-5e69-ad71-5432e235bfa5	افيز مجوز 3/4 بلاستيك		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 12:42:57.916679+00	2026-04-13 13:45:50.879926+00	0.000	0.000	tracked
830adebb-e1c8-4e24-86fe-26eda9b4fbc7	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية استلس ستار طويل 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 16:30:48.273081+00	2026-04-13 13:45:56.375921+00	0.000	0.000	tracked
98f52e8f-3949-4c87-a044-f01790695506	1a1d02e5-073c-5e69-ad71-5432e235bfa5	افيز فردي بلاستيك 1"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 13:11:43.766421+00	2026-04-13 13:46:01.34362+00	0.000	0.000	tracked
fb178da9-8ff8-4431-9e53-ff8773d684ad	f170e76b-4135-5781-b898-91e1259af14f	سوستة دش 40 سم فايف ستار 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 16:47:22.763411+00	2026-04-13 13:46:06.934125+00	0.000	0.000	tracked
745efab6-e9cb-4323-8d17-a2fe2c555010	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 6 لينا وش اوكره 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 14:56:33.752983+00	2026-04-13 13:46:22.366706+00	0.000	0.000	tracked
9b9ca756-26a9-4567-970d-715c339b6d48	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعه مطبخ متحركه فايف ستار		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:19:12.705353+00	2026-04-13 13:46:32.138361+00	0.000	0.000	tracked
1ac52e2c-94b4-473a-8bab-7bacc1ac2673	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	جلبة سليكون 2"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 12:30:55.633451+00	2026-04-13 13:46:39.476057+00	0.000	0.000	tracked
4f371ebc-a80b-413d-8224-7c7458e3fc6a	f170e76b-4135-5781-b898-91e1259af14f	سوستة 10سم 	\N	عدد	20.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:56:22.223581+00	2026-04-13 13:47:42.558024+00	0.000	0.000	tracked
69eb82c2-d146-45da-947e-df7d9c7e91c6	63e2904c-e0db-55e5-9f40-d5f84a85a501	محبس بلية 3/4" BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:02:15.262595+00	2026-04-22 14:02:27.346157+00	0.000	0.000	tracked
bc621655-d111-43be-b3a7-b860e8e487c7	7f15ec9b-720f-580d-ad54-61fcb04a20d9	بوش نيكل 3/8 *1/2		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:31:15.575818+00	2026-04-15 14:18:16.906838+00	0.000	0.000	tracked
92d13d9b-4fda-4f70-b4a2-158fdac5eb08	63e2904c-e0db-55e5-9f40-d5f84a85a501	T لحام 3/4*1 BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:17:36.21048+00	2026-04-22 14:17:48.714118+00	0.000	0.000	tracked
a470a716-8bc7-4c3b-a4d2-ada3f0dafdd9	f170e76b-4135-5781-b898-91e1259af14f	سوستة 3/8 * 3/8 محملة 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:56:46.094901+00	2026-04-15 15:06:41.746956+00	0.000	0.000	tracked
2f9198ab-da9a-4a8a-9746-d9e451336cf9	2f560337-5a50-59c7-92ed-2a14c0dbd904	كوع 1.5 BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 16:20:48.054875+00	2026-04-22 16:20:48.054875+00	0.000	0.000	untracked
a57c48df-95f9-4c17-bff1-82c1d151b0b0	49ebba26-a7d1-42a2-bb7a-850f732f1f78	نقاص 1*3/4 بولي		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-17 11:28:42.677622+00	2026-04-17 11:29:25.924477+00	0.000	0.000	tracked
e583e7c1-b883-4bca-bd92-c79c07f3102a	49ebba26-a7d1-42a2-bb7a-850f732f1f78	نقاص 1*1.5بولي		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-17 11:29:55.932101+00	2026-04-17 11:30:03.918895+00	0.000	0.000	tracked
a87a4c13-b30d-40ac-bffc-38f73ef2f141	9a3e6604-1d9e-59a2-9306-b96751e63a08	جلبة بسن داخلي 1*1بولي BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 13:42:47.488943+00	2026-04-22 13:42:59.123321+00	0.000	0.000	tracked
31147ad9-de4f-4ee1-aaa2-4f86cce7963a	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حنفية فلتر 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:21:53.176613+00	2026-04-12 12:12:54.866063+00	0.000	0.000	tracked
e204e8a5-b604-4547-9484-1f498d6dc46d	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 تاتش AM 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:26:20.132173+00	2026-04-12 14:20:47.024288+00	0.000	0.000	untracked
0d6d6f68-4a79-41fb-9c7c-2d8274a55354	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 تاتش MK	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:26:30.691931+00	2026-04-12 14:20:57.218602+00	0.000	0.000	untracked
26988569-34c5-4e63-884c-e618d9c3820a	3990e818-7790-55bf-9cf9-6a7e45c45026	نبل 2" نحاس		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:46:58.703543+00	2026-04-13 13:48:01.328505+00	0.000	0.000	tracked
02c411bc-4988-4422-bc60-fa2acc687b5c	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكنه صندوق ضغط ان جي		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:37:12.408822+00	2026-04-13 13:48:14.126712+00	0.000	0.000	tracked
20076dde-b7fc-463a-af90-381696236d45	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكنه صندوق تربو 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:36:21.083271+00	2026-04-13 13:48:19.590173+00	0.000	0.000	tracked
2d4491e6-7f57-4c93-a720-a7be5d68b4b9	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكنه صندوق الامين جنب 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 18:35:23.066746+00	2026-04-13 13:48:25.471568+00	0.000	0.000	tracked
45b3d31e-23e5-4b53-ad46-e71044fd702b	daf8935a-6a30-5667-ac81-f4a398cbc305	طقم مسمار صندوق 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 13:21:16.637652+00	2026-04-13 14:09:43.40548+00	0.000	0.000	tracked
c36eaf49-88a6-453a-badd-ebef0c1e6ee5	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3" رمادي بزبالة بلاستيك 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 14:01:47.207838+00	2026-04-13 14:09:53.798454+00	0.000	0.000	tracked
b846a51a-8875-4a9c-9afc-19b7b5eea618	db5470af-2e31-4a61-b24c-b2ff749c469b	لفة سلك 6 ملي سويدي 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 14:21:25.469551+00	2026-04-13 14:25:39.484279+00	0.000	0.000	tracked
c5b2afd8-2550-4d3b-8a3d-3ff6bef14544	3990e818-7790-55bf-9cf9-6a7e45c45026	بوش 1/2*3/4 نحاس 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 17:33:13.437346+00	2026-04-15 14:19:03.203598+00	0.000	0.000	tracked
41ff54cc-6f6b-4366-a49d-4dc4378f813a	1cea07a9-ef47-5aa1-9143-71481f27f43c	ماسوره 20مم		عدد	29.50	0.00	0.00		\N	\N	\N	\N	f	2026-04-18 19:54:51.396946+00	2026-04-18 19:59:26.292964+00	0.000	0.000	tracked
fd5f3438-24bf-427a-9f05-b93ef2e6e983	9a3e6604-1d9e-59a2-9306-b96751e63a08	محبس بلية 1" BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:03:02.979609+00	2026-04-22 14:03:17.423824+00	0.000	0.000	tracked
80e1b844-6853-4d0e-b574-51a38644a638	d0b68374-c340-51f8-8e0b-eab0a823c6f5	كوع 4" 45 110" BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:51:53.363069+00	2026-04-22 14:52:04.105645+00	0.000	0.000	tracked
e7640605-a1fb-4ed5-96de-952bdfd35d01	d0b68374-c340-51f8-8e0b-eab0a823c6f5	طبه 4" 110 BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 15:23:08.432583+00	2026-04-22 15:26:35.381136+00	0.000	0.000	tracked
920dd176-0c14-4215-87bd-0af9eb30cbf0	2c85857a-6249-557c-892b-8dd099fce6af	جلبة 3" 75		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 16:16:27.374168+00	2026-04-22 16:16:38.120685+00	0.000	0.000	tracked
2c4c4d5b-db29-4f28-b53e-bb2aaecab809	df634c7a-d345-505a-82a4-2bdc2e899a7b	مدخنه مقاس (5)		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 12:27:53.382727+00	2026-04-12 12:28:38.994878+00	0.000	0.000	tracked
0d2c4abe-8714-4cea-b01e-967e024ad4cb	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامه 1.5" نحاس		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 13:38:07.533609+00	2026-04-13 13:29:28.446431+00	0.000	0.000	tracked
c8dbcca5-dcae-485a-aeae-deea53ae1586	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة مطبخ 5 لينا اوكره 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 14:53:38.614401+00	2026-04-13 13:48:33.579012+00	0.000	0.000	tracked
803dc7a3-eb72-458f-82eb-a1bed2a9157c	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعه تاتش لومي 15*15		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 15:17:43.199751+00	2026-04-13 13:48:37.917004+00	0.000	0.000	tracked
6c38825d-4c46-4892-a768-255e236c306b	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعه تاتش 20*20 مستورد 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 15:22:04.797209+00	2026-04-13 13:48:42.317549+00	0.000	0.000	tracked
d60e69da-7058-429d-8890-144bf710100b	5d243e5e-b20e-5f54-9828-e080a13b0a39	طاسة دش معدن 15*15		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 15:50:53.289249+00	2026-04-13 13:48:46.638267+00	0.000	0.000	tracked
b419fb16-6f5d-478c-8ce4-c19a2e25f8c2	5d243e5e-b20e-5f54-9828-e080a13b0a39	سوسته دش جولدن 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 16:10:33.508059+00	2026-04-13 13:48:51.830821+00	0.000	0.000	tracked
85c4336b-4190-4737-a888-a83dee164695	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كوع 1/2" بولي BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 16:29:44.312771+00	2026-04-15 14:24:40.030121+00	0.000	0.000	tracked
327257f0-e96b-4e86-8094-0e1216466f99	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	جلبة 1/2" بولي BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 16:36:14.210045+00	2026-04-15 14:24:43.764534+00	0.000	0.000	tracked
1ce42d75-79fd-472f-8613-41af9ac5559c	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	طبة اختبار 1/2" 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 17:10:51.905073+00	2026-04-17 11:33:07.793111+00	0.000	0.000	tracked
11be2aad-959d-44fa-b21d-0adf241669ac	717cca0e-559c-409e-8623-d47ecff326c6	جركن عازل اسمنتي		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 14:25:05.036565+00	2026-04-22 14:25:15.266815+00	0.000	0.000	tracked
3854671f-68b4-489a-865a-8c80fb2a80d5	d0b68374-c340-51f8-8e0b-eab0a823c6f5	مشترك 4/2 110" BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 15:12:08.34542+00	2026-04-22 15:12:19.287411+00	0.000	0.000	tracked
f0b655f9-def6-4462-9d88-7a334725016e	2c85857a-6249-557c-892b-8dd099fce6af	مشترك 3" مفتوح 75 BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-22 15:15:34.259092+00	2026-04-22 15:16:40.866845+00	0.000	0.000	tracked
c44ffb44-d7cc-4ab0-b7c7-6b0c073b059e	daf8935a-6a30-5667-ac81-f4a398cbc305	نوزل شطاف بالخرطوم كامل (أنس)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:30:58.500228+00	2026-02-01 16:30:58.500228+00	0.000	0.000	untracked
7c033855-5e8a-44e7-a03a-c91729b55080	753bd696-70ef-5e78-bd15-456428b31687	كوع عاده 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:06:54.889056+00	2026-02-08 14:06:54.889056+00	0.000	0.000	untracked
96057283-03bb-4f16-a011-5b4e00628633	f170e76b-4135-5781-b898-91e1259af14f	سوستة دوش سلامكو 		عدد	70.00	60.00	48.00		\N	\N	\N	\N	t	2026-04-12 17:41:35.709218+00	2026-04-12 17:43:29.370876+00	0.000	0.000	tracked
13187950-a7ec-4e6c-a0e1-a08dbb28666a	f170e76b-4135-5781-b898-91e1259af14f	سوستة دش 50 م فايف ستار 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 16:48:32.305183+00	2026-04-13 13:49:26.582519+00	0.000	0.000	tracked
b3790156-be36-4d7a-9bb2-cf9ebe405cad	f170e76b-4135-5781-b898-91e1259af14f	سوستة دش روما  30 سم 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-12 16:44:26.217678+00	2026-04-13 13:49:30.590876+00	0.000	0.000	tracked
a2e0f808-484f-4e7a-8fc7-bbdd41e2e3cc	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	تي 1/2" بولي BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 16:38:14.258008+00	2026-04-15 14:24:55.052377+00	0.000	0.000	tracked
e945e2a1-188f-4855-88be-ea4cb303aaa5	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	جلبة بسن خارجي 1/2 BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 17:07:43.799002+00	2026-04-15 14:25:18.855495+00	0.000	0.000	tracked
427bdbf1-0a40-491a-bff7-7ea64a086ea0	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كوع بسن 1/2*1/2 بولي BR 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 16:39:56.809961+00	2026-04-22 13:13:18.956933+00	0.000	0.000	tracked
ee38e66f-0104-46d4-a30f-798a7fdde029	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	جلبة بسن داخلي 1/2" BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 17:09:20.855853+00	2026-04-15 14:25:04.815961+00	0.000	0.000	tracked
198fe32c-37df-43bf-9d75-db5bf327abfb	46f96c6a-23fd-5740-849e-61de853f07aa	جلبة بسن خارجي 1 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:59:34.73245+00	2026-01-26 21:59:34.73245+00	0.000	0.000	untracked
b81afeec-6c16-455a-8aed-b6a43abd3b9b	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 1.5 كبايه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 19:16:38.530868+00	2026-04-13 13:49:47.92245+00	0.000	0.000	tracked
c66c0732-d798-447c-a1d8-9fc73cd6396d	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	تي بسن داخلي 1/2" BR		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-13 17:10:22.233013+00	2026-04-15 14:25:10.206433+00	0.000	0.000	tracked
b3c35aa0-469b-4e4e-8560-1dec134adfbf	d5901618-eafd-5ad1-b0e6-f0f56f1cda35	كوع بسن 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 21:03:06.498596+00	2026-04-15 14:26:06.631463+00	0.000	0.000	untracked
24fb14a1-81cd-4bff-934c-979871903865	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شجرة وش 1/2 محمل ديتوريا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:06:35.725891+00	2026-01-22 15:06:35.725891+00	0.000	0.000	untracked
97565e26-97a2-4284-ba09-ae9b8f8b6be2	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شجرة دش اوكر (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:08:25.838261+00	2026-01-22 15:08:25.838261+00	0.000	0.000	untracked
338cbd11-8f82-4e1f-851b-c36446f165a0	d5901618-eafd-5ad1-b0e6-f0f56f1cda35	جلبة بسن داخلي 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 21:04:39.88191+00	2026-04-15 14:26:08.680492+00	0.000	0.000	untracked
69c84270-5d73-406f-a0f6-4509aa6ffd14	ae20d096-97b0-524d-bf38-e8865a491102	وش و زور مشتمل دفن 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 00:59:53.495774+00	2026-04-13 13:50:18.873377+00	0.000	0.000	tracked
c8b78e53-a457-4b32-8897-c449f3fe1e4f	7f15ec9b-720f-580d-ad54-61fcb04a20d9	محبس بالأكور سالمكو محمل بوصة (ادهم)	\N	عدد	320.00	220.00	10.00	\N	\N	\N	\N	\N	t	2026-01-18 19:53:20.393421+00	2026-04-15 14:29:47.661516+00	0.000	0.000	untracked
6aa50703-922e-4b64-a284-90ed8be49d64	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 2" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:26:08.143744+00	2026-02-17 17:26:08.143744+00	0.000	0.000	untracked
c3fa9713-cfff-4df1-a1be-e67923363d0a	ae20d096-97b0-524d-bf38-e8865a491102	خرطوم سوستة	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 00:59:41.182496+00	2026-03-10 00:59:41.182496+00	0.000	0.000	untracked
5b317e75-8dcd-4ae8-8a1e-ee0de4afc793	ae20d096-97b0-524d-bf38-e8865a491102	شيك بلف 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:01:03.95927+00	2026-03-10 01:01:03.95927+00	0.000	0.000	untracked
a2f62574-cda1-4f08-b38e-4cb5d32188b6	ae20d096-97b0-524d-bf38-e8865a491102	مجرى خرج مجوز	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:01:18.567212+00	2026-03-10 01:01:18.567212+00	0.000	0.000	untracked
7e3e1e0b-859d-4b02-abd3-95199402ec4c	0a625299-9939-57bf-9214-75c4fa91e993	ثمن لزق 900 بارد 	\N	عدد	75.00	50.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-04-12 14:20:23.857989+00	0.000	0.000	untracked
accc59f1-42a1-4501-b345-658bcec88377	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينة جنب 2" تربو		عدد	120.00	0.00	0.00	تربو	\N	\N	\N	\N	t	2026-04-01 14:35:59.755089+00	2026-04-01 14:35:59.755089+00	0.000	0.000	untracked
d327c0dd-7a93-4935-bb1b-30c523147993	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينة شداد 1.5" تربو		عدد	0.00	0.00	0.00	تربو	\N	\N	\N	\N	t	2026-04-01 14:41:03.919728+00	2026-04-01 14:41:03.919728+00	0.000	0.000	untracked
cf75658d-4804-42d6-bd8f-edf3a77549be	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه رمادى (ساليمكو )	\N	عدد	75.00	38.00	30.00	\N	\N	\N	\N	\N	t	2026-02-02 19:16:58.666155+00	2026-04-13 13:56:03.245255+00	0.000	0.000	tracked
a828ddc0-5d87-4062-a86a-a50dcf685191	df634c7a-d345-505a-82a4-2bdc2e899a7b	شداد سيفون قصير		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-08 16:13:17.464556+00	2026-04-08 16:13:33.66516+00	0.000	0.000	untracked
142261d6-cfbb-480a-8077-6e1e674a5d66	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سيليكون 114		عدد	0.00	0.00	0.00	غير معروف	\N	\N	\N	\N	t	2026-04-01 14:52:46.85334+00	2026-04-13 14:10:53.494802+00	0.000	0.000	untracked
115d93bd-f3b5-42e8-9c3d-eb8a677d4d63	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سيليكون 2.5"		عدد	0.00	0.00	0.00	غير معروف	\N	\N	\N	\N	t	2026-04-01 14:57:07.11459+00	2026-04-13 14:10:56.463298+00	0.000	0.000	untracked
8e3760bd-0096-493b-9e0e-e96262b63371	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه بباب سوستة 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-08 17:48:11.591395+00	2026-04-13 14:11:11.757258+00	0.000	0.000	tracked
bb158824-4c3b-4a7e-b7ab-3f7478148361	6e48e18f-bfe0-59e7-81ac-090ada6061b2	طبة كاب 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:59:57.327557+00	2026-02-08 12:59:57.327557+00	0.000	0.000	untracked
60f411d9-101b-4fac-9476-9c3156ca32e5	6e48e18f-bfe0-59e7-81ac-090ada6061b2	تي 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:02:31.006671+00	2026-02-08 13:02:31.006671+00	0.000	0.000	untracked
8e2b3882-c6fc-42c0-85b9-1ce43ec06076	6e48e18f-bfe0-59e7-81ac-090ada6061b2	تي 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:31:49.745179+00	2026-02-08 14:31:49.745179+00	0.000	0.000	untracked
892d2704-38a2-4e62-a752-066a045fe36e	6e48e18f-bfe0-59e7-81ac-090ada6061b2	كوع سن داخلي 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:35:15.357294+00	2026-02-08 14:35:15.357294+00	0.000	0.000	untracked
b667424e-e746-44bc-9c47-839e858bc00a	69c8851c-0e49-50f6-aa84-346755ef3132	مشترك باب 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:46:09.557466+00	2026-02-08 12:46:09.557466+00	0.000	0.000	untracked
baeea72c-a311-41bf-9680-40ae18dca71c	69c8851c-0e49-50f6-aa84-346755ef3132	جلبة 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:46:17.630758+00	2026-02-08 12:46:17.630758+00	0.000	0.000	untracked
39742801-02c4-47fe-bdf9-55c330e781ca	69c8851c-0e49-50f6-aa84-346755ef3132	واي 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:46:26.81403+00	2026-02-08 12:46:26.81403+00	0.000	0.000	untracked
e6fd727d-e3c4-4364-a327-d6718553c39b	69c8851c-0e49-50f6-aa84-346755ef3132	طبة كاب 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:46:39.949684+00	2026-02-08 12:46:39.949684+00	0.000	0.000	untracked
0b66cdef-de0b-4e0d-a091-0c6478c6edd0	69c8851c-0e49-50f6-aa84-346755ef3132	كوع باب 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:23:02.439219+00	2026-02-08 13:23:02.439219+00	0.000	0.000	untracked
4856275a-91cb-4889-bc57-4e10e1b703c9	69c8851c-0e49-50f6-aa84-346755ef3132	هواية 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:23:50.82904+00	2026-02-08 14:23:50.82904+00	0.000	0.000	untracked
888d9a19-395c-4cbe-b334-346cb8006b9a	69c8851c-0e49-50f6-aa84-346755ef3132	جلبة سن داخلي 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:36:26.909287+00	2026-02-08 14:36:26.909287+00	0.000	0.000	untracked
e7eb5039-f585-4133-8a5c-30d2c64211d1	0ff37f54-86c4-5e7b-a45b-7b0f059fe533	طبة تسليك 3"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:55:40.174127+00	2026-02-08 12:55:40.174127+00	0.000	0.000	untracked
e660c870-680d-4c0d-ac35-ad6c4e0740a6	0ff37f54-86c4-5e7b-a45b-7b0f059fe533	طبة كاب 3"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:59:14.46174+00	2026-02-08 12:59:14.46174+00	0.000	0.000	untracked
23644c4a-953b-46df-8f24-f28a6f04466e	0ff37f54-86c4-5e7b-a45b-7b0f059fe533	هواية 3"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:23:13.549607+00	2026-02-08 14:23:13.549607+00	0.000	0.000	untracked
8f92156d-4980-4897-a21d-6bb7a3001734	0ff37f54-86c4-5e7b-a45b-7b0f059fe533	جرجوري 3"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:43:11.372835+00	2026-02-08 14:43:11.372835+00	0.000	0.000	untracked
8671c2bd-ccab-45f7-8ef1-6c75e1c56809	33f73ec5-118e-5a83-bf95-62e0ba535dff	طبة كاب 4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:58:43.480198+00	2026-02-08 12:58:43.480198+00	0.000	0.000	untracked
9a23640f-c9b3-4037-866f-df3e018fe0b6	33f73ec5-118e-5a83-bf95-62e0ba535dff	طبة تسليك 4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:04:25.583595+00	2026-02-08 13:04:25.583595+00	0.000	0.000	untracked
182d1f97-9302-4f7b-9482-dbbd0206af9d	33f73ec5-118e-5a83-bf95-62e0ba535dff	هواية 4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:14:20.365837+00	2026-02-08 14:14:20.365837+00	0.000	0.000	untracked
8733206d-6230-4c5d-8b7d-eb3f9fd26123	33f73ec5-118e-5a83-bf95-62e0ba535dff	جرجوري 4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:41:12.668569+00	2026-02-08 14:41:12.668569+00	0.000	0.000	untracked
ab4ea6d5-f256-48e0-ac8b-cfa800182482	fab03014-2cfb-57bf-aa2f-7998e3b33df2	نقاص 1.5 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:13:45.774354+00	2026-02-08 13:13:45.774354+00	0.000	0.000	untracked
53746d4e-4530-4d61-9b35-294b61f4618c	e51e11b8-471d-57ed-96e7-1fbe83eb4965	نقاص 1.5 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:21:56.575712+00	2026-02-08 13:21:56.575712+00	0.000	0.000	untracked
57925e1a-2021-417f-8be6-34d1bdef1dfb	692519e0-6295-5892-9d1d-91cad5f3dd85	نقاص 2 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:24:04.046593+00	2026-02-08 13:24:04.046593+00	0.000	0.000	untracked
672e317a-e3e5-42d5-8da2-40b152ca973e	201504f6-3716-569b-9502-2a404a8cbb03	طقم شداد خلاط هاند مكسر 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:24:53.652054+00	2026-04-09 15:24:53.652054+00	0.000	0.000	untracked
d8044cc3-b892-4d4d-b108-e5d2dc39134b	201504f6-3716-569b-9502-2a404a8cbb03	طقم تثبيت خلاط شجرة 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:25:38.063466+00	2026-04-09 15:25:38.063466+00	0.000	0.000	untracked
e78feee1-8757-433d-9a58-27338aaf1655	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية كولمن قصيرة 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 10:43:48.393413+00	2026-04-11 10:43:48.393413+00	0.000	0.000	untracked
dc5466a4-a4b3-4a4d-b1c9-789c67538f53	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجة جمب		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 11:54:58.965924+00	2026-04-11 11:54:58.965924+00	0.000	0.000	untracked
be51fd0b-c2ec-4539-94fa-e4929c926ea2	7b07a8a7-291e-504c-82ec-e7b14467ff8c	ع9بهيبليق		عدد	3434.00	3434.00	34.00		\N	\N	\N	\N	f	2026-04-04 14:34:17.251818+00	2026-04-04 14:34:52.970451+00	0.000	0.000	untracked
4f3dbaf3-4941-439c-92bb-adaf9464e207	7b07a8a7-291e-504c-82ec-e7b14467ff8c	شكرتون كهرباء صغير 		عدد	30.00	25.00	0.00		\N	\N	\N	\N	t	2026-04-03 17:59:44.824439+00	2026-04-05 14:00:11.05392+00	0.000	0.000	untracked
b420fae1-65c7-47f3-aebd-4ec5dac6eb6e	df634c7a-d345-505a-82a4-2bdc2e899a7b	منيجا سالمكو طبه سوستة فار 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-08 16:31:45.740822+00	2026-04-09 13:36:38.662738+00	0.000	0.000	untracked
fc34d4b3-7215-42ae-9c64-eb7d8b003cda	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامة خزان استانلس 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-04-13 13:29:34.505711+00	0.000	0.000	tracked
caef7973-c811-4391-bc0d-07a8f5ef6087	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينة جنب 1.5" تربو		عدد	0.00	0.00	0.00	تربو	\N	\N	\N	\N	t	2026-04-01 14:36:55.547184+00	2026-04-13 14:11:33.207154+00	0.000	0.000	tracked
d739fea9-b75f-4059-901f-eec4c0483b53	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب هاند ميكسر تكات كبير 	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:27:53.619265+00	2026-04-04 09:26:20.843749+00	0.000	0.000	untracked
36f3a9bc-a99c-4079-8845-41a73a850097	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سيليكون 110		عدد	0.00	0.00	0.00	غير معروف	\N	\N	\N	\N	t	2026-04-01 14:54:17.368283+00	2026-04-13 14:11:42.662037+00	0.000	0.000	untracked
f9e48d97-167b-443e-bb9f-0dcc047bad58	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة هاند ميكسر وش 	\N	عدد	90.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-04-13 14:11:48.102602+00	0.000	0.000	tracked
0f81a2a2-6a73-4278-836d-a08c10fb0238	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكنة ضغط فرست 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 14:29:09.249098+00	2026-04-13 14:12:07.469212+00	0.000	0.000	tracked
258a592c-948d-42c9-8c2d-8bfa4641b016	201504f6-3716-569b-9502-2a404a8cbb03	صامولة قنطرة 5 لينا 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:15:47.734201+00	2026-04-13 14:12:12.709487+00	0.000	0.000	tracked
2777c8de-00ad-419f-bd60-236b2e52effa	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية كولمن طويلة		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 10:44:14.015801+00	2026-04-13 14:12:19.382493+00	0.000	0.000	tracked
2f0bead1-730a-45f1-9ce9-71f11246b94f	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2/3	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:31:44.286884+00	2026-02-08 13:31:44.286884+00	0.000	0.000	untracked
bb5f4a08-269d-41b4-993b-2ea33302507a	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:53:05.869834+00	2026-02-08 13:53:05.869834+00	0.000	0.000	untracked
2de17cf9-3fe3-4533-a032-818ffdb0eea5	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2/2 عالية	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:55:32.159269+00	2026-02-08 13:55:32.159269+00	0.000	0.000	untracked
9df6119f-d341-4c6d-a93e-674107276697	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2 * 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:01:15.933689+00	2026-02-08 14:01:15.933689+00	0.000	0.000	untracked
e3a7418f-9d48-48df-b265-6e20a4c0667a	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2 * 1.5 عالية	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:01:55.965237+00	2026-02-08 14:01:55.965237+00	0.000	0.000	untracked
40faef4c-37c9-4ecb-a603-b377687bed9c	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة شاور 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:02:36.061897+00	2026-02-08 14:02:36.061897+00	0.000	0.000	untracked
46653e57-d6d2-4fa1-9ea9-c4095da20503	dd2b913d-417a-55cf-8fa4-c539aa173fc3	جلبة 1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:22:34.239712+00	2026-01-22 11:22:34.239712+00	0.000	0.000	untracked
2efc200a-fa8f-4bc8-8b04-ddc3491110df	dd2b913d-417a-55cf-8fa4-c539aa173fc3	تي 1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:23:13.728784+00	2026-01-22 11:23:13.728784+00	0.000	0.000	untracked
ea231ea8-7b79-4616-b5ff-7133ce3b9355	dd2b913d-417a-55cf-8fa4-c539aa173fc3	كوع بسن 1/2 (بلال)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:24:56.592898+00	2026-01-22 11:24:56.592898+00	0.000	0.000	untracked
f9ab2612-e5b6-448b-b85b-a41883850361	dd2b913d-417a-55cf-8fa4-c539aa173fc3	تي بسن 1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:32:33.403478+00	2026-01-22 18:32:33.403478+00	0.000	0.000	untracked
fbe38b09-fe9a-4053-9587-bbf370223390	dd2b913d-417a-55cf-8fa4-c539aa173fc3	جلبة سن داخلي نص بوصة (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:33:04.378991+00	2026-01-22 18:33:04.378991+00	0.000	0.000	untracked
d144b604-d157-4c59-8006-25da0df08daf	dd2b913d-417a-55cf-8fa4-c539aa173fc3	كوع لحام نص بوصة (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:33:28.412125+00	2026-01-22 18:33:28.412125+00	0.000	0.000	untracked
5261d27a-2f3f-43db-97de-7d90d039facf	dd2b913d-417a-55cf-8fa4-c539aa173fc3	كرنك 1/2" طويل (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:37:33.986183+00	2026-01-25 10:37:33.986183+00	0.000	0.000	untracked
f1ff0933-c92e-41d2-a794-809088048e47	dd2b913d-417a-55cf-8fa4-c539aa173fc3	كوع بسن داخلي 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 13:43:08.04037+00	2026-01-27 13:43:08.04037+00	0.000	0.000	untracked
3fa1f00e-e4e3-4884-81b3-404b8de81e1b	605f3728-7c52-5f81-a820-2f56527a37b2	كوع 3/4 (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:21:32.032575+00	2026-01-22 11:21:32.032575+00	0.000	0.000	untracked
320e8a3d-d0df-4ac8-ba39-cc0fcd9e9b99	605f3728-7c52-5f81-a820-2f56527a37b2	جلبة 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:21:54.654868+00	2026-01-22 11:21:54.654868+00	0.000	0.000	untracked
e74dc2f7-3677-4e8c-912e-9ef271bbba67	605f3728-7c52-5f81-a820-2f56527a37b2	تي 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:26:47.72345+00	2026-01-22 18:26:47.72345+00	0.000	0.000	untracked
1a2576db-4e4b-4e7f-8c93-d601687d5cd3	605f3728-7c52-5f81-a820-2f56527a37b2	كرنك 3/4" صغير (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:38:47.313577+00	2026-01-25 10:38:47.313577+00	0.000	0.000	untracked
422b5b97-7734-4947-afd8-cd7171cdc1b3	605f3728-7c52-5f81-a820-2f56527a37b2	كرنك 3/4" كبير (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:39:07.953462+00	2026-01-25 10:39:07.953462+00	0.000	0.000	untracked
39fbc351-60c0-4c49-914c-390c09215664	201504f6-3716-569b-9502-2a404a8cbb03	طقم كرنك خلاط نحاس		عدد	90.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 09:12:51.586987+00	2026-04-04 09:12:51.586987+00	0.000	0.000	untracked
69213b66-dcf4-4bab-a2b5-79af4480e472	7f47135b-3fea-5482-90d6-acef9402708e	محبس بلاكور 1/2"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-04 10:02:59.905062+00	2026-04-04 10:33:12.833499+00	0.000	0.000	untracked
e928f12e-8a09-46dd-9269-2189cf393524	7f47135b-3fea-5482-90d6-acef9402708e	محبس بلية 3/4"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-04 10:04:40.32452+00	2026-04-04 10:33:15.631479+00	0.000	0.000	untracked
4ba979a4-5c14-4e95-a68a-c3453e5b2341	7f47135b-3fea-5482-90d6-acef9402708e	محبس بلاكور 1"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-04 10:08:20.177745+00	2026-04-04 10:33:18.216364+00	0.000	0.000	untracked
b9d03115-22e0-4c3e-b064-8c08dd658389	df634c7a-d345-505a-82a4-2bdc2e899a7b	اوكره جمب استلس 		عدد	50.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-08 16:17:44.09591+00	2026-04-08 16:18:04.252645+00	0.000	0.000	untracked
644330ab-aa5e-424d-a11d-2a66436161da	939f4e0e-dd51-54d3-9737-dfa50e8363e7	طابق بانيو محمل 		عدد	190.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 16:02:08.810624+00	2026-04-13 14:12:34.453601+00	0.000	0.000	untracked
19ca0c73-ab1d-41ee-8a08-45121c253710	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	كوتشة سيفون (1.5, 2)		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 12:03:41.947252+00	2026-04-13 14:12:51.423252+00	0.000	0.000	tracked
b75b4bad-63d7-4336-a14d-b95c9a221e74	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بسن داخلي 3/4		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 15:21:39.015588+00	2026-04-15 15:42:45.054602+00	0.000	0.000	tracked
a268d0b4-97d9-4f49-99c3-19491bc9f078	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينة شداد 2" تربو		عدد	0.00	0.00	0.00	تربو	\N	\N	\N	\N	t	2026-04-01 14:39:58.103714+00	2026-04-13 14:12:59.728165+00	0.000	0.000	tracked
ac0cbfea-84d2-4e19-9d5c-130b926174e9	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	محبس لاكور 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 20:36:07.194753+00	2026-04-13 16:25:14.950736+00	0.000	0.000	untracked
d29b5399-d05a-441e-907e-664b9caaded4	201504f6-3716-569b-9502-2a404a8cbb03	كعب خلاط استالنس	\N	عدد	15.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:46:58.581873+00	2026-04-04 09:23:56.273961+00	0.000	0.000	untracked
ba67d7df-9487-4059-996b-a0ce57ed1f1d	df634c7a-d345-505a-82a4-2bdc2e899a7b	حنفية جمب 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 14:30:39.812034+00	2026-04-13 14:13:54.53513+00	0.000	0.000	tracked
959c3547-fa77-4cc0-a105-c9f8e9252092	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية شيلد		عدد	150.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 17:12:27.535814+00	2026-04-04 17:12:36.30226+00	0.000	0.000	untracked
0668c81e-e210-485a-bd0f-4d072c702c6e	df634c7a-d345-505a-82a4-2bdc2e899a7b	اوكره جمب بلاستيك 		عدد	0.00	0.00	0.00	طيب	\N	\N	\N	\N	t	2026-04-08 16:19:48.101805+00	2026-04-13 14:14:13.982617+00	0.000	0.000	tracked
3b4c474b-bcca-4785-8c8e-29b2b42e5a79	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كرنك 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 20:36:42.246455+00	2026-04-13 16:25:16.869424+00	0.000	0.000	untracked
c43bc70d-9e2d-49b9-89df-7e8396361190	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كرنك طويل 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 20:40:30.035555+00	2026-04-13 16:25:19.706043+00	0.000	0.000	untracked
a7c6cd69-4a08-4d2a-9ebf-817df83510f6	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	طبه اختبار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 21:22:29.439955+00	2026-04-13 16:25:22.326489+00	0.000	0.000	untracked
365c40f7-a07a-4fd9-bc17-468c7fb2536e	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل 3/8*1/2 نيكل 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:28:47.50298+00	2026-04-13 14:14:24.16718+00	0.000	0.000	tracked
fb0d86fd-7ffc-4290-831b-19ac15f5c448	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بسن خارجي 1" بسن نحاس		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 15:28:24.855997+00	2026-04-15 15:42:48.950545+00	0.000	0.000	tracked
f9f94c31-4ab6-4b16-860c-42b07f2fe7ac	63e2904c-e0db-55e5-9f40-d5f84a85a501	كوع لحام 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:15:16.749339+00	2026-04-17 11:33:36.333829+00	0.000	0.000	tracked
3cc22441-f1e7-4186-b81f-37d1e1548fd6	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	صامولة نبل شجرة 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:23:04.586477+00	2026-04-13 14:14:30.007303+00	0.000	0.000	tracked
99a28536-9fce-497d-b168-b3a14c79d5c1	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل خلاط نيكل		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 10:49:13.846514+00	2026-04-13 14:14:41.565016+00	0.000	0.000	tracked
728d6023-951b-4a19-8cfb-d62631ab5736	daf8935a-6a30-5667-ac81-f4a398cbc305	مسمار قاعدة كليوباترا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:59:24.143925+00	2026-04-13 14:14:55.638155+00	0.000	0.000	tracked
a2afe05f-3beb-49bd-a5ba-36565fdd14cb	605f3728-7c52-5f81-a820-2f56527a37b2	جلبة لحام 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 14:37:19.811175+00	2026-01-27 14:37:19.811175+00	0.000	0.000	untracked
88fdb5d9-d19d-4087-aba0-19adfca71918	605f3728-7c52-5f81-a820-2f56527a37b2	تي لحام 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 14:37:45.667488+00	2026-01-27 14:37:45.667488+00	0.000	0.000	untracked
f1e6d3ae-1a60-4187-af58-d0309ad4de89	412d5f95-e302-5cfc-aa6b-12cb95411b3f	جلبة سن خارجي 1/2*1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:23:52.353189+00	2026-01-22 11:23:52.353189+00	0.000	0.000	untracked
d05db9fb-adba-4899-8736-7c7d1c8172e1	412d5f95-e302-5cfc-aa6b-12cb95411b3f	تي سن داخلي 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 16:35:13.25749+00	2026-01-27 16:35:13.25749+00	0.000	0.000	untracked
e124b922-be63-4889-9c39-d2c339ac546e	c6db36fa-a81c-58bc-b7d6-608f8d3ae1d1	كوع لحام 1/2 * 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 15:14:06.928674+00	2026-01-27 15:14:06.928674+00	0.000	0.000	untracked
914922e9-da51-442c-9e3f-8839b9fa251f	5e9fdd71-7989-5122-b2d6-49bc9ba8851c	كوع بسن داخلي 3/4 * 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:28:15.515477+00	2026-01-22 18:28:15.515477+00	0.000	0.000	untracked
f6de776c-d026-48e0-a682-85eebc4b4cbd	ab9446cf-95d8-5574-b37a-e54d68e708fe	كوع بسن داخلي 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:27:26.332496+00	2026-03-24 12:33:07.688217+00	0.000	0.000	untracked
01466b3d-dd2f-47f7-991f-988d273d3a3b	978af021-a666-5101-af9e-ed05c156645b	ماسورة 75 (3")	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:35:03.878094+00	2026-02-10 13:35:03.878094+00	0.000	0.000	untracked
b18c3367-ee65-4e16-8e4f-a1148284aaae	978af021-a666-5101-af9e-ed05c156645b	ماسورة 4"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:36:40.870273+00	2026-02-10 13:36:40.870273+00	0.000	0.000	untracked
e3171dc4-a972-40ef-8452-ade0250302fa	978af021-a666-5101-af9e-ed05c156645b	ماسورة 2	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:37:28.557743+00	2026-02-10 13:37:28.557743+00	0.000	0.000	untracked
4a86af6d-e32f-4b72-a561-f98020e19e26	978af021-a666-5101-af9e-ed05c156645b	ماسورة 1.5"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:38:55.086831+00	2026-02-10 13:38:55.086831+00	0.000	0.000	untracked
006eaf5f-789b-47a7-9106-944764fdc08b	978af021-a666-5101-af9e-ed05c156645b	ماسورة 1"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:39:16.678477+00	2026-02-10 13:39:16.678477+00	0.000	0.000	untracked
74460fc9-5b94-427c-b129-876231ab5674	978af021-a666-5101-af9e-ed05c156645b	قواطع ماسورة 75	\N	متر	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:40:19.983297+00	2026-02-10 13:40:19.983297+00	0.000	0.000	untracked
ff0e6f72-8440-4a9c-9a71-470453065413	978af021-a666-5101-af9e-ed05c156645b	قواطع ماسورة 2"	\N	متر	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:40:58.11851+00	2026-02-10 13:40:58.11851+00	0.000	0.000	untracked
38add71e-db1c-4c7b-a43d-6b79280ec3dc	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	جلبة فلتر 3/4 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 12:53:45.831514+00	2026-04-11 12:53:45.831514+00	0.000	0.000	untracked
6a3a5dfa-5075-4b9a-a36a-52c655d5eab9	94f8de20-fe91-4ebd-9c16-1ce74e99b797	متر بولي 1/2" PN20 المصرية الالمانية		متر	0.00	0.00	0.00	BFS	\N	\N	\N	\N	t	2026-04-04 09:29:11.45188+00	2026-04-04 09:29:33.65694+00	0.000	0.000	untracked
308c8c23-3ebf-4676-bc47-cdac99a59f17	7f47135b-3fea-5482-90d6-acef9402708e	محبس بلية 1"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-04 10:11:36.082076+00	2026-04-04 10:33:20.650709+00	0.000	0.000	untracked
54b51aca-a22a-4638-a14d-f4052eddb90a	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كوع لحام 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 20:30:04.076514+00	2026-04-13 16:25:03.75212+00	0.000	0.000	untracked
d90ce028-6aeb-4cbe-916b-d5941eb564d3	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	جلبة لحام 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 20:31:02.904767+00	2026-04-13 16:25:06.291939+00	0.000	0.000	untracked
1d039edf-9ba6-45b7-ac98-cbf42cf7ef49	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	تي لحام 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 20:32:42.822347+00	2026-04-13 16:25:08.98819+00	0.000	0.000	untracked
efa431de-b26f-4add-b34c-b4bb0c6a1f3d	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	طبة كاب 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 20:34:09.788818+00	2026-04-13 16:25:12.636208+00	0.000	0.000	untracked
bb6e8e5f-10ce-4074-a838-5afc4bfd8c9b	63e2904c-e0db-55e5-9f40-d5f84a85a501	T دفن 3/4 BR	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:15:45.928637+00	2026-04-22 13:49:04.19432+00	0.000	0.000	tracked
7a96c6f0-022b-44be-81d3-88b909f472d1	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سيليكون بقفيز 2"		عدد	0.00	0.00	0.00	غير معروف	\N	\N	\N	\N	t	2026-04-01 14:50:26.749499+00	2026-04-01 14:50:26.749499+00	0.000	0.000	untracked
b05c8b96-3c17-4d83-9665-e4da5bbb6529	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سيليكون 6"		عدد	0.00	0.00	0.00	غير معروف	\N	\N	\N	\N	t	2026-04-01 14:55:12.035709+00	2026-04-01 14:55:12.035709+00	0.000	0.000	untracked
66a44e6e-ba10-4e53-96ee-b41b8af644eb	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون كوب نيو فولد 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 14:53:16.073775+00	2026-04-09 14:53:16.073775+00	0.000	0.000	untracked
819e0c3a-b235-4ddb-bd47-6663768def49	201504f6-3716-569b-9502-2a404a8cbb03	طقم كرنك مشاكل 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:13:56.387195+00	2026-04-09 15:13:56.387195+00	0.000	0.000	untracked
885638eb-a9ca-4ee2-bf74-5730e5852bc6	201504f6-3716-569b-9502-2a404a8cbb03	صامولة زنق 1/2 "		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:16:48.648599+00	2026-04-09 15:16:48.648599+00	0.000	0.000	untracked
e7f5a544-04fd-4b2d-9146-fb79df577821	df634c7a-d345-505a-82a4-2bdc2e899a7b	طبة صندوق طرد		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 10:50:42.766966+00	2026-04-11 10:50:42.766966+00	0.000	0.000	untracked
8cf7eef1-0a73-491c-b6cc-8222f3c45595	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش بلاستيك مشكل	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-04-12 16:17:00.584166+00	0.000	0.000	tracked
811c48aa-84b6-4bed-9771-3e6dd162e9a6	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية استانلس ستار قصير 	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-04-12 16:29:50.226407+00	0.000	0.000	tracked
ec991740-f53e-42ea-9e48-6af7a7696248	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس فايف ستار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-29 12:46:12.866726+00	2026-04-12 16:32:37.180476+00	0.000	0.000	untracked
ae78cb21-9bf8-441a-a101-6be57eb4f2c0	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة لومي (يوسف)	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-04-15 14:29:34.172113+00	0.000	0.000	tracked
53a3e08e-728d-4291-b2f7-9cc69a69cbac	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية ايطالي نص بوصة (يوسف)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 19:56:06.791359+00	2026-02-21 15:16:06.543079+00	0.000	0.000	untracked
982d6fa2-8c29-4580-863a-215600003c9b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية نحاس AG نص بوصة (يوسف)	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 10:21:43.6071+00	2026-02-21 15:15:10.630101+00	0.000	0.000	untracked
bca0c8ae-6b62-4ad0-a150-47fbd9955eab	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية كوبشة شيلد (عمار)	\N	عدد	180.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:33:28.660709+00	2026-02-23 19:47:15.577099+00	0.000	0.000	untracked
4008a90d-eda0-4bc9-b7d9-0401c419b3e1	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية كوبشة شجرة	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:34:25.603146+00	2026-02-23 19:47:19.616332+00	0.000	0.000	untracked
bd473534-32ba-4522-912d-ab3c9f59ac24	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية غسالة تركي OM	\N	عدد	190.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:34:47.580728+00	2026-02-23 19:48:02.91339+00	0.000	0.000	untracked
27b32f29-2ac8-445e-aaf4-531e4cabd48c	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية 3/4 بزبوز بلاستيك	\N	عدد	180.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 13:07:55.312027+00	2026-02-23 19:49:11.168989+00	0.000	0.000	untracked
4b596a39-71ad-4be0-adcb-82637141438e	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية استانلس تورو	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000	untracked
fd927c9a-2843-4740-b97e-c92f51424765	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية فايف ستار اسود	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000	untracked
5b18456a-9aee-431f-8344-81bda7d32061	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية مكة	\N	عدد	130.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:50:33.033144+00	2026-01-29 12:50:33.033144+00	0.000	0.000	untracked
06030f57-05d3-4624-ab21-4f2dbd36628c	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية بلاستيك تركي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 09:40:16.889555+00	2026-02-10 09:40:16.889555+00	0.000	0.000	untracked
92d27d2a-5f22-47c2-a167-4b6fc0908e3e	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية بلية 1/2 فيدمار	\N	قطعة	150.00	135.00	125.00	\N	\N	\N	\N	\N	t	2026-03-15 16:46:04.748045+00	2026-03-15 16:46:04.748045+00	0.000	0.000	untracked
9d19a1d3-c280-4944-879b-0db02b1ebfc9	7f15ec9b-720f-580d-ad54-61fcb04a20d9	وش نيكل خفيف (عمر)	\N	عدد	20.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:55:34.840636+00	2026-02-23 19:51:36.048033+00	0.000	0.000	untracked
7652a593-90d8-4ba8-9bf0-d1f452915da4	7f15ec9b-720f-580d-ad54-61fcb04a20d9	ماسورة دش دفن مدورة (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:24:50.477843+00	2026-02-23 19:52:11.728847+00	0.000	0.000	untracked
13ab7f8d-4d5c-495d-9665-b12b51ba8097	7f15ec9b-720f-580d-ad54-61fcb04a20d9	ماسورة دش دفن عكاز (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:27:22.798+00	2026-02-24 13:32:50.124984+00	0.000	0.000	untracked
b3634d52-7df0-4e6c-89a9-2887f761f7aa	7f15ec9b-720f-580d-ad54-61fcb04a20d9	ماسورة دش دفن مربعة طويلة (الكوك)	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:28:21.375167+00	2026-02-23 19:52:28.863685+00	0.000	0.000	untracked
65907699-7b64-4dd9-9ea8-d9f8cb23c6f4	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة شاور ست	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-01-29 12:42:36.459591+00	0.000	0.000	untracked
af31725d-fa0f-42df-88d4-9041e36ad994	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالاكور 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:12:18.345365+00	2026-04-04 10:36:43.832473+00	0.000	0.000	untracked
b9b32325-fda4-46a7-b4f4-6da187863e4a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالاكور بولي  1/2 "	\N	عدد	50.00	45.00	40.00	\N	\N	\N	\N	\N	t	2026-01-19 18:59:35.718523+00	2026-04-04 10:37:22.552833+00	0.000	0.000	untracked
ca985298-d266-4483-8a13-ff73c90536dc	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالاكور بولي 1 "	\N	عدد	90.00	80.00	72.00	\N	\N	\N	\N	\N	t	2026-01-19 19:02:29.385696+00	2026-04-04 10:38:06.062384+00	0.000	0.000	untracked
ffa8d86a-6352-4d4c-a6f1-76622d09b032	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 2" جويل 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:36:06.982384+00	2026-04-04 10:38:38.568599+00	0.000	0.000	untracked
c5e11e14-9dd2-487d-9c2e-27b59ba3408f	d17128f8-94aa-54ce-87d8-4dc515f98bf8	test product to delete	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-03-25 18:45:45.235033+00	2026-03-25 18:45:45.331357+00	0.000	0.000	untracked
d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالاكور فالكون 1/2 "	\N	عدد	90.00	85.00	70.00	\N	\N	\N	\N	\N	t	2026-01-20 14:10:40.162417+00	2026-04-04 10:39:22.814387+00	0.000	0.000	untracked
2ac3dc85-e7cf-4ff1-8aff-01e6d8fd54a1	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:37:50.742321+00	2026-04-04 10:39:35.465261+00	0.000	0.000	untracked
8af6f47a-5f64-4895-945b-fd307a9859f3	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	جلبة فلتر 1/2		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 12:54:52.708122+00	2026-04-11 12:54:52.708122+00	0.000	0.000	untracked
8d0b7fc0-80de-406e-9491-a6784fa8afcd	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	افيز لاتش 1"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 09:57:26.0183+00	2026-04-04 09:57:26.0183+00	0.000	0.000	untracked
82fe00a0-9b9f-413b-833e-48161df96eec	7f47135b-3fea-5482-90d6-acef9402708e	محبس بلية 1/2"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-04 10:03:23.317231+00	2026-04-04 10:33:23.605515+00	0.000	0.000	untracked
05099d66-09c8-4389-8d33-6a95b96de74e	eb886d53-bd4d-559c-ba48-dd925c0a9cb6	كوع صرف 4" 114 المصرية الالمانية		عدد	97.00	87.50	0.00	BFS	\N	\N	\N	\N	t	2026-04-05 13:23:26.353428+00	2026-04-05 13:23:30.288703+00	0.000	0.000	untracked
6c1a7601-4298-4f3f-be83-c3e4abdedaf4	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية استلس 	\N	قطعة	60.00	35.00	31.00	\N	\N	\N	\N	\N	t	2026-03-15 17:12:44.252251+00	2026-04-12 16:32:55.557484+00	0.000	0.000	tracked
bf47a971-4a38-4adf-84b7-0f838da38a57	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش ساليمكو	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-29 12:42:36.459591+00	2026-04-15 14:30:16.667314+00	0.000	0.000	untracked
244e72f6-2f15-49f4-8526-3b485ebb345b	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة فيدمار سوداء 	\N	عدد	280.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:22:00.846063+00	2026-04-15 14:43:22.007866+00	0.000	0.000	tracked
07ad204e-14a8-4bec-92e2-3997be506cc5	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	جلبة كوتشة محول فلتر		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 12:55:24.282925+00	2026-04-11 12:55:24.282925+00	0.000	0.000	untracked
744fdb5a-3deb-4d50-9439-d30f3df343a0	7f47135b-3fea-5482-90d6-acef9402708e	محبس بلاكور 3/4"		عدد	0.00	0.00	0.00		\N	\N	\N	\N	f	2026-04-04 10:05:09.361049+00	2026-04-04 10:33:25.978948+00	0.000	0.000	untracked
2128f377-5cf5-4f1f-bcf8-ae290ba38075	5c708129-4240-5f6a-bd5d-7ed1c5434d1e	بلاعة 2*1.5"		عدد	75.00	67.50	0.00	روك	\N	\N	\N	\N	t	2026-04-05 13:36:59.209539+00	2026-04-05 13:37:02.630676+00	0.000	0.000	untracked
4c7f2b6e-8a67-489f-ad91-257ba78a7f51	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاويه اوزو نحاس	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-04-12 16:25:57.662033+00	0.000	0.000	tracked
edf6547d-ee07-419d-a822-18de5c4ac63d	7f15ec9b-720f-580d-ad54-61fcb04a20d9	بوش نيكل 3/4*1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:57:47.40477+00	2026-04-15 14:19:06.526378+00	0.000	0.000	tracked
ab4ba887-5c44-4a22-b567-670c0001b603	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:41:05.350297+00	2026-04-04 10:39:48.871289+00	0.000	0.000	untracked
c19f42ec-ad6d-4161-9f38-a9c4cecb643b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 3/4 " سالمكو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:43:07.366133+00	2026-04-04 10:40:08.674618+00	0.000	0.000	untracked
6d2e9857-cc51-4c79-aa4d-d7b9e4208678	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 3/4 ِ" AG	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:43:28.77324+00	2026-04-04 10:40:22.838528+00	0.000	0.000	untracked
67ba969e-da10-4bbd-9900-606bf254045b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية PG" 1/2 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:47:44.278206+00	2026-04-04 10:40:45.649587+00	0.000	0.000	untracked
d14ac884-8431-46ba-adcb-5190dbaf9da0	d17128f8-94aa-54ce-87d8-4dc515f98bf8	تي نيكل 1/2"	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:48:02.678005+00	2026-04-04 10:40:58.436629+00	0.000	0.000	untracked
695705d9-9757-4f2a-be89-fe096ffd87c2	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 1/2 "AG	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:48:44.598128+00	2026-04-04 10:41:18.831808+00	0.000	0.000	untracked
9f86c75d-e220-45e8-95a2-405be7b53488	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 1"سالمكو 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 10:53:10.372659+00	2026-04-04 10:42:02.271411+00	0.000	0.000	untracked
b7d3a006-f7a1-40d6-b3d8-20192e7f93bf	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالاكور سالمكو محمل 3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 15:36:22.061533+00	2026-04-04 10:42:45.4857+00	0.000	0.000	untracked
b41ae764-b97b-4662-b865-b572790ec127	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالاكور عادي محمل 3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 15:36:46.589467+00	2026-04-04 10:43:02.843111+00	0.000	0.000	untracked
85114c68-11e1-442b-a79d-0279c2bb798b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية  3/4 سكاي	\N	عدد	220.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 16:37:17.691787+00	2026-04-04 10:43:24.019405+00	0.000	0.000	untracked
92a238d8-f2da-4c28-9127-fbc8cece0c0b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية بوز بلاستيك AG (يوسف)	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 18:20:28.450377+00	2026-04-04 11:02:12.15772+00	0.000	0.000	untracked
bf75d681-d9d1-4af8-871f-2ed687b63fd1	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية كعب نحاس	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000	untracked
b09598b6-4537-4e39-b28b-d50cb6d8d19a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس سما	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000	untracked
ed7dc576-4868-491e-847f-08379201a129	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور 3/4 BG	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 13:33:59.109432+00	2026-01-30 13:33:59.109432+00	0.000	0.000	untracked
77badf35-82f3-4f15-9645-864081747352	69c8851c-0e49-50f6-aa84-346755ef3132	قشرة 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:43:30.573237+00	2026-02-08 14:43:30.573237+00	0.000	0.000	untracked
d268cf2c-4306-4069-92de-d1879e230952	7f15ec9b-720f-580d-ad54-61fcb04a20d9	محول سماعة صامولة	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:54:05.665427+00	0.000	0.000	untracked
17ef1e9c-6898-494a-8e97-ecf2af3f72fb	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دوش 1مم 20 * 20 استانلس رانك محملة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-02-23 19:54:57.02382+00	0.000	0.000	untracked
c06966da-9cdb-4ed6-9296-177f3a63b307	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دوش 1" 20 * 20 استانلس روما محملة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000	untracked
7838761b-9eb9-46bb-a99e-c09e677377a9	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 10 * 10 استلس لافينا	\N	عدد	90.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-02-24 13:33:59.227101+00	0.000	0.000	untracked
7e625f21-6107-40ed-a03a-280e64655065	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 10 * 10 سنبرس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000	untracked
432e6e7e-c5ea-4639-a2ca-b3cac3b07617	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش استانلس 10 * 10 جولدن ارو	\N	عدد	90.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-02-24 13:34:44.651586+00	0.000	0.000	untracked
309e1a4a-3b5b-4aba-a3f0-375f8bb26b69	116387e4-1052-4100-aad0-740a50b15de0	حله 0.5 مللي فيدمار ك	\N	قطعة	750.00	520.00	465.00	\N	\N	\N	\N	\N	t	2026-03-15 16:37:15.629092+00	2026-04-15 14:31:24.324489+00	0.000	0.000	untracked
0a078193-e0d3-4669-b71b-5a4fdda5f8f9	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش طيبة سرعات	\N	عدد	180.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-04-15 14:30:37.556172+00	0.000	0.000	untracked
35f48cd9-aa95-45dc-91f8-239baa9e8572	116387e4-1052-4100-aad0-740a50b15de0	حله 1 ملي فيدمار ص	\N	قطعة	850.00	750.00	645.00	\N	\N	\N	\N	\N	t	2026-03-15 16:42:33.251321+00	2026-04-15 14:31:33.620312+00	0.000	0.000	untracked
a59c2e11-fed2-4972-a7e5-bc34fd5266fd	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 10 * 10 ترنتي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-04-15 14:33:47.55071+00	0.000	0.000	tracked
ff6f769c-0bfb-49fc-86cf-e73805d51892	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 20 * 20 بلاستيك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-04-15 14:34:05.24086+00	0.000	0.000	tracked
ba07f41a-a9f8-4e30-bb91-be5cfa125019	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 15 * 15 ترنتي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-04-15 14:34:00.282774+00	0.000	0.000	untracked
ff573b1e-dc23-4f5c-b48b-ca3aa2ae1a1a	116387e4-1052-4100-aad0-740a50b15de0	حله 5 زرار فيدمار	\N	قطعة	5500.00	4850.00	3750.00	\N	\N	\N	\N	\N	t	2026-03-15 16:47:55.014009+00	2026-04-15 14:38:47.842211+00	0.000	0.000	untracked
f9256353-ac61-4e15-8dff-4cad2591bda2	116387e4-1052-4100-aad0-740a50b15de0	حله 0.5 فيدمار ص	\N	قطعة	480.00	380.00	285.00	\N	صغير	\N	\N	\N	t	2026-03-15 16:40:15.885174+00	2026-04-15 14:38:57.83171+00	0.000	0.000	untracked
cd3b2528-421e-4761-b84e-90651f4cfd3f	7f15ec9b-720f-580d-ad54-61fcb04a20d9	صبانه استالس	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:23:21.840221+00	2026-04-15 14:39:25.434979+00	0.000	0.000	tracked
f0b0cc99-32e6-4b1a-8493-25be82e03e31	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طبة حوض نيكل	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 15:41:13.227521+00	2026-04-15 14:39:48.647368+00	0.000	0.000	tracked
813e8a9d-af7f-496c-80da-0eab496e15df	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 15 * 15 ارساني	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-04-15 14:40:36.613767+00	0.000	0.000	tracked
d1aa753f-65da-40f1-8548-eed1df9fac72	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش طيبة بلاستيك	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-04-15 14:40:16.467619+00	0.000	0.000	untracked
871b0c43-957e-4eb5-b5f0-4609014c1885	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش مدورة كبيرة بلاستيك	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-04-15 14:41:15.853513+00	0.000	0.000	tracked
4005644b-b6d1-45f8-8af9-7929eca4e075	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دوش 15 * 15 جولدن ارو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-04-15 14:40:53.167938+00	0.000	0.000	untracked
a4d3df08-ac1d-4f42-82f3-da2fdbeb1958	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 15 * 15 بلاستيك	\N	عدد	100.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-04-15 14:41:08.589142+00	0.000	0.000	untracked
d75fcff2-ef64-48b3-9cd8-e06d40e3a399	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة فيدمار بيضاء	\N	عدد	250.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-04-15 14:41:31.510233+00	0.000	0.000	tracked
1a73646e-94d9-4857-92dc-496a90475520	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 20*20 سان ارساني (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-29 12:43:30.531794+00	2026-04-15 14:42:08.520918+00	0.000	0.000	untracked
f8361f30-bb8d-4a44-bc2d-3ae7ef72f027	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل شجرة 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:21:29.597426+00	2026-04-15 15:37:17.52461+00	0.000	0.000	tracked
ff053f4f-7e5e-44a6-a452-893663ae65be	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة فايدمار سوداء	\N	عدد	280.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-29 12:42:36.459591+00	2026-04-15 14:42:29.899171+00	0.000	0.000	tracked
3a6f01a4-e9a4-4032-8b64-35410b5a8d5e	7f15ec9b-720f-580d-ad54-61fcb04a20d9	محول سماعة بدون صاموصة	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-04-15 14:43:00.865724+00	0.000	0.000	untracked
6972c97c-fdb0-4a9b-b563-06ec0ac883c3	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	طبة نيكل 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:39:22.422214+00	2026-04-15 14:52:11.690742+00	0.000	0.000	tracked
0fd12267-532b-4474-b66e-a1ffa378a6c9	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة جرومي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-04-12 14:42:53.359991+00	0.000	0.000	tracked
ae005153-de66-49ed-b132-23434ecacf5c	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة ستار خفيفة 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-04-12 14:40:02.72529+00	0.000	0.000	tracked
72635b19-9fcc-4fd6-9ada-b9cf33bb50a0	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة الوان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-04-12 15:27:50.112854+00	0.000	0.000	tracked
111bc6b3-d484-49b9-adab-2e9790badcde	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	كيس مسامير قلب خشن 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-04-04 09:28:14.916795+00	0.000	0.000	untracked
340dd769-792d-4917-9d5e-5d73c4eb605d	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	افيز لاتش 2" 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:44:15.445975+00	2026-04-04 09:56:25.556482+00	0.000	0.000	untracked
c9baaa25-10f2-481b-aa74-81d2c5a83f70	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	افيز لاتش 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:44:35.814227+00	2026-04-04 09:56:49.726719+00	0.000	0.000	untracked
7ff32213-f0de-403c-a2b4-df7c66a07a1f	7f15ec9b-720f-580d-ad54-61fcb04a20d9	جلبة تطويل استالس	\N	قطعة	45.00	26.00	21.00	\N	\N	\N	\N	\N	f	2026-03-15 17:00:35.852613+00	2026-04-11 15:08:48.136569+00	0.000	0.000	untracked
980318ab-6084-4cf4-9ee7-b095ffcf96e6	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	جلبة سوستة طويلة	\N	قطعة	70.00	45.00	35.00	\N	\N	\N	\N	\N	f	2026-03-15 17:21:28.131328+00	2026-04-04 09:59:59.535428+00	0.000	0.000	untracked
128ffb7a-b57c-424e-bd25-b6e16dce002d	903c8f75-9786-51d1-956e-f481e1dbf84f	اوكرة بلاستيك شفاف 	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:14:12.808976+00	2026-04-04 10:00:24.183816+00	0.000	0.000	untracked
4e58a261-a2db-4aa2-8a1b-5a4a38ebfed2	903c8f75-9786-51d1-956e-f481e1dbf84f	اوكرة وردة	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:26:03.635992+00	2026-04-04 10:00:31.459532+00	0.000	0.000	untracked
9599e8f6-0e41-4ba6-af39-945ab7b97b91	903c8f75-9786-51d1-956e-f481e1dbf84f	اوكرة جاجوار 	\N	عدد	25.00	12.50	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:25:15.651997+00	2026-04-04 10:00:56.298258+00	0.000	0.000	untracked
c0897fde-d9e6-4626-b027-149b7ae5322e	903c8f75-9786-51d1-956e-f481e1dbf84f	يد هاند ميكسر عريضة محملة 	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:39:46.244078+00	2026-04-04 10:01:12.088418+00	0.000	0.000	untracked
b1690bbc-ba39-4da5-85ea-7e75005ded9b	903c8f75-9786-51d1-956e-f481e1dbf84f	يد هاند ميكسر عريضة	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:41:45.683618+00	2026-04-04 10:01:24.008628+00	0.000	0.000	untracked
4223c273-9145-42c8-8bb6-e2faf2b7a9b4	903c8f75-9786-51d1-956e-f481e1dbf84f	اوكرة بلاستيك (ادهم)	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-20 13:26:48.852523+00	2026-04-04 10:01:32.661389+00	0.000	0.000	untracked
68051f41-2be1-42c1-bed7-53af6544d15b	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة حراري متر ونص فايف ستار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:38:52.731585+00	2026-01-29 12:38:52.731585+00	0.000	0.000	untracked
e34c6775-3e66-462d-80db-5bb4fff9601a	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة حراري 2 متر فايف ستار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:38:52.731585+00	2026-01-29 12:38:52.731585+00	0.000	0.000	untracked
f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور بولي 3/4 "	\N	عدد	75.00	65.00	60.00	\N	\N	\N	\N	\N	t	2026-01-19 18:59:57.014037+00	2026-04-04 10:34:02.940802+00	0.000	0.000	untracked
cb153139-9139-4c4b-b341-9cabab43c132	69f9914c-e165-5167-a85b-6ba46173bba3	حنفيه أسانسير كعب بلاستيك تربو	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 15:49:11.82749+00	2026-04-05 14:07:12.180979+00	0.000	0.000	untracked
da68d7f2-f8d7-44bb-85a3-d91ab5d02ffa	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 2" PG pluse 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:36:50.56777+00	2026-04-04 10:38:47.743744+00	0.000	0.000	untracked
a1651be8-8cf4-4662-b40f-2173c9bef33d	f170e76b-4135-5781-b898-91e1259af14f	سوستة 80سم	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:51:11.568774+00	2026-04-15 15:31:59.489789+00	0.000	0.000	tracked
879040b7-642e-443d-a467-cb4a3cbc5bc3	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة ستار محملة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-04-12 16:14:59.700653+00	0.000	0.000	tracked
83759832-7ee5-43fc-8828-695b2d8c7c3e	7f15ec9b-720f-580d-ad54-61fcb04a20d9	صامولة سيخ شطاف	\N	عدد	10.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:03:52.832692+00	2026-04-15 14:31:00.989127+00	0.000	0.000	tracked
9eff5877-e547-41bf-980d-10c679112e9c	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة لوكس تكات	\N	قطعة	150.00	95.00	80.00	\N	\N	\N	\N	\N	t	2026-03-15 17:15:33.643842+00	2026-04-15 14:30:46.18942+00	0.000	0.000	untracked
3892616c-8ad0-47d2-aebc-ba3c30cefb39	7f15ec9b-720f-580d-ad54-61fcb04a20d9	محول دش	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:41:52.557812+00	2026-04-15 14:38:23.033619+00	0.000	0.000	tracked
1d1a007d-0b0d-40fe-9be0-7116cf80a675	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة عادية	\N	قطعة	130.00	85.00	70.00	\N	\N	\N	\N	\N	t	2026-03-15 17:17:02.331845+00	2026-04-15 14:40:30.380004+00	0.000	0.000	untracked
1fe12fb1-b560-4cda-b0cc-db6f35c24079	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	كوع نيكل 1/2" محمل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:42:21.574265+00	2026-04-15 14:52:07.032679+00	0.000	0.000	untracked
70afd455-12ab-4f85-9e1a-5868e01b1511	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	جلبة نيكل 2/1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:02:53.393661+00	2026-04-15 14:52:23.11023+00	0.000	0.000	tracked
6e4b57c6-a303-4249-9f3c-7075f1a14bce	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 80سم 	\N	عدد	55.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:51:40.22396+00	2026-04-15 15:00:34.560957+00	0.000	0.000	tracked
1ab3227c-7697-46a5-8d66-861e81721181	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن كبير 3/4	\N	عدد	100.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:49:53.950398+00	2026-04-15 14:52:38.355788+00	0.000	0.000	untracked
e6b6fddb-3d45-4e26-87b1-a5d13cd14132	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل استانلس 5 سم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:52:55.978731+00	2026-04-15 14:54:37.973039+00	0.000	0.000	untracked
72d5081a-5a3c-42f1-af96-68799e6498d8	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل ماتور	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:53:16.867499+00	2026-04-15 14:59:26.377372+00	0.000	0.000	untracked
5f551abc-5798-4f04-8557-01afc73bb977	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 90سم 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:51:26.448063+00	2026-04-15 15:00:46.844176+00	0.000	0.000	tracked
19a8cf3f-9008-41b9-8383-3a361d6c6f59	f170e76b-4135-5781-b898-91e1259af14f	سوستة متر عادية 	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:49:58.992836+00	2026-04-15 15:32:05.233921+00	0.000	0.000	tracked
8efe2eb5-bd06-48bb-b1ae-b843129e85eb	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 60 سم (يوسف)	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-04-15 15:26:03.622202+00	0.000	0.000	tracked
03c117ec-5a52-40c6-907f-ece60dddfe68	f170e76b-4135-5781-b898-91e1259af14f	سوستة 70سم 	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:50:42.384657+00	2026-04-15 15:32:19.425762+00	0.000	0.000	tracked
db85a468-811d-49b2-8f84-89c4f1aaa3d5	f170e76b-4135-5781-b898-91e1259af14f	سوستة 60 محملة فايف ستار 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-22 15:29:02.765329+00	2026-04-15 15:32:11.421402+00	0.000	0.000	tracked
3d23ca07-4628-4207-a0a3-e34c38daf932	f170e76b-4135-5781-b898-91e1259af14f	سوستة ناشفة 60سم (انس)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:49:36.400484+00	2026-04-15 15:32:15.409676+00	0.000	0.000	tracked
1a29b242-fcb5-49a2-95fd-a12c0de7c030	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة الرحمة 	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-29 12:38:52.731585+00	2026-04-15 15:35:27.246351+00	0.000	0.000	tracked
4b6005cc-aac8-4964-8031-d08ff8f50372	f170e76b-4135-5781-b898-91e1259af14f	سوستة 50 محملة روتانا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-22 15:33:15.214038+00	2026-04-15 15:33:01.116332+00	0.000	0.000	untracked
2e2fe069-9320-4585-b0eb-b079dcf40692	f170e76b-4135-5781-b898-91e1259af14f	سوستة 90سم 	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:50:58.704623+00	2026-04-15 15:31:54.21411+00	0.000	0.000	tracked
cf47fda2-2f58-48c3-aa6e-e33743683878	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة محملة 60 فايف ستار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-22 15:35:12.396915+00	2026-04-15 15:33:03.494105+00	0.000	0.000	untracked
24717bd9-9cb5-47b1-9e14-4780dd676eb3	f170e76b-4135-5781-b898-91e1259af14f	سوستة 60 محملة روتانا 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-22 15:30:33.245796+00	2026-04-15 15:35:55.882597+00	0.000	0.000	tracked
958976e5-78b1-48dd-b90c-639ecac8608e	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل نيكل 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:45:52.790075+00	2026-04-15 15:38:06.040393+00	0.000	0.000	untracked
84d19c17-a7a2-4523-9693-5c45c88a5e48	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بولي 3/4 "	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:14:53.186684+00	2026-04-15 15:44:45.028205+00	0.000	0.000	untracked
d387eae9-d064-43d1-ad43-461553cf6a05	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل نيكل 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:43:22.452043+00	2026-04-15 15:38:21.291426+00	0.000	0.000	untracked
6a92aee9-a9f4-490d-bf5f-37ca073ba4f8	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بولي 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:15:16.691315+00	2026-04-15 15:44:42.169943+00	0.000	0.000	untracked
36a71af5-edd7-4e4c-9b77-fb2b37c53cf8	201504f6-3716-569b-9502-2a404a8cbb03	صامولة قنطرة هاند مكسر  نيكل 		عدد	35.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 11:11:33.258145+00	2026-04-11 17:17:05.228943+00	0.000	0.000	untracked
6cf339ab-5c51-4d0c-a096-98aa08096dbb	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 ساليمكو كرت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:30.876672+00	2026-04-12 14:06:12.581271+00	0.000	0.000	tracked
9ca11fc9-3bed-4caa-8dd9-4c4b09b03709	16c83b9f-b315-5a50-8d09-fd0b8da2ee70	مشترك عادة 2" المصرية الالمانية		عدد	32.00	29.00	0.00	BFS	\N	\N	\N	\N	t	2026-04-05 14:57:24.096537+00	2026-04-05 14:57:27.633743+00	0.000	0.000	untracked
8c5b88b7-459f-4831-b67c-61bfc16c6496	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 سبانش 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:03.581273+00	2026-04-12 14:21:12.440042+00	0.000	0.000	untracked
8c31b689-b723-4b4f-b7a5-3657a4733077	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 السهم الذهبي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:23:58.045634+00	2026-04-12 14:21:05.557453+00	0.000	0.000	untracked
c3a1165c-ac37-4772-b198-5e973ff7ca06	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 ريباني 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:22.97243+00	2026-04-12 14:21:19.453178+00	0.000	0.000	untracked
f3a41c82-cd3e-4ac8-a3cf-49c9a046410c	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب هاند ميكسر بكعب صغير 	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:31:49.419637+00	2026-04-04 09:27:48.204068+00	0.000	0.000	untracked
2eed92b4-8064-48ee-9f2d-7c302bbdb2aa	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب هاند ميكسر بدون كعب صغير 	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:32:28.500164+00	2026-04-04 09:28:37.962128+00	0.000	0.000	untracked
0ae66dbf-16a0-48bf-b13e-eed2701f3cc6	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب هاند ميكسر بكعب كبير	\N	عدد	70.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:37:43.363781+00	2026-04-04 09:29:00.387009+00	0.000	0.000	untracked
b1a685ab-b142-4c3d-95c9-d9100774032d	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب هاند ميكسر بدون كعب كبير 	\N	عدد	55.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:33:17.684343+00	2026-04-04 09:29:21.285591+00	0.000	0.000	untracked
02108d69-33a5-41c9-82f6-6601fc7c7e56	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب هاند ميكسر تكات صغير 	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:38:44.947628+00	2026-04-04 09:29:44.230328+00	0.000	0.000	untracked
66a706c3-065f-4965-b6f5-a416003ca375	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب جولد صغير	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:44:29.582588+00	2026-04-04 09:30:55.479073+00	0.000	0.000	untracked
1e06fee4-89c2-4465-bc78-5b71826b797e	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب 3.5 ايطالي	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:45:02.640757+00	2026-04-04 09:31:15.077998+00	0.000	0.000	untracked
78539233-0e35-4584-8a63-835c6f128067	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب 3 لينيا	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:45:48.201209+00	2026-04-04 09:35:44.631964+00	0.000	0.000	untracked
e2623548-7fd4-4a00-99a6-d772fbc76efa	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن 1/2	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:48:17.733307+00	2026-04-04 09:32:20.458666+00	0.000	0.000	untracked
307e8ebe-dc59-4130-bdc0-363ea0d4caea	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب جولد كبير	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:50:48.984631+00	2026-04-04 09:41:05.08761+00	0.000	0.000	untracked
e178893c-75cf-4e65-a118-70dd4ab0e610	7d25587c-4cf1-4eee-905a-eec5fb7e9f68	قلب 3.5لينا 	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 15:14:21.377007+00	2026-04-04 09:43:51.109295+00	0.000	0.000	untracked
708b57dc-834f-466c-8df4-62b50eb8affb	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن 3/4 صغير	\N	عدد	95.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:48:39.412528+00	2026-04-04 09:45:38.779035+00	0.000	0.000	untracked
c1186f95-835b-4480-96a0-8a0b3edfd1d6	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن 3/4 كبير مربع	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:49:13.489254+00	2026-04-04 09:45:45.828202+00	0.000	0.000	untracked
a710b7fe-897e-43da-808a-c193b7e5573e	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن 1 بوصه	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:49:33.00445+00	2026-04-04 09:47:49.448849+00	0.000	0.000	untracked
2a2a52bb-b8d8-4af4-93d6-41ed8267a589	201504f6-3716-569b-9502-2a404a8cbb03	قلب 1/2 "	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:44:10.223261+00	2026-04-04 11:56:03.214454+00	0.000	0.000	untracked
40cdebca-7a06-49c2-a5fa-850250936c54	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل نحاس محمل 	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:53:16.867499+00	2026-04-15 14:54:12.631828+00	0.000	0.000	tracked
67361216-d048-4bca-9f65-3c1df07745a1	7f15ec9b-720f-580d-ad54-61fcb04a20d9	كوع سناره محمل		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 15:06:59.545699+00	2026-04-11 15:06:59.545699+00	0.000	0.000	untracked
200ed75f-470f-490a-9dbb-56886e13ecd0	f170e76b-4135-5781-b898-91e1259af14f	سوستة 80 سم	\N	قطعة	60.00	19.00	15.00	\N	\N	\N	\N	\N	t	2026-03-15 17:32:35.923758+00	2026-04-24 08:43:50.699092+00	0.000	0.000	untracked
d32342b1-8699-4cab-a46d-c599555abf3c	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 لازا 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:11.413259+00	2026-04-12 14:21:26.302098+00	0.000	0.000	untracked
ce256e73-4b15-4f88-b65e-4247cc702058	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	جلبة 1" نيكل 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 14:40:25.012099+00	2026-04-15 14:43:38.63028+00	0.000	0.000	tracked
76974cd1-2978-4467-ae5a-b558aa71c242	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل استانلس	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:52:55.978731+00	2026-04-15 14:54:16.122682+00	0.000	0.000	tracked
446e88dc-63ad-49b3-9018-6042e55df88e	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل نحاس مشرشه	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:52:55.978731+00	2026-04-15 14:54:20.869125+00	0.000	0.000	tracked
357dad92-ae44-40df-98d6-135586d4f7c9	f170e76b-4135-5781-b898-91e1259af14f	سوستة 30سم 	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:57:11.11977+00	2026-04-15 15:05:06.955994+00	0.000	0.000	tracked
5660d767-7d28-4b31-a146-9c7071134ce8	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 50سم 	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:52:33.084658+00	2026-04-15 15:02:01.84001+00	0.000	0.000	tracked
e529e2cf-83ac-4047-a94a-d0089030b1a4	f170e76b-4135-5781-b898-91e1259af14f	سوستة سخان 30 سم	\N	قطعة	35.00	14.00	10.00	\N	\N	\N	\N	\N	f	2026-03-15 17:28:34.179202+00	2026-04-15 15:32:32.334316+00	0.000	0.000	tracked
99d7b5a5-446f-44a9-82fc-17d6745c25f6	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 3/8 (عمر وميدو)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:55:14.544742+00	2026-04-15 15:32:45.17207+00	0.000	0.000	tracked
3e463d34-e6d9-43cb-b0c8-a6c76be8290a	f170e76b-4135-5781-b898-91e1259af14f	سوستة 3/8 * 3/8 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:55:43.701823+00	2026-04-15 15:32:49.022111+00	0.000	0.000	tracked
d159b603-06ca-4d80-b251-120ca04bd0ee	f170e76b-4135-5781-b898-91e1259af14f	سوستة 20سم 	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:57:23.792768+00	2026-04-15 15:03:22.956739+00	0.000	0.000	tracked
85be72d3-5d91-4bc1-8bc8-73b53c083490	f170e76b-4135-5781-b898-91e1259af14f	سوستة 70 سم	\N	قطعة	50.00	19.00	15.00	\N	\N	\N	\N	\N	t	2026-03-15 17:30:24.066428+00	2026-04-15 15:03:31.555096+00	0.000	0.000	tracked
a3b2e66c-e781-4009-a566-0a5285a513ef	f170e76b-4135-5781-b898-91e1259af14f	سوستة 70سم 	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-30 14:52:05.521177+00	2026-04-15 15:03:40.921648+00	0.000	0.000	tracked
d4f387cf-2b6a-4ca0-ba1c-099b594a5949	f170e76b-4135-5781-b898-91e1259af14f	سوستة 40سم 	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:57:01.999862+00	2026-04-15 15:05:20.92668+00	0.000	0.000	tracked
311f37ca-8c7f-4b3c-a32a-4bd675dd929b	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 40سم 	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:53:56.656353+00	2026-04-15 15:05:31.847627+00	0.000	0.000	tracked
858d8c6c-94bc-4b7b-9bf6-f5aaf4cc7aca	f170e76b-4135-5781-b898-91e1259af14f	سوستة 50سم 	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:53:31.375983+00	2026-04-15 15:05:46.177045+00	0.000	0.000	tracked
04e83173-2a26-4e61-b3be-456de3b641f9	f170e76b-4135-5781-b898-91e1259af14f	سوستة 60سم (انس)	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:53:05.184302+00	2026-04-15 15:26:17.361712+00	0.000	0.000	tracked
e55b3b91-07db-49dd-a8c0-10d76d164e42	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل نيكل 3/4"	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:44:02.371266+00	2026-04-15 15:40:55.66035+00	0.000	0.000	untracked
aabb6a08-a5c6-4a2c-b7dd-66ec1e019393	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة ايطالي متر ونص	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-10 13:28:55.910952+00	2026-04-15 15:36:06.400298+00	0.000	0.000	tracked
88420337-987a-48a0-a9db-fb0769395f8b	f170e76b-4135-5781-b898-91e1259af14f	سوستة سخان 50 سم	\N	قطعة	35.00	14.00	10.00	\N	\N	\N	\N	\N	f	2026-03-15 17:27:24.635008+00	2026-04-15 15:32:29.204577+00	0.000	0.000	tracked
50d2a42b-4735-4fb8-924d-8d86cbdcd133	f170e76b-4135-5781-b898-91e1259af14f	سوستة 100 سم	\N	قطعة	70.00	19.00	15.00	\N	\N	\N	\N	\N	f	2026-03-15 17:33:50.515367+00	2026-04-15 15:32:39.701135+00	0.000	0.000	tracked
3132378f-a089-4b2b-a047-c1e0a8651c31	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بسن خارجي 1/2 بسن نحاس 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 15:19:02.497919+00	2026-04-15 15:42:40.363057+00	0.000	0.000	tracked
eef8c1af-7cf9-4222-8baa-43bf0094c923	0a625299-9939-57bf-9214-75c4fa91e993	ثمن لزق 914 حار 	\N	عدد	80.00	60.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-04-12 14:20:35.193046+00	0.000	0.000	untracked
26592f03-3ad9-436b-8eb1-c97d23551fb2	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 الصقر 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:59.836683+00	2026-04-12 14:21:31.652587+00	0.000	0.000	untracked
fffc498b-ab89-446f-bf7e-43ad31c86527	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20*20 تاتش لومي 	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:26:11.412927+00	2026-04-12 14:21:37.869852+00	0.000	0.000	untracked
a21a8080-f94d-4927-bf0b-2390e2500059	3990e818-7790-55bf-9cf9-6a7e45c45026	صامولة زنق نحاس 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:54:36.9018+00	2026-04-15 15:36:37.975503+00	0.000	0.000	tracked
60569b7c-dcce-4e35-a474-19916aa35ca3	6e48e18f-bfe0-59e7-81ac-090ada6061b2	جلبة سن داخلي 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:39:46.172566+00	2026-02-08 14:39:46.172566+00	0.000	0.000	untracked
dbdb45fe-083e-42bb-b3c8-df69ec408f8d	0a625299-9939-57bf-9214-75c4fa91e993	ربع لزق 900 بارد	\N	عدد	110.00	80.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-04-03 17:46:07.107948+00	0.000	0.000	untracked
8edab49c-8f12-47b1-963d-8adea2c8ce02	0a625299-9939-57bf-9214-75c4fa91e993	ربع لزق 914 حار 	\N	عدد	130.00	95.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-04-03 17:48:24.809693+00	0.000	0.000	untracked
13d75310-8904-479f-9803-f13687b3bb57	0a625299-9939-57bf-9214-75c4fa91e993	نص لزق 914 حار 	\N	عدد	210.00	185.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:00:25.803028+00	2026-04-03 17:48:42.322995+00	0.000	0.000	untracked
cd65e985-404b-46db-819e-af8c5163937a	0a625299-9939-57bf-9214-75c4fa91e993	لزق مواسير عريض كبير 	\N	عدد	40.00	25.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:01:31.323747+00	2026-04-03 17:49:02.051032+00	0.000	0.000	untracked
09ac1895-0aa4-46d7-bf13-4f5d0a4d5c60	0a625299-9939-57bf-9214-75c4fa91e993	لزق مواسير عريض صغير 	\N	عدد	30.00	18.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:01:59.450741+00	2026-04-03 17:49:12.399756+00	0.000	0.000	untracked
0f662576-a144-4692-ad0b-937314746bdc	0a625299-9939-57bf-9214-75c4fa91e993	نص لزق 900 بارد 	\N	عدد	205.00	180.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:56:00.681382+00	2026-04-03 17:49:36.404996+00	0.000	0.000	untracked
a57e4eab-cbcf-4bf5-b649-33206c8e5efd	0a625299-9939-57bf-9214-75c4fa91e993	ثمن لزق رمادي 917	\N	عدد	75.00	95.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 21:04:34.039761+00	2026-04-03 17:53:16.719385+00	0.000	0.000	untracked
27f3d0ff-1203-4b97-81e8-3be4720852e2	0a625299-9939-57bf-9214-75c4fa91e993	سليكون عضم ابيض 	\N	عدد	140.00	115.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:54:13.696396+00	2026-04-03 17:50:00.610761+00	0.000	0.000	untracked
2063f0a4-2037-4436-937e-bb771626b4d0	0a625299-9939-57bf-9214-75c4fa91e993	سيليكون عضم رمادي	\N	عدد	140.00	115.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:54:21.896209+00	2026-04-03 17:50:13.347085+00	0.000	0.000	untracked
8d3a98f2-685a-417d-9600-8d0b51d74d97	0a625299-9939-57bf-9214-75c4fa91e993	لزق اوزو حار 	\N	عدد	45.00	30.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 20:27:41.543325+00	2026-04-03 17:56:05.593132+00	0.000	0.000	untracked
14089411-b7a2-4a4e-b9d0-f4efb8cc75c0	0a625299-9939-57bf-9214-75c4fa91e993	ربع لحام رمادي 917 	\N	عدد	120.00	90.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:56:53.225459+00	2026-04-03 17:53:01.919478+00	0.000	0.000	untracked
5f8e2238-5325-4ff2-b77e-05d6398eb000	3eafb215-ee16-58c9-b9ec-7033aa951137	بكرة تفلون وسط	\N	عدد	10.00	5.50	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:00:20.898163+00	2026-04-03 17:56:54.363788+00	0.000	0.000	untracked
a4997b77-66bf-4b4f-ae74-74762dd0712c	3eafb215-ee16-58c9-b9ec-7033aa951137	بكرة تفلون صغيرة	\N	عدد	5.00	3.75	0.00	\N	\N	\N	\N	\N	t	2026-01-18 18:53:32.586762+00	2026-04-03 17:56:43.786614+00	0.000	0.000	untracked
c00d945c-163e-4291-9788-c7c48cde10b6	7b07a8a7-291e-504c-82ec-e7b14467ff8c	شكرتون كهرباء كبير 	\N	عدد	40.00	35.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 16:37:07.609221+00	2026-04-03 17:59:04.256259+00	0.000	0.000	untracked
43b85fea-b00f-4300-b4e2-48505f28e8c5	3eafb215-ee16-58c9-b9ec-7033aa951137	تفلون شنطة ص	\N	قطعة	5.00	3.50	2.50	\N	\N	\N	\N	\N	f	2026-03-15 17:02:41.692515+00	2026-04-03 17:57:39.058435+00	0.000	0.000	untracked
79901430-1032-480c-b559-9ddc203f643f	3eafb215-ee16-58c9-b9ec-7033aa951137	تفلون مضغوط (بوش)	\N	قطعة	30.00	14.00	10.50	\N	\N	\N	\N	\N	f	2026-03-15 17:04:59.620263+00	2026-04-03 17:57:48.316979+00	0.000	0.000	untracked
2f3e5183-d945-419c-aba7-63cde2d18b66	0a625299-9939-57bf-9214-75c4fa91e993	سيليكون شفاف	\N	عدد	75.00	55.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:09:36.338117+00	2026-04-03 17:58:19.115415+00	0.000	0.000	untracked
0aa136ff-9388-4688-bbb1-a3a344d9cde5	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا (10) عادة فايف ستار 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-04-03 18:15:53.970277+00	0.000	0.000	untracked
e738439d-440a-4f78-9dc6-83fe84f8670d	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا سيراميك  (20 ) فايف ستار 	\N	عدد	230.00	210.00	163.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-04-03 18:12:38.620088+00	0.000	0.000	untracked
767f8dde-1ac2-4a50-8afb-982ff0b34fa9	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا سيراميك (15) فايف ستار 	\N	عدد	175.00	150.00	118.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-04-03 18:11:48.066336+00	0.000	0.000	untracked
38f70be7-6eda-4e3f-8f5d-cc664f4588e2	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة (15) نيو سيجما	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:16:45.388774+00	2026-04-03 18:17:54.594787+00	0.000	0.000	untracked
ff494980-4c73-4a61-81a8-2cdb3ad57c2c	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا (15) ساليمكو 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:23:45.548065+00	2026-04-03 18:19:09.173736+00	0.000	0.000	untracked
0d793ff6-689e-42c9-b1c5-3d1518459fb4	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا (15) اللؤلؤ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:23:51.300812+00	2026-04-03 18:19:42.000729+00	0.000	0.000	untracked
dfd4135f-7efa-4f2e-96b3-02e44342a7ab	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا (15) تاتش لومي	\N	عدد	85.00	60.00	50.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:45.34786+00	2026-04-04 09:04:42.605409+00	0.000	0.000	untracked
b6fb8546-4a43-4944-a315-be3ee1ea1fcb	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 ريبلان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:34:22.867705+00	2026-01-29 12:34:22.867705+00	0.000	0.000	untracked
aed26ebb-13d6-470e-b3be-18c28441b516	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 نوفا تركي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:34:22.867705+00	2026-01-29 12:34:22.867705+00	0.000	0.000	untracked
d7760ccb-4830-42c2-942f-517aed6b57ab	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 فرداني عادي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:34:22.867705+00	2026-01-29 12:34:22.867705+00	0.000	0.000	untracked
c3238e7f-7d91-40b4-8df2-6cd9161fc09a	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة محمل 20 * 20 المنبع	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000	untracked
ca20b458-786d-4bed-b94a-a91b10a6c621	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة بلاستيك 20 * 20 ساليمكو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000	untracked
988e63a2-5543-487a-9f20-e8caf9133c05	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة بلاستيك 20 * 20 كيلوباترا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000	untracked
3614e70f-96f3-4b69-9104-188a0574085d	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 فولكانو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000	untracked
c952ae33-8b9e-4eb8-b67f-56fb587e7314	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 عادي PFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000	untracked
01060665-4be6-4d76-b3cc-374e0d2e1d4a	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة نيو سيجما تاتش 15 * 15	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000	untracked
9cba759f-0edf-4d87-aa6b-d7fb7c7ced9e	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة تاتش سوبر ستار 15 * 15	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000	untracked
c14b87a0-3545-4545-8c7f-f00de35c208f	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة ماتدور 15 * 15	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000	untracked
39f5ed3b-7c34-4b75-9331-32a95c7d8b81	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة تاتتش 15 * 15 النورس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000	untracked
adc37b18-86dc-4fbb-bea1-856a682a5095	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة تاتش 20 * 20  pvs	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000	untracked
4afc0d54-afc2-40e3-89c0-bb8d316b043f	f0906684-99d3-55aa-9994-9427e941823e	كيلو اسمنت ابيض		كيلو	10.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 11:58:20.8037+00	2026-04-04 12:00:52.756502+00	0.000	0.000	untracked
4aff0452-0f86-4435-a377-3fc75234ba73	939f4e0e-dd51-54d3-9737-dfa50e8363e7	طابق بانيو تاتش 		عدد	150.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 12:09:48.935+00	2026-04-04 12:10:37.281076+00	0.000	0.000	untracked
bf14d1ca-8f4d-4a9f-a8ff-435203615af8	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعه 15*15كرت لافنا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:23:38.052074+00	2026-04-12 14:38:21.718824+00	0.000	0.000	tracked
8b6e0771-fc64-4898-9a82-e408dec91136	3eafb215-ee16-58c9-b9ec-7033aa951137	بكرة تفلون بوش 	\N	عدد	35.00	18.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:00:29.83319+00	2026-04-15 14:19:14.69681+00	0.000	0.000	untracked
a7861f0d-2057-4965-97f3-26b745cbbc8b	3990e818-7790-55bf-9cf9-6a7e45c45026	صامولة زنق نحاس 1بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:55:54.273374+00	2026-04-15 15:36:42.396594+00	0.000	0.000	tracked
21587981-5f52-41a0-8aad-f7a573837b0a	69f9914c-e165-5167-a85b-6ba46173bba3	شداد طويل (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 18:22:52.679189+00	2026-04-11 16:10:06.801653+00	0.000	0.000	untracked
d5442bca-dd7e-4793-aded-ef8d13f3d2b9	69f9914c-e165-5167-a85b-6ba46173bba3	حنفيه أسانسير كعب نحاس 	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:01:15.78419+00	2026-04-11 16:23:20.932654+00	0.000	0.000	untracked
4defd0e4-66bd-483d-95d2-805d2132cacf	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 1" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 13:07:27.808173+00	2026-01-25 13:07:27.808173+00	0.000	0.000	untracked
0f4beb3a-88e1-4869-9add-eca39c3a738a	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 2 و1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 10:12:35.204666+00	2026-01-27 10:12:35.204666+00	0.000	0.000	untracked
e3ef3606-53ce-4847-a9ae-7357efdea79a	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه سوسته تركى	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-25 23:14:04.662874+00	2026-02-25 23:14:04.662874+00	0.000	0.000	untracked
27e4b81d-9590-4576-b818-2a69da7afafd	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيحه استالس	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-25 23:16:10.366716+00	2026-02-25 23:16:10.366716+00	0.000	0.000	untracked
1220b394-a688-46f9-a9c5-6c815cef43d0	69f9914c-e165-5167-a85b-6ba46173bba3	زرار ضغط	\N	قطعة	20.00	13.00	9.00	\N	\N	\N	\N	\N	t	2026-03-15 16:58:42.15504+00	2026-03-15 16:58:42.15504+00	0.000	0.000	untracked
11ebff6a-eec6-4331-92fe-aac2c3373c9c	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينه تركي	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:58:49.261182+00	2026-03-04 13:58:49.261182+00	0.000	0.000	untracked
38e871be-2c5b-4e85-b0a6-f5c1eceb0b50	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينة ايديال	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:59:01.060385+00	2026-03-04 13:59:01.060385+00	0.000	0.000	untracked
33f55188-0fe1-4788-9809-3591288e60f3	0fe9fe9a-ca99-5bac-85da-bf506d92be69	مكنة تربو	\N	قطعة	120.00	85.00	58.00	\N	\N	\N	\N	\N	t	2026-03-15 16:55:34.652521+00	2026-03-15 16:55:34.652521+00	0.000	0.000	untracked
6638cc77-52db-4850-8515-7336252846cf	0fe9fe9a-ca99-5bac-85da-bf506d92be69	مكنة ضغط نوفا	\N	قطعة	120.00	85.00	60.00	\N	\N	\N	\N	\N	t	2026-03-15 16:56:59.683521+00	2026-03-15 16:56:59.683521+00	0.000	0.000	untracked
4ebdc6b6-72e6-43cd-83eb-389d25b5c5ec	daf8935a-6a30-5667-ac81-f4a398cbc305	ماسورة وراق بلاستيك (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 12:02:39.378525+00	2026-01-25 12:02:39.378525+00	0.000	0.000	untracked
67f5d187-e095-4c7d-b864-5789fc3290ec	daf8935a-6a30-5667-ac81-f4a398cbc305	ماسورة وراق استانلس (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 12:03:00.927509+00	2026-01-25 12:03:00.927509+00	0.000	0.000	untracked
de12a113-2bee-459d-a18b-971c54badbeb	daf8935a-6a30-5667-ac81-f4a398cbc305	وراقة مناديل ايفون	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:55:07.811048+00	2026-01-29 12:55:07.811048+00	0.000	0.000	untracked
883f0d1e-6801-402e-9168-1e7f3435d336	daf8935a-6a30-5667-ac81-f4a398cbc305	اوكرة جنب استانلس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:56:03.427526+00	2026-01-29 12:56:03.427526+00	0.000	0.000	untracked
329b40d0-86df-4887-b985-ea2bc7990b83	69f9914c-e165-5167-a85b-6ba46173bba3	حنفيه أسانسير كعب بلاستيك نيوجولد (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-01 16:04:07.2767+00	2026-04-08 18:08:28.528222+00	0.000	0.000	untracked
49f4d737-1d66-4bbf-8011-44949b013133	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه ايطالى	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:33:58.596563+00	2026-04-09 14:23:12.533595+00	0.000	0.000	untracked
9c6b491e-0f64-46ba-983d-e9512587b4c1	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه موجه 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 18:29:54.169036+00	2026-04-11 10:53:47.668859+00	0.000	0.000	untracked
93f907c6-3b84-4d95-b1a5-b57483e81451	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكنه ضغط كيس	\N	عدد	95.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:09:18.786823+00	2026-04-11 12:08:33.006946+00	0.000	0.000	untracked
94c0f2c9-04d7-467c-ae8a-eb553591eac7	daf8935a-6a30-5667-ac81-f4a398cbc305	طبة حوض ستار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 12:52:11.951551+00	2026-02-10 12:52:11.951551+00	0.000	0.000	untracked
bffd258f-b84e-4beb-8d18-ae23f611015d	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	شمعة مرحلة 2 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 12:09:17.936616+00	2026-01-22 12:09:17.936616+00	0.000	0.000	untracked
d2879635-0b3c-4c36-8199-9f2b94a535ab	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	شمعة مرحلة 1 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:31:36.798765+00	2026-01-22 14:31:36.798765+00	0.000	0.000	untracked
fb3622ca-2180-4ed7-811e-479b4d54f849	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	شمعة مرحلة 4 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:32:55.085674+00	2026-01-22 14:32:55.085674+00	0.000	0.000	untracked
9c1e6d13-9d15-46d1-9779-623dbc89684f	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	شمعة مرحلة 3 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:33:45.821867+00	2026-01-22 14:33:45.821867+00	0.000	0.000	untracked
4afdd266-b0cd-49ab-aa95-b46ea2fdc5a5	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حنفية فلتر اوكر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:50:13.899449+00	2026-01-29 12:50:13.899449+00	0.000	0.000	untracked
a4bc8fa2-5b9b-4d21-8b22-788662938fcd	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حنفية فلتر محمل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:50:13.899449+00	2026-01-29 12:50:13.899449+00	0.000	0.000	untracked
59b1408c-5d92-4b6b-b109-28c7a39f41fd	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	قنطرة فيلتر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:54:27.585787+00	2026-01-29 12:54:27.585787+00	0.000	0.000	untracked
0ba7d154-06d4-4148-bf47-71dbe931348a	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	وصله سريعه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:59:52.874967+00	2026-02-01 16:59:52.874967+00	0.000	0.000	untracked
53baae4e-9523-419b-b62f-ef1b43737105	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	نطرة فلتر 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:01:37.122142+00	2026-02-01 17:01:37.122142+00	0.000	0.000	untracked
39e8ca5e-8abc-4918-8e32-052d5862db47	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف شيلد نحاس 3/4 بوصة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:47:42.676159+00	2026-01-20 13:47:42.676159+00	0.000	0.000	untracked
b5459d2a-95fc-418b-99f9-f21a8406b6f1	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 1/2 بوصة (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:12:16.803625+00	2026-01-20 14:12:16.803625+00	0.000	0.000	untracked
79880071-7ae2-49d2-bda2-46c567d90c8e	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 3/4 (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:12:47.458892+00	2026-01-20 14:12:47.458892+00	0.000	0.000	untracked
ae608ba9-9030-4a2d-89d6-fa70769c09a7	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 1 بوصة (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:13:36.339435+00	2026-01-20 14:13:36.339435+00	0.000	0.000	untracked
c2b0f8d3-5a8b-4744-8cb6-c51fc74a019f	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 2 بوصة (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:13:44.386965+00	2026-01-20 14:13:44.386965+00	0.000	0.000	untracked
befa0c0a-622a-46f8-913b-ca6e7a4ed98e	f0906684-99d3-55aa-9994-9427e941823e	كيلو جبس		كيلو	10.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 11:59:11.13594+00	2026-04-04 12:00:58.612353+00	0.000	0.000	untracked
b69b3ce6-eb91-4356-86b3-2240135059b3	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	بزبوز فلتر بلاستيك 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 14:53:07.769469+00	2026-04-11 14:53:07.769469+00	0.000	0.000	untracked
f0c427f2-000f-4197-b044-9cb16ef86801	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 1/2 محمل 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:37:22.332383+00	2026-04-12 14:21:47.286661+00	0.000	0.000	untracked
35ad6cc3-4464-483f-9c63-7426eeee828a	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز نص خفيف 1/2 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:38:06.827415+00	2026-04-12 14:21:52.607001+00	0.000	0.000	untracked
0bc85e43-0849-4d93-a656-73ffe8cb39eb	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 3/4 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:38:34.843504+00	2026-04-12 14:21:57.917733+00	0.000	0.000	untracked
3afc718e-22cb-40f5-85b6-f36a9aefa8b5	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 2" خفيف 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:42:24.569801+00	2026-04-12 14:22:04.871564+00	0.000	0.000	untracked
e2a0d6b0-083c-4d18-a788-795dbc4bf1df	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 2" محمل 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:42:58.654475+00	2026-04-12 14:22:13.149216+00	0.000	0.000	untracked
ec85f3a5-9492-404a-bb1e-ad401f624d53	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 3" محمل 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:43:40.257346+00	2026-04-12 14:22:19.504902+00	0.000	0.000	untracked
80f8c742-7ee3-47cb-96cf-7fd5819cc7c1	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 3" خفيف 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:44:16.853683+00	2026-04-12 14:22:26.358489+00	0.000	0.000	untracked
760b0215-4244-4bdb-8309-21894890e616	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 4" محمل 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:45:46.415871+00	2026-04-12 14:22:33.915807+00	0.000	0.000	untracked
4dd2c933-9bb8-4496-8f14-e5cf55e14a62	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 4" خفيف 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:46:17.954431+00	2026-04-12 14:22:41.815009+00	0.000	0.000	untracked
df95ab62-3460-4fd8-97b3-d041e121aa96	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 6" 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:47:31.376609+00	2026-04-12 14:23:22.272853+00	0.000	0.000	untracked
7b92bee1-e9df-4679-8856-f13f1491aa2d	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 1 و1/2" شعبي 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:48:35.136908+00	2026-04-12 14:23:32.982395+00	0.000	0.000	untracked
ebb8fe3a-e453-4bf8-b931-c01008a6a192	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 1.5" محمل 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:49:04.319186+00	2026-04-12 14:25:13.665813+00	0.000	0.000	untracked
c7c52aa2-562e-477a-a972-d04f35efcb87	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز بجوان 3/4" 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:49:35.689487+00	2026-04-12 14:26:09.5674+00	0.000	0.000	untracked
43262301-8bc0-4e5e-98f8-df79b0032751	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه كوع  	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 18:28:53.021728+00	2026-04-13 13:13:23.81976+00	0.000	0.000	tracked
5bb79780-a8aa-4007-b778-5ad0dbb78e6e	69f9914c-e165-5167-a85b-6ba46173bba3	عوامه جمب السكرى	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:18:09.42226+00	2026-04-13 13:29:46.538512+00	0.000	0.000	tracked
6c169f15-1614-4161-97af-cf38b1608e64	7f15ec9b-720f-580d-ad54-61fcb04a20d9	بلبله طاسة دش 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 14:58:42.789107+00	2026-04-15 14:30:52.957791+00	0.000	0.000	tracked
d3c4e18f-4297-4fea-b338-756ca2c90097	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بسن خارجي 1/2 بسن نيكل 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 15:19:36.584224+00	2026-04-15 15:42:34.357362+00	0.000	0.000	tracked
44357f2a-f7f8-441c-bdd8-f9f1af4487a8	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بسن خارجي محمل 1*1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-04-15 15:43:04.941575+00	0.000	0.000	tracked
0a5287eb-3d47-4451-ac01-b6d97287ada1	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بسن داخلي 1*1/2 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-04-15 15:43:09.109355+00	0.000	0.000	tracked
5b7abdfc-f2bb-4d1e-905a-fd54be99c46f	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بسن داخلي 1بوصة بسن نيكل 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 15:17:44.289282+00	2026-04-15 15:43:12.402506+00	0.000	0.000	tracked
f3f5bc34-6e8a-4fce-aaff-440ca5fd8a9a	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف سخان (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:16:14.851146+00	2026-01-20 14:16:14.851146+00	0.000	0.000	untracked
8860ce8d-06ec-41f7-9fa2-87e2979c660c	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف لاكور 1 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:17:17.027115+00	2026-01-20 14:17:17.027115+00	0.000	0.000	untracked
d1cc6cac-ad63-4fda-93d9-913571e3fe9e	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 1 و 1/2 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:33:10.336915+00	2026-01-20 15:33:10.336915+00	0.000	0.000	untracked
7f5190eb-4444-470d-87ec-f037f1b4d36a	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بوابة 1 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:55:29.280372+00	2026-01-20 15:55:29.280372+00	0.000	0.000	untracked
3a1f1896-d864-4700-a1df-a92942f60e58	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة 1 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:56:10.576738+00	2026-01-20 15:56:10.576738+00	0.000	0.000	untracked
5a69e732-8a23-459e-8321-aaabf2d24e8e	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة 3/4 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:56:57.601327+00	2026-01-20 15:56:57.601327+00	0.000	0.000	untracked
d2fd8ca2-1dba-4cf1-81fb-82dc5a323a7f	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة 1/2 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:57:58.480216+00	2026-01-20 15:57:58.480216+00	0.000	0.000	untracked
5dc65401-81f9-49c1-8995-94b48888200f	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 17:52:25.757162+00	2026-01-20 17:52:25.757162+00	0.000	0.000	untracked
966eee6d-776d-4e2c-a7a1-2e93df03e90d	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف لاكور 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:34:25.206656+00	2026-01-21 09:34:25.206656+00	0.000	0.000	untracked
95e488af-8082-4dac-903d-ae4ea9039e8e	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس محمل بسوستة 1/2 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:15:53.456983+00	2026-01-22 11:15:53.456983+00	0.000	0.000	untracked
77d16d51-67f9-479c-aa04-d7e44d41976d	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة محمل نص بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 11:56:44.752842+00	2026-01-25 11:56:44.752842+00	0.000	0.000	untracked
21720bca-49df-4dd9-84aa-4858271209cd	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن خارجي 2" و1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000	untracked
fe3b4b4b-f997-4e20-8a71-11df8a4c2e63	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور 3/4  سن خارجي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000	untracked
b1bd2473-dbe5-409d-999a-342ece893357	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور 3/4 سن داخلي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000	untracked
0f4ae4a8-89db-4d5d-85d5-704f681f9764	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور 1/2 بسن خارجي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000	untracked
4ee4ef31-bccf-4cf0-b768-53db7d80ea36	ac497863-17f1-5a7a-8ac1-274f86b4001b	فلوماك صيني	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:55:21.374679+00	2026-03-04 13:55:21.374679+00	0.000	0.000	untracked
65d744cb-8b17-49e8-b485-e114e01b9987	ac497863-17f1-5a7a-8ac1-274f86b4001b	فلوماك ايطالي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:58:06.724196+00	2026-03-04 13:58:06.724196+00	0.000	0.000	untracked
db501a5e-8889-470a-abac-1aae9f62414b	ac497863-17f1-5a7a-8ac1-274f86b4001b	فلوماك كوباية	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:58:19.357574+00	2026-03-04 13:58:19.357574+00	0.000	0.000	untracked
5d2c6496-0b93-4d27-8f33-ab6c72e3ab08	daf8935a-6a30-5667-ac81-f4a398cbc305	مسمار صبانات 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:58:59.760059+00	2026-04-09 14:11:02.784664+00	0.000	0.000	untracked
23856709-a9eb-49e8-a93d-8d659ff16a26	daf8935a-6a30-5667-ac81-f4a398cbc305	مسمار سخان 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:59:38.943772+00	2026-04-09 14:11:09.740466+00	0.000	0.000	untracked
71cc6095-c87f-4909-b84c-f89eb5660fa7	daf8935a-6a30-5667-ac81-f4a398cbc305	مسمار حوض 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 15:00:01.823495+00	2026-04-09 14:11:21.176023+00	0.000	0.000	untracked
013dc815-ab1d-46f5-b3ce-3c09ec80c29b	a77bbc03-437a-5071-b287-7a1cb6a9ac77	مسمار سديلي  L معدن 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-04-09 14:11:30.841659+00	0.000	0.000	untracked
2de745f3-490c-458f-8d80-f8ef4fe03cb9	a77bbc03-437a-5071-b287-7a1cb6a9ac77	مسمار سديلي جرار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:03:17.755964+00	2026-04-09 14:11:43.098003+00	0.000	0.000	untracked
2e415055-50d3-403c-b6b6-132cc06cac09	a77bbc03-437a-5071-b287-7a1cb6a9ac77	مسمار سديلي L بلاستيك 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 17:14:10.101598+00	2026-04-09 14:11:49.700826+00	0.000	0.000	untracked
577cd1d9-5876-4b11-be1c-cd338c878aa2	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	محبس فلتر استالس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:36:27.970155+00	2026-02-01 17:36:27.970155+00	0.000	0.000	untracked
5167fb35-085a-42cc-82ea-73e3684bea9a	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حنفية كولمان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:05:12.898574+00	2026-02-01 17:05:12.898574+00	0.000	0.000	untracked
e5e9bcf1-22ad-40e2-a443-9b4acdbbe426	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حامل حنفية فلتر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:13:30.784739+00	2026-02-01 17:13:30.784739+00	0.000	0.000	untracked
ed6fb4fe-6aa7-4a8f-8856-bbdd3b7b7625	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	محول فلتر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:02:20.851609+00	2026-02-01 17:02:20.851609+00	0.000	0.000	untracked
177bed74-3f94-4fed-93a0-e23cb13847f4	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن خارجي 1" * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000	untracked
523adcc8-e4e9-4766-981b-e5165d723e43	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن داخلي 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000	untracked
c1895f9b-5d9b-4507-9ac8-be10dd5c08d0	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن داخلي 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000	untracked
8a00f949-0c0c-4c21-8d44-c6ffaae33aa9	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن داخلي 1" بسن نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-04-11 15:13:53.290048+00	0.000	0.000	untracked
dd7fe2ec-0f4e-4de5-8f45-a7891f0bce59	5b970d56-5ee8-594e-bcde-6ce50c1d47c3	ماتور ايطالي 1 حصان	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:45:50.975615+00	2026-03-04 13:45:50.975615+00	0.000	0.000	untracked
f8dd4fea-855d-402a-8de3-c62d5dc51df0	5b970d56-5ee8-594e-bcde-6ce50c1d47c3	ماتور ايطالي 1/2 حصان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:46:14.534908+00	2026-03-04 13:46:14.534908+00	0.000	0.000	untracked
45f0395c-d566-4c2b-b586-3cd2d1d99f7b	5b970d56-5ee8-594e-bcde-6ce50c1d47c3	ماتور صيني 1/2 حصان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:48:13.142898+00	2026-03-04 13:48:13.142898+00	0.000	0.000	untracked
fb232540-a7f2-4037-b600-1ee220be7b4d	753bd696-70ef-5e78-bd15-456428b31687	جلبة 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:11:35.389255+00	2026-02-08 14:11:35.389255+00	0.000	0.000	untracked
1dc0dbc5-8c7d-45d7-b240-e343b6bc50fa	753bd696-70ef-5e78-bd15-456428b31687	تي 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:11:59.999094+00	2026-02-08 14:11:59.999094+00	0.000	0.000	untracked
b277559f-9416-4077-b01d-108ca5d2ad84	753bd696-70ef-5e78-bd15-456428b31687	واي 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:24:30.685307+00	2026-02-08 14:24:30.685307+00	0.000	0.000	untracked
7c32ca44-d362-41fb-94c8-843a6c2b6eb1	753bd696-70ef-5e78-bd15-456428b31687	طبة كاب 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:34:10.669716+00	2026-02-08 14:34:10.669716+00	0.000	0.000	untracked
c45f5e63-c8f4-46b5-bd72-ba04bfad276e	6e48e18f-bfe0-59e7-81ac-090ada6061b2	طبة تسليك 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:45:56.317097+00	2026-02-08 12:45:56.317097+00	0.000	0.000	untracked
042c84a3-1f76-4d4d-ac34-bfcd30ae8355	201504f6-3716-569b-9502-2a404a8cbb03	اوكره صيني 		عدد	140.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-04 14:32:56.844789+00	2026-04-04 14:33:54.393843+00	0.000	0.000	untracked
22a11cf4-2023-4f18-895e-89f507d5829a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	تطويلة محبس دفن 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 15:09:24.86699+00	2026-04-11 15:09:24.86699+00	0.000	0.000	untracked
dc4dcdc4-6c4c-422a-b43a-64a95dd46387	63e2904c-e0db-55e5-9f40-d5f84a85a501	محبس لاكور 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:16:04.063738+00	2026-01-26 21:16:04.063738+00	0.000	0.000	untracked
85a51c91-a72c-4762-91ee-38a342e74c48	63e2904c-e0db-55e5-9f40-d5f84a85a501	كوع لحام 3/4 مفتوح	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:28:28.462952+00	2026-01-31 14:28:28.462952+00	0.000	0.000	untracked
4fc7f1f8-8b6a-42fa-b439-eb37e404f119	9a3e6604-1d9e-59a2-9306-b96751e63a08	محبس لاكور 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-28 10:10:59.544879+00	2026-01-28 10:10:59.544879+00	0.000	0.000	untracked
868ab4a9-b2ef-435e-a292-fdbc7e3752d6	a8e4d683-3422-50bf-bd7c-91584afca4c4	جلبة لحام 3" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:41:47.014108+00	2026-01-26 20:41:47.014108+00	0.000	0.000	untracked
56ae25fe-9036-4f6d-a788-b665157a3301	a8e4d683-3422-50bf-bd7c-91584afca4c4	جلبة سن داخلي 3" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:43:20.189943+00	2026-01-26 20:43:20.189943+00	0.000	0.000	untracked
5c2aab48-9df3-4dce-b31f-0ec0746050c0	3bdaca2a-6e9c-5e2b-b964-711663449202	جلبة لحام 4" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:28:37.455045+00	2026-01-26 20:28:37.455045+00	0.000	0.000	untracked
e6f44831-450b-4431-8b3b-898c83545db9	1da2db1b-955b-5530-885e-33ed2ab7e7d3	تي محبس 1/2 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:23:09.209938+00	2026-01-26 21:23:09.209938+00	0.000	0.000	untracked
d14d6889-b9b2-454e-a5eb-ac5744e8939b	1da2db1b-955b-5530-885e-33ed2ab7e7d3	جلبة بسن خارجي 1/2 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:08:59.903959+00	2026-01-26 22:08:59.903959+00	0.000	0.000	untracked
6ae3a388-329b-4811-a338-c61a5d690642	c286bcb5-a984-59c2-b633-ef3ebf4da01f	تي محبس دفن 3/4 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:38:31.164992+00	2026-01-26 21:38:31.164992+00	0.000	0.000	untracked
760b529d-dbde-4e70-919c-610ce46ee71a	c286bcb5-a984-59c2-b633-ef3ebf4da01f	جلبة بسن خارجي 3/4 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:39:18.575886+00	2026-01-26 21:39:18.575886+00	0.000	0.000	untracked
48662f9e-7606-4818-b2a8-375230a4923a	c286bcb5-a984-59c2-b633-ef3ebf4da01f	جلبة بسن داخلي 3/4 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:39:48.229897+00	2026-01-26 21:39:48.229897+00	0.000	0.000	untracked
49e6c837-6ec8-4ff1-9b10-214b6df66b33	765f5e85-edfb-58dc-bf2b-4790017fb2f8	تي لحام 3/4 * 1/2 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:44:55.657012+00	2026-01-26 20:44:55.657012+00	0.000	0.000	untracked
26a4f674-5c48-4ff6-8634-143def01cd85	765f5e85-edfb-58dc-bf2b-4790017fb2f8	كوع بسن 3/4 * 1/2 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:46:07.696375+00	2026-01-26 20:46:07.696375+00	0.000	0.000	untracked
c9835638-133e-40e3-86d5-76725f3b9751	765f5e85-edfb-58dc-bf2b-4790017fb2f8	تي بسن 3/4 * 1/2 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:46:48.177685+00	2026-01-26 20:46:48.177685+00	0.000	0.000	untracked
b771a653-3406-4c85-8d38-55002fcfc673	765f5e85-edfb-58dc-bf2b-4790017fb2f8	جلبة سن داخلي 3/4 * 1/2 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:47:42.874794+00	2026-01-26 20:47:42.874794+00	0.000	0.000	untracked
541617c9-27f4-4738-9d7f-dffd1fb8975e	765f5e85-edfb-58dc-bf2b-4790017fb2f8	جلبة لحام 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:29:52.672492+00	2026-01-31 14:29:52.672492+00	0.000	0.000	untracked
202995e6-bfba-49cd-9985-735486af9c35	9dc6edb6-19f2-5c9d-8c52-5a335ced3880	تي لحام 1" * 3/4" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:56:16.056423+00	2026-01-26 20:56:16.056423+00	0.000	0.000	untracked
3a563ab6-c4d5-4458-bfca-5ac51e029c72	9dc6edb6-19f2-5c9d-8c52-5a335ced3880	جلبة لحام 1 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:08:49.904267+00	2026-01-26 21:08:49.904267+00	0.000	0.000	untracked
59c5ef97-35e2-45d5-bcbc-94c0a854195e	aeffa6be-df79-58c1-93ba-30d4f612d48e	تي لحام  1* 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:07:34.70497+00	2026-01-26 21:07:34.70497+00	0.000	0.000	untracked
2a583630-04db-4a74-927a-0f8ef4d83d03	20ecf9c0-8655-5221-a299-7a517bc5c6ec	جلبة 1.5 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:13:21.310816+00	2026-01-26 21:13:21.310816+00	0.000	0.000	untracked
7bbeec16-c5dd-434c-9415-643d647ed54c	59148d2a-fc7e-58d6-adf7-e6e87869724c	جلبة لحام 1.5 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:14:47.991815+00	2026-01-26 21:14:47.991815+00	0.000	0.000	untracked
afa1092c-9aba-4b1a-ac8e-8b91bb308469	46f96c6a-23fd-5740-849e-61de853f07aa	جلبة بسن داخلي 1 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:58:53.401604+00	2026-01-26 21:58:53.401604+00	0.000	0.000	untracked
4b615637-457b-4c61-b4c8-e69607aff352	d6654c3e-1821-5363-80b2-79297fffcc14	ماسورة 1.5"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:42:32.606727+00	2026-02-10 13:42:32.606727+00	0.000	0.000	untracked
4a9db8a4-6cdf-4666-ae94-28002243bce6	d6654c3e-1821-5363-80b2-79297fffcc14	ماسورة 1"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:43:36.471241+00	2026-02-10 13:43:36.471241+00	0.000	0.000	untracked
d119f961-855e-4209-ae8f-00e30ed71e3c	d6654c3e-1821-5363-80b2-79297fffcc14	ماسورة 3/4"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:44:16.949695+00	2026-02-10 13:44:16.949695+00	0.000	0.000	untracked
3ba8e991-c7c9-4ee0-b3e8-265a9b8e13c4	d6654c3e-1821-5363-80b2-79297fffcc14	ماسورة 1/2"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:45:01.933868+00	2026-02-10 13:45:01.933868+00	0.000	0.000	untracked
ad598ec1-2ff3-43fd-97b7-c957aa24375f	24dcb16c-9713-518d-8af0-a48722e900dc	بشبوري (الكوك و ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-20 16:41:50.944655+00	0.000	0.000	untracked
155fa0fb-6b2b-44db-8541-db6e2250448b	24dcb16c-9713-518d-8af0-a48722e900dc	سيخ شطاف الومونيوم (الكوك)	\N	عدد	35.00	13.50	9.50	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-23 16:31:15.151033+00	0.000	0.000	untracked
7e302e33-3bb9-436d-b2a6-f64f71fa113e	24dcb16c-9713-518d-8af0-a48722e900dc	سيخ شطاف نحاس (الكوك)	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-21 15:02:47.061757+00	0.000	0.000	untracked
15902323-3734-41df-bb0e-732074b9a1aa	24dcb16c-9713-518d-8af0-a48722e900dc	خرطوم شطاف الوان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:03:44.986461+00	2026-01-18 19:03:44.986461+00	0.000	0.000	untracked
e5bc8d66-e55d-4fe6-a17a-cf8f6ff8cd1b	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي جروهي (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:19:45.630201+00	2026-01-22 14:19:45.630201+00	0.000	0.000	untracked
55e08b76-5995-4930-91ae-2c3ab291202e	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي نيكل سالمكو (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.080983+00	2026-01-29 12:49:38.080983+00	0.000	0.000	untracked
a98b567b-37a4-4c42-9801-a5902cb3ef95	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي اسود ساليمكو (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000	untracked
9228f6d9-1d01-45dc-a79f-9b80a68c3c55	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي روما (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000	untracked
9ad31176-b502-43b7-b47a-57cdaa1e623f	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي كيس ستار (ادهم)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-02-21 15:05:00.917042+00	0.000	0.000	untracked
c3887692-7b86-4407-a0ce-78ecc804fadc	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي سولو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000	untracked
6244a9bf-08bb-41a8-9bec-b8cc3df96f19	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي سوبر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000	untracked
48fba67d-dbc6-424b-b2eb-497fdc9b7bd1	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي إينوفا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000	untracked
d285b94f-1298-4c3a-b7ac-0042de1e97ea	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي ماست	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000	untracked
45d11bd8-b3a6-42f3-8c0e-6db0e73093f0	d5901618-eafd-5ad1-b0e6-f0f56f1cda35	جلبة بسن خارجي 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 21:05:07.12304+00	2026-04-15 14:26:10.584687+00	0.000	0.000	untracked
720df594-4b7f-46b4-b602-884e803ed8f9	d5901618-eafd-5ad1-b0e6-f0f56f1cda35	تي بسن 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-26 21:05:39.788358+00	2026-04-15 14:26:12.7441+00	0.000	0.000	untracked
43e5a9ca-78c2-4f05-affc-4c6e2491605a	63e2904c-e0db-55e5-9f40-d5f84a85a501	جلبة لحام 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:16:35.061885+00	2026-04-17 11:33:59.624396+00	0.000	0.000	tracked
7568b958-f282-4aa1-85b5-24349625f9db	63e2904c-e0db-55e5-9f40-d5f84a85a501	تي لحام 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:17:08.717317+00	2026-04-17 11:34:16.697377+00	0.000	0.000	tracked
4d5e6616-df0c-41a0-a88c-bad074a514af	7cb8a098-41ca-53d9-b4e0-cdb8907a18d9	جلبة بسن خارجي 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:01:09.086358+00	2026-04-22 13:54:05.259923+00	0.000	0.000	tracked
9cce9245-5bbe-42c5-b6b2-f4fc4e5ec8e3	63e2904c-e0db-55e5-9f40-d5f84a85a501	كرنك 3/4 لحام BR	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:20:25.437116+00	2026-04-22 13:33:02.259897+00	0.000	0.000	tracked
d2ffb803-9a86-4990-b834-9a3d7413444d	9a3e6604-1d9e-59a2-9306-b96751e63a08	كوع لحام 1 بوصه BR	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:50:05.188327+00	2026-04-22 13:34:07.332768+00	0.000	0.000	tracked
12d44342-c0ea-4093-8344-8a3fe616b946	9a3e6604-1d9e-59a2-9306-b96751e63a08	جلبة لحام 1 بوصة BR	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:50:32.28219+00	2026-04-22 13:34:38.90937+00	0.000	0.000	tracked
3b1471c3-f7f4-4a7d-a28d-06206542e170	9a3e6604-1d9e-59a2-9306-b96751e63a08	تي لحام 1 بوصه BR	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:50:57.378248+00	2026-04-22 13:35:57.241448+00	0.000	0.000	tracked
6a6a73a1-51e7-48ae-8455-0e176997bed6	7cb8a098-41ca-53d9-b4e0-cdb8907a18d9	شيك بلف لاكور 1.5 بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:00:34.456897+00	2026-04-22 14:13:17.567921+00	0.000	0.000	tracked
9cffbe6c-1071-48ce-8973-fcd035c61762	63e2904c-e0db-55e5-9f40-d5f84a85a501	طبه كاب 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:19:54.664464+00	2026-04-22 14:16:20.04033+00	0.000	0.000	tracked
19ad03e8-e71e-4be7-90ef-08bd6572f06f	9a3e6604-1d9e-59a2-9306-b96751e63a08	طبه  1 بوصه كاب 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:46:51.352013+00	2026-04-22 14:15:58.258054+00	0.000	0.000	tracked
3a4c0ba0-e011-4496-b6b8-2cdc7dc89c88	63e2904c-e0db-55e5-9f40-d5f84a85a501	طبة كاب 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-31 14:33:59.537256+00	2026-04-22 14:16:33.6248+00	0.000	0.000	tracked
65bfbf00-27bf-4323-ab25-1ccd994cddc4	24dcb16c-9713-518d-8af0-a48722e900dc	يد شطاف خارجي	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-02-21 15:03:39.300701+00	0.000	0.000	untracked
3ef92e16-40ee-44f0-98ca-671ee3a5805b	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	كاوتشة سيفون 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:28:10.806647+00	2026-02-02 15:28:10.806647+00	0.000	0.000	untracked
d50650fc-9afe-4e35-b5d9-eb8dd047b187	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	كاوتشة سيفون 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:28:23.912166+00	2026-02-02 15:28:23.912166+00	0.000	0.000	untracked
32f48e5f-5ab9-419b-8916-585ded0e8320	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مكنة سيفون كاملة فيرست	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:28:48.340611+00	2026-02-02 15:28:48.340611+00	0.000	0.000	untracked
c7423fe8-0195-4f61-894f-5692b13601c9	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	حامل سماعة متحرك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:30:06.112259+00	2026-02-02 15:30:06.112259+00	0.000	0.000	untracked
29837797-dac6-4388-b18f-4513160e8d31	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	حامل شطاف عادي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:30:30.859666+00	2026-02-02 15:30:30.859666+00	0.000	0.000	untracked
f0a893bd-5ba6-4416-9f76-2f89c54a7767	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مسمار قعدة ايطالي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:36:54.790817+00	2026-02-02 15:36:54.790817+00	0.000	0.000	untracked
6ec910b4-8783-403d-a1b3-3010fa7db258	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي لاتش 3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:38:08.931853+00	2026-02-02 15:38:08.931853+00	0.000	0.000	untracked
1743d3fb-848e-476a-8cab-5e48149abdc3	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي لاتش 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:39:26.862435+00	2026-02-02 15:39:26.862435+00	0.000	0.000	untracked
32cac645-8208-4dac-9da8-01986e061b8c	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 1.5 ماليزى	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:06:44.180499+00	2026-02-21 21:40:25.304995+00	0.000	0.000	untracked
3475e3b2-b002-47e6-88ee-85a33cd7f837	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 2 بوصه ماليزى	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:07:21.784587+00	2026-02-21 21:40:36.875084+00	0.000	0.000	untracked
625c7018-17e7-4090-9e8a-fbbedab8d3e2	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 1.5 رمادى	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:09:46.434495+00	2026-02-21 21:40:48.138474+00	0.000	0.000	untracked
3f69fa98-e1f0-4102-a092-d17b3924abf9	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون3 بوصه بفايظ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:13:58.857832+00	2026-02-02 19:13:58.857832+00	0.000	0.000	untracked
f7f12634-4eb0-4c26-8f20-691639ed46fa	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه بروحين	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:14:35.730526+00	2026-02-02 19:14:35.730526+00	0.000	0.000	untracked
a6701d83-54db-4c36-968d-2354d17328ec	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 2 بوصه بروحين	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:15:22.467925+00	2026-02-02 19:15:22.467925+00	0.000	0.000	untracked
538af4af-6d6c-4210-be3c-0ffaecc7a7ed	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه قصيره	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 15:35:09.987893+00	2026-04-11 11:01:52.170436+00	0.000	0.000	untracked
c3c27efc-96b1-4a23-bdab-93e04c7e9940	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه قصيره (ساليمكو )	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:29:39.724353+00	2026-04-11 11:02:04.306245+00	0.000	0.000	untracked
30150049-3f07-44c8-a64d-f23fd7141fdc	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مسمار قاعدة الما	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:36:35.687663+00	2026-04-09 14:10:54.202164+00	0.000	0.000	untracked
bf9ce757-b348-4b75-bbb4-0c6bf8efc605	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه كوع (الشعلة )	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:29:08.6693+00	2026-04-11 11:02:15.118484+00	0.000	0.000	untracked
1db05d34-4a6f-4897-9a7c-619aa7351406	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه لوكس 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:29:48.842245+00	2026-04-11 11:02:27.200355+00	0.000	0.000	untracked
e0066fb9-2326-421b-a886-489c8b5863ab	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 2 بوصه رمادى	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:10:08.971445+00	2026-02-21 21:41:04.522003+00	0.000	0.000	untracked
fa3c71db-d1ce-4a46-9ee5-9b8b4c2158e1	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مسمار قاعدة كيلوباترا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 15:36:21.69907+00	2026-04-11 11:02:47.306207+00	0.000	0.000	untracked
6b464626-fbe4-4656-bd1a-d571d6836693	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 2" صيني رمادي	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:24:10.827742+00	2026-02-21 21:38:10.234836+00	0.000	0.000	untracked
58991d0b-13f2-4dff-80e7-41c64abe1120	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه عدلة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 15:35:46.899174+00	2026-04-11 10:55:23.579972+00	0.000	0.000	untracked
fd1d4d05-a75f-4b1e-bab1-26b542487294	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه استانلس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 15:29:25.074519+00	2026-04-11 11:01:34.581362+00	0.000	0.000	untracked
6d01a666-06e8-4462-9315-00ba9f599a34	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه موجة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 15:36:02.450285+00	2026-04-11 11:01:46.850642+00	0.000	0.000	untracked
fb762949-d7b9-450d-982b-102fb9ceed95	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	حنفية جنب اسانسير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:25:43.003892+00	2026-02-02 15:25:43.003892+00	0.000	0.000	untracked
605b00e5-e53a-42e8-b98d-53030c4f7284	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون صينى 1.5	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:19:01.181735+00	2026-02-21 21:43:47.495468+00	0.000	0.000	untracked
48745b7a-4ef7-4583-a151-234efc18dbe7	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون صينى 2 بوصه	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:19:28.108334+00	2026-02-21 21:44:00.953521+00	0.000	0.000	untracked
ec82ff6e-c170-46cd-8bf4-56341eb31632	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون رمادي 2"	\N	قطعة	50.00	27.00	21.00	\N	\N	\N	\N	\N	t	2026-03-15 17:36:40.441539+00	2026-03-15 17:36:40.441539+00	0.000	0.000	untracked
9ac24b13-ee09-4646-9bb8-249a9b471037	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة مياه 3 متر جولدن فلو (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:12:30.120497+00	2026-02-21 14:39:51.846576+00	0.000	0.000	untracked
19d71c4a-8090-4996-a85c-2df2eb0ee554	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة مياه متر ونص جولدن فلو (الكوك)	\N	عدد	80.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:12:34.503756+00	2026-02-21 14:39:45.801646+00	0.000	0.000	untracked
a392d3d8-9dc7-4509-92c6-96e52892dc45	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة مياه متر ونص جولدن تركي (الكوك)	\N	عدد	80.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:12:45.952747+00	2026-02-21 14:39:25.335134+00	0.000	0.000	untracked
543dae04-a219-44b2-a24c-8e663ec4c865	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة مياه 3 متر جولدن تركي (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:12:52.496582+00	2026-02-21 14:39:18.134764+00	0.000	0.000	untracked
c9d9c6cf-9b3c-464e-acb8-89e7b9e60117	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة صرف 3 متر (ادهم)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:14:53.843401+00	2026-02-21 14:38:55.431289+00	0.000	0.000	untracked
a677536b-b254-402f-861c-caa5d4baf82f	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة صرف متر ونص (ادهم)	\N	عدد	80.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:15:24.714112+00	2026-02-21 14:38:48.103872+00	0.000	0.000	untracked
189b8e6e-6161-40ba-ab29-98d73b32232e	682ba68b-ea1b-565a-972d-e92063da3cbb	حنفية غسالة (عمار)	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:35:22.486394+00	2026-02-21 14:38:21.602117+00	0.000	0.000	untracked
8fae6b9b-5008-41b4-a965-9a6c1ded4518	682ba68b-ea1b-565a-972d-e92063da3cbb	حنفية غسالة روفا (بلال)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 19:38:43.959582+00	2026-02-21 14:38:28.854569+00	0.000	0.000	untracked
aaa9b0ea-6fca-4ea2-9b68-59b22b719e6c	2732421b-5c80-556c-9323-4c8f800ad58e	مشترك 1 بوصة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:05:44.248619+00	2026-01-19 19:05:44.248619+00	0.000	0.000	untracked
aebc30af-cb2d-40a1-a4aa-7a7f438a864a	6e264538-d570-56e8-ab82-3a3db2f04764	مشترك سن داخلي - سن 1/2 * 3/4 (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:03:41.558684+00	2026-01-19 19:03:41.558684+00	0.000	0.000	untracked
2e9f519a-ab35-4cc7-a168-bd51332e9700	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه بزباله استالس	\N	عدد	180.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 19:17:51.624571+00	2026-04-11 16:52:42.475014+00	0.000	0.000	untracked
da12de49-d1d6-4554-b5ae-43e76227ca90	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامة نحاس بالونة بلاستيك 3/4 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-20 16:41:50.944655+00	2026-04-11 16:56:54.539156+00	0.000	0.000	untracked
41c01f1c-ff76-4391-85d4-f5079c3787ce	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي فردي 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 15:39:54.460178+00	2026-04-13 12:24:57.378463+00	0.000	0.000	untracked
db4063c5-f89d-40d9-abd9-968984ad74f8	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي فردي 3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 21:26:32.249983+00	2026-04-13 12:25:03.889069+00	0.000	0.000	untracked
857d4856-aca0-4f69-89d8-59ed2d1b86d0	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامة خزان نحاس علبة بسن 3/8*1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-04-13 13:29:49.474776+00	0.000	0.000	tracked
111240d0-c336-4cf3-9cd2-6779a85cb709	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي مجوز 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 15:37:24.090484+00	2026-04-13 12:25:22.387662+00	0.000	0.000	tracked
66e9c7ca-229c-4dbb-9f3a-345225214c9f	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي مجوز 3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-02-02 21:30:11.403724+00	2026-04-13 12:25:31.731596+00	0.000	0.000	tracked
45b07094-6fd8-4438-aa7b-4ba17e5ed897	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3" ماليزي 	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:10:48.025512+00	2026-04-13 13:54:58.174816+00	0.000	0.000	tracked
d78e3631-becb-459d-bcb7-f626d9bdae58	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون بانيو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:17:15.44432+00	2026-04-13 13:54:33.36576+00	0.000	0.000	tracked
0c3f197e-b856-4f1f-b96f-fdb8e806da50	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3" ماليزي	\N	قطعة	70.00	35.00	30.00	\N	\N	\N	\N	\N	f	2026-03-15 17:09:04.979474+00	2026-04-13 13:54:44.907832+00	0.000	0.000	tracked
bfde9b7d-4434-46e2-9972-bc39262ad6ac	6e264538-d570-56e8-ab82-3a3db2f04764	كوع سن داخلي - سن 1/2 * 3/4  (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:03:52.399587+00	2026-01-19 19:03:52.399587+00	0.000	0.000	untracked
04584170-0c95-4aec-9669-fc9bc5778b8e	6e264538-d570-56e8-ab82-3a3db2f04764	جلبة سن داخلي - سن 1/2 * 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:04:00.511238+00	2026-01-19 19:04:00.511238+00	0.000	0.000	untracked
855d8d44-57d9-4704-9908-8fdefbf12615	6e264538-d570-56e8-ab82-3a3db2f04764	جلبة سن خارجي - سن 1/2 * 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:04:07.237227+00	2026-01-19 19:04:07.237227+00	0.000	0.000	untracked
62f17a04-2661-4859-8678-a0d17bbc0a0d	24af384e-9a22-58fd-bd52-970a3c97cad0	مشترك 3/4 * 3/4 سن داخلي (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:04:13.150707+00	2026-01-19 19:04:13.150707+00	0.000	0.000	untracked
3ccc958f-8b6a-4bd8-a9d0-47bba9de7485	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط دش روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 12:10:41.758539+00	2026-01-22 12:10:41.758539+00	0.000	0.000	untracked
751a8dd7-078f-4709-9144-9c29d8b89762	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط موكا دش (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:00:28.285706+00	2026-01-22 14:00:28.285706+00	0.000	0.000	untracked
cbb6ab60-767c-4ddb-be13-89063020cabc	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:02:07.150454+00	2026-01-22 14:02:07.150454+00	0.000	0.000	untracked
06095b8b-ee17-4436-9942-c9976657fd63	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ لومي (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:02:47.405899+00	2026-01-22 14:02:47.405899+00	0.000	0.000	untracked
1b0a5385-3616-4c3a-b745-a85f92393217	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ موكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:04:02.189476+00	2026-01-22 14:04:02.189476+00	0.000	0.000	untracked
1cda0ceb-91d1-46c2-966c-39fb3afa37af	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ سالمكو ابيض (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:07:27.101698+00	2026-01-22 14:07:27.101698+00	0.000	0.000	untracked
313c6041-991c-4284-86ba-400fc94cb85f	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش اليريا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:08:34.638235+00	2026-03-24 11:28:04.936399+00	0.000	0.000	untracked
0f6dcd53-d686-43ae-8d75-54b1a8d2fcfe	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ جولد روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:09:49.421859+00	2026-01-22 14:09:49.421859+00	0.000	0.000	untracked
ca3d769f-2e88-4ab4-a664-10168fd3f444	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش جولد روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:10:24.3023+00	2026-01-22 14:10:24.3023+00	0.000	0.000	untracked
42080636-8663-44f5-b4c1-9b39aaac1507	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش اوكر لومي (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:13:25.965227+00	2026-01-22 14:13:25.965227+00	0.000	0.000	untracked
6fbb04b8-4330-4c11-bfa4-8b1109d55f89	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط اوكر سالمكو ابيض (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:16:39.260973+00	2026-01-22 14:16:39.260973+00	0.000	0.000	untracked
21f29f18-4d31-44eb-8cbe-787b049dfa55	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش كوكو موكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:40:53.885962+00	2026-01-22 14:40:53.885962+00	0.000	0.000	untracked
6c320719-401e-47ac-bee3-21e7b61769b5	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش ساليمكو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:43:18.814499+00	2026-01-22 14:43:18.814499+00	0.000	0.000	untracked
10fad07e-e235-4c23-8975-fbf164f85ea0	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:46:39.725569+00	2026-01-22 14:46:39.725569+00	0.000	0.000	untracked
e4a2fec7-1530-4b1c-b279-8ea6e7fb894e	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ فيتو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:53:15.741383+00	2026-01-22 14:53:15.741383+00	0.000	0.000	untracked
9b47cbd8-d805-47d6-bd39-8452ad291acc	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ سينزو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:53:53.533228+00	2026-01-22 14:53:53.533228+00	0.000	0.000	untracked
0053a86b-d8a7-4da3-92dd-fd92a4e9bcc8	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ موكا احمر  (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:54:17.309819+00	2026-01-22 14:54:17.309819+00	0.000	0.000	untracked
dad20297-7d49-4231-bfd1-812ecb3ded63	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف ليمار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:55:06.989326+00	2026-01-22 14:55:06.989326+00	0.000	0.000	untracked
a4e213ae-e816-4c03-a379-402ec0d79454	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف سينزو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:55:27.229806+00	2026-01-22 14:55:27.229806+00	0.000	0.000	untracked
95070eb6-92ac-49bb-9242-b9d24fcfd7bb	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف روك MG (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:56:20.109743+00	2026-01-22 14:56:20.109743+00	0.000	0.000	untracked
5cd2a754-00cb-4a1c-a7bd-3ea5e0147927	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف سينيور (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:56:58.253773+00	2026-01-22 14:56:58.253773+00	0.000	0.000	untracked
f1f57c68-4a58-447a-85ac-8147d2acd1d9	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف النيل (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:57:26.765701+00	2026-01-22 14:57:26.765701+00	0.000	0.000	untracked
c412d1be-d6c6-417b-9f67-48f9129e145d	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط 1/2 بارد جنا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:01:58.830456+00	2026-01-22 15:01:58.830456+00	0.000	0.000	untracked
d3fec787-b312-4d8d-83f4-918c4b1add15	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شجرة دش ديتوريا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:03:06.732934+00	2026-01-22 15:03:06.732934+00	0.000	0.000	untracked
89153ada-a2e6-45ff-965d-a610fca6a73f	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه بزباله معدن	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:16:05.314159+00	2026-04-11 12:34:27.920969+00	0.000	0.000	untracked
58a4a59e-3495-4e62-b2d0-472aaebd65d6	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط دش سينزو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:08:55.197365+00	2026-01-22 15:08:55.197365+00	0.000	0.000	untracked
06ddd19d-3ce2-4821-af81-09a1691dbd66	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش جولدن ايجل (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:13:20.237613+00	2026-01-22 15:13:20.237613+00	0.000	0.000	untracked
112dcd47-c1b5-48e5-8c35-a607803fbab9	50aac995-d284-5518-bbb9-019cfdeb1378	طبة حوض ستار (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:00:28.989011+00	2026-01-25 17:00:28.989011+00	0.000	0.000	untracked
f03dd423-06f8-47ff-9f3f-38aeac20a897	50aac995-d284-5518-bbb9-019cfdeb1378	محبس مجوز محمل (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:03:16.445111+00	2026-01-25 17:03:16.445111+00	0.000	0.000	untracked
9f43f345-bb0d-4097-9ce2-8fc11499c952	50aac995-d284-5518-bbb9-019cfdeb1378	محبس مجوز خفيف (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:03:29.659999+00	2026-01-25 17:03:29.659999+00	0.000	0.000	untracked
0022d9ed-8597-4847-aa41-496c0f5f6fdc	50aac995-d284-5518-bbb9-019cfdeb1378	خزان شاور (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:04:10.236359+00	2026-01-25 17:04:10.236359+00	0.000	0.000	untracked
acd67601-084b-4d50-9c35-121344944338	50aac995-d284-5518-bbb9-019cfdeb1378	محبس جولد (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:04:35.499663+00	2026-01-25 17:04:35.499663+00	0.000	0.000	untracked
11cbf451-8e09-4ceb-b1d6-1093e8704a2f	50aac995-d284-5518-bbb9-019cfdeb1378	حنفية غسالة هواي (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:04:54.796142+00	2026-01-25 17:04:54.796142+00	0.000	0.000	untracked
364cf46d-c57a-4d8e-bb4d-76c81c41110b	50aac995-d284-5518-bbb9-019cfdeb1378	محبس هاينز (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:05:12.299668+00	2026-01-25 17:05:12.299668+00	0.000	0.000	untracked
1bdf30f3-f488-4e03-a464-31e600a3c012	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط دش جولدن ايجل	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:59:26.741401+00	2026-03-04 13:59:26.741401+00	0.000	0.000	untracked
ecdbb38a-6d75-4400-85a5-3aab9d88372b	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط دوش اوكر	\N	قطعة	650.00	580.00	520.00	\N	\N	\N	\N	\N	t	2026-03-15 16:51:10.228907+00	2026-03-15 16:51:10.228907+00	0.000	0.000	untracked
9270a294-f2ee-4bf5-8871-ba778fc8e784	50aac995-d284-5518-bbb9-019cfdeb1378	طقم خلاط اوكر	\N	طقم	1550.00	1450.00	1200.00	\N	\N	\N	\N	\N	t	2026-03-15 16:53:55.748347+00	2026-03-15 16:53:55.748347+00	0.000	0.000	untracked
f12652f3-f3c6-43ae-8afa-04fafd701c2f	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شجرة استالس	\N	قطعة	600.00	420.00	300.00	\N	\N	\N	\N	\N	t	2026-03-15 17:06:36.203073+00	2026-03-15 17:06:36.203073+00	0.000	0.000	untracked
a0bb2d53-4a9c-4d5f-bce9-69f0f7092fa4	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط 1/2 استالس مط	\N	قطعة	250.00	190.00	100.00	\N	\N	\N	\N	\N	t	2026-03-15 17:20:14.050966+00	2026-03-15 17:20:14.050966+00	0.000	0.000	untracked
0a184115-b9d7-4ab5-9d82-c864eb702b45	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة وش هاند ميكسر قصيرة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000	untracked
9d992477-0510-4e5d-82c2-89b66cc8658c	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة وش هاند ميكسر طويلة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000	untracked
37ee2418-56bb-4d8e-b0ec-fe9ffb1fc333	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة عكاز وش صغير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000	untracked
d6a1126f-180e-480d-9924-1fb69414f686	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة عكاز وش كبير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000	untracked
729d42f1-7d09-46f9-a4bf-58d11104de7b	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة مطبخ هاند ميكسر مقلوبة كبيرة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000	untracked
e196b412-5f2c-4a18-81ee-3c50385a03fc	201504f6-3716-569b-9502-2a404a8cbb03	وصلت خلاط 5 لنيا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:11:27.335241+00	2026-02-01 17:11:27.335241+00	0.000	0.000	untracked
eabea370-6202-46ed-836d-89822831f083	86600a27-d5d3-56ab-a8ed-e3ea152ea390	كوع عادة محمل 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:06:01.8035+00	2026-01-29 13:06:01.8035+00	0.000	0.000	untracked
a2cdd98c-fbff-4718-bb70-ebb3eb940b55	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل نحاس 3/5 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:11:59.962066+00	2026-01-29 13:11:59.962066+00	0.000	0.000	untracked
6652a94b-e908-4557-a060-95e8a2d1c9c3	86600a27-d5d3-56ab-a8ed-e3ea152ea390	كوع صنارة محمل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:26:04.321138+00	2026-01-29 13:26:04.321138+00	0.000	0.000	untracked
2bd5ddec-5128-4551-a96d-f826eaaec686	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل 3/4 نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:31:32.249287+00	2026-01-29 13:31:32.249287+00	0.000	0.000	untracked
129089d7-95d4-42cc-94ef-2e54da0be9f1	86600a27-d5d3-56ab-a8ed-e3ea152ea390	طبة 1/2 نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:33:31.976981+00	2026-01-29 13:33:31.976981+00	0.000	0.000	untracked
b4d85961-96ba-4080-aa56-285b5489712c	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سماعة نيكل 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:39:26.104821+00	2026-01-29 13:39:26.104821+00	0.000	0.000	untracked
e0e6359a-6bf8-43ed-bb47-0b0e63e10d65	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سماعة نيكل 3/4 * 1/2 نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:40:02.808686+00	2026-01-29 13:40:02.808686+00	0.000	0.000	untracked
fc080463-994d-4137-87fb-c0544751b8ac	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل خلاط صغير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:40:16.840735+00	2026-01-29 13:40:16.840735+00	0.000	0.000	untracked
4c4aa1f7-2214-4e18-86fc-792298942132	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل خلاط كبير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:40:35.207902+00	2026-01-29 13:40:35.207902+00	0.000	0.000	untracked
7dbbf287-1956-44eb-8f05-20c48068fa87	201504f6-3716-569b-9502-2a404a8cbb03	طقم كرنك خلاط استالس	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:07:27.044835+00	2026-04-04 09:09:51.021557+00	0.000	0.000	untracked
5d31eb67-6989-4113-8936-43dc6ae1a959	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 5 لينيا وش	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-04-04 09:06:06.760639+00	0.000	0.000	untracked
85d12824-8b4e-4805-a439-94123944367c	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 6 لينيا مطبخ	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-04-04 09:06:23.541531+00	0.000	0.000	untracked
8bfd6725-3128-4c54-b869-fc2a959df714	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة هاند ميكسر مطبخ	\N	عدد	90.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-04-04 09:06:42.312798+00	0.000	0.000	untracked
66dfac46-fd00-4ebf-93de-f48f6110b778	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 5 لينيا مطبخ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-29 12:36:28.051655+00	2026-04-04 09:07:19.25584+00	0.000	0.000	untracked
2a0cb6d2-3bf2-48b5-9454-37cd53b23c9e	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 6 لينيا وش	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-29 12:36:28.051655+00	2026-04-04 09:07:23.394307+00	0.000	0.000	untracked
39a64571-ec16-476d-be59-88ceef71426a	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة مطبخ هاند ميكسر وش	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-01-29 12:36:28.051655+00	2026-04-04 09:08:12.49931+00	0.000	0.000	untracked
3facfe2f-f0db-410c-b679-7e7082704488	201504f6-3716-569b-9502-2a404a8cbb03	هلاله ( 1 ) مسمار 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:06:07.674285+00	2026-04-04 09:13:53.928968+00	0.000	0.000	untracked
bf8c300e-e7d6-4072-9c5f-c1745542bf46	201504f6-3716-569b-9502-2a404a8cbb03	هلاله (2 ) مسمار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:06:27.799151+00	2026-04-04 09:15:10.084076+00	0.000	0.000	untracked
f28d6018-f8ef-4e25-b404-1830ea0d3708	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة هاند ميكسر عكاز مطبخ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:50:51.761397+00	2026-04-04 09:15:45.55376+00	0.000	0.000	untracked
de2a4366-eab4-4c04-9bd0-362a29eab7e8	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة عكاز هاند ميكسر 	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-04-04 09:16:33.231363+00	0.000	0.000	untracked
b656dab6-3e5f-43f4-9405-9c2dd680411f	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة مطبخ هاند ميكسر مقلوبة صغيرة	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-04-04 09:35:26.513596+00	0.000	0.000	untracked
1d30a4fe-fbfe-4d3e-886d-d7c5ec544240	201504f6-3716-569b-9502-2a404a8cbb03	صامولة قنطرة 6 لنيا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:09:23.581078+00	2026-02-01 17:09:23.581078+00	0.000	0.000	untracked
fbc41295-0338-4e49-b61e-79e99e9f5667	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل نحاس 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:09:04.443198+00	2026-01-29 13:09:04.443198+00	0.000	0.000	untracked
d7ce890d-87cd-46af-8486-d92bce906566	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط موكا مطبخ (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 21:03:25.955866+00	2026-01-25 21:03:25.955866+00	0.000	0.000	untracked
015510b5-5c17-40eb-8099-378255764017	86600a27-d5d3-56ab-a8ed-e3ea152ea390	مشترك نحاس 1/2 محمل	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:05:20.202709+00	2026-02-21 21:52:50.698951+00	0.000	0.000	untracked
87d4538d-0e02-44ee-976a-53651c8e11ab	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل خزان 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:04:56.586921+00	2026-04-11 15:05:09.378316+00	0.000	0.000	untracked
731e6d42-8a1f-466f-b80e-97784861e90c	86600a27-d5d3-56ab-a8ed-e3ea152ea390	كعب خلاط نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:40:51.095914+00	2026-01-29 13:40:51.095914+00	0.000	0.000	untracked
242e2fb5-5a2d-4d00-ba37-e9f08f40c31f	f0906684-99d3-55aa-9994-9427e941823e	كوع 1" عادة سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:10:14.72849+00	2026-02-04 14:10:14.72849+00	0.000	0.000	untracked
2a10fa6f-8cec-43fc-868a-d9c6b614e101	f0906684-99d3-55aa-9994-9427e941823e	كوع 1" مفتوح سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:12:26.727776+00	2026-02-04 14:12:26.727776+00	0.000	0.000	untracked
3896b31c-7763-425a-8bc2-d52a6b6ed94f	f0906684-99d3-55aa-9994-9427e941823e	جلبة 1" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:12:55.784626+00	2026-02-04 14:12:55.784626+00	0.000	0.000	untracked
48ff7790-a0dc-4c11-b27f-e1c8c92ca52f	f0906684-99d3-55aa-9994-9427e941823e	مشترك تي 1" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:13:35.832428+00	2026-02-04 14:13:35.832428+00	0.000	0.000	untracked
2d83aef3-45b0-41bb-9475-b1b64ab3bded	f0906684-99d3-55aa-9994-9427e941823e	مشترك واي 1" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:14:42.896833+00	2026-02-04 14:14:42.896833+00	0.000	0.000	untracked
58972db3-c507-4f0a-a8aa-77ba90cd06fd	f0906684-99d3-55aa-9994-9427e941823e	كوع عادة 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:16:09.84822+00	2026-02-04 14:16:09.84822+00	0.000	0.000	untracked
8e2e8783-9d76-478b-b10f-e9342e98e16f	f0906684-99d3-55aa-9994-9427e941823e	مشترك واي 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:16:44.775591+00	2026-02-04 14:16:44.775591+00	0.000	0.000	untracked
5a69faeb-91af-4ec9-85f2-6939c22df3d1	f0906684-99d3-55aa-9994-9427e941823e	كوع مفتوح 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 15:09:53.89195+00	2026-02-04 15:09:53.89195+00	0.000	0.000	untracked
8f7aafa6-b4da-421c-a7bd-f27fa96b1974	f0906684-99d3-55aa-9994-9427e941823e	جلبة عادة 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 15:22:56.563347+00	2026-02-04 15:22:56.563347+00	0.000	0.000	untracked
16215c47-6d07-4eab-a055-de8f98d0b6d8	f0906684-99d3-55aa-9994-9427e941823e	كوع 2" عادة سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:02:16.529075+00	2026-02-04 16:02:16.529075+00	0.000	0.000	untracked
75f27b8f-be6b-4bb7-90cd-6604cf2a14c1	f0906684-99d3-55aa-9994-9427e941823e	تي 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:05:12.25651+00	2026-02-04 16:05:12.25651+00	0.000	0.000	untracked
9bdfe990-a632-4e4a-a461-c97627f66aa2	f0906684-99d3-55aa-9994-9427e941823e	كوع مفتوح 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:05:35.775817+00	2026-02-04 16:05:35.775817+00	0.000	0.000	untracked
6bce2691-dbf2-484b-bd68-b1ca3e7404ed	f0906684-99d3-55aa-9994-9427e941823e	كوع عادة بباب 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:17:36.974994+00	2026-02-04 16:17:36.974994+00	0.000	0.000	untracked
8c61aff3-78b7-499c-a20c-f2e2d06f31c2	f0906684-99d3-55aa-9994-9427e941823e	تي 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:19:43.150728+00	2026-02-04 16:19:43.150728+00	0.000	0.000	untracked
04955fdd-d0f5-4355-a51b-4c78e6fa51b5	f0906684-99d3-55aa-9994-9427e941823e	واي 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:20:17.1682+00	2026-02-04 16:20:17.1682+00	0.000	0.000	untracked
74f991b9-037e-480f-b6d4-e47da50d2e4a	f0906684-99d3-55aa-9994-9427e941823e	تي بباب 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:24:20.57455+00	2026-02-04 16:24:20.57455+00	0.000	0.000	untracked
c9d4bbe8-5763-41f3-8fca-6328191b54c6	f0906684-99d3-55aa-9994-9427e941823e	كوع بباب 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:26:10.590267+00	2026-02-04 16:26:10.590267+00	0.000	0.000	untracked
01345ffe-fb1e-4b0b-9ccc-b52ce0716020	f0906684-99d3-55aa-9994-9427e941823e	تي 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:33:49.525696+00	2026-02-04 16:33:49.525696+00	0.000	0.000	untracked
ef927bc2-dd52-4c27-af97-abef6001cb3d	f0906684-99d3-55aa-9994-9427e941823e	جلبة 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:38:33.48579+00	2026-02-04 16:38:33.48579+00	0.000	0.000	untracked
7da00ad0-bb2c-4d44-b9d0-52caf278cd55	f0906684-99d3-55aa-9994-9427e941823e	طبة تسليك سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:40:02.365338+00	2026-02-04 16:40:02.365338+00	0.000	0.000	untracked
95397be8-d564-4c4d-a4d4-52bc321fb9e5	f0906684-99d3-55aa-9994-9427e941823e	تي بباب 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:15:36.281301+00	2026-02-04 19:15:36.281301+00	0.000	0.000	untracked
7516d39d-1ba9-4514-8694-b156c4b3f404	f0906684-99d3-55aa-9994-9427e941823e	جلبة لحام 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:16:50.471338+00	2026-02-04 19:16:50.471338+00	0.000	0.000	untracked
446eca70-ca36-48ac-86a0-10f6e18c01a9	f0906684-99d3-55aa-9994-9427e941823e	تي 4" عادة سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:18:56.727941+00	2026-02-04 19:18:56.727941+00	0.000	0.000	untracked
8d300a64-8928-47af-9d61-e8cda073dcc3	f0906684-99d3-55aa-9994-9427e941823e	كوع مفتوح 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:20:28.168356+00	2026-02-04 19:20:28.168356+00	0.000	0.000	untracked
4d4366c5-3ee6-44bf-ac5a-a341aaf15057	f0906684-99d3-55aa-9994-9427e941823e	برقع بلاعة سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:22:12.903896+00	2026-02-04 19:22:12.903896+00	0.000	0.000	untracked
1cd6083f-f377-478d-b54e-a3a0b8a66595	f0906684-99d3-55aa-9994-9427e941823e	نقاص 2 * 1.5 سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:23:01.208091+00	2026-02-04 19:23:01.208091+00	0.000	0.000	untracked
2653d564-e6ce-4bd7-86f0-f84f09d3c529	f0906684-99d3-55aa-9994-9427e941823e	نقاص 1.5 * 1 سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:23:32.151448+00	2026-02-04 19:23:32.151448+00	0.000	0.000	untracked
0df5e9da-aa4e-44b8-aa5b-bf926888b7c6	f0906684-99d3-55aa-9994-9427e941823e	هواية 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:24:15.993677+00	2026-02-04 19:24:15.993677+00	0.000	0.000	untracked
b2695def-80ca-4556-85df-e9cf5440d08d	f0906684-99d3-55aa-9994-9427e941823e	هواية 1" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:25:31.479382+00	2026-02-04 19:25:31.479382+00	0.000	0.000	untracked
a092d113-7153-47dd-8589-2a48f7807e6d	f0906684-99d3-55aa-9994-9427e941823e	واي 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:27:36.55209+00	2026-02-04 19:27:36.55209+00	0.000	0.000	untracked
ea08286a-83e1-4151-8221-3ad4cbf6fd9d	f0906684-99d3-55aa-9994-9427e941823e	وصلة تمدد 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:32:54.583146+00	2026-02-04 19:32:54.583146+00	0.000	0.000	untracked
a01fae38-7472-40c8-a340-7915a7359b6b	f0906684-99d3-55aa-9994-9427e941823e	كوع بسن داخلي 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:34:37.70368+00	2026-02-04 19:34:37.70368+00	0.000	0.000	untracked
1697cc2b-8aa6-40c8-8d42-412bcb10dca9	f0906684-99d3-55aa-9994-9427e941823e	اختبار	\N	عدد	111.00	0.00	0.00	\N	small	standard	plastic	\N	t	2026-02-06 22:00:13.12123+00	2026-02-06 22:00:13.12123+00	0.000	0.000	untracked
cca800ba-631f-49da-94c9-8ea5b8e8ea6b	92d22b39-ff32-572a-a53e-3e3942306976	طبة 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 16:25:42.309536+00	2026-02-05 16:25:42.309536+00	0.000	0.000	untracked
ffd44b52-646c-48dd-ad49-7a955a9dcb21	92d22b39-ff32-572a-a53e-3e3942306976	طبة كاب 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 16:30:06.145087+00	2026-02-05 16:30:06.145087+00	0.000	0.000	untracked
d468aa72-a661-4d6a-bac0-431892931b0b	92d22b39-ff32-572a-a53e-3e3942306976	طبة كاب 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:06:40.193488+00	2026-02-05 17:06:40.193488+00	0.000	0.000	untracked
fdbf99f3-062b-4011-814f-e8e50634b02d	92d22b39-ff32-572a-a53e-3e3942306976	تي 1.5 * 0.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:08:11.609015+00	2026-02-05 17:08:11.609015+00	0.000	0.000	untracked
74d2c47d-ad15-41de-98b4-b4d6d98c659c	92d22b39-ff32-572a-a53e-3e3942306976	تي 2" * 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:55:14.189288+00	2026-02-05 17:55:14.189288+00	0.000	0.000	untracked
f305a965-af31-433c-9514-e050f4508875	92d22b39-ff32-572a-a53e-3e3942306976	تي 2" * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:55:44.690649+00	2026-02-05 17:55:44.690649+00	0.000	0.000	untracked
df868d6f-bda5-4441-893a-9fe733f91e32	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1.5 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:59:49.503819+00	2026-02-05 17:59:49.503819+00	0.000	0.000	untracked
1f687959-dffd-407a-83d6-63980b3fb35e	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:07:35.726949+00	2026-02-05 18:07:35.726949+00	0.000	0.000	untracked
7e96927a-e82c-40dd-b730-40452540550b	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 2 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:09:45.183057+00	2026-02-05 18:09:45.183057+00	0.000	0.000	untracked
b93d809f-b9c2-462f-b50f-584a05e408f7	92d22b39-ff32-572a-a53e-3e3942306976	تي 1.5 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:10:11.359066+00	2026-02-05 18:10:11.359066+00	0.000	0.000	untracked
7e82c0ee-eb1a-48c8-8c31-d57c4ee62112	92d22b39-ff32-572a-a53e-3e3942306976	طبة اختبار الوان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:12:26.36636+00	2026-02-05 18:12:26.36636+00	0.000	0.000	untracked
5582619d-2012-4f07-83c0-c904f6e57bc3	92d22b39-ff32-572a-a53e-3e3942306976	طبة 2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:13:57.381539+00	2026-02-05 18:13:57.381539+00	0.000	0.000	untracked
ffa0d3cc-9d21-44ee-8ac7-5e3b17ddee92	92d22b39-ff32-572a-a53e-3e3942306976	تي لحام 1.5 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:15:28.382625+00	2026-02-05 18:15:28.382625+00	0.000	0.000	untracked
3da95089-bfa4-407c-ba9d-8b096302c4ef	92d22b39-ff32-572a-a53e-3e3942306976	تي 2 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:16:10.846336+00	2026-02-05 18:16:10.846336+00	0.000	0.000	untracked
46401744-e12c-435b-baa4-5fd53469118e	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 2 * 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:18:47.855139+00	2026-02-05 18:18:47.855139+00	0.000	0.000	untracked
658992d5-1f93-4309-afb5-22dd41777f6c	92d22b39-ff32-572a-a53e-3e3942306976	تي لحام 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:19:46.542462+00	2026-02-05 18:19:46.542462+00	0.000	0.000	untracked
9dcdf30e-a5b5-4636-af3b-a8491cb82704	92d22b39-ff32-572a-a53e-3e3942306976	تي لحام 1" * 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:21:11.054137+00	2026-02-05 18:21:11.054137+00	0.000	0.000	untracked
429fcc2b-56f4-4e32-a3bf-3437b64a3201	92d22b39-ff32-572a-a53e-3e3942306976	تي لحام 1 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:21:36.974283+00	2026-02-05 18:21:36.974283+00	0.000	0.000	untracked
99bec8cc-8f51-4bff-b8c4-6c79bef4892e	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1.5 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:25:47.389968+00	2026-02-05 18:25:47.389968+00	0.000	0.000	untracked
9fa7f793-227b-44d7-a95c-c88c5705e89c	92d22b39-ff32-572a-a53e-3e3942306976	كوع لحام 1 * 0.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:26:25.710839+00	2026-02-05 18:26:25.710839+00	0.000	0.000	untracked
b0010911-a553-4480-9d0d-d51e432e61b6	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:27:11.517947+00	2026-02-05 18:27:11.517947+00	0.000	0.000	untracked
4ff0fa6b-1b53-4064-98b5-30bba06b1dfa	92d22b39-ff32-572a-a53e-3e3942306976	كوع 1 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:27:37.822443+00	2026-02-05 18:27:37.822443+00	0.000	0.000	untracked
92565437-4f18-408f-ac3d-ffc4624663ed	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1.5 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:28:53.022014+00	2026-02-05 18:28:53.022014+00	0.000	0.000	untracked
55612a96-6a02-474c-ac65-009a45ab9d9f	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:30:26.142125+00	2026-02-05 18:30:26.142125+00	0.000	0.000	untracked
55747c66-cd99-453d-be45-ecd7ce155ec3	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:33:01.949471+00	2026-02-05 18:33:01.949471+00	0.000	0.000	untracked
64c281e1-8184-463e-bee6-0e83f1b9b7aa	8f28d905-151c-55b6-8379-1d5332eced40	كوع عادة 4" BFS	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:27:12.223007+00	2026-02-17 17:27:12.223007+00	0.000	0.000	untracked
48d5fc8b-2739-48e2-9ee4-3c0fab0d6bf7	8f28d905-151c-55b6-8379-1d5332eced40	كوع مفتوح 4" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:27:41.838572+00	2026-02-17 17:27:41.838572+00	0.000	0.000	untracked
dfa66d4f-7243-48a9-a33c-5e072222cac4	8f28d905-151c-55b6-8379-1d5332eced40	كوع بباب 4" BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:28:08.527426+00	2026-02-17 17:28:08.527426+00	0.000	0.000	untracked
6567f7cf-c146-4df8-a3be-8650e082cad7	8f28d905-151c-55b6-8379-1d5332eced40	كوع باب 4" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:28:35.854887+00	2026-02-17 17:28:35.854887+00	0.000	0.000	untracked
dcaf8c13-ddc1-4fb6-849b-694a0c59edc2	8f28d905-151c-55b6-8379-1d5332eced40	جلبة لحام 4" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:29:00.27245+00	2026-02-17 17:29:00.27245+00	0.000	0.000	untracked
fc3a49eb-0812-42b7-9f84-08333b2559d8	8f28d905-151c-55b6-8379-1d5332eced40	جلبة اصلاح 3" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:30:02.215396+00	2026-02-17 17:30:02.215396+00	0.000	0.000	untracked
ca29c5d5-7258-4543-9775-474b7a2e2256	8f28d905-151c-55b6-8379-1d5332eced40	جلبة لحام 3" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:30:43.439673+00	2026-02-17 17:30:43.439673+00	0.000	0.000	untracked
597008d4-6870-4765-96e9-29436230b29e	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 3 على 2 روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:34:22.734638+00	2026-02-17 17:34:22.734638+00	0.000	0.000	untracked
9f1b35b7-6bd2-40cd-8453-c6288391b2a8	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 3 على 2 باب روك	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:37:19.487416+00	2026-02-17 17:37:19.487416+00	0.000	0.000	untracked
63f63c8e-27f5-479a-a4ed-48d8ef15c1e0	8f28d905-151c-55b6-8379-1d5332eced40	نقاص 6 على 4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:37:36.206737+00	2026-02-17 17:37:36.206737+00	0.000	0.000	untracked
9230b14e-5c16-482b-998a-c3cc6242c67a	8f28d905-151c-55b6-8379-1d5332eced40	صليبة 3" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:39:44.590162+00	2026-02-17 17:39:44.590162+00	0.000	0.000	untracked
9838af29-0eeb-401b-b8b9-e7272e248cc2	8f28d905-151c-55b6-8379-1d5332eced40	نقاص 4 على 3	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:40:22.670993+00	2026-02-17 17:40:22.670993+00	0.000	0.000	untracked
89c711d3-026a-4080-90e5-5854aadbfad2	8f28d905-151c-55b6-8379-1d5332eced40	نقاص 3 على 2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:40:54.669555+00	2026-02-17 17:40:54.669555+00	0.000	0.000	untracked
80955f9e-f1a7-4dd6-b254-d0aae0786059	8f28d905-151c-55b6-8379-1d5332eced40	نقاص 4 على 2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:41:33.598368+00	2026-02-17 17:41:33.598368+00	0.000	0.000	untracked
5d19848f-34eb-48f2-8d0e-bff2658bb264	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 3" بباب روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:41:50.718026+00	2026-02-17 17:41:50.718026+00	0.000	0.000	untracked
71e6c269-0b0a-4ff3-95bd-a105988cdda0	8f28d905-151c-55b6-8379-1d5332eced40	واي 3" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:42:12.735868+00	2026-02-17 17:42:12.735868+00	0.000	0.000	untracked
ea4801eb-2031-4f2d-a875-16e122174ba1	8f28d905-151c-55b6-8379-1d5332eced40	مشترك واي 4"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:00:06.469912+00	2026-02-20 19:00:06.469912+00	0.000	0.000	untracked
27ae4b21-56ff-449e-bdc0-e3412e63d57c	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4 على 2 بباب	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:00:37.78151+00	2026-02-20 19:00:37.78151+00	0.000	0.000	untracked
5a9a1c42-136b-45d4-93f1-0ca22ca48e21	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4 على 2 عادة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:01:26.605874+00	2026-02-20 19:01:26.605874+00	0.000	0.000	untracked
53a965c4-ec9f-4331-8c09-7ae3eb11c2bc	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4 على 3 بباب	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:03:19.581906+00	2026-02-20 19:03:19.581906+00	0.000	0.000	untracked
0b532dc7-1461-473d-a967-fca1cef3817c	8f28d905-151c-55b6-8379-1d5332eced40	جلبة لحام 6" 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:09:15.685113+00	2026-02-20 19:09:45.006064+00	0.000	0.000	untracked
d886bc4f-a8d0-425d-8919-b03e171ca969	8f28d905-151c-55b6-8379-1d5332eced40	جلبة لحام  6" 160	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:10:13.045315+00	2026-02-20 19:10:13.045315+00	0.000	0.000	untracked
f3d9f278-2361-45dc-b5c3-9b12be2f20e8	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6" 160 بباب	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:10:38.32447+00	2026-02-20 19:10:38.32447+00	0.000	0.000	untracked
18ef625c-0276-44dd-890c-8917d875580e	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6" 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:11:15.28564+00	2026-02-20 19:11:15.28564+00	0.000	0.000	untracked
19df2fa4-493a-4977-9f28-df694c4fa19e	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6" عادة 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:11:29.877766+00	2026-02-20 19:11:29.877766+00	0.000	0.000	untracked
c48b78b3-b5bf-41f2-8a1e-dd3cb2497de6	8f28d905-151c-55b6-8379-1d5332eced40	كوع 6" بباب 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:11:42.548745+00	2026-02-20 19:11:42.548745+00	0.000	0.000	untracked
9d9a0a7f-d9f6-4032-89ba-e04abc66217f	8f28d905-151c-55b6-8379-1d5332eced40	كوع 6" بوصة بباب 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:11:53.589739+00	2026-02-20 19:11:53.589739+00	0.000	0.000	untracked
274c2b30-5c67-452d-8668-d0e04a0f3752	8f28d905-151c-55b6-8379-1d5332eced40	كوع مفتوح 6"بباب 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:12:24.357203+00	2026-02-20 19:12:24.357203+00	0.000	0.000	untracked
d936244e-daa6-4f8e-a484-e8976bd04eb7	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/2 عاده	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:11:53.080656+00	2026-02-21 21:11:53.080656+00	0.000	0.000	untracked
f2dee181-2ff3-4ca5-a5eb-610dc49f5969	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/3 باب	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:12:37.221354+00	2026-02-21 21:12:37.221354+00	0.000	0.000	untracked
c3e347d9-49ce-471d-95b9-e53b8aef5a65	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/3 عاده	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:13:39.109783+00	2026-02-21 21:13:39.109783+00	0.000	0.000	untracked
87d7c4ab-4a5e-4140-9b56-693d38a64a63	8f28d905-151c-55b6-8379-1d5332eced40	جلبه لحام 6 بوصه168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:17:12.917242+00	2026-02-21 21:17:12.917242+00	0.000	0.000	untracked
a44e2af6-528b-4e34-9e0e-a8b4a4ab7198	8f28d905-151c-55b6-8379-1d5332eced40	جلبه لحام 6 بوصه 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:17:53.237769+00	2026-02-21 21:17:53.237769+00	0.000	0.000	untracked
c8ed0258-b82f-46df-b1d5-a9cca14ff8fa	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6 بوصه 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:18:37.299647+00	2026-02-21 21:18:37.299647+00	0.000	0.000	untracked
6deedd3b-0c5a-4535-b6e9-df2e2ae52399	8f28d905-151c-55b6-8379-1d5332eced40	مشترك باب 6 بوصه 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:19:32.292231+00	2026-02-21 21:19:32.292231+00	0.000	0.000	untracked
b6cc78ec-f150-4350-90b6-f3ae1f4068d3	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6بوصه 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:20:26.886073+00	2026-02-21 21:20:26.886073+00	0.000	0.000	untracked
1ce1c5c8-03bb-4f93-8e4c-84a6b69f386c	8f28d905-151c-55b6-8379-1d5332eced40	كوع باب 6 بوصه 168 روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:21:26.531987+00	2026-02-21 21:21:26.531987+00	0.000	0.000	untracked
1587c12f-d8dc-40f5-8d22-d051af0287fd	8f28d905-151c-55b6-8379-1d5332eced40	كوع باب 6 بوصه 160 روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:22:21.540549+00	2026-02-21 21:22:21.540549+00	0.000	0.000	untracked
433f723b-d4d3-4dbe-9866-49c9fcd6c040	8f28d905-151c-55b6-8379-1d5332eced40	كوع مفتوح 6 بوصه 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:23:01.828092+00	2026-02-21 21:23:01.828092+00	0.000	0.000	untracked
c973aa90-e274-4a13-bd63-fb0141d26fb5	8f28d905-151c-55b6-8379-1d5332eced40	كوع عاده 6 بوصه 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:23:38.899672+00	2026-02-21 21:23:38.899672+00	0.000	0.000	untracked
429a54f9-6312-4e78-a0f0-3621129feb75	8f28d905-151c-55b6-8379-1d5332eced40	كوع مفتوح 6 بوصه 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:24:14.886048+00	2026-02-21 21:24:14.886048+00	0.000	0.000	untracked
48272cca-653d-4506-b8fd-d5e3a4f1835f	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6/4 160*110	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:25:05.66843+00	2026-02-21 21:25:05.66843+00	0.000	0.000	untracked
4e81ce7f-47a6-4813-ae27-30d0d1753051	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6/4 168*114	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:25:54.564452+00	2026-02-21 21:25:54.564452+00	0.000	0.000	untracked
125dffb9-8af1-4a61-b5b6-89d48a631935	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/3BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:26:58.852132+00	2026-02-21 21:26:58.852132+00	0.000	0.000	untracked
c987d093-12be-452d-b2b7-bc0eebcf8389	8f28d905-151c-55b6-8379-1d5332eced40	مشترك باب 4/3 البحر الأحمر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:28:06.131785+00	2026-02-21 21:28:06.131785+00	0.000	0.000	untracked
c7f3e93a-438f-480a-977a-4b1c03769984	8f28d905-151c-55b6-8379-1d5332eced40	صليبه 4/2 الأهرام	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:28:45.65167+00	2026-02-21 21:28:45.65167+00	0.000	0.000	untracked
c1a296c0-6471-45fd-bb5e-5f91f68e77fd	8f28d905-151c-55b6-8379-1d5332eced40	جلبه لحام 4 بوصه روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:29:27.395828+00	2026-02-21 21:29:27.395828+00	0.000	0.000	untracked
e8064580-f5a5-42d8-a083-bd3e3d3f4481	8f28d905-151c-55b6-8379-1d5332eced40	جلبه اصلاح 4 بوصه روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:30:08.77231+00	2026-02-21 21:30:08.77231+00	0.000	0.000	untracked
7bd70918-ce49-4b75-b72c-18154bd2f79a	8f28d905-151c-55b6-8379-1d5332eced40	واى 4 بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:32:32.709138+00	2026-02-21 21:32:32.709138+00	0.000	0.000	untracked
0fe7c2a0-f60e-4f15-b284-2c8b1b12d7dc	8f28d905-151c-55b6-8379-1d5332eced40	مشترك باب 4/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:33:11.363362+00	2026-02-21 21:33:11.363362+00	0.000	0.000	untracked
ec568ee9-0b5f-4dc4-a628-fd3f5fe9db4d	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:33:51.187818+00	2026-02-21 21:33:51.187818+00	0.000	0.000	untracked
de486650-4431-4dde-aa4d-4ce6be1554d8	8f28d905-151c-55b6-8379-1d5332eced40	مشترك باب 4/3	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:34:49.379716+00	2026-02-21 21:34:49.379716+00	0.000	0.000	untracked
c5f83958-3304-4314-a56f-7fe15431bc7b	ae20d096-97b0-524d-bf38-e8865a491102	كوع نزل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:01:28.455547+00	2026-03-10 01:01:28.455547+00	0.000	0.000	untracked
81f74c2a-1ec7-4771-9329-92b0d0eb7ddd	ae20d096-97b0-524d-bf38-e8865a491102	شيك بلف لاكور 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:01:52.695222+00	2026-03-10 01:01:52.695222+00	0.000	0.000	untracked
561a1696-03a7-4801-8efd-a117a2121f3b	ae20d096-97b0-524d-bf38-e8865a491102	شيك بلف لاكور 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:02:12.903167+00	2026-03-10 01:02:12.903167+00	0.000	0.000	untracked
e7cb2e9b-10a3-42a5-9c43-04f5fc233e88	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/3	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:35:23.395697+00	2026-02-21 21:35:23.395697+00	0.000	0.000	untracked
150417bc-5700-4216-b3b2-8025ab306799	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1" BFS	\N	قطعة	0.00	0.00	0.00	BFS	1 بوصة	\N	بولي	\N	t	2026-02-17 16:17:16.570873+00	2026-02-17 16:17:16.570873+00	0.000	0.000	untracked
8f408e6d-5856-4378-a341-ef62648949ea	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 2" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:35:32.866681+00	2026-02-17 16:35:32.866681+00	0.000	0.000	untracked
6bacb56d-ae76-419f-93ce-564835dd276f	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1.5" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:36:26.161745+00	2026-02-17 16:36:26.161745+00	0.000	0.000	untracked
50092680-cdcf-4383-8803-ec896ba51cb9	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:37:15.041683+00	2026-02-17 16:37:15.041683+00	0.000	0.000	untracked
d60038ee-8ce8-44e1-8e87-3e0e75660752	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1*3/4" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:39:37.13686+00	2026-02-17 16:39:37.13686+00	0.000	0.000	untracked
44a29ecc-7b57-44f8-9298-01d1a42f76d4	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:40:24.241494+00	2026-02-17 16:40:24.241494+00	0.000	0.000	untracked
9f22d4f4-5c38-4ca7-9078-a9d451317a5f	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1*3/4 كايرو ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:42:32.658476+00	2026-02-17 16:42:32.658476+00	0.000	0.000	untracked
92a0b6e4-83c5-4abe-8dad-32bdf4c0df62	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1" كايرو ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:43:09.825812+00	2026-02-17 16:43:09.825812+00	0.000	0.000	untracked
6416cbb3-ef5c-4b48-910c-e1f891054f13	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1.5 بوصة BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:43:37.217406+00	2026-02-17 16:43:37.217406+00	0.000	0.000	untracked
9430efeb-9681-4466-b405-c11f7fd0411e	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1.5" معزول اكوا جرين	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:44:19.088721+00	2026-02-17 16:44:19.088721+00	0.000	0.000	untracked
3041ec21-6f51-4485-8515-b10a24942254	36041da5-c9a4-574f-9538-790b9601a464	تي سن داخلي عادي 1" اكوا ستار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:44:59.408798+00	2026-02-17 16:44:59.408798+00	0.000	0.000	untracked
753605cc-8cdb-4fa2-a0c3-174686ddedf4	36041da5-c9a4-574f-9538-790b9601a464	تي سن داخلي عالي 1" اكوا ستار	\N	عدد	0.00	0.00	0.00	\N	\N	ض	\N	\N	t	2026-02-17 16:45:23.904255+00	2026-02-17 16:45:23.904255+00	0.000	0.000	untracked
a4924db4-ea93-4351-9379-4280a11f5b6f	36041da5-c9a4-574f-9538-790b9601a464	كوع بسن داخلي 1*3/4" لافيستا	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:07:52.017481+00	2026-02-17 17:07:52.017481+00	0.000	0.000	untracked
51d95493-39bf-475c-9813-c22378608033	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 2" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:08:23.232776+00	2026-02-17 17:08:23.232776+00	0.000	0.000	untracked
a42630ba-4abb-49ad-b469-7860b870c6bd	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 2" BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:17:27.78349+00	2026-02-17 17:17:27.78349+00	0.000	0.000	untracked
81b8e587-43f6-4aa7-89f4-2a959a309ccd	36041da5-c9a4-574f-9538-790b9601a464	تي محبس دفن 1*3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:20:28.3524+00	2026-02-17 17:20:28.3524+00	0.000	0.000	untracked
bba112a6-5123-4eec-8359-ab2005280f18	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 3/4 ستار ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:22:52.6234+00	2026-02-17 17:22:52.6234+00	0.000	0.000	untracked
dc7a612e-4896-4e1b-992c-445b206f40f7	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 3/4 ستار ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:23:34.527814+00	2026-02-17 17:23:34.527814+00	0.000	0.000	untracked
3c49a84e-2451-459c-81a9-50577aa031ff	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1" معزول BFS	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:24:27.167207+00	2026-02-17 17:24:27.167207+00	0.000	0.000	untracked
5a108d5a-5cd0-4061-a61a-8487514cd407	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1" معزول BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:25:02.719521+00	2026-02-17 17:25:02.719521+00	0.000	0.000	untracked
7637f2f6-5553-4362-9abe-b79b9b211e66	36041da5-c9a4-574f-9538-790b9601a464	تي لحام 2" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:17:58.17133+00	2026-02-17 16:17:58.17133+00	0.000	0.000	untracked
612e2397-4ece-4c57-a7f9-842843bed5be	36041da5-c9a4-574f-9538-790b9601a464	تي لحام 1.5" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:19:05.506041+00	2026-02-17 16:19:05.506041+00	0.000	0.000	untracked
955997b7-2036-4f64-adf6-26ee55975902	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 1.5 اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:21:11.874888+00	2026-02-17 16:21:11.874888+00	0.000	0.000	untracked
25786994-56ff-4a82-9b45-c8d30fc092c8	36041da5-c9a4-574f-9538-790b9601a464	كوع بسن داخلي 1*3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:22:12.169365+00	2026-02-17 16:22:12.169365+00	0.000	0.000	untracked
8f6beea1-072b-4f7d-9bc6-8591373b292e	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 2" اكوا روك	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:24:05.394756+00	2026-02-17 16:24:05.394756+00	0.000	0.000	untracked
3d6cff07-15a4-4c75-992d-ce195ec48a0c	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:25:41.826927+00	2026-02-17 16:25:41.826927+00	0.000	0.000	untracked
d2a03983-48c8-42f0-8675-2b0aeec3e469	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 1" كايرو ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:26:24.833411+00	2026-02-17 16:26:24.833411+00	0.000	0.000	untracked
356ad760-f17e-4108-aa87-3f44b452fbd0	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 1" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:27:24.738933+00	2026-02-17 16:27:24.738933+00	0.000	0.000	untracked
511fc549-b298-481f-ae1a-d0cc9b4dfe9d	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1.5" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:28:24.929834+00	2026-02-17 16:28:24.929834+00	0.000	0.000	untracked
3fc85ed1-884e-4034-9ac6-2dd78c114a4b	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1.5" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:29:08.465047+00	2026-02-17 16:29:08.465047+00	0.000	0.000	untracked
4c046095-bd35-4fe7-ba57-b3fe61d3b3b9	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1.5" معزول BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:30:14.513404+00	2026-02-17 16:30:14.513404+00	0.000	0.000	untracked
fb5099b2-64e9-452e-b4d6-2c3591a1b042	36041da5-c9a4-574f-9538-790b9601a464	تي سن 1 * 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:31:07.986514+00	2026-02-17 16:31:07.986514+00	0.000	0.000	untracked
556f835a-5c2b-44a5-a3a2-086a96b984d3	36041da5-c9a4-574f-9538-790b9601a464	كوع بسن 1" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:31:57.905305+00	2026-02-17 16:31:57.905305+00	0.000	0.000	untracked
2cc00c44-0fde-4eaf-9a50-927b79ab7097	36041da5-c9a4-574f-9538-790b9601a464	تي لحام 1" اكوا روك	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:33:34.561086+00	2026-02-17 16:33:34.561086+00	0.000	0.000	untracked
46051af4-1f3c-4cb8-8018-08c7158d73c4	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 2" BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:34:17.409953+00	2026-02-17 16:34:17.409953+00	0.000	0.000	untracked
762e3eca-4c16-438c-bde5-49aebf6d8be9	36041da5-c9a4-574f-9538-790b9601a464	تي لحام 1" BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:35:01.264861+00	2026-02-17 16:35:01.264861+00	0.000	0.000	untracked
8bf8a752-b3fe-4e2c-9f0f-6396f484f085	d17128f8-94aa-54ce-87d8-4dc515f98bf8	منتج تجريبي	\N	عدد	0.00	0.00	10.00		\N	\N	\N	\N	f	2026-03-30 01:42:54.200292+00	2026-04-04 10:43:46.841368+00	0.000	0.000	untracked
517e8569-1a19-4a7b-8743-c6a9df8adae2	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حنفية كولمن		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-09 15:30:38.738082+00	2026-04-09 15:30:38.738082+00	0.000	0.000	untracked
8ee97fac-d9e7-46f2-87d2-6f252272cc43	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط موكا وش (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 21:03:46.179096+00	2026-01-25 21:03:46.179096+00	0.000	0.000	untracked
92e36fa1-8349-447e-a7be-511d6f209f20	201504f6-3716-569b-9502-2a404a8cbb03	مشترك لافو مانو 5 لينا 		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 14:52:10.533839+00	2026-04-11 14:52:10.533839+00	0.000	0.000	untracked
01c759af-1334-4521-be65-58d69f5d3158	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بسن خارجي 3/4		عدد	0.00	0.00	0.00		\N	\N	\N	\N	t	2026-04-11 15:21:09.100886+00	2026-04-15 15:43:16.458007+00	0.000	0.000	tracked
\.


--
-- Data for Name: purchase_order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchase_order_items (id, po_id, product_id, qty_ordered, qty_received, unit_cost, notes) FROM stdin;
13d4341d-4721-4547-b4d7-3498c6eb5650	362b6e0d-4f17-4662-875b-1e63005a2d44	c8b78e53-a457-4b32-8897-c449f3fe1e4f	5.000	5.000	10.00	\N
\.


--
-- Data for Name: purchase_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchase_orders (id, po_number, supplier_id, warehouse_id, created_by, status, notes, created_at, received_at, amount_paid, received_by_name, invoice_image_url) FROM stdin;
362b6e0d-4f17-4662-875b-1e63005a2d44	PO-001004	\N	59a2b8d7-e26b-4979-ae0e-3984f1b711b2	f00d039c-caa7-5b00-adba-365ed90c5f10	received	\N	2026-03-30 03:47:08.364144+00	2026-03-30 04:16:19.209469+00	0.00	\N	/uploads/po_362b6e0d-4f17-4662-875b-1e63005a2d44.png
\.


--
-- Data for Name: purchase_price_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchase_price_history (id, product_id, po_id, supplier_id, old_cost, new_cost, created_at) FROM stdin;
8cc754cb-b7d8-4294-b054-bbe98a5dae81	c8b78e53-a457-4b32-8897-c449f3fe1e4f	362b6e0d-4f17-4662-875b-1e63005a2d44	\N	15.50	10.00	2026-03-30 04:16:18.96905+00
\.


--
-- Data for Name: safe_deposits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.safe_deposits (id, safe_id, shift_id, warehouse_id, amount, received_by, received_by_name, deposited_by, deposited_by_name, notes, doc_number, created_at) FROM stdin;
eed54ceb-7f07-4eef-b38d-e9f597669599	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	1500.00	f00d039c-caa7-5b00-adba-365ed90c5f10	عمار محمد السيد	f00d039c-caa7-5b00-adba-365ed90c5f10	عمار محمد السيد	توريد يومي	DEP-001031	2026-03-31 16:50:27.998146+00
2cf8efcc-fa04-4295-913c-59da5b54624f	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	81d14179-f091-4b8c-b756-8da0717ea007	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	530.00	90b16bd6-d77a-456c-93fe-04c9a8eb445e	مؤمن محمد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	ندا خالد احمد النجار	تسليم الدرج عند إغلاق الوردية	DEP-001043	2026-04-04 09:38:10.606645+00
c8a33027-3e0a-4b3a-a0ea-5eba0176755a	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	e5355dec-89d0-445f-9fc7-85065801c28c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	4715.00	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	محمد احمد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	ندا خالد احمد النجار	تسليم الدرج عند إغلاق الوردية	DEP-001056	2026-04-05 08:48:51.430216+00
8a7b52c2-61ad-4187-941f-9e03dee22b28	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	900146ce-a935-43ea-a6d4-647276e80612	536e6eba-c111-4d60-b812-ead42ab23883	3400.00	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	محمد احمد	f00d039c-caa7-5b00-adba-365ed90c5f10	عمار محمد السيد	تسليم الدرج عند إغلاق الوردية	DEP-001057	2026-04-09 17:00:21.77481+00
1afab27a-984e-4b4b-94bc-8cc8840b806b	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	8c089b6f-0320-44e1-a2aa-8845c90b71aa	536e6eba-c111-4d60-b812-ead42ab23883	2275.00	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	محمد احمد	85ba0e1f-040c-44b2-90a3-0afcaa30178b	الشيخ ابراهيم	تسليم الدرج عند إغلاق الوردية	DEP-001061	2026-04-11 11:34:04.50237+00
fbcd5c47-b19c-405a-a6b3-fc5e12cc2254	b4d0abe6-580f-4725-9a44-01bf7f86062e	6f43b59c-48b9-4220-a9ad-c0348cad9197	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	140.00	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	محمد احمد	ee31f134-c885-42b4-950b-53284e09a25b	داليا السيد	تسليم الدرج عند إغلاق الوردية	DEP-001065	2026-04-15 13:39:50.882578+00
5c0abd66-938a-471b-ad79-ea29b045b12d	b4d0abe6-580f-4725-9a44-01bf7f86062e	638065e8-f2e9-4435-b0eb-9cbfef60a771	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3040.00	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	محمد احمد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	ندا خالد احمد النجار	تسليم الدرج عند إغلاق الوردية	DEP-001081	2026-04-17 10:57:44.950293+00
b92e151b-dfbf-4566-bffe-a144f6e4f569	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	cee213fd-a788-4f57-afa0-b5416461570b	dc59d83b-1dec-4f60-8cde-4826031c7195	3980.00	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	محمد احمد	f00d039c-caa7-5b00-adba-365ed90c5f10	عمار محمد السيد	تسليم الدرج عند إغلاق الوردية	DEP-001085	2026-04-21 13:24:00.216201+00
\.


--
-- Data for Name: safe_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.safe_transactions (id, safe_id, tx_type, amount, balance_after, note, created_by, created_at) FROM stdin;
f28b9fd0-d53f-405e-a159-c0d3537b6def	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	deposit	530.00	2030.00	تسليم الدرج عند إغلاق الوردية	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-04 09:38:10.606645+00
1e5e2673-0a7e-46b2-a93e-e65fde8e20dd	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	deposit	14724.00	16754.00	تحويل من حماده 	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-04 17:08:11.446055+00
7ef29265-c364-47a9-a5c1-2cf0a2dfa898	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	deposit	4715.00	21469.00	تسليم الدرج عند إغلاق الوردية	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-05 08:48:51.430216+00
0697d277-07dd-4a10-9841-393b13b9b00b	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	deposit	3400.00	24869.00	تسليم الدرج عند إغلاق الوردية	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-09 17:00:21.77481+00
286130cb-ec79-4c0f-8d70-c3493cc4b487	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	deposit	2275.00	27144.00	تسليم الدرج عند إغلاق الوردية	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-11 11:34:04.50237+00
704ee411-c1bd-40d9-9c06-f2579b56b54e	b4d0abe6-580f-4725-9a44-01bf7f86062e	deposit	140.00	140.00	تسليم الدرج عند إغلاق الوردية	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 13:39:50.882578+00
aa10ba47-feb5-4653-8c9f-badcb22741c5	b4d0abe6-580f-4725-9a44-01bf7f86062e	deposit	3040.00	3180.00	تسليم الدرج عند إغلاق الوردية	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 10:57:44.950293+00
f3c61208-d163-4e10-afc0-a361ad30fd9f	5a157f4c-4d31-4e3c-93f2-a66e81b44f45	deposit	3980.00	31124.00	تسليم الدرج عند إغلاق الوردية	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-21 13:24:00.216201+00
\.


--
-- Data for Name: safes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.safes (id, name, location, balance, is_active, created_at, safe_type) FROM stdin;
c49a5a41-1db4-4541-a899-a99b2e40da56	خزنة العبور	معرض العبور	0.00	t	2026-03-31 16:12:22.734709+00	permanent
b4d0abe6-580f-4725-9a44-01bf7f86062e	خزنة معرض المؤمن	معرض المؤمن	3180.00	t	2026-03-31 16:12:22.734709+00	permanent
5a157f4c-4d31-4e3c-93f2-a66e81b44f45	الخزنة الرئيسية	المكتب الرئيسي	31124.00	t	2026-03-31 16:12:22.734709+00	permanent
\.


--
-- Data for Name: sale_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sale_items (id, sale_id, product_id, qty, unit_price, unit_cost, discount) FROM stdin;
3caacd26-851e-4532-a911-aac480f117ad	fa635f6f-c835-40ac-a8e0-d17436acc603	5bb79780-a8aa-4007-b778-5ad0dbb78e6e	1.000	0.00	0.00	0.00
b7040959-b1b8-4d9d-b0ee-ac76307900a7	fa635f6f-c835-40ac-a8e0-d17436acc603	33f55188-0fe1-4788-9809-3591288e60f3	4.000	85.00	58.00	0.00
c468b39f-51f2-4bac-a0a3-9d3512f30684	beea6ccd-679c-413a-8a04-5b820ff8df8f	ca985298-d266-4483-8a13-ff73c90536dc	1.000	90.00	72.00	0.00
36c38a0c-3fda-41ce-b706-206013fcf1eb	beea6ccd-679c-413a-8a04-5b820ff8df8f	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	1.000	75.00	60.00	0.00
ff041412-3dcc-4f37-a7be-9506e36aa5d3	beea6ccd-679c-413a-8a04-5b820ff8df8f	b9b32325-fda4-46a7-b4f4-6da187863e4a	1.000	50.00	40.00	0.00
7e7bdd28-397b-405f-aa9c-87f1883cec63	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	ca985298-d266-4483-8a13-ff73c90536dc	1.000	90.00	72.00	0.00
841d3979-027c-4801-bd5c-401f7099da7e	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	1.000	75.00	60.00	0.00
012a00d4-4a68-4879-8d90-151149bd62b1	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	b9b32325-fda4-46a7-b4f4-6da187863e4a	1.000	50.00	40.00	0.00
a76fdaa7-dd6f-4229-a234-862aef4add82	8ffd2445-36b9-4860-b005-711c418cc856	8cf7eef1-0a73-491c-b6cc-8222f3c45595	1.000	60.00	0.00	0.00
0f49bf4e-d704-4536-b8ce-604b947a9985	de55ead7-27bd-4e29-ad9a-e7aef4b74978	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	70.000	75.00	60.00	0.00
bbee140e-de0b-435b-b564-0c4bf18a7d80	6dda74b4-cb34-4648-8f6e-44fb7a3672b5	ffa8d86a-6352-4d4c-a6f1-76622d09b032	1.000	0.00	0.00	0.00
fe0f7e9f-c3b2-4406-963c-49a0ce94f253	6dda74b4-cb34-4648-8f6e-44fb7a3672b5	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	1.000	90.00	70.00	0.00
830046f8-bf16-43c7-9f4b-8c1af59b59e5	7189b418-dcf5-4925-ae01-eee514901aa4	811c48aa-84b6-4bed-9771-3e6dd162e9a6	5.000	75.00	0.00	0.00
5cf8ceee-c554-46aa-9a87-76257cf9a492	569525ba-651e-4f5c-897d-aa471449308b	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	200.00	15.50	0.00
0c37097c-efb1-48fa-bc02-c6acb1cce9fd	60741e19-f2c2-4e79-abc7-8f6c53055111	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	200.00	15.50	0.00
530b836d-5236-4e3b-84ac-15b7abdc4c24	0dce5e50-b8c5-4941-a0f6-cf5a48fd046a	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	100.00	15.50	0.00
eeef7f82-91e2-44de-b93b-c35a082b3b61	884ae1ed-8143-4046-8fa4-0d857306db9a	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	200.00	15.50	0.00
0d02b82a-7337-4177-b5b3-94f020d02a90	48c0fe08-ef76-49d1-bb60-040e3cf6199d	c8b78e53-a457-4b32-8897-c449f3fe1e4f	2.000	100.00	15.50	0.00
eee6e96d-b3e9-4eb3-b7f9-4f1abdd60dd7	6348d7f3-012a-4b73-bfec-2fdf78efdc93	c8b78e53-a457-4b32-8897-c449f3fe1e4f	5.000	100.00	15.50	0.00
89875f98-9df7-4d66-aeb1-c2d58099b26c	8292cd3e-da80-4675-b002-c4e398917432	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	100.00	15.50	0.00
bd0111f7-465c-4085-b61b-43ad8aaeccd9	15bf83d7-f130-4bce-a71b-e4587d7d9b62	c8b78e53-a457-4b32-8897-c449f3fe1e4f	2.000	200.00	15.50	0.00
66db9218-a6d7-487a-8a70-0de80272ea35	59b9226f-dfaa-462f-ba0c-f821151888d9	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	320.00	15.50	0.00
9db3b581-03e1-4596-a5e2-4e21cb94e35d	1d866b7d-b966-4a0e-a83a-2a8438b15f13	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	320.00	15.50	0.00
4c615292-5fb3-41b9-bb3f-b036e99a3d84	d1a97146-348e-4668-a5df-4ae243bb6b99	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	320.00	15.50	0.00
746fc590-6024-4fa1-bd01-6c2c19fc1a76	7378debc-2ab8-4eda-93cf-baf46683b08d	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	320.00	15.50	0.00
ee8f52ed-e283-4f04-8469-58d3f4166dd6	057b59b5-9e08-4411-bf43-6b75dd16f914	c8b78e53-a457-4b32-8897-c449f3fe1e4f	2.000	200.00	15.50	0.00
7123beb6-b271-4c57-bf74-5de9598abe50	b2ae013b-d8ce-4948-a025-9a7880ff02c6	c8b78e53-a457-4b32-8897-c449f3fe1e4f	5.000	220.00	15.50	0.00
22a6f5df-a618-42b2-bcf1-d4bcd6b228c1	da2ba20c-9068-4e49-840b-1053dccae1cf	c8b78e53-a457-4b32-8897-c449f3fe1e4f	2.000	220.00	15.50	0.00
df1dbc39-d6fa-4063-9b1d-6cedcec62f3d	33f210e9-d206-48b3-b8e3-5f8ca0fcc44f	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	320.00	15.50	0.00
bd5f215b-2e36-455b-9c74-47172f2b8f3f	4cf0467b-29c4-448a-8edf-11efa6c23756	c8b78e53-a457-4b32-8897-c449f3fe1e4f	3.000	320.00	15.50	0.00
ba19364c-3b6f-4309-af75-45f59a11fdd2	f0caea27-2456-4ac1-9e91-535c9488f8d1	c8b78e53-a457-4b32-8897-c449f3fe1e4f	1.000	320.00	15.50	0.00
24ef3a30-c79b-4e47-b624-ef91b097e68b	c226fe67-ae31-4d7e-babe-becb70294339	c8b78e53-a457-4b32-8897-c449f3fe1e4f	2.000	320.00	15.50	0.00
9f9103b3-ebde-4cfe-b807-3729e026a1c1	24d4ae60-0bf1-4056-a83c-a5faa958d10b	b9b32325-fda4-46a7-b4f4-6da187863e4a	1.000	50.00	40.00	0.00
737f448b-21ff-4cbd-be7b-3a2c907e3aa2	75e919da-7d78-4dbe-ac0b-3ca8abb7407f	b9b32325-fda4-46a7-b4f4-6da187863e4a	5.000	50.00	40.00	0.00
0c4cec9b-61cb-48aa-8b54-ca9f5bdd435a	678a4d14-d028-4c24-a72f-0dbaa1bbb258	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	1.000	90.00	70.00	0.00
8b621055-9092-4082-861d-e77f2013a86d	deec8934-2282-4a63-bff3-44e6123420fb	b9b32325-fda4-46a7-b4f4-6da187863e4a	1.000	50.00	40.00	0.00
a7b50dec-cb53-4412-9880-03124de8505e	199a9759-0bc7-467e-9689-5b55ed482852	b9b32325-fda4-46a7-b4f4-6da187863e4a	5.000	50.00	40.00	0.00
9e7c5467-b6d8-4809-b3e8-606eecd80058	f8b9bade-e1b5-4251-b0d3-7591bcfda080	871b0c43-957e-4eb5-b5f0-4609014c1885	1.000	150.00	0.00	0.00
643cf210-1b7d-4c2a-888c-b1e71aac4201	f8b9bade-e1b5-4251-b0d3-7591bcfda080	7e625f21-6107-40ed-a03a-280e64655065	1.000	0.00	0.00	0.00
2878186c-e409-426d-a732-cd87c5b34031	f8b9bade-e1b5-4251-b0d3-7591bcfda080	17ef1e9c-6898-494a-8e97-ecf2af3f72fb	1.000	0.00	0.00	0.00
145997c2-2b8d-413b-8064-e3dc03a081e1	f8b9bade-e1b5-4251-b0d3-7591bcfda080	813e8a9d-af7f-496c-80da-0eab496e15df	1.000	0.00	0.00	0.00
71f339cd-36dd-484e-b636-f2bda4df858b	690521f4-ada7-4ea6-8959-eb911552ce17	ca985298-d266-4483-8a13-ff73c90536dc	1.000	90.00	72.00	0.00
36f3f422-db23-47f5-9df4-0334fa36437e	690521f4-ada7-4ea6-8959-eb911552ce17	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	1.000	75.00	60.00	0.00
4c282fc7-4b68-4bb8-a865-057b20d9f9d4	690521f4-ada7-4ea6-8959-eb911552ce17	b9b32325-fda4-46a7-b4f4-6da187863e4a	2.000	50.00	40.00	0.00
bd3c147e-9ab1-4681-9eb9-6d38a5744549	690521f4-ada7-4ea6-8959-eb911552ce17	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	1.000	90.00	70.00	0.00
9e207ded-9b14-46e5-9152-8fcb80248348	690521f4-ada7-4ea6-8959-eb911552ce17	695705d9-9757-4f2a-be89-fe096ffd87c2	1.000	0.00	0.00	0.00
5bc39619-a3e8-4de6-9a27-92ea5e7faad2	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	da68d7f2-f8d7-44bb-85a3-d91ab5d02ffa	3.000	0.00	0.00	0.00
4e2b7c37-03a4-4725-a8e3-cf45e66e6239	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	af31725d-fa0f-42df-88d4-9041e36ad994	1.000	0.00	0.00	0.00
f5e05920-60da-415f-a91a-77fa6ff35080	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	b9b32325-fda4-46a7-b4f4-6da187863e4a	1.000	50.00	40.00	0.00
192c8100-3eb1-4e39-abe8-42fe887158b5	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	1.000	75.00	60.00	0.00
d8d02c0e-ce36-4cd6-b2c5-8185f8046ea3	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	ca985298-d266-4483-8a13-ff73c90536dc	1.000	90.00	72.00	0.00
ef43cd5d-268b-4f6e-a246-6f1bb4b5ec4a	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	2ac3dc85-e7cf-4ff1-8aff-01e6d8fd54a1	1.000	0.00	0.00	0.00
1ee49885-7cc7-4b8b-b139-0002aa0236d5	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	ffa8d86a-6352-4d4c-a6f1-76622d09b032	1.000	0.00	0.00	0.00
651460ed-d6d0-45db-a851-6c240be0afc3	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	1.000	90.00	70.00	0.00
aac330c1-2466-4771-ba7f-2857411a9dbc	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	ab4ba887-5c44-4a22-b567-670c0001b603	1.000	0.00	0.00	0.00
055208bf-2b95-4602-a2d5-c79568b7ae94	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	c19f42ec-ad6d-4161-9f38-a9c4cecb643b	1.000	0.00	0.00	0.00
ee6c6b6d-fe1b-406d-985c-951dfbbd85ae	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	6d2e9857-cc51-4c79-aa4d-d7b9e4208678	1.000	0.00	0.00	0.00
fe715a5b-3ea3-472d-a628-ac29ca83528e	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	67ba969e-da10-4bbd-9900-606bf254045b	1.000	0.00	0.00	0.00
17eb0dd8-32b1-4a85-9267-6af2188f2e77	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	b7d3a006-f7a1-40d6-b3d8-20192e7f93bf	1.000	0.00	0.00	0.00
8a0e181b-55f4-42ba-a1ec-0c9b391df3f5	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	9f86c75d-e220-45e8-95a2-405be7b53488	1.000	0.00	0.00	0.00
097da23b-84cc-4439-a703-a74f82124b21	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	695705d9-9757-4f2a-be89-fe096ffd87c2	1.000	0.00	0.00	0.00
3111daf4-f299-4371-b5ef-f4a867aeb64c	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	d14ac884-8431-46ba-adcb-5190dbaf9da0	1.000	35.00	0.00	0.00
b2c45d85-8b23-41b7-8ffc-cda457deb830	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	b41ae764-b97b-4662-b865-b572790ec127	1.000	0.00	0.00	0.00
db641784-111f-40c4-a6a9-bce428e46cbe	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	55cc2075-bfe4-4613-91de-05535390b28a	1.000	35.00	0.00	0.00
d226bb55-b47a-45bb-a19f-a89eab06a7c9	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	85114c68-11e1-442b-a79d-0279c2bb798b	1.000	220.00	0.00	0.00
381e56f1-b796-464c-b879-a89a996c3604	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	056ef88b-f53d-4806-9e24-f9f931f54dcf	1.000	280.00	0.00	0.00
9366f284-65cc-42fe-ad66-a0e1f772822a	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	982d6fa2-8c29-4580-863a-215600003c9b	1.000	85.00	0.00	0.00
02a56e39-42a1-410a-bfcb-bc981e92204a	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	53a3e08e-728d-4291-b2f7-9cc69a69cbac	1.000	120.00	0.00	0.00
8d0ddbdc-658c-47a4-8d38-b2f6294d1583	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	92a238d8-f2da-4c28-9127-fbc8cece0c0b	1.000	75.00	0.00	0.00
5f48ca86-208e-4dc5-9d0d-5d8a36f68605	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	0eb4a2fa-6d82-4005-bbb7-c958edcf281a	1.000	380.00	0.00	0.00
3160fa25-bb71-4bcc-b1e2-535f476de31f	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	bca0c8ae-6b62-4ad0-a150-47fbd9955eab	1.000	180.00	0.00	0.00
3ac672db-fcf3-44b6-a4c4-c7f02f2ebc60	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	4008a90d-eda0-4bc9-b7d9-0401c419b3e1	1.000	150.00	0.00	0.00
2cdf3a08-b43e-4598-837e-defed21593d4	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	bd473534-32ba-4522-912d-ab3c9f59ac24	1.000	190.00	0.00	0.00
4b9895e3-8f7a-468b-9c3a-f3ca2675a4ad	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	27b32f29-2ac8-445e-aaf4-531e4cabd48c	1.000	180.00	0.00	0.00
d68bdb11-b818-4f2d-a70b-f226eb6287d7	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	b09598b6-4537-4e39-b28b-d50cb6d8d19a	1.000	0.00	0.00	0.00
b4094b05-2c5e-4ffa-81cc-b122dd9c6353	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	fd927c9a-2843-4740-b97e-c92f51424765	1.000	120.00	0.00	0.00
09550a89-1742-44e5-b3ba-80157e276be2	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	4b596a39-71ad-4be0-adcb-82637141438e	1.000	75.00	0.00	0.00
ce098f06-9ed3-4ca9-bed9-561429bdb260	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	811c48aa-84b6-4bed-9771-3e6dd162e9a6	1.000	75.00	0.00	0.00
675e81a5-cefa-486a-b5dc-8fac3ef27d1c	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	bf75d681-d9d1-4af8-871f-2ed687b63fd1	1.000	85.00	0.00	0.00
cd4c4ad9-5c48-4024-a93b-67522dc4767a	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	4c7f2b6e-8a67-489f-ad91-257ba78a7f51	1.000	65.00	0.00	0.00
e6265c8f-86d2-465f-a984-845e13f97879	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	ec991740-f53e-42ea-9e48-6af7a7696248	1.000	0.00	0.00	0.00
b4aebfa8-9844-4a8e-a74c-d4ce437b7686	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	5b18456a-9aee-431f-8344-81bda7d32061	1.000	130.00	0.00	0.00
b1350209-37e3-42b5-8a5e-649b57bcc036	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	13ab7f8d-4d5c-495d-9665-b12b51ba8097	1.000	120.00	0.00	0.00
394dad90-ca50-40e1-a9f8-9844fc2aa503	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	7652a593-90d8-4ba8-9bf0-d1f452915da4	1.000	120.00	0.00	0.00
a6211570-d744-4326-85bc-dd8054ad6d66	a5a7c9f2-47c8-4490-9e91-dbced23a07ae	9d19a1d3-c280-4944-879b-0db02b1ebfc9	1.000	20.00	0.00	0.00
ed140124-0f79-45a6-8f1a-ab600191065f	fb0d3cd9-8c58-4c27-9c88-ff369e9c759d	36a71af5-edd7-4e4c-9b77-fb2b37c53cf8	1.000	35.00	0.00	0.00
badb23a1-07e6-42a2-a838-d470cfda5a3a	79c8f84d-d6c2-479e-aba9-59e3a2399e83	b656dab6-3e5f-43f4-9405-9c2dd680411f	1.000	120.00	0.00	0.00
1c76d4dd-95b4-418f-8157-fce54de8c72d	b7093033-af31-4495-94af-1afbd0f7d6a2	2a2a52bb-b8d8-4af4-93d6-41ed8267a589	1.000	40.00	0.00	0.00
f7dfa5e9-70a1-4b94-b4c5-683b341bf9b5	8c57aaa4-0af7-4158-b602-dd8154a31ac5	3475e3b2-b002-47e6-88ee-85a33cd7f837	1.000	35.00	0.00	0.00
a89c8ae6-608a-44d5-8168-2def43bbe63a	722ae65a-8e33-4c67-a60e-ce7f3641e55a	4afc0d54-afc2-40e3-89c0-bb8d316b043f	2.000	10.00	0.00	0.00
171cf14e-e0af-48dd-9a5f-3807245e9259	722ae65a-8e33-4c67-a60e-ce7f3641e55a	befa0c0a-622a-46f8-913b-ca6e7a4ed98e	2.000	10.00	0.00	0.00
579baeba-24e1-4e9c-b39c-0b043c6ebcc3	6658a571-8f6f-4346-8a00-e273453fd0e8	9599e8f6-0e41-4ba6-af39-945ab7b97b91	1.000	25.00	0.00	0.00
770f0855-c10e-420d-92dd-0db629afc44d	4324a1c7-c9a5-428c-9caa-80721faddd2a	4aff0452-0f86-4435-a377-3fc75234ba73	1.000	150.00	0.00	0.00
9ecd003f-85f9-49c2-8a59-1479b316c46e	0c357ce9-3d1a-4b61-9284-54a9c0135182	2a2a52bb-b8d8-4af4-93d6-41ed8267a589	1.000	40.00	0.00	0.00
649800fe-d4d0-42ff-bdf1-d5bc7c3efa46	43d22f28-e464-4738-997e-14fda425b9d4	9599e8f6-0e41-4ba6-af39-945ab7b97b91	1.000	25.00	0.00	0.00
8bd8ee4b-81be-4a83-a0fc-c8dd2d475d6d	ada7f1f3-5d72-49cd-87c1-ec845fbf8c06	042c84a3-1f76-4d4d-ac34-bfcd30ae8355	1.000	140.00	0.00	20.00
3f7d779b-cba0-4e57-b399-ac9d08a20630	ccafcf2e-b171-4468-99f3-7f14e1484684	644330ab-aa5e-424d-a11d-2a66436161da	1.000	190.00	0.00	0.00
efbcda2b-2483-4fa1-825d-3f5e5b398abd	68a5d40a-dc4a-48b9-8153-bf4b82af7bb6	959c3547-fa77-4cc0-a105-c9f8e9252092	1.000	150.00	0.00	0.00
66d00772-433d-4f10-8e92-49d9f36544f6	55b0b4c8-2057-42d0-a306-eac87d4bb0bc	811c48aa-84b6-4bed-9771-3e6dd162e9a6	10.000	75.00	0.00	0.00
d4c7b08e-726e-4204-9da6-4e68c95ab61e	164ada49-92bf-47e1-a2a3-c62f5d09da58	eef8c1af-7cf9-4222-8baa-43bf0094c923	1.000	80.00	0.00	0.00
cb8e8bc8-130c-45b8-89b5-bf9dfe67dc10	164ada49-92bf-47e1-a2a3-c62f5d09da58	cd65e985-404b-46db-819e-af8c5163937a	1.000	40.00	0.00	0.00
7b63282f-305b-451a-a952-1a3a79569d54	164ada49-92bf-47e1-a2a3-c62f5d09da58	0f662576-a144-4692-ad0b-937314746bdc	1.000	205.00	0.00	0.00
b3b85141-3c96-43fa-8369-9ca2c9e92fe2	164ada49-92bf-47e1-a2a3-c62f5d09da58	8edab49c-8f12-47b1-963d-8adea2c8ce02	1.000	130.00	0.00	0.00
7d541c19-85ae-4633-b8d0-8ae4bce365b3	164ada49-92bf-47e1-a2a3-c62f5d09da58	a4997b77-66bf-4b4f-ae74-74762dd0712c	1.000	5.00	0.00	0.00
d6217670-a1d0-435e-a5a2-43c327da4650	d007be7b-6a2f-47a2-87fd-41493daf268b	056ef88b-f53d-4806-9e24-f9f931f54dcf	1.000	280.00	0.00	0.00
758cf1cd-3f30-460e-be2c-af81a1939270	d007be7b-6a2f-47a2-87fd-41493daf268b	4008a90d-eda0-4bc9-b7d9-0401c419b3e1	1.000	150.00	0.00	0.00
f59c78df-dd10-44a8-ab4e-333a4dd4f10f	d007be7b-6a2f-47a2-87fd-41493daf268b	bca0c8ae-6b62-4ad0-a150-47fbd9955eab	1.000	180.00	0.00	0.00
44c96914-bd5c-46d1-8e50-3f55b75ab3d9	d007be7b-6a2f-47a2-87fd-41493daf268b	4b596a39-71ad-4be0-adcb-82637141438e	1.000	75.00	0.00	0.00
d83be8cb-d935-48b6-ab1f-f58d1c77fca5	c7710e3c-facb-4ed0-9ffe-9f80a23823df	d2879635-0b3c-4c36-8199-9f2b94a535ab	1.000	50.00	0.00	0.00
d29c84b7-80db-4c69-ac85-a361727f7b92	c7710e3c-facb-4ed0-9ffe-9f80a23823df	bffd258f-b84e-4beb-8d18-ae23f611015d	1.000	50.00	0.00	0.00
db688a8e-8839-4380-be82-019884d1446a	c7710e3c-facb-4ed0-9ffe-9f80a23823df	9c1e6d13-9d15-46d1-9779-623dbc89684f	1.000	40.00	0.00	0.00
5442ff9e-f8cd-4edf-8f59-9e9002e1227e	01bfe807-abfb-4b40-b2ba-91cdf635e8b1	55cc2075-bfe4-4613-91de-05535390b28a	1.000	35.00	0.00	0.00
1717308b-f2ff-4ad9-9075-0fd09ebc6fc1	9a7319e2-31a4-4753-abc2-bb92bbe01f07	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	1.000	150.00	0.00	0.00
304f13e0-192d-4a53-a181-9805495ff127	1ff4ccc4-5613-4a7a-ba95-5ac080aeef04	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	1.000	150.00	0.00	0.00
e80aa474-7462-47ca-9792-1b0a67a3fdd1	ca4ea6f5-82ca-4f96-bed8-a5b2a2a1b3c1	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	1.000	150.00	0.00	0.00
34c9d54c-a4f8-4139-9ef5-af3c38359c91	a5d2f6e4-34ea-46ae-a671-2a779e4d8cc5	78539233-0e35-4584-8a63-835c6f128067	1.000	35.00	0.00	0.00
44e91442-a677-4d3a-b568-20d45435f771	191377d0-0506-4cd5-bf1d-fc3fd65bac11	b9b32325-fda4-46a7-b4f4-6da187863e4a	1.000	180.00	40.00	0.00
8b1e3907-f08d-4404-8554-70e051d9543a	bb784b10-07c3-4a93-b36e-eb72a3c50a82	49f4d737-1d66-4bbf-8011-44949b013133	1.000	230.00	0.00	0.00
a4914cd1-c0e0-4d63-bce7-ae6bfc9af71d	8f3d7790-b687-4008-a659-9876db7ff7f7	e660c870-680d-4c0d-ac35-ad6c4e0740a6	4.000	37.50	0.00	0.00
8241448b-bb2b-4b92-8a70-e9794086f366	68de17de-7680-4292-9603-8cacab936e2d	189b8e6e-6161-40ba-ab29-98d73b32232e	1.000	100.00	0.00	0.00
c38152ba-044c-4e1e-8c10-1cf797740d7c	9962c7e8-8e13-4754-bb24-3dd9c434b4b9	958976e5-78b1-48dd-b90c-639ecac8608e	1.000	20.00	0.00	0.00
81c65096-9dc0-41c0-b5d5-defdc37fd6bb	3bc55c39-04c5-4c70-a956-54e262642e52	7e302e33-3bb9-436d-b2a6-f64f71fa113e	1.000	45.00	0.00	0.00
d594c897-f08a-46a6-a6d4-1872e30e2ec8	8c5491cc-a19c-40f6-ae95-53ce44f08a0a	dc312bb2-984d-4c5b-8f9d-f5a0a165eb78	1.000	85.00	0.00	0.00
f1d99bbe-7e03-4c59-abe4-347d14327ea9	c9bd780c-9eb4-4ee1-a7ac-8f21fa7293b4	357dad92-ae44-40df-98d6-135586d4f7c9	1.000	35.00	0.00	0.00
ae14083b-d36c-4648-8f79-d1d4a373a786	3de73516-254f-47b6-89d4-3e4b9a289e6b	a4997b77-66bf-4b4f-ae74-74762dd0712c	1.000	5.00	0.00	0.00
a2d06b45-737d-48d6-849d-96b8a6545841	12c64805-0c9e-41b1-8a35-e0faede4dfee	858d8c6c-94bc-4b7b-9bf6-f5aaf4cc7aca	1.000	35.00	0.00	0.00
84f7f1f1-ed0b-4247-86b6-d9251050e112	149faca0-30a9-465e-9a18-10cd67c71a23	6c53ac78-8c67-4b7d-9417-fe21bb9cad2c	1.000	50.00	0.00	0.00
c6a49cfa-fbac-400e-952e-83e017ebd14a	641a91af-fb3a-4ba0-90b1-3d78f6db15ee	9ad31176-b502-43b7-b47a-57cdaa1e623f	1.000	120.00	0.00	0.00
62284395-6466-44a0-913c-b4f232e6e6b6	9cfee519-9104-4f79-8523-9849182a4951	fbc41295-0338-4e49-b61e-79e99e9f5667	1.000	30.00	0.00	0.00
0e35ee72-01f4-4359-a0cc-1dbec4e064e1	a19b0900-0496-40c2-8d39-e4efc6a33a63	5e9e99fb-95ac-4298-a437-570417737d44	1.000	2000.00	0.00	0.00
60ac5a9e-b4db-46af-8000-eaeffd892dc0	bf0089c4-e0b3-4ec0-9573-1d60d3ca8c56	fd927c9a-2843-4740-b97e-c92f51424765	15.000	110.00	0.00	0.00
e59bd362-d700-4501-9060-18bc32cf353c	3f6c0df5-9b7e-4f8c-a56c-a70e50ab37a8	c80f86d8-cb80-465f-ad00-b3583f1c4c40	1.000	100.00	0.00	0.00
ee06d8c3-8b24-43b6-b7d1-1aef04880f20	c95cc1a0-f6ed-4990-9837-99f0ac15effc	2f3e5183-d945-419c-aba7-63cde2d18b66	1.000	75.00	0.00	0.00
\.


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales (id, invoice_number, customer_id, warehouse_id, cashier_id, shift_id, sale_mode, status, discount_amount, notes, created_at, is_credit, created_by, payment_method, wallet_id) FROM stdin;
c226fe67-ae31-4d7e-babe-becb70294339	INV-0325182125	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 18:21:25.445077+00	f	\N	cash	\N
f0caea27-2456-4ac1-9e91-535c9488f8d1	INV-0325182137	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 18:21:37.532105+00	f	\N	cash	\N
4cf0467b-29c4-448a-8edf-11efa6c23756	INV-0325182313	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 18:23:13.379562+00	f	\N	cash	\N
33f210e9-d206-48b3-b8e3-5f8ca0fcc44f	INV-0325182324	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 18:23:24.821394+00	f	\N	cash	\N
da2ba20c-9068-4e49-840b-1053dccae1cf	INV-0325182702	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	returned	0.00	\N	2026-03-25 18:27:02.803282+00	f	\N	cash	\N
fa635f6f-c835-40ac-a8e0-d17436acc603	INV-0325191812	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	8fb616cd-cbf6-4587-9eed-36cba02101b4	wholesale	confirmed	0.00	\N	2026-03-25 19:18:12.618104+00	f	\N	cash	\N
b2ae013b-d8ce-4948-a025-9a7880ff02c6	INV-0325195831	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	confirmed	0.00	\N	2026-03-25 19:58:30.752572+00	f	\N	cash	\N
057b59b5-9e08-4411-bf43-6b75dd16f914	QUO-0325205705	\N	cc063dcf-cef9-4763-a1dc-5a918dbeda93	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	quotation	0.00	\N	2026-03-25 20:57:05.408294+00	f	\N	cash	\N
beea6ccd-679c-413a-8a04-5b820ff8df8f	INV-0325220206	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	55cbdec7-b42c-4183-b251-53aaa8f07c1b	retail	confirmed	0.00	\N	2026-03-25 22:02:06.343297+00	f	\N	cash	\N
7378debc-2ab8-4eda-93cf-baf46683b08d	INV-0325220542	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 22:05:42.362436+00	f	\N	cash	\N
d1a97146-348e-4668-a5df-4ae243bb6b99	INV-0325220628	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 22:06:28.651864+00	f	\N	cash	\N
1d866b7d-b966-4a0e-a83a-2a8438b15f13	INV-0325220649	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 22:06:49.350579+00	f	\N	cash	\N
59b9226f-dfaa-462f-ba0c-f821151888d9	INV-0325220821	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 22:08:21.301213+00	f	\N	cash	\N
a51ab5f1-a2ff-4913-8630-f872e1a6ca79	INV-0325220854	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	55cbdec7-b42c-4183-b251-53aaa8f07c1b	retail	returned	0.00	\N	2026-03-25 22:08:53.994403+00	f	\N	cash	\N
8ffd2445-36b9-4860-b005-711c418cc856	INV-0325221111	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	55cbdec7-b42c-4183-b251-53aaa8f07c1b	retail	returned	0.00	\N	2026-03-25 22:11:11.184759+00	f	\N	cash	\N
de55ead7-27bd-4e29-ad9a-e7aef4b74978	INV-0326053034	ea70b37f-e40d-4d13-a014-52ed6cc34d9e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	1dc0d5f0-327a-4708-aff9-26c483ab313b	retail	confirmed	0.00	\N	2026-03-26 05:30:34.229674+00	f	\N	cash	\N
15bf83d7-f130-4bce-a71b-e4587d7d9b62	INV-0326095143	9338ff3f-c554-4648-9965-0b49d68aa7db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	confirmed	0.00	\N	2026-03-26 09:51:42.80797+00	t	\N	cash	\N
8292cd3e-da80-4675-b002-c4e398917432	INV-0326095144	9338ff3f-c554-4648-9965-0b49d68aa7db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-26 09:51:44.029524+00	f	\N	cash	\N
6dda74b4-cb34-4648-8f6e-44fb7a3672b5	INV-0326104103	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	1dc0d5f0-327a-4708-aff9-26c483ab313b	wholesale	confirmed	0.00	\N	2026-03-26 10:41:03.717603+00	t	\N	cash	\N
6348d7f3-012a-4b73-bfec-2fdf78efdc93	INV-0326104521	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-26 10:45:20.99253+00	f	\N	cash	\N
48c0fe08-ef76-49d1-bb60-040e3cf6199d	RET-0326104521	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	returned	0.00	مرتجع جزئي من INV-0326104521	2026-03-26 10:45:21.226507+00	f	\N	cash	\N
884ae1ed-8143-4046-8fa4-0d857306db9a	RET-0326125337	9338ff3f-c554-4648-9965-0b49d68aa7db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	returned	0.00	مرتجع جزئي من INV-0326095143	2026-03-26 12:53:37.629082+00	f	\N	cash	\N
0dce5e50-b8c5-4941-a0f6-cf5a48fd046a	INV-0327151000	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	3dcf287f-653a-4299-b80d-c840e1503e2b	retail	confirmed	0.00	\N	2026-03-27 15:10:00.472241+00	f	\N	cash	\N
60741e19-f2c2-4e79-abc7-8f6c53055111	QUO-0327151000	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	quotation	0.00	\N	2026-03-27 15:10:00.739301+00	f	\N	cash	\N
569525ba-651e-4f5c-897d-aa471449308b	INV-0327151032	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	confirmed	0.00	\N	2026-03-27 15:10:32.646508+00	f	\N	cash	\N
7189b418-dcf5-4925-ae01-eee514901aa4	INV-0328120249	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	3dcf287f-653a-4299-b80d-c840e1503e2b	retail	confirmed	75.00	\N	2026-03-28 12:02:49.494187+00	f	\N	cash	\N
24d4ae60-0bf1-4056-a83c-a5faa958d10b	INV-0329165628	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	4a7dd547-9642-4562-a0a8-1fa55de24162	retail	confirmed	0.00	\N	2026-03-29 16:56:28.947849+00	t	f00d039c-caa7-5b00-adba-365ed90c5f10	cash	\N
75e919da-7d78-4dbe-ac0b-3ca8abb7407f	INV-001025	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	4a7dd547-9642-4562-a0a8-1fa55de24162	retail	confirmed	0.00	\N	2026-03-29 17:18:47.390297+00	f	f00d039c-caa7-5b00-adba-365ed90c5f10	cash	\N
678a4d14-d028-4c24-a72f-0dbaa1bbb258	INV-001026	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	4a7dd547-9642-4562-a0a8-1fa55de24162	retail	confirmed	0.00	\N	2026-03-29 17:18:55.672741+00	f	f00d039c-caa7-5b00-adba-365ed90c5f10	cash	\N
deec8934-2282-4a63-bff3-44e6123420fb	INV-001027	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	a4a070b3-e6f5-499f-9940-dcd41fcc2188	retail	confirmed	0.00	\N	2026-03-30 13:33:52.40389+00	f	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	cash	\N
199a9759-0bc7-467e-9689-5b55ed482852	INV-001028	973fbcf1-c2b3-450e-8584-a63cf0885350	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	a4a070b3-e6f5-499f-9940-dcd41fcc2188	retail	confirmed	0.00	\N	2026-03-31 11:42:55.471697+00	t	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	cash	\N
f8b9bade-e1b5-4251-b0d3-7591bcfda080	INV-001040	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	a4a070b3-e6f5-499f-9940-dcd41fcc2188	retail	confirmed	0.00	\N	2026-04-03 15:49:11.728512+00	f	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	cash	\N
690521f4-ada7-4ea6-8959-eb911552ce17	INV-001041	\N	536e6eba-c111-4d60-b812-ead42ab23883	f00d039c-caa7-5b00-adba-365ed90c5f10	900146ce-a935-43ea-a6d4-647276e80612	retail	confirmed	0.00	\N	2026-04-03 18:44:06.036492+00	f	f00d039c-caa7-5b00-adba-365ed90c5f10	cash	\N
a5a7c9f2-47c8-4490-9e91-dbced23a07ae	INV-001042	\N	536e6eba-c111-4d60-b812-ead42ab23883	f00d039c-caa7-5b00-adba-365ed90c5f10	900146ce-a935-43ea-a6d4-647276e80612	retail	confirmed	0.00	\N	2026-04-03 18:46:32.357587+00	f	f00d039c-caa7-5b00-adba-365ed90c5f10	cash	\N
fb0d3cd9-8c58-4c27-9c88-ff369e9c759d	INV-001044	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 11:53:01.188877+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
79c8f84d-d6c2-479e-aba9-59e3a2399e83	INV-001045	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 11:54:22.580318+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
b7093033-af31-4495-94af-1afbd0f7d6a2	INV-001046	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 11:56:25.460384+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
8c57aaa4-0af7-4158-b602-dd8154a31ac5	INV-001047	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 11:56:48.185288+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
722ae65a-8e33-4c67-a60e-ce7f3641e55a	INV-001048	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 12:01:01.87457+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
6658a571-8f6f-4346-8a00-e273453fd0e8	INV-001049	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 12:01:17.361055+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
4324a1c7-c9a5-428c-9caa-80721faddd2a	INV-001050	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 12:10:43.167716+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
0c357ce9-3d1a-4b61-9284-54a9c0135182	INV-001051	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 12:45:43.620612+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
43d22f28-e464-4738-997e-14fda425b9d4	INV-001052	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 12:59:03.526909+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
ada7f1f3-5d72-49cd-87c1-ec845fbf8c06	INV-001053	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 14:35:02.868867+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
ccafcf2e-b171-4468-99f3-7f14e1484684	INV-001054	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	retail	confirmed	0.00	\N	2026-04-04 16:02:35.379898+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
68a5d40a-dc4a-48b9-8153-bf4b82af7bb6	INV-001055	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	e5355dec-89d0-445f-9fc7-85065801c28c	retail	confirmed	0.00	\N	2026-04-04 17:12:59.620644+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
55b0b4c8-2057-42d0-a306-eac87d4bb0bc	INV-001058	d5b26988-5de6-44bb-8761-7a0963be4ad3	536e6eba-c111-4d60-b812-ead42ab23883	85ba0e1f-040c-44b2-90a3-0afcaa30178b	81d0c548-0de6-4773-9630-f001207f5598	wholesale	confirmed	0.00	\N	2026-04-09 17:04:52.567672+00	t	85ba0e1f-040c-44b2-90a3-0afcaa30178b	credit	\N
164ada49-92bf-47e1-a2a3-c62f5d09da58	INV-001059	\N	536e6eba-c111-4d60-b812-ead42ab23883	85ba0e1f-040c-44b2-90a3-0afcaa30178b	81d0c548-0de6-4773-9630-f001207f5598	retail	confirmed	0.00	\N	2026-04-09 17:29:17.580966+00	f	85ba0e1f-040c-44b2-90a3-0afcaa30178b	cash	\N
d007be7b-6a2f-47a2-87fd-41493daf268b	INV-001060	\N	536e6eba-c111-4d60-b812-ead42ab23883	85ba0e1f-040c-44b2-90a3-0afcaa30178b	1a61e024-d1fe-4627-89c1-d587bd2bfab0	retail	confirmed	0.00	\N	2026-04-09 17:39:33.67449+00	f	85ba0e1f-040c-44b2-90a3-0afcaa30178b	wallet	8168ea3e-3935-477f-a412-9184f9188885
c7710e3c-facb-4ed0-9ffe-9f80a23823df	INV-001062	\N	536e6eba-c111-4d60-b812-ead42ab23883	658196d5-857d-493c-94e4-e604b01764ab	7fc6e86e-a0b6-462c-814e-1f5c04397f36	retail	confirmed	0.00	\N	2026-04-11 11:36:03.539892+00	f	658196d5-857d-493c-94e4-e604b01764ab	cash	\N
01bfe807-abfb-4b40-b2ba-91cdf635e8b1	INV-001063	\N	dc59d83b-1dec-4f60-8cde-4826031c7195	85ba0e1f-040c-44b2-90a3-0afcaa30178b	7827d0d8-ad02-4b7b-8b54-cb9f7c3ab997	retail	confirmed	0.00	\N	2026-04-11 16:57:50.030337+00	f	85ba0e1f-040c-44b2-90a3-0afcaa30178b	cash	\N
9a7319e2-31a4-4753-abc2-bb92bbe01f07	INV-001064	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	6f43b59c-48b9-4220-a9ad-c0348cad9197	retail	confirmed	0.00	\N	2026-04-15 13:33:13.852725+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
1ff4ccc4-5613-4a7a-ba95-5ac080aeef04	INV-001066	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	f7bebd31-df98-4b71-8a19-e4daead03400	retail	returned	0.00	\N	2026-04-15 13:53:44.52708+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
ca4ea6f5-82ca-4f96-bed8-a5b2a2a1b3c1	INV-001067	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	retail	confirmed	0.00	\N	2026-04-15 14:13:25.866305+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
a5d2f6e4-34ea-46ae-a671-2a779e4d8cc5	INV-001068	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	retail	confirmed	0.00	\N	2026-04-15 14:15:34.328059+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
8f3d7790-b687-4008-a659-9876db7ff7f7	INV-001071	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	0dbb0981-7969-4775-8d06-123a461e83e0	retail	confirmed	0.00	\N	2026-04-15 19:24:13.33222+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
191377d0-0506-4cd5-bf1d-fc3fd65bac11	INV-001069	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	retail	confirmed	0.00	\N	2026-04-15 15:22:30.433226+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
bb784b10-07c3-4a93-b36e-eb72a3c50a82	INV-001070	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	retail	confirmed	0.00	\N	2026-04-15 16:49:50.980428+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
68de17de-7680-4292-9603-8cacab936e2d	INV-001072	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee31f134-c885-42b4-950b-53284e09a25b	0dbb0981-7969-4775-8d06-123a461e83e0	retail	confirmed	0.00	\N	2026-04-15 19:33:10.850009+00	f	ee31f134-c885-42b4-950b-53284e09a25b	cash	\N
9962c7e8-8e13-4754-bb24-3dd9c434b4b9	INV-001073	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	638065e8-f2e9-4435-b0eb-9cbfef60a771	retail	confirmed	0.00	\N	2026-04-16 17:48:17.701328+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
3bc55c39-04c5-4c70-a956-54e262642e52	INV-001074	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	638065e8-f2e9-4435-b0eb-9cbfef60a771	retail	confirmed	0.00	\N	2026-04-16 17:53:59.149494+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
8c5491cc-a19c-40f6-ae95-53ce44f08a0a	INV-001075	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	638065e8-f2e9-4435-b0eb-9cbfef60a771	retail	confirmed	0.00	\N	2026-04-16 18:09:21.705211+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
c9bd780c-9eb4-4ee1-a7ac-8f21fa7293b4	INV-001076	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	638065e8-f2e9-4435-b0eb-9cbfef60a771	retail	confirmed	0.00	\N	2026-04-16 18:12:40.942116+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
3de73516-254f-47b6-89d4-3e4b9a289e6b	INV-001077	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	638065e8-f2e9-4435-b0eb-9cbfef60a771	retail	confirmed	0.00	\N	2026-04-16 18:13:09.28253+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
12c64805-0c9e-41b1-8a35-e0faede4dfee	INV-001078	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	638065e8-f2e9-4435-b0eb-9cbfef60a771	retail	confirmed	0.00	\N	2026-04-16 18:16:59.030531+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
149faca0-30a9-465e-9a18-10cd67c71a23	INV-001079	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	638065e8-f2e9-4435-b0eb-9cbfef60a771	retail	confirmed	0.00	\N	2026-04-16 18:19:38.130327+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
641a91af-fb3a-4ba0-90b1-3d78f6db15ee	INV-001080	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	638065e8-f2e9-4435-b0eb-9cbfef60a771	retail	confirmed	0.00	\N	2026-04-16 18:46:52.341965+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
9cfee519-9104-4f79-8523-9849182a4951	INV-001082	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	114bc5a4-76e6-4f4b-a8f8-33244c6a3469	retail	confirmed	0.00	\N	2026-04-17 11:00:38.94932+00	f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	cash	\N
a19b0900-0496-40c2-8d39-e4efc6a33a63	INV-001083	\N	dc59d83b-1dec-4f60-8cde-4826031c7195	85ba0e1f-040c-44b2-90a3-0afcaa30178b	7827d0d8-ad02-4b7b-8b54-cb9f7c3ab997	retail	confirmed	0.00	\N	2026-04-18 20:01:20.449249+00	f	85ba0e1f-040c-44b2-90a3-0afcaa30178b	cash	\N
bf0089c4-e0b3-4ec0-9573-1d60d3ca8c56	INV-001084	973fbcf1-c2b3-450e-8584-a63cf0885350	dc59d83b-1dec-4f60-8cde-4826031c7195	658196d5-857d-493c-94e4-e604b01764ab	9caef843-cb34-4aab-b867-e0b32e96d2ab	retail	confirmed	0.00	\N	2026-04-20 16:43:05.129604+00	t	658196d5-857d-493c-94e4-e604b01764ab	credit	\N
3f6c0df5-9b7e-4f8c-a56c-a70e50ab37a8	INV-001086	\N	dc59d83b-1dec-4f60-8cde-4826031c7195	85ba0e1f-040c-44b2-90a3-0afcaa30178b	1cfd81c6-cd5d-4c58-ac06-b77e9cf9c167	retail	confirmed	0.00	\N	2026-04-21 19:52:09.950176+00	f	85ba0e1f-040c-44b2-90a3-0afcaa30178b	cash	\N
c95cc1a0-f6ed-4990-9837-99f0ac15effc	INV-001087	\N	dc59d83b-1dec-4f60-8cde-4826031c7195	85ba0e1f-040c-44b2-90a3-0afcaa30178b	1cfd81c6-cd5d-4c58-ac06-b77e9cf9c167	retail	confirmed	0.00	\N	2026-04-22 13:32:01.704837+00	f	85ba0e1f-040c-44b2-90a3-0afcaa30178b	cash	\N
\.


--
-- Data for Name: shifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shifts (id, cashier_id, status, initial_amount, closing_balance, next_day_drawer, closed_by, notes, started_at, closed_at, warehouse_id, supervisor_id, deposit_received_by, deposit_amount) FROM stdin;
c881e0f8-b5f2-4c39-bf01-5b0cad9afcf5	\N	closed	130.00	137.00	0.00	\N	\N	2026-02-06 18:11:08.12637+00	2026-02-06 18:12:33.316453+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
609eedda-701a-4531-abb5-91467eacc595	\N	closed	137.00	4239.00	137.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-02-06 18:26:19.36459+00	2026-03-14 16:11:10.492504+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
8fb616cd-cbf6-4587-9eed-36cba02101b4	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	137.00	500.00	100.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-14 16:11:41.041904+00	2026-03-25 19:32:56.458226+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
ba06a6e8-ef0b-405f-99ca-3870cef7ab96	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	100.00	80.00	30.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-25 21:34:40.047034+00	2026-03-25 19:34:40.316056+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
55cbdec7-b42c-4183-b251-53aaa8f07c1b	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	150.00	335.00	150.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-25 21:52:10.561385+00	2026-03-25 20:10:40.468094+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
d139d108-aea2-4725-b5f1-6c8f6f6975f1	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	500.00	500.00	500.00	f00d039c-caa7-5b00-adba-365ed90c5f10	تسليم عهدة إلى 6a11d77b-24cc-577e-9ec3-4b0088eb7585. 	2026-03-25 22:46:48.744742+00	2026-03-25 20:47:35.379215+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
fab82fac-6477-4693-991d-7de7d933cc93	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	500.00	500.00	400.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-25 22:54:50.157345+00	2026-03-25 21:08:57.036538+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
9e39f741-2b38-4eb2-aa6d-f65300b06713	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	400.00	400.00	400.00	f00d039c-caa7-5b00-adba-365ed90c5f10	تسليم عهدة إلى 6a11d77b-24cc-577e-9ec3-4b0088eb7585. 	2026-03-25 23:09:02.989959+00	2026-03-26 01:12:01.574239+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
7aaf5ef0-0515-498f-8dbb-5b975b9dd900	6a11d77b-24cc-577e-9ec3-4b0088eb7585	closed	500.00	\N	\N	\N	استلام عهدة من f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:47:35.377359+00	2026-03-26 03:35:05.103584+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
0d04608a-91b5-4568-acfe-365d24228670	6a11d77b-24cc-577e-9ec3-4b0088eb7585	open	300.00	\N	\N	\N	\N	2026-03-26 04:18:47.597485+00	\N	a0366e3a-97c3-46f9-a38c-1316edd22e88	\N	\N	\N
ff1dbe65-5402-4af3-a0c4-4b130ef8b11e	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	100.00	90.00	50.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-26 03:28:44.763979+00	2026-03-26 02:40:34.893048+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
dff47b8d-f7d1-444e-8b80-79bb0c0d0c8f	6a11d77b-24cc-577e-9ec3-4b0088eb7585	closed	400.00	400.00	400.00	6a11d77b-24cc-577e-9ec3-4b0088eb7585	تسليم عهدة إلى f00d039c-caa7-5b00-adba-365ed90c5f10. 	2026-03-26 03:12:01.571392+00	2026-03-26 02:49:24.440563+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
1dc0d5f0-327a-4708-aff9-26c483ab313b	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	400.00	5000.00	50.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-26 04:49:24.436858+00	2026-03-27 03:16:18.436942+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
f96f6bdf-ca98-4a84-acf4-47ab176cb366	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	500.00	480.00	80.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-27 05:17:54.285992+00	2026-03-27 03:17:54.46788+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
15399445-14ab-4dea-aadc-0c0c1befe128	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	300.00	300.00	50.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-27 05:19:29.270053+00	2026-03-27 03:19:29.459574+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	\N	\N	\N
3dcf287f-653a-4299-b80d-c840e1503e2b	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	50.00	330.00	0.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-27 12:03:57.997932+00	2026-03-29 14:04:54.248611+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	\N
4a7dd547-9642-4562-a0a8-1fa55de24162	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	0.00	190.00	190.00	f00d039c-caa7-5b00-adba-365ed90c5f10	تسليم عهدة إلى 7ef659d3-53f7-48b1-aca3-538ef5a1b3cd. 	2026-03-29 16:53:09.769922+00	2026-03-29 17:20:24.165954+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	\N
a4a070b3-e6f5-499f-9940-dcd41fcc2188	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	closed	190.00	640.00	640.00	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	تسليم عهدة إلى 6a11d77b-24cc-577e-9ec3-4b0088eb7585. 	2026-03-29 17:20:24.162693+00	2026-04-03 17:34:23.443167+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	\N
81d14179-f091-4b8c-b756-8da0717ea007	6a11d77b-24cc-577e-9ec3-4b0088eb7585	closed	640.00	640.00	110.00	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	2026-04-03 17:34:23.430458+00	2026-04-04 09:38:10.580181+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	90b16bd6-d77a-456c-93fe-04c9a8eb445e	\N	\N
b3d28ac9-4ac9-4b17-84ac-a6c05253ef3d	ee31f134-c885-42b4-950b-53284e09a25b	closed	110.00	3665.00	3665.00	ee31f134-c885-42b4-950b-53284e09a25b	تسليم عهدة إلى 6a11d77b-24cc-577e-9ec3-4b0088eb7585. 	2026-04-04 10:23:49.993783+00	2026-04-04 16:33:47.335851+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	\N
e5355dec-89d0-445f-9fc7-85065801c28c	6a11d77b-24cc-577e-9ec3-4b0088eb7585	closed	3665.00	4815.00	100.00	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	2026-04-04 16:33:47.332736+00	2026-04-05 08:48:51.383001+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
900146ce-a935-43ea-a6d4-647276e80612	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	0.00	3400.00	0.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-03-31 11:50:34.888454+00	2026-04-09 17:00:21.664971+00	536e6eba-c111-4d60-b812-ead42ab23883	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
81d0c548-0de6-4773-9630-f001207f5598	85ba0e1f-040c-44b2-90a3-0afcaa30178b	closed	0.00	1810.00	1810.00	85ba0e1f-040c-44b2-90a3-0afcaa30178b	تسليم عهدة إلى 85ba0e1f-040c-44b2-90a3-0afcaa30178b. 	2026-04-09 17:01:18.785097+00	2026-04-09 17:30:43.723752+00	536e6eba-c111-4d60-b812-ead42ab23883	85ba0e1f-040c-44b2-90a3-0afcaa30178b	\N	\N
1a61e024-d1fe-4627-89c1-d587bd2bfab0	85ba0e1f-040c-44b2-90a3-0afcaa30178b	closed	1810.00	2295.00	2295.00	85ba0e1f-040c-44b2-90a3-0afcaa30178b	تسليم عهدة إلى 85ba0e1f-040c-44b2-90a3-0afcaa30178b. 	2026-04-09 17:30:43.720821+00	2026-04-09 19:32:20.796613+00	536e6eba-c111-4d60-b812-ead42ab23883	85ba0e1f-040c-44b2-90a3-0afcaa30178b	\N	\N
8c089b6f-0320-44e1-a2aa-8845c90b71aa	85ba0e1f-040c-44b2-90a3-0afcaa30178b	closed	2295.00	2295.00	20.00	85ba0e1f-040c-44b2-90a3-0afcaa30178b	\N	2026-04-09 19:32:20.791263+00	2026-04-11 11:34:04.414299+00	536e6eba-c111-4d60-b812-ead42ab23883	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
7fc6e86e-a0b6-462c-814e-1f5c04397f36	658196d5-857d-493c-94e4-e604b01764ab	open	20.00	\N	\N	\N	\N	2026-04-11 11:34:36.902849+00	\N	536e6eba-c111-4d60-b812-ead42ab23883	\N	\N	\N
6f43b59c-48b9-4220-a9ad-c0348cad9197	ee31f134-c885-42b4-950b-53284e09a25b	closed	100.00	230.00	90.00	ee31f134-c885-42b4-950b-53284e09a25b	\N	2026-04-05 09:07:48.555369+00	2026-04-15 13:39:50.858792+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
7102a2f6-e219-469d-82ca-f0e219dead60	ee31f134-c885-42b4-950b-53284e09a25b	closed	90.00	90.00	90.00	ee31f134-c885-42b4-950b-53284e09a25b	\N	2026-04-15 13:40:08.758516+00	2026-04-15 13:41:15.028197+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
f7bebd31-df98-4b71-8a19-e4daead03400	ee31f134-c885-42b4-950b-53284e09a25b	closed	90.00	90.00	90.00	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	2026-04-15 13:42:29.403599+00	2026-04-15 14:05:20.357852+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
1f6ee49f-98ac-4ec2-b0fa-5b28f1eae07e	6a11d77b-24cc-577e-9ec3-4b0088eb7585	closed	90.00	90.00	90.00	ee31f134-c885-42b4-950b-53284e09a25b	\N	2026-04-15 14:05:53.451066+00	2026-04-15 14:09:07.846917+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
5f1b5c1f-bb3b-4b71-966b-1ff4948d9ada	ee31f134-c885-42b4-950b-53284e09a25b	closed	90.00	800.00	800.00	ee31f134-c885-42b4-950b-53284e09a25b	تسليم عهدة إلى 6a11d77b-24cc-577e-9ec3-4b0088eb7585. 	2026-04-15 14:10:13.816555+00	2026-04-15 16:52:22.008319+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	\N
0dbb0981-7969-4775-8d06-123a461e83e0	6a11d77b-24cc-577e-9ec3-4b0088eb7585	closed	800.00	250.00	250.00	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	2026-04-15 16:52:22.005738+00	2026-04-15 20:01:57.449678+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
73bdd2e6-f881-4dd1-9631-250e247abf6f	916e8dbf-c920-4cfd-a9af-f2f76d16417b	closed	250.00	100.00	100.00	ee31f134-c885-42b4-950b-53284e09a25b	\N	2026-04-15 20:06:52.449757+00	2026-04-16 12:44:50.25264+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
638065e8-f2e9-4435-b0eb-9cbfef60a771	6a11d77b-24cc-577e-9ec3-4b0088eb7585	closed	100.00	3305.00	265.00	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	2026-04-16 17:43:48.823187+00	2026-04-17 10:57:44.927071+00	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
114bc5a4-76e6-4f4b-a8f8-33244c6a3469	6a11d77b-24cc-577e-9ec3-4b0088eb7585	open	265.00	\N	\N	\N	\N	2026-04-17 10:58:55.435525+00	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	\N
7827d0d8-ad02-4b7b-8b54-cb9f7c3ab997	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	0.00	2035.00	2035.00	f00d039c-caa7-5b00-adba-365ed90c5f10	تسليم عهدة إلى 658196d5-857d-493c-94e4-e604b01764ab. 	2026-04-11 16:13:27.885299+00	2026-04-19 21:24:27.972019+00	dc59d83b-1dec-4f60-8cde-4826031c7195	\N	\N	\N
9caef843-cb34-4aab-b867-e0b32e96d2ab	658196d5-857d-493c-94e4-e604b01764ab	closed	2035.00	3985.00	3985.00	658196d5-857d-493c-94e4-e604b01764ab	تسليم عهدة إلى f00d039c-caa7-5b00-adba-365ed90c5f10. 	2026-04-19 21:24:27.964614+00	2026-04-20 16:47:30.031846+00	dc59d83b-1dec-4f60-8cde-4826031c7195	\N	\N	\N
cee213fd-a788-4f57-afa0-b5416461570b	f00d039c-caa7-5b00-adba-365ed90c5f10	closed	3985.00	3985.00	5.00	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	2026-04-20 16:47:30.029154+00	2026-04-21 13:24:00.165601+00	dc59d83b-1dec-4f60-8cde-4826031c7195	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	\N	\N
1cfd81c6-cd5d-4c58-ac06-b77e9cf9c167	85ba0e1f-040c-44b2-90a3-0afcaa30178b	closed	5.00	180.00	180.00	85ba0e1f-040c-44b2-90a3-0afcaa30178b	تسليم عهدة إلى 85ba0e1f-040c-44b2-90a3-0afcaa30178b. 	2026-04-21 19:50:42.657506+00	2026-04-22 15:26:56.855783+00	dc59d83b-1dec-4f60-8cde-4826031c7195	\N	\N	\N
4293a80b-6b43-4b79-ba90-26f734f28377	85ba0e1f-040c-44b2-90a3-0afcaa30178b	closed	180.00	180.00	180.00	85ba0e1f-040c-44b2-90a3-0afcaa30178b	تسليم عهدة إلى 658196d5-857d-493c-94e4-e604b01764ab. 	2026-04-22 15:26:56.853341+00	2026-04-22 17:07:30.351976+00	dc59d83b-1dec-4f60-8cde-4826031c7195	\N	\N	\N
ed9a9380-df7e-4d28-8433-2d0d060a6a5d	658196d5-857d-493c-94e4-e604b01764ab	open	180.00	\N	\N	\N	استلام عهدة من 85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-22 17:07:30.35048+00	\N	dc59d83b-1dec-4f60-8cde-4826031c7195	\N	\N	\N
\.


--
-- Data for Name: stock_movements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_movements (id, product_id, warehouse_id, movement_type, qty, unit_cost, unit_price, ref_id, ref_type, note, created_by, created_at) FROM stdin;
0fffe9ac-9365-4c50-a264-66a765ee8fb0	728d6023-951b-4a19-8cfb-d62631ab5736	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	67.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:08:59.187858+00
59fcfb8c-897d-4163-b9c2-a7665f97ab01	55cc2075-bfe4-4613-91de-05535390b28a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-11 16:21:46.928506+00
9e58745c-3e4d-4623-991a-02f0c7c12510	d5442bca-dd7e-4793-aded-ef8d13f3d2b9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	73.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:22:48.236747+00
1efac565-551f-4dc6-af3f-81fe232b3189	66a44e6e-ba10-4e53-96ee-b41b8af644eb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	78.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:24:22.931161+00
7d9a779c-4476-4405-acb0-58a599530ef7	0f81a2a2-6a73-4278-836d-a08c10fb0238	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:25:03.769938+00
ddf7c88f-8f9b-4fe8-a2a6-7f5b05cdd3a0	19ca0c73-ab1d-41ee-8a08-45121c253710	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	238.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:26:48.965391+00
bcd5da6f-f44d-41b1-8eea-3896524881c7	5bb79780-a8aa-4007-b778-5ad0dbb78e6e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_in	2.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:51:12.015338+00
c5604320-02e9-4d4c-ba1e-0dbd755f42b5	6b464626-fbe4-4656-bd1a-d571d6836693	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	37.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:53:31.712839+00
e0669817-2347-4f98-b0c2-a5c6e7947b71	258a592c-948d-42c9-8c2d-8bfa4641b016	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	193.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:55:10.218499+00
c0780286-066a-4fbf-a2bd-5ecde671945f	38add71e-db1c-4c7b-a43d-6b79280ec3dc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:00:57.041622+00
65fea859-1411-426a-ab68-9cf649d59d45	d8044cc3-b892-4d4d-b108-e5d2dc39134b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	82.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:02:12.426102+00
56610e63-8164-4fa2-843a-9eda289f1b20	99a28536-9fce-497d-b168-b3a14c79d5c1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	38.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:05:48.866361+00
77acb0b7-06c3-413a-ad2c-f13ac775bc58	015510b5-5c17-40eb-8099-378255764017	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	43.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:09:16.754665+00
efc6bb97-33f2-41bc-8038-09e3dc714c76	3132378f-a089-4b2b-a047-c1e0a8651c31	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:12:20.683415+00
cef084a1-1070-42c1-9e21-67fe2a2a9fb8	d3c4e18f-4297-4fea-b338-756ca2c90097	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:12:30.792852+00
89ebe4d3-b3b3-4809-8f79-ecb06725324a	c93e6a11-6694-486c-936c-3208c49f198f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	57.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:26:54.516652+00
236201e7-b0da-4015-944f-e3f772006a55	311f37ca-8c7f-4b3c-a32a-4bd675dd929b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	174.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:28:44.618024+00
3ba2563a-f6e7-4190-9b3e-8446be0de704	d159b603-06ca-4d80-b251-120ca04bd0ee	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	132.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:34:05.616529+00
373494ac-a30f-4073-ab3e-746f28155cfd	91e61835-47cd-4f2b-ab57-012a307a2c79	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 12:44:32.251183+00
69b7c226-6af0-4690-aefa-90074c30819e	745c9937-e523-400f-8665-dd79e076f39f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:27:42.893623+00
7f6c4ca4-2801-4988-951a-d971c2dba550	3475e3b2-b002-47e6-88ee-85a33cd7f837	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	45.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:31:18.403574+00
b005418e-14d6-4b78-9b8f-46cc9061241e	7c033855-5e8a-44e7-a03a-c91729b55080	59a2b8d7-e26b-4979-ae0e-3984f1b711b2	transfer_out	7.000	0.00	0.00	37566316-bffe-4b80-8e23-c8f905921fd6	dispatch	احا	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 14:17:33.501816+00
34fdef38-f784-43cb-a8f7-9c8efb1d2907	45b07094-6fd8-4438-aa7b-4ba17e5ed897	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	27.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:53:51.885013+00
0558b28f-4b58-4521-8285-a9977193f261	c8b78e53-a457-4b32-8897-c449f3fe1e4f	da49f5cd-ecad-46d3-872a-37c80585a2f0	transfer_out	5.000	0.00	0.00	9238cc9e-ab78-4676-8cff-79228ddc1f1c	dispatch	صرف للمعرض	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:49:31.492925+00
aaf1e152-cc34-4337-b597-7157cea3aea4	1a03ff11-9bf4-472b-aae3-8734a988747c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	0.500	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 14:23:54.102153+00
7a19544f-19a7-4010-b460-7e5130b39f54	c8b78e53-a457-4b32-8897-c449f3fe1e4f	da49f5cd-ecad-46d3-872a-37c80585a2f0	purchase	100.000	15.50	0.00	96df7161-c316-4e54-93f7-853861ccbc36	goods_receipt	فاتورة 1234	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:49:31.620689+00
a7bf8ee7-f976-4ceb-9691-238e178150af	c0bb6a9f-74a3-451e-bbe4-155987c92339	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 14:25:57.38109+00
e130a07e-a4a9-4bd2-b134-81ce42f5cd62	327257f0-e96b-4e86-8094-0e1216466f99	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 17:11:31.732449+00
fc84538c-59fe-4511-9926-8c2eb1152c87	ee38e66f-0104-46d4-a30f-798a7fdde029	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 18:00:37.057101+00
fba6d8c0-37c2-4429-bd25-13681d4a715a	a2e0f808-484f-4e7a-8fc7-bbdd41e2e3cc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 18:04:27.416807+00
b75ca3a8-a8cb-4039-ab23-89ae5c69b378	958976e5-78b1-48dd-b90c-639ecac8608e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	20.00	9962c7e8-8e13-4754-bb24-3dd9c434b4b9	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 17:48:17.701328+00
5a7bfb7e-308c-4949-98e9-ebb5f00b4a69	fd927c9a-2843-4740-b97e-c92f51424765	dc59d83b-1dec-4f60-8cde-4826031c7195	sale	15.000	0.00	110.00	bf0089c4-e0b3-4ec0-9573-1d60d3ca8c56	sale	\N	658196d5-857d-493c-94e4-e604b01764ab	2026-04-20 16:43:05.129604+00
28a7b9e9-8fd3-4227-9157-ee3eb8d29f12	a828ddc0-5d87-4062-a86a-a50dcf685191	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	321.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:09:33.38605+00
52a758f8-dfa5-486b-98a7-0c3de030d699	cf75658d-4804-42d6-bd8f-edf3a77549be	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	30.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:51:50.916443+00
d2d47508-737a-4ca5-9703-0f20f8e3acac	a7861f0d-2057-4965-97f3-26b745cbbc8b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:54:39.987051+00
0833e155-f7d3-49db-b1a7-8a033099788a	55cc2075-bfe4-4613-91de-05535390b28a	dc59d83b-1dec-4f60-8cde-4826031c7195	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	2026-04-11 16:59:49.934626+00
cf71ee9d-e50e-43fd-84c7-4a0633d2fcfe	8af6f47a-5f64-4895-945b-fd307a9859f3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	51.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:01:01.544532+00
6e5e29f9-6cbf-4108-af93-599bd466168c	672e317a-e3e5-42d5-8da2-40b152ca973e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	248.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:02:38.969777+00
a09dbc35-fa29-4854-b7a5-c97a27c111aa	517e8569-1a19-4a7b-8743-c6a9df8adae2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:04:29.719166+00
bca2e106-e09b-4df1-8872-c14a339f4ec6	ed6fb4fe-6aa7-4a8f-8856-bbdd3b7b7625	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:05:15.801864+00
bd9e81a9-9ed9-4a10-9621-9ca976093cd2	e7f5a544-04fd-4b2d-9146-fb79df577821	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	81.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:06:58.26589+00
902eab36-e7e7-4ffe-80e3-8faf1c67269f	fbc41295-0338-4e49-b61e-79e99e9f5667	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	108.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:08:11.256097+00
b63166a9-ad3e-4d8e-9165-3b02b4bd55bc	eabea370-6202-46ed-836d-89822831f083	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	120.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:08:44.714024+00
90529a4a-b04e-4324-a9fa-4b393cd11d91	67361216-d048-4bca-9f65-3c1df07745a1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	38.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:09:51.579014+00
9ce9e2f6-9c2e-4a3d-b202-b8380a3e10f7	22a11cf4-2023-4f18-895e-89f507d5829a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:10:35.248566+00
50ad33ae-9810-422f-8af1-805953e80ec7	8efe2eb5-bd06-48bb-b1ae-b843129e85eb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	156.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:27:26.326607+00
6cf026e6-52d2-416e-b449-fb9002466d4a	85be72d3-5d91-4bc1-8bc8-73b53c083490	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	83.000	15.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:32:46.128722+00
c53e625d-880c-49be-bce4-329b5adab485	357dad92-ae44-40df-98d6-135586d4f7c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:33:57.072438+00
fd39984f-822b-42ea-b79e-66a55335ec15	98a0d6e7-821f-45f3-8d99-52cd2e6d4699	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	250.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 12:20:49.33203+00
ab348d15-936f-4667-89a9-dbde8d2016bd	12a192bf-25f2-43bb-b1e5-94ac6cb5e62b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	278.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 12:21:43.411165+00
cfbabf9c-9f90-4124-8993-4c4468eebc31	d78e3631-becb-459d-bcb7-f626d9bdae58	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:30:43.858471+00
5d09f047-3542-4f45-9c88-feac8078a32a	32cac645-8208-4dac-9da8-01986e061b8c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:53:04.974043+00
ed51e1f6-f10f-4a66-8b29-6a9db42c22ec	1a03ff11-9bf4-472b-aae3-8734a988747c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 14:23:18.957342+00
6e9f92d9-6545-476e-9d44-53a99d6624a2	0a9b79fd-9500-41b5-bd72-86f8c282ecfb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 14:31:05.492303+00
c6aa5d32-ecf7-459b-89e9-5104ec7cac29	cb81213b-7bb7-4274-abb4-2d974f8a60cb	dc59d83b-1dec-4f60-8cde-4826031c7195	opening_stock	0.000	0.00	0.00	\N	\N	رصيد افتتاحي	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-13 16:00:02.247119+00
29a3d779-fb50-459b-8cce-f4752a10bc39	ee38e66f-0104-46d4-a30f-798a7fdde029	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 18:00:57.252155+00
ce9a95c8-a23f-4b3a-9776-d866f97bfa6f	7e302e33-3bb9-436d-b2a6-f64f71fa113e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	45.00	3bc55c39-04c5-4c70-a956-54e262642e52	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 17:53:59.149494+00
9080dc37-0b5b-41f0-9215-a931e09ba302	fbc41295-0338-4e49-b61e-79e99e9f5667	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	30.00	9cfee519-9104-4f79-8523-9849182a4951	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:00:38.94932+00
9bdafe81-53d3-41a0-980f-8b37b251e73a	a6443656-c761-4e9b-8d67-7396fe3275a6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:27:28.624942+00
40a866ee-d6c5-402b-8788-07f323ec18f1	a57c48df-95f9-4c17-bff1-82c1d151b0b0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:29:23.604248+00
3d1a2fc0-7af1-4c2a-91a8-cf01110f81a6	7568b958-f282-4aa1-85b5-24349625f9db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	90.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:34:11.633171+00
d179d99a-14f7-4406-8cb3-72ef8bc3b9a3	5e9e99fb-95ac-4298-a437-570417737d44	dc59d83b-1dec-4f60-8cde-4826031c7195	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-18 20:00:48.852656+00
92e0dc62-cde1-449b-a166-a06efada7ebe	c80f86d8-cb80-465f-ad00-b3583f1c4c40	dc59d83b-1dec-4f60-8cde-4826031c7195	sale	1.000	0.00	100.00	3f6c0df5-9b7e-4f8c-a56c-a70e50ab37a8	sale	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-21 19:52:09.950176+00
30c56d83-f6c6-4ee8-be17-92b30fced825	cb81213b-7bb7-4274-abb4-2d974f8a60cb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	92.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:12:34.93691+00
9bb6b3e3-da6f-46f5-88a6-c9acc4a2bf29	89153ada-a2e6-45ff-965d-a610fca6a73f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:52:18.362361+00
65253cfe-9d2c-4a7c-875b-06075175f64f	885638eb-a9ca-4ee2-bf74-5730e5852bc6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	129.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:54:15.618104+00
95382c9c-0287-4ada-a88b-e1f673f6d011	a21a8080-f94d-4927-bf0b-2390e2500059	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	156.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:54:28.401168+00
98940b41-006f-4f54-b70b-1f6edade9fc2	83759832-7ee5-43fc-8828-695b2d8c7c3e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	109.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:55:20.529985+00
22010543-107d-421b-984d-a262b121f3eb	55cc2075-bfe4-4613-91de-05535390b28a	dc59d83b-1dec-4f60-8cde-4826031c7195	sale	1.000	0.00	35.00	01bfe807-abfb-4b40-b2ba-91cdf635e8b1	sale	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-11 16:57:50.030337+00
189ee454-d361-469b-aac9-877e569c771d	36a71af5-edd7-4e4c-9b77-fb2b37c53cf8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	137.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:59:48.156713+00
4f918d9e-c90b-4a46-8570-4ea669fe647a	55cc2075-bfe4-4613-91de-05535390b28a	dc59d83b-1dec-4f60-8cde-4826031c7195	adjustment_in	1.000	0.00	0.00	\N	\N	تصحيح جرد	c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	2026-04-11 17:00:17.842695+00
bb14d2da-4e01-466c-ad1b-5788d3e1c335	f8361f30-bb8d-4a44-bc2d-3ae7ef72f027	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	104.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:01:25.331679+00
2375a44f-f4b8-4b77-8e97-3c2ce16b2ff4	2777c8de-00ad-419f-bd60-236b2e52effa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	31.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:04:43.969314+00
44542f0e-91c1-43ca-bd63-b194da606e66	b69b3ce6-eb91-4356-86b3-2240135059b3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	40.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:07:25.840017+00
519891c2-4555-473f-bd74-4180992ac08b	87d4538d-0e02-44ee-976a-53651c8e11ab	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	42.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:09:32.879117+00
e592c3b1-0e58-44ec-8ef5-3726db30c7cc	01c759af-1334-4521-be65-58d69f5d3158	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	67.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:12:53.714776+00
cbcaeb2a-df86-4883-8e99-ed9a4b042185	6e4b57c6-a303-4249-9f3c-7075f1a14bce	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	78.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:27:56.486178+00
f7ef1df3-42eb-443d-98f0-c823ad6057f4	858d8c6c-94bc-4b7b-9bf6-f5aaf4cc7aca	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	377.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:33:31.628661+00
927f3bce-3259-4e2a-b491-025de25ed6ad	d4f387cf-2b6a-4ca0-ba1c-099b594a5949	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	41.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:33:46.483181+00
f4e8cd57-e9ba-4442-9f93-ecda60a39361	2af69fb2-b207-43c5-9f6d-0fa26b40cf18	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	462.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 12:22:40.481241+00
748224e2-fac3-44ec-be31-6ae223472c13	147e4173-a198-4ef5-b70c-9ed8aa73c872	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	262.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 12:26:56.971018+00
fef896c0-580a-46eb-9d51-646b6d58b29f	f0b0cc99-32e6-4b1a-8493-25be82e03e31	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	207.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:19:52.638523+00
644ec161-26aa-4607-97a0-9861522f06a6	45b3d31e-23e5-4b53-ad46-e71044fd702b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	121.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:21:46.39591+00
f79a518f-7402-4a9a-8700-83ee7422ea9c	b817632a-1b1c-4494-bbef-2dcc9c54aff5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	18.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:30:04.945035+00
388851e0-a522-4c23-a28f-d0c8a2a3ce31	625c7018-17e7-4090-9e8a-fbbedab8d3e2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	51.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:53:17.422058+00
203175ea-a7f2-4952-a6cf-f965e9464202	b846a51a-8875-4a9c-9afc-19b7b5eea618	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 14:22:02.788832+00
9711aaf5-68f9-44dc-a740-3019b948de9b	437f52ee-b323-4a5b-a6cf-aaac3b2e4691	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 14:25:54.772326+00
37e085d9-d14b-4a3e-8501-1b8b44ea86f6	c120ad01-bbee-4fcf-923a-d30ccd95de43	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	23.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 15:03:04.438289+00
9ca2fe59-6543-4b6b-926a-61282f9039fb	672e317a-e3e5-42d5-8da2-40b152ca973e	dc59d83b-1dec-4f60-8cde-4826031c7195	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-13 15:55:32.475712+00
bc18494c-e0e7-462b-95b5-d7c1f4624d27	c66c0732-d798-447c-a1d8-9fc73cd6396d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	62.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 18:04:50.959813+00
b63bcdb5-985a-4b5f-abdf-303478e710a1	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	150.00	9a7319e2-31a4-4753-abc2-bb92bbe01f07	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-15 13:33:13.852725+00
5c9510e1-d7f3-4629-a955-bd715090e026	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	150.00	1ff4ccc4-5613-4a7a-ba95-5ac080aeef04	sale	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 13:53:44.52708+00
ef832885-c9b4-4391-b4a1-ea50796453ef	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	150.00	ca4ea6f5-82ca-4f96-bed8-a5b2a2a1b3c1	sale	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:13:25.866305+00
af97d94a-1377-404d-9c8b-77a7e998139a	b9b32325-fda4-46a7-b4f4-6da187863e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	40.00	180.00	191377d0-0506-4cd5-bf1d-fc3fd65bac11	sale	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 15:22:30.433226+00
92c53575-7b68-475c-b4eb-ae83ccd88996	dc312bb2-984d-4c5b-8f9d-f5a0a165eb78	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	85.00	8c5491cc-a19c-40f6-ae95-53ce44f08a0a	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:09:21.705211+00
fcfb9203-af87-47fc-b01a-243cf95ca88e	357dad92-ae44-40df-98d6-135586d4f7c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	35.00	c9bd780c-9eb4-4ee1-a7ac-8f21fa7293b4	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:12:40.942116+00
bdc680c1-a2fe-4c2b-97fd-2d092bca5dae	858d8c6c-94bc-4b7b-9bf6-f5aaf4cc7aca	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	35.00	12c64805-0c9e-41b1-8a35-e0faede4dfee	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:16:59.030531+00
ba757502-1198-4dba-9402-e2f79198ce3f	2fbf13f5-20e4-4d56-a923-31acf00d8e7b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:26:18.995935+00
adb62a5f-fd9b-4e70-9fcf-7b4f8c34c24e	eb80381b-f03c-4b75-b499-0ce239678953	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:32:06.091438+00
882dad36-efc0-4164-8296-f15c919ceb37	5e9e99fb-95ac-4298-a437-570417737d44	dc59d83b-1dec-4f60-8cde-4826031c7195	sale	1.000	0.00	2000.00	a19b0900-0496-40c2-8d39-e4efc6a33a63	sale	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-18 20:01:20.449249+00
1275d4f7-223b-4473-8bd6-7894d8d4a962	6262274f-c0c8-4a53-84cf-c3977995ddce	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	100.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:14:12.390275+00
11915689-b9d5-4795-b969-f13eb69865c3	bb6e8e5f-10ce-4074-a838-5afc4bfd8c9b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:48:59.520987+00
8a48cc66-c73a-48e4-901f-8c5bd9709636	db12ee40-16a3-42ce-b548-5de14a547b0a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:55:00.273816+00
7e247169-9ad4-48d4-9ccd-a91930bda706	0c08bdc9-fa2c-437e-98df-0b56837b1315	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	23.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:56:51.22389+00
85547249-6e19-4ed8-b1fb-fd9557efe3fd	6a6a73a1-51e7-48ae-8455-0e176997bed6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:13:13.782629+00
cb872dd3-cd20-4e41-bd30-73caf9593942	c28b3b82-82ae-4845-ab2a-4dfd414ee5ca	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:20:24.263095+00
878a0657-b797-4304-972e-fc896372e0b9	80e1b844-6853-4d0e-b574-51a38644a638	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:52:00.159716+00
5b24c4b7-2fae-4f0e-82d2-6208d73544c7	0668c81e-e210-485a-bd0f-4d072c702c6e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	43.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:13:47.363766+00
52e3abfb-3679-4506-99f7-0cb44be7f2e0	bf9ce757-b348-4b75-bbb4-0c6bf8efc605	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:19:27.944593+00
f273385f-b4b3-4f98-b831-67449f40a916	5bb79780-a8aa-4007-b778-5ad0dbb78e6e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:29:05.393833+00
1c91611d-4833-4b41-a42e-574c456c3d3b	e0066fb9-2326-421b-a886-489c8b5863ab	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	38.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:53:23.76707+00
b2daee32-e374-47d1-a3c3-f7a550edbc88	819e0c3a-b235-4ddb-bd47-6663768def49	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:53:52.050961+00
e552418c-f18c-4507-8d70-819dbd0543d7	577cd1d9-5876-4b11-be1c-cd338c878aa2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	58.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:00:38.104384+00
9864c742-5eb8-4481-bc57-2db6334e2cdd	3cc22441-f1e7-4186-b81f-37d1e1548fd6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:01:50.466672+00
6a979f5c-070e-4351-b363-1272f7f4924a	365c40f7-a07a-4fd9-bc17-468c7fb2536e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	46.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:03:56.504008+00
847f2a9b-2980-49b3-8586-ae10ddce954b	e5e9bcf1-22ad-40e2-a443-9b4acdbbe426	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:05:02.240758+00
a839d02d-422d-4053-8001-5f794c11e3c9	ce256e73-4b15-4f88-b65e-4247cc702058	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:06:39.012154+00
5692f534-1138-43f0-8e75-ed016831016c	6c169f15-1614-4161-97af-cf38b1608e64	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:07:40.514131+00
0c0dd07f-03d9-4ae4-a992-f73c875daadd	b75b4bad-63d7-4336-a14d-b95c9a221e74	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	150.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:13:08.640971+00
a92b0cdb-15a0-4f81-82ae-1402865488bb	5f551abc-5798-4f04-8557-01afc73bb977	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	41.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:28:05.898713+00
c3030954-c117-4501-aa2e-263881e2e9d7	04e83173-2a26-4e61-b3be-456de3b641f9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	79.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:33:09.989008+00
9973b5a6-2aa9-4a37-bba7-646dfcc21b0d	4f371ebc-a80b-413d-8224-7c7458e3fc6a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:34:46.537236+00
71b23760-fd0b-4337-97ea-f620da60530b	89392aba-aa30-4188-914b-4792ca2815d0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	546.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 12:19:54.764876+00
d6d5abed-02bf-4515-acbe-e213adefe090	37ee2418-56bb-4d8e-b0ec-fe9ffb1fc333	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 12:34:31.623705+00
384de4bd-fcf7-48bd-954e-97f8e66cafe5	8eb4090c-1096-43f2-acd8-31efcbd7e315	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 12:43:21.835457+00
718a4c14-d1c8-43e6-a9ea-5f7d303ac403	43262301-8bc0-4e5e-98f8-df79b0032751	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	35.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:13:40.30722+00
c25f3bbc-29b3-4a0d-a0bc-2e8726d2fe71	c36eaf49-88a6-453a-badd-ebef0c1e6ee5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 14:02:05.604134+00
580694af-5a6c-4660-84d0-94d7376ad4a8	85c4336b-4190-4737-a888-a83dee164695	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	66.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 16:30:55.497477+00
7e9758a2-8221-448e-8954-69ac6ca76551	ee38e66f-0104-46d4-a30f-798a7fdde029	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	6.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 18:00:53.818012+00
d0a80960-d775-490b-87e0-f1360da600f1	427bdbf1-0a40-491a-bff7-7ea64a086ea0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	72.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 18:04:38.494406+00
ff022ebc-860e-4619-9745-f26237f937f7	a4997b77-66bf-4b4f-ae74-74762dd0712c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	5.00	3de73516-254f-47b6-89d4-3e4b9a289e6b	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:13:09.28253+00
e6439746-c6f8-4119-bcf9-9ea2e0c99838	da5bf6fb-6156-445d-a462-809b65e03e52	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	66.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:31:10.613033+00
0626c9d8-fcde-4a3a-a316-0974dc417e75	d2ffb803-9a86-4990-b834-9a3d7413444d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:34:01.515364+00
a0871bfa-b6a2-451a-b51b-e117089a4342	3b1471c3-f7f4-4a7d-a28d-06206542e170	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:35:52.641802+00
a783fa8c-bfd2-4dab-b08a-a56b630060b6	b262a202-b104-436c-961b-749be916955c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:37:45.142933+00
0b3d26ae-9b6a-4bf7-837f-33689608764b	4d5e6616-df0c-41a0-a88c-bad074a514af	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:54:01.353196+00
30051c84-ef72-4d90-a5e3-4575298e2779	9cffbe6c-1071-48ce-8973-fcd035c61762	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:16:15.809754+00
c3d13594-54a5-444a-b132-5ca46ccba2fc	b262a202-b104-436c-961b-749be916955c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:21:29.313373+00
e43f74ac-c237-4672-ae13-8d0eb7c4ad88	b262a202-b104-436c-961b-749be916955c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:23:16.849254+00
d3a4e2ce-4afb-422e-a9df-4610b93997f2	b262a202-b104-436c-961b-749be916955c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_in	3.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:23:31.209654+00
5c81a86b-08a8-45fb-8c44-8bea4a8e9fff	431857ef-7002-4208-836b-2d92a8b886db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:41:35.041477+00
1a9b5e2b-9c11-4d04-ab99-c09b418b112e	3854671f-68b4-489a-865a-8c80fb2a80d5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 15:12:15.20872+00
a7ba4c71-70a9-435e-b152-98d32da25c0f	bc28ef2a-26a3-4fa2-9f4e-2b938f776bd4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:16:55.120413+00
2f580211-c6dd-4ba5-ad2f-1a678c646bba	e3ef3606-53ce-4847-a9ae-7357efdea79a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:20:25.000291+00
36789435-e9dc-42c9-925d-c5c7d6774d74	49f4d737-1d66-4bbf-8011-44949b013133	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	36.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:21:01.032548+00
ccf34995-47ed-4735-abc2-3729fd8b705c	55cc2075-bfe4-4613-91de-05535390b28a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	16.000	0.00	0.00	\N	\N	تصحيح جرد	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-11 16:23:07.611305+00
552c5918-a041-415a-8df3-1a4733fa063f	cb153139-9139-4c4b-b341-9cabab43c132	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	83.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:23:59.794055+00
679e7a19-3bbb-42ec-9e2e-cd1399b76569	93f907c6-3b84-4d95-b1a5-b57483e81451	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	43.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:27:40.113397+00
7630b58e-2cdf-44ac-8be5-91085dfd8708	857d4856-aca0-4f69-89d8-59ed2d1b86d0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:57:46.242528+00
86bec213-5f37-4631-bb77-68de96dcf797	1d30a4fe-fbfe-4d3e-886d-d7c5ec544240	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	57.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:00:06.375391+00
b675e4cf-c22e-41fa-97d5-8b8dd3408992	3892616c-8ad0-47d2-aebc-ba3c30cefb39	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:02:59.80641+00
51c20ab3-28aa-4105-b17d-3ad5c3076fd7	e78feee1-8757-433d-9a58-27338aaf1655	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	71.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:04:35.959262+00
d2c2233d-4bdf-4cba-9a91-b4e6f9f6202e	07ad204e-14a8-4bec-92e2-3997be506cc5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:05:31.912222+00
d151b4ef-0538-473d-a699-c8785af5dd63	92e36fa1-8349-447e-a7be-511d6f209f20	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:07:11.441998+00
bbeeb23a-1a30-454b-8fff-e66d5c119c5f	177bed74-3f94-4fed-93a0-e23cb13847f4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	63.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:10:13.745087+00
70edca33-e16c-4f5c-b65a-f4f2e318281f	523adcc8-e4e9-4766-981b-e5165d723e43	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:11:13.313318+00
89c4566c-b1c4-409c-97e6-9d5266093416	c1895f9b-5d9b-4507-9ac8-be10dd5c08d0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	220.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:11:23.657011+00
0e748517-ac43-4247-96a6-39b57ab3536c	8a00f949-0c0c-4c21-8d44-c6ffaae33aa9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:13:32.696228+00
403a961b-ddbc-4c53-9858-bf50affc10c6	5660d767-7d28-4b31-a146-9c7071134ce8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	223.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 11:28:29.637116+00
3556145f-c82a-47e6-b3e3-1cfe17dd428e	6c53ac78-8c67-4b7d-9417-fe21bb9cad2c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	50.00	149faca0-30a9-465e-9a18-10cd67c71a23	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:19:38.130327+00
c737fb1b-dcca-4f2a-a640-c56d0e0349d6	9ad31176-b502-43b7-b47a-57cdaa1e623f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	120.00	641a91af-fb3a-4ba0-90b1-3d78f6db15ee	sale	\N	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-16 18:46:52.341965+00
496cba82-3cf4-4e2d-a3e4-64cb56486b82	e583e7c1-b883-4bca-bd92-c79c07f3102a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:30:00.768671+00
a05d619e-96e1-41f6-8f55-3f703ad0c15d	1956ad46-29b3-447e-abd2-de8532dcb0d1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:32:38.403303+00
3d79d11d-003a-48ba-80e0-10f9cfd2218a	f9f94c31-4ab6-4b16-860c-42b07f2fe7ac	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	97.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:33:32.085922+00
8475cf17-61cc-429c-9f90-f7f0036aceed	43e5a9ca-78c2-4f05-affc-4c6e2491605a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	61.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:33:54.521348+00
e6d91137-e38b-406a-a2de-29066851ec1c	41ff54cc-6f6b-4366-a49d-4dc4378f813a	dc59d83b-1dec-4f60-8cde-4826031c7195	opening_stock	60.000	0.00	0.00	\N	\N	رصيد افتتاحي	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-18 19:59:06.488294+00
53a620a0-b534-474e-8d6c-09932b880378	2f3e5183-d945-419c-aba7-63cde2d18b66	dc59d83b-1dec-4f60-8cde-4826031c7195	sale	1.000	0.00	75.00	c95cc1a0-f6ed-4990-9837-99f0ac15effc	sale	\N	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-22 13:32:01.704837+00
4b2e21fd-9682-4a71-8e0d-88e39e12460f	9032580b-60a6-4db2-a363-ab3c8ecdaa84	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:32:05.070434+00
b0c4770d-964a-4449-aebc-af3db2c98857	9cce9245-5bbe-42c5-b6b2-f4fc4e5ec8e3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	44.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:32:53.635353+00
fb233ff7-6acc-4843-9d0e-0ca13db7d66f	9e79c962-150d-4880-8b93-31cb260ba8fd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:47:10.139285+00
60654099-2243-4243-9aca-313da9696b0a	fd5f3438-24bf-427a-9f05-b93ef2e6e983	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:03:08.985245+00
02b3dfd4-e2bc-415e-8bd7-28bee4e12186	92d13d9b-4fda-4f70-b4a2-158fdac5eb08	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:17:43.171042+00
7cbdbec6-1abc-438c-a314-fd10e3d8206b	11be2aad-959d-44fa-b21d-0adf241669ac	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:25:10.832904+00
5ba0e98c-d922-4a59-85e9-6af546d8ab3b	c3c27efc-96b1-4a23-bdab-93e04c7e9940	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:17:38.832918+00
c8a33fdb-a15d-4523-a640-91242764ba85	1db05d34-4a6f-4897-9a7c-619aa7351406	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:20:36.337345+00
1f7bfcec-154c-45ee-8917-168242daaa39	9c6b491e-0f64-46ba-983d-e9512587b4c1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	23.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:20:46.241985+00
38c9143d-c155-47f0-8e8c-e75a55a5688b	da12de49-d1d6-4554-b5ae-43e76227ca90	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:28:16.681972+00
50423a9c-93b3-47ad-b4e2-82b9e701f2f8	5b7abdfc-f2bb-4d1e-905a-fd54be99c46f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:13:38.729001+00
da9c8c85-1ef4-4c8b-a72b-1eef7258dc59	fb0d86fd-7ffc-4290-831b-19ac15f5c448	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	52.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:13:58.511537+00
496f7a20-8746-445f-a287-f3945b368deb	36a71af5-edd7-4e4c-9b77-fb2b37c53cf8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	137.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:16:21.417557+00
edcf0e88-2f32-4f3d-b290-ee331d835363	edf6547d-ee07-419d-a822-18de5c4ac63d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	1340.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:30:34.825269+00
b86ab42a-e144-49c3-bf95-a231e4b44095	999b9700-0527-4039-8d38-cd9b484ccd46	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	309.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:36:57.544822+00
362d42bb-3fd9-4972-a80b-db731801295c	b4792075-b071-4390-8183-b9615ecba622	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:12:03.4583+00
24b8c129-5270-4eb2-879d-f3fddf22d14d	aeb7ad06-7e28-4732-b145-cfef45c9521d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:24:16.162857+00
dc67a7d0-8169-4d08-a79f-599231d5c680	a268d0b4-97d9-4f49-99c3-19491bc9f078	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	86.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:40:23.355651+00
dbd5be01-535d-45e0-9647-f304b8a75922	0ee2584f-6386-447a-898f-27cd91fa584d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 12:29:25.664424+00
fa631af1-c298-49c1-b6de-98ac689288b7	e8064580-f5a5-42d8-a083-bd3e3d3f4481	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:16:44.181957+00
b5916a24-d0b0-4a81-90e1-d1ab482801ed	3fd2efb0-19b6-470f-9092-dd0823473c82	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:20:50.823956+00
67dfba86-1874-4376-9464-262432e73a1b	98f52e8f-3949-4c87-a044-f01790695506	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	57.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:12:05.667534+00
a649b148-de13-4227-9288-b9a514ae9e8e	c7423fe8-0195-4f61-894f-5692b13601c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	114.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:16:30.901973+00
c467b4c7-27ae-46ba-9c6e-18406c11e099	0a23f4fe-5242-49be-8b49-2618e47be277	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	79.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:19:09.065534+00
43e45241-98a9-40ef-9f1b-a4cf233a6906	c80f86d8-cb80-465f-ad00-b3583f1c4c40	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	92.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:23:00.269206+00
07c1e2a1-960b-4f7b-9f5e-4a73ed7335e5	c5f83958-3304-4314-a56f-7fe15431bc7b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	92.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:28:02.69478+00
2defc5b7-88b4-412f-84a9-dc9e379d3c26	69c84270-5d73-406f-a0f6-4509aa6ffd14	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	244.000	0.00	0.00	\N	\N	رصيد افتتاحي	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-04-13 13:51:00.87712+00
19fa7b2e-6055-4f16-bbf2-d5c0148c96ad	c80f86d8-cb80-465f-ad00-b3583f1c4c40	dc59d83b-1dec-4f60-8cde-4826031c7195	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-13 16:00:14.029736+00
46449811-8a5f-4571-80d2-2a5ba531f063	e945e2a1-188f-4855-88be-ea4cb303aaa5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-13 18:01:01.076025+00
582afa59-973b-4b19-8ffe-ced0522b7312	28ef30d2-959f-470e-868c-6d1b638cfeb1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:28:09.929078+00
961b1cec-9ed7-4562-a113-60b53eea2ea9	1ce42d75-79fd-472f-8613-41af9ac5559c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	107.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-17 11:33:05.253672+00
dad3e4ac-ac9f-435f-b179-215812b6d881	41ff54cc-6f6b-4366-a49d-4dc4378f813a	dc59d83b-1dec-4f60-8cde-4826031c7195	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-18 19:55:24.436252+00
678439b8-08dd-40ae-bcbc-a931041e1607	12d44342-c0ea-4093-8344-8a3fe616b946	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:34:28.15499+00
0efe0f5e-3a8e-47f1-b8ee-332725a43495	f9bb2b67-91f9-4176-a285-ad980d259775	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:06:33.465182+00
4766c931-2012-4314-b910-af7ec3d6bb8f	f612c100-6427-4c00-b507-11311a312843	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:14:59.16042+00
444b1ffb-b44b-4e54-8a46-6ed193777f80	19ad03e8-e71e-4be7-90ef-08bd6572f06f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:15:24.218105+00
345e1343-9b0f-44f1-ad6d-62ed8216ec2a	b262a202-b104-436c-961b-749be916955c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:22:34.448541+00
51776415-53fd-422f-a977-c831d2c0596d	b262a202-b104-436c-961b-749be916955c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	10.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:23:12.252581+00
1846f2c3-f5e6-44bf-a5e0-160a8e64fdff	da76bac1-e445-4b78-881d-49e35771b067	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:26:45.131212+00
ec2ef859-29c0-4cb4-94ad-d0a1469c549f	68a41885-4ec7-40c5-a891-c45002ddecb9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:40:31.05596+00
fab67af8-3ada-421e-bac5-7f29649338b6	4179d2bc-a6da-476b-aa18-1d919852e3c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:50:36.896211+00
0a298551-6010-4393-928b-c80b890fb1b6	f0b655f9-def6-4462-9d88-7a334725016e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 15:15:46.489644+00
48f53d75-e4d9-4558-8734-a6e292433241	e7640605-a1fb-4ed5-96de-952bdfd35d01	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 15:23:23.061167+00
07651833-e6ba-4204-9ffe-d94a55d77d1a	2f9198ab-da9a-4a8a-9746-d9e451336cf9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 16:20:54.292438+00
65209dbb-ea61-4705-adc8-9aecdad677f8	8e3760bd-0096-493b-9e0e-e96262b63371	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:17:54.398459+00
367dcec1-2690-4211-9692-7cd4eb02346f	55cc2075-bfe4-4613-91de-05535390b28a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-11 16:22:26.44967+00
e8f7c604-bf2c-417e-837c-487bbe03d733	ba67d7df-9487-4059-996b-a0ce57ed1f1d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 16:25:43.362168+00
1311c56e-1ce9-477d-9139-4fb5b152e51b	44357f2a-f7f8-441c-bdd8-f9f1af4487a8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:14:14.618866+00
dd8ac672-39e1-426c-8f30-d80046eb15cc	9c2ccb88-40d9-47de-9b2b-480d82c50e7c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	110.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:19:10.210179+00
bcd5a609-79e1-49a8-9298-8e1488646aed	e37b5235-d605-445d-93ca-4b6af20f76ac	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	331.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:26:11.010891+00
c3bd2f76-546b-443c-865f-7ae19a25fd76	edf6547d-ee07-419d-a822-18de5c4ac63d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1340.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:28:35.121358+00
d1497325-6f38-41aa-bac1-7706fde97f97	2bd5ddec-5128-4551-a96d-f826eaaec686	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	556.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:30:02.713535+00
7d7d5a2a-7ada-4de0-926a-8af9d8918639	add73888-1d66-435e-bdc6-31e24d57718a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	41.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:42:16.715168+00
e804f5fc-6be1-48e5-b36f-299f0d37e271	26988569-34c5-4e63-884c-e618d9c3820a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:47:13.31529+00
b926abe6-e726-492a-be4e-a7c01d950b3b	9b9ca756-26a9-4567-970d-715c339b6d48	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:19:55.612049+00
133ab370-4d4d-447d-b61f-e0580e91248b	e4028986-2cb3-40e0-84e7-6e167bac110d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	127.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:29:12.374909+00
53baaa69-4d43-4c2a-b046-2f6eebb79b84	caef7973-c811-4391-bc0d-07a8f5ef6087	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	63.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:39:49.62704+00
faaa695c-4e14-4c85-8f85-502c376cdece	1ac52e2c-94b4-473a-8bab-7bacc1ac2673	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	45.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:21:01.573237+00
72544ea9-0e73-4a05-9039-2db01ebb25f4	fc34d4b3-7215-42ae-9c64-eb7d8b003cda	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:35:06.214773+00
d30f6395-a01f-45dc-8762-38b717eaecc5	d87c198f-b9e4-47b3-be1d-ca135da5243a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:44:40.359399+00
a5b0ccf7-6221-415c-a542-c8483771e4dc	e50f6cef-cbd4-4458-97fc-52eb563bc3c5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:44:54.51372+00
ba74a92e-440d-4166-8c65-b364e5cf67ff	19f9e986-7a6d-43b3-99c8-424277fb7b01	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:45:02.498666+00
814bbba8-ab7d-43b8-8532-c690ca1d48f5	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	return_in	1.000	0.00	150.00	1ff4ccc4-5613-4a7a-ba95-5ac080aeef04	return	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:02:35.285845+00
fc43ca19-c4e4-49bb-b4e7-1f4a962b2745	2eeb97e3-ce9d-4ced-ba71-4de536b02669	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:41:21.686858+00
ebc997a0-d689-443e-9d63-e9b87a6c979a	a87a4c13-b30d-40ac-bffc-38f73ef2f141	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 13:42:54.450703+00
d34c4de3-b9f7-4b6b-86d2-e50701be33d2	69eb82c2-d146-45da-947e-df7d9c7e91c6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:02:21.751613+00
d0d0f805-2b73-4b47-8527-022fd73c1310	b262a202-b104-436c-961b-749be916955c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:21:50.639317+00
e627f389-19ca-45fa-8a32-3e32df09fd1a	7b0b59ed-bf39-46a2-8e35-e974084cb919	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 14:49:05.400794+00
a6b16799-0572-4813-8356-dfd6d14b751b	0d71a0fc-2f22-4bef-9038-6b30deeb267a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 15:14:30.974116+00
f7cde032-3b86-470f-b31c-da3e8934e022	920dd176-0c14-4215-87bd-0af9eb30cbf0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-22 16:16:33.006462+00
8980dab1-f410-48b7-b3b0-0208becb7bbb	0a5287eb-3d47-4451-ac01-b6d97287ada1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	50.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:14:38.329823+00
29a4052f-d5b4-48f1-be53-d298c8b02630	36a71af5-edd7-4e4c-9b77-fb2b37c53cf8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	194.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:16:39.580464+00
a59d2ed2-bf85-4de5-a476-54d7933ad9df	731e6d42-8a1f-466f-b80e-97784861e90c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	868.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:20:57.697438+00
022256d9-fae2-489e-959b-9515da3ce035	6972c97c-fdb0-4a9b-b563-06ec0ac883c3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	352.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:29:26.489743+00
fcc3b277-74fa-46bc-9c14-ee2ec2a4dbb3	bc621655-d111-43be-b3a7-b860e8e487c7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1340.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:31:34.520646+00
6cdab186-be59-4d25-85ba-b142ebe22da7	c5b2afd8-2550-4d3b-8a3d-3ff6bef14544	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	254.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:33:37.872399+00
feb0ca95-4c0d-4879-8960-b777317ec431	41fe92be-9e23-406a-90bc-04734c30a5a9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	126.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:39:10.233053+00
77bd172a-eb4a-4dbe-984b-3080afe3373d	9995e6c2-e656-4f06-b7d1-938574985a22	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:48:01.401517+00
84760fea-ee44-41d4-9e2f-dca0489c278f	12496280-b9bd-43e5-882b-8cad7ac41d14	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:14:36.058196+00
8f94389b-c7ef-41be-b79e-2edd12e14888	02c411bc-4988-4422-bc60-fa2acc687b5c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:37:31.994056+00
f441ff32-fafe-43f8-8fc9-f718707f1015	accc59f1-42a1-4501-b345-658bcec88377	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	86.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:40:12.915084+00
a67ac65f-88ce-439a-9382-f2cd3d1172e8	1ac52e2c-94b4-473a-8bab-7bacc1ac2673	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	11.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:20:56.48548+00
00c05a8f-5360-47e4-916b-8e9bbb38e150	0d2c4abe-8714-4cea-b01e-967e024ad4cb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:45:11.965715+00
9d56d5c4-c087-4113-a802-a73d8b049f90	78539233-0e35-4584-8a63-835c6f128067	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	35.00	a5d2f6e4-34ea-46ae-a671-2a779e4d8cc5	sale	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 14:15:34.328059+00
fd39d265-ae55-4b89-9910-73098309d7a6	e660c870-680d-4c0d-ac35-ad6c4e0740a6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	4.000	0.00	37.50	8f3d7790-b687-4008-a659-9876db7ff7f7	sale	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 19:24:13.33222+00
2f30082f-fd52-4b69-8391-dc00d3450294	fc080463-994d-4137-87fb-c0544751b8ac	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	488.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:15:01.353809+00
aa501664-4970-458f-be3e-bc7e5a277ace	6c53ac78-8c67-4b7d-9417-fe21bb9cad2c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	137.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:16:14.610875+00
dc434a56-3773-4903-bb2c-8ea0f9936f72	129089d7-95d4-42cc-94ef-2e54da0be9f1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	374.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:29:05.54503+00
3bff4225-4198-4044-a079-593f0f2be25d	edf6547d-ee07-419d-a822-18de5c4ac63d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	605.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:30:40.842017+00
9946bcb6-5c6e-4dc3-bd55-d20fd773b2ee	567716d2-0cca-4d9d-a291-f5e070c5b0a0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	36.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:34:48.108055+00
482efc8e-e4e8-4d18-b906-1d5aa20ed413	935326ee-fa2f-4434-b571-471f0e996f35	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:35:38.003254+00
4316b8ce-8e83-49a0-8def-bd4f639ea8d8	70c6a2cb-6643-4373-9e08-da46d851fe2e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	153.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:41:06.320961+00
0a3c0388-a0d1-4b3d-92a5-bb11a94c966a	7ee0b4c1-23e9-4783-b9fe-f148c7606066	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:16:41.04217+00
2806121e-57b7-492b-92e4-b4ecf84e471b	31147ad9-de4f-4ee1-aaa2-4f86cce7963a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:22:12.051489+00
96e528f4-a536-4db1-b951-2ed715b11c16	9ad31176-b502-43b7-b47a-57cdaa1e623f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:26:15.165654+00
a16d8173-46fe-402c-9bd9-8cdaf2a86a07	2d4491e6-7f57-4c93-a720-a7be5d68b4b9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:35:46.714714+00
f7ac4bb9-184c-4c40-a71d-442b1c6db759	20076dde-b7fc-463a-af90-381696236d45	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:36:41.291781+00
fb64e317-9374-4818-a032-8eb917caa77b	a268d0b4-97d9-4f49-99c3-19491bc9f078	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	27.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:40:38.769726+00
fca4a6cb-d2f8-4e1d-b5ac-13483385c0af	ef7073ab-4d25-442d-8505-6eacd9886f13	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 12:25:55.865939+00
1bd2c852-c888-43a0-8f08-d1e982fe1567	2c4c4d5b-db29-4f28-b53e-bb2aaecab809	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 12:28:21.469292+00
07cb0cc4-307a-4d3b-9a65-062b9a5c1006	49f4d737-1d66-4bbf-8011-44949b013133	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	230.00	bb784b10-07c3-4a93-b36e-eb72a3c50a82	sale	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 16:49:50.980428+00
580d14d7-5419-4731-9e43-0c2358d9b03b	ae6ca5a9-4e53-4085-b698-2f78efea5482	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 17:28:07.345723+00
e11d9996-fef6-4aac-aea2-258a3333fc6e	fbc41295-0338-4e49-b61e-79e99e9f5667	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:07:58.889681+00
4be726f1-5c10-4495-b73a-d266f71270db	65bfbf00-27bf-4323-ab25-1ccd994cddc4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:26:57.090143+00
5b53e932-ec67-44de-9ffe-e2624bfa8d14	cd3b2528-421e-4761-b84e-90651f4cfd3f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:37:52.812383+00
613a5e29-53d3-4a4a-b8c7-eb29ec2da25f	a268d0b4-97d9-4f49-99c3-19491bc9f078	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	86.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:39:41.225696+00
695b5b1a-3a5e-44ed-8f52-594836731e72	d327c0dd-7a93-4935-bb1b-30c523147993	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-11 18:40:51.450757+00
6e5484cc-5ad5-4f3f-8e66-14cbac6446c3	189b8e6e-6161-40ba-ab29-98d73b32232e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	100.00	68de17de-7680-4292-9603-8cacab936e2d	sale	\N	ee31f134-c885-42b4-950b-53284e09a25b	2026-04-15 19:33:10.850009+00
ea5fa40f-f7e8-4e96-b5ec-d78bd7e870b6	1ac52e2c-94b4-473a-8bab-7bacc1ac2673	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:17:05.789428+00
8189c6de-da5f-4add-b452-19978320dafe	18988ac3-83bf-4b07-9bf3-f31dc4810704	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:48:21.584603+00
c801c317-8553-448e-871f-a0a3609b1919	ae78cb21-9bf8-441a-a101-6be57eb4f2c0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:15:39.57418+00
e380bd1e-083e-4a36-8e96-190c3c574931	bf14d1ca-8f4d-4a9f-a8ff-435203615af8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	32.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:37:22.250096+00
4fc9e0dd-bf60-4fa7-aac1-1006af3be4b9	72635b19-9fcc-4fd6-9ada-b9cf33bb50a0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:26:18.559835+00
3d8de866-c271-4278-bfc0-6c2b2cc9a7fa	d60e69da-7058-429d-8890-144bf710100b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:51:12.015215+00
0f7072ac-9f84-4c72-be73-d931d966135f	6cf339ab-5c51-4d0c-a096-98aa08096dbb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	67.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 13:57:19.696418+00
d26dfcc6-c299-4e38-9667-6e749a37d97d	ff6f769c-0bfb-49fc-86cf-e73805d51892	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:15:12.949359+00
386a248e-0895-4053-b182-1d6585c67ebc	8bfd6725-3128-4c54-b869-fc2a959df714	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	206.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:45:19.925962+00
cce1ae3b-4785-476f-aa60-518402c8de12	803dc7a3-eb72-458f-82eb-a1bed2a9157c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	51.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:17:58.734334+00
997b9c2d-bef1-4df1-a244-dd772464b984	39f5ed3b-7c34-4b75-9331-32a95c7d8b81	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:22:52.047034+00
84e9e4ef-b778-433c-8109-0dba88f9a983	a59c2e11-fed2-4972-a7e5-bc34fd5266fd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:49:10.02521+00
bd85eb42-5054-4bdf-913d-a09316c1ae1d	813e8a9d-af7f-496c-80da-0eab496e15df	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:03:24.842554+00
a19c1b2c-23e5-4ba4-926d-889a7d857ad5	244e72f6-2f15-49f4-8526-3b485ebb345b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	0.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:08:42.841091+00
c29b1158-2cd2-4eb3-baee-3f880c115025	879040b7-642e-443d-a467-cb4a3cbc5bc3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:11:22.777544+00
f7cd5f7d-bf51-4410-acc1-8ec6a0169687	8cf7eef1-0a73-491c-b6cc-8222f3c45595	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	69.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:17:47.362471+00
0cf85c63-e720-404e-892b-bb4bf81fd470	4c7f2b6e-8a67-489f-ad91-257ba78a7f51	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	232.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:23:17.872153+00
7d7c866b-05b0-42fb-950b-1acd0e30acde	4b596a39-71ad-4be0-adcb-82637141438e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	412.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:27:59.710351+00
18d624ad-0a48-4c24-a7b4-1d39ac69f2e1	446e88dc-63ad-49b3-9018-6042e55df88e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	326.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:34:56.660957+00
fa4d075a-4060-4c76-8979-3108fd2e9c67	13187950-a7ec-4e6c-a0e1-a08dbb28666a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:50:04.927093+00
c9c8db76-24f7-4435-9dc2-3ab36dc5ad72	ae005153-de66-49ed-b132-23434ecacf5c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:39:21.792751+00
7c855547-8e1b-4798-a916-46e28f4ad470	f9e48d97-167b-443e-bb9f-0dcc047bad58	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	139.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:44:36.20666+00
9c468c2c-eb7b-4322-83ba-b0d70a3f11fb	37ee2418-56bb-4d8e-b0ec-fe9ffb1fc333	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	6.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:46:39.397786+00
0bdd940e-7171-49d7-9949-1e3a4d925c50	61a43033-a203-475e-bfc2-c843163a2756	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:21:10.148171+00
c760cbc4-5bda-406f-80b3-f73d7938fa20	39f5ed3b-7c34-4b75-9331-32a95c7d8b81	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:23:10.788161+00
ca43735c-9786-4daa-a7a9-2345a5706067	05772215-09f1-41a4-91b3-e56c69ec58db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	47.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:46:13.972765+00
8ce2aca3-17a2-4d97-96b6-1dc3773e7caa	871b0c43-957e-4eb5-b5f0-4609014c1885	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:04:22.448146+00
8fbd9469-2ddf-482b-805e-36e44e80c677	6c1a7601-4298-4f3f-be83-c3e4abdedaf4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	31.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:33:16.195772+00
8d138d3e-3e75-4f29-9d1a-49fc7acc9b22	70afd455-12ab-4f85-9e1a-5868e01b1511	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1128.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:35:35.814045+00
1a512399-adda-4187-9be4-d14385847fa0	b3790156-be36-4d7a-9bb2-cf9ebe405cad	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:44:49.241027+00
3f16d2be-1588-423e-9f49-d1cb3a08327b	67e52b55-eb97-4426-bf88-5fc459bf9141	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	38.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 17:35:45.201355+00
7b493e18-5308-49bd-a356-615b2954fc0c	0fd12267-532b-4474-b66e-a1ffa378a6c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	27.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:43:13.198529+00
baf0c5fe-7ecc-49fa-9913-beaacab47d2e	5d31eb67-6989-4113-8936-43dc6ae1a959	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	72.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:45:43.379902+00
0284895e-da32-423e-b135-dc6e99817dc6	c8dbcca5-dcae-485a-aeae-deea53ae1586	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:54:00.900222+00
4adb9d75-3c3d-47ed-95d3-54f01056aa52	745efab6-e9cb-4323-8d17-a2fe2c555010	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	69.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:57:00.885275+00
45453b7b-b461-4dcd-92a5-dafa8a78f107	fffc498b-ab89-446f-bf7e-43ad31c86527	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:21:32.084476+00
3afe2f67-21ec-4301-9aba-3d5eaf95115b	6c38825d-4c46-4892-a768-255e236c306b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:22:22.350747+00
06bb159b-60ad-4eb8-8753-a3bb4efa758b	ca20b458-786d-4bed-b94a-a91b10a6c621	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	42.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:24:02.420736+00
c0b0bfa1-a2f2-4f57-a146-e9a20f8b5d3c	d75fcff2-ef64-48b3-9cd8-e06d40e3a399	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:08:58.300597+00
926df394-24da-461f-b29a-78690705ce3f	40cdebca-7a06-49c2-a5fa-850250936c54	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	499.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:34:36.039752+00
e6fbd7e5-2e82-462b-b775-9179681141ea	37ee2418-56bb-4d8e-b0ec-fe9ffb1fc333	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:45:01.939286+00
a98f3e3d-02f6-4eae-9b6e-6ce3dbbfadbd	85d12824-8b4e-4805-a439-94123944367c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	241.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 14:48:24.822445+00
36b974c2-93b9-4194-be0b-08e1ebeac630	39f5ed3b-7c34-4b75-9331-32a95c7d8b81	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_out	15.000	0.00	0.00	\N	\N	تصحيح جرد	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:23:07.861141+00
44600252-6c53-4415-8c6c-bb5301b11eae	92518465-ec8a-4c4c-8fa9-d7517296ae04	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 15:48:00.267693+00
d46c54c6-c8b5-471c-87f2-922923a82b4e	3614e70f-96f3-4b69-9104-188a0574085d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	31.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:06:37.38487+00
ac14e833-1aa3-4211-b285-6a73d336d7cf	dc312bb2-984d-4c5b-8f9d-f5a0a165eb78	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:21:58.068724+00
78864f7a-d02b-4723-a0b4-94259cf6e066	811c48aa-84b6-4bed-9771-3e6dd162e9a6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	38.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:31:15.20919+00
40c9ec4e-9d0f-4f70-b99d-034e2f7c5bb3	029b8c6c-707a-49a1-be04-96aea6010416	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:46:21.06607+00
6b781c40-5b87-4a64-998d-ed739466be32	fb178da9-8ff8-4431-9e53-ff8773d684ad	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:47:41.450671+00
226456f0-b58a-4ddc-8cd9-48b42d03736d	adc37b18-86dc-4fbb-bea1-856a682a5095	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:07:32.701407+00
1f1e605b-2d6e-47a6-b869-c346b4e94c6a	b419fb16-6f5d-478c-8ce4-c19a2e25f8c2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:10:51.304031+00
94f3a1b7-278c-4e66-a955-127e8c4c1355	8816fa99-fe08-4d0b-ae95-19558eb03a22	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	51.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:19:39.424003+00
42ccb018-5535-4713-ae9f-55ada2a77b9f	830adebb-e1c8-4e24-86fe-26eda9b4fbc7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	60.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:31:22.826543+00
b8ce5c52-6b61-4174-b114-7efebfe9af1b	76974cd1-2978-4467-ae5a-b558aa71c242	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	121.000	0.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 16:34:50.039424+00
729b96e9-fbfd-4d30-ab3c-8c9e71471891	96057283-03bb-4f16-a011-5b4e00628633	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	48.00	0.00	\N	\N	رصيد افتتاحي	6a11d77b-24cc-577e-9ec3-4b0088eb7585	2026-04-12 17:42:34.395904+00
f46e0dac-45f8-4a34-8609-518cb5d1a58b	c8b78e53-a457-4b32-8897-c449f3fe1e4f	59a2b8d7-e26b-4979-ae0e-3984f1b711b2	purchase	5.000	10.00	0.00	362b6e0d-4f17-4662-875b-1e63005a2d44	purchase	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-30 04:16:18.96905+00
\.


--
-- Data for Name: store_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store_settings (key, value, updated_at) FROM stdin;
printer	NPIEB8E9E (HP LaserJet E50145)	2026-03-25 18:13:41.323568+00
low_stock_threshold	5	2026-03-25 18:13:41.323568+00
product_options_sizes	["1", "1 * 0", "1 * 1", "1 * 1 بوصة", "1 * 1/2 بوصة", "1 * 3", "1 * 3/4 بوصة", "1 1/2 بوصة", "1 بوصة", "1 سم", "1 متر", "1.5", "1.5 * 1 بوصة", "1.5 * 3/4 بوصة", "1.5 بوصة", "1.5 سم", "1.5 متر", "1/2", "1/2 * 1/2 بوصة", "1/2 * 3/4 بوصة", "1/2 بوصة", "1/4 (ربع)", "1/8 (ثمن)", "10 * 10 سم", "10 سم", "10*10", "10*10 سم", "15 * 15 سم", "15*15", "15*15 سم", "2", "2 * 1", "2 * 1 بوصة", "2 * 1.5 بوصة", "2 * 3", "2 1/2 بوصة", "2 بوصة", "2 متر", "2/2 بوصة", "2/3 بوصة", "20 * 20 سم", "20 سم", "20*20", "20*20 سم", "3 بوصة", "3 بوصة (75 مم)", "3 لينيا", "3 متر", "3.5", "3/4", "3/4 * 1/2", "3/4 * 1/2 بوصة", "3/4 * 3/4 بوصة", "3/4 بوصة", "3/4 صغير", "3/4 كبير", "3/5", "3/8 * 3/8", "3/8 بوصة", "30 سم", "4 بوصة", "40 سم", "5 * 0", "5 * 1", "5 * 3", "5 سم", "50 سم", "6 بوصة", "60 سم", "70 سم", "75 مم", "80 سم", "90 سم", "small", "بوش", "ثمن كيلو", "جرار", "حرف L", "خشن", "ربع كيلو", "صغير", "طويل", "عادي", "عريض", "عريض صغير", "عريض كبير", "عريضة", "غير محدد", "قياسي", "كامل", "كبير", "كبيرة", "محمل", "مرحلة 1", "مرحلة 2", "مرحلة 3", "مرحلة 4", "نص كيلو", "وسط"]	2026-03-25 18:32:34.291009+00
product_options_companies	["ADH", "AG", "AG (يوسف)", "BG", "HANMIX", "OM تركي", "PFS", "PG", "PG (يوسف)", "PG Pluse (أدهم)", "PVS", "أدهم", "ألما", "أنس", "إيطالي", "إيطالي (يوسف)", "إينوفا", "احمد حماية الله", "ادهم", "ارساني", "الكوك", "الكوك - فايف ستار", "الكوك وأدهم", "المصرية الالمانية", "المنبع", "النورس", "اوزو", "ايفون", "بلال", "بي أر", "بي ار", "تركي", "ترنتي", "تورو", "جروهي الكوك", "جوبل (أدهم)", "جولد", "جولدن ارو", "رانك", "روفا", "روك", "روما", "روما أدهم", "ريبلان", "سالمكو (أدهم)", "سالمكو (عمار)", "سالمكو (يوسف)", "سالمكو أدهم", "ساليمكو", "ساليمكو أدهم", "سان ارساني يوسف", "ستار", "سكاي", "سما", "سمارت", "سنبرس", "سوبر", "سوبر ستار", "سولو", "شاور ست", "شيلد", "شيلد (عمار)", "صيني", "طيبة", "عام", "عمار", "عمر", "عمر واللو", "عمر وميدو", "غير محدد", "فايف ستار", "فولكانو", "فيدمار", "فيرست", "كولمان", "كيس ستار أدهم", "كيسل", "كيلوباترا", "لافينا", "لومي", "ماتدور", "ماست", "مكة", "نواكل", "نوفا تركي", "نيو سيجما", "هاند شاور", "يوسف", "يوسف (AM)", "يوسف (MK)", "يوسف (لومي)", "يوسف - السهم الذهبي", "يوسف - الصقر", "يوسف - اللؤلؤ", "يوسف - تاتش لومي", "يوسف - ريباني", "يوسف - ساليمكو", "يوسف - سبانش", "يوسف - لازا", "يوسف - لافنا", "يوسف - نيو سيجما", "يوسف والكوك"]	2026-03-25 18:32:34.291009+00
product_options_materials	["plastic", "ألومنيوم", "إستانلس", "استانلس", "استانلس ستيل", "بلاستيك", "بلاستيك شفاف", "بلاستيك/نحاس", "بولي", "بولي بروبلين", "بي في سي", "تفلون", "حديد", "حراري", "ستانلس", "ستانلس إيطالي", "سيليكون", "عادي", "كاوتش", "كربون مسمط", "كربون نشط", "كروم", "لاصق", "لزق 900 بارد", "لزق 914 حار", "محمل", "معدن", "ميمبرين", "نحاس", "نحاس كروم", "نحاس محمل", "نحاس مطلي", "نحاس نيكل", "نحاس وبلاستيك", "نحاس/بلاستيك", "نيكل", "نيكل محمل", "يو بي في سي"]	2026-03-25 18:32:34.291009+00
product_options_units	["قطعة", "كيلو", "ماسورة", "متر", "طقم", "علبة", "كرتونة"]	2026-03-25 18:32:34.291009+00
store_name	شركة المصرية الالمانية	2026-03-26 04:33:22.147637+00
store_address		2026-03-26 04:33:22.147637+00
currency	جنيه مصري	2026-03-26 04:33:22.147637+00
logo_url	https://i.ibb.co/Dgv4QwTZ/image.png	2026-03-29 12:09:20.072901+00
store_phone	01114439625	2026-03-30 13:20:25.505404+00
paper_size	"A4"	2026-04-03 18:34:46.11981+00
contact_phones	[{"name": "م/مؤمن", "phone": "01065324979"}, {"name": "   م/محمد", "phone": "01202456394"}, {"name": "   م/مصطفى", "phone": "01145838183"}]	2026-04-04 11:46:40.165363+00
\.


--
-- Data for Name: subcategories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subcategories (id, category_id, name, created_at) FROM stdin;
d17128f8-94aa-54ce-87d8-4dc515f98bf8	4caac7b8-13eb-53e5-a4d7-c28059165c3b	محابس وحنفيات	2026-03-25 18:13:41.323568+00
7f15ec9b-720f-580d-ad54-61fcb04a20d9	4caac7b8-13eb-53e5-a4d7-c28059165c3b	استليسات	2026-03-25 18:13:41.323568+00
7f47135b-3fea-5482-90d6-acef9402708e	4caac7b8-13eb-53e5-a4d7-c28059165c3b	محابس بالأكور وبلية	2026-03-25 18:13:41.323568+00
903c8f75-9786-51d1-956e-f481e1dbf84f	4caac7b8-13eb-53e5-a4d7-c28059165c3b	اوكر	2026-03-25 18:13:41.323568+00
eac36a6f-f7ef-5e8e-9ca9-443292af7e18	4caac7b8-13eb-53e5-a4d7-c28059165c3b	نبل	2026-03-25 18:13:41.323568+00
e2dfb819-1be4-50bd-8612-e411aaa719d5	4caac7b8-13eb-53e5-a4d7-c28059165c3b	لواكير	2026-03-25 18:13:41.323568+00
8a44ea94-e593-5cc1-bce2-d57efdfa53f3	4caac7b8-13eb-53e5-a4d7-c28059165c3b	جلب	2026-03-25 18:13:41.323568+00
de8ac890-fee4-5705-8bd1-25c72f48474c	4caac7b8-13eb-53e5-a4d7-c28059165c3b	قلوب وجلب تطويل	2026-03-25 18:13:41.323568+00
f170e76b-4135-5781-b898-91e1259af14f	4caac7b8-13eb-53e5-a4d7-c28059165c3b	سوست	2026-03-25 18:13:41.323568+00
3990e818-7790-55bf-9cf9-6a7e45c45026	4caac7b8-13eb-53e5-a4d7-c28059165c3b	نحاسات	2026-03-25 18:13:41.323568+00
0a625299-9939-57bf-9214-75c4fa91e993	8dc1113a-8ef3-56e8-8db4-44dea8b73394	لزق	2026-03-25 18:13:41.323568+00
3eafb215-ee16-58c9-b9ec-7033aa951137	8dc1113a-8ef3-56e8-8db4-44dea8b73394	تفلون	2026-03-25 18:13:41.323568+00
7b07a8a7-291e-504c-82ec-e7b14467ff8c	8dc1113a-8ef3-56e8-8db4-44dea8b73394	شكرتون	2026-03-25 18:13:41.323568+00
939f4e0e-dd51-54d3-9737-dfa50e8363e7	e11d248d-8083-5c8a-bd3d-93737603b2ce	غطيان	2026-03-25 18:13:41.323568+00
b12ed220-d73c-519f-9a7d-ecb58dd62515	e11d248d-8083-5c8a-bd3d-93737603b2ce	قفزان	2026-03-25 18:13:41.323568+00
df634c7a-d345-505a-82a4-2bdc2e899a7b	e11d248d-8083-5c8a-bd3d-93737603b2ce	مانيجه	2026-03-25 18:13:41.323568+00
69f9914c-e165-5167-a85b-6ba46173bba3	eec4c28c-ac4c-5e78-9157-be2158226a37	لوازم ماكينه	2026-03-25 18:13:41.323568+00
0fe9fe9a-ca99-5bac-85da-bf506d92be69	eec4c28c-ac4c-5e78-9157-be2158226a37	ماكينه	2026-03-25 18:13:41.323568+00
daf8935a-6a30-5667-ac81-f4a398cbc305	becef785-9b1d-5b14-91b4-bebe341c2642	لوازم اطقم صيني	2026-03-25 18:13:41.323568+00
8ee8e20b-ffb9-5b16-96db-954194f2a369	becef785-9b1d-5b14-91b4-bebe341c2642	اطقم صيني	2026-03-25 18:13:41.323568+00
a77bbc03-437a-5071-b287-7a1cb6a9ac77	becef785-9b1d-5b14-91b4-bebe341c2642	سديلي	2026-03-25 18:13:41.323568+00
f4d19c5a-646c-5976-b7b8-0d06ce75be1c	0c34aec3-607f-51b8-b032-2e83ada6c584	لوازم فلاتر	2026-03-25 18:13:41.323568+00
724f3e54-4bb3-5838-9399-a9c172df621c	0c34aec3-607f-51b8-b032-2e83ada6c584	فلاتر	2026-03-25 18:13:41.323568+00
ac497863-17f1-5a7a-8ac1-274f86b4001b	5bf1090c-ae87-5030-98a7-2ed1cc793377	لوازم مواتير	2026-03-25 18:13:41.323568+00
5b970d56-5ee8-594e-bcde-6ce50c1d47c3	5bf1090c-ae87-5030-98a7-2ed1cc793377	مواتير	2026-03-25 18:13:41.323568+00
917ab77a-c6d2-5744-9b58-5e376018202d	71396019-5291-58c6-99a2-eb79cc120767	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
0cd5f633-608f-584a-bd8b-37201f028e03	71396019-5291-58c6-99a2-eb79cc120767	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
9d9e6fe3-d79d-5cd8-80c9-612781140dcc	71396019-5291-58c6-99a2-eb79cc120767	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
12b98edc-0ae6-5290-876e-07df9ac8b4ba	71396019-5291-58c6-99a2-eb79cc120767	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
385a1eac-0712-55fc-b124-bccd6e111001	71396019-5291-58c6-99a2-eb79cc120767	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
e41a3aa2-7c50-5b84-8c28-a88c01153dcb	71396019-5291-58c6-99a2-eb79cc120767	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
502bead9-694f-5ef0-af7c-5f8eaae920f9	71396019-5291-58c6-99a2-eb79cc120767	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
100e740c-555c-5c4c-9cf7-fbd101f0f41e	71396019-5291-58c6-99a2-eb79cc120767	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
d1582c83-ec85-5455-9447-b8acbb88c6ed	71396019-5291-58c6-99a2-eb79cc120767	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
c1716fb2-d12e-5561-8ac1-a530beaf8ec7	71396019-5291-58c6-99a2-eb79cc120767	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
de09fb5a-7507-55ac-9322-668d9ca5beab	71396019-5291-58c6-99a2-eb79cc120767	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
9f6c3115-0f07-57d0-aa1d-d7ee29be5e15	71396019-5291-58c6-99a2-eb79cc120767	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
33a88f50-c871-566d-8b50-cb0e3849b780	71396019-5291-58c6-99a2-eb79cc120767	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
f33c47eb-b3c2-56f7-a851-625c99c58bcc	71396019-5291-58c6-99a2-eb79cc120767	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
dfd04446-3c4c-5c1d-9c7d-fd0b41408573	71396019-5291-58c6-99a2-eb79cc120767	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
c6c63252-5b1b-5945-92d3-b1f1735217d2	d5752969-164e-5001-a888-c76bc3c19642	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
e4a77316-a3ff-5131-94d6-e59f36fe1e9d	d5752969-164e-5001-a888-c76bc3c19642	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
753bd696-70ef-5e78-bd15-456428b31687	d5752969-164e-5001-a888-c76bc3c19642	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
6e48e18f-bfe0-59e7-81ac-090ada6061b2	d5752969-164e-5001-a888-c76bc3c19642	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
69c8851c-0e49-50f6-aa84-346755ef3132	d5752969-164e-5001-a888-c76bc3c19642	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
dcafdd2d-dabb-567c-9bb8-b7f6ef1f9c02	d5752969-164e-5001-a888-c76bc3c19642	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
d5220213-06a4-551c-a4b6-b1c9673bf9a6	d5752969-164e-5001-a888-c76bc3c19642	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
ee18ba7a-c5f7-5f4a-9661-7ad4d90d8266	d5752969-164e-5001-a888-c76bc3c19642	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
f4b8b239-3b88-5e0f-b59a-17ac1df53560	d5752969-164e-5001-a888-c76bc3c19642	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
b45346d2-9cad-5a24-ad3f-3e04005c02f1	d5752969-164e-5001-a888-c76bc3c19642	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
fa03a4e4-520a-5180-8a25-f457a6ad3e1d	d5752969-164e-5001-a888-c76bc3c19642	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
b597d56e-a73e-5ff6-809f-81599d331212	d5752969-164e-5001-a888-c76bc3c19642	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
62f3cf0a-283e-59a0-b055-c34ef5d67288	d5752969-164e-5001-a888-c76bc3c19642	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
99c01736-192e-5fdc-8861-593f1426d139	d5752969-164e-5001-a888-c76bc3c19642	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
88191eec-318c-597d-9752-e26e10d8874c	d5752969-164e-5001-a888-c76bc3c19642	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
5c708129-4240-5f6a-bd5d-7ed1c5434d1e	d5752969-164e-5001-a888-c76bc3c19642	قطع 2 * 1.5	2026-03-25 18:13:41.323568+00
0ff37f54-86c4-5e7b-a45b-7b0f059fe533	d5752969-164e-5001-a888-c76bc3c19642	قطع 3 بوصة	2026-03-25 18:13:41.323568+00
33f73ec5-118e-5a83-bf95-62e0ba535dff	d5752969-164e-5001-a888-c76bc3c19642	قطع 4 بوصة	2026-03-25 18:13:41.323568+00
fab03014-2cfb-57bf-aa2f-7998e3b33df2	d5752969-164e-5001-a888-c76bc3c19642	قطع 1.5 * 3/4	2026-03-25 18:13:41.323568+00
e51e11b8-471d-57ed-96e7-1fbe83eb4965	d5752969-164e-5001-a888-c76bc3c19642	قطع 1.5 * 1	2026-03-25 18:13:41.323568+00
692519e0-6295-5892-9d1d-91cad5f3dd85	d5752969-164e-5001-a888-c76bc3c19642	قطع 2 * 1	2026-03-25 18:13:41.323568+00
141f9c5b-6d31-55ee-86f6-ad02f51926e7	d5752969-164e-5001-a888-c76bc3c19642	بلاعات	2026-03-25 18:13:41.323568+00
dd2b913d-417a-55cf-8fa4-c539aa173fc3	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
605f3728-7c52-5f81-a820-2f56527a37b2	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
d4b7958a-f827-5a95-bb78-74e72e9081ac	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
ca584991-90a5-5424-9567-9d7f5a49a3e9	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
2b383ebb-281e-579d-b4a3-785e3ec1b583	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
a9526b99-9334-5266-870f-70bb30aacaac	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
77b24e3b-d8f8-5764-9879-fe1cf0222069	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
7afd58d2-0170-51d0-80b9-dafb43921678	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
683ca3d1-3a64-5b74-b888-79b2938eace2	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
802e8062-7f98-59b0-b9e2-e37c8615978c	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
4ccf3e56-30f5-5ab8-aa20-f3676a5061e9	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
412d5f95-e302-5cfc-aa6b-12cb95411b3f	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
c6db36fa-a81c-58bc-b7d6-608f8d3ae1d1	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
5e9fdd71-7989-5122-b2d6-49bc9ba8851c	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
ab9446cf-95d8-5574-b37a-e54d68e708fe	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
5a19ea93-e476-5648-ad0e-654ffb6f8b85	8d82283e-d183-5952-ba2a-aec1f42e5342	قطع 3 بوضة	2026-03-25 18:13:41.323568+00
3c50e6b2-460b-5a16-a8f0-8b793600ada4	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
3f20d660-a62d-5771-be7f-000123b1a6e2	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
57a121ca-3477-5b68-bde3-6e46a610fc66	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
2f560337-5a50-59c7-92ed-2a14c0dbd904	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
a8ff45b6-15c0-55fd-b568-542ed549a396	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
2c85857a-6249-557c-892b-8dd099fce6af	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
ec9abba3-9266-5c16-a646-178cbcb34440	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
d0b68374-c340-51f8-8e0b-eab0a823c6f5	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
7f651064-3427-567d-bdbc-f39eab06799b	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
aef30f22-bc1d-55ee-9da6-e1d170070261	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
9eb88d49-0acc-52c3-a580-2356d9d8abf3	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
6e463712-2be9-5275-a23c-858883beadec	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
3b448288-bcde-50eb-b1e6-897c4a5614c0	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
b73b6487-d0c8-5964-89c7-850a47c51da8	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
05955e95-b1f5-5267-a35d-7d154105cebd	b26ef2bd-07b9-54a8-8d2e-3371535208ea	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
978af021-a666-5101-af9e-ed05c156645b	b26ef2bd-07b9-54a8-8d2e-3371535208ea	مواسير	2026-03-25 18:13:41.323568+00
cc46a1fa-5849-5695-b684-3c5ec13bb0a6	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
63e2904c-e0db-55e5-9f40-d5f84a85a501	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
9a3e6604-1d9e-59a2-9306-b96751e63a08	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
7cb8a098-41ca-53d9-b4e0-cdb8907a18d9	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
0b85b586-e81d-5b04-866a-afd2726601fc	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
de03f92f-41ff-5c3d-9f53-84d3397626ab	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
a8e4d683-3422-50bf-bd7c-91584afca4c4	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
3bdaca2a-6e9c-5e2b-b964-711663449202	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
96732414-d3fe-5d37-9585-8cdd148373d0	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
9a1c912c-90c3-5d08-9f34-ed0af52d229a	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
5cb94034-0d64-57b9-8873-c48bc87a329d	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
d5901618-eafd-5ad1-b0e6-f0f56f1cda35	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
1da2db1b-955b-5530-885e-33ed2ab7e7d3	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
c286bcb5-a984-59c2-b633-ef3ebf4da01f	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
765f5e85-edfb-58dc-bf2b-4790017fb2f8	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
9dc6edb6-19f2-5c9d-8c52-5a335ced3880	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1 * 3/4	2026-03-25 18:13:41.323568+00
aeffa6be-df79-58c1-93ba-30d4f612d48e	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1 * 1/2	2026-03-25 18:13:41.323568+00
20ecf9c0-8655-5221-a299-7a517bc5c6ec	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1 و1/2 * 3/4	2026-03-25 18:13:41.323568+00
59148d2a-fc7e-58d6-adf7-e6e87869724c	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1 و 1/2 * 1	2026-03-25 18:13:41.323568+00
46f96c6a-23fd-5740-849e-61de853f07aa	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 1 * 1	2026-03-25 18:13:41.323568+00
d6654c3e-1821-5363-80b2-79297fffcc14	c61407e7-6f34-507e-b401-9e28544c6ffc	مواسير	2026-03-25 18:13:41.323568+00
dfa4a5f8-abea-5e9d-8ed4-2a99807ef404	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
77ced8bc-60ad-568c-a51d-f0b890faa0a8	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
393d0809-7280-57c5-bd9d-a6baef3bef7a	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
884a8c15-3fe2-5ffa-8785-7b2ca5648130	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
75c6517a-5c39-5e23-9e19-ea85b739f40f	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
f152eecc-86a3-511e-8fe7-f85361b7d69d	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
6b3e331c-b52c-58d6-aed9-67be50b87558	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
9e9810e3-47f7-5728-af3e-85e0fe03fc62	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
5e83f85a-1ddc-532e-a260-aab279710437	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
fbbdf1ab-ba5e-5250-bbc4-77ba280c68f0	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
39f800d8-18a0-5b11-9c14-7c44dab218b7	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
a28c076d-ea6c-53ad-8bec-cd3633d98268	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
ff992bae-d79e-5737-9b28-f450881735ab	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
aa638250-648c-5a0f-945d-2aa98f6ed4e5	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
40da3d67-2ec6-5e01-9948-bee9c53ca408	36d7143c-b44f-5970-9c9e-a3b8b80c13e5	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
e099ca1f-6a49-52f8-bdfb-8d6579a20ce0	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
50f522ed-4c01-5501-8394-c9a32d524225	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
e14d1ffb-87cc-5246-852d-d8a8506eb494	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
2c3a8f66-9e5b-57c5-9f0e-4d62c1fee5c9	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
4168b49e-a270-51a4-81ac-6e95693f8609	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
6c9446a4-07b6-5d3e-8a98-df520a49e60b	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
323337c4-285e-51c9-b01f-45cdea80edce	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
9845f808-e10d-51d2-ad98-9a996ecedf60	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
d3649100-9cc7-5488-b270-392d525e26aa	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
9fcb17c4-ce7e-577d-8f10-5ccf2cbb3149	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
3d41fb45-6473-5116-9a50-12952e009629	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
76ab3f5f-9849-557c-91c6-66b35792f5e2	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
56e9fab0-a602-5e56-9224-d7cf7fb584d2	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
e0e1c91c-960f-5ae1-a2ba-7c630ca8f30a	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
8d4b0064-680d-5952-89ab-e8612a5f4cd4	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
55ff2b2d-9752-5c2c-bcf7-16c9ecbaa1a9	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 2 * 1.5	2026-03-25 18:13:41.323568+00
85f79f76-dbbd-5084-86b8-e79285b6fa0a	b86aa34e-a4b5-51fc-a973-96f428d82fc0	قطع 3 بوصة	2026-03-25 18:13:41.323568+00
1cea07a9-ef47-5aa1-9143-71481f27f43c	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
02e80c6e-c035-5134-8015-b987d54476af	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
8454148b-4c4d-5e12-811e-137f4025350e	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
e4f59802-bf68-5d67-b4c6-6f8b0609415b	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
86d3ec82-895f-5c89-8227-9f0e70180068	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
1a312bf6-dee6-5377-9df9-b7b20ec9d288	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
959f5638-56ff-5f57-b233-610869c0137e	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
8a84f65e-6e44-5013-8d9b-cf678204ec48	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
deb6ce28-77ae-5589-b802-ae4a1d2a82e9	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
e91986c7-e5ab-50c7-bb78-c4831d7596fc	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
e4078ef0-7aac-5a3a-9d8f-e3453fd1b784	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
563669cc-7d61-5d3f-9a35-db72e3f2826a	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
b9833df9-8a21-5d39-9500-e15f7c41ad91	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
e0a1cc47-f797-5000-91c3-9e3b87c67df8	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
0f716f0c-aac4-5356-8306-f1a367f2cce5	07c411fb-ecef-5022-a228-9e6d5e8db604	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	76c1c9a0-8b8d-5958-8a14-3dc2f241a635	لوازم خزانات	2026-03-25 18:13:41.323568+00
24dcb16c-9713-518d-8af0-a48722e900dc	2e9e355b-440a-5364-92ba-33d303c6039f	شطافات	2026-03-25 18:13:41.323568+00
d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	2e9e355b-440a-5364-92ba-33d303c6039f	سيفونات	2026-03-25 18:13:41.323568+00
682ba68b-ea1b-565a-972d-e92063da3cbb	2e9e355b-440a-5364-92ba-33d303c6039f	لوازم غسالات	2026-03-25 18:13:41.323568+00
a2d24d60-3532-51e5-8afb-8eda7b9be75d	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
085cb45d-6d8d-5b83-97e1-7aed5d894436	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
2732421b-5c80-556c-9323-4c8f800ad58e	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
fd633f75-a421-5f87-9aa2-97688748a712	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
893b547b-f9e3-5b05-8405-c72cefb151a5	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
2fbfb9bb-f80c-5857-994c-fb1afd5ced93	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
eb1d8268-250d-5020-988a-8f439e3a2865	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
3d21e934-450a-58d4-b841-2da42500abf4	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
c8935c08-ddd5-5c7c-af25-53e802fd930c	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
b299e7de-38a6-529f-a2fb-5c5c7d8d8cea	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
a7afdbbf-29cd-52de-8b2e-5cc80261d44d	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
fa9b7754-3753-5ebb-9656-7fced34eb852	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
6e264538-d570-56e8-ab82-3a3db2f04764	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
24af384e-9a22-58fd-bd52-970a3c97cad0	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
636b145d-6c87-5bb1-96b0-9e310ec6f58b	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
33e8b433-3ee7-51f7-b7e1-18a94467117f	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
0c598bc5-8f46-5e1e-8b06-668d2efaf118	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
ef645590-7da7-5ca4-85b9-fc1fb239460a	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
6b76dbfa-aeb0-52e9-89f8-c21fb3e08278	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
16c83b9f-b315-5a50-8d09-fd0b8da2ee70	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
f632c202-7f1a-53b6-a296-f3c54bb6c525	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
3513329f-1fb7-5449-b040-675e0d5150d9	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
f14af88c-6d08-59f9-a235-0b94389c6d36	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
eb886d53-bd4d-559c-ba48-dd925c0a9cb6	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
c5b5eef5-0f09-5f4e-9eca-64b90a1f7b0e	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
6b843848-69da-5f9d-b6b7-276ab5f63051	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
f0099e08-f4dd-5230-b01c-960f1498fab3	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
b258a1e8-cc49-5d5f-89d0-6d3307ec4a81	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
a64aaf28-7027-5d38-bb91-4802d4c755da	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
636d2ea3-cfcc-5599-866e-a90732f63ce2	cf660238-35ef-5656-a4f0-6d569293dfd8	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
50aac995-d284-5518-bbb9-019cfdeb1378	1dcb7c7b-7c65-5765-933e-0331c121e032	خلاطات	2026-03-25 18:13:41.323568+00
201504f6-3716-569b-9502-2a404a8cbb03	1dcb7c7b-7c65-5765-933e-0331c121e032	لوازم خلاطات	2026-03-25 18:13:41.323568+00
5d243e5e-b20e-5f54-9828-e080a13b0a39	e2cee846-5949-507b-8625-012eec13a6e6	اللي ف الوش	2026-03-25 18:13:41.323568+00
86600a27-d5d3-56ab-a8ed-e3ea152ea390	e2cee846-5949-507b-8625-012eec13a6e6	اللي على الشمال	2026-03-25 18:13:41.323568+00
1a1d02e5-073c-5e69-ad71-5432e235bfa5	e2cee846-5949-507b-8625-012eec13a6e6	اللي ف الوش 2	2026-03-25 18:13:41.323568+00
f0906684-99d3-55aa-9994-9427e941823e	e2cee846-5949-507b-8625-012eec13a6e6	اخرى	2026-03-25 18:13:41.323568+00
92d22b39-ff32-572a-a53e-3e3942306976	e2cee846-5949-507b-8625-012eec13a6e6	بولي نص المحل	2026-03-25 18:13:41.323568+00
8f28d905-151c-55b6-8379-1d5332eced40	e2cee846-5949-507b-8625-012eec13a6e6	تحت السندرة ابيض	2026-03-25 18:13:41.323568+00
36041da5-c9a4-574f-9538-790b9601a464	e2cee846-5949-507b-8625-012eec13a6e6	بولي جنب المواسير	2026-03-25 18:13:41.323568+00
ae20d096-97b0-524d-bf38-e8865a491102	e2cee846-5949-507b-8625-012eec13a6e6	طلبية شهر 3	2026-03-25 18:13:41.323568+00
9a26d49d-306b-4641-9682-d45821fb988b	d5752969-164e-5001-a888-c76bc3c19642	مواسير	2026-04-04 09:10:30.210138+00
94f8de20-fe91-4ebd-9c16-1ce74e99b797	f2e45fda-3401-5c1d-b76f-90c2b1dfa43f	مواسير	2026-04-04 09:10:46.389019+00
7d25587c-4cf1-4eee-905a-eec5fb7e9f68	1dcb7c7b-7c65-5765-933e-0331c121e032	قلوب خلاطات	2026-04-04 09:24:57.539238+00
116387e4-1052-4100-aad0-740a50b15de0	9e478fd3-55ff-5125-8409-0047688d6453	حله 1 ملي 	2026-04-04 10:51:30.768937+00
38039040-a0fb-43f3-b797-fc9261be912f	cf660238-35ef-5656-a4f0-6d569293dfd8	مواسير	2026-04-05 14:58:26.816409+00
db5470af-2e31-4a61-b24c-b2ff749c469b	4237ec93-d9b7-4061-877c-d866a6565576	لوزام كهرباء	2026-04-13 14:19:42.7096+00
717cca0e-559c-409e-8623-d47ecff326c6	c61407e7-6f34-507e-b401-9e28544c6ffc	نواكل	2026-04-13 14:26:55.596742+00
49ebba26-a7d1-42a2-bb7a-850f732f1f78	c61407e7-6f34-507e-b401-9e28544c6ffc	مسلوب	2026-04-17 11:10:24.900903+00
6e5adb99-fc20-4ec3-9366-8427dcc2a094	c61407e7-6f34-507e-b401-9e28544c6ffc	قطع 4"	2026-04-17 11:31:15.19398+00
b573fe58-7d47-4e7c-95bc-0494d6a4387a	752b064e-82fe-4680-b581-8654da63bfca	 لحام معزول 3/4	2026-04-22 14:05:07.233416+00
2b737b5c-2894-4b2d-b076-b80d8a50f8a5	b26ef2bd-07b9-54a8-8d2e-3371535208ea	مسلوب BR	2026-04-22 14:43:42.867542+00
\.


--
-- Data for Name: supplier_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier_transactions (id, supplier_id, amount, type, reference_doc, notes, created_at) FROM stdin;
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (id, name, phone, address, created_at, type, balance, notes) FROM stdin;
0774fa50-1be1-41db-af04-bc156d47c49b	مورد تجريبي	01000000000	\N	2026-03-28 13:41:08.477311+00	supplier	0.00	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, full_name, role, password_hash, is_active, created_at, updated_at, permissions, is_manager, default_warehouse_id) FROM stdin;
7a04031f-e0fa-4c26-880c-a2b287929a8e	aldeeb	عبد اللطيف	cashier	$2b$12$VRRLQ8AIROq2/QLGO0/C.uNftKFDhhF2LNC352SPXATJNJDcR.N0i	f	2026-03-28 16:35:26.487894+00	2026-04-05 15:33:51.120831+00	["pos", "inventory", "reports", "archive", "settings"]	f	59a2b8d7-e26b-4979-ae0e-3984f1b711b2
5f693928-e947-4ff0-91e5-c369f0ea0449	mostafa	مصطفى محمد	admin	$2b$12$OyEJLbVGSrc2w2CGJZbuJ.Io6LB9J/JtqaHiAoinMTBzJeLx4RxEa	t	2026-04-03 15:47:05.177169+00	2026-04-03 15:47:05.177169+00	["pos", "sales", "quotations", "inventory", "operations", "customers", "reports", "archive", "payroll", "users", "settings", "admin", "shifts"]	t	\N
90b16bd6-d77a-456c-93fe-04c9a8eb445e	momen	مؤمن محمد	admin	$2b$12$fw7d/b27iaFBWGvuUEiO/OvL4ZBdK2zWrkLi6h0J0kgHOmV1A7eY6	t	2026-04-03 15:41:42.36881+00	2026-04-03 15:41:42.36881+00	["pos", "sales", "quotations", "inventory", "operations", "customers", "reports", "archive", "payroll", "users", "settings", "admin", "shifts"]	t	\N
f00d039c-caa7-5b00-adba-365ed90c5f10	ammar	عمار محمد السيد	admin	$2b$12$XqisxnWbwfVZOJjFhoKF6ejOzvTaJSNRx/iYHdT6oXQRBCkxpXgY.	t	2026-02-06 19:14:38.254017+00	2026-04-03 15:47:17.263865+00	["pos", "inventory", "reports", "archive", "settings", "users", "payroll", "admin", "operations", "quotations", "sales", "customers", "shifts"]	f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
7a953310-2957-42e5-89ac-eb58456a7123	amer	عبد اللطيف الديب	manager	$2b$12$eijJJLKWdNbNUd6w2f/c..awQ6qVFl/D/IZznUyRdcSzOe6dUOhYy	t	2026-04-05 15:34:31.549927+00	2026-04-05 15:34:48.648686+00	["inventory", "operations", "purchases", "archive"]	f	\N
d17b4b23-b266-4f91-9091-fdbb6506a628	ibrahim	الشيخ ابراهيم	manager	$2b$12$rtudnLSoanWlYi2zpA8HhO8vzIz.lZUgJaRHs7JRWpNx/TT66qQL2	f	2026-03-28 16:32:18.850313+00	2026-04-09 16:52:37.515701+00	["pos", "inventory", "reports", "archive", "settings"]	f	536e6eba-c111-4d60-b812-ead42ab23883
c067535b-99c8-4d2c-9ff5-5ae2bd0e5f28	mohamed	محمد احمد	admin	$2b$12$Hz6wdOdQhscgkAZILqMqxetG4Jpq/gCAf.JKwwCdFKlPCA423ZRgi	t	2026-04-03 15:45:23.732885+00	2026-04-03 15:45:23.732885+00	["pos", "sales", "quotations", "inventory", "operations", "customers", "reports", "archive", "users", "admin", "shifts"]	t	\N
ee31f134-c885-42b4-950b-53284e09a25b	dalia	داليا السيد	admin	$2b$12$6bcnQ5PrlC7ZWtDMYxgkCe1OU3w01hUSlM6/wlxcPy2bqkbI5/w8y	t	2026-03-28 16:05:35.145099+00	2026-04-15 12:57:01.80739+00	["pos", "inventory", "reports", "archive", "settings"]	f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	alkok	احمد الكوك	cashier	$2b$12$2PtWLZlbisP7z3MDpFS4sO.P6/eudl9aOgHzwu13kPwtP0IkyZJP6	t	2026-03-28 16:03:53.959822+00	2026-04-15 12:57:28.853413+00	["pos", "sales", "inventory", "archive"]	f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
6a11d77b-24cc-577e-9ec3-4b0088eb7585	nada	ندا خالد احمد النجار	admin	$2b$12$Jtd9lBDziJqz88kRqOMKZuddwVRWL8GYinH7yzFDJ2vLPpqyYaGca	t	2026-02-28 16:21:52.170677+00	2026-04-15 13:59:40.081724+00	["pos", "inventory", "reports", "archive", "payroll", "admin", "operations", "quotations", "sales", "customers", "shifts", "finance"]	f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
916e8dbf-c920-4cfd-a9af-f2f76d16417b	belal	بلال عادل	cashier	$2b$12$o/QzwwcoNbJvKQHTXmYk7e0cQV1jukCdOsnThbw2MWm9BgBrgcXvC	t	2026-03-28 16:24:44.334465+00	2026-04-15 19:59:14.607405+00	["pos", "inventory", "reports", "archive", "settings"]	f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
85ba0e1f-040c-44b2-90a3-0afcaa30178b	s	الشيخ ابراهيم	admin	$2b$12$VZGwA5SBDoUrY1u.okPo8epYII.ldsptzoLdreIIJrEoGeaFDq00i	t	2026-04-09 16:58:34.22661+00	2026-04-18 19:53:19.402129+00	["pos", "sales", "quotations", "inventory", "operations", "customers", "reports", "archive", "shifts"]	f	dc59d83b-1dec-4f60-8cde-4826031c7195
658196d5-857d-493c-94e4-e604b01764ab	habiba	حبيبة عماد	cashier	$2b$12$1WJPe7SnWydrjCiRDBFliuPm3lH7xcxOzbOOPLunnO5O4lHckNq26	t	2026-03-28 16:04:57.856624+00	2026-04-19 21:19:53.207224+00	["pos", "inventory", "reports", "archive", "settings"]	f	dc59d83b-1dec-4f60-8cde-4826031c7195
e340421d-5fe5-4f17-8067-b6c781e458f6	مدير مخزن 	عادل	storekeeper	$2b$12$ktYMmMIC1UPqFdYPdY051.g2Rc6eGXRpUCHKF35SI8QW.tR0ZHLom	t	2026-04-20 17:19:33.926941+00	2026-04-20 17:19:33.926941+00	["inventory", "operations", "purchases", "archive"]	f	\N
\.


--
-- Data for Name: wallet_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wallet_transactions (id, wallet_id, amount, tx_type, ref_id, note, created_by, created_at) FROM stdin;
cc79792b-2e4c-4dd1-a38c-3fc94522d1c2	8168ea3e-3935-477f-a412-9184f9188885	685.00	sale	d007be7b-6a2f-47a2-87fd-41493daf268b	بيع INV-001060	85ba0e1f-040c-44b2-90a3-0afcaa30178b	2026-04-09 17:39:33.67449+00
\.


--
-- Data for Name: warehouse_product_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouse_product_status (warehouse_id, product_id, status) FROM stdin;
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	728d6023-951b-4a19-8cfb-d62631ab5736	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	bc28ef2a-26a3-4fa2-9f4e-2b938f776bd4	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e3ef3606-53ce-4847-a9ae-7357efdea79a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	49f4d737-1d66-4bbf-8011-44949b013133	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	55cc2075-bfe4-4613-91de-05535390b28a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d5442bca-dd7e-4793-aded-ef8d13f3d2b9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	cb153139-9139-4c4b-b341-9cabab43c132	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	66a44e6e-ba10-4e53-96ee-b41b8af644eb	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0f81a2a2-6a73-4278-836d-a08c10fb0238	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	19ca0c73-ab1d-41ee-8a08-45121c253710	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	93f907c6-3b84-4d95-b1a5-b57483e81451	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	cf75658d-4804-42d6-bd8f-edf3a77549be	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a7861f0d-2057-4965-97f3-26b745cbbc8b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	857d4856-aca0-4f69-89d8-59ed2d1b86d0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	1d30a4fe-fbfe-4d3e-886d-d7c5ec544240	tracked
dc59d83b-1dec-4f60-8cde-4826031c7195	55cc2075-bfe4-4613-91de-05535390b28a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	8af6f47a-5f64-4895-945b-fd307a9859f3	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	672e317a-e3e5-42d5-8da2-40b152ca973e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3892616c-8ad0-47d2-aebc-ba3c30cefb39	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	517e8569-1a19-4a7b-8743-c6a9df8adae2	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e78feee1-8757-433d-9a58-27338aaf1655	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ed6fb4fe-6aa7-4a8f-8856-bbdd3b7b7625	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	07ad204e-14a8-4bec-92e2-3997be506cc5	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e7f5a544-04fd-4b2d-9146-fb79df577821	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	92e36fa1-8349-447e-a7be-511d6f209f20	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	eabea370-6202-46ed-836d-89822831f083	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	67361216-d048-4bca-9f65-3c1df07745a1	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	177bed74-3f94-4fed-93a0-e23cb13847f4	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	22a11cf4-2023-4f18-895e-89f507d5829a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	523adcc8-e4e9-4766-981b-e5165d723e43	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c1895f9b-5d9b-4507-9ac8-be10dd5c08d0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	8a00f949-0c0c-4c21-8d44-c6ffaae33aa9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	fc080463-994d-4137-87fb-c0544751b8ac	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6c53ac78-8c67-4b7d-9417-fe21bb9cad2c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	129089d7-95d4-42cc-94ef-2e54da0be9f1	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	567716d2-0cca-4d9d-a291-f5e070c5b0a0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	935326ee-fa2f-4434-b571-471f0e996f35	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	70c6a2cb-6643-4373-9e08-da46d851fe2e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	fbc41295-0338-4e49-b61e-79e99e9f5667	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	7ee0b4c1-23e9-4783-b9fe-f148c7606066	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	31147ad9-de4f-4ee1-aaa2-4f86cce7963a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9ad31176-b502-43b7-b47a-57cdaa1e623f	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	2d4491e6-7f57-4c93-a720-a7be5d68b4b9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	20076dde-b7fc-463a-af90-381696236d45	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ef7073ab-4d25-442d-8505-6eacd9886f13	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	2c4c4d5b-db29-4f28-b53e-bb2aaecab809	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ae78cb21-9bf8-441a-a101-6be57eb4f2c0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	bf14d1ca-8f4d-4a9f-a8ff-435203615af8	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	72635b19-9fcc-4fd6-9ada-b9cf33bb50a0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d60e69da-7058-429d-8890-144bf710100b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adc37b18-86dc-4fbb-bea1-856a682a5095	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b419fb16-6f5d-478c-8ce4-c19a2e25f8c2	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	8816fa99-fe08-4d0b-ae95-19558eb03a22	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	830adebb-e1c8-4e24-86fe-26eda9b4fbc7	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	76974cd1-2978-4467-ae5a-b558aa71c242	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	96057283-03bb-4f16-a011-5b4e00628633	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c93e6a11-6694-486c-936c-3208c49f198f	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	5660d767-7d28-4b31-a146-9c7071134ce8	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	311f37ca-8c7f-4b3c-a32a-4bd675dd929b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d159b603-06ca-4d80-b251-120ca04bd0ee	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	91e61835-47cd-4f2b-ab57-012a307a2c79	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	745c9937-e523-400f-8665-dd79e076f39f	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3475e3b2-b002-47e6-88ee-85a33cd7f837	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	45b07094-6fd8-4438-aa7b-4ba17e5ed897	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c0bb6a9f-74a3-451e-bbe4-155987c92339	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	327257f0-e96b-4e86-8094-0e1216466f99	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ee38e66f-0104-46d4-a30f-798a7fdde029	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a2e0f808-484f-4e7a-8fc7-bbdd41e2e3cc	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	2fbf13f5-20e4-4d56-a923-31acf00d8e7b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	eb80381b-f03c-4b75-b499-0ce239678953	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a4997b77-66bf-4b4f-ae74-74762dd0712c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	7e302e33-3bb9-436d-b2a6-f64f71fa113e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b9b32325-fda4-46a7-b4f4-6da187863e4a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	958976e5-78b1-48dd-b90c-639ecac8608e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e660c870-680d-4c0d-ac35-ad6c4e0740a6	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	189b8e6e-6161-40ba-ab29-98d73b32232e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	78539233-0e35-4584-8a63-835c6f128067	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	12d44342-c0ea-4093-8344-8a3fe616b946	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f9bb2b67-91f9-4176-a285-ad980d259775	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f612c100-6427-4c00-b507-11311a312843	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	19ad03e8-e71e-4be7-90ef-08bd6572f06f	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	da76bac1-e445-4b78-881d-49e35771b067	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	68a41885-4ec7-40c5-a891-c45002ddecb9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	4179d2bc-a6da-476b-aa18-1d919852e3c9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f0b655f9-def6-4462-9d88-7a334725016e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e7640605-a1fb-4ed5-96de-952bdfd35d01	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	2f9198ab-da9a-4a8a-9746-d9e451336cf9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a828ddc0-5d87-4062-a86a-a50dcf685191	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c3c27efc-96b1-4a23-bdab-93e04c7e9940	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	1db05d34-4a6f-4897-9a7c-619aa7351406	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9c6b491e-0f64-46ba-983d-e9512587b4c1	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	da12de49-d1d6-4554-b5ae-43e76227ca90	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	89153ada-a2e6-45ff-965d-a610fca6a73f	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	885638eb-a9ca-4ee2-bf74-5730e5852bc6	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a21a8080-f94d-4927-bf0b-2390e2500059	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	83759832-7ee5-43fc-8828-695b2d8c7c3e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f8361f30-bb8d-4a44-bc2d-3ae7ef72f027	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	2777c8de-00ad-419f-bd60-236b2e52effa	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b69b3ce6-eb91-4356-86b3-2240135059b3	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	87d4538d-0e02-44ee-976a-53651c8e11ab	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	01c759af-1334-4521-be65-58d69f5d3158	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	5b7abdfc-f2bb-4d1e-905a-fd54be99c46f	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	fb0d86fd-7ffc-4290-831b-19ac15f5c448	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	36a71af5-edd7-4e4c-9b77-fb2b37c53cf8	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ae6ca5a9-4e53-4085-b698-2f78efea5482	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	999b9700-0527-4039-8d38-cd9b484ccd46	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b4792075-b071-4390-8183-b9615ecba622	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	aeb7ad06-7e28-4732-b145-cfef45c9521d	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	65bfbf00-27bf-4323-ab25-1ccd994cddc4	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	cd3b2528-421e-4761-b84e-90651f4cfd3f	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a268d0b4-97d9-4f49-99c3-19491bc9f078	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d327c0dd-7a93-4935-bb1b-30c523147993	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0ee2584f-6386-447a-898f-27cd91fa584d	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e8064580-f5a5-42d8-a083-bd3e3d3f4481	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3fd2efb0-19b6-470f-9092-dd0823473c82	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ae005153-de66-49ed-b132-23434ecacf5c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f9e48d97-167b-443e-bb9f-0dcc047bad58	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	61a43033-a203-475e-bfc2-c843163a2756	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	05772215-09f1-41a4-91b3-e56c69ec58db	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	871b0c43-957e-4eb5-b5f0-4609014c1885	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6c1a7601-4298-4f3f-be83-c3e4abdedaf4	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	70afd455-12ab-4f85-9e1a-5868e01b1511	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b3790156-be36-4d7a-9bb2-cf9ebe405cad	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	67e52b55-eb97-4426-bf88-5fc459bf9141	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	8efe2eb5-bd06-48bb-b1ae-b843129e85eb	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	85be72d3-5d91-4bc1-8bc8-73b53c083490	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	357dad92-ae44-40df-98d6-135586d4f7c9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	98a0d6e7-821f-45f3-8d99-52cd2e6d4699	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	12a192bf-25f2-43bb-b1e5-94ac6cb5e62b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	98f52e8f-3949-4c87-a044-f01790695506	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c7423fe8-0195-4f61-894f-5692b13601c9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0a23f4fe-5242-49be-8b49-2618e47be277	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c80f86d8-cb80-465f-ad00-b3583f1c4c40	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c5f83958-3304-4314-a56f-7fe15431bc7b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d78e3631-becb-459d-bcb7-f626d9bdae58	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	69c84270-5d73-406f-a0f6-4509aa6ffd14	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	32cac645-8208-4dac-9da8-01986e061b8c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	1a03ff11-9bf4-472b-aae3-8734a988747c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0a9b79fd-9500-41b5-bd72-86f8c282ecfb	tracked
dc59d83b-1dec-4f60-8cde-4826031c7195	cb81213b-7bb7-4274-abb4-2d974f8a60cb	tracked
dc59d83b-1dec-4f60-8cde-4826031c7195	c80f86d8-cb80-465f-ad00-b3583f1c4c40	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e945e2a1-188f-4855-88be-ea4cb303aaa5	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a6443656-c761-4e9b-8d67-7396fe3275a6	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a57c48df-95f9-4c17-bff1-82c1d151b0b0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	7568b958-f282-4aa1-85b5-24349625f9db	tracked
dc59d83b-1dec-4f60-8cde-4826031c7195	5e9e99fb-95ac-4298-a437-570417737d44	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6262274f-c0c8-4a53-84cf-c3977995ddce	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	2eeb97e3-ce9d-4ced-ba71-4de536b02669	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a87a4c13-b30d-40ac-bffc-38f73ef2f141	tracked
59a2b8d7-e26b-4979-ae0e-3984f1b711b2	7c033855-5e8a-44e7-a03a-c91729b55080	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	bb6e8e5f-10ce-4074-a838-5afc4bfd8c9b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	db12ee40-16a3-42ce-b548-5de14a547b0a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0c08bdc9-fa2c-437e-98df-0b56837b1315	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	69eb82c2-d146-45da-947e-df7d9c7e91c6	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a6a73a1-51e7-48ae-8455-0e176997bed6	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c28b3b82-82ae-4845-ab2a-4dfd414ee5ca	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	7b0b59ed-bf39-46a2-8e35-e974084cb919	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	80e1b844-6853-4d0e-b574-51a38644a638	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0d71a0fc-2f22-4bef-9038-6b30deeb267a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	920dd176-0c14-4215-87bd-0af9eb30cbf0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	cb81213b-7bb7-4274-abb4-2d974f8a60cb	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	8e3760bd-0096-493b-9e0e-e96262b63371	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ba67d7df-9487-4059-996b-a0ce57ed1f1d	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e0066fb9-2326-421b-a886-489c8b5863ab	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	819e0c3a-b235-4ddb-bd47-6663768def49	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	577cd1d9-5876-4b11-be1c-cd338c878aa2	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3cc22441-f1e7-4186-b81f-37d1e1548fd6	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	365c40f7-a07a-4fd9-bc17-468c7fb2536e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e5e9bcf1-22ad-40e2-a443-9b4acdbbe426	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ce256e73-4b15-4f88-b65e-4247cc702058	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6c169f15-1614-4161-97af-cf38b1608e64	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b75b4bad-63d7-4336-a14d-b95c9a221e74	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	44357f2a-f7f8-441c-bdd8-f9f1af4487a8	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9c2ccb88-40d9-47de-9b2b-480d82c50e7c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e37b5235-d605-445d-93ca-4b6af20f76ac	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	2bd5ddec-5128-4551-a96d-f826eaaec686	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	edf6547d-ee07-419d-a822-18de5c4ac63d	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	add73888-1d66-435e-bdc6-31e24d57718a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	26988569-34c5-4e63-884c-e618d9c3820a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9b9ca756-26a9-4567-970d-715c339b6d48	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e4028986-2cb3-40e0-84e7-6e167bac110d	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	caef7973-c811-4391-bc0d-07a8f5ef6087	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	1ac52e2c-94b4-473a-8bab-7bacc1ac2673	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	fc34d4b3-7215-42ae-9c64-eb7d8b003cda	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d87c198f-b9e4-47b3-be1d-ca135da5243a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e50f6cef-cbd4-4458-97fc-52eb563bc3c5	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	19f9e986-7a6d-43b3-99c8-424277fb7b01	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0fd12267-532b-4474-b66e-a1ffa378a6c9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	5d31eb67-6989-4113-8936-43dc6ae1a959	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c8dbcca5-dcae-485a-aeae-deea53ae1586	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	745efab6-e9cb-4323-8d17-a2fe2c555010	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	fffc498b-ab89-446f-bf7e-43ad31c86527	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6c38825d-4c46-4892-a768-255e236c306b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ca20b458-786d-4bed-b94a-a91b10a6c621	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d75fcff2-ef64-48b3-9cd8-e06d40e3a399	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	40cdebca-7a06-49c2-a5fa-850250936c54	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6e4b57c6-a303-4249-9f3c-7075f1a14bce	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	858d8c6c-94bc-4b7b-9bf6-f5aaf4cc7aca	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d4f387cf-2b6a-4ca0-ba1c-099b594a5949	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	2af69fb2-b207-43c5-9f6d-0fa26b40cf18	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	147e4173-a198-4ef5-b70c-9ed8aa73c872	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f0b0cc99-32e6-4b1a-8493-25be82e03e31	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	45b3d31e-23e5-4b53-ad46-e71044fd702b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b817632a-1b1c-4494-bbef-2dcc9c54aff5	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	625c7018-17e7-4090-9e8a-fbbedab8d3e2	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b846a51a-8875-4a9c-9afc-19b7b5eea618	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	437f52ee-b323-4a5b-a6cf-aaac3b2e4691	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c120ad01-bbee-4fcf-923a-d30ccd95de43	tracked
dc59d83b-1dec-4f60-8cde-4826031c7195	672e317a-e3e5-42d5-8da2-40b152ca973e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c66c0732-d798-447c-a1d8-9fc73cd6396d	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	28ef30d2-959f-470e-868c-6d1b638cfeb1	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	1ce42d75-79fd-472f-8613-41af9ac5559c	tracked
dc59d83b-1dec-4f60-8cde-4826031c7195	41ff54cc-6f6b-4366-a49d-4dc4378f813a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	da5bf6fb-6156-445d-a462-809b65e03e52	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d2ffb803-9a86-4990-b834-9a3d7413444d	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3b1471c3-f7f4-4a7d-a28d-06206542e170	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	4d5e6616-df0c-41a0-a88c-bad074a514af	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9cffbe6c-1071-48ce-8973-fcd035c61762	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	b262a202-b104-436c-961b-749be916955c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	431857ef-7002-4208-836b-2d92a8b886db	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3854671f-68b4-489a-865a-8c80fb2a80d5	tracked
59a2b8d7-e26b-4979-ae0e-3984f1b711b2	c8b78e53-a457-4b32-8897-c449f3fe1e4f	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0668c81e-e210-485a-bd0f-4d072c702c6e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	bf9ce757-b348-4b75-bbb4-0c6bf8efc605	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	5bb79780-a8aa-4007-b778-5ad0dbb78e6e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6b464626-fbe4-4656-bd1a-d571d6836693	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	258a592c-948d-42c9-8c2d-8bfa4641b016	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	38add71e-db1c-4c7b-a43d-6b79280ec3dc	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d8044cc3-b892-4d4d-b108-e5d2dc39134b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	99a28536-9fce-497d-b168-b3a14c79d5c1	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	015510b5-5c17-40eb-8099-378255764017	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3132378f-a089-4b2b-a047-c1e0a8651c31	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	d3c4e18f-4297-4fea-b338-756ca2c90097	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0a5287eb-3d47-4451-ac01-b6d97287ada1	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	731e6d42-8a1f-466f-b80e-97784861e90c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6972c97c-fdb0-4a9b-b563-06ec0ac883c3	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	bc621655-d111-43be-b3a7-b860e8e487c7	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c5b2afd8-2550-4d3b-8a3d-3ff6bef14544	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	41fe92be-9e23-406a-90bc-04734c30a5a9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9995e6c2-e656-4f06-b7d1-938574985a22	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	12496280-b9bd-43e5-882b-8cad7ac41d14	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	02c411bc-4988-4422-bc60-fa2acc687b5c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	accc59f1-42a1-4501-b345-658bcec88377	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	0d2c4abe-8714-4cea-b01e-967e024ad4cb	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	18988ac3-83bf-4b07-9bf3-f31dc4810704	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6cf339ab-5c51-4d0c-a096-98aa08096dbb	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	ff6f769c-0bfb-49fc-86cf-e73805d51892	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	8bfd6725-3128-4c54-b869-fc2a959df714	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	85d12824-8b4e-4805-a439-94123944367c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	803dc7a3-eb72-458f-82eb-a1bed2a9157c	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	39f5ed3b-7c34-4b75-9331-32a95c7d8b81	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	92518465-ec8a-4c4c-8fa9-d7517296ae04	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	a59c2e11-fed2-4972-a7e5-bc34fd5266fd	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	813e8a9d-af7f-496c-80da-0eab496e15df	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	3614e70f-96f3-4b69-9104-188a0574085d	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	244e72f6-2f15-49f4-8526-3b485ebb345b	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	879040b7-642e-443d-a467-cb4a3cbc5bc3	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	8cf7eef1-0a73-491c-b6cc-8222f3c45595	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	dc312bb2-984d-4c5b-8f9d-f5a0a165eb78	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	4c7f2b6e-8a67-489f-ad91-257ba78a7f51	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	4b596a39-71ad-4be0-adcb-82637141438e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	811c48aa-84b6-4bed-9771-3e6dd162e9a6	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	446e88dc-63ad-49b3-9018-6042e55df88e	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	029b8c6c-707a-49a1-be04-96aea6010416	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	fb178da9-8ff8-4431-9e53-ff8773d684ad	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	13187950-a7ec-4e6c-a0e1-a08dbb28666a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	5f551abc-5798-4f04-8557-01afc73bb977	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	04e83173-2a26-4e61-b3be-456de3b641f9	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	4f371ebc-a80b-413d-8224-7c7458e3fc6a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	89392aba-aa30-4188-914b-4792ca2815d0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	37ee2418-56bb-4d8e-b0ec-fe9ffb1fc333	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	8eb4090c-1096-43f2-acd8-31efcbd7e315	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	43262301-8bc0-4e5e-98f8-df79b0032751	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	c36eaf49-88a6-453a-badd-ebef0c1e6ee5	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	85c4336b-4190-4737-a888-a83dee164695	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	427bdbf1-0a40-491a-bff7-7ea64a086ea0	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	e583e7c1-b883-4bca-bd92-c79c07f3102a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	1956ad46-29b3-447e-abd2-de8532dcb0d1	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f9f94c31-4ab6-4b16-860c-42b07f2fe7ac	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	43e5a9ca-78c2-4f05-affc-4c6e2491605a	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9032580b-60a6-4db2-a363-ab3c8ecdaa84	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9cce9245-5bbe-42c5-b6b2-f4fc4e5ec8e3	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	9e79c962-150d-4880-8b93-31cb260ba8fd	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	fd5f3438-24bf-427a-9f05-b93ef2e6e983	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	92d13d9b-4fda-4f70-b4a2-158fdac5eb08	tracked
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	11be2aad-959d-44fa-b21d-0adf241669ac	tracked
da49f5cd-ecad-46d3-872a-37c80585a2f0	c8b78e53-a457-4b32-8897-c449f3fe1e4f	tracked
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouses (id, code, name, is_active, created_at, warehouse_type) FROM stdin;
a0366e3a-97c3-46f9-a38c-1316edd22e88	SH2	المعرض الثاني	f	2026-03-25 20:16:56.760825+00	showroom
da49f5cd-ecad-46d3-872a-37c80585a2f0	WH1	المخزن الأول	f	2026-03-25 20:16:56.760825+00	warehouse
de88991a-eb48-445c-a780-cc66735f7e7a	SH3	المعرض الثالث	f	2026-03-25 20:16:56.760825+00	showroom
71cda278-002c-4d7f-85c5-5377d19d2572	WH4	المخزن الرابع	f	2026-03-25 20:16:56.760825+00	warehouse
1fcc6ed7-6637-4952-bb24-e73a68c45eac	WH5	المخزن الخامس	f	2026-03-25 20:16:56.760825+00	warehouse
2215ceda-adca-4983-ae67-d7ee6a2075cc	WH3	المخزن الثالث	f	2026-03-25 20:16:56.760825+00	warehouse
cc063dcf-cef9-4763-a1dc-5a918dbeda93	WH2	مخزن الفرع الثاني	f	2026-03-25 19:58:31.263159+00	warehouse
59a2b8d7-e26b-4979-ae0e-3984f1b711b2	WH01	البادروم	t	2026-03-26 04:31:39.758026+00	warehouse
aa710114-6a36-42c1-9546-b8c47390bcd8	WH02	مخزن البولي	t	2026-03-26 04:32:07.150354+00	warehouse
895019af-e233-4d66-93d4-36d0f5079f38	WH03	مخزن الحديد	t	2026-03-26 04:32:29.11938+00	warehouse
122f5b3b-9519-5b1e-a3fd-0ddacba7e157	main	معرض المؤمن	t	2026-03-25 18:13:41.323568+00	showroom
9040725c-f657-442a-83ee-2ac1c83edc32	SH4	المعرض الرابع	f	2026-03-26 10:22:27.544889+00	showroom
2f1c6c9b-3f76-4c8e-b004-e91b9b653a60	WH6	المخزن السادس	f	2026-03-26 10:22:27.727209+00	warehouse
cb6d74a5-2aab-473e-8acb-3b559fa4fea4	R03	معرض شارع ناصر	t	2026-03-26 10:36:27.904509+00	showroom
536e6eba-c111-4d60-b812-ead42ab23883	R02_OLD	معرض العبور	f	2026-03-26 10:36:00.475856+00	showroom
dc59d83b-1dec-4f60-8cde-4826031c7195	R02	معرض العبور	t	2026-04-11 13:48:52.3676+00	showroom
\.


--
-- Name: dispatch_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dispatch_seq', 1001, true);


--
-- Name: invoice_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoice_seq', 1087, true);


--
-- Name: purchase_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.purchase_seq', 1004, true);


--
-- Name: quotation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quotation_seq', 1001, true);


--
-- Name: archived_documents archived_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archived_documents
    ADD CONSTRAINT archived_documents_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: collection_items collection_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_items
    ADD CONSTRAINT collection_items_pkey PRIMARY KEY (id);


--
-- Name: customer_payments customer_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: drawer_transactions drawer_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drawer_transactions
    ADD CONSTRAINT drawer_transactions_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: financial_categories financial_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_categories
    ADD CONSTRAINT financial_categories_pkey PRIMARY KEY (id);


--
-- Name: hr_advances hr_advances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_advances
    ADD CONSTRAINT hr_advances_pkey PRIMARY KEY (id);


--
-- Name: hr_attendance hr_attendance_employee_id_work_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_attendance
    ADD CONSTRAINT hr_attendance_employee_id_work_date_key UNIQUE (employee_id, work_date);


--
-- Name: hr_attendance hr_attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_attendance
    ADD CONSTRAINT hr_attendance_pkey PRIMARY KEY (id);


--
-- Name: hr_audit_log hr_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_audit_log
    ADD CONSTRAINT hr_audit_log_pkey PRIMARY KEY (id);


--
-- Name: hr_employees hr_employees_emp_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_employees
    ADD CONSTRAINT hr_employees_emp_code_key UNIQUE (emp_code);


--
-- Name: hr_employees hr_employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_employees
    ADD CONSTRAINT hr_employees_pkey PRIMARY KEY (id);


--
-- Name: hr_payroll hr_payroll_employee_id_month_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_payroll
    ADD CONSTRAINT hr_payroll_employee_id_month_key UNIQUE (employee_id, month);


--
-- Name: hr_payroll hr_payroll_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_payroll
    ADD CONSTRAINT hr_payroll_pkey PRIMARY KEY (id);


--
-- Name: hr_settings hr_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_settings
    ADD CONSTRAINT hr_settings_pkey PRIMARY KEY (key);


--
-- Name: hr_shifts hr_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_shifts
    ADD CONSTRAINT hr_shifts_pkey PRIMARY KEY (id);


--
-- Name: hr_sync_log hr_sync_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_sync_log
    ADD CONSTRAINT hr_sync_log_pkey PRIMARY KEY (id);


--
-- Name: payment_wallets payment_wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_wallets
    ADD CONSTRAINT payment_wallets_pkey PRIMARY KEY (id);


--
-- Name: payroll_entries payroll_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_entries
    ADD CONSTRAINT payroll_entries_pkey PRIMARY KEY (id);


--
-- Name: payroll_periods payroll_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_periods
    ADD CONSTRAINT payroll_periods_pkey PRIMARY KEY (id);


--
-- Name: product_collections product_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_collections
    ADD CONSTRAINT product_collections_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: purchase_order_items purchase_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_po_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_po_number_key UNIQUE (po_number);


--
-- Name: purchase_price_history purchase_price_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_price_history
    ADD CONSTRAINT purchase_price_history_pkey PRIMARY KEY (id);


--
-- Name: safe_deposits safe_deposits_doc_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_deposits
    ADD CONSTRAINT safe_deposits_doc_number_key UNIQUE (doc_number);


--
-- Name: safe_deposits safe_deposits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_deposits
    ADD CONSTRAINT safe_deposits_pkey PRIMARY KEY (id);


--
-- Name: safe_transactions safe_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_transactions
    ADD CONSTRAINT safe_transactions_pkey PRIMARY KEY (id);


--
-- Name: safes safes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safes
    ADD CONSTRAINT safes_pkey PRIMARY KEY (id);


--
-- Name: sale_items sale_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_pkey PRIMARY KEY (id);


--
-- Name: sales sales_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_invoice_number_key UNIQUE (invoice_number);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- Name: shifts shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_pkey PRIMARY KEY (id);


--
-- Name: stock_movements stock_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_pkey PRIMARY KEY (id);


--
-- Name: store_settings store_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store_settings
    ADD CONSTRAINT store_settings_pkey PRIMARY KEY (key);


--
-- Name: subcategories subcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subcategories
    ADD CONSTRAINT subcategories_pkey PRIMARY KEY (id);


--
-- Name: supplier_transactions supplier_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_transactions
    ADD CONSTRAINT supplier_transactions_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: wallet_transactions wallet_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_pkey PRIMARY KEY (id);


--
-- Name: warehouse_product_status warehouse_product_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_product_status
    ADD CONSTRAINT warehouse_product_status_pkey PRIMARY KEY (warehouse_id, product_id);


--
-- Name: warehouses warehouses_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_code_key UNIQUE (code);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_created ON public.audit_log USING btree (created_at DESC);


--
-- Name: idx_audit_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_entity ON public.audit_log USING btree (entity_type, entity_id);


--
-- Name: idx_audit_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_user ON public.audit_log USING btree (user_id);


--
-- Name: idx_collection_items_collection; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_collection_items_collection ON public.collection_items USING btree (collection_id);


--
-- Name: idx_pph_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pph_product ON public.purchase_price_history USING btree (product_id);


--
-- Name: idx_sup_tx_supplier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sup_tx_supplier ON public.supplier_transactions USING btree (supplier_id);


--
-- Name: idx_wallet_tx_wallet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wallet_tx_wallet ON public.wallet_transactions USING btree (wallet_id);


--
-- Name: ix_archived_documents_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_archived_documents_created_at ON public.archived_documents USING btree (created_at);


--
-- Name: ix_archived_documents_doc_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_archived_documents_doc_type ON public.archived_documents USING btree (doc_type);


--
-- Name: ix_archived_documents_ref_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_archived_documents_ref_id ON public.archived_documents USING btree (ref_id);


--
-- Name: ix_customer_payments_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_customer_payments_customer_id ON public.customer_payments USING btree (customer_id);


--
-- Name: ix_drawer_transactions_shift_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_drawer_transactions_shift_id ON public.drawer_transactions USING btree (shift_id);


--
-- Name: ix_products_barcode; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_products_barcode ON public.products USING btree (barcode);


--
-- Name: ix_sale_items_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_sale_items_product_id ON public.sale_items USING btree (product_id);


--
-- Name: ix_sale_items_sale_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_sale_items_sale_id ON public.sale_items USING btree (sale_id);


--
-- Name: ix_sales_cashier_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_sales_cashier_id ON public.sales USING btree (cashier_id);


--
-- Name: ix_sales_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_sales_created_at ON public.sales USING btree (created_at);


--
-- Name: ix_sales_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_sales_customer_id ON public.sales USING btree (customer_id);


--
-- Name: ix_sales_shift_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_sales_shift_id ON public.sales USING btree (shift_id);


--
-- Name: ix_stock_movements_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_stock_movements_created_at ON public.stock_movements USING btree (created_at);


--
-- Name: ix_stock_movements_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_stock_movements_product_id ON public.stock_movements USING btree (product_id);


--
-- Name: ix_stock_movements_ref_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_stock_movements_ref_id ON public.stock_movements USING btree (ref_id);


--
-- Name: ix_stock_movements_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_stock_movements_warehouse_id ON public.stock_movements USING btree (warehouse_id);


--
-- Name: archived_documents archived_documents_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archived_documents
    ADD CONSTRAINT archived_documents_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: collection_items collection_items_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_items
    ADD CONSTRAINT collection_items_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.product_collections(id) ON DELETE CASCADE;


--
-- Name: collection_items collection_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_items
    ADD CONSTRAINT collection_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: customer_payments customer_payments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: customer_payments customer_payments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: drawer_transactions drawer_transactions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drawer_transactions
    ADD CONSTRAINT drawer_transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.financial_categories(id);


--
-- Name: drawer_transactions drawer_transactions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drawer_transactions
    ADD CONSTRAINT drawer_transactions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: drawer_transactions drawer_transactions_shift_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drawer_transactions
    ADD CONSTRAINT drawer_transactions_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.shifts(id) ON DELETE CASCADE;


--
-- Name: drawer_transactions drawer_transactions_wallet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drawer_transactions
    ADD CONSTRAINT drawer_transactions_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.payment_wallets(id) ON DELETE SET NULL;


--
-- Name: employees employees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: hr_advances hr_advances_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_advances
    ADD CONSTRAINT hr_advances_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: hr_advances hr_advances_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_advances
    ADD CONSTRAINT hr_advances_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.hr_employees(id);


--
-- Name: hr_attendance hr_attendance_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_attendance
    ADD CONSTRAINT hr_attendance_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.hr_employees(id) ON DELETE CASCADE;


--
-- Name: hr_audit_log hr_audit_log_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_audit_log
    ADD CONSTRAINT hr_audit_log_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.users(id);


--
-- Name: hr_employees hr_employees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_employees
    ADD CONSTRAINT hr_employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: hr_payroll hr_payroll_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_payroll
    ADD CONSTRAINT hr_payroll_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: hr_payroll hr_payroll_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_payroll
    ADD CONSTRAINT hr_payroll_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.hr_employees(id);


--
-- Name: payroll_entries payroll_entries_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_entries
    ADD CONSTRAINT payroll_entries_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: payroll_entries payroll_entries_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_entries
    ADD CONSTRAINT payroll_entries_period_id_fkey FOREIGN KEY (period_id) REFERENCES public.payroll_periods(id) ON DELETE CASCADE;


--
-- Name: payroll_periods payroll_periods_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_periods
    ADD CONSTRAINT payroll_periods_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: products products_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES public.subcategories(id) ON DELETE RESTRICT;


--
-- Name: purchase_order_items purchase_order_items_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.purchase_orders(id) ON DELETE CASCADE;


--
-- Name: purchase_order_items purchase_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: purchase_orders purchase_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: purchase_orders purchase_orders_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: purchase_orders purchase_orders_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id);


--
-- Name: purchase_price_history purchase_price_history_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_price_history
    ADD CONSTRAINT purchase_price_history_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.purchase_orders(id) ON DELETE SET NULL;


--
-- Name: purchase_price_history purchase_price_history_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_price_history
    ADD CONSTRAINT purchase_price_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: purchase_price_history purchase_price_history_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_price_history
    ADD CONSTRAINT purchase_price_history_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: safe_deposits safe_deposits_deposited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_deposits
    ADD CONSTRAINT safe_deposits_deposited_by_fkey FOREIGN KEY (deposited_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: safe_deposits safe_deposits_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_deposits
    ADD CONSTRAINT safe_deposits_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: safe_deposits safe_deposits_safe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_deposits
    ADD CONSTRAINT safe_deposits_safe_id_fkey FOREIGN KEY (safe_id) REFERENCES public.safes(id);


--
-- Name: safe_deposits safe_deposits_shift_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_deposits
    ADD CONSTRAINT safe_deposits_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.shifts(id) ON DELETE SET NULL;


--
-- Name: safe_deposits safe_deposits_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_deposits
    ADD CONSTRAINT safe_deposits_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE SET NULL;


--
-- Name: safe_transactions safe_transactions_safe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safe_transactions
    ADD CONSTRAINT safe_transactions_safe_id_fkey FOREIGN KEY (safe_id) REFERENCES public.safes(id);


--
-- Name: sale_items sale_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: sale_items sale_items_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id) ON DELETE CASCADE;


--
-- Name: sales sales_cashier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_cashier_id_fkey FOREIGN KEY (cashier_id) REFERENCES public.users(id);


--
-- Name: sales sales_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: sales sales_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: sales sales_shift_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.shifts(id);


--
-- Name: sales sales_wallet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.payment_wallets(id) ON DELETE SET NULL;


--
-- Name: sales sales_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id);


--
-- Name: shifts shifts_cashier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_cashier_id_fkey FOREIGN KEY (cashier_id) REFERENCES public.users(id);


--
-- Name: shifts shifts_closed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_closed_by_fkey FOREIGN KEY (closed_by) REFERENCES public.users(id);


--
-- Name: shifts shifts_deposit_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_deposit_received_by_fkey FOREIGN KEY (deposit_received_by) REFERENCES public.users(id);


--
-- Name: shifts shifts_supervisor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_supervisor_id_fkey FOREIGN KEY (supervisor_id) REFERENCES public.users(id);


--
-- Name: shifts shifts_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id);


--
-- Name: stock_movements stock_movements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: stock_movements stock_movements_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: stock_movements stock_movements_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: subcategories subcategories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subcategories
    ADD CONSTRAINT subcategories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: supplier_transactions supplier_transactions_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_transactions
    ADD CONSTRAINT supplier_transactions_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: users users_default_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_default_warehouse_id_fkey FOREIGN KEY (default_warehouse_id) REFERENCES public.warehouses(id) ON DELETE SET NULL;


--
-- Name: wallet_transactions wallet_transactions_wallet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.payment_wallets(id);


--
-- Name: warehouse_product_status warehouse_product_status_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_product_status
    ADD CONSTRAINT warehouse_product_status_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: warehouse_product_status warehouse_product_status_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_product_status
    ADD CONSTRAINT warehouse_product_status_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict FNqkJVaDpMYB89oi1Abb7gUi54FhraxqiKOd5H55dAgQPVGRXQwfSoJWtn5bgJN

