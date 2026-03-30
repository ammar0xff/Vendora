--
-- PostgreSQL database dump
--

\restrict 81eVqdV4iSXUzMBJq2tQQpepS9oXZtzcIlfRa8rOz4jE31qjouOdte7uH2Ttgnp

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
    'purchase_invoice'
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
    category_id uuid
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
    reorder_qty numeric(12,3) DEFAULT 0
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
    created_by uuid
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
f9dd5401-59f7-539e-b5d3-dc0274ce1802	المصرية الالمانية PFS	2026-03-25 18:13:41.323568+00
d5752969-164e-5001-a888-c76bc3c19642	روك ابيض	2026-03-25 18:13:41.323568+00
8d82283e-d183-5952-ba2a-aec1f42e5342	روك بولي	2026-03-25 18:13:41.323568+00
b26ef2bd-07b9-54a8-8d2e-3371535208ea	سمارت	2026-03-25 18:13:41.323568+00
c61407e7-6f34-507e-b401-9e28544c6ffc	PR	2026-03-25 18:13:41.323568+00
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
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, name, phone, address, is_cash, created_at, balance) FROM stdin;
ea70b37f-e40d-4d13-a014-52ed6cc34d9e	شركة النيل للتجارة	01012345678	\N	f	2026-03-26 00:07:36.965671+00	0.00
973fbcf1-c2b3-450e-8584-a63cf0885350	ابو يوسف	010757557554	\N	f	2026-03-26 04:02:34.168886+00	0.00
9338ff3f-c554-4648-9965-0b49d68aa7db	شركة الاختبار	\N	\N	f	2026-03-26 09:51:42.641516+00	25.00
\.


--
-- Data for Name: drawer_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drawer_transactions (id, shift_id, type, amount, ref_id, note, created_by, created_at, category_id) FROM stdin;
11ca6cd2-d9c0-42e1-a9e8-e80ccc08978c	609eedda-701a-4531-abb5-91467eacc595	sale	385.00	\N	\N	\N	2026-02-07 16:52:08.542826+00	\N
dde7e4a2-9b04-4145-824e-84ff0d2ca246	609eedda-701a-4531-abb5-91467eacc595	sale	700.00	\N	\N	\N	2026-02-07 16:55:31.453133+00	\N
894e7f55-5ba3-41da-8c6a-7025199aa9ca	609eedda-701a-4531-abb5-91467eacc595	sale	7.00	\N	\N	\N	2026-02-07 16:57:59.61598+00	\N
668fb2c6-cf8c-4b27-b5c2-c7a34be44a18	609eedda-701a-4531-abb5-91467eacc595	sale	7.00	\N	\N	\N	2026-02-07 16:58:17.525194+00	\N
14228221-bee0-4b31-b8b4-73eb2312072e	609eedda-701a-4531-abb5-91467eacc595	sale	350.00	\N	\N	\N	2026-02-07 17:06:01.758293+00	\N
d4e5d205-7e8d-4a88-b42e-5e0382077ad9	609eedda-701a-4531-abb5-91467eacc595	sale	7.00	\N	\N	\N	2026-02-07 17:09:35.129109+00	\N
30bf98d5-11db-4cf1-bdd0-54a30f15612f	609eedda-701a-4531-abb5-91467eacc595	sale	350.00	\N	\N	\N	2026-02-07 17:11:12.810263+00	\N
8c918676-b2f7-4127-9799-9cfe2fa62fd2	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-07 17:53:43.235896+00	\N
521a1b8a-845e-4363-a3b0-348ec660fc0a	609eedda-701a-4531-abb5-91467eacc595	sale	42.00	\N	\N	\N	2026-02-07 17:54:44.926386+00	\N
4af1999b-0961-4258-8330-44635b2d0b60	609eedda-701a-4531-abb5-91467eacc595	sale	1400.00	\N	\N	\N	2026-02-07 21:13:33.603046+00	\N
3325b520-5299-4238-98b7-573f4c80b2e0	609eedda-701a-4531-abb5-91467eacc595	sale	35.00	\N	\N	\N	2026-02-07 21:18:42.656092+00	\N
e097cf01-e343-420e-a315-41a910c4dfad	609eedda-701a-4531-abb5-91467eacc595	sale	21.00	\N	\N	\N	2026-02-07 21:23:31.463665+00	\N
1941d12e-e2cd-4f49-a5b6-7e5243712275	609eedda-701a-4531-abb5-91467eacc595	sale	35.00	\N	\N	\N	2026-02-07 21:26:28.836201+00	\N
e9cf5315-8eb9-43b8-baca-3df26b991ccb	609eedda-701a-4531-abb5-91467eacc595	sale	21.00	\N	\N	\N	2026-02-07 22:00:16.807736+00	\N
22dca9c9-b7c1-4739-b160-1f6baf9990e6	609eedda-701a-4531-abb5-91467eacc595	sale	28.00	\N	\N	\N	2026-02-08 11:26:52.992775+00	\N
7f4aac5c-1879-45c1-920e-ec1c4a41427e	609eedda-701a-4531-abb5-91467eacc595	sale	15.00	\N	\N	\N	2026-02-08 16:24:37.558158+00	\N
647859d1-ab4f-42d9-92ba-49d965304a27	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-08 16:46:31.133491+00	\N
4ca676d9-3f99-4583-9261-d7aa17f982e9	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-08 19:26:37.773692+00	\N
dc352780-4fce-4bbc-90e7-5f3eb4978019	609eedda-701a-4531-abb5-91467eacc595	sale	14.00	\N	\N	\N	2026-02-09 20:25:39.354709+00	\N
42e5a111-3054-428c-98b8-0b1efa9de40f	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-10 12:48:01.763736+00	\N
5d5bd60b-fb9b-4ed3-86fb-8bcf36a989ba	609eedda-701a-4531-abb5-91467eacc595	sale	5.00	\N	\N	\N	2026-02-10 15:43:16.757607+00	\N
2816a774-2051-4861-8113-e230a126b397	609eedda-701a-4531-abb5-91467eacc595	sale	0.00	\N	\N	\N	2026-02-10 15:44:38.091412+00	\N
8211f75a-7af9-49c0-b174-44524c677168	609eedda-701a-4531-abb5-91467eacc595	sale	680.00	\N	\N	\N	2026-02-10 15:58:08.454527+00	\N
4564566f-6679-4286-98c2-8d2aa38f4bfc	8fb616cd-cbf6-4587-9eed-36cba02101b4	sale	0.00	\N	\N	\N	2026-03-24 10:56:08.703+00	\N
246f19d8-fe50-4724-a103-86a23ab8b082	8fb616cd-cbf6-4587-9eed-36cba02101b4	sale	0.00	\N	\N	\N	2026-03-24 11:28:37.026919+00	\N
2105487b-f540-4c57-b1b0-9cb23aacaa11	8fb616cd-cbf6-4587-9eed-36cba02101b4	expense	75.00	\N	مصروف	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:23:44.409309+00	\N
0510177b-8b00-4608-9acd-b07e73f34241	8fb616cd-cbf6-4587-9eed-36cba02101b4	sale	340.00	fa635f6f-c835-40ac-a8e0-d17436acc603	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 19:18:12.618104+00	\N
b566d987-1496-439e-84d6-a654be26ce52	8fb616cd-cbf6-4587-9eed-36cba02101b4	expense	25.00	\N	مصروف شاي وقهوة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 21:32:56.322235+00	\N
cb6280da-1016-44c6-ad53-f9e3d34f866d	ba06a6e8-ef0b-405f-99ca-3870cef7ab96	expense	20.00	\N	مصروف	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 21:34:40.213108+00	\N
142e639b-369c-4ff1-ba71-4eb4045ef602	55cbdec7-b42c-4183-b251-53aaa8f07c1b	sale	215.00	beea6ccd-679c-413a-8a04-5b820ff8df8f	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:02:06.343297+00	\N
a031b8fd-00c2-4ed8-9088-1ef890933923	55cbdec7-b42c-4183-b251-53aaa8f07c1b	sale	215.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:08:53.994403+00	\N
6cd6cf86-260c-4eb5-8b86-b0e9cc19d97f	55cbdec7-b42c-4183-b251-53aaa8f07c1b	expense	30.00	\N	عيش	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:09:13.29495+00	\N
501a87f8-cae0-4bc3-ad8e-0c55154c8335	55cbdec7-b42c-4183-b251-53aaa8f07c1b	return_	215.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:09:25.975637+00	\N
3065be2d-c6df-4f75-b1c2-8522feaa23ca	55cbdec7-b42c-4183-b251-53aaa8f07c1b	sale	60.00	8ffd2445-36b9-4860-b005-711c418cc856	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:11:11.184759+00	\N
f7bb0cc2-5789-44e8-8025-87d6e380b61e	55cbdec7-b42c-4183-b251-53aaa8f07c1b	return_	60.00	8ffd2445-36b9-4860-b005-711c418cc856	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:11:24.303735+00	\N
d675ae27-53b6-43c7-a63b-2bf3498ab60b	ff1dbe65-5402-4af3-a0c4-4b130ef8b11e	expense	10.00	\N	test	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 04:25:11.454619+00	\N
ba0c10aa-1cd5-4ef9-a1ee-d5b2fa916e6e	1dc0d5f0-327a-4708-aff9-26c483ab313b	deposit	500.00	\N	مواصلات	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 05:29:48.274283+00	\N
9a1b7c66-ff1e-4383-bb2e-ed834be6be8f	1dc0d5f0-327a-4708-aff9-26c483ab313b	sale	5250.00	de55ead7-27bd-4e29-ad9a-e7aef4b74978	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 05:30:34.229674+00	\N
63970c64-7987-4053-9560-90b8c3c11a42	1dc0d5f0-327a-4708-aff9-26c483ab313b	deposit	350.00	\N	دفعة من شركة الاختبار	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:00:43.503152+00	\N
ae9a6cc7-05e9-4c6f-b0f9-84bf7ab1e024	1dc0d5f0-327a-4708-aff9-26c483ab313b	sale	90.00	6dda74b4-cb34-4648-8f6e-44fb7a3672b5	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:41:03.717603+00	\N
c058fa85-19c2-4ff6-82c4-e80784d4e7d7	3dcf287f-653a-4299-b80d-c840e1503e2b	sale	100.00	0dce5e50-b8c5-4941-a0f6-cf5a48fd046a	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 15:10:00.472241+00	\N
6bf5cd59-49b8-4f5e-9116-2f97bf7303e0	3dcf287f-653a-4299-b80d-c840e1503e2b	expense	150.00	\N	إيجار شهر مارس	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 12:06:35.936893+00	\N
ecf09251-185b-4fe6-854c-de55a0f260ed	3dcf287f-653a-4299-b80d-c840e1503e2b	deposit	-600.00	\N	دفعة من شركة النيل للتجارة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:01:55.803776+00	\N
9d1acab4-58a7-408e-b4a1-41820237f565	3dcf287f-653a-4299-b80d-c840e1503e2b	deposit	100.00	\N	دفعة من شركة النيل للتجارة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:02.085509+00	\N
a8ed6d06-04e0-4b59-a42a-9b06e65676ad	3dcf287f-653a-4299-b80d-c840e1503e2b	deposit	30.00	\N	عيش	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:23.484892+00	\N
6024021a-b6d7-4a24-8502-97858928c199	3dcf287f-653a-4299-b80d-c840e1503e2b	sale	300.00	7189b418-dcf5-4925-ae01-eee514901aa4	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:49.494187+00	\N
3c5aa4c7-2b63-4ec4-a4c1-45fae4c20c6a	4a7dd547-9642-4562-a0a8-1fa55de24162	sale	50.00	24d4ae60-0bf1-4056-a83c-a5faa958d10b	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 16:56:28.947849+00	\N
3e5ff3ce-ee59-4b0b-982a-3423ab266a82	4a7dd547-9642-4562-a0a8-1fa55de24162	sale	250.00	75e919da-7d78-4dbe-ac0b-3ca8abb7407f	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:18:47.390297+00	\N
6282a980-e92f-442f-b5e7-8057ff8a2a9f	4a7dd547-9642-4562-a0a8-1fa55de24162	sale	90.00	678a4d14-d028-4c24-a72f-0dbaa1bbb258	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:18:55.672741+00	\N
fe76de03-c9d8-44ab-825e-a96391ab4f8f	4a7dd547-9642-4562-a0a8-1fa55de24162	deposit	25.00	\N	دفعة من شركة الاختبار	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:19:20.882728+00	\N
fc5e3d3f-011d-462a-8c40-fee6af6920f1	4a7dd547-9642-4562-a0a8-1fa55de24162	deposit	550.00	\N	مواصلات	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:19:39.619664+00	\N
34c2659b-d774-495e-8e92-bfdfffc8c693	4a7dd547-9642-4562-a0a8-1fa55de24162	expense	200.00	\N	تفويل فطوطة	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:20:02.008717+00	\N
e5696e65-bac1-4f81-a379-7b7c67f1392a	a4a070b3-e6f5-499f-9940-dcd41fcc2188	sale	50.00	deec8934-2282-4a63-bff3-44e6123420fb	\N	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-03-30 13:33:52.40389+00	\N
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
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, subcategory_id, name, barcode, unit, retail_price, wholesale_price, cost_price, company, size, type, material, image_url, is_active, created_at, updated_at, reorder_point, reorder_qty) FROM stdin;
c5e11e14-9dd2-487d-9c2e-27b59ba3408f	d17128f8-94aa-54ce-87d8-4dc515f98bf8	test product to delete	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	f	2026-03-25 18:45:45.235033+00	2026-03-25 18:45:45.331357+00	0.000	0.000
af31725d-fa0f-42df-88d4-9041e36ad994	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور 1 ونص بوصة (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:12:18.345365+00	2026-01-18 20:12:18.345365+00	0.000	0.000
b9b32325-fda4-46a7-b4f4-6da187863e4a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور بولي*بولي  1/2 بوصة (عمر)	\N	عدد	50.00	45.00	40.00	\N	\N	\N	\N	\N	t	2026-01-19 18:59:35.718523+00	2026-02-23 16:13:45.144576+00	0.000	0.000
f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور بولي*بولي 3/4 بوصة (عمر)	\N	عدد	75.00	65.00	60.00	\N	\N	\N	\N	\N	t	2026-01-19 18:59:57.014037+00	2026-02-23 16:14:07.85577+00	0.000	0.000
ca985298-d266-4483-8a13-ff73c90536dc	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور بولي*بولي 1 بوصة (عمر)	\N	عدد	90.00	80.00	72.00	\N	\N	\N	\N	\N	t	2026-01-19 19:02:29.385696+00	2026-02-23 16:14:27.497537+00	0.000	0.000
d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور فالكون 1/2 بوصة	\N	عدد	90.00	85.00	70.00	\N	\N	\N	\N	\N	t	2026-01-20 14:10:40.162417+00	2026-02-23 16:20:02.378763+00	0.000	0.000
ffa8d86a-6352-4d4c-a6f1-76622d09b032	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 2" جويل (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:36:06.982384+00	2026-02-24 11:34:09.274652+00	0.000	0.000
da68d7f2-f8d7-44bb-85a3-d91ab5d02ffa	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 2" PG pluse (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:36:50.56777+00	2026-01-21 09:36:50.56777+00	0.000	0.000
2ac3dc85-e7cf-4ff1-8aff-01e6d8fd54a1	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 2" مياه (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:37:50.742321+00	2026-01-21 09:37:50.742321+00	0.000	0.000
ab4ba887-5c44-4a22-b567-670c0001b603	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية بوصة ونص (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:41:05.350297+00	2026-01-21 09:41:05.350297+00	0.000	0.000
c19f42ec-ad6d-4161-9f38-a9c4cecb643b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 3/4 سالمكو (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:43:07.366133+00	2026-01-21 09:43:07.366133+00	0.000	0.000
6d2e9857-cc51-4c79-aa4d-d7b9e4208678	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 3/4 ِAG	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:43:28.77324+00	2026-01-21 09:43:28.77324+00	0.000	0.000
67ba969e-da10-4bbd-9900-606bf254045b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية PG نص بوصة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:47:44.278206+00	2026-01-21 09:47:44.278206+00	0.000	0.000
d14ac884-8431-46ba-adcb-5190dbaf9da0	d17128f8-94aa-54ce-87d8-4dc515f98bf8	تي نيكل نص بوصة	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:48:02.678005+00	2026-02-24 13:36:49.420851+00	0.000	0.000
695705d9-9757-4f2a-be89-fe096ffd87c2	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 1/2 بوصة AG	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:48:44.598128+00	2026-01-21 09:48:44.598128+00	0.000	0.000
9f86c75d-e220-45e8-95a2-405be7b53488	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بلية 1 بوصة سالمكو (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 10:53:10.372659+00	2026-01-21 10:53:10.372659+00	0.000	0.000
b7d3a006-f7a1-40d6-b3d8-20192e7f93bf	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور سالمكو محمل 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 15:36:22.061533+00	2026-01-21 15:36:22.061533+00	0.000	0.000
b41ae764-b97b-4662-b865-b572790ec127	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور عادي محمل 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 15:36:46.589467+00	2026-01-21 15:36:46.589467+00	0.000	0.000
55cc2075-bfe4-4613-91de-05535390b28a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية بلاستيك	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 16:36:03.564033+00	2026-02-21 21:45:13.511767+00	0.000	0.000
85114c68-11e1-442b-a79d-0279c2bb798b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية سكاي 3/4	\N	عدد	220.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 16:37:17.691787+00	2026-02-23 19:46:18.799931+00	0.000	0.000
056ef88b-f53d-4806-9e24-f9f931f54dcf	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية 3/4" PG (يوسف)	\N	عدد	280.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 17:57:09.849733+00	2026-02-23 19:46:14.704199+00	0.000	0.000
0eb4a2fa-6d82-4005-bbb7-c958edcf281a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية نحاس بلية1 بوصة (يوسف)	\N	عدد	380.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 18:00:15.242202+00	2026-02-21 21:44:58.682402+00	0.000	0.000
92a238d8-f2da-4c28-9127-fbc8cece0c0b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية بوز بلاستيك AG (يوسف)	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 18:20:28.450377+00	2026-02-21 15:14:45.910048+00	0.000	0.000
53a3e08e-728d-4291-b2f7-9cc69a69cbac	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية ايطالي نص بوصة (يوسف)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 19:56:06.791359+00	2026-02-21 15:16:06.543079+00	0.000	0.000
982d6fa2-8c29-4580-863a-215600003c9b	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية نحاس AG نص بوصة (يوسف)	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 10:21:43.6071+00	2026-02-21 15:15:10.630101+00	0.000	0.000
bca0c8ae-6b62-4ad0-a150-47fbd9955eab	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية كوبشة شيلد (عمار)	\N	عدد	180.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:33:28.660709+00	2026-02-23 19:47:15.577099+00	0.000	0.000
4008a90d-eda0-4bc9-b7d9-0401c419b3e1	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية كوبشة شجرة	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:34:25.603146+00	2026-02-23 19:47:19.616332+00	0.000	0.000
bd473534-32ba-4522-912d-ab3c9f59ac24	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية غسالة تركي OM	\N	عدد	190.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:34:47.580728+00	2026-02-23 19:48:02.91339+00	0.000	0.000
27b32f29-2ac8-445e-aaf4-531e4cabd48c	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية 3/4 بزبوز بلاستيك	\N	عدد	180.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 13:07:55.312027+00	2026-02-23 19:49:11.168989+00	0.000	0.000
811c48aa-84b6-4bed-9771-3e6dd162e9a6	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية استانلس فايف ستار	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000
4b596a39-71ad-4be0-adcb-82637141438e	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية استانلس تورو	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000
fd927c9a-2843-4740-b97e-c92f51424765	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية فايف ستار اسود	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000
b09598b6-4537-4e39-b28b-d50cb6d8d19a	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس سما	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000
bf75d681-d9d1-4af8-871f-2ed687b63fd1	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية كعب نحاس	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000
4c7f2b6e-8a67-489f-ad91-257ba78a7f51	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاويه اوزو	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-02-21 21:46:47.802043+00	0.000	0.000
ec991740-f53e-42ea-9e48-6af7a7696248	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس فايف ستار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:46:12.866726+00	2026-01-29 12:46:12.866726+00	0.000	0.000
5b18456a-9aee-431f-8344-81bda7d32061	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية مكة	\N	عدد	130.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:50:33.033144+00	2026-01-29 12:50:33.033144+00	0.000	0.000
ed7dc576-4868-491e-847f-08379201a129	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس بالأكور 3/4 BG	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 13:33:59.109432+00	2026-01-30 13:33:59.109432+00	0.000	0.000
06030f57-05d3-4624-ab21-4f2dbd36628c	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية بلاستيك تركي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 09:40:16.889555+00	2026-02-10 09:40:16.889555+00	0.000	0.000
92d27d2a-5f22-47c2-a167-4b6fc0908e3e	d17128f8-94aa-54ce-87d8-4dc515f98bf8	حنفية بلية 1/2 فيدمار	\N	قطعة	150.00	135.00	125.00	\N	\N	\N	\N	\N	t	2026-03-15 16:46:04.748045+00	2026-03-15 16:46:04.748045+00	0.000	0.000
6c1a7601-4298-4f3f-be83-c3e4abdedaf4	d17128f8-94aa-54ce-87d8-4dc515f98bf8	محبس زاوية	\N	قطعة	60.00	35.00	31.00	\N	\N	\N	\N	\N	t	2026-03-15 17:12:44.252251+00	2026-03-15 17:12:44.252251+00	0.000	0.000
9d19a1d3-c280-4944-879b-0db02b1ebfc9	7f15ec9b-720f-580d-ad54-61fcb04a20d9	وش نيكل خفيف (عمر)	\N	عدد	20.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:55:34.840636+00	2026-02-23 19:51:36.048033+00	0.000	0.000
244e72f6-2f15-49f4-8526-3b485ebb345b	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة فيدمار سوداء (الكوك)	\N	عدد	280.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:22:00.846063+00	2026-02-21 15:05:32.004398+00	0.000	0.000
7652a593-90d8-4ba8-9bf0-d1f452915da4	7f15ec9b-720f-580d-ad54-61fcb04a20d9	ماسورة دش دفن مدورة (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:24:50.477843+00	2026-02-23 19:52:11.728847+00	0.000	0.000
13ab7f8d-4d5c-495d-9665-b12b51ba8097	7f15ec9b-720f-580d-ad54-61fcb04a20d9	ماسورة دش دفن عكاز (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:27:22.798+00	2026-02-24 13:32:50.124984+00	0.000	0.000
b3634d52-7df0-4e6c-89a9-2887f761f7aa	7f15ec9b-720f-580d-ad54-61fcb04a20d9	ماسورة دش دفن مربعة طويلة (الكوك)	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:28:21.375167+00	2026-02-23 19:52:28.863685+00	0.000	0.000
ae78cb21-9bf8-441a-a101-6be57eb4f2c0	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة لومي (يوسف)	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:52:34.272681+00	0.000	0.000
8cf7eef1-0a73-491c-b6cc-8222f3c45595	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش بلاستيك	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:53:02.464566+00	0.000	0.000
bf47a971-4a38-4adf-84b7-0f838da38a57	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش ساليمكو	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:53:22.305053+00	0.000	0.000
65907699-7b64-4dd9-9ea8-d9f8cb23c6f4	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة شاور ست	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-01-29 12:42:36.459591+00	0.000	0.000
3e6b7157-4754-456c-a3ef-63d087e40dd3	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش هاند شاور	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-01-29 12:42:36.459591+00	0.000	0.000
d1aa753f-65da-40f1-8548-eed1df9fac72	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش طيبة بلاستيك	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-24 13:33:27.884694+00	0.000	0.000
0a078193-e0d3-4669-b71b-5a4fdda5f8f9	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة دش طيبة سرعات	\N	عدد	180.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:53:52.30356+00	0.000	0.000
d268cf2c-4306-4069-92de-d1879e230952	7f15ec9b-720f-580d-ad54-61fcb04a20d9	محول سماعة صامولة	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:54:05.665427+00	0.000	0.000
3a6f01a4-e9a4-4032-8b64-35410b5a8d5e	7f15ec9b-720f-580d-ad54-61fcb04a20d9	محول سماعة بدون صاموصة	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:54:11.77727+00	0.000	0.000
ff053f4f-7e5e-44a6-a452-893663ae65be	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة فايدمار سوداء	\N	عدد	280.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:54:42.39868+00	0.000	0.000
d75fcff2-ef64-48b3-9cd8-e06d40e3a399	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة فيدمار بيضاء	\N	عدد	250.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:42:36.459591+00	2026-02-23 19:54:26.832+00	0.000	0.000
17ef1e9c-6898-494a-8e97-ecf2af3f72fb	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دوش 1مم 20 * 20 استانلس رانك محملة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-02-23 19:54:57.02382+00	0.000	0.000
871b0c43-957e-4eb5-b5f0-4609014c1885	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش مدورة كبيرة بلاستيك	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-02-24 13:30:55.406705+00	0.000	0.000
a4d3df08-ac1d-4f42-82f3-da2fdbeb1958	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 15 * 15 بلاستيك	\N	عدد	100.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-02-24 13:32:28.835548+00	0.000	0.000
c06966da-9cdb-4ed6-9296-177f3a63b307	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دوش 1" 20 * 20 استانلس روما محملة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000
7838761b-9eb9-46bb-a99e-c09e677377a9	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 10 * 10 استلس لافينا	\N	عدد	90.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-02-24 13:33:59.227101+00	0.000	0.000
7e625f21-6107-40ed-a03a-280e64655065	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 10 * 10 سنبرس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000
432e6e7e-c5ea-4639-a2ca-b3cac3b07617	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش استانلس 10 * 10 جولدن ارو	\N	عدد	90.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-02-24 13:34:44.651586+00	0.000	0.000
1a73646e-94d9-4857-92dc-496a90475520	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 20*20 سان ارساني (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000
813e8a9d-af7f-496c-80da-0eab496e15df	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 15 * 15 ارساني	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000
a59c2e11-fed2-4972-a7e5-bc34fd5266fd	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 10 * 10 ترنتي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000
ba07f41a-a9f8-4e30-bb91-be5cfa125019	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 15 * 15 ترنتي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000
4005644b-b6d1-45f8-8af9-7929eca4e075	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دوش 15 * 15 جولدن ارو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000
ff6f769c-0bfb-49fc-86cf-e73805d51892	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طاسة دش 20 * 20 بلاستيك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:43:30.531794+00	2026-01-29 12:43:30.531794+00	0.000	0.000
f0b0cc99-32e6-4b1a-8493-25be82e03e31	7f15ec9b-720f-580d-ad54-61fcb04a20d9	طبة حوض نيكل(أنس)	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 15:41:13.227521+00	2026-02-24 13:35:37.14787+00	0.000	0.000
edf6547d-ee07-419d-a822-18de5c4ac63d	7f15ec9b-720f-580d-ad54-61fcb04a20d9	بوش نيكل 3/4*1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:57:47.40477+00	2026-02-01 16:57:47.40477+00	0.000	0.000
83759832-7ee5-43fc-8828-695b2d8c7c3e	7f15ec9b-720f-580d-ad54-61fcb04a20d9	صامولة سيخ شطاف	\N	عدد	10.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:03:52.832692+00	2026-02-24 13:35:44.412006+00	0.000	0.000
3892616c-8ad0-47d2-aebc-ba3c30cefb39	7f15ec9b-720f-580d-ad54-61fcb04a20d9	محول سماعه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:41:52.557812+00	2026-02-01 17:41:52.557812+00	0.000	0.000
cd3b2528-421e-4761-b84e-90651f4cfd3f	7f15ec9b-720f-580d-ad54-61fcb04a20d9	صبانه استالس	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:23:21.840221+00	2026-02-24 13:36:31.595819+00	0.000	0.000
309e1a4a-3b5b-4aba-a3f0-375f8bb26b69	7f15ec9b-720f-580d-ad54-61fcb04a20d9	حله 0.5 مللي فيدمار ك	\N	قطعة	750.00	520.00	465.00	\N	\N	\N	\N	\N	t	2026-03-15 16:37:15.629092+00	2026-03-15 16:48:26.281471+00	0.000	0.000
f9256353-ac61-4e15-8dff-4cad2591bda2	7f15ec9b-720f-580d-ad54-61fcb04a20d9	حله 0.5 فيدمار ص	\N	قطعة	480.00	380.00	285.00	\N	صغير	\N	\N	\N	t	2026-03-15 16:40:15.885174+00	2026-03-15 16:40:15.885174+00	0.000	0.000
35f48cd9-aa95-45dc-91f8-239baa9e8572	7f15ec9b-720f-580d-ad54-61fcb04a20d9	حله 1 ملي فيدمار ص	\N	قطعة	850.00	750.00	645.00	\N	\N	\N	\N	\N	t	2026-03-15 16:42:33.251321+00	2026-03-15 16:44:07.146783+00	0.000	0.000
ff573b1e-dc23-4f5c-b48b-ca3aa2ae1a1a	7f15ec9b-720f-580d-ad54-61fcb04a20d9	حله 5 زرار فيدمار	\N	قطعة	5500.00	4850.00	3750.00	\N	\N	\N	\N	\N	t	2026-03-15 16:47:55.014009+00	2026-03-15 16:47:55.014009+00	0.000	0.000
7ff32213-f0de-403c-a2b4-df7c66a07a1f	7f15ec9b-720f-580d-ad54-61fcb04a20d9	جلبة تطويل استالس	\N	قطعة	45.00	26.00	21.00	\N	\N	\N	\N	\N	t	2026-03-15 17:00:35.852613+00	2026-03-15 17:00:35.852613+00	0.000	0.000
9eff5877-e547-41bf-980d-10c679112e9c	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة لوكس تكات	\N	قطعة	150.00	95.00	80.00	\N	\N	\N	\N	\N	t	2026-03-15 17:15:33.643842+00	2026-03-15 17:15:33.643842+00	0.000	0.000
1d1a007d-0b0d-40fe-9be0-7116cf80a675	7f15ec9b-720f-580d-ad54-61fcb04a20d9	سماعة عادية	\N	قطعة	130.00	85.00	70.00	\N	\N	\N	\N	\N	t	2026-03-15 17:17:02.331845+00	2026-03-15 17:17:02.331845+00	0.000	0.000
128ffb7a-b57c-424e-bd25-b6e16dce002d	903c8f75-9786-51d1-956e-f481e1dbf84f	اوكرة بلاستيك شفاف (عمار)	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:14:12.808976+00	2026-02-21 14:58:56.295044+00	0.000	0.000
9599e8f6-0e41-4ba6-af39-945ab7b97b91	903c8f75-9786-51d1-956e-f481e1dbf84f	اوكرة جاجوار (ادهم)	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:25:15.651997+00	2026-02-21 14:55:28.606925+00	0.000	0.000
4e58a261-a2db-4aa2-8a1b-5a4a38ebfed2	903c8f75-9786-51d1-956e-f481e1dbf84f	اوكرة وردة (ادهم)	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:26:03.635992+00	2026-02-21 14:55:40.213622+00	0.000	0.000
4223c273-9145-42c8-8bb6-e2faf2b7a9b4	903c8f75-9786-51d1-956e-f481e1dbf84f	اوكرة بلاستيك (ادهم)	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:26:48.852523+00	2026-02-21 15:00:07.253837+00	0.000	0.000
c0897fde-d9e6-4626-b027-149b7ae5322e	903c8f75-9786-51d1-956e-f481e1dbf84f	يد هاند ميكسر عريضة محملة جداً (عمار)	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:39:46.244078+00	2026-02-21 15:01:49.492589+00	0.000	0.000
b1690bbc-ba39-4da5-85ea-7e75005ded9b	903c8f75-9786-51d1-956e-f481e1dbf84f	يد هاند ميكسر عريضة محملة (عمار)	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:41:45.683618+00	2026-02-21 15:01:54.47049+00	0.000	0.000
d387eae9-d064-43d1-ad43-461553cf6a05	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل نيكل 1 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:43:22.452043+00	2026-01-20 13:43:22.452043+00	0.000	0.000
958976e5-78b1-48dd-b90c-639ecac8608e	eac36a6f-f7ef-5e8e-9ca9-443292af7e18	نبل نيكل نص بوصة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:45:52.790075+00	2026-01-21 09:45:52.790075+00	0.000	0.000
84d19c17-a7a2-4523-9693-5c45c88a5e48	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بولي 3/4 بوصة (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:14:53.186684+00	2026-01-20 14:14:53.186684+00	0.000	0.000
6a92aee9-a9f4-490d-bf5f-37ca073ba4f8	e2dfb819-1be4-50bd-8612-e411aaa719d5	لاكور بولي 1/2 بوصة (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:15:16.691315+00	2026-01-20 14:15:16.691315+00	0.000	0.000
70afd455-12ab-4f85-9e1a-5868e01b1511	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	جلبة نيكل 2/1 بوصة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:02:53.393661+00	2026-01-20 15:02:53.393661+00	0.000	0.000
6972c97c-fdb0-4a9b-b563-06ec0ac883c3	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	طبة نيكل 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:39:22.422214+00	2026-01-21 09:39:22.422214+00	0.000	0.000
1fe12fb1-b560-4cda-b0cc-db6f35c24079	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	كوع عادة نص بوصة محمل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:42:21.574265+00	2026-01-21 09:42:21.574265+00	0.000	0.000
340dd769-792d-4917-9d5e-5d73c4eb605d	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	افيز لاتش 2" (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:44:15.445975+00	2026-01-21 09:44:15.445975+00	0.000	0.000
c9baaa25-10f2-481b-aa74-81d2c5a83f70	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	افيز لاتش نص بوصة (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:44:35.814227+00	2026-01-21 09:44:35.814227+00	0.000	0.000
d29b5399-d05a-441e-907e-664b9caaded4	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	كعب خلاط استالنس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:46:58.581873+00	2026-02-23 16:46:08.349315+00	0.000	0.000
980318ab-6084-4cf4-9ee7-b095ffcf96e6	8a44ea94-e593-5cc1-bce2-d57efdfa53f3	جلبة سوستة طويلة	\N	قطعة	70.00	45.00	35.00	\N	\N	\N	\N	\N	t	2026-03-15 17:21:28.131328+00	2026-03-15 17:21:28.131328+00	0.000	0.000
111bc6b3-d484-49b9-adab-2e9790badcde	de8ac890-fee4-5705-8bd1-25c72f48474c	كيس مسامير قلب خشن (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-02-20 16:41:50.943661+00	0.000	0.000
d739fea9-b75f-4059-901f-eec4c0483b53	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب هاند ميكسر تكات كبير (عمار)	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:27:53.619265+00	2026-02-25 12:50:19.524203+00	0.000	0.000
f3a41c82-cd3e-4ac8-a3cf-49c9a046410c	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب هاند ميكسر بكعب صغير (عمار)	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:31:49.419637+00	2026-02-25 12:50:30.693523+00	0.000	0.000
2eed92b4-8064-48ee-9f2d-7c302bbdb2aa	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب هاند ميكسر بدون كعب صغير (عمار)	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:32:28.500164+00	2026-02-25 12:50:38.166004+00	0.000	0.000
b1a685ab-b142-4c3d-95c9-d9100774032d	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب هاند ميكسر بدون كعب كبير (عمار)	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:33:17.684343+00	2026-02-25 12:50:44.563536+00	0.000	0.000
0ae66dbf-16a0-48bf-b13e-eed2701f3cc6	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب هاند ميكسر بكعب كبير (عمار)	\N	عدد	70.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:37:43.363781+00	2026-02-25 12:50:59.302635+00	0.000	0.000
02108d69-33a5-41c9-82f6-6601fc7c7e56	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب هاند ميكسر تكات صغير (عمار)	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:38:44.947628+00	2026-02-25 12:51:18.99807+00	0.000	0.000
e55b3b91-07db-49dd-a8c0-10d76d164e42	de8ac890-fee4-5705-8bd1-25c72f48474c	نبل نيكل 3/4 بوصة (عمار)	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:44:02.371266+00	2026-02-25 12:51:28.836553+00	0.000	0.000
2a2a52bb-b8d8-4af4-93d6-41ed8267a589	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب 1/2	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:44:10.223261+00	2026-02-25 12:47:47.14025+00	0.000	0.000
66a706c3-065f-4965-b6f5-a416003ca375	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب جولد صغير	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:44:29.582588+00	2026-02-25 12:47:57.925671+00	0.000	0.000
1e06fee4-89c2-4465-bc78-5b71826b797e	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب 3.5 ايطالي	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:45:02.640757+00	2026-02-25 12:48:03.493108+00	0.000	0.000
78539233-0e35-4584-8a63-835c6f128067	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب 3 لينيا	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:45:48.201209+00	2026-02-25 12:48:17.700677+00	0.000	0.000
e2623548-7fd4-4a00-99a6-d772fbc76efa	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن 1/2	\N	عدد	80.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:48:17.733307+00	2026-02-25 12:48:31.396701+00	0.000	0.000
708b57dc-834f-466c-8df4-62b50eb8affb	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن 3/4 صغير	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:48:39.412528+00	2026-02-25 12:48:49.318275+00	0.000	0.000
c1186f95-835b-4480-96a0-8a0b3edfd1d6	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن 3/4 كبير مربع	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:49:13.489254+00	2026-01-26 22:49:13.489254+00	0.000	0.000
a710b7fe-897e-43da-808a-c193b7e5573e	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن 1 بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:49:33.00445+00	2026-01-26 22:49:33.00445+00	0.000	0.000
1ab3227c-7697-46a5-8d66-861e81721181	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب دفن كبير 3/4	\N	عدد	100.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:49:53.950398+00	2026-02-25 12:49:11.444792+00	0.000	0.000
307e8ebe-dc59-4130-bdc0-363ea0d4caea	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب جولد كبير	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:50:48.984631+00	2026-02-25 12:49:17.124681+00	0.000	0.000
446e88dc-63ad-49b3-9018-6042e55df88e	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل نحاس	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:52:55.978731+00	2026-02-25 12:49:25.734054+00	0.000	0.000
76974cd1-2978-4467-ae5a-b558aa71c242	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل استانلس	\N	عدد	15.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:52:55.978731+00	2026-02-25 12:49:37.380574+00	0.000	0.000
e6b6fddb-3d45-4e26-87b1-a5d13cd14132	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل استانلس 5 سم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:52:55.978731+00	2026-01-29 12:52:55.978731+00	0.000	0.000
40cdebca-7a06-49c2-a5fa-850250936c54	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل نحاس (1)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:53:16.867499+00	2026-01-29 12:53:16.867499+00	0.000	0.000
72d5081a-5a3c-42f1-af96-68799e6498d8	de8ac890-fee4-5705-8bd1-25c72f48474c	جلبة تطويل ماتور	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:53:16.867499+00	2026-01-29 12:53:16.867499+00	0.000	0.000
e178893c-75cf-4e65-a118-70dd4ab0e610	de8ac890-fee4-5705-8bd1-25c72f48474c	قلب 3.5 عادي	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 15:14:21.377007+00	2026-02-25 12:51:49.25243+00	0.000	0.000
db85a468-811d-49b2-8f84-89c4f1aaa3d5	f170e76b-4135-5781-b898-91e1259af14f	سوستة 60 محملة فايف ستار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:29:02.765329+00	2026-01-22 15:29:02.765329+00	0.000	0.000
24717bd9-9cb5-47b1-9e14-4780dd676eb3	f170e76b-4135-5781-b898-91e1259af14f	سوستة 60 محملة روتانا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:30:33.245796+00	2026-01-22 15:30:33.245796+00	0.000	0.000
4b6005cc-aac8-4964-8031-d08ff8f50372	f170e76b-4135-5781-b898-91e1259af14f	سوستة 50 محملة روتانا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:33:15.214038+00	2026-01-22 15:33:15.214038+00	0.000	0.000
cf47fda2-2f58-48c3-aa6e-e33743683878	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة محملة 60 فايف ستار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:35:12.396915+00	2026-01-22 15:35:12.396915+00	0.000	0.000
68051f41-2be1-42c1-bed7-53af6544d15b	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة حراري متر ونص فايف ستار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:38:52.731585+00	2026-01-29 12:38:52.731585+00	0.000	0.000
e34c6775-3e66-462d-80db-5bb4fff9601a	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة حراري 2 متر فايف ستار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:38:52.731585+00	2026-01-29 12:38:52.731585+00	0.000	0.000
1a29b242-fcb5-49a2-95fd-a12c0de7c030	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة الرحمة (الكوك)	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:38:52.731585+00	2026-02-21 14:35:52.182506+00	0.000	0.000
879040b7-642e-443d-a467-cb4a3cbc5bc3	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة ستار محملة (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-01-29 12:39:59.0912+00	0.000	0.000
ae005153-de66-49ed-b132-23434ecacf5c	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة ستار خفيفة (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-01-29 12:39:59.0912+00	0.000	0.000
0fd12267-532b-4474-b66e-a1ffa378a6c9	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة جروهي (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-01-29 12:39:59.0912+00	0.000	0.000
8efe2eb5-bd06-48bb-b1ae-b843129e85eb	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 60 سم (يوسف)	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-02-21 14:35:41.541678+00	0.000	0.000
72635b19-9fcc-4fd6-9ada-b9cf33bb50a0	f170e76b-4135-5781-b898-91e1259af14f	سوستة قنطرة الوان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:39:59.0912+00	2026-01-29 12:39:59.0912+00	0.000	0.000
3d23ca07-4628-4207-a0a3-e34c38daf932	f170e76b-4135-5781-b898-91e1259af14f	سوستة ناشفة 60سم (انس)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:49:36.400484+00	2026-01-30 14:49:36.400484+00	0.000	0.000
19a8cf3f-9008-41b9-8383-3a361d6c6f59	f170e76b-4135-5781-b898-91e1259af14f	سوستة متر عادية (انس)	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:49:58.992836+00	2026-02-21 14:31:42.695296+00	0.000	0.000
03c117ec-5a52-40c6-907f-ece60dddfe68	f170e76b-4135-5781-b898-91e1259af14f	سوستة 70سم (انس)	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:50:42.384657+00	2026-02-21 14:31:18.551665+00	0.000	0.000
2e2fe069-9320-4585-b0eb-b079dcf40692	f170e76b-4135-5781-b898-91e1259af14f	سوستة 90سم (انس)	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:50:58.704623+00	2026-02-21 14:30:55.649113+00	0.000	0.000
a1651be8-8cf4-4662-b40f-2173c9bef33d	f170e76b-4135-5781-b898-91e1259af14f	سوستة 80سم (انس)	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:51:11.568774+00	2026-02-21 14:30:49.673894+00	0.000	0.000
5f551abc-5798-4f04-8557-01afc73bb977	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 90سم (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:51:26.448063+00	2026-01-30 14:51:26.448063+00	0.000	0.000
6e4b57c6-a303-4249-9f3c-7075f1a14bce	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 80سم (الكوك)	\N	عدد	55.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:51:40.22396+00	2026-02-21 14:35:34.906947+00	0.000	0.000
a3b2e66c-e781-4009-a566-0a5285a513ef	f170e76b-4135-5781-b898-91e1259af14f	سوستة 70سم (الكوك)	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:52:05.521177+00	2026-02-21 14:30:43.752266+00	0.000	0.000
5660d767-7d28-4b31-a146-9c7071134ce8	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 50سم (يوسف والكوك)	\N	عدد	40.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:52:33.084658+00	2026-02-21 14:34:03.064735+00	0.000	0.000
04e83173-2a26-4e61-b3be-456de3b641f9	f170e76b-4135-5781-b898-91e1259af14f	سوستة 60سم (انس)	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:53:05.184302+00	2026-02-21 14:30:36.759252+00	0.000	0.000
858d8c6c-94bc-4b7b-9bf6-f5aaf4cc7aca	f170e76b-4135-5781-b898-91e1259af14f	سوستة 50سم (انس)	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:53:31.375983+00	2026-02-21 14:30:31.736236+00	0.000	0.000
311f37ca-8c7f-4b3c-a32a-4bd675dd929b	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 40سم (الكوك)	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:53:56.656353+00	2026-02-21 14:33:39.367351+00	0.000	0.000
99d7b5a5-446f-44a9-82fc-17d6745c25f6	f170e76b-4135-5781-b898-91e1259af14f	سوستة شجرة 3/8 (عمر وميدو)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:55:14.544742+00	2026-01-30 14:55:14.544742+00	0.000	0.000
3e463d34-e6d9-43cb-b0c8-a6c76be8290a	f170e76b-4135-5781-b898-91e1259af14f	سوستة 3/8 * 3/8 (عمر وميدو)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:55:43.701823+00	2026-01-30 14:55:43.701823+00	0.000	0.000
4f371ebc-a80b-413d-8224-7c7458e3fc6a	f170e76b-4135-5781-b898-91e1259af14f	سوستة 10سم (الكوك)	\N	عدد	20.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:56:22.223581+00	2026-02-21 14:30:08.421871+00	0.000	0.000
a470a716-8bc7-4c3b-a4d2-ada3f0dafdd9	f170e76b-4135-5781-b898-91e1259af14f	سوستة 3/8 * 3/8 محملة (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:56:46.094901+00	2026-01-30 14:56:46.094901+00	0.000	0.000
d4f387cf-2b6a-4ca0-ba1c-099b594a5949	f170e76b-4135-5781-b898-91e1259af14f	سوستة 40سم (انس)	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:57:01.999862+00	2026-02-21 14:29:54.517735+00	0.000	0.000
357dad92-ae44-40df-98d6-135586d4f7c9	f170e76b-4135-5781-b898-91e1259af14f	سوستة 30سم (انس)	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:57:11.11977+00	2026-01-30 14:57:11.11977+00	0.000	0.000
d159b603-06ca-4d80-b251-120ca04bd0ee	f170e76b-4135-5781-b898-91e1259af14f	سوستة 20سم (انس)	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:57:23.792768+00	2026-01-30 14:57:23.792768+00	0.000	0.000
aabb6a08-a5c6-4a2c-b7dd-66ec1e019393	f170e76b-4135-5781-b898-91e1259af14f	سوستة سماعة ايطالي متر ونص	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:28:55.910952+00	2026-02-10 13:28:55.910952+00	0.000	0.000
88420337-987a-48a0-a9db-fb0769395f8b	f170e76b-4135-5781-b898-91e1259af14f	سوستة سخان 50 سم	\N	قطعة	35.00	14.00	10.00	\N	\N	\N	\N	\N	t	2026-03-15 17:27:24.635008+00	2026-03-15 17:27:24.635008+00	0.000	0.000
e529e2cf-83ac-4047-a94a-d0089030b1a4	f170e76b-4135-5781-b898-91e1259af14f	سوستة سخان 30 سم	\N	قطعة	35.00	14.00	10.00	\N	\N	\N	\N	\N	t	2026-03-15 17:28:34.179202+00	2026-03-15 17:28:34.179202+00	0.000	0.000
85be72d3-5d91-4bc1-8bc8-73b53c083490	f170e76b-4135-5781-b898-91e1259af14f	سوستة 70 سم	\N	قطعة	50.00	19.00	15.00	\N	\N	\N	\N	\N	t	2026-03-15 17:30:24.066428+00	2026-03-15 17:31:09.569293+00	0.000	0.000
200ed75f-470f-490a-9dbb-56886e13ecd0	f170e76b-4135-5781-b898-91e1259af14f	سوستة 80 سم	\N	قطعة	60.00	19.00	15.00	\N	\N	\N	\N	\N	t	2026-03-15 17:32:35.923758+00	2026-03-15 17:32:35.923758+00	0.000	0.000
50d2a42b-4735-4fb8-924d-8d86cbdcd133	f170e76b-4135-5781-b898-91e1259af14f	سوستة 100 سم	\N	قطعة	70.00	19.00	15.00	\N	\N	\N	\N	\N	t	2026-03-15 17:33:50.515367+00	2026-03-15 17:33:50.515367+00	0.000	0.000
a21a8080-f94d-4927-bf0b-2390e2500059	3990e818-7790-55bf-9cf9-6a7e45c45026	صامولة زنق نحاس 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:54:36.9018+00	2026-02-01 16:54:36.9018+00	0.000	0.000
a7861f0d-2057-4965-97f3-26b745cbbc8b	3990e818-7790-55bf-9cf9-6a7e45c45026	صامولة زنق نحاس 1بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:55:54.273374+00	2026-02-01 16:55:54.273374+00	0.000	0.000
7e3e1e0b-859d-4b02-abd3-95199402ec4c	0a625299-9939-57bf-9214-75c4fa91e993	ثمن لزق 900 بارد (الكوك)	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-02-21 14:44:45.685867+00	0.000	0.000
eef8c1af-7cf9-4222-8baa-43bf0094c923	0a625299-9939-57bf-9214-75c4fa91e993	ثمن لزق 914 حار (الكوك)	\N	عدد	80.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-02-21 14:45:14.35981+00	0.000	0.000
dbdb45fe-083e-42bb-b3c8-df69ec408f8d	0a625299-9939-57bf-9214-75c4fa91e993	ربع لزق 900 بارد (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-02-21 14:49:57.301562+00	0.000	0.000
8edab49c-8f12-47b1-963d-8adea2c8ce02	0a625299-9939-57bf-9214-75c4fa91e993	ربع لزق 914 حار (عمار)	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-02-21 14:50:08.486495+00	0.000	0.000
13d75310-8904-479f-9803-f13687b3bb57	0a625299-9939-57bf-9214-75c4fa91e993	نص لزق 914 حار (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:00:25.803028+00	2026-01-18 19:00:25.803028+00	0.000	0.000
cd65e985-404b-46db-819e-af8c5163937a	0a625299-9939-57bf-9214-75c4fa91e993	لزق مواسير عريض كبير (ادهم)	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:01:31.323747+00	2026-02-21 14:51:14.965896+00	0.000	0.000
09ac1895-0aa4-46d7-bf13-4f5d0a4d5c60	0a625299-9939-57bf-9214-75c4fa91e993	لزق مواسير عريض صغير (ادهم)	\N	عدد	30.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:01:59.450741+00	2026-02-21 14:51:57.510829+00	0.000	0.000
0f662576-a144-4692-ad0b-937314746bdc	0a625299-9939-57bf-9214-75c4fa91e993	نص لزق 900 بارد (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:56:00.681382+00	2026-01-18 19:56:00.681382+00	0.000	0.000
14089411-b7a2-4a4e-b9d0-f4efb8cc75c0	0a625299-9939-57bf-9214-75c4fa91e993	ربع لحام رمادي 917 (احمد حماية الله)	\N	عدد	170.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:56:53.225459+00	2026-02-21 14:53:42.359321+00	0.000	0.000
27f3d0ff-1203-4b97-81e8-3be4720852e2	0a625299-9939-57bf-9214-75c4fa91e993	سليكون عضم ابيض (عمر)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:54:13.696396+00	2026-02-21 14:54:07.302153+00	0.000	0.000
2063f0a4-2037-4436-937e-bb771626b4d0	0a625299-9939-57bf-9214-75c4fa91e993	سيليكون عضم رمادي (عمر)	\N	عدد	130.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:54:21.896209+00	2026-02-21 14:54:29.015895+00	0.000	0.000
a57e4eab-cbcf-4bf5-b649-33206c8e5efd	0a625299-9939-57bf-9214-75c4fa91e993	ثمن لزق رمادي 917 (عمر)	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 21:04:34.039761+00	2026-02-21 14:54:37.206924+00	0.000	0.000
8d3a98f2-685a-417d-9600-8d0b51d74d97	0a625299-9939-57bf-9214-75c4fa91e993	لزق اوزو حار (عمار)	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 20:27:41.543325+00	2026-02-21 14:54:46.484037+00	0.000	0.000
a4997b77-66bf-4b4f-ae74-74762dd0712c	3eafb215-ee16-58c9-b9ec-7033aa951137	بكرة تفلون صغيرة (احمد حماية الله)	\N	عدد	5.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 18:53:32.586762+00	2026-01-18 18:53:32.586762+00	0.000	0.000
5f8e2238-5325-4ff2-b77e-05d6398eb000	3eafb215-ee16-58c9-b9ec-7033aa951137	بكرة تفلون وسط (عمر)	\N	عدد	10.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:00:20.898163+00	2026-02-21 14:40:24.136019+00	0.000	0.000
8b6e0771-fc64-4898-9a82-e408dec91136	3eafb215-ee16-58c9-b9ec-7033aa951137	بكرة تفلون بوش (عمر)	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:00:29.83319+00	2026-02-21 21:37:08.0089+00	0.000	0.000
2f3e5183-d945-419c-aba7-63cde2d18b66	3eafb215-ee16-58c9-b9ec-7033aa951137	سيليكون عادي (عمر)	\N	عدد	75.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 20:09:36.338117+00	2026-02-21 21:47:45.17857+00	0.000	0.000
43b85fea-b00f-4300-b4e2-48505f28e8c5	3eafb215-ee16-58c9-b9ec-7033aa951137	تفلون شنطة ص	\N	قطعة	5.00	3.50	2.50	\N	\N	\N	\N	\N	t	2026-03-15 17:02:41.692515+00	2026-03-15 17:02:41.692515+00	0.000	0.000
79901430-1032-480c-b559-9ddc203f643f	3eafb215-ee16-58c9-b9ec-7033aa951137	تفلون مضغوط (بوش)	\N	قطعة	30.00	14.00	10.50	\N	\N	\N	\N	\N	t	2026-03-15 17:04:59.620263+00	2026-03-15 17:04:59.620263+00	0.000	0.000
c00d945c-163e-4291-9788-c7c48cde10b6	7b07a8a7-291e-504c-82ec-e7b14467ff8c	شكرتون كهرباء عادي	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 16:37:07.609221+00	2026-01-27 16:37:07.609221+00	0.000	0.000
e738439d-440a-4f78-9dc6-83fe84f8670d	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20*20 محمل عادة فايف ستار (الكوك)	\N	عدد	195.00	175.00	163.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-02-23 16:35:00.9513+00	0.000	0.000
767f8dde-1ac2-4a50-8afb-982ff0b34fa9	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15*15 محمل عادة فايف ستار بلاطة	\N	عدد	150.00	130.00	118.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-02-23 16:33:59.990167+00	0.000	0.000
0aa136ff-9388-4688-bbb1-a3a344d9cde5	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 10*10 محمل عادة فايف ستار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.943661+00	2026-02-20 16:41:50.943661+00	0.000	0.000
38f70be7-6eda-4e3f-8f5d-cc664f4588e2	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 نيو سيجما (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:16:45.388774+00	2026-01-29 12:16:45.388774+00	0.000	0.000
bf14d1ca-8f4d-4a9f-a8ff-435203615af8	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 لافنا (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:23:38.052074+00	2026-01-29 12:23:38.052074+00	0.000	0.000
ff494980-4c73-4a61-81a8-2cdb3ad57c2c	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 ساليمكو (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:23:45.548065+00	2026-01-29 12:23:45.548065+00	0.000	0.000
0d793ff6-689e-42c9-b1c5-3d1518459fb4	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 اللؤلؤ (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:23:51.300812+00	2026-01-29 12:23:51.300812+00	0.000	0.000
8c31b689-b723-4b4f-b7a5-3657a4733077	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 السهم الذهبي (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:23:58.045634+00	2026-01-29 12:23:58.045634+00	0.000	0.000
8c5b88b7-459f-4831-b67c-61bfc16c6496	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 سبانش (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:03.581273+00	2026-01-29 12:24:03.581273+00	0.000	0.000
d32342b1-8699-4cab-a46d-c599555abf3c	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 لازا (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:11.413259+00	2026-01-29 12:24:11.413259+00	0.000	0.000
c3a1165c-ac37-4772-b198-5e973ff7ca06	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 ريباني (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:22.97243+00	2026-01-29 12:24:22.97243+00	0.000	0.000
6cf339ab-5c51-4d0c-a096-98aa08096dbb	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 ساليمكو (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:30.876672+00	2026-01-29 12:24:30.876672+00	0.000	0.000
dfd4135f-7efa-4f2e-96b3-02e44342a7ab	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 تاتش لومي (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:45.34786+00	2026-01-29 12:24:45.34786+00	0.000	0.000
26592f03-3ad9-436b-8eb1-c97d23551fb2	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 الصقر (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:24:59.836683+00	2026-01-29 12:24:59.836683+00	0.000	0.000
fffc498b-ab89-446f-bf7e-43ad31c86527	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20*20 تاتش لومي (يوسف)	\N	عدد	150.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:26:11.412927+00	2026-02-21 21:49:01.482285+00	0.000	0.000
60569b7c-dcce-4e35-a474-19916aa35ca3	6e48e18f-bfe0-59e7-81ac-090ada6061b2	جلبة سن داخلي 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:39:46.172566+00	2026-02-08 14:39:46.172566+00	0.000	0.000
e204e8a5-b604-4547-9484-1f498d6dc46d	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 تاتش AM (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:26:20.132173+00	2026-01-29 12:26:20.132173+00	0.000	0.000
0d6d6f68-4a79-41fb-9c7c-2d8274a55354	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 تاتش MK (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:26:30.691931+00	2026-01-29 12:26:30.691931+00	0.000	0.000
b6fb8546-4a43-4944-a315-be3ee1ea1fcb	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 ريبلان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:34:22.867705+00	2026-01-29 12:34:22.867705+00	0.000	0.000
aed26ebb-13d6-470e-b3be-18c28441b516	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 نوفا تركي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:34:22.867705+00	2026-01-29 12:34:22.867705+00	0.000	0.000
d7760ccb-4830-42c2-942f-517aed6b57ab	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 فرداني عادي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:34:22.867705+00	2026-01-29 12:34:22.867705+00	0.000	0.000
c3238e7f-7d91-40b4-8df2-6cd9161fc09a	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة محمل 20 * 20 المنبع	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000
ca20b458-786d-4bed-b94a-a91b10a6c621	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة بلاستيك 20 * 20 ساليمكو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000
988e63a2-5543-487a-9f20-e8caf9133c05	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة بلاستيك 20 * 20 كيلوباترا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000
3614e70f-96f3-4b69-9104-188a0574085d	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 15 * 15 فولكانو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000
c952ae33-8b9e-4eb8-b67f-56fb587e7314	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة 20 * 20 عادي PFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:07.052653+00	2026-01-29 12:35:07.052653+00	0.000	0.000
01060665-4be6-4d76-b3cc-374e0d2e1d4a	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة نيو سيجما تاتش 15 * 15	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000
9cba759f-0edf-4d87-aa6b-d7fb7c7ced9e	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة تاتش سوبر ستار 15 * 15	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000
c14b87a0-3545-4545-8c7f-f00de35c208f	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة ماتدور 15 * 15	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000
39f5ed3b-7c34-4b75-9331-32a95c7d8b81	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة تاتتش 15 * 15 النورس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000
adc37b18-86dc-4fbb-bea1-856a682a5095	939f4e0e-dd51-54d3-9737-dfa50e8363e7	غطا بلاعة تاتش 20 * 20  pvs	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:35:44.97126+00	2026-01-29 12:35:44.97126+00	0.000	0.000
f0c427f2-000f-4197-b044-9cb16ef86801	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 1/2 محمل (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:37:22.332383+00	2026-01-22 18:37:22.332383+00	0.000	0.000
35ad6cc3-4464-483f-9c63-7426eeee828a	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز نص خفيف 1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:38:06.827415+00	2026-01-22 18:38:06.827415+00	0.000	0.000
0bc85e43-0849-4d93-a656-73ffe8cb39eb	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:38:34.843504+00	2026-01-22 18:38:34.843504+00	0.000	0.000
3afc718e-22cb-40f5-85b6-f36a9aefa8b5	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 2" خفيف (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:42:24.569801+00	2026-01-25 10:42:24.569801+00	0.000	0.000
e2a0d6b0-083c-4d18-a788-795dbc4bf1df	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 2" محمل (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:42:58.654475+00	2026-01-25 10:42:58.654475+00	0.000	0.000
ec85f3a5-9492-404a-bb1e-ad401f624d53	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 3" محمل (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:43:40.257346+00	2026-01-25 10:43:40.257346+00	0.000	0.000
80f8c742-7ee3-47cb-96cf-7fd5819cc7c1	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 3" خفيف (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:44:16.853683+00	2026-01-25 10:44:16.853683+00	0.000	0.000
760b0215-4244-4bdb-8309-21894890e616	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 4" محمل (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:45:46.415871+00	2026-01-25 10:45:46.415871+00	0.000	0.000
4dd2c933-9bb8-4496-8f14-e5cf55e14a62	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 4" خفيف (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:46:17.954431+00	2026-01-25 10:46:17.954431+00	0.000	0.000
df95ab62-3460-4fd8-97b3-d041e121aa96	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 6" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:47:31.376609+00	2026-01-25 10:47:31.376609+00	0.000	0.000
7b92bee1-e9df-4679-8856-f13f1491aa2d	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 1 و1/2" شعبي (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:48:35.136908+00	2026-01-25 10:48:35.136908+00	0.000	0.000
ebb8fe3a-e453-4bf8-b931-c01008a6a192	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 1 و1/2" محمل (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:49:04.319186+00	2026-01-25 10:49:04.319186+00	0.000	0.000
c7c52aa2-562e-477a-a972-d04f35efcb87	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز بجوان 3/4" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:49:35.689487+00	2026-01-25 10:49:35.689487+00	0.000	0.000
4defd0e4-66bd-483d-95d2-805d2132cacf	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 1" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 13:07:27.808173+00	2026-01-25 13:07:27.808173+00	0.000	0.000
0f4beb3a-88e1-4869-9add-eca39c3a738a	b12ed220-d73c-519f-9a7d-ecb58dd62515	افيز 2 و1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 10:12:35.204666+00	2026-01-27 10:12:35.204666+00	0.000	0.000
49f4d737-1d66-4bbf-8011-44949b013133	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه سوسته ايطالى (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:33:58.596563+00	2026-02-01 16:33:58.596563+00	0.000	0.000
43262301-8bc0-4e5e-98f8-df79b0032751	df634c7a-d345-505a-82a4-2bdc2e899a7b	منيجا عدله (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 18:28:53.021728+00	2026-02-02 18:28:53.021728+00	0.000	0.000
9c6b491e-0f64-46ba-983d-e9512587b4c1	df634c7a-d345-505a-82a4-2bdc2e899a7b	منيجا موجه (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 18:29:54.169036+00	2026-02-02 18:29:54.169036+00	0.000	0.000
e3ef3606-53ce-4847-a9ae-7357efdea79a	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيجه سوسته تركى	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-25 23:14:04.662874+00	2026-02-25 23:14:04.662874+00	0.000	0.000
27e4b81d-9590-4576-b818-2a69da7afafd	df634c7a-d345-505a-82a4-2bdc2e899a7b	مانيحه استالس	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-25 23:16:10.366716+00	2026-02-25 23:16:10.366716+00	0.000	0.000
cb153139-9139-4c4b-b341-9cabab43c132	69f9914c-e165-5167-a85b-6ba46173bba3	حنفيه أسانسير كعب بلاستيك تربو طاتش(يوسف)	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 15:49:11.82749+00	2026-02-21 21:50:20.058226+00	0.000	0.000
d5442bca-dd7e-4793-aded-ef8d13f3d2b9	69f9914c-e165-5167-a85b-6ba46173bba3	حنفيه أسانسير كعب نحاس نيوجولد(عمار)	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:01:15.78419+00	2026-02-21 21:50:13.256771+00	0.000	0.000
329b40d0-86df-4887-b985-ea2bc7990b83	69f9914c-e165-5167-a85b-6ba46173bba3	حنفيه أسانسير كعب بلاستيك نيوجولد (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:04:07.2767+00	2026-02-01 16:04:07.2767+00	0.000	0.000
5bb79780-a8aa-4007-b778-5ad0dbb78e6e	69f9914c-e165-5167-a85b-6ba46173bba3	عوامه جمب السكرى(يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:18:09.42226+00	2026-02-01 16:18:09.42226+00	0.000	0.000
21587981-5f52-41a0-8aad-f7a573837b0a	69f9914c-e165-5167-a85b-6ba46173bba3	شداد طويل (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 18:22:52.679189+00	2026-02-02 18:22:52.679189+00	0.000	0.000
1220b394-a688-46f9-a9c5-6c815cef43d0	69f9914c-e165-5167-a85b-6ba46173bba3	زرار ضغط	\N	قطعة	20.00	13.00	9.00	\N	\N	\N	\N	\N	t	2026-03-15 16:58:42.15504+00	2026-03-15 16:58:42.15504+00	0.000	0.000
93f907c6-3b84-4d95-b1a5-b57483e81451	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينه ضغط كيس(يوسف)	\N	عدد	95.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:09:18.786823+00	2026-02-21 21:49:48.922933+00	0.000	0.000
11ebff6a-eec6-4331-92fe-aac2c3373c9c	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينه تركي	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:58:49.261182+00	2026-03-04 13:58:49.261182+00	0.000	0.000
38e871be-2c5b-4e85-b0a6-f5c1eceb0b50	0fe9fe9a-ca99-5bac-85da-bf506d92be69	ماكينة ايديال	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:59:01.060385+00	2026-03-04 13:59:01.060385+00	0.000	0.000
33f55188-0fe1-4788-9809-3591288e60f3	0fe9fe9a-ca99-5bac-85da-bf506d92be69	مكنة تربو	\N	قطعة	120.00	85.00	58.00	\N	\N	\N	\N	\N	t	2026-03-15 16:55:34.652521+00	2026-03-15 16:55:34.652521+00	0.000	0.000
6638cc77-52db-4850-8515-7336252846cf	0fe9fe9a-ca99-5bac-85da-bf506d92be69	مكنة ضغط نوفا	\N	قطعة	120.00	85.00	60.00	\N	\N	\N	\N	\N	t	2026-03-15 16:56:59.683521+00	2026-03-15 16:56:59.683521+00	0.000	0.000
4ebdc6b6-72e6-43cd-83eb-389d25b5c5ec	daf8935a-6a30-5667-ac81-f4a398cbc305	ماسورة وراق بلاستيك (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 12:02:39.378525+00	2026-01-25 12:02:39.378525+00	0.000	0.000
67f5d187-e095-4c7d-b864-5789fc3290ec	daf8935a-6a30-5667-ac81-f4a398cbc305	ماسورة وراق استانلس (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 12:03:00.927509+00	2026-01-25 12:03:00.927509+00	0.000	0.000
de12a113-2bee-459d-a18b-971c54badbeb	daf8935a-6a30-5667-ac81-f4a398cbc305	وراقة مناديل ايفون	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:55:07.811048+00	2026-01-29 12:55:07.811048+00	0.000	0.000
883f0d1e-6801-402e-9168-1e7f3435d336	daf8935a-6a30-5667-ac81-f4a398cbc305	اوكرة جنب استانلس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:56:03.427526+00	2026-01-29 12:56:03.427526+00	0.000	0.000
5d2c6496-0b93-4d27-8f33-ab6c72e3ab08	daf8935a-6a30-5667-ac81-f4a398cbc305	مسمار صبانات (عمر واللو)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:58:59.760059+00	2026-01-30 14:58:59.760059+00	0.000	0.000
728d6023-951b-4a19-8cfb-d62631ab5736	daf8935a-6a30-5667-ac81-f4a398cbc305	مسمار قعدة (عمر واللو)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:59:24.143925+00	2026-01-30 14:59:24.143925+00	0.000	0.000
23856709-a9eb-49e8-a93d-8d659ff16a26	daf8935a-6a30-5667-ac81-f4a398cbc305	مسمار سخان (عمر واللو)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 14:59:38.943772+00	2026-01-30 14:59:38.943772+00	0.000	0.000
71cc6095-c87f-4909-b84c-f89eb5660fa7	daf8935a-6a30-5667-ac81-f4a398cbc305	مسمار حوض (عمر وميدو)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-30 15:00:01.823495+00	2026-01-30 15:00:01.823495+00	0.000	0.000
c44ffb44-d7cc-4ab0-b7c7-6b0c073b059e	daf8935a-6a30-5667-ac81-f4a398cbc305	نوزل شطاف بالخرطوم كامل (أنس)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:30:58.500228+00	2026-02-01 16:30:58.500228+00	0.000	0.000
94c0f2c9-04d7-467c-ae8a-eb553591eac7	daf8935a-6a30-5667-ac81-f4a398cbc305	طبة حوض ستار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 12:52:11.951551+00	2026-02-10 12:52:11.951551+00	0.000	0.000
013dc815-ab1d-46f5-b3ce-3c09ec80c29b	a77bbc03-437a-5071-b287-7a1cb6a9ac77	مسمار سديلي  L معدن (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-20 16:41:50.944655+00	0.000	0.000
2de745f3-490c-458f-8d80-f8ef4fe03cb9	a77bbc03-437a-5071-b287-7a1cb6a9ac77	مسمار سديلي جرار (أنس)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:03:17.755964+00	2026-01-18 19:03:17.755964+00	0.000	0.000
2e415055-50d3-403c-b6b6-132cc06cac09	a77bbc03-437a-5071-b287-7a1cb6a9ac77	مسمار سديلي L بلاستيك (أنس)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 17:14:10.101598+00	2026-01-22 17:14:10.101598+00	0.000	0.000
bffd258f-b84e-4beb-8d18-ae23f611015d	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	شمعة مرحلة 2 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 12:09:17.936616+00	2026-01-22 12:09:17.936616+00	0.000	0.000
d2879635-0b3c-4c36-8199-9f2b94a535ab	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	شمعة مرحلة 1 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:31:36.798765+00	2026-01-22 14:31:36.798765+00	0.000	0.000
fb3622ca-2180-4ed7-811e-479b4d54f849	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	شمعة مرحلة 4 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:32:55.085674+00	2026-01-22 14:32:55.085674+00	0.000	0.000
9c1e6d13-9d15-46d1-9779-623dbc89684f	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	شمعة مرحلة 3 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:33:45.821867+00	2026-01-22 14:33:45.821867+00	0.000	0.000
4afdd266-b0cd-49ab-aa95-b46ea2fdc5a5	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حنفية فلتر اوكر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:50:13.899449+00	2026-01-29 12:50:13.899449+00	0.000	0.000
a4bc8fa2-5b9b-4d21-8b22-788662938fcd	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حنفية فلتر محمل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:50:13.899449+00	2026-01-29 12:50:13.899449+00	0.000	0.000
59b1408c-5d92-4b6b-b109-28c7a39f41fd	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	قنطرة فيلتر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:54:27.585787+00	2026-01-29 12:54:27.585787+00	0.000	0.000
0ba7d154-06d4-4148-bf47-71dbe931348a	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	وصله سريعه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 16:59:52.874967+00	2026-02-01 16:59:52.874967+00	0.000	0.000
53baae4e-9523-419b-b62f-ef1b43737105	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	نطرة فلتر 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:01:37.122142+00	2026-02-01 17:01:37.122142+00	0.000	0.000
ed6fb4fe-6aa7-4a8f-8856-bbdd3b7b7625	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	محول فلتر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:02:20.851609+00	2026-02-01 17:02:20.851609+00	0.000	0.000
5167fb35-085a-42cc-82ea-73e3684bea9a	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حنفية كولمان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:05:12.898574+00	2026-02-01 17:05:12.898574+00	0.000	0.000
e5e9bcf1-22ad-40e2-a443-9b4acdbbe426	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	حامل حنفية فلتر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:13:30.784739+00	2026-02-01 17:13:30.784739+00	0.000	0.000
577cd1d9-5876-4b11-be1c-cd338c878aa2	f4d19c5a-646c-5976-b7b8-0d06ce75be1c	محبس فلتر استالس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:36:27.970155+00	2026-02-01 17:36:27.970155+00	0.000	0.000
39e8ca5e-8abc-4918-8e32-052d5862db47	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف شيلد نحاس 3/4 بوصة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 13:47:42.676159+00	2026-01-20 13:47:42.676159+00	0.000	0.000
b5459d2a-95fc-418b-99f9-f21a8406b6f1	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 1/2 بوصة (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:12:16.803625+00	2026-01-20 14:12:16.803625+00	0.000	0.000
79880071-7ae2-49d2-bda2-46c567d90c8e	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 3/4 (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:12:47.458892+00	2026-01-20 14:12:47.458892+00	0.000	0.000
ae608ba9-9030-4a2d-89d6-fa70769c09a7	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 1 بوصة (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:13:36.339435+00	2026-01-20 14:13:36.339435+00	0.000	0.000
c2b0f8d3-5a8b-4744-8cb6-c51fc74a019f	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 2 بوصة (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:13:44.386965+00	2026-01-20 14:13:44.386965+00	0.000	0.000
f3f5bc34-6e8a-4fce-aaff-440ca5fd8a9a	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف سخان (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:16:14.851146+00	2026-01-20 14:16:14.851146+00	0.000	0.000
8860ce8d-06ec-41f7-9fa2-87e2979c660c	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف لاكور 1 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 14:17:17.027115+00	2026-01-20 14:17:17.027115+00	0.000	0.000
d1cc6cac-ad63-4fda-93d9-913571e3fe9e	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف بولي 1 و 1/2 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:33:10.336915+00	2026-01-20 15:33:10.336915+00	0.000	0.000
7f5190eb-4444-470d-87ec-f037f1b4d36a	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بوابة 1 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:55:29.280372+00	2026-01-20 15:55:29.280372+00	0.000	0.000
3a1f1896-d864-4700-a1df-a92942f60e58	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة 1 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:56:10.576738+00	2026-01-20 15:56:10.576738+00	0.000	0.000
5a69e732-8a23-459e-8321-aaabf2d24e8e	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة 3/4 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:56:57.601327+00	2026-01-20 15:56:57.601327+00	0.000	0.000
d2fd8ca2-1dba-4cf1-81fb-82dc5a323a7f	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة 1/2 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 15:57:58.480216+00	2026-01-20 15:57:58.480216+00	0.000	0.000
5dc65401-81f9-49c1-8995-94b48888200f	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-20 17:52:25.757162+00	2026-01-20 17:52:25.757162+00	0.000	0.000
966eee6d-776d-4e2c-a7a1-2e93df03e90d	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف لاكور 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:34:25.206656+00	2026-01-21 09:34:25.206656+00	0.000	0.000
95e488af-8082-4dac-903d-ae4ea9039e8e	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس محمل بسوستة 1/2 بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:15:53.456983+00	2026-01-22 11:15:53.456983+00	0.000	0.000
77d16d51-67f9-479c-aa04-d7e44d41976d	ac497863-17f1-5a7a-8ac1-274f86b4001b	شيك بلف نحاس بسوستة محمل نص بوصة (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 11:56:44.752842+00	2026-01-25 11:56:44.752842+00	0.000	0.000
523adcc8-e4e9-4766-981b-e5165d723e43	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن داخلي 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
0a5287eb-3d47-4451-ac01-b6d97287ada1	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن داخلي 1" و1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
21720bca-49df-4dd9-84aa-4858271209cd	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن خارجي 2" و1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
177bed74-3f94-4fed-93a0-e23cb13847f4	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن خارجي 1" * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
44357f2a-f7f8-441c-bdd8-f9f1af4487a8	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن خارجي محمل 1 و1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
8a00f949-0c0c-4c21-8d44-c6ffaae33aa9	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن داخلي 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
fe3b4b4b-f997-4e20-8a71-11df8a4c2e63	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور 3/4  سن خارجي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
b1bd2473-dbe5-409d-999a-342ece893357	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور 3/4 سن داخلي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
0f4ae4a8-89db-4d5d-85d5-704f681f9764	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور 1/2 بسن خارجي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
c1895f9b-5d9b-4507-9ac8-be10dd5c08d0	ac497863-17f1-5a7a-8ac1-274f86b4001b	لاكور بسن داخلي 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:14:24.637282+00	2026-01-31 14:14:24.637282+00	0.000	0.000
4ee4ef31-bccf-4cf0-b768-53db7d80ea36	ac497863-17f1-5a7a-8ac1-274f86b4001b	فلوماك صيني	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:55:21.374679+00	2026-03-04 13:55:21.374679+00	0.000	0.000
65d744cb-8b17-49e8-b485-e114e01b9987	ac497863-17f1-5a7a-8ac1-274f86b4001b	فلوماك ايطالي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:58:06.724196+00	2026-03-04 13:58:06.724196+00	0.000	0.000
db501a5e-8889-470a-abac-1aae9f62414b	ac497863-17f1-5a7a-8ac1-274f86b4001b	فلوماك كوباية	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:58:19.357574+00	2026-03-04 13:58:19.357574+00	0.000	0.000
dd7fe2ec-0f4e-4de5-8f45-a7891f0bce59	5b970d56-5ee8-594e-bcde-6ce50c1d47c3	ماتور ايطالي 1 حصان	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:45:50.975615+00	2026-03-04 13:45:50.975615+00	0.000	0.000
f8dd4fea-855d-402a-8de3-c62d5dc51df0	5b970d56-5ee8-594e-bcde-6ce50c1d47c3	ماتور ايطالي 1/2 حصان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:46:14.534908+00	2026-03-04 13:46:14.534908+00	0.000	0.000
45f0395c-d566-4c2b-b586-3cd2d1d99f7b	5b970d56-5ee8-594e-bcde-6ce50c1d47c3	ماتور صيني 1/2 حصان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:48:13.142898+00	2026-03-04 13:48:13.142898+00	0.000	0.000
7c033855-5e8a-44e7-a03a-c91729b55080	753bd696-70ef-5e78-bd15-456428b31687	كوع عاده 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:06:54.889056+00	2026-02-08 14:06:54.889056+00	0.000	0.000
fb232540-a7f2-4037-b600-1ee220be7b4d	753bd696-70ef-5e78-bd15-456428b31687	جلبة 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:11:35.389255+00	2026-02-08 14:11:35.389255+00	0.000	0.000
1dc0dbc5-8c7d-45d7-b240-e343b6bc50fa	753bd696-70ef-5e78-bd15-456428b31687	تي 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:11:59.999094+00	2026-02-08 14:11:59.999094+00	0.000	0.000
b277559f-9416-4077-b01d-108ca5d2ad84	753bd696-70ef-5e78-bd15-456428b31687	واي 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:24:30.685307+00	2026-02-08 14:24:30.685307+00	0.000	0.000
7c32ca44-d362-41fb-94c8-843a6c2b6eb1	753bd696-70ef-5e78-bd15-456428b31687	طبة كاب 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:34:10.669716+00	2026-02-08 14:34:10.669716+00	0.000	0.000
c45f5e63-c8f4-46b5-bd72-ba04bfad276e	6e48e18f-bfe0-59e7-81ac-090ada6061b2	طبة تسليك 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:45:56.317097+00	2026-02-08 12:45:56.317097+00	0.000	0.000
bb158824-4c3b-4a7e-b7ab-3f7478148361	6e48e18f-bfe0-59e7-81ac-090ada6061b2	طبة كاب 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:59:57.327557+00	2026-02-08 12:59:57.327557+00	0.000	0.000
60f411d9-101b-4fac-9476-9c3156ca32e5	6e48e18f-bfe0-59e7-81ac-090ada6061b2	تي 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:02:31.006671+00	2026-02-08 13:02:31.006671+00	0.000	0.000
8e2b3882-c6fc-42c0-85b9-1ce43ec06076	6e48e18f-bfe0-59e7-81ac-090ada6061b2	تي 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:31:49.745179+00	2026-02-08 14:31:49.745179+00	0.000	0.000
892d2704-38a2-4e62-a752-066a045fe36e	6e48e18f-bfe0-59e7-81ac-090ada6061b2	كوع سن داخلي 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:35:15.357294+00	2026-02-08 14:35:15.357294+00	0.000	0.000
b667424e-e746-44bc-9c47-839e858bc00a	69c8851c-0e49-50f6-aa84-346755ef3132	مشترك باب 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:46:09.557466+00	2026-02-08 12:46:09.557466+00	0.000	0.000
baeea72c-a311-41bf-9680-40ae18dca71c	69c8851c-0e49-50f6-aa84-346755ef3132	جلبة 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:46:17.630758+00	2026-02-08 12:46:17.630758+00	0.000	0.000
39742801-02c4-47fe-bdf9-55c330e781ca	69c8851c-0e49-50f6-aa84-346755ef3132	واي 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:46:26.81403+00	2026-02-08 12:46:26.81403+00	0.000	0.000
e6fd727d-e3c4-4364-a327-d6718553c39b	69c8851c-0e49-50f6-aa84-346755ef3132	طبة كاب 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:46:39.949684+00	2026-02-08 12:46:39.949684+00	0.000	0.000
0b66cdef-de0b-4e0d-a091-0c6478c6edd0	69c8851c-0e49-50f6-aa84-346755ef3132	كوع باب 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:23:02.439219+00	2026-02-08 13:23:02.439219+00	0.000	0.000
4856275a-91cb-4889-bc57-4e10e1b703c9	69c8851c-0e49-50f6-aa84-346755ef3132	هواية 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:23:50.82904+00	2026-02-08 14:23:50.82904+00	0.000	0.000
888d9a19-395c-4cbe-b334-346cb8006b9a	69c8851c-0e49-50f6-aa84-346755ef3132	جلبة سن داخلي 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:36:26.909287+00	2026-02-08 14:36:26.909287+00	0.000	0.000
77badf35-82f3-4f15-9645-864081747352	69c8851c-0e49-50f6-aa84-346755ef3132	قشرة 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:43:30.573237+00	2026-02-08 14:43:30.573237+00	0.000	0.000
fe50fee1-d638-4dbb-9e55-d8ee6d6716ec	5c708129-4240-5f6a-bd5d-7ed1c5434d1e	نقاص 2 * 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:51:54.81516+00	2026-02-08 12:51:54.81516+00	0.000	0.000
e7eb5039-f585-4133-8a5c-30d2c64211d1	0ff37f54-86c4-5e7b-a45b-7b0f059fe533	طبة تسليك 3"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:55:40.174127+00	2026-02-08 12:55:40.174127+00	0.000	0.000
e660c870-680d-4c0d-ac35-ad6c4e0740a6	0ff37f54-86c4-5e7b-a45b-7b0f059fe533	طبة كاب 3"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:59:14.46174+00	2026-02-08 12:59:14.46174+00	0.000	0.000
23644c4a-953b-46df-8f24-f28a6f04466e	0ff37f54-86c4-5e7b-a45b-7b0f059fe533	هواية 3"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:23:13.549607+00	2026-02-08 14:23:13.549607+00	0.000	0.000
8f92156d-4980-4897-a21d-6bb7a3001734	0ff37f54-86c4-5e7b-a45b-7b0f059fe533	جرجوري 3"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:43:11.372835+00	2026-02-08 14:43:11.372835+00	0.000	0.000
8671c2bd-ccab-45f7-8ef1-6c75e1c56809	33f73ec5-118e-5a83-bf95-62e0ba535dff	طبة كاب 4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 12:58:43.480198+00	2026-02-08 12:58:43.480198+00	0.000	0.000
9a23640f-c9b3-4037-866f-df3e018fe0b6	33f73ec5-118e-5a83-bf95-62e0ba535dff	طبة تسليك 4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:04:25.583595+00	2026-02-08 13:04:25.583595+00	0.000	0.000
182d1f97-9302-4f7b-9482-dbbd0206af9d	33f73ec5-118e-5a83-bf95-62e0ba535dff	هواية 4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:14:20.365837+00	2026-02-08 14:14:20.365837+00	0.000	0.000
8733206d-6230-4c5d-8b7d-eb3f9fd26123	33f73ec5-118e-5a83-bf95-62e0ba535dff	جرجوري 4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:41:12.668569+00	2026-02-08 14:41:12.668569+00	0.000	0.000
ab4ea6d5-f256-48e0-ac8b-cfa800182482	fab03014-2cfb-57bf-aa2f-7998e3b33df2	نقاص 1.5 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:13:45.774354+00	2026-02-08 13:13:45.774354+00	0.000	0.000
53746d4e-4530-4d61-9b35-294b61f4618c	e51e11b8-471d-57ed-96e7-1fbe83eb4965	نقاص 1.5 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:21:56.575712+00	2026-02-08 13:21:56.575712+00	0.000	0.000
57925e1a-2021-417f-8be6-34d1bdef1dfb	692519e0-6295-5892-9d1d-91cad5f3dd85	نقاص 2 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:24:04.046593+00	2026-02-08 13:24:04.046593+00	0.000	0.000
2f0bead1-730a-45f1-9ce9-71f11246b94f	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2/3	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:31:44.286884+00	2026-02-08 13:31:44.286884+00	0.000	0.000
bb5f4a08-269d-41b4-993b-2ea33302507a	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:53:05.869834+00	2026-02-08 13:53:05.869834+00	0.000	0.000
2de17cf9-3fe3-4533-a032-818ffdb0eea5	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2/2 عالية	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 13:55:32.159269+00	2026-02-08 13:55:32.159269+00	0.000	0.000
9df6119f-d341-4c6d-a93e-674107276697	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2 * 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:01:15.933689+00	2026-02-08 14:01:15.933689+00	0.000	0.000
e3a7418f-9d48-48df-b265-6e20a4c0667a	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة 2 * 1.5 عالية	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:01:55.965237+00	2026-02-08 14:01:55.965237+00	0.000	0.000
40faef4c-37c9-4ecb-a603-b377687bed9c	141f9c5b-6d31-55ee-86f6-ad02f51926e7	بلاعة شاور 2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-08 14:02:36.061897+00	2026-02-08 14:02:36.061897+00	0.000	0.000
46653e57-d6d2-4fa1-9ea9-c4095da20503	dd2b913d-417a-55cf-8fa4-c539aa173fc3	جلبة 1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:22:34.239712+00	2026-01-22 11:22:34.239712+00	0.000	0.000
2efc200a-fa8f-4bc8-8b04-ddc3491110df	dd2b913d-417a-55cf-8fa4-c539aa173fc3	تي 1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:23:13.728784+00	2026-01-22 11:23:13.728784+00	0.000	0.000
ea231ea8-7b79-4616-b5ff-7133ce3b9355	dd2b913d-417a-55cf-8fa4-c539aa173fc3	كوع بسن 1/2 (بلال)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:24:56.592898+00	2026-01-22 11:24:56.592898+00	0.000	0.000
f9ab2612-e5b6-448b-b85b-a41883850361	dd2b913d-417a-55cf-8fa4-c539aa173fc3	تي بسن 1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:32:33.403478+00	2026-01-22 18:32:33.403478+00	0.000	0.000
fbe38b09-fe9a-4053-9587-bbf370223390	dd2b913d-417a-55cf-8fa4-c539aa173fc3	جلبة سن داخلي نص بوصة (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:33:04.378991+00	2026-01-22 18:33:04.378991+00	0.000	0.000
d144b604-d157-4c59-8006-25da0df08daf	dd2b913d-417a-55cf-8fa4-c539aa173fc3	كوع لحام نص بوصة (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:33:28.412125+00	2026-01-22 18:33:28.412125+00	0.000	0.000
5261d27a-2f3f-43db-97de-7d90d039facf	dd2b913d-417a-55cf-8fa4-c539aa173fc3	كرنك 1/2" طويل (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:37:33.986183+00	2026-01-25 10:37:33.986183+00	0.000	0.000
f1ff0933-c92e-41d2-a794-809088048e47	dd2b913d-417a-55cf-8fa4-c539aa173fc3	كوع بسن داخلي 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 13:43:08.04037+00	2026-01-27 13:43:08.04037+00	0.000	0.000
3fa1f00e-e4e3-4884-81b3-404b8de81e1b	605f3728-7c52-5f81-a820-2f56527a37b2	كوع 3/4 (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:21:32.032575+00	2026-01-22 11:21:32.032575+00	0.000	0.000
320e8a3d-d0df-4ac8-ba39-cc0fcd9e9b99	605f3728-7c52-5f81-a820-2f56527a37b2	جلبة 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:21:54.654868+00	2026-01-22 11:21:54.654868+00	0.000	0.000
e74dc2f7-3677-4e8c-912e-9ef271bbba67	605f3728-7c52-5f81-a820-2f56527a37b2	تي 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:26:47.72345+00	2026-01-22 18:26:47.72345+00	0.000	0.000
1a2576db-4e4b-4e7f-8c93-d601687d5cd3	605f3728-7c52-5f81-a820-2f56527a37b2	كرنك 3/4" صغير (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:38:47.313577+00	2026-01-25 10:38:47.313577+00	0.000	0.000
422b5b97-7734-4947-afd8-cd7171cdc1b3	605f3728-7c52-5f81-a820-2f56527a37b2	كرنك 3/4" كبير (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 10:39:07.953462+00	2026-01-25 10:39:07.953462+00	0.000	0.000
a2afe05f-3beb-49bd-a5ba-36565fdd14cb	605f3728-7c52-5f81-a820-2f56527a37b2	جلبة لحام 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 14:37:19.811175+00	2026-01-27 14:37:19.811175+00	0.000	0.000
88fdb5d9-d19d-4087-aba0-19adfca71918	605f3728-7c52-5f81-a820-2f56527a37b2	تي لحام 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 14:37:45.667488+00	2026-01-27 14:37:45.667488+00	0.000	0.000
f1e6d3ae-1a60-4187-af58-d0309ad4de89	412d5f95-e302-5cfc-aa6b-12cb95411b3f	جلبة سن خارجي 1/2*1/2 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 11:23:52.353189+00	2026-01-22 11:23:52.353189+00	0.000	0.000
d05db9fb-adba-4899-8736-7c7d1c8172e1	412d5f95-e302-5cfc-aa6b-12cb95411b3f	تي سن داخلي 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 16:35:13.25749+00	2026-01-27 16:35:13.25749+00	0.000	0.000
e124b922-be63-4889-9c39-d2c339ac546e	c6db36fa-a81c-58bc-b7d6-608f8d3ae1d1	كوع لحام 1/2 * 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-27 15:14:06.928674+00	2026-01-27 15:14:06.928674+00	0.000	0.000
914922e9-da51-442c-9e3f-8839b9fa251f	5e9fdd71-7989-5122-b2d6-49bc9ba8851c	كوع بسن داخلي 3/4 * 3/4 (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:28:15.515477+00	2026-01-22 18:28:15.515477+00	0.000	0.000
f6de776c-d026-48e0-a682-85eebc4b4cbd	ab9446cf-95d8-5574-b37a-e54d68e708fe	كوع بسن داخلي 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 18:27:26.332496+00	2026-03-24 12:33:07.688217+00	0.000	0.000
01466b3d-dd2f-47f7-991f-988d273d3a3b	978af021-a666-5101-af9e-ed05c156645b	ماسورة 75 (3")	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:35:03.878094+00	2026-02-10 13:35:03.878094+00	0.000	0.000
b18c3367-ee65-4e16-8e4f-a1148284aaae	978af021-a666-5101-af9e-ed05c156645b	ماسورة 4"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:36:40.870273+00	2026-02-10 13:36:40.870273+00	0.000	0.000
e3171dc4-a972-40ef-8452-ade0250302fa	978af021-a666-5101-af9e-ed05c156645b	ماسورة 2	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:37:28.557743+00	2026-02-10 13:37:28.557743+00	0.000	0.000
4a86af6d-e32f-4b72-a561-f98020e19e26	978af021-a666-5101-af9e-ed05c156645b	ماسورة 1.5"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:38:55.086831+00	2026-02-10 13:38:55.086831+00	0.000	0.000
006eaf5f-789b-47a7-9106-944764fdc08b	978af021-a666-5101-af9e-ed05c156645b	ماسورة 1"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:39:16.678477+00	2026-02-10 13:39:16.678477+00	0.000	0.000
74460fc9-5b94-427c-b129-876231ab5674	978af021-a666-5101-af9e-ed05c156645b	قواطع ماسورة 75	\N	متر	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:40:19.983297+00	2026-02-10 13:40:19.983297+00	0.000	0.000
ff0e6f72-8440-4a9c-9a71-470453065413	978af021-a666-5101-af9e-ed05c156645b	قواطع ماسورة 2"	\N	متر	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:40:58.11851+00	2026-02-10 13:40:58.11851+00	0.000	0.000
54b51aca-a22a-4638-a14d-f4052eddb90a	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كوع لحام 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:30:04.076514+00	2026-01-26 20:30:04.076514+00	0.000	0.000
d90ce028-6aeb-4cbe-916b-d5941eb564d3	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	جلبة لحام 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:31:02.904767+00	2026-01-26 20:31:02.904767+00	0.000	0.000
1d039edf-9ba6-45b7-ac98-cbf42cf7ef49	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	تي لحام 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:32:42.822347+00	2026-01-26 20:32:42.822347+00	0.000	0.000
efa431de-b26f-4add-b34c-b4bb0c6a1f3d	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	طبة كاب 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:34:09.788818+00	2026-01-26 20:34:09.788818+00	0.000	0.000
ac0cbfea-84d2-4e19-9d5c-130b926174e9	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	محبس لاكور 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:36:07.194753+00	2026-01-26 20:36:07.194753+00	0.000	0.000
3b4c474b-bcca-4785-8c8e-29b2b42e5a79	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كرنك 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:36:42.246455+00	2026-01-26 20:36:42.246455+00	0.000	0.000
c43bc70d-9e2d-49b9-89df-7e8396361190	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	كرنك طويل 1/2" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:40:30.035555+00	2026-01-26 20:40:30.035555+00	0.000	0.000
a7c6cd69-4a08-4d2a-9ebf-817df83510f6	cc46a1fa-5849-5695-b684-3c5ec13bb0a6	طبه اختبار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:22:29.439955+00	2026-01-26 21:22:29.439955+00	0.000	0.000
f9f94c31-4ab6-4b16-860c-42b07f2fe7ac	63e2904c-e0db-55e5-9f40-d5f84a85a501	كوع لحام 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:15:16.749339+00	2026-01-26 21:15:16.749339+00	0.000	0.000
bb6e8e5f-10ce-4074-a838-5afc4bfd8c9b	63e2904c-e0db-55e5-9f40-d5f84a85a501	محبس دفن 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:15:45.928637+00	2026-01-26 21:15:45.928637+00	0.000	0.000
dc4dcdc4-6c4c-422a-b43a-64a95dd46387	63e2904c-e0db-55e5-9f40-d5f84a85a501	محبس لاكور 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:16:04.063738+00	2026-01-26 21:16:04.063738+00	0.000	0.000
43e5a9ca-78c2-4f05-affc-4c6e2491605a	63e2904c-e0db-55e5-9f40-d5f84a85a501	جلبة لحام 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:16:35.061885+00	2026-01-26 21:16:35.061885+00	0.000	0.000
7568b958-f282-4aa1-85b5-24349625f9db	63e2904c-e0db-55e5-9f40-d5f84a85a501	تي لحام 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:17:08.717317+00	2026-01-26 21:17:08.717317+00	0.000	0.000
9cffbe6c-1071-48ce-8973-fcd035c61762	63e2904c-e0db-55e5-9f40-d5f84a85a501	طبه كاب 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:19:54.664464+00	2026-01-26 21:19:54.664464+00	0.000	0.000
9cce9245-5bbe-42c5-b6b2-f4fc4e5ec8e3	63e2904c-e0db-55e5-9f40-d5f84a85a501	كرنك 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:20:25.437116+00	2026-01-26 21:20:25.437116+00	0.000	0.000
85a51c91-a72c-4762-91ee-38a342e74c48	63e2904c-e0db-55e5-9f40-d5f84a85a501	كوع لحام 3/4 مفتوح	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:28:28.462952+00	2026-01-31 14:28:28.462952+00	0.000	0.000
3a4c0ba0-e011-4496-b6b8-2cdc7dc89c88	63e2904c-e0db-55e5-9f40-d5f84a85a501	طبة كاب 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:33:59.537256+00	2026-01-31 14:33:59.537256+00	0.000	0.000
19ad03e8-e71e-4be7-90ef-08bd6572f06f	9a3e6604-1d9e-59a2-9306-b96751e63a08	طبه  1 بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:46:51.352013+00	2026-01-26 21:46:51.352013+00	0.000	0.000
d2ffb803-9a86-4990-b834-9a3d7413444d	9a3e6604-1d9e-59a2-9306-b96751e63a08	كوع لحام 1 بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:50:05.188327+00	2026-01-26 21:50:05.188327+00	0.000	0.000
12d44342-c0ea-4093-8344-8a3fe616b946	9a3e6604-1d9e-59a2-9306-b96751e63a08	جلبة لحام 1 بوصة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:50:32.28219+00	2026-01-26 21:50:32.28219+00	0.000	0.000
3b1471c3-f7f4-4a7d-a28d-06206542e170	9a3e6604-1d9e-59a2-9306-b96751e63a08	تي لحام 1 بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:50:57.378248+00	2026-01-26 21:50:57.378248+00	0.000	0.000
4fc7f1f8-8b6a-42fa-b439-eb37e404f119	9a3e6604-1d9e-59a2-9306-b96751e63a08	محبس لاكور 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-28 10:10:59.544879+00	2026-01-28 10:10:59.544879+00	0.000	0.000
6a6a73a1-51e7-48ae-8455-0e176997bed6	7cb8a098-41ca-53d9-b4e0-cdb8907a18d9	شيك بلف لاكور 1.5 بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:00:34.456897+00	2026-01-26 22:00:34.456897+00	0.000	0.000
4d5e6616-df0c-41a0-a88c-bad074a514af	7cb8a098-41ca-53d9-b4e0-cdb8907a18d9	جلبة بسن خارجي 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:01:09.086358+00	2026-01-26 22:01:09.086358+00	0.000	0.000
868ab4a9-b2ef-435e-a292-fdbc7e3752d6	a8e4d683-3422-50bf-bd7c-91584afca4c4	جلبة لحام 3" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:41:47.014108+00	2026-01-26 20:41:47.014108+00	0.000	0.000
56ae25fe-9036-4f6d-a788-b665157a3301	a8e4d683-3422-50bf-bd7c-91584afca4c4	جلبة سن داخلي 3" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:43:20.189943+00	2026-01-26 20:43:20.189943+00	0.000	0.000
5c2aab48-9df3-4dce-b31f-0ec0746050c0	3bdaca2a-6e9c-5e2b-b964-711663449202	جلبة لحام 4" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:28:37.455045+00	2026-01-26 20:28:37.455045+00	0.000	0.000
b3c35aa0-469b-4e4e-8560-1dec134adfbf	d5901618-eafd-5ad1-b0e6-f0f56f1cda35	كوع بسن 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:03:06.498596+00	2026-01-26 21:03:06.498596+00	0.000	0.000
338cbd11-8f82-4e1f-851b-c36446f165a0	d5901618-eafd-5ad1-b0e6-f0f56f1cda35	جلبة بسن داخلي 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:04:39.88191+00	2026-01-26 21:04:39.88191+00	0.000	0.000
45d11bd8-b3a6-42f3-8c0e-6db0e73093f0	d5901618-eafd-5ad1-b0e6-f0f56f1cda35	جلبة بسن خارجي 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:05:07.12304+00	2026-01-26 21:05:07.12304+00	0.000	0.000
720df594-4b7f-46b4-b602-884e803ed8f9	d5901618-eafd-5ad1-b0e6-f0f56f1cda35	تي بسن 1/2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:05:39.788358+00	2026-01-26 21:05:39.788358+00	0.000	0.000
e6f44831-450b-4431-8b3b-898c83545db9	1da2db1b-955b-5530-885e-33ed2ab7e7d3	تي محبس 1/2 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:23:09.209938+00	2026-01-26 21:23:09.209938+00	0.000	0.000
d14d6889-b9b2-454e-a5eb-ac5744e8939b	1da2db1b-955b-5530-885e-33ed2ab7e7d3	جلبة بسن خارجي 1/2 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 22:08:59.903959+00	2026-01-26 22:08:59.903959+00	0.000	0.000
6ae3a388-329b-4811-a338-c61a5d690642	c286bcb5-a984-59c2-b633-ef3ebf4da01f	تي محبس دفن 3/4 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:38:31.164992+00	2026-01-26 21:38:31.164992+00	0.000	0.000
760b529d-dbde-4e70-919c-610ce46ee71a	c286bcb5-a984-59c2-b633-ef3ebf4da01f	جلبة بسن خارجي 3/4 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:39:18.575886+00	2026-01-26 21:39:18.575886+00	0.000	0.000
48662f9e-7606-4818-b2a8-375230a4923a	c286bcb5-a984-59c2-b633-ef3ebf4da01f	جلبة بسن داخلي 3/4 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:39:48.229897+00	2026-01-26 21:39:48.229897+00	0.000	0.000
49e6c837-6ec8-4ff1-9b10-214b6df66b33	765f5e85-edfb-58dc-bf2b-4790017fb2f8	تي لحام 3/4 * 1/2 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:44:55.657012+00	2026-01-26 20:44:55.657012+00	0.000	0.000
26a4f674-5c48-4ff6-8634-143def01cd85	765f5e85-edfb-58dc-bf2b-4790017fb2f8	كوع بسن 3/4 * 1/2 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:46:07.696375+00	2026-01-26 20:46:07.696375+00	0.000	0.000
c9835638-133e-40e3-86d5-76725f3b9751	765f5e85-edfb-58dc-bf2b-4790017fb2f8	تي بسن 3/4 * 1/2 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:46:48.177685+00	2026-01-26 20:46:48.177685+00	0.000	0.000
b771a653-3406-4c85-8d38-55002fcfc673	765f5e85-edfb-58dc-bf2b-4790017fb2f8	جلبة سن داخلي 3/4 * 1/2 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:47:42.874794+00	2026-01-26 20:47:42.874794+00	0.000	0.000
541617c9-27f4-4738-9d7f-dffd1fb8975e	765f5e85-edfb-58dc-bf2b-4790017fb2f8	جلبة لحام 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-31 14:29:52.672492+00	2026-01-31 14:29:52.672492+00	0.000	0.000
202995e6-bfba-49cd-9985-735486af9c35	9dc6edb6-19f2-5c9d-8c52-5a335ced3880	تي لحام 1" * 3/4" (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 20:56:16.056423+00	2026-01-26 20:56:16.056423+00	0.000	0.000
3a563ab6-c4d5-4458-bfca-5ac51e029c72	9dc6edb6-19f2-5c9d-8c52-5a335ced3880	جلبة لحام 1 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:08:49.904267+00	2026-01-26 21:08:49.904267+00	0.000	0.000
59c5ef97-35e2-45d5-bcbc-94c0a854195e	aeffa6be-df79-58c1-93ba-30d4f612d48e	تي لحام  1* 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:07:34.70497+00	2026-01-26 21:07:34.70497+00	0.000	0.000
2a583630-04db-4a74-927a-0f8ef4d83d03	20ecf9c0-8655-5221-a299-7a517bc5c6ec	جلبة 1.5 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:13:21.310816+00	2026-01-26 21:13:21.310816+00	0.000	0.000
7bbeec16-c5dd-434c-9415-643d647ed54c	59148d2a-fc7e-58d6-adf7-e6e87869724c	جلبة لحام 1.5 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:14:47.991815+00	2026-01-26 21:14:47.991815+00	0.000	0.000
afa1092c-9aba-4b1a-ac8e-8b91bb308469	46f96c6a-23fd-5740-849e-61de853f07aa	جلبة بسن داخلي 1 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:58:53.401604+00	2026-01-26 21:58:53.401604+00	0.000	0.000
198fe32c-37df-43bf-9d75-db5bf327abfb	46f96c6a-23fd-5740-849e-61de853f07aa	جلبة بسن خارجي 1 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-26 21:59:34.73245+00	2026-01-26 21:59:34.73245+00	0.000	0.000
4b615637-457b-4c61-b4c8-e69607aff352	d6654c3e-1821-5363-80b2-79297fffcc14	ماسورة 1.5"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:42:32.606727+00	2026-02-10 13:42:32.606727+00	0.000	0.000
4a9db8a4-6cdf-4666-ae94-28002243bce6	d6654c3e-1821-5363-80b2-79297fffcc14	ماسورة 1"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:43:36.471241+00	2026-02-10 13:43:36.471241+00	0.000	0.000
d119f961-855e-4209-ae8f-00e30ed71e3c	d6654c3e-1821-5363-80b2-79297fffcc14	ماسورة 3/4"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:44:16.949695+00	2026-02-10 13:44:16.949695+00	0.000	0.000
3ba8e991-c7c9-4ee0-b3e8-265a9b8e13c4	d6654c3e-1821-5363-80b2-79297fffcc14	ماسورة 1/2"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-10 13:45:01.933868+00	2026-02-10 13:45:01.933868+00	0.000	0.000
fc34d4b3-7215-42ae-9c64-eb7d8b003cda	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامة خزان استانلس بوصة (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-20 16:41:50.944655+00	0.000	0.000
857d4856-aca0-4f69-89d8-59ed2d1b86d0	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامة خزان نحاس بالونة بلاستيك بوصة (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-20 16:41:50.944655+00	0.000	0.000
da12de49-d1d6-4554-b5ae-43e76227ca90	32aad4e8-9baf-5f6b-b52f-e17675e4bcd9	عوامة نحاس بالونة بلاستيك 3/4 (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-20 16:41:50.944655+00	0.000	0.000
ad598ec1-2ff3-43fd-97b7-c957aa24375f	24dcb16c-9713-518d-8af0-a48722e900dc	بشبوري (الكوك و ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-20 16:41:50.944655+00	0.000	0.000
155fa0fb-6b2b-44db-8541-db6e2250448b	24dcb16c-9713-518d-8af0-a48722e900dc	سيخ شطاف الومونيوم (الكوك)	\N	عدد	35.00	13.50	9.50	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-23 16:31:15.151033+00	0.000	0.000
7e302e33-3bb9-436d-b2a6-f64f71fa113e	24dcb16c-9713-518d-8af0-a48722e900dc	سيخ شطاف نحاس (الكوك)	\N	عدد	45.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 16:41:50.944655+00	2026-02-21 15:02:47.061757+00	0.000	0.000
15902323-3734-41df-bb0e-732074b9a1aa	24dcb16c-9713-518d-8af0-a48722e900dc	خرطوم شطاف الوان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:03:44.986461+00	2026-01-18 19:03:44.986461+00	0.000	0.000
e5bc8d66-e55d-4fe6-a17a-cf8f6ff8cd1b	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي جروهي (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:19:45.630201+00	2026-01-22 14:19:45.630201+00	0.000	0.000
55e08b76-5995-4930-91ae-2c3ab291202e	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي نيكل سالمكو (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.080983+00	2026-01-29 12:49:38.080983+00	0.000	0.000
a98b567b-37a4-4c42-9801-a5902cb3ef95	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي اسود ساليمكو (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000
9228f6d9-1d01-45dc-a79f-9b80a68c3c55	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي روما (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000
9ad31176-b502-43b7-b47a-57cdaa1e623f	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي كيس ستار (ادهم)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-02-21 15:05:00.917042+00	0.000	0.000
c3887692-7b86-4407-a0ce-78ecc804fadc	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي سولو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000
6244a9bf-08bb-41a8-9bec-b8cc3df96f19	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي سوبر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000
48fba67d-dbc6-424b-b2eb-497fdc9b7bd1	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي إينوفا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000
d285b94f-1298-4c3a-b7ac-0042de1e97ea	24dcb16c-9713-518d-8af0-a48722e900dc	شطاف خارجي ماست	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-01-29 12:49:38.082003+00	0.000	0.000
65bfbf00-27bf-4323-ab25-1ccd994cddc4	24dcb16c-9713-518d-8af0-a48722e900dc	يد شطاف خارجي	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:49:38.082003+00	2026-02-21 15:03:39.300701+00	0.000	0.000
6b464626-fbe4-4656-bd1a-d571d6836693	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 2" صيني رمادي	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:24:10.827742+00	2026-02-21 21:38:10.234836+00	0.000	0.000
fb762949-d7b9-450d-982b-102fb9ceed95	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	حنفية جنب اسانسير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:25:43.003892+00	2026-02-02 15:25:43.003892+00	0.000	0.000
3ef92e16-40ee-44f0-98ca-671ee3a5805b	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	كاوتشة سيفون 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:28:10.806647+00	2026-02-02 15:28:10.806647+00	0.000	0.000
d50650fc-9afe-4e35-b5d9-eb8dd047b187	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	كاوتشة سيفون 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:28:23.912166+00	2026-02-02 15:28:23.912166+00	0.000	0.000
32f48e5f-5ab9-419b-8916-585ded0e8320	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مكنة سيفون كاملة فيرست	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:28:48.340611+00	2026-02-02 15:28:48.340611+00	0.000	0.000
bf9ce757-b348-4b75-bbb4-0c6bf8efc605	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه كوع	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:29:08.6693+00	2026-02-02 15:29:08.6693+00	0.000	0.000
fd1d4d05-a75f-4b1e-bab1-26b542487294	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه استانلس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:29:25.074519+00	2026-02-02 15:29:25.074519+00	0.000	0.000
c3c27efc-96b1-4a23-bdab-93e04c7e9940	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه فار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:29:39.724353+00	2026-02-02 15:29:39.724353+00	0.000	0.000
1db05d34-4a6f-4897-9a7c-619aa7351406	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه عادية	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:29:48.842245+00	2026-02-02 15:29:48.842245+00	0.000	0.000
c7423fe8-0195-4f61-894f-5692b13601c9	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	حامل سماعة متحرك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:30:06.112259+00	2026-02-02 15:30:06.112259+00	0.000	0.000
29837797-dac6-4388-b18f-4513160e8d31	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	حامل شطاف عادي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:30:30.859666+00	2026-02-02 15:30:30.859666+00	0.000	0.000
538af4af-6d6c-4210-be3c-0ffaecc7a7ed	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه قصيره	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:35:09.987893+00	2026-02-02 15:35:09.987893+00	0.000	0.000
cb81213b-7bb7-4274-abb4-2d974f8a60cb	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	شداد طويل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:35:28.975017+00	2026-02-02 15:35:28.975017+00	0.000	0.000
58991d0b-13f2-4dff-80e7-41c64abe1120	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه عدلة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:35:46.899174+00	2026-02-02 15:35:46.899174+00	0.000	0.000
6d01a666-06e8-4462-9315-00ba9f599a34	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مانيجه موجة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:36:02.450285+00	2026-02-02 15:36:02.450285+00	0.000	0.000
fa3c71db-d1ce-4a46-9ee5-9b8b4c2158e1	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مسمار قعدة كيلوباترا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:36:21.69907+00	2026-02-02 15:36:21.69907+00	0.000	0.000
30150049-3f07-44c8-a64d-f23fd7141fdc	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مسمار قعدة الما	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:36:35.687663+00	2026-02-02 15:36:35.687663+00	0.000	0.000
f0a893bd-5ba6-4416-9f76-2f89c54a7767	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	مسمار قعدة ايطالي	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:36:54.790817+00	2026-02-02 15:36:54.790817+00	0.000	0.000
111240d0-c336-4cf3-9cd2-6779a85cb709	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي مجوز 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:37:24.090484+00	2026-02-02 15:37:24.090484+00	0.000	0.000
6ec910b4-8783-403d-a1b3-3010fa7db258	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي لاتش 3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:38:08.931853+00	2026-02-02 15:38:08.931853+00	0.000	0.000
1743d3fb-848e-476a-8cab-5e48149abdc3	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي لاتش 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:39:26.862435+00	2026-02-02 15:39:26.862435+00	0.000	0.000
41c01f1c-ff76-4391-85d4-f5079c3787ce	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي فردي 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 15:39:54.460178+00	2026-02-02 15:39:54.460178+00	0.000	0.000
32cac645-8208-4dac-9da8-01986e061b8c	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 1.5 ماليزى	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:06:44.180499+00	2026-02-21 21:40:25.304995+00	0.000	0.000
3475e3b2-b002-47e6-88ee-85a33cd7f837	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 2 بوصه ماليزى	\N	عدد	35.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:07:21.784587+00	2026-02-21 21:40:36.875084+00	0.000	0.000
625c7018-17e7-4090-9e8a-fbbedab8d3e2	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 1.5 رمادى	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:09:46.434495+00	2026-02-21 21:40:48.138474+00	0.000	0.000
e0066fb9-2326-421b-a886-489c8b5863ab	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 2 بوصه رمادى	\N	عدد	50.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:10:08.971445+00	2026-02-21 21:41:04.522003+00	0.000	0.000
45b07094-6fd8-4438-aa7b-4ba17e5ed897	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه أبيض	\N	عدد	65.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:10:48.025512+00	2026-02-21 21:41:22.426883+00	0.000	0.000
3f69fa98-e1f0-4102-a092-d17b3924abf9	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون3 بوصه بفايظ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:13:58.857832+00	2026-02-02 19:13:58.857832+00	0.000	0.000
f7f12634-4eb0-4c26-8f20-691639ed46fa	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه بروحين	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:14:35.730526+00	2026-02-02 19:14:35.730526+00	0.000	0.000
a6701d83-54db-4c36-968d-2354d17328ec	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 2 بوصه بروحين	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:15:22.467925+00	2026-02-02 19:15:22.467925+00	0.000	0.000
89153ada-a2e6-45ff-965d-a610fca6a73f	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه بزباله بلاستيك	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:16:05.314159+00	2026-02-21 21:42:02.445075+00	0.000	0.000
b81afeec-6c16-455a-8aed-b6a43abd3b9b	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 1.5 كبايه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:16:38.530868+00	2026-02-02 19:16:38.530868+00	0.000	0.000
cf75658d-4804-42d6-bd8f-edf3a77549be	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه رمادى	\N	عدد	75.00	38.00	30.00	\N	\N	\N	\N	\N	t	2026-02-02 19:16:58.666155+00	2026-03-15 17:10:44.53093+00	0.000	0.000
d78e3631-becb-459d-bcb7-f626d9bdae58	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون بانيو	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:17:15.44432+00	2026-02-02 19:17:15.44432+00	0.000	0.000
2e9f519a-ab35-4cc7-a168-bd51332e9700	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3 بوصه بزباله استالس	\N	عدد	180.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:17:51.624571+00	2026-02-21 21:43:30.922208+00	0.000	0.000
605b00e5-e53a-42e8-b98d-53030c4f7284	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون صينى 1.5	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:19:01.181735+00	2026-02-21 21:43:47.495468+00	0.000	0.000
48745b7a-4ef7-4583-a151-234efc18dbe7	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون صينى 2 بوصه	\N	عدد	25.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 19:19:28.108334+00	2026-02-21 21:44:00.953521+00	0.000	0.000
db4063c5-f89d-40d9-abd9-968984ad74f8	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي فردي 3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 21:26:32.249983+00	2026-02-02 21:26:32.249983+00	0.000	0.000
66e9c7ca-229c-4dbb-9f3a-345225214c9f	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	قفيز بولي مجوز 3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-02 21:30:11.403724+00	2026-02-02 21:30:11.403724+00	0.000	0.000
0c3f197e-b856-4f1f-b96f-fdb8e806da50	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون 3" ماليزي	\N	قطعة	70.00	35.00	30.00	\N	\N	\N	\N	\N	t	2026-03-15 17:09:04.979474+00	2026-03-15 17:09:04.979474+00	0.000	0.000
ec82ff6e-c170-46cd-8bf4-56341eb31632	d7bf6066-2de4-51b2-b5dd-ea05d25bc1a2	سيفون رمادي 2"	\N	قطعة	50.00	27.00	21.00	\N	\N	\N	\N	\N	t	2026-03-15 17:36:40.441539+00	2026-03-15 17:36:40.441539+00	0.000	0.000
9ac24b13-ee09-4646-9bb8-249a9b471037	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة مياه 3 متر جولدن فلو (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:12:30.120497+00	2026-02-21 14:39:51.846576+00	0.000	0.000
19d71c4a-8090-4996-a85c-2df2eb0ee554	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة مياه متر ونص جولدن فلو (الكوك)	\N	عدد	80.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:12:34.503756+00	2026-02-21 14:39:45.801646+00	0.000	0.000
a392d3d8-9dc7-4509-92c6-96e52892dc45	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة مياه متر ونص جولدن تركي (الكوك)	\N	عدد	80.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:12:45.952747+00	2026-02-21 14:39:25.335134+00	0.000	0.000
543dae04-a219-44b2-a24c-8e663ec4c865	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة مياه 3 متر جولدن تركي (الكوك)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:12:52.496582+00	2026-02-21 14:39:18.134764+00	0.000	0.000
c9d9c6cf-9b3c-464e-acb8-89e7b9e60117	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة صرف 3 متر (ادهم)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:14:53.843401+00	2026-02-21 14:38:55.431289+00	0.000	0.000
a677536b-b254-402f-861c-caa5d4baf82f	682ba68b-ea1b-565a-972d-e92063da3cbb	خرطوم غسالة صرف متر ونص (ادهم)	\N	عدد	80.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-18 19:15:24.714112+00	2026-02-21 14:38:48.103872+00	0.000	0.000
189b8e6e-6161-40ba-ab29-98d73b32232e	682ba68b-ea1b-565a-972d-e92063da3cbb	حنفية غسالة (عمار)	\N	عدد	85.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 09:35:22.486394+00	2026-02-21 14:38:21.602117+00	0.000	0.000
8fae6b9b-5008-41b4-a965-9a6c1ded4518	682ba68b-ea1b-565a-972d-e92063da3cbb	حنفية غسالة روفا (بلال)	\N	عدد	120.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-21 19:38:43.959582+00	2026-02-21 14:38:28.854569+00	0.000	0.000
aaa9b0ea-6fca-4ea2-9b68-59b22b719e6c	2732421b-5c80-556c-9323-4c8f800ad58e	مشترك 1 بوصة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:05:44.248619+00	2026-01-19 19:05:44.248619+00	0.000	0.000
aebc30af-cb2d-40a1-a4aa-7a7f438a864a	6e264538-d570-56e8-ab82-3a3db2f04764	مشترك سن داخلي - سن 1/2 * 3/4 (عمر)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:03:41.558684+00	2026-01-19 19:03:41.558684+00	0.000	0.000
bfde9b7d-4434-46e2-9972-bc39262ad6ac	6e264538-d570-56e8-ab82-3a3db2f04764	كوع سن داخلي - سن 1/2 * 3/4  (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:03:52.399587+00	2026-01-19 19:03:52.399587+00	0.000	0.000
04584170-0c95-4aec-9669-fc9bc5778b8e	6e264538-d570-56e8-ab82-3a3db2f04764	جلبة سن داخلي - سن 1/2 * 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:04:00.511238+00	2026-01-19 19:04:00.511238+00	0.000	0.000
855d8d44-57d9-4704-9908-8fdefbf12615	6e264538-d570-56e8-ab82-3a3db2f04764	جلبة سن خارجي - سن 1/2 * 3/4 (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:04:07.237227+00	2026-01-19 19:04:07.237227+00	0.000	0.000
62f17a04-2661-4859-8678-a0d17bbc0a0d	24af384e-9a22-58fd-bd52-970a3c97cad0	مشترك 3/4 * 3/4 سن داخلي (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-19 19:04:13.150707+00	2026-01-19 19:04:13.150707+00	0.000	0.000
3ccc958f-8b6a-4bd8-a9d0-47bba9de7485	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط دش روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 12:10:41.758539+00	2026-01-22 12:10:41.758539+00	0.000	0.000
751a8dd7-078f-4709-9144-9c29d8b89762	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط موكا دش (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:00:28.285706+00	2026-01-22 14:00:28.285706+00	0.000	0.000
cbb6ab60-767c-4ddb-be13-89063020cabc	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:02:07.150454+00	2026-01-22 14:02:07.150454+00	0.000	0.000
06095b8b-ee17-4436-9942-c9976657fd63	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ لومي (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:02:47.405899+00	2026-01-22 14:02:47.405899+00	0.000	0.000
1b0a5385-3616-4c3a-b745-a85f92393217	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ موكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:04:02.189476+00	2026-01-22 14:04:02.189476+00	0.000	0.000
1cda0ceb-91d1-46c2-966c-39fb3afa37af	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ سالمكو ابيض (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:07:27.101698+00	2026-01-22 14:07:27.101698+00	0.000	0.000
313c6041-991c-4284-86ba-400fc94cb85f	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش اليريا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:08:34.638235+00	2026-03-24 11:28:04.936399+00	0.000	0.000
0f6dcd53-d686-43ae-8d75-54b1a8d2fcfe	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ جولد روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:09:49.421859+00	2026-01-22 14:09:49.421859+00	0.000	0.000
ca3d769f-2e88-4ab4-a664-10168fd3f444	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش جولد روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:10:24.3023+00	2026-01-22 14:10:24.3023+00	0.000	0.000
42080636-8663-44f5-b4c1-9b39aaac1507	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش اوكر لومي (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:13:25.965227+00	2026-01-22 14:13:25.965227+00	0.000	0.000
6fbb04b8-4330-4c11-bfa4-8b1109d55f89	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط اوكر سالمكو ابيض (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:16:39.260973+00	2026-01-22 14:16:39.260973+00	0.000	0.000
21f29f18-4d31-44eb-8cbe-787b049dfa55	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش كوكو موكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:40:53.885962+00	2026-01-22 14:40:53.885962+00	0.000	0.000
6c320719-401e-47ac-bee3-21e7b61769b5	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش ساليمكو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:43:18.814499+00	2026-01-22 14:43:18.814499+00	0.000	0.000
10fad07e-e235-4c23-8975-fbf164f85ea0	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش روكا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:46:39.725569+00	2026-01-22 14:46:39.725569+00	0.000	0.000
e4a2fec7-1530-4b1c-b279-8ea6e7fb894e	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ فيتو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:53:15.741383+00	2026-01-22 14:53:15.741383+00	0.000	0.000
9b47cbd8-d805-47d6-bd39-8452ad291acc	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ سينزو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:53:53.533228+00	2026-01-22 14:53:53.533228+00	0.000	0.000
0053a86b-d8a7-4da3-92dd-fd92a4e9bcc8	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط مطبخ موكا احمر  (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:54:17.309819+00	2026-01-22 14:54:17.309819+00	0.000	0.000
dad20297-7d49-4231-bfd1-812ecb3ded63	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف ليمار (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:55:06.989326+00	2026-01-22 14:55:06.989326+00	0.000	0.000
a4e213ae-e816-4c03-a379-402ec0d79454	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف سينزو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:55:27.229806+00	2026-01-22 14:55:27.229806+00	0.000	0.000
95070eb6-92ac-49bb-9242-b9d24fcfd7bb	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف روك MG (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:56:20.109743+00	2026-01-22 14:56:20.109743+00	0.000	0.000
5cd2a754-00cb-4a1c-a7bd-3ea5e0147927	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف سينيور (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:56:58.253773+00	2026-01-22 14:56:58.253773+00	0.000	0.000
f1f57c68-4a58-447a-85ac-8147d2acd1d9	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شطاف النيل (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 14:57:26.765701+00	2026-01-22 14:57:26.765701+00	0.000	0.000
c412d1be-d6c6-417b-9f67-48f9129e145d	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط 1/2 بارد جنا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:01:58.830456+00	2026-01-22 15:01:58.830456+00	0.000	0.000
d3fec787-b312-4d8d-83f4-918c4b1add15	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شجرة دش ديتوريا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:03:06.732934+00	2026-01-22 15:03:06.732934+00	0.000	0.000
24fb14a1-81cd-4bff-934c-979871903865	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شجرة وش 1/2 محمل ديتوريا (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:06:35.725891+00	2026-01-22 15:06:35.725891+00	0.000	0.000
97565e26-97a2-4284-ba09-ae9b8f8b6be2	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شجرة دش اوكر (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:08:25.838261+00	2026-01-22 15:08:25.838261+00	0.000	0.000
58a4a59e-3495-4e62-b2d0-472aaebd65d6	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط دش سينزو (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:08:55.197365+00	2026-01-22 15:08:55.197365+00	0.000	0.000
06ddd19d-3ce2-4821-af81-09a1691dbd66	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط وش جولدن ايجل (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-22 15:13:20.237613+00	2026-01-22 15:13:20.237613+00	0.000	0.000
112dcd47-c1b5-48e5-8c35-a607803fbab9	50aac995-d284-5518-bbb9-019cfdeb1378	طبة حوض ستار (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:00:28.989011+00	2026-01-25 17:00:28.989011+00	0.000	0.000
f03dd423-06f8-47ff-9f3f-38aeac20a897	50aac995-d284-5518-bbb9-019cfdeb1378	محبس مجوز محمل (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:03:16.445111+00	2026-01-25 17:03:16.445111+00	0.000	0.000
9f43f345-bb0d-4097-9ce2-8fc11499c952	50aac995-d284-5518-bbb9-019cfdeb1378	محبس مجوز خفيف (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:03:29.659999+00	2026-01-25 17:03:29.659999+00	0.000	0.000
0022d9ed-8597-4847-aa41-496c0f5f6fdc	50aac995-d284-5518-bbb9-019cfdeb1378	خزان شاور (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:04:10.236359+00	2026-01-25 17:04:10.236359+00	0.000	0.000
acd67601-084b-4d50-9c35-121344944338	50aac995-d284-5518-bbb9-019cfdeb1378	محبس جولد (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:04:35.499663+00	2026-01-25 17:04:35.499663+00	0.000	0.000
11cbf451-8e09-4ceb-b1d6-1093e8704a2f	50aac995-d284-5518-bbb9-019cfdeb1378	حنفية غسالة هواي (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:04:54.796142+00	2026-01-25 17:04:54.796142+00	0.000	0.000
364cf46d-c57a-4d8e-bb4d-76c81c41110b	50aac995-d284-5518-bbb9-019cfdeb1378	محبس هاينز (ادهم)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 17:05:12.299668+00	2026-01-25 17:05:12.299668+00	0.000	0.000
d7ce890d-87cd-46af-8486-d92bce906566	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط موكا مطبخ (عمار)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 21:03:25.955866+00	2026-01-25 21:03:25.955866+00	0.000	0.000
8ee97fac-d9e7-46f2-87d2-6f252272cc43	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط موكا وش (الكوك)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-25 21:03:46.179096+00	2026-01-25 21:03:46.179096+00	0.000	0.000
1bdf30f3-f488-4e03-a464-31e600a3c012	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط دش جولدن ايجل	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-04 13:59:26.741401+00	2026-03-04 13:59:26.741401+00	0.000	0.000
ecdbb38a-6d75-4400-85a5-3aab9d88372b	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط دوش اوكر	\N	قطعة	650.00	580.00	520.00	\N	\N	\N	\N	\N	t	2026-03-15 16:51:10.228907+00	2026-03-15 16:51:10.228907+00	0.000	0.000
9270a294-f2ee-4bf5-8871-ba778fc8e784	50aac995-d284-5518-bbb9-019cfdeb1378	طقم خلاط اوكر	\N	طقم	1550.00	1450.00	1200.00	\N	\N	\N	\N	\N	t	2026-03-15 16:53:55.748347+00	2026-03-15 16:53:55.748347+00	0.000	0.000
f12652f3-f3c6-43ae-8afa-04fafd701c2f	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط شجرة استالس	\N	قطعة	600.00	420.00	300.00	\N	\N	\N	\N	\N	t	2026-03-15 17:06:36.203073+00	2026-03-15 17:06:36.203073+00	0.000	0.000
a0bb2d53-4a9c-4d5f-bce9-69f0f7092fa4	50aac995-d284-5518-bbb9-019cfdeb1378	خلاط 1/2 استالس مط	\N	قطعة	250.00	190.00	100.00	\N	\N	\N	\N	\N	t	2026-03-15 17:20:14.050966+00	2026-03-15 17:20:14.050966+00	0.000	0.000
f9e48d97-167b-443e-bb9f-0dcc047bad58	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة حمام هاند ميكسر وش (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
39a64571-ec16-476d-be59-88ceef71426a	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة مطبخ هاند ميكسر وش (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
de2a4366-eab4-4c04-9bd0-362a29eab7e8	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة عكاز هاند ميكسر (يوسف)	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
5d31eb67-6989-4113-8936-43dc6ae1a959	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 5 لينيا وش	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
66dfac46-fd00-4ebf-93de-f48f6110b778	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 5 لينيا مطبخ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
85d12824-8b4e-4805-a439-94123944367c	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 6 لينيا مطبخ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
2a0cb6d2-3bf2-48b5-9454-37cd53b23c9e	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة 6 لينيا وش	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
0a184115-b9d7-4ab5-9d82-c864eb702b45	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة وش هاند ميكسر قصيرة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
b656dab6-3e5f-43f4-9405-9c2dd680411f	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة مطبخ هاند ميكسر مقلوبة صغيرة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
9d992477-0510-4e5d-82c2-89b66cc8658c	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة وش هاند ميكسر طويلة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
8bfd6725-3128-4c54-b869-fc2a959df714	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة هاند ميكسر مطبخ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
37ee2418-56bb-4d8e-b0ec-fe9ffb1fc333	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة عكاز وش صغير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
d6a1126f-180e-480d-9924-1fb69414f686	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة عكاز وش كبير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
729d42f1-7d09-46f9-a4bf-58d11104de7b	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة مطبخ هاند ميكسر مقلوبة كبيرة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:36:28.051655+00	2026-01-29 12:36:28.051655+00	0.000	0.000
f28d6018-f8ef-4e25-b404-1830ea0d3708	201504f6-3716-569b-9502-2a404a8cbb03	قنطرة هاند ميكسر غكاز مطبخ	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 12:50:51.761397+00	2026-01-29 12:50:51.761397+00	0.000	0.000
3facfe2f-f0db-410c-b679-7e7082704488	201504f6-3716-569b-9502-2a404a8cbb03	هلاله مسمار 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:06:07.674285+00	2026-02-01 17:06:07.674285+00	0.000	0.000
bf8c300e-e7d6-4072-9c5f-c1745542bf46	201504f6-3716-569b-9502-2a404a8cbb03	هلاله 2 مسمار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:06:27.799151+00	2026-02-01 17:06:27.799151+00	0.000	0.000
7dbbf287-1956-44eb-8f05-20c48068fa87	201504f6-3716-569b-9502-2a404a8cbb03	طقم كرنك خلاط استالس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:07:27.044835+00	2026-02-01 17:07:27.044835+00	0.000	0.000
1d30a4fe-fbfe-4d3e-886d-d7c5ec544240	201504f6-3716-569b-9502-2a404a8cbb03	صامولة قنطرة 6 لنيا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:09:23.581078+00	2026-02-01 17:09:23.581078+00	0.000	0.000
6c53ac78-8c67-4b7d-9417-fe21bb9cad2c	201504f6-3716-569b-9502-2a404a8cbb03	صامولة زنق هاند ميكسر نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:10:35.219759+00	2026-02-01 17:10:35.219759+00	0.000	0.000
e196b412-5f2c-4a18-81ee-3c50385a03fc	201504f6-3716-569b-9502-2a404a8cbb03	وصلت خلاط 5 لنيا	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-01 17:11:27.335241+00	2026-02-01 17:11:27.335241+00	0.000	0.000
87d4538d-0e02-44ee-976a-53651c8e11ab	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبلة خزان 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:04:56.586921+00	2026-01-29 13:04:56.586921+00	0.000	0.000
015510b5-5c17-40eb-8099-378255764017	86600a27-d5d3-56ab-a8ed-e3ea152ea390	مشترك نحاس 1/2 محمل	\N	عدد	60.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:05:20.202709+00	2026-02-21 21:52:50.698951+00	0.000	0.000
eabea370-6202-46ed-836d-89822831f083	86600a27-d5d3-56ab-a8ed-e3ea152ea390	كوع عادة محمل 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:06:01.8035+00	2026-01-29 13:06:01.8035+00	0.000	0.000
fbc41295-0338-4e49-b61e-79e99e9f5667	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل نحاس 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:09:04.443198+00	2026-01-29 13:09:04.443198+00	0.000	0.000
a2cdd98c-fbff-4718-bb70-ebb3eb940b55	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل نحاس 3/5 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:11:59.962066+00	2026-01-29 13:11:59.962066+00	0.000	0.000
6652a94b-e908-4557-a060-95e8a2d1c9c3	86600a27-d5d3-56ab-a8ed-e3ea152ea390	كوع صنارة محمل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:26:04.321138+00	2026-01-29 13:26:04.321138+00	0.000	0.000
2bd5ddec-5128-4551-a96d-f826eaaec686	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل 3/4 نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:31:32.249287+00	2026-01-29 13:31:32.249287+00	0.000	0.000
129089d7-95d4-42cc-94ef-2e54da0be9f1	86600a27-d5d3-56ab-a8ed-e3ea152ea390	طبة 1/2 نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:33:31.976981+00	2026-01-29 13:33:31.976981+00	0.000	0.000
b4d85961-96ba-4080-aa56-285b5489712c	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سماعة نيكل 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:39:26.104821+00	2026-01-29 13:39:26.104821+00	0.000	0.000
e0e6359a-6bf8-43ed-bb47-0b0e63e10d65	86600a27-d5d3-56ab-a8ed-e3ea152ea390	جلبة سماعة نيكل 3/4 * 1/2 نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:40:02.808686+00	2026-01-29 13:40:02.808686+00	0.000	0.000
fc080463-994d-4137-87fb-c0544751b8ac	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل خلاط صغير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:40:16.840735+00	2026-01-29 13:40:16.840735+00	0.000	0.000
4c4aa1f7-2214-4e18-86fc-792298942132	86600a27-d5d3-56ab-a8ed-e3ea152ea390	نبل خلاط كبير	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:40:35.207902+00	2026-01-29 13:40:35.207902+00	0.000	0.000
731e6d42-8a1f-466f-b80e-97784861e90c	86600a27-d5d3-56ab-a8ed-e3ea152ea390	كعب خلاط نحاس	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-01-29 13:40:51.095914+00	2026-01-29 13:40:51.095914+00	0.000	0.000
242e2fb5-5a2d-4d00-ba37-e9f08f40c31f	f0906684-99d3-55aa-9994-9427e941823e	كوع 1" عادة سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:10:14.72849+00	2026-02-04 14:10:14.72849+00	0.000	0.000
2a10fa6f-8cec-43fc-868a-d9c6b614e101	f0906684-99d3-55aa-9994-9427e941823e	كوع 1" مفتوح سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:12:26.727776+00	2026-02-04 14:12:26.727776+00	0.000	0.000
3896b31c-7763-425a-8bc2-d52a6b6ed94f	f0906684-99d3-55aa-9994-9427e941823e	جلبة 1" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:12:55.784626+00	2026-02-04 14:12:55.784626+00	0.000	0.000
48ff7790-a0dc-4c11-b27f-e1c8c92ca52f	f0906684-99d3-55aa-9994-9427e941823e	مشترك تي 1" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:13:35.832428+00	2026-02-04 14:13:35.832428+00	0.000	0.000
2d83aef3-45b0-41bb-9475-b1b64ab3bded	f0906684-99d3-55aa-9994-9427e941823e	مشترك واي 1" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:14:42.896833+00	2026-02-04 14:14:42.896833+00	0.000	0.000
58972db3-c507-4f0a-a8aa-77ba90cd06fd	f0906684-99d3-55aa-9994-9427e941823e	كوع عادة 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:16:09.84822+00	2026-02-04 14:16:09.84822+00	0.000	0.000
8e2e8783-9d76-478b-b10f-e9342e98e16f	f0906684-99d3-55aa-9994-9427e941823e	مشترك واي 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 14:16:44.775591+00	2026-02-04 14:16:44.775591+00	0.000	0.000
5a69faeb-91af-4ec9-85f2-6939c22df3d1	f0906684-99d3-55aa-9994-9427e941823e	كوع مفتوح 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 15:09:53.89195+00	2026-02-04 15:09:53.89195+00	0.000	0.000
8f7aafa6-b4da-421c-a7bd-f27fa96b1974	f0906684-99d3-55aa-9994-9427e941823e	جلبة عادة 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 15:22:56.563347+00	2026-02-04 15:22:56.563347+00	0.000	0.000
16215c47-6d07-4eab-a055-de8f98d0b6d8	f0906684-99d3-55aa-9994-9427e941823e	كوع 2" عادة سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:02:16.529075+00	2026-02-04 16:02:16.529075+00	0.000	0.000
75f27b8f-be6b-4bb7-90cd-6604cf2a14c1	f0906684-99d3-55aa-9994-9427e941823e	تي 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:05:12.25651+00	2026-02-04 16:05:12.25651+00	0.000	0.000
9bdfe990-a632-4e4a-a461-c97627f66aa2	f0906684-99d3-55aa-9994-9427e941823e	كوع مفتوح 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:05:35.775817+00	2026-02-04 16:05:35.775817+00	0.000	0.000
6bce2691-dbf2-484b-bd68-b1ca3e7404ed	f0906684-99d3-55aa-9994-9427e941823e	كوع عادة بباب 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:17:36.974994+00	2026-02-04 16:17:36.974994+00	0.000	0.000
8c61aff3-78b7-499c-a20c-f2e2d06f31c2	f0906684-99d3-55aa-9994-9427e941823e	تي 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:19:43.150728+00	2026-02-04 16:19:43.150728+00	0.000	0.000
04955fdd-d0f5-4355-a51b-4c78e6fa51b5	f0906684-99d3-55aa-9994-9427e941823e	واي 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:20:17.1682+00	2026-02-04 16:20:17.1682+00	0.000	0.000
74f991b9-037e-480f-b6d4-e47da50d2e4a	f0906684-99d3-55aa-9994-9427e941823e	تي بباب 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:24:20.57455+00	2026-02-04 16:24:20.57455+00	0.000	0.000
c9d4bbe8-5763-41f3-8fca-6328191b54c6	f0906684-99d3-55aa-9994-9427e941823e	كوع بباب 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:26:10.590267+00	2026-02-04 16:26:10.590267+00	0.000	0.000
01345ffe-fb1e-4b0b-9ccc-b52ce0716020	f0906684-99d3-55aa-9994-9427e941823e	تي 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:33:49.525696+00	2026-02-04 16:33:49.525696+00	0.000	0.000
ef927bc2-dd52-4c27-af97-abef6001cb3d	f0906684-99d3-55aa-9994-9427e941823e	جلبة 2" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:38:33.48579+00	2026-02-04 16:38:33.48579+00	0.000	0.000
7da00ad0-bb2c-4d44-b9d0-52caf278cd55	f0906684-99d3-55aa-9994-9427e941823e	طبة تسليك سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 16:40:02.365338+00	2026-02-04 16:40:02.365338+00	0.000	0.000
95397be8-d564-4c4d-a4d4-52bc321fb9e5	f0906684-99d3-55aa-9994-9427e941823e	تي بباب 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:15:36.281301+00	2026-02-04 19:15:36.281301+00	0.000	0.000
7516d39d-1ba9-4514-8694-b156c4b3f404	f0906684-99d3-55aa-9994-9427e941823e	جلبة لحام 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:16:50.471338+00	2026-02-04 19:16:50.471338+00	0.000	0.000
446eca70-ca36-48ac-86a0-10f6e18c01a9	f0906684-99d3-55aa-9994-9427e941823e	تي 4" عادة سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:18:56.727941+00	2026-02-04 19:18:56.727941+00	0.000	0.000
8d300a64-8928-47af-9d61-e8cda073dcc3	f0906684-99d3-55aa-9994-9427e941823e	كوع مفتوح 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:20:28.168356+00	2026-02-04 19:20:28.168356+00	0.000	0.000
4d4366c5-3ee6-44bf-ac5a-a341aaf15057	f0906684-99d3-55aa-9994-9427e941823e	برقع بلاعة سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:22:12.903896+00	2026-02-04 19:22:12.903896+00	0.000	0.000
1cd6083f-f377-478d-b54e-a3a0b8a66595	f0906684-99d3-55aa-9994-9427e941823e	نقاص 2 * 1.5 سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:23:01.208091+00	2026-02-04 19:23:01.208091+00	0.000	0.000
2653d564-e6ce-4bd7-86f0-f84f09d3c529	f0906684-99d3-55aa-9994-9427e941823e	نقاص 1.5 * 1 سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:23:32.151448+00	2026-02-04 19:23:32.151448+00	0.000	0.000
0df5e9da-aa4e-44b8-aa5b-bf926888b7c6	f0906684-99d3-55aa-9994-9427e941823e	هواية 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:24:15.993677+00	2026-02-04 19:24:15.993677+00	0.000	0.000
b2695def-80ca-4556-85df-e9cf5440d08d	f0906684-99d3-55aa-9994-9427e941823e	هواية 1" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:25:31.479382+00	2026-02-04 19:25:31.479382+00	0.000	0.000
a092d113-7153-47dd-8589-2a48f7807e6d	f0906684-99d3-55aa-9994-9427e941823e	واي 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:27:36.55209+00	2026-02-04 19:27:36.55209+00	0.000	0.000
ea08286a-83e1-4151-8221-3ad4cbf6fd9d	f0906684-99d3-55aa-9994-9427e941823e	وصلة تمدد 4" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:32:54.583146+00	2026-02-04 19:32:54.583146+00	0.000	0.000
a01fae38-7472-40c8-a340-7915a7359b6b	f0906684-99d3-55aa-9994-9427e941823e	كوع بسن داخلي 1.5" سمارت	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-04 19:34:37.70368+00	2026-02-04 19:34:37.70368+00	0.000	0.000
1697cc2b-8aa6-40c8-8d42-412bcb10dca9	f0906684-99d3-55aa-9994-9427e941823e	اختبار	\N	عدد	111.00	0.00	0.00	\N	small	standard	plastic	\N	t	2026-02-06 22:00:13.12123+00	2026-02-06 22:00:13.12123+00	0.000	0.000
cca800ba-631f-49da-94c9-8ea5b8e8ea6b	92d22b39-ff32-572a-a53e-3e3942306976	طبة 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 16:25:42.309536+00	2026-02-05 16:25:42.309536+00	0.000	0.000
ffd44b52-646c-48dd-ad49-7a955a9dcb21	92d22b39-ff32-572a-a53e-3e3942306976	طبة كاب 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 16:30:06.145087+00	2026-02-05 16:30:06.145087+00	0.000	0.000
d468aa72-a661-4d6a-bac0-431892931b0b	92d22b39-ff32-572a-a53e-3e3942306976	طبة كاب 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:06:40.193488+00	2026-02-05 17:06:40.193488+00	0.000	0.000
fdbf99f3-062b-4011-814f-e8e50634b02d	92d22b39-ff32-572a-a53e-3e3942306976	تي 1.5 * 0.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:08:11.609015+00	2026-02-05 17:08:11.609015+00	0.000	0.000
74d2c47d-ad15-41de-98b4-b4d6d98c659c	92d22b39-ff32-572a-a53e-3e3942306976	تي 2" * 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:55:14.189288+00	2026-02-05 17:55:14.189288+00	0.000	0.000
f305a965-af31-433c-9514-e050f4508875	92d22b39-ff32-572a-a53e-3e3942306976	تي 2" * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:55:44.690649+00	2026-02-05 17:55:44.690649+00	0.000	0.000
df868d6f-bda5-4441-893a-9fe733f91e32	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1.5 * 1	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 17:59:49.503819+00	2026-02-05 17:59:49.503819+00	0.000	0.000
1f687959-dffd-407a-83d6-63980b3fb35e	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:07:35.726949+00	2026-02-05 18:07:35.726949+00	0.000	0.000
7e96927a-e82c-40dd-b730-40452540550b	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 2 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:09:45.183057+00	2026-02-05 18:09:45.183057+00	0.000	0.000
b93d809f-b9c2-462f-b50f-584a05e408f7	92d22b39-ff32-572a-a53e-3e3942306976	تي 1.5 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:10:11.359066+00	2026-02-05 18:10:11.359066+00	0.000	0.000
7e82c0ee-eb1a-48c8-8c31-d57c4ee62112	92d22b39-ff32-572a-a53e-3e3942306976	طبة اختبار الوان	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:12:26.36636+00	2026-02-05 18:12:26.36636+00	0.000	0.000
5582619d-2012-4f07-83c0-c904f6e57bc3	92d22b39-ff32-572a-a53e-3e3942306976	طبة 2 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:13:57.381539+00	2026-02-05 18:13:57.381539+00	0.000	0.000
ffa0d3cc-9d21-44ee-8ac7-5e3b17ddee92	92d22b39-ff32-572a-a53e-3e3942306976	تي لحام 1.5 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:15:28.382625+00	2026-02-05 18:15:28.382625+00	0.000	0.000
3da95089-bfa4-407c-ba9d-8b096302c4ef	92d22b39-ff32-572a-a53e-3e3942306976	تي 2 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:16:10.846336+00	2026-02-05 18:16:10.846336+00	0.000	0.000
46401744-e12c-435b-baa4-5fd53469118e	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 2 * 1.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:18:47.855139+00	2026-02-05 18:18:47.855139+00	0.000	0.000
658992d5-1f93-4309-afb5-22dd41777f6c	92d22b39-ff32-572a-a53e-3e3942306976	تي لحام 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:19:46.542462+00	2026-02-05 18:19:46.542462+00	0.000	0.000
9dcdf30e-a5b5-4636-af3b-a8491cb82704	92d22b39-ff32-572a-a53e-3e3942306976	تي لحام 1" * 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:21:11.054137+00	2026-02-05 18:21:11.054137+00	0.000	0.000
429fcc2b-56f4-4e32-a3bf-3437b64a3201	92d22b39-ff32-572a-a53e-3e3942306976	تي لحام 1 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:21:36.974283+00	2026-02-05 18:21:36.974283+00	0.000	0.000
99bec8cc-8f51-4bff-b8c4-6c79bef4892e	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1.5 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:25:47.389968+00	2026-02-05 18:25:47.389968+00	0.000	0.000
9fa7f793-227b-44d7-a95c-c88c5705e89c	92d22b39-ff32-572a-a53e-3e3942306976	كوع لحام 1 * 0.5	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:26:25.710839+00	2026-02-05 18:26:25.710839+00	0.000	0.000
b0010911-a553-4480-9d0d-d51e432e61b6	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:27:11.517947+00	2026-02-05 18:27:11.517947+00	0.000	0.000
4ff0fa6b-1b53-4064-98b5-30bba06b1dfa	92d22b39-ff32-572a-a53e-3e3942306976	كوع 1 * 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:27:37.822443+00	2026-02-05 18:27:37.822443+00	0.000	0.000
92565437-4f18-408f-ac3d-ffc4624663ed	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1.5 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:28:53.022014+00	2026-02-05 18:28:53.022014+00	0.000	0.000
55612a96-6a02-474c-ac65-009a45ab9d9f	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 1 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:30:26.142125+00	2026-02-05 18:30:26.142125+00	0.000	0.000
55747c66-cd99-453d-be45-ecd7ce155ec3	92d22b39-ff32-572a-a53e-3e3942306976	نقاص 3/4 * 1/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-05 18:33:01.949471+00	2026-02-05 18:33:01.949471+00	0.000	0.000
64c281e1-8184-463e-bee6-0e83f1b9b7aa	8f28d905-151c-55b6-8379-1d5332eced40	كوع عادة 4" BFS	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:27:12.223007+00	2026-02-17 17:27:12.223007+00	0.000	0.000
48d5fc8b-2739-48e2-9ee4-3c0fab0d6bf7	8f28d905-151c-55b6-8379-1d5332eced40	كوع مفتوح 4" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:27:41.838572+00	2026-02-17 17:27:41.838572+00	0.000	0.000
dfa66d4f-7243-48a9-a33c-5e072222cac4	8f28d905-151c-55b6-8379-1d5332eced40	كوع بباب 4" BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:28:08.527426+00	2026-02-17 17:28:08.527426+00	0.000	0.000
6567f7cf-c146-4df8-a3be-8650e082cad7	8f28d905-151c-55b6-8379-1d5332eced40	كوع باب 4" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:28:35.854887+00	2026-02-17 17:28:35.854887+00	0.000	0.000
dcaf8c13-ddc1-4fb6-849b-694a0c59edc2	8f28d905-151c-55b6-8379-1d5332eced40	جلبة لحام 4" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:29:00.27245+00	2026-02-17 17:29:00.27245+00	0.000	0.000
fc3a49eb-0812-42b7-9f84-08333b2559d8	8f28d905-151c-55b6-8379-1d5332eced40	جلبة اصلاح 3" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:30:02.215396+00	2026-02-17 17:30:02.215396+00	0.000	0.000
ca29c5d5-7258-4543-9775-474b7a2e2256	8f28d905-151c-55b6-8379-1d5332eced40	جلبة لحام 3" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:30:43.439673+00	2026-02-17 17:30:43.439673+00	0.000	0.000
597008d4-6870-4765-96e9-29436230b29e	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 3 على 2 روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:34:22.734638+00	2026-02-17 17:34:22.734638+00	0.000	0.000
9f1b35b7-6bd2-40cd-8453-c6288391b2a8	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 3 على 2 باب روك	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:37:19.487416+00	2026-02-17 17:37:19.487416+00	0.000	0.000
63f63c8e-27f5-479a-a4ed-48d8ef15c1e0	8f28d905-151c-55b6-8379-1d5332eced40	نقاص 6 على 4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:37:36.206737+00	2026-02-17 17:37:36.206737+00	0.000	0.000
9230b14e-5c16-482b-998a-c3cc6242c67a	8f28d905-151c-55b6-8379-1d5332eced40	صليبة 3" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:39:44.590162+00	2026-02-17 17:39:44.590162+00	0.000	0.000
9838af29-0eeb-401b-b8b9-e7272e248cc2	8f28d905-151c-55b6-8379-1d5332eced40	نقاص 4 على 3	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:40:22.670993+00	2026-02-17 17:40:22.670993+00	0.000	0.000
89c711d3-026a-4080-90e5-5854aadbfad2	8f28d905-151c-55b6-8379-1d5332eced40	نقاص 3 على 2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:40:54.669555+00	2026-02-17 17:40:54.669555+00	0.000	0.000
80955f9e-f1a7-4dd6-b254-d0aae0786059	8f28d905-151c-55b6-8379-1d5332eced40	نقاص 4 على 2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:41:33.598368+00	2026-02-17 17:41:33.598368+00	0.000	0.000
5d19848f-34eb-48f2-8d0e-bff2658bb264	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 3" بباب روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:41:50.718026+00	2026-02-17 17:41:50.718026+00	0.000	0.000
71e6c269-0b0a-4ff3-95bd-a105988cdda0	8f28d905-151c-55b6-8379-1d5332eced40	واي 3" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:42:12.735868+00	2026-02-17 17:42:12.735868+00	0.000	0.000
ea4801eb-2031-4f2d-a875-16e122174ba1	8f28d905-151c-55b6-8379-1d5332eced40	مشترك واي 4"	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:00:06.469912+00	2026-02-20 19:00:06.469912+00	0.000	0.000
27ae4b21-56ff-449e-bdc0-e3412e63d57c	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4 على 2 بباب	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:00:37.78151+00	2026-02-20 19:00:37.78151+00	0.000	0.000
5a9a1c42-136b-45d4-93f1-0ca22ca48e21	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4 على 2 عادة	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:01:26.605874+00	2026-02-20 19:01:26.605874+00	0.000	0.000
53a965c4-ec9f-4331-8c09-7ae3eb11c2bc	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4 على 3 بباب	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:03:19.581906+00	2026-02-20 19:03:19.581906+00	0.000	0.000
0b532dc7-1461-473d-a967-fca1cef3817c	8f28d905-151c-55b6-8379-1d5332eced40	جلبة لحام 6" 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:09:15.685113+00	2026-02-20 19:09:45.006064+00	0.000	0.000
d886bc4f-a8d0-425d-8919-b03e171ca969	8f28d905-151c-55b6-8379-1d5332eced40	جلبة لحام  6" 160	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:10:13.045315+00	2026-02-20 19:10:13.045315+00	0.000	0.000
f3d9f278-2361-45dc-b5c3-9b12be2f20e8	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6" 160 بباب	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:10:38.32447+00	2026-02-20 19:10:38.32447+00	0.000	0.000
18ef625c-0276-44dd-890c-8917d875580e	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6" 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:11:15.28564+00	2026-02-20 19:11:15.28564+00	0.000	0.000
19df2fa4-493a-4977-9f28-df694c4fa19e	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6" عادة 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:11:29.877766+00	2026-02-20 19:11:29.877766+00	0.000	0.000
c48b78b3-b5bf-41f2-8a1e-dd3cb2497de6	8f28d905-151c-55b6-8379-1d5332eced40	كوع 6" بباب 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:11:42.548745+00	2026-02-20 19:11:42.548745+00	0.000	0.000
9d9a0a7f-d9f6-4032-89ba-e04abc66217f	8f28d905-151c-55b6-8379-1d5332eced40	كوع 6" بوصة بباب 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:11:53.589739+00	2026-02-20 19:11:53.589739+00	0.000	0.000
274c2b30-5c67-452d-8668-d0e04a0f3752	8f28d905-151c-55b6-8379-1d5332eced40	كوع مفتوح 6"بباب 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-20 19:12:24.357203+00	2026-02-20 19:12:24.357203+00	0.000	0.000
d936244e-daa6-4f8e-a484-e8976bd04eb7	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/2 عاده	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:11:53.080656+00	2026-02-21 21:11:53.080656+00	0.000	0.000
f2dee181-2ff3-4ca5-a5eb-610dc49f5969	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/3 باب	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:12:37.221354+00	2026-02-21 21:12:37.221354+00	0.000	0.000
c3e347d9-49ce-471d-95b9-e53b8aef5a65	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/3 عاده	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:13:39.109783+00	2026-02-21 21:13:39.109783+00	0.000	0.000
87d7c4ab-4a5e-4140-9b56-693d38a64a63	8f28d905-151c-55b6-8379-1d5332eced40	جلبه لحام 6 بوصه168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:17:12.917242+00	2026-02-21 21:17:12.917242+00	0.000	0.000
a44e2af6-528b-4e34-9e0e-a8b4a4ab7198	8f28d905-151c-55b6-8379-1d5332eced40	جلبه لحام 6 بوصه 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:17:53.237769+00	2026-02-21 21:17:53.237769+00	0.000	0.000
c8ed0258-b82f-46df-b1d5-a9cca14ff8fa	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6 بوصه 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:18:37.299647+00	2026-02-21 21:18:37.299647+00	0.000	0.000
6deedd3b-0c5a-4535-b6e9-df2e2ae52399	8f28d905-151c-55b6-8379-1d5332eced40	مشترك باب 6 بوصه 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:19:32.292231+00	2026-02-21 21:19:32.292231+00	0.000	0.000
b6cc78ec-f150-4350-90b6-f3ae1f4068d3	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6بوصه 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:20:26.886073+00	2026-02-21 21:20:26.886073+00	0.000	0.000
1ce1c5c8-03bb-4f93-8e4c-84a6b69f386c	8f28d905-151c-55b6-8379-1d5332eced40	كوع باب 6 بوصه 168 روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:21:26.531987+00	2026-02-21 21:21:26.531987+00	0.000	0.000
1587c12f-d8dc-40f5-8d22-d051af0287fd	8f28d905-151c-55b6-8379-1d5332eced40	كوع باب 6 بوصه 160 روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:22:21.540549+00	2026-02-21 21:22:21.540549+00	0.000	0.000
433f723b-d4d3-4dbe-9866-49c9fcd6c040	8f28d905-151c-55b6-8379-1d5332eced40	كوع مفتوح 6 بوصه 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:23:01.828092+00	2026-02-21 21:23:01.828092+00	0.000	0.000
c973aa90-e274-4a13-bd63-fb0141d26fb5	8f28d905-151c-55b6-8379-1d5332eced40	كوع عاده 6 بوصه 168	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:23:38.899672+00	2026-02-21 21:23:38.899672+00	0.000	0.000
429a54f9-6312-4e78-a0f0-3621129feb75	8f28d905-151c-55b6-8379-1d5332eced40	كوع مفتوح 6 بوصه 160	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:24:14.886048+00	2026-02-21 21:24:14.886048+00	0.000	0.000
48272cca-653d-4506-b8fd-d5e3a4f1835f	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6/4 160*110	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:25:05.66843+00	2026-02-21 21:25:05.66843+00	0.000	0.000
4e81ce7f-47a6-4813-ae27-30d0d1753051	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 6/4 168*114	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:25:54.564452+00	2026-02-21 21:25:54.564452+00	0.000	0.000
125dffb9-8af1-4a61-b5b6-89d48a631935	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/3BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:26:58.852132+00	2026-02-21 21:26:58.852132+00	0.000	0.000
c987d093-12be-452d-b2b7-bc0eebcf8389	8f28d905-151c-55b6-8379-1d5332eced40	مشترك باب 4/3 البحر الأحمر	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:28:06.131785+00	2026-02-21 21:28:06.131785+00	0.000	0.000
c7f3e93a-438f-480a-977a-4b1c03769984	8f28d905-151c-55b6-8379-1d5332eced40	صليبه 4/2 الأهرام	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:28:45.65167+00	2026-02-21 21:28:45.65167+00	0.000	0.000
c1a296c0-6471-45fd-bb5e-5f91f68e77fd	8f28d905-151c-55b6-8379-1d5332eced40	جلبه لحام 4 بوصه روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:29:27.395828+00	2026-02-21 21:29:27.395828+00	0.000	0.000
e8064580-f5a5-42d8-a083-bd3e3d3f4481	8f28d905-151c-55b6-8379-1d5332eced40	جلبه اصلاح 4 بوصه روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:30:08.77231+00	2026-02-21 21:30:08.77231+00	0.000	0.000
7bd70918-ce49-4b75-b72c-18154bd2f79a	8f28d905-151c-55b6-8379-1d5332eced40	واى 4 بوصه	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:32:32.709138+00	2026-02-21 21:32:32.709138+00	0.000	0.000
0fe7c2a0-f60e-4f15-b284-2c8b1b12d7dc	8f28d905-151c-55b6-8379-1d5332eced40	مشترك باب 4/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:33:11.363362+00	2026-02-21 21:33:11.363362+00	0.000	0.000
ec568ee9-0b5f-4dc4-a628-fd3f5fe9db4d	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/2	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:33:51.187818+00	2026-02-21 21:33:51.187818+00	0.000	0.000
de486650-4431-4dde-aa4d-4ce6be1554d8	8f28d905-151c-55b6-8379-1d5332eced40	مشترك باب 4/3	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:34:49.379716+00	2026-02-21 21:34:49.379716+00	0.000	0.000
e7cb2e9b-10a3-42a5-9c43-04f5fc233e88	8f28d905-151c-55b6-8379-1d5332eced40	مشترك 4/3	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-21 21:35:23.395697+00	2026-02-21 21:35:23.395697+00	0.000	0.000
150417bc-5700-4216-b3b2-8025ab306799	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1" BFS	\N	قطعة	0.00	0.00	0.00	BFS	1 بوصة	\N	بولي	\N	t	2026-02-17 16:17:16.570873+00	2026-02-17 16:17:16.570873+00	0.000	0.000
7637f2f6-5553-4362-9abe-b79b9b211e66	36041da5-c9a4-574f-9538-790b9601a464	تي لحام 2" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:17:58.17133+00	2026-02-17 16:17:58.17133+00	0.000	0.000
612e2397-4ece-4c57-a7f9-842843bed5be	36041da5-c9a4-574f-9538-790b9601a464	تي لحام 1.5" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:19:05.506041+00	2026-02-17 16:19:05.506041+00	0.000	0.000
955997b7-2036-4f64-adf6-26ee55975902	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 1.5 اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:21:11.874888+00	2026-02-17 16:21:11.874888+00	0.000	0.000
25786994-56ff-4a82-9b45-c8d30fc092c8	36041da5-c9a4-574f-9538-790b9601a464	كوع بسن داخلي 1*3/4"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:22:12.169365+00	2026-02-17 16:22:12.169365+00	0.000	0.000
8f6beea1-072b-4f7d-9bc6-8591373b292e	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 2" اكوا روك	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:24:05.394756+00	2026-02-17 16:24:05.394756+00	0.000	0.000
3d6cff07-15a4-4c75-992d-ce195ec48a0c	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:25:41.826927+00	2026-02-17 16:25:41.826927+00	0.000	0.000
d2a03983-48c8-42f0-8675-2b0aeec3e469	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 1" كايرو ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:26:24.833411+00	2026-02-17 16:26:24.833411+00	0.000	0.000
356ad760-f17e-4108-aa87-3f44b452fbd0	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 1" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:27:24.738933+00	2026-02-17 16:27:24.738933+00	0.000	0.000
511fc549-b298-481f-ae1a-d0cc9b4dfe9d	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1.5" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:28:24.929834+00	2026-02-17 16:28:24.929834+00	0.000	0.000
3fc85ed1-884e-4034-9ac6-2dd78c114a4b	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1.5" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:29:08.465047+00	2026-02-17 16:29:08.465047+00	0.000	0.000
4c046095-bd35-4fe7-ba57-b3fe61d3b3b9	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1.5" معزول BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:30:14.513404+00	2026-02-17 16:30:14.513404+00	0.000	0.000
fb5099b2-64e9-452e-b4d6-2c3591a1b042	36041da5-c9a4-574f-9538-790b9601a464	تي سن 1 * 1/2"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:31:07.986514+00	2026-02-17 16:31:07.986514+00	0.000	0.000
556f835a-5c2b-44a5-a3a2-086a96b984d3	36041da5-c9a4-574f-9538-790b9601a464	كوع بسن 1" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:31:57.905305+00	2026-02-17 16:31:57.905305+00	0.000	0.000
2cc00c44-0fde-4eaf-9a50-927b79ab7097	36041da5-c9a4-574f-9538-790b9601a464	تي لحام 1" اكوا روك	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:33:34.561086+00	2026-02-17 16:33:34.561086+00	0.000	0.000
46051af4-1f3c-4cb8-8018-08c7158d73c4	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 2" BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:34:17.409953+00	2026-02-17 16:34:17.409953+00	0.000	0.000
762e3eca-4c16-438c-bde5-49aebf6d8be9	36041da5-c9a4-574f-9538-790b9601a464	تي لحام 1" BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:35:01.264861+00	2026-02-17 16:35:01.264861+00	0.000	0.000
8f408e6d-5856-4378-a341-ef62648949ea	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 2" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:35:32.866681+00	2026-02-17 16:35:32.866681+00	0.000	0.000
6bacb56d-ae76-419f-93ce-564835dd276f	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1.5" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:36:26.161745+00	2026-02-17 16:36:26.161745+00	0.000	0.000
50092680-cdcf-4383-8803-ec896ba51cb9	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:37:15.041683+00	2026-02-17 16:37:15.041683+00	0.000	0.000
d60038ee-8ce8-44e1-8e87-3e0e75660752	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1*3/4" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:39:37.13686+00	2026-02-17 16:39:37.13686+00	0.000	0.000
44a29ecc-7b57-44f8-9298-01d1a42f76d4	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:40:24.241494+00	2026-02-17 16:40:24.241494+00	0.000	0.000
9f22d4f4-5c38-4ca7-9078-a9d451317a5f	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1*3/4 كايرو ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:42:32.658476+00	2026-02-17 16:42:32.658476+00	0.000	0.000
92a0b6e4-83c5-4abe-8dad-32bdf4c0df62	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 1" كايرو ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:43:09.825812+00	2026-02-17 16:43:09.825812+00	0.000	0.000
6416cbb3-ef5c-4b48-910c-e1f891054f13	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1.5 بوصة BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:43:37.217406+00	2026-02-17 16:43:37.217406+00	0.000	0.000
9430efeb-9681-4466-b405-c11f7fd0411e	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1.5" معزول اكوا جرين	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:44:19.088721+00	2026-02-17 16:44:19.088721+00	0.000	0.000
3041ec21-6f51-4485-8515-b10a24942254	36041da5-c9a4-574f-9538-790b9601a464	تي سن داخلي عادي 1" اكوا ستار	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 16:44:59.408798+00	2026-02-17 16:44:59.408798+00	0.000	0.000
753605cc-8cdb-4fa2-a0c3-174686ddedf4	36041da5-c9a4-574f-9538-790b9601a464	تي سن داخلي عالي 1" اكوا ستار	\N	عدد	0.00	0.00	0.00	\N	\N	ض	\N	\N	t	2026-02-17 16:45:23.904255+00	2026-02-17 16:45:23.904255+00	0.000	0.000
a4924db4-ea93-4351-9379-4280a11f5b6f	36041da5-c9a4-574f-9538-790b9601a464	كوع بسن داخلي 1*3/4" لافيستا	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:07:52.017481+00	2026-02-17 17:07:52.017481+00	0.000	0.000
51d95493-39bf-475c-9813-c22378608033	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 2" اكوا روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:08:23.232776+00	2026-02-17 17:08:23.232776+00	0.000	0.000
a42630ba-4abb-49ad-b469-7860b870c6bd	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 2" BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:17:27.78349+00	2026-02-17 17:17:27.78349+00	0.000	0.000
81b8e587-43f6-4aa7-89f4-2a959a309ccd	36041da5-c9a4-574f-9538-790b9601a464	تي محبس دفن 1*3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:20:28.3524+00	2026-02-17 17:20:28.3524+00	0.000	0.000
bba112a6-5123-4eec-8359-ab2005280f18	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 3/4 ستار ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:22:52.6234+00	2026-02-17 17:22:52.6234+00	0.000	0.000
dc7a612e-4896-4e1b-992c-445b206f40f7	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن داخلي 3/4 ستار ثيرم	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:23:34.527814+00	2026-02-17 17:23:34.527814+00	0.000	0.000
3c49a84e-2451-459c-81a9-50577aa031ff	36041da5-c9a4-574f-9538-790b9601a464	جلبة لحام 1" معزول BFS	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:24:27.167207+00	2026-02-17 17:24:27.167207+00	0.000	0.000
5a108d5a-5cd0-4061-a61a-8487514cd407	36041da5-c9a4-574f-9538-790b9601a464	كوع لحام 1" معزول BFS	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:25:02.719521+00	2026-02-17 17:25:02.719521+00	0.000	0.000
6aa50703-922e-4b64-a284-90ed8be49d64	36041da5-c9a4-574f-9538-790b9601a464	جلبة سن خارجي 2" روك	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-02-17 17:26:08.143744+00	2026-02-17 17:26:08.143744+00	0.000	0.000
c3fa9713-cfff-4df1-a1be-e67923363d0a	ae20d096-97b0-524d-bf38-e8865a491102	خرطوم سوستة	\N	قطعة	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 00:59:41.182496+00	2026-03-10 00:59:41.182496+00	0.000	0.000
69c84270-5d73-406f-a0f6-4509aa6ffd14	ae20d096-97b0-524d-bf38-e8865a491102	مشتمل دفن	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 00:59:53.495774+00	2026-03-10 00:59:53.495774+00	0.000	0.000
5b317e75-8dcd-4ae8-8a1e-ee0de4afc793	ae20d096-97b0-524d-bf38-e8865a491102	شيك بلف 1.5"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:01:03.95927+00	2026-03-10 01:01:03.95927+00	0.000	0.000
a2f62574-cda1-4f08-b38e-4cb5d32188b6	ae20d096-97b0-524d-bf38-e8865a491102	مجرى خرج مجوز	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:01:18.567212+00	2026-03-10 01:01:18.567212+00	0.000	0.000
c5f83958-3304-4314-a56f-7fe15431bc7b	ae20d096-97b0-524d-bf38-e8865a491102	كوع نزل	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:01:28.455547+00	2026-03-10 01:01:28.455547+00	0.000	0.000
81f74c2a-1ec7-4771-9329-92b0d0eb7ddd	ae20d096-97b0-524d-bf38-e8865a491102	شيك بلف لاكور 3/4	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:01:52.695222+00	2026-03-10 01:01:52.695222+00	0.000	0.000
561a1696-03a7-4801-8efd-a117a2121f3b	ae20d096-97b0-524d-bf38-e8865a491102	شيك بلف لاكور 1"	\N	عدد	0.00	0.00	0.00	\N	\N	\N	\N	\N	t	2026-03-10 01:02:12.903167+00	2026-03-10 01:02:12.903167+00	0.000	0.000
8bf8a752-b3fe-4e2c-9f0f-6396f484f085	d17128f8-94aa-54ce-87d8-4dc515f98bf8	منتج تجريبي	\N	عدد	0.00	0.00	10.00		\N	\N	\N	\N	t	2026-03-30 01:42:54.200292+00	2026-03-30 01:42:54.200292+00	0.000	0.000
c8b78e53-a457-4b32-8897-c449f3fe1e4f	7f15ec9b-720f-580d-ad54-61fcb04a20d9	محبس بالأكور سالمكو محمل بوصة (ادهم)	\N	عدد	320.00	220.00	10.00	\N	\N	\N	\N	\N	t	2026-01-18 19:53:20.393421+00	2026-03-28 15:00:49.234672+00	0.000	0.000
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
\.


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales (id, invoice_number, customer_id, warehouse_id, cashier_id, shift_id, sale_mode, status, discount_amount, notes, created_at, is_credit, created_by) FROM stdin;
c226fe67-ae31-4d7e-babe-becb70294339	INV-0325182125	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 18:21:25.445077+00	f	\N
f0caea27-2456-4ac1-9e91-535c9488f8d1	INV-0325182137	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 18:21:37.532105+00	f	\N
4cf0467b-29c4-448a-8edf-11efa6c23756	INV-0325182313	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 18:23:13.379562+00	f	\N
33f210e9-d206-48b3-b8e3-5f8ca0fcc44f	INV-0325182324	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 18:23:24.821394+00	f	\N
da2ba20c-9068-4e49-840b-1053dccae1cf	INV-0325182702	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	returned	0.00	\N	2026-03-25 18:27:02.803282+00	f	\N
fa635f6f-c835-40ac-a8e0-d17436acc603	INV-0325191812	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	8fb616cd-cbf6-4587-9eed-36cba02101b4	wholesale	confirmed	0.00	\N	2026-03-25 19:18:12.618104+00	f	\N
b2ae013b-d8ce-4948-a025-9a7880ff02c6	INV-0325195831	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	confirmed	0.00	\N	2026-03-25 19:58:30.752572+00	f	\N
057b59b5-9e08-4411-bf43-6b75dd16f914	QUO-0325205705	\N	cc063dcf-cef9-4763-a1dc-5a918dbeda93	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	quotation	0.00	\N	2026-03-25 20:57:05.408294+00	f	\N
beea6ccd-679c-413a-8a04-5b820ff8df8f	INV-0325220206	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	55cbdec7-b42c-4183-b251-53aaa8f07c1b	retail	confirmed	0.00	\N	2026-03-25 22:02:06.343297+00	f	\N
7378debc-2ab8-4eda-93cf-baf46683b08d	INV-0325220542	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 22:05:42.362436+00	f	\N
d1a97146-348e-4668-a5df-4ae243bb6b99	INV-0325220628	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 22:06:28.651864+00	f	\N
1d866b7d-b966-4a0e-a83a-2a8438b15f13	INV-0325220649	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 22:06:49.350579+00	f	\N
59b9226f-dfaa-462f-ba0c-f821151888d9	INV-0325220821	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-25 22:08:21.301213+00	f	\N
a51ab5f1-a2ff-4913-8630-f872e1a6ca79	INV-0325220854	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	55cbdec7-b42c-4183-b251-53aaa8f07c1b	retail	returned	0.00	\N	2026-03-25 22:08:53.994403+00	f	\N
8ffd2445-36b9-4860-b005-711c418cc856	INV-0325221111	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	55cbdec7-b42c-4183-b251-53aaa8f07c1b	retail	returned	0.00	\N	2026-03-25 22:11:11.184759+00	f	\N
de55ead7-27bd-4e29-ad9a-e7aef4b74978	INV-0326053034	ea70b37f-e40d-4d13-a014-52ed6cc34d9e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	1dc0d5f0-327a-4708-aff9-26c483ab313b	retail	confirmed	0.00	\N	2026-03-26 05:30:34.229674+00	f	\N
15bf83d7-f130-4bce-a71b-e4587d7d9b62	INV-0326095143	9338ff3f-c554-4648-9965-0b49d68aa7db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	confirmed	0.00	\N	2026-03-26 09:51:42.80797+00	t	\N
8292cd3e-da80-4675-b002-c4e398917432	INV-0326095144	9338ff3f-c554-4648-9965-0b49d68aa7db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-26 09:51:44.029524+00	f	\N
6dda74b4-cb34-4648-8f6e-44fb7a3672b5	INV-0326104103	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	1dc0d5f0-327a-4708-aff9-26c483ab313b	wholesale	confirmed	0.00	\N	2026-03-26 10:41:03.717603+00	t	\N
6348d7f3-012a-4b73-bfec-2fdf78efdc93	INV-0326104521	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	confirmed	0.00	\N	2026-03-26 10:45:20.99253+00	f	\N
48c0fe08-ef76-49d1-bb60-040e3cf6199d	RET-0326104521	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	retail	returned	0.00	مرتجع جزئي من INV-0326104521	2026-03-26 10:45:21.226507+00	f	\N
884ae1ed-8143-4046-8fa4-0d857306db9a	RET-0326125337	9338ff3f-c554-4648-9965-0b49d68aa7db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	returned	0.00	مرتجع جزئي من INV-0326095143	2026-03-26 12:53:37.629082+00	f	\N
0dce5e50-b8c5-4941-a0f6-cf5a48fd046a	INV-0327151000	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	3dcf287f-653a-4299-b80d-c840e1503e2b	retail	confirmed	0.00	\N	2026-03-27 15:10:00.472241+00	f	\N
60741e19-f2c2-4e79-abc7-8f6c53055111	QUO-0327151000	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	quotation	0.00	\N	2026-03-27 15:10:00.739301+00	f	\N
569525ba-651e-4f5c-897d-aa471449308b	INV-0327151032	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	\N	wholesale	confirmed	0.00	\N	2026-03-27 15:10:32.646508+00	f	\N
7189b418-dcf5-4925-ae01-eee514901aa4	INV-0328120249	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	3dcf287f-653a-4299-b80d-c840e1503e2b	retail	confirmed	75.00	\N	2026-03-28 12:02:49.494187+00	f	\N
24d4ae60-0bf1-4056-a83c-a5faa958d10b	INV-0329165628	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	4a7dd547-9642-4562-a0a8-1fa55de24162	retail	confirmed	0.00	\N	2026-03-29 16:56:28.947849+00	t	f00d039c-caa7-5b00-adba-365ed90c5f10
75e919da-7d78-4dbe-ac0b-3ca8abb7407f	INV-001025	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	4a7dd547-9642-4562-a0a8-1fa55de24162	retail	confirmed	0.00	\N	2026-03-29 17:18:47.390297+00	f	f00d039c-caa7-5b00-adba-365ed90c5f10
678a4d14-d028-4c24-a72f-0dbaa1bbb258	INV-001026	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	f00d039c-caa7-5b00-adba-365ed90c5f10	4a7dd547-9642-4562-a0a8-1fa55de24162	retail	confirmed	0.00	\N	2026-03-29 17:18:55.672741+00	f	f00d039c-caa7-5b00-adba-365ed90c5f10
deec8934-2282-4a63-bff3-44e6123420fb	INV-001027	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	a4a070b3-e6f5-499f-9940-dcd41fcc2188	retail	confirmed	0.00	\N	2026-03-30 13:33:52.40389+00	f	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd
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
a4a070b3-e6f5-499f-9940-dcd41fcc2188	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	open	190.00	\N	\N	\N	استلام عهدة من f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:20:24.162693+00	\N	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	6a11d77b-24cc-577e-9ec3-4b0088eb7585	\N	\N
\.


--
-- Data for Name: stock_movements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_movements (id, product_id, warehouse_id, movement_type, qty, unit_cost, unit_price, ref_id, ref_type, note, created_by, created_at) FROM stdin;
2229d3b1-f86b-42e4-8682-58e6909ede91	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	2.000	0.00	320.00	c226fe67-ae31-4d7e-babe-becb70294339	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:21:25.445077+00
d05a6ec4-7044-4301-9ecd-05ee4e360134	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	320.00	f0caea27-2456-4ac1-9e91-535c9488f8d1	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:21:37.532105+00
11f811c7-1777-4e0c-960d-eb78a2e4e896	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	3.000	0.00	320.00	4cf0467b-29c4-448a-8edf-11efa6c23756	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:23:13.379562+00
7f6375c8-e821-4121-ad4f-b09446329b10	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	320.00	33f210e9-d206-48b3-b8e3-5f8ca0fcc44f	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:23:24.821394+00
bc471dc7-5d7b-4f6d-9ceb-7b43e6cf8867	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	2.000	0.00	200.00	15bf83d7-f130-4bce-a71b-e4587d7d9b62	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 09:51:42.80797+00
95396108-8551-4e3b-907f-ef55c9888586	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	100.00	8292cd3e-da80-4675-b002-c4e398917432	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 09:51:44.029524+00
4fddc3a8-d0b7-4f91-afac-cb9363e1f361	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	2.000	0.00	220.00	da2ba20c-9068-4e49-840b-1053dccae1cf	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:27:02.803282+00
04d794f7-ca1c-4df0-8465-8d2ea0459159	ffa8d86a-6352-4d4c-a6f1-76622d09b032	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	0.00	6dda74b4-cb34-4648-8f6e-44fb7a3672b5	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:41:03.717603+00
da25f1fb-fe3b-45a3-8a2b-fbc5b27df2ab	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	70.00	90.00	6dda74b4-cb34-4648-8f6e-44fb7a3672b5	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:41:03.717603+00
20df7163-075c-4537-9632-1a17f07abbe3	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	return_in	2.000	0.00	220.00	da2ba20c-9068-4e49-840b-1053dccae1cf	return	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:33:12.500425+00
230aa18e-a131-4054-8741-9697c971450b	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	5.000	0.00	100.00	6348d7f3-012a-4b73-bfec-2fdf78efdc93	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:45:20.99253+00
29ddb9fc-098f-46a3-be42-07c611b68639	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	return_in	2.000	0.00	100.00	48c0fe08-ef76-49d1-bb60-040e3cf6199d	partial_return	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 10:45:21.226507+00
ba9bda6e-d8a9-4137-b9fa-e71d69239e66	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	return_in	1.000	0.00	200.00	884ae1ed-8143-4046-8fa4-0d857306db9a	partial_return	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 12:53:37.629082+00
a6096fa4-8e3f-4421-9622-a0d317bc2222	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_in	10.000	0.00	0.00	\N	\N	bulk restock	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:47:53.030303+00
76158dca-eb52-4625-b229-40aa5bc1520d	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	adjustment_in	5.000	0.00	0.00	\N	\N	bulk restock 2	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 18:47:53.030303+00
38105649-44ac-41e7-aaae-3ddeefbc0f24	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	100.00	0dce5e50-b8c5-4941-a0f6-cf5a48fd046a	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 15:10:00.472241+00
12b87344-3764-4fed-8d34-c49065871fcb	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	200.00	569525ba-651e-4f5c-897d-aa471449308b	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-27 15:10:32.854446+00
ea8a713e-3535-4f1a-a7a8-7d4a1b9a5e0c	5bb79780-a8aa-4007-b778-5ad0dbb78e6e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	0.00	fa635f6f-c835-40ac-a8e0-d17436acc603	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 19:18:12.618104+00
c9b8efa3-6f60-4892-977d-1b23a3be55de	33f55188-0fe1-4788-9809-3591288e60f3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	4.000	58.00	85.00	fa635f6f-c835-40ac-a8e0-d17436acc603	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 19:18:12.618104+00
cbdda16d-4f64-4471-9014-29329e79da35	811c48aa-84b6-4bed-9771-3e6dd162e9a6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	5.000	0.00	75.00	7189b418-dcf5-4925-ae01-eee514901aa4	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 12:02:49.494187+00
5901e2cf-6849-47ef-8bdb-99e379e14f38	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	5.000	0.00	220.00	b2ae013b-d8ce-4948-a025-9a7880ff02c6	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 19:58:31.031118+00
b005418e-14d6-4b78-9b8f-46cc9061241e	7c033855-5e8a-44e7-a03a-c91729b55080	59a2b8d7-e26b-4979-ae0e-3984f1b711b2	transfer_out	7.000	0.00	0.00	37566316-bffe-4b80-8e23-c8f905921fd6	dispatch	احا	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 14:17:33.501816+00
0ca88067-a697-4c4e-9e9c-b0e7aa64e086	7c033855-5e8a-44e7-a03a-c91729b55080	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	transfer_in	7.000	0.00	0.00	37566316-bffe-4b80-8e23-c8f905921fd6	dispatch	احا	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-28 14:17:33.501816+00
0558b28f-4b58-4521-8285-a9977193f261	c8b78e53-a457-4b32-8897-c449f3fe1e4f	da49f5cd-ecad-46d3-872a-37c80585a2f0	transfer_out	5.000	0.00	0.00	9238cc9e-ab78-4676-8cff-79228ddc1f1c	dispatch	صرف للمعرض	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:49:31.492925+00
444d10bb-c96c-4dae-ab9b-0f3ee5e2e3e7	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	transfer_in	5.000	0.00	0.00	9238cc9e-ab78-4676-8cff-79228ddc1f1c	dispatch	صرف للمعرض	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:49:31.492925+00
7a19544f-19a7-4010-b460-7e5130b39f54	c8b78e53-a457-4b32-8897-c449f3fe1e4f	da49f5cd-ecad-46d3-872a-37c80585a2f0	purchase	100.000	15.50	0.00	96df7161-c316-4e54-93f7-853861ccbc36	goods_receipt	فاتورة 1234	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 20:49:31.620689+00
ec7eb48a-ae16-491e-b9b2-b516fb6c5a00	ca985298-d266-4483-8a13-ff73c90536dc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	72.00	90.00	beea6ccd-679c-413a-8a04-5b820ff8df8f	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:02:06.343297+00
82d81b5c-830a-4a36-840a-2c762a25774f	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	60.00	75.00	beea6ccd-679c-413a-8a04-5b820ff8df8f	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:02:06.343297+00
ab9ce72b-d10e-4157-8ff1-943ff1f80e38	b9b32325-fda4-46a7-b4f4-6da187863e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	40.00	50.00	beea6ccd-679c-413a-8a04-5b820ff8df8f	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:02:06.343297+00
fb74856f-2ba4-4614-834e-87cc55179788	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	320.00	7378debc-2ab8-4eda-93cf-baf46683b08d	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:05:42.362436+00
ddf224f4-ef3a-46b0-9cf4-30356d0d0498	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	320.00	d1a97146-348e-4668-a5df-4ae243bb6b99	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:06:28.651864+00
1bc47d0f-266b-4a37-aad6-7bd6583991c8	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	320.00	1d866b7d-b966-4a0e-a83a-2a8438b15f13	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:06:49.350579+00
98198521-d36f-4da6-9ffd-f2eccbfbccba	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	320.00	59b9226f-dfaa-462f-ba0c-f821151888d9	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:08:21.301213+00
e221dcd5-4fd0-44b1-a55a-9c5978cf3246	ca985298-d266-4483-8a13-ff73c90536dc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	72.00	90.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:08:53.994403+00
9220828b-4c95-42b7-aca8-c52b325e8a70	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	60.00	75.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:08:53.994403+00
210432d3-5d58-4f92-9d82-4e74c617618c	b9b32325-fda4-46a7-b4f4-6da187863e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	40.00	50.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:08:53.994403+00
31cb2630-0c33-4c73-81a4-e5f017ad919a	ca985298-d266-4483-8a13-ff73c90536dc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	return_in	1.000	72.00	90.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	return	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:09:25.975637+00
5b9e150d-96d8-4f71-bafa-97f6c7981e27	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	return_in	1.000	60.00	75.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	return	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:09:25.975637+00
9af62e60-aeb4-4f81-8caf-e0fe75061113	b9b32325-fda4-46a7-b4f4-6da187863e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	return_in	1.000	40.00	50.00	a51ab5f1-a2ff-4913-8630-f872e1a6ca79	return	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:09:25.975637+00
1432c3d4-cc85-4907-bf30-17192a3b8b3e	8cf7eef1-0a73-491c-b6cc-8222f3c45595	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	0.00	60.00	8ffd2445-36b9-4860-b005-711c418cc856	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:11:11.184759+00
4b14322d-178f-4be4-82ca-917fcad366fe	8cf7eef1-0a73-491c-b6cc-8222f3c45595	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	return_in	1.000	0.00	60.00	8ffd2445-36b9-4860-b005-711c418cc856	return	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-25 22:11:24.303735+00
98cecc4a-7e8a-40c5-9d55-b652bd07b85e	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	70.000	60.00	75.00	de55ead7-27bd-4e29-ad9a-e7aef4b74978	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-26 05:30:34.229674+00
22c2464e-d62f-48ee-8ae6-dc0a557e20d1	c8b78e53-a457-4b32-8897-c449f3fe1e4f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	47.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بالأكور سالمكو محمل بوصة (ادهم)	\N	2026-01-18 19:53:20.393421+00
8f159ab2-a9f4-4331-b102-bd02b2f396ff	af31725d-fa0f-42df-88d4-9041e36ad994	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بالأكور 1 ونص بوصة (ادهم)	\N	2026-01-18 20:12:18.345365+00
2bbc42b3-d803-4e18-bbc3-11296ad0c4a0	b9b32325-fda4-46a7-b4f4-6da187863e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	94.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بالأكور بولي*بولي  1/2 بوصة (عمر)	\N	2026-01-19 18:59:35.718523+00
7f0584d0-4fb2-4d43-8c38-e19dd66ad3bd	f0cd51f3-5b93-45a9-bad8-c7f76cc2c726	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	75.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بالأكور بولي*بولي 3/4 بوصة (عمر)	\N	2026-01-19 18:59:57.014037+00
907624fb-4680-4a85-940f-47794011f34f	ca985298-d266-4483-8a13-ff73c90536dc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	18.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بالأكور بولي*بولي 1 بوصة (عمر)	\N	2026-01-19 19:02:29.385696+00
ddef35e8-58c7-4c8a-8ea4-87bce3684389	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	96.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بالأكور 1/2 بوصة	\N	2026-01-20 14:10:40.162417+00
fdfb384e-02ec-4198-a1ea-bd437f9d615d	ffa8d86a-6352-4d4c-a6f1-76622d09b032	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بلية 2" جوبل (ادهم)	\N	2026-01-21 09:36:06.982384+00
c805423e-beaa-41f3-ad6f-ea738645eda7	2ac3dc85-e7cf-4ff1-8aff-01e6d8fd54a1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بلية 2" مياه (ادهم)	\N	2026-01-21 09:37:50.742321+00
399e9d97-651c-42ad-aef5-deed1f69f23c	ab4ba887-5c44-4a22-b567-670c0001b603	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بلية بوصة ونص (يوسف)	\N	2026-01-21 09:41:05.350297+00
973cc6a1-d97b-49d9-a803-cdfce75f7624	c19f42ec-ad6d-4161-9f38-a9c4cecb643b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بلية 3/4 سالمكو (عمار)	\N	2026-01-21 09:43:07.366133+00
553487f0-b56d-4207-b84e-7c3fe5d6c2a5	6d2e9857-cc51-4c79-aa4d-d7b9e4208678	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بلية 3/4 ِAG	\N	2026-01-21 09:43:28.77324+00
d15090d6-c20d-4814-82f2-64a49fd08b92	67ba969e-da10-4bbd-9900-606bf254045b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	27.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بلية PG نص بوصة	\N	2026-01-21 09:47:44.278206+00
307b2525-657a-4629-a25d-5f670d89ba1b	d14ac884-8431-46ba-adcb-5190dbaf9da0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5434.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي نيكل نص بوصة	\N	2026-01-21 09:48:02.678005+00
3271a96d-37bd-4dab-8c60-0972608252f5	695705d9-9757-4f2a-be89-fe096ffd87c2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بلية 1/2 بوصة AG	\N	2026-01-21 09:48:44.598128+00
f3101e0b-489e-409a-bb1f-e71db9b340c1	9f86c75d-e220-45e8-95a2-405be7b53488	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	69.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بلية 1 بوصة سالمكو (ادهم)	\N	2026-01-21 10:53:10.372659+00
479b8f5a-45f1-426d-91da-4d02ef1d18a7	b7d3a006-f7a1-40d6-b3d8-20192e7f93bf	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بالأكور سالمكو محمل 3/4 (يوسف)	\N	2026-01-21 15:36:22.061533+00
e5273cae-58ce-4543-8dda-ab54973df9eb	b41ae764-b97b-4662-b865-b572790ec127	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	93.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس بالأكور عادي محمل 3/4 (يوسف)	\N	2026-01-21 15:36:46.589467+00
5418c6e9-e686-40be-8af8-ad4d4826be10	55cc2075-bfe4-4613-91de-05535390b28a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	149.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية بلاستيك	\N	2026-01-21 16:36:03.564033+00
81bef9c2-5230-43dc-b06f-b0af52c3592e	85114c68-11e1-442b-a79d-0279c2bb798b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	96.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية سكاي 3/4	\N	2026-01-21 16:37:17.691787+00
47dad145-b7f5-41a7-9fbc-2fcbb6641d2a	056ef88b-f53d-4806-9e24-f9f931f54dcf	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	59.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية 3/4" PG (يوسف)	\N	2026-01-21 17:57:09.849733+00
53f632e1-a748-4508-86ce-1684be47b16b	0eb4a2fa-6d82-4005-bbb7-c958edcf281a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية نحاس بلية بوصة (يوسف)	\N	2026-01-21 18:00:15.242202+00
0677655b-e54c-40c0-8d44-630288acbeb4	92a238d8-f2da-4c28-9127-fbc8cece0c0b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية بوز بلاستيك AG (يوسف)	\N	2026-01-21 18:20:28.450377+00
1ebe91ee-3a77-414e-abd3-d3a5f097da04	53a3e08e-728d-4291-b2f7-9cc69a69cbac	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	39.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية ايطالي نص بوصة (يوسف)	\N	2026-01-21 19:56:06.791359+00
709ad1b6-1400-4820-aea6-efa990fac38e	982d6fa2-8c29-4580-863a-215600003c9b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	35.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية نحاس AG نص بوصة (يوسف)	\N	2026-01-22 10:21:43.6071+00
9b450227-436b-4b05-87f6-abdb564be35d	bca0c8ae-6b62-4ad0-a150-47fbd9955eab	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية كوبشة شيلد (عمار)	\N	2026-01-25 10:33:28.660709+00
49193c05-c118-481f-9b24-65e82eb2dcd5	4008a90d-eda0-4bc9-b7d9-0401c419b3e1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية كوبشة شجرة	\N	2026-01-25 10:34:25.603146+00
a534fa39-eb80-4849-850a-3cd70fad6013	bd473534-32ba-4522-912d-ab3c9f59ac24	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية غسالة تركي OM	\N	2026-01-25 10:34:47.580728+00
02b93315-c10d-459f-947c-6e8dda30dece	27b32f29-2ac8-445e-aaf4-531e4cabd48c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية 3/4 بزبوز بلاستيك	\N	2026-01-25 13:07:55.312027+00
ccd24a74-2ed5-4dad-9495-82ac474151a1	811c48aa-84b6-4bed-9771-3e6dd162e9a6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس زاوية استانلس فايف ستار	\N	2026-01-29 12:46:12.866726+00
1b537ce0-0f51-497c-b08e-8386e537ea20	4b596a39-71ad-4be0-adcb-82637141438e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	78.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس زاوية استانلس تورو	\N	2026-01-29 12:46:12.866726+00
8c099252-9a72-446f-b03e-a12ed9ae5743	fd927c9a-2843-4740-b97e-c92f51424765	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس زاوية فايف ستار اسود	\N	2026-01-29 12:46:12.866726+00
796f4ea0-b017-492b-8e70-85e86836e376	b09598b6-4537-4e39-b28b-d50cb6d8d19a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	51.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس سما	\N	2026-01-29 12:46:12.866726+00
99611b12-7e64-4749-a8ec-6fa4fde27986	bf75d681-d9d1-4af8-871f-2ed687b63fd1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	149.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس زاوية كعب نحاس	\N	2026-01-29 12:46:12.866726+00
dc20a8b2-256a-4032-b08e-46d0c2a5e05f	4c7f2b6e-8a67-489f-ad91-257ba78a7f51	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	445.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس نحاس اوزو	\N	2026-01-29 12:46:12.866726+00
cd2de55a-3b89-4f2b-8356-091f7e7be6f2	ec991740-f53e-42ea-9e48-6af7a7696248	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	52.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس فايف ستار	\N	2026-01-29 12:46:12.866726+00
49f5df00-f91d-4c93-8416-2e6e4cb46b83	5b18456a-9aee-431f-8344-81bda7d32061	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس زاوية مكة	\N	2026-01-29 12:50:33.033144+00
de4c7836-7ae0-4f1f-aafe-df781aa57f07	06030f57-05d3-4624-ab21-4f2dbd36628c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	115.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية بلاستيك تركي	\N	2026-02-10 09:40:16.889555+00
d3a67260-aa4e-496b-81cf-b284342a6502	9d19a1d3-c280-4944-879b-0db02b1ebfc9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	411.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | وش نيكل خفيف (عمر)	\N	2026-01-18 20:55:34.840636+00
3da35a5e-b1cb-4372-b6ca-05feefaaf6be	244e72f6-2f15-49f4-8526-3b485ebb345b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة فيدمار سوداء (الكوك)	\N	2026-01-22 14:22:00.846063+00
df162dd1-4bfd-40e4-99d2-a3dca6b45f8e	7652a593-90d8-4ba8-9bf0-d1f452915da4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة دش دفن مدورة (الكوك)	\N	2026-01-22 14:24:50.477843+00
de706183-8878-4474-9b1f-39d4750d8d96	13ab7f8d-4d5c-495d-9665-b12b51ba8097	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة دش دفن عكاز (الكوك)	\N	2026-01-22 14:27:22.798+00
33cda31a-1b7a-414c-a854-34cf691cc8c2	b3634d52-7df0-4e6c-89a9-2887f761f7aa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة دش دفن مربعة طويلة (الكوك)	\N	2026-01-22 14:28:21.375167+00
7aba12b4-370c-4fbe-925d-6b5d4fddeb02	ae78cb21-9bf8-441a-a101-6be57eb4f2c0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة لومي (يوسف)	\N	2026-01-29 12:42:36.459591+00
eec5ca82-8943-4202-a4e5-dfca0798d55e	8cf7eef1-0a73-491c-b6cc-8222f3c45595	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة دش بلاستيك	\N	2026-01-29 12:42:36.459591+00
7f3cd0f9-e514-426d-a915-fbf6f2fd261b	bf47a971-4a38-4adf-84b7-0f838da38a57	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة دش ساليمكو	\N	2026-01-29 12:42:36.459591+00
71e9e8ce-6965-4d1b-a997-c00a23b679b9	65907699-7b64-4dd9-9ea8-d9f8cb23c6f4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة شاور ست	\N	2026-01-29 12:42:36.459591+00
cee2a8ca-5719-42cf-a17f-dccc15a857f3	3e6b7157-4754-456c-a3ef-63d087e40dd3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة دش هاند شاور	\N	2026-01-29 12:42:36.459591+00
73a1c84c-955c-42c8-acc5-e09e64ac7f95	d1aa753f-65da-40f1-8548-eed1df9fac72	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة دش طيبة بلاستيك	\N	2026-01-29 12:42:36.459591+00
47b54b7c-1584-4e4b-892c-a4426e0e4f4f	0a078193-e0d3-4669-b71b-5a4fdda5f8f9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة دش طيبة سرعات	\N	2026-01-29 12:42:36.459591+00
9be0ae66-e508-4b00-934e-ecd6f65ba56f	d268cf2c-4306-4069-92de-d1879e230952	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محول سماعة صامولة	\N	2026-01-29 12:42:36.459591+00
5714691d-94ef-45d1-8563-8823442d4632	3a6f01a4-e9a4-4032-8b64-35410b5a8d5e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محول سماعة بدون صاموصة	\N	2026-01-29 12:42:36.459591+00
516644cb-85d4-44ec-b6a1-675d5ea84ae8	ff053f4f-7e5e-44a6-a452-893663ae65be	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة فايدمار	\N	2026-01-29 12:42:36.459591+00
c01975a7-6e77-411e-b013-1e5077be5eb7	d75fcff2-ef64-48b3-9cd8-e06d40e3a399	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة فيدمار بيضاء	\N	2026-01-29 12:42:36.459591+00
6e087f29-f5cb-432d-ac84-67039149f938	17ef1e9c-6898-494a-8e97-ecf2af3f72fb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دوش 1" 20 * 20 استانلس رانك محملة	\N	2026-01-29 12:43:30.531794+00
1d3dfdb1-2f16-4755-8901-15ff91e1a54d	871b0c43-957e-4eb5-b5f0-4609014c1885	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش مدورة كبيرة بلاستيك	\N	2026-01-29 12:43:30.531794+00
3c5071c1-a659-4349-a3bd-175620e0f0bb	a4d3df08-ac1d-4f42-82f3-da2fdbeb1958	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش 15 * 15 بلاستيك	\N	2026-01-29 12:43:30.531794+00
04e61d2c-7827-4726-9ddb-7f2538c6499f	c06966da-9cdb-4ed6-9296-177f3a63b307	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دوش 1" 20 * 20 استانلس روما محملة	\N	2026-01-29 12:43:30.531794+00
629fc3ff-91b3-40ef-be90-a8998d696909	7838761b-9eb9-46bb-a99e-c09e677377a9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش 10 * 10 استلس لافينا	\N	2026-01-29 12:43:30.531794+00
7325debf-967c-49ce-83fc-ae40306de7e7	7e625f21-6107-40ed-a03a-280e64655065	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش 10 * 10 سنبرس	\N	2026-01-29 12:43:30.531794+00
86f28bdb-21b9-489e-b499-a42439fbfe1c	432e6e7e-c5ea-4639-a2ca-b3cac3b07617	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش استانلس 10 * 10 جولدن ارو	\N	2026-01-29 12:43:30.531794+00
8622e6a3-e9c2-4fc7-984e-45dd45e8bf4d	1a73646e-94d9-4857-92dc-496a90475520	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش 20*20 سان ارساني (يوسف)	\N	2026-01-29 12:43:30.531794+00
c54799df-5ee6-4672-9d2d-84a7f9d3531b	813e8a9d-af7f-496c-80da-0eab496e15df	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش 15 * 15 ارساني	\N	2026-01-29 12:43:30.531794+00
a99d31af-2475-4641-8bfc-bdad42bb7644	a59c2e11-fed2-4972-a7e5-bc34fd5266fd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش 10 * 10 ترنتي	\N	2026-01-29 12:43:30.531794+00
d7dfcdcc-91ed-4096-a60b-46a4fcfd8929	ba07f41a-a9f8-4e30-bb91-be5cfa125019	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش 15 * 15 ترنتي	\N	2026-01-29 12:43:30.531794+00
fab19327-761f-4666-ba69-dbcd1f3bf886	4005644b-b6d1-45f8-8af9-7929eca4e075	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دوش 15 * 15 جولدن ارو	\N	2026-01-29 12:43:30.531794+00
3beeae61-de5b-4b5c-ad0a-2c608534a2d5	ff6f769c-0bfb-49fc-86cf-e73805d51892	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طاسة دش 20 * 20 بلاستيك	\N	2026-01-29 12:43:30.531794+00
875778b7-d3db-4bf6-a39d-7bb45116ff2f	f0b0cc99-32e6-4b1a-8493-25be82e03e31	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	156.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة حوض نيكل(أنس)	\N	2026-02-01 15:41:13.227521+00
9c68b46d-83f6-4626-912a-a07c6ee69e90	edf6547d-ee07-419d-a822-18de5c4ac63d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	630.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بوش نيكل 3/4*1/2	\N	2026-02-01 16:57:47.40477+00
7da8c63b-6464-4aaa-9839-d5aed4e4841d	83759832-7ee5-43fc-8828-695b2d8c7c3e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	176.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | صامولة سيخ شطاف	\N	2026-02-01 17:03:52.832692+00
8c72898f-7b1c-4af1-8372-f72ceb8f5b9c	3892616c-8ad0-47d2-aebc-ba3c30cefb39	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	36.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محول سماعه	\N	2026-02-01 17:41:52.557812+00
c7621337-9b1c-48a1-86e3-40b20f0488fc	cd3b2528-421e-4761-b84e-90651f4cfd3f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | صبانه استالس	\N	2026-02-02 19:23:21.840221+00
42bae0b9-dea1-4d36-9be9-74bd6e933537	128ffb7a-b57c-424e-bd25-b6e16dce002d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	135.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | اوكرة بلاستيك شفاف (عمار)	\N	2026-01-19 19:14:12.808976+00
3e010801-0aca-466f-81cf-6ca9e0e6c7a5	9599e8f6-0e41-4ba6-af39-945ab7b97b91	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	105.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | اوكرة جاجوار (ادهم)	\N	2026-01-20 13:25:15.651997+00
e33b6f02-aecb-450a-bcef-974539a4f01b	4e58a261-a2db-4aa2-8a1b-5a4a38ebfed2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	251.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | اوكرة وردة (ادهم)	\N	2026-01-20 13:26:03.635992+00
9eb09006-9991-4472-b399-d228b8b4cefa	4223c273-9145-42c8-8bb6-e2faf2b7a9b4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	90.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | اوكرة بلاستيك (ادهم)	\N	2026-01-20 13:26:48.852523+00
0deaf879-4d02-452c-bba1-12048defed3c	c0897fde-d9e6-4626-b027-149b7ae5322e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	74.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | يد هاند ميكسر عريضة محملة جداً (عمار)	\N	2026-01-20 13:39:46.244078+00
52c44c2a-b29b-479a-8506-e02d2ed2776c	b1690bbc-ba39-4da5-85ea-7e75005ded9b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | يد هاند ميكسر عريضة محملة (عمار)	\N	2026-01-20 13:41:45.683618+00
4d253834-cab2-497a-b12d-c054e3baf2b5	d387eae9-d064-43d1-ad43-461553cf6a05	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	102.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبل نيكل 1 بوصة (عمار)	\N	2026-01-20 13:43:22.452043+00
4d557b65-7b9f-4880-9c7a-36e26fe92f64	958976e5-78b1-48dd-b90c-639ecac8608e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	70195.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبل نيكل نص بوصة	\N	2026-01-21 09:45:52.790075+00
be4d4314-db76-4200-8f3c-947af5f7ca64	84d19c17-a7a2-4523-9693-5c45c88a5e48	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	103.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بولي 3/4 بوصة (ادهم)	\N	2026-01-20 14:14:53.186684+00
c923bbaa-80c1-4943-b1ef-a651b92fa1f0	6a92aee9-a9f4-490d-bf5f-37ca073ba4f8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	199.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بولي 1/2 بوصة (ادهم)	\N	2026-01-20 14:15:16.691315+00
cfec08c0-20e9-450e-b083-221dc72d712e	70afd455-12ab-4f85-9e1a-5868e01b1511	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	59.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة نيكل 2/1 بوصة	\N	2026-01-20 15:02:53.393661+00
8cfb0488-f173-4be3-8abc-870faf42363a	6972c97c-fdb0-4a9b-b563-06ec0ac883c3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	267.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة نيكل 1/2"	\N	2026-01-21 09:39:22.422214+00
8628b491-df6c-4403-b2cb-fee3d848c0e6	1fe12fb1-b560-4cda-b0cc-db6f35c24079	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	332.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع عادة نص بوصة محمل	\N	2026-01-21 09:42:21.574265+00
de07264b-0bc3-4a25-ae1b-f54930e9fd56	340dd769-792d-4917-9d5e-5d73c4eb605d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	52.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز لاتش 2" (ادهم)	\N	2026-01-21 09:44:15.445975+00
d635b19e-130b-4de1-8ef0-f1c5315c79f2	c9baaa25-10f2-481b-aa74-81d2c5a83f70	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	211.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز لاتش نص بوصة (ادهم)	\N	2026-01-21 09:44:35.814227+00
2e809963-7756-4d88-8882-7f9a7e50d726	d29b5399-d05a-441e-907e-664b9caaded4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5796.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قاعدة كعب خلاط (عمار)	\N	2026-01-21 09:46:58.581873+00
f2fe9727-ef2b-4e5b-8dc8-c2f56664428a	111bc6b3-d484-49b9-adab-2e9790badcde	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	249.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كيس مسامير قلب خشن (الكوك)	\N	2026-02-20 16:41:50.943661+00
1cff609b-5d62-48cb-8fb5-b01c2f583e7b	d739fea9-b75f-4059-901f-eec4c0483b53	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	36.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب هاند ميكسر تكات كبير (عمار)	\N	2026-01-20 13:27:53.619265+00
619e77a4-9e2d-4546-871d-92ff6e0873d5	f3a41c82-cd3e-4ac8-a3cf-49c9a046410c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	37.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب هاند ميكسر بكعب صغير (عمار)	\N	2026-01-20 13:31:49.419637+00
eee651db-0d9e-4f41-adac-0fb00aad641a	2eed92b4-8064-48ee-9f2d-7c302bbdb2aa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	50.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب هاند ميكسر بدون كعب صغير (عمار)	\N	2026-01-20 13:32:28.500164+00
f50cba6b-8c4e-4672-b11e-0394b739403e	b1a685ab-b142-4c3d-95c9-d9100774032d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	57.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب هاند ميكسر بدون كعب كبير (عمار)	\N	2026-01-20 13:33:17.684343+00
1fc94df5-2062-4ca0-8ec1-00635dc78b0a	0ae66dbf-16a0-48bf-b13e-eed2701f3cc6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	191.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب هاند ميكسر بكعب كبير (عمار)	\N	2026-01-20 13:37:43.363781+00
9f688fcf-2089-4b46-b9b5-156f19e89d84	e55b3b91-07db-49dd-a8c0-10d76d164e42	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	132.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبل نيكل 3/4 بوصة (عمار)	\N	2026-01-20 13:44:02.371266+00
eef83891-e9f4-4129-a266-07853aa843fe	2a2a52bb-b8d8-4af4-93d6-41ed8267a589	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	86.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب 1/2	\N	2026-01-26 22:44:10.223261+00
a110d6f9-ba9e-466c-b427-919179410e05	66a706c3-065f-4965-b6f5-a416003ca375	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	139.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب جولد صغير	\N	2026-01-26 22:44:29.582588+00
c5bf378b-9e1b-4eba-bece-1be1ba0c4216	1e06fee4-89c2-4465-bc78-5b71826b797e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	166.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب 3.5 ايطالي	\N	2026-01-26 22:45:02.640757+00
cf007e87-8a0e-4466-b910-f3b09ee45fb6	78539233-0e35-4584-8a63-835c6f128067	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	171.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب 3 لينيا	\N	2026-01-26 22:45:48.201209+00
2f221deb-a020-49c8-bf4f-d79177178754	e2623548-7fd4-4a00-99a6-d772fbc76efa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	74.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب دفن 1/2	\N	2026-01-26 22:48:17.733307+00
f9235bc7-8853-4d1f-885a-71cae8b3480c	708b57dc-834f-466c-8df4-62b50eb8affb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب دفن 3/4 صغير	\N	2026-01-26 22:48:39.412528+00
4a02cbb1-e9a7-4b33-ac99-261648914876	c1186f95-835b-4480-96a0-8a0b3edfd1d6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب دفن 3/4 كبير مربع	\N	2026-01-26 22:49:13.489254+00
c82a0f70-0c0d-458b-918c-d208e6303efa	a710b7fe-897e-43da-808a-c193b7e5573e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب دفن 1 بوصه	\N	2026-01-26 22:49:33.00445+00
849bc4f7-016e-44b9-b989-0ab3b9aa5562	1ab3227c-7697-46a5-8d66-861e81721181	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	65.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب دفن كبير 3/4	\N	2026-01-26 22:49:53.950398+00
5a9d60b7-dc8d-42c6-bf32-5e22db335d69	307e8ebe-dc59-4130-bdc0-363ea0d4caea	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	78.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب جولد كبير	\N	2026-01-26 22:50:48.984631+00
7bedea83-6a1f-47f3-9eb8-bfc76d066f85	446e88dc-63ad-49b3-9018-6042e55df88e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1041.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة تطويل نحاس	\N	2026-01-29 12:52:55.978731+00
a2382fd7-8655-42e9-add7-617b2b659e47	76974cd1-2978-4467-ae5a-b558aa71c242	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	211.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة تطويل استانلس	\N	2026-01-29 12:52:55.978731+00
a464532b-52cc-4dd2-ad93-b7b49fa25db4	e6b6fddb-3d45-4e26-87b1-a5d13cd14132	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	59.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة تطويل استانلس 5 سم	\N	2026-01-29 12:52:55.978731+00
2fd72993-8551-494c-a5ac-8779738c4b86	40cdebca-7a06-49c2-a5fa-850250936c54	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1038.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة تطويل نحاس (1)	\N	2026-01-29 12:53:16.867499+00
09713f18-cc3a-46a5-9f97-6eb30fdc2e4a	72d5081a-5a3c-42f1-af96-68799e6498d8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة تطويل ماتور	\N	2026-01-29 12:53:16.867499+00
b4386b82-3172-4ee6-b256-7146ce342e1d	e178893c-75cf-4e65-a118-70dd4ab0e610	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	95.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قلب 3.5 عادي	\N	2026-01-29 15:14:21.377007+00
3e20f5be-dc56-4396-a04c-fb2fcf944a5a	baeea72c-a311-41bf-9680-40ae18dca71c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	88.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة 2"	\N	2026-02-08 12:46:17.630758+00
264e428a-faba-496f-a422-254f155720d0	db85a468-811d-49b2-8f84-89c4f1aaa3d5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	88.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 60 محملة فايف ستار (الكوك)	\N	2026-01-22 15:29:02.765329+00
03e09ae4-8c76-465b-8516-479b5a3c8f56	24717bd9-9cb5-47b1-9e14-4780dd676eb3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 60 محملة روتانا (الكوك)	\N	2026-01-22 15:30:33.245796+00
02b33924-b212-4e60-8e41-7865453efc70	4b6005cc-aac8-4964-8031-d08ff8f50372	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 50 محملة روتانا (الكوك)	\N	2026-01-22 15:33:15.214038+00
9fe6a3e6-3591-4b17-8c04-d669d8e5f9cf	cf47fda2-2f58-48c3-aa6e-e33743683878	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة شجرة محملة 60 فايف ستار (الكوك)	\N	2026-01-22 15:35:12.396915+00
d784ae77-3ca3-4832-9e22-ac85f36cab4c	68051f41-2be1-42c1-bed7-53af6544d15b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سماعة حراري متر ونص فايف ستار (الكوك)	\N	2026-01-29 12:38:52.731585+00
93b8af41-10f4-4296-b46e-d22457e5fad2	e34c6775-3e66-462d-80db-5bb4fff9601a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	32.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سماعة حراري 2 متر فايف ستار (الكوك)	\N	2026-01-29 12:38:52.731585+00
9ff102c5-c0ed-414d-8ad3-704b9cb13974	1a29b242-fcb5-49a2-95fd-a12c0de7c030	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	46.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سماعة الرحمة (الكوك)	\N	2026-01-29 12:38:52.731585+00
b2e2b2de-f2af-4b45-8581-561f0fbd20e6	879040b7-642e-443d-a467-cb4a3cbc5bc3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سماعة ستار محملة (يوسف)	\N	2026-01-29 12:39:59.0912+00
89c5722d-512e-485a-99ae-d7e525164731	ae005153-de66-49ed-b132-23434ecacf5c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سماعة ستار خفيفة (يوسف)	\N	2026-01-29 12:39:59.0912+00
c2bc237b-9485-413a-af9e-78579182482f	0fd12267-532b-4474-b66e-a1ffa378a6c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سماعة جروهي (يوسف)	\N	2026-01-29 12:39:59.0912+00
ec42cd93-0d29-4625-83bb-00991a75c3e9	8efe2eb5-bd06-48bb-b1ae-b843129e85eb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	124.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة شجرة 60 سم (يوسف)	\N	2026-01-29 12:39:59.0912+00
9d18074b-509d-4778-823d-649f058c5074	72635b19-9fcc-4fd6-9ada-b9cf33bb50a0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	51.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة قنطرة الوان	\N	2026-01-29 12:39:59.0912+00
31640a02-f2d7-4ce3-a424-222615083f0e	3d23ca07-4628-4207-a0a3-e34c38daf932	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	142.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة ناشفة 60سم (انس)	\N	2026-01-30 14:49:36.400484+00
160b335c-e88f-491f-b09a-3f31f37f8d5e	19a8cf3f-9008-41b9-8383-3a361d6c6f59	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	55.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة متر عادية (انس)	\N	2026-01-30 14:49:58.992836+00
0cb549d5-acb4-48a1-b973-f83a339e6d26	03c117ec-5a52-40c6-907f-ece60dddfe68	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	59.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 70سم (انس)	\N	2026-01-30 14:50:42.384657+00
cf42f76a-c0d4-41d6-9eb6-a8d75910eb7e	2e2fe069-9320-4585-b0eb-b079dcf40692	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 90سم (انس)	\N	2026-01-30 14:50:58.704623+00
33c37198-ba7d-4bd6-b36b-8db01123939a	a1651be8-8cf4-4662-b40f-2173c9bef33d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	46.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 80سم (انس)	\N	2026-01-30 14:51:11.568774+00
de5fee4c-0983-452f-89ee-68b8dce03691	5f551abc-5798-4f04-8557-01afc73bb977	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	35.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة شجرة 90سم (الكوك)	\N	2026-01-30 14:51:26.448063+00
3363b36b-cf85-4d5c-a0c3-29e598b8b9d3	6e4b57c6-a303-4249-9f3c-7075f1a14bce	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	84.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة شجرة 80سم (الكوك)	\N	2026-01-30 14:51:40.22396+00
08709168-308e-4706-9521-c8af7a572854	a3b2e66c-e781-4009-a566-0a5285a513ef	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	60.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 70سم (الكوك)	\N	2026-01-30 14:52:05.521177+00
1c3be1b1-01cf-47a7-9c91-1eeebb6891c1	5660d767-7d28-4b31-a146-9c7071134ce8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	231.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة شجرة 50سم (يوسف والكوك)	\N	2026-01-30 14:52:33.084658+00
345398a6-390d-4a25-8744-b7a4b27f9694	04e83173-2a26-4e61-b3be-456de3b641f9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	148.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 60سم (انس)	\N	2026-01-30 14:53:05.184302+00
275a1894-4fc0-4d6b-bfb8-1b116fed760c	858d8c6c-94bc-4b7b-9bf6-f5aaf4cc7aca	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	328.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 50سم (انس)	\N	2026-01-30 14:53:31.375983+00
f3a9f274-af66-4894-b2e1-4adb46720e92	311f37ca-8c7f-4b3c-a32a-4bd675dd929b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	165.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة شجرة 40سم (الكوك)	\N	2026-01-30 14:53:56.656353+00
67f825cf-1df5-4508-98d1-214d0916a943	99d7b5a5-446f-44a9-82fc-17d6745c25f6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	133.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة شجرة 3/8 (عمر وميدو)	\N	2026-01-30 14:55:14.544742+00
ea72f318-fdf2-4240-b03e-0c55efde6032	3e463d34-e6d9-43cb-b0c8-a6c76be8290a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	39.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 3/8 * 3/8 (عمر وميدو)	\N	2026-01-30 14:55:43.701823+00
6a1bb9ed-9ec0-4d1f-85df-d47e7edc3fe4	4f371ebc-a80b-413d-8224-7c7458e3fc6a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 10سم (الكوك)	\N	2026-01-30 14:56:22.223581+00
11213892-bd8f-4313-8089-5cf7aaa1d1c9	a470a716-8bc7-4c3b-a4d2-ada3f0dafdd9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 3/8 * 3/8 محملة (عمر)	\N	2026-01-30 14:56:46.094901+00
ea7d265b-21f7-4291-8b60-b2c1303b8729	d4f387cf-2b6a-4ca0-ba1c-099b594a5949	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 40سم (انس)	\N	2026-01-30 14:57:01.999862+00
3dcbec9e-91f4-470a-a9f8-d50e57278a9f	357dad92-ae44-40df-98d6-135586d4f7c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 30سم (انس)	\N	2026-01-30 14:57:11.11977+00
a9be25cd-bbe9-4998-91d0-1af9a69206d9	d159b603-06ca-4d80-b251-120ca04bd0ee	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 20سم (انس)	\N	2026-01-30 14:57:23.792768+00
acf9a78f-ed37-4bc2-aa8c-a1fe99ec14d5	aabb6a08-a5c6-4a2c-b7dd-66ec1e019393	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سماعة ايطالي متر ونص	\N	2026-02-10 13:28:55.910952+00
17b6616d-78ab-4380-9906-e6dbb41c6eb8	a21a8080-f94d-4927-bf0b-2390e2500059	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	112.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | صامولة زنق نحاس 3/4	\N	2026-02-01 16:54:36.9018+00
3c7f37ff-3dc3-4c96-b267-c13c342d721e	a7861f0d-2057-4965-97f3-26b745cbbc8b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | صامولة زنق نحاس 1بوصه	\N	2026-02-01 16:55:54.273374+00
3a5934e8-6ab3-447c-8f38-fc921826a089	7e3e1e0b-859d-4b02-abd3-95199402ec4c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	77.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ثمن لزق 900 بارد (الكوك)	\N	2026-02-20 16:41:50.943661+00
017b22a7-716c-4193-b779-6906691e1902	eef8c1af-7cf9-4222-8baa-43bf0094c923	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	108.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ثمن لزق 914 حار (الكوك)	\N	2026-02-20 16:41:50.943661+00
cf1b7ed8-f9a8-4f52-8743-e69bd26c4917	dbdb45fe-083e-42bb-b3c8-df69ec408f8d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	61.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ربع لزق 900 بارد (الكوك)	\N	2026-02-20 16:41:50.943661+00
f6d33443-4cf3-4c4a-9c2b-f8c480589f0a	8edab49c-8f12-47b1-963d-8adea2c8ce02	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	38.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ربع لزق 914 حار (عمار)	\N	2026-02-20 16:41:50.943661+00
2b8e4647-d3e1-488d-b009-e699a8504aa3	13d75310-8904-479f-9803-f13687b3bb57	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نص لزق 914 حار (ادهم)	\N	2026-01-18 19:00:25.803028+00
b9f628c1-6411-405d-8a9c-f89a083b53fe	cd65e985-404b-46db-819e-af8c5163937a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	111.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لزق مواسير عريض كبير (ادهم)	\N	2026-01-18 19:01:31.323747+00
8e826091-b35c-49ea-a8fc-010b0e3b9284	09ac1895-0aa4-46d7-bf13-4f5d0a4d5c60	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	102.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لزق مواسير عريض صغير (ادهم)	\N	2026-01-18 19:01:59.450741+00
cdb06b3e-64bd-476c-bfcb-9754be687c6d	0f662576-a144-4692-ad0b-937314746bdc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نص لزق 900 بارد (ادهم)	\N	2026-01-18 19:56:00.681382+00
355dcc00-8fa8-499b-893f-597c697568a8	14089411-b7a2-4a4e-b9d0-f4efb8cc75c0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	43.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ربع لحام رمادي 917 (احمد حماية الله)	\N	2026-01-18 19:56:53.225459+00
e1de3e06-42c1-47e8-9c59-304908cfe4ad	27f3d0ff-1203-4b97-81e8-3be4720852e2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سليكون عضم ابيض (عمر)	\N	2026-01-18 20:54:13.696396+00
033447f0-76bc-4e91-95c0-40a09f4bed5c	2063f0a4-2037-4436-937e-bb771626b4d0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيليكون عضم رمادي (عمر)	\N	2026-01-18 20:54:21.896209+00
566bb634-ccf9-4b46-86e5-5f9ee3c698e9	a57e4eab-cbcf-4bf5-b649-33206c8e5efd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	63.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ثمن لزق رمادي 917 (عمر)	\N	2026-01-18 21:04:34.039761+00
2b84fcca-e94d-49d9-984b-63745479d5dd	8d3a98f2-685a-417d-9600-8d0b51d74d97	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لزق اوزو حار (عمار)	\N	2026-01-19 20:27:41.543325+00
5de082bd-5ccf-4950-b124-b9d1233a1c67	a4997b77-66bf-4b4f-ae74-74762dd0712c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بكرة تفلون صغيرة (احمد حماية الله)	\N	2026-01-18 18:53:32.586762+00
8b7fd899-f488-45b9-ac67-e895adbdba6e	5f8e2238-5325-4ff2-b77e-05d6398eb000	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	126.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بكرة تفلون وسط (عمر)	\N	2026-01-18 20:00:20.898163+00
5a95a97d-2100-4167-87b2-358f8d2b1163	8b6e0771-fc64-4898-9a82-e408dec91136	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	89.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بكرة تفلون بوش (عمر)	\N	2026-01-18 20:00:29.83319+00
8a9fc9a4-240f-43e4-a37d-45baac49efbd	2f3e5183-d945-419c-aba7-63cde2d18b66	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيليكون عادي (عمر)	\N	2026-01-18 20:09:36.338117+00
a86f6a33-83df-4185-a1df-2a41117164df	c00d945c-163e-4291-9788-c7c48cde10b6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شكرتون كهرباء عادي	\N	2026-01-27 16:37:07.609221+00
9fec0008-871c-46c2-8e1e-1ee0d4783777	e738439d-440a-4f78-9dc6-83fe84f8670d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 20*20 محمل عادة فايف ستار (الكوك)	\N	2026-02-20 16:41:50.943661+00
df1e6a0f-88d2-49b8-bb20-63b3cf85674d	767f8dde-1ac2-4a50-8afb-982ff0b34fa9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15*15 محمل عادة فايف ستار (الكوك)	\N	2026-02-20 16:41:50.943661+00
25ed48db-20b6-4000-a4ad-ca4d7022375b	0aa136ff-9388-4688-bbb1-a3a344d9cde5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 10*10 محمل عادة فايف ستار (الكوك)	\N	2026-02-20 16:41:50.943661+00
233ba60f-9353-4eab-8ff5-9874d05c34b3	38f70be7-6eda-4e3f-8f5d-cc664f4588e2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 نيو سيجما (يوسف)	\N	2026-01-29 12:16:45.388774+00
6f9fcf91-59a5-4c02-b923-a917d550f504	bf14d1ca-8f4d-4a9f-a8ff-435203615af8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 لافنا (يوسف)	\N	2026-01-29 12:23:38.052074+00
9e4a46f9-e5c2-407e-9dc3-b0d5779d5a62	ff494980-4c73-4a61-81a8-2cdb3ad57c2c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 ساليمكو (يوسف)	\N	2026-01-29 12:23:45.548065+00
39365aea-f8c7-4f1c-b8b3-c890a55b52fa	0d793ff6-689e-42c9-b1c5-3d1518459fb4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 اللؤلؤ (يوسف)	\N	2026-01-29 12:23:51.300812+00
45c97249-0421-4d78-966e-1d2ca29695cf	8c31b689-b723-4b4f-b7a5-3657a4733077	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 السهم الذهبي (يوسف)	\N	2026-01-29 12:23:58.045634+00
c4742f9c-dd90-4719-845c-d9c1370c8720	8c5b88b7-459f-4831-b67c-61bfc16c6496	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 سبانش (يوسف)	\N	2026-01-29 12:24:03.581273+00
ad8a41f8-eedc-4f18-b6aa-285bd9bbb6db	d32342b1-8699-4cab-a46d-c599555abf3c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 لازا (يوسف)	\N	2026-01-29 12:24:11.413259+00
6c0e9520-4c3e-47e6-8201-84357eddb06e	c3a1165c-ac37-4772-b198-5e973ff7ca06	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 ريباني (يوسف)	\N	2026-01-29 12:24:22.97243+00
1655715b-85ea-446a-b9e7-c170be72c72e	6cf339ab-5c51-4d0c-a096-98aa08096dbb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 20 * 20 ساليمكو (يوسف)	\N	2026-01-29 12:24:30.876672+00
b2d3190a-52e1-4e34-9d00-22443973e9f4	dfd4135f-7efa-4f2e-96b3-02e44342a7ab	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 تاتش لومي (يوسف)	\N	2026-01-29 12:24:45.34786+00
9b3a00e4-7b4c-41b1-80af-b24c6e9c93de	26592f03-3ad9-436b-8eb1-c97d23551fb2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 20 * 20 الصقر (يوسف)	\N	2026-01-29 12:24:59.836683+00
18ee5f4d-b413-4df5-a7ef-3e3adbe7b458	fffc498b-ab89-446f-bf7e-43ad31c86527	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	35.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 20*20 تاتش لومي (يوسف)	\N	2026-01-29 12:26:11.412927+00
677f25c0-4766-4d0c-a199-6141dbdeffdb	b9b32325-fda4-46a7-b4f4-6da187863e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	40.00	50.00	24d4ae60-0bf1-4056-a83c-a5faa958d10b	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 16:56:28.947849+00
6ac50c2b-34a6-4a36-8603-96146da42312	e204e8a5-b604-4547-9484-1f498d6dc46d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 20 * 20 تاتش AM (يوسف)	\N	2026-01-29 12:26:20.132173+00
a6c3a55d-c273-4f99-95ce-c25e74f1db8e	0d6d6f68-4a79-41fb-9c7c-2d8274a55354	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 20 * 20 تاتش MK (يوسف)	\N	2026-01-29 12:26:30.691931+00
52210bd7-52b1-4f09-bb05-88f47aa56216	b6fb8546-4a43-4944-a315-be3ee1ea1fcb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 ريبلان	\N	2026-01-29 12:34:22.867705+00
00c70fdf-472a-4011-b8ca-2293ed32fe9e	aed26ebb-13d6-470e-b3be-18c28441b516	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 نوفا تركي	\N	2026-01-29 12:34:22.867705+00
cd8bdab5-82bc-4173-b777-20f7e8372e61	d7760ccb-4830-42c2-942f-517aed6b57ab	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 فرداني عادي	\N	2026-01-29 12:34:22.867705+00
74b4d2fb-a6cc-4932-ba30-35dbfb4ea75b	c3238e7f-7d91-40b4-8df2-6cd9161fc09a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة محمل 20 * 20 المنبع	\N	2026-01-29 12:35:07.052653+00
f895a6a1-0e54-46c5-a40f-4502af32623d	ca20b458-786d-4bed-b94a-a91b10a6c621	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	53.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة بلاستيك 20 * 20 ساليمكو	\N	2026-01-29 12:35:07.052653+00
b822c799-0fa8-4f6d-9926-43f6ee9d509f	988e63a2-5543-487a-9f20-e8caf9133c05	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة بلاستيك 20 * 20 كيلوباترا	\N	2026-01-29 12:35:07.052653+00
8ebf6ad3-c994-45b2-b658-1577c42d1c78	3614e70f-96f3-4b69-9104-188a0574085d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	43.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 15 * 15 فولكانو	\N	2026-01-29 12:35:07.052653+00
4acc090e-ea0b-4f4d-9015-4f47af3d5d06	c952ae33-8b9e-4eb8-b67f-56fb587e7314	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة 20 * 20 عادي PFS	\N	2026-01-29 12:35:07.052653+00
16e2e9a6-8909-4538-b3c4-199326c760fb	01060665-4be6-4d76-b3cc-374e0d2e1d4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة نيو سيجما تاتش 15 * 15	\N	2026-01-29 12:35:44.97126+00
8ba11db3-5b36-44df-9e01-73cad5956bf2	9cba759f-0edf-4d87-aa6b-d7fb7c7ced9e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة تاتش سوبر ستار 15 * 15	\N	2026-01-29 12:35:44.97126+00
d51f2a89-d001-4647-becf-930011802f7b	c14b87a0-3545-4545-8c7f-f00de35c208f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة ماتدور 15 * 15	\N	2026-01-29 12:35:44.97126+00
30a8eb84-d596-4092-b598-79a714c47d65	39f5ed3b-7c34-4b75-9331-32a95c7d8b81	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة تاتتش 15 * 15 النورس	\N	2026-01-29 12:35:44.97126+00
068243a5-1192-4809-b011-e36c31a4bcee	adc37b18-86dc-4fbb-bea1-856a682a5095	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | غطا بلاعة تاتش 20 * 20  pvs	\N	2026-01-29 12:35:44.97126+00
a2a2b0a9-9ce8-4b53-afed-5c3b046ce3ad	f0c427f2-000f-4197-b044-9cb16ef86801	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	108.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 1/2 محمل (يوسف)	\N	2026-01-22 18:37:22.332383+00
ca00635a-12a5-4a6c-80fd-702de1e6caa3	35ad6cc3-4464-483f-9c63-7426eeee828a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	374.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز نص خفيف 1/2 (يوسف)	\N	2026-01-22 18:38:06.827415+00
da7c3ba3-c5f6-4b2b-97ac-3843196c693e	0bc85e43-0849-4d93-a656-73ffe8cb39eb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	270.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 3/4 (يوسف)	\N	2026-01-22 18:38:34.843504+00
5a44b796-2c51-452d-8bfe-2b643d60b106	3afc718e-22cb-40f5-85b6-f36a9aefa8b5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	268.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 2" خفيف (عمار)	\N	2026-01-25 10:42:24.569801+00
85787933-08e3-4a06-b72d-6761cd3cdb99	e2a0d6b0-083c-4d18-a788-795dbc4bf1df	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	192.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 2" محمل (عمار)	\N	2026-01-25 10:42:58.654475+00
19a5b261-8712-42df-8913-5999af15f50c	ec85f3a5-9492-404a-bb1e-ad401f624d53	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	78.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 3" محمل (عمار)	\N	2026-01-25 10:43:40.257346+00
5e0845aa-b326-41ed-9ed4-c93d0cc7b3bb	80f8c742-7ee3-47cb-96cf-7fd5819cc7c1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	93.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 3" خفيف (عمار)	\N	2026-01-25 10:44:16.853683+00
c0e2059b-6f19-437f-b3bf-eaaa2432f35f	760b0215-4244-4bdb-8309-21894890e616	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	46.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 4" محمل (عمار)	\N	2026-01-25 10:45:46.415871+00
b1e5762e-e840-44eb-bd2f-b3f878301cb6	4dd2c933-9bb8-4496-8f14-e5cf55e14a62	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 4" خفيف (عمار)	\N	2026-01-25 10:46:17.954431+00
564ef7a4-741e-4d3f-8019-64d3a1c6c7a0	df95ab62-3460-4fd8-97b3-d041e121aa96	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 6" (عمار)	\N	2026-01-25 10:47:31.376609+00
224315c7-3353-4b1f-bc08-f951b573c93c	7b92bee1-e9df-4679-8856-f13f1491aa2d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	56.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 1 و1/2" شعبي (عمار)	\N	2026-01-25 10:48:35.136908+00
0949abcd-1f06-43fe-ab68-5a4207bc5f58	ebb8fe3a-e453-4bf8-b931-c01008a6a192	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	196.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 1 و1/2" محمل (عمار)	\N	2026-01-25 10:49:04.319186+00
886f5456-6738-42e0-bf03-e99f46061e96	c7c52aa2-562e-477a-a972-d04f35efcb87	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	167.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز بجوان 3/4" (عمار)	\N	2026-01-25 10:49:35.689487+00
5c10d04b-e49d-4cf5-b373-ccead58c87b4	4defd0e4-66bd-483d-95d2-805d2132cacf	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 1" (عمار)	\N	2026-01-25 13:07:27.808173+00
7a848eaa-4320-428a-af86-9b9a99e4d95b	0f4beb3a-88e1-4869-9add-eca39c3a738a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | افيز 2 و1/2" (عمار)	\N	2026-01-27 10:12:35.204666+00
2b6c055a-9450-4dae-8a8b-a56e8edc71b0	49f4d737-1d66-4bbf-8011-44949b013133	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه سوسته ايطالى (يوسف)	\N	2026-02-01 16:33:58.596563+00
4cb860b4-c6fb-45ac-b477-c60f05b0f191	43262301-8bc0-4e5e-98f8-df79b0032751	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | منيجا عدله (يوسف)	\N	2026-02-02 18:28:53.021728+00
49f1f7f9-5441-4b7e-accf-48340cff4023	9c6b491e-0f64-46ba-983d-e9512587b4c1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | منيجا موجه (يوسف)	\N	2026-02-02 18:29:54.169036+00
9513722c-1080-4dfd-83c9-7b7f0a2730e7	cb153139-9139-4c4b-b341-9cabab43c132	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	92.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفيه أسانسير كعب بلاستيك تربو طاتش(يوسف)	\N	2026-02-01 15:49:11.82749+00
0c91d64d-56c5-4d08-b48e-dd8b74ab06ec	d5442bca-dd7e-4793-aded-ef8d13f3d2b9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	42.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفيه أسانسير كعب نحاس نيوجولد(عمار)	\N	2026-02-01 16:01:15.78419+00
28b09370-db0d-4970-8b6a-15f7be072cad	329b40d0-86df-4887-b985-ea2bc7990b83	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفيه أسانسير كعب بلاستيك نيوجولد (عمار)	\N	2026-02-01 16:04:07.2767+00
77fd271a-fce6-4ef3-98df-0369136cc44b	5bb79780-a8aa-4007-b778-5ad0dbb78e6e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | عوامه جمب السكرى(يوسف)	\N	2026-02-01 16:18:09.42226+00
e0479444-a864-43a9-9a9b-1de4dfd119a5	21587981-5f52-41a0-8aad-f7a573837b0a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	86.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شداد طويل (يوسف)	\N	2026-02-02 18:22:52.679189+00
26a9a583-efd5-446b-8aa3-8dab2c28689c	93f907c6-3b84-4d95-b1a5-b57483e81451	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماكينه ضغط كيس(يوسف)	\N	2026-02-01 16:09:18.786823+00
a3183bd9-a5b7-4cd5-a3a6-048a3178a74b	4ebdc6b6-72e6-43cd-83eb-389d25b5c5ec	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	160.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة وراق بلاستيك (عمار)	\N	2026-01-25 12:02:39.378525+00
96eb1fd9-bcd7-40db-bf65-f3d193117829	67f5d187-e095-4c7d-b864-5789fc3290ec	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	45.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة وراق استانلس (عمار)	\N	2026-01-25 12:03:00.927509+00
4ff675fb-5476-4006-8582-6a16b074d0b8	de12a113-2bee-459d-a18b-971c54badbeb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | وراقة مناديل ايفون	\N	2026-01-29 12:55:07.811048+00
465a7456-cb88-4ea5-b390-dde840e914c3	883f0d1e-6801-402e-9168-1e7f3435d336	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | اوكرة جنب استانلس	\N	2026-01-29 12:56:03.427526+00
5a22a3d4-8f98-4474-b3c2-759bee33d9c4	5d2c6496-0b93-4d27-8f33-ab6c72e3ab08	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	130.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار صبانات (عمر واللو)	\N	2026-01-30 14:58:59.760059+00
2ab3d563-1b9a-402c-bb77-6dd2290d598d	728d6023-951b-4a19-8cfb-d62631ab5736	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	166.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار قعدة (عمر واللو)	\N	2026-01-30 14:59:24.143925+00
23c31b1b-aa36-43b1-ac9a-5ae8d6c7d4d9	23856709-a9eb-49e8-a93d-8d659ff16a26	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	188.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار سخان (عمر واللو)	\N	2026-01-30 14:59:38.943772+00
c3b03455-e600-4252-bc65-ad9fbf5bddc2	71cc6095-c87f-4909-b84c-f89eb5660fa7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	249.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار حوض (عمر وميدو)	\N	2026-01-30 15:00:01.823495+00
af940a48-b90b-4aee-99ea-83398bbcfc63	c44ffb44-d7cc-4ab0-b7c7-6b0c073b059e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	84.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نوزل شطاف بالخرطوم كامل (أنس)	\N	2026-02-01 16:30:58.500228+00
0daf3883-2844-446d-a569-d28a014e105b	94c0f2c9-04d7-467c-ae8a-eb553591eac7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	53.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة حوض ستار	\N	2026-02-10 12:52:11.951551+00
47290753-aee2-4607-a4cd-15c6c3d833bc	013dc815-ab1d-46f5-b3ce-3c09ec80c29b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار سديلي  L معدن (الكوك)	\N	2026-02-20 16:41:50.944655+00
3cbde7ce-0f0a-4d0d-9f85-d2ac4f175e18	2de745f3-490c-458f-8d80-f8ef4fe03cb9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	31.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار سديلي جرار (أنس)	\N	2026-01-18 19:03:17.755964+00
a3619220-d2d4-44a7-8277-f07656202a00	2e415055-50d3-403c-b6b6-132cc06cac09	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	42.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار سديلي L بلاستيك (أنس)	\N	2026-01-22 17:14:10.101598+00
5903f066-0f73-4788-be7a-973b919f7997	bffd258f-b84e-4beb-8d18-ae23f611015d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شمعة مرحلة 2 (الكوك)	\N	2026-01-22 12:09:17.936616+00
2f501885-63be-4820-b232-eaab5fb195a3	d2879635-0b3c-4c36-8199-9f2b94a535ab	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شمعة مرحلة 1 (الكوك)	\N	2026-01-22 14:31:36.798765+00
3f09f189-bd46-4d57-b5fa-737bd49ec27f	fb3622ca-2180-4ed7-811e-479b4d54f849	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شمعة مرحلة 4 (الكوك)	\N	2026-01-22 14:32:55.085674+00
f3835210-02a6-4b5d-a4e9-ee54b89170d6	9c1e6d13-9d15-46d1-9779-623dbc89684f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شمعة مرحلة 3 (الكوك)	\N	2026-01-22 14:33:45.821867+00
26da71f5-5963-4410-b3e2-9632368db5ed	4afdd266-b0cd-49ab-aa95-b46ea2fdc5a5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية فلتر اوكر	\N	2026-01-29 12:50:13.899449+00
f54cb6b2-70ab-4523-99b8-9ee1cd7f8c95	a4bc8fa2-5b9b-4d21-8b22-788662938fcd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية فلتر محمل	\N	2026-01-29 12:50:13.899449+00
53f2a638-d411-4788-8cb6-7578d446d67a	59b1408c-5d92-4b6b-b109-28c7a39f41fd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة فيلتر	\N	2026-01-29 12:54:27.585787+00
bc47354f-e440-44d1-b8ef-d3b16c0b3e05	0ba7d154-06d4-4148-bf47-71dbe931348a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	44.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | وصله سريعه	\N	2026-02-01 16:59:52.874967+00
b7e9c8da-9c1f-4518-b306-0e14a8e1372d	53baae4e-9523-419b-b62f-ef1b43737105	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	61.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نطرة فلتر 3/4	\N	2026-02-01 17:01:37.122142+00
dce25980-7f40-4c3a-ac41-3b6a8a65bfe8	ed6fb4fe-6aa7-4a8f-8856-bbdd3b7b7625	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محول فلتر	\N	2026-02-01 17:02:20.851609+00
51464290-0145-4ca1-94f9-9a597bc9bf15	5167fb35-085a-42cc-82ea-73e3684bea9a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	121.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية كولمان	\N	2026-02-01 17:05:12.898574+00
3e6ffc85-f751-4125-8dd2-957fce70871f	e5e9bcf1-22ad-40e2-a443-9b4acdbbe426	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	35.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حامل حنفية فلتر	\N	2026-02-01 17:13:30.784739+00
9f66b08d-dc95-4836-9aea-d5b94bf12916	577cd1d9-5876-4b11-be1c-cd338c878aa2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	53.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس فلتر استالس	\N	2026-02-01 17:36:27.970155+00
56e8609b-60fb-43a9-a97b-a3f042f94aa6	39e8ca5e-8abc-4918-8e32-052d5862db47	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف شيلد نحاس 3/4 بوصة	\N	2026-01-20 13:47:42.676159+00
7203b332-c4cd-4ecd-9ff5-5eab4974f69a	b5459d2a-95fc-418b-99f9-f21a8406b6f1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	302.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف بولي 1/2 بوصة (عمر)	\N	2026-01-20 14:12:16.803625+00
fa51b821-3a8a-48db-b442-b2e2d0603100	79880071-7ae2-49d2-bda2-46c567d90c8e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	190.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف بولي 3/4 (عمر)	\N	2026-01-20 14:12:47.458892+00
39bdbdc0-5af1-4fbe-b23d-5d6dc968961f	ae608ba9-9030-4a2d-89d6-fa70769c09a7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف بولي 1 بوصة (عمر)	\N	2026-01-20 14:13:36.339435+00
bacf8eaa-55a3-4085-af34-490b9758c3e4	c2b0f8d3-5a8b-4744-8cb6-c51fc74a019f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف بولي 2 بوصة (عمر)	\N	2026-01-20 14:13:44.386965+00
8cf99024-0776-4332-9af1-23a4180ba2e1	f3f5bc34-6e8a-4fce-aaff-440ca5fd8a9a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	77.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف سخان (عمار)	\N	2026-01-20 14:16:14.851146+00
bfc8453b-1e90-42fa-8a8c-d95083055888	8860ce8d-06ec-41f7-9fa2-87e2979c660c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف لاكور 1 بوصة (عمار)	\N	2026-01-20 14:17:17.027115+00
d5bb769e-dcb9-4242-8446-70644d0d9911	d1cc6cac-ad63-4fda-93d9-913571e3fe9e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف بولي 1 و 1/2 بوصة (عمار)	\N	2026-01-20 15:33:10.336915+00
b81b830c-5706-463d-ba71-a964ba6d3175	7f5190eb-4444-470d-87ec-f037f1b4d36a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف نحاس بوابة 1 بوصة (عمار)	\N	2026-01-20 15:55:29.280372+00
ed85a976-0c91-44e2-bd0a-b07ee9c0f6aa	3a1f1896-d864-4700-a1df-a92942f60e58	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	89.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف نحاس بسوستة 1 بوصة (عمار)	\N	2026-01-20 15:56:10.576738+00
4eb6f90e-4bf3-4699-a9e8-eb7f5dfb9ed6	5a69e732-8a23-459e-8321-aaabf2d24e8e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	32.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف نحاس بسوستة 3/4 بوصة (عمار)	\N	2026-01-20 15:56:57.601327+00
cd145622-5863-48ec-9691-e0361c928424	d2fd8ca2-1dba-4cf1-81fb-82dc5a323a7f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	70.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف نحاس بسوستة 1/2 بوصة (عمار)	\N	2026-01-20 15:57:58.480216+00
94210deb-0e46-412e-a71e-e6cdec76d377	5dc65401-81f9-49c1-8995-94b48888200f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	88.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف نحاس بسوستة 1"	\N	2026-01-20 17:52:25.757162+00
8189639f-5fea-4b32-aca8-e4b8350b13bb	966eee6d-776d-4e2c-a7a1-2e93df03e90d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	49.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف لاكور 3/4	\N	2026-01-21 09:34:25.206656+00
6774db10-f17b-468e-8a82-a45f58f15fe5	95e488af-8082-4dac-903d-ae4ea9039e8e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف نحاس محمل بسوستة 1/2 بوصة (عمار)	\N	2026-01-22 11:15:53.456983+00
419b3344-edf4-4f5f-823e-72c4c184265f	77d16d51-67f9-479c-aa04-d7e44d41976d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف نحاس بسوستة محمل نص بوصة (عمار)	\N	2026-01-25 11:56:44.752842+00
038457bc-45a5-4a26-8bb3-5c4ec1ea4712	523adcc8-e4e9-4766-981b-e5165d723e43	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بسن داخلي 2"	\N	2026-01-31 14:14:24.637282+00
55506f82-6bb4-4955-8817-c84ad911e885	0a5287eb-3d47-4451-ac01-b6d97287ada1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بسن داخلي 1" و1/2	\N	2026-01-31 14:14:24.637282+00
4eb60cdf-beef-429b-9dbf-701903d35ac7	21720bca-49df-4dd9-84aa-4858271209cd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بسن خارجي 2" و1/2	\N	2026-01-31 14:14:24.637282+00
2f76f532-3a58-406a-a12b-9b120eb8a82c	b9b32325-fda4-46a7-b4f4-6da187863e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	5.000	40.00	50.00	75e919da-7d78-4dbe-ac0b-3ca8abb7407f	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:18:47.390297+00
dcd01a42-9462-4fe9-818a-fe2834191f0d	177bed74-3f94-4fed-93a0-e23cb13847f4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	91.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بسن خارجي 1" * 3/4	\N	2026-01-31 14:14:24.637282+00
90c494b4-854c-4a70-a8c7-595388db4d31	44357f2a-f7f8-441c-bdd8-f9f1af4487a8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بسن خارجي محمل 1 و1/2	\N	2026-01-31 14:14:24.637282+00
739d7422-8877-4580-ac8b-f13307f75a6a	8a00f949-0c0c-4c21-8d44-c6ffaae33aa9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	82.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بسن داخلي 1"	\N	2026-01-31 14:14:24.637282+00
11f87927-cb5c-416d-aaba-bfdf3e5cf339	fe3b4b4b-f997-4e20-8a71-11df8a4c2e63	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	82.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور 3/4  سن خارجي	\N	2026-01-31 14:14:24.637282+00
32f59479-f38e-4a5a-8b49-8261a92af752	b1bd2473-dbe5-409d-999a-342ece893357	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	158.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور 3/4 سن داخلي	\N	2026-01-31 14:14:24.637282+00
bd00462a-d24a-4559-ba48-f8b3493aa04e	0f4ae4a8-89db-4d5d-85d5-704f681f9764	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	47.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور 1/2 بسن خارجي	\N	2026-01-31 14:14:24.637282+00
a81b327c-19b6-43e1-bd40-4cd3772dda76	c1895f9b-5d9b-4507-9ac8-be10dd5c08d0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	232.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | لاكور بسن داخلي 1/2"	\N	2026-01-31 14:14:24.637282+00
aaf55798-1f3a-4933-8ead-bc5f5a5f1e7e	7c033855-5e8a-44e7-a03a-c91729b55080	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	151.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع عاده 1"	\N	2026-02-08 14:06:54.889056+00
464cd9e6-4085-483d-9dc6-8bdcc2eba940	fb232540-a7f2-4037-b600-1ee220be7b4d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة 1"	\N	2026-02-08 14:11:35.389255+00
08cdb0ea-a045-45a2-b269-ea85f0a16222	1dc0dbc5-8c7d-45d7-b240-e343b6bc50fa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	99.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 1"	\N	2026-02-08 14:11:59.999094+00
05bef9e1-1b89-4f59-9c4f-5724277328ec	b277559f-9416-4077-b01d-108ca5d2ad84	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	75.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | واي 1"	\N	2026-02-08 14:24:30.685307+00
2c4a6985-970c-4bd6-9986-236bf663e691	7c32ca44-d362-41fb-94c8-843a6c2b6eb1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	352.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 1"	\N	2026-02-08 14:34:10.669716+00
20a85616-5d75-4ef5-86ff-3945b70f0573	c45f5e63-c8f4-46b5-bd72-ba04bfad276e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	189.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة تسليك 1.5"	\N	2026-02-08 12:45:56.317097+00
fae054bb-095e-4075-a76d-f9a172722b5f	bb158824-4c3b-4a7e-b7ab-3f7478148361	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	135.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 1.5"	\N	2026-02-08 12:59:57.327557+00
76dcaa60-d78c-41a2-8aa1-33564e512915	60f411d9-101b-4fac-9476-9c3156ca32e5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	52.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 1.5"	\N	2026-02-08 13:02:31.006671+00
1f7f2a42-4ef6-4fb6-977b-1ff760bedf4d	8e2b3882-c6fc-42c0-85b9-1ce43ec06076	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 1.5	\N	2026-02-08 14:31:49.745179+00
7b393536-e59f-4557-9573-4ad8c98f8ea9	892d2704-38a2-4e62-a752-066a045fe36e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	76.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع سن داخلي 1.5	\N	2026-02-08 14:35:15.357294+00
b2ffcd6a-6fc5-4333-aee7-7529079f3c48	60569b7c-dcce-4e35-a474-19916aa35ca3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	166.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 1.5"	\N	2026-02-08 14:39:46.172566+00
4425ef1f-40b1-4893-95f4-a706d184fd1a	b667424e-e746-44bc-9c47-839e858bc00a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	40.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك باب 2"	\N	2026-02-08 12:46:09.557466+00
925847ae-8b2f-4cb0-80e0-cbe58b300efc	39742801-02c4-47fe-bdf9-55c330e781ca	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | واي 2"	\N	2026-02-08 12:46:26.81403+00
91a94585-db7f-4134-9390-05dd50ca34e5	e6fd727d-e3c4-4364-a327-d6718553c39b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	79.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 2"	\N	2026-02-08 12:46:39.949684+00
56977756-ed50-40e7-a8bf-94a3e361c136	0b66cdef-de0b-4e0d-a091-0c6478c6edd0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع باب 2"	\N	2026-02-08 13:23:02.439219+00
d9c6d88c-9d1c-403c-b5ea-a36290afb769	4856275a-91cb-4889-bc57-4e10e1b703c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	54.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | هواية 2"	\N	2026-02-08 14:23:50.82904+00
5cb23b1e-14ac-4cab-8ebf-c22851763692	888d9a19-395c-4cbe-b334-346cb8006b9a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	197.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 2"	\N	2026-02-08 14:36:26.909287+00
545b1608-e9c3-468f-a99c-b4515a671b69	77badf35-82f3-4f15-9645-864081747352	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	36.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قشرة 2"	\N	2026-02-08 14:43:30.573237+00
e425e4ab-c30d-4e3e-8162-1a1fd2bde432	fe50fee1-d638-4dbb-9e55-d8ee6d6716ec	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	167.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 2 * 1.5	\N	2026-02-08 12:51:54.81516+00
d5d5de36-45a8-4744-8f6a-9b1986e96197	e7eb5039-f585-4133-8a5c-30d2c64211d1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة تسليك 3"	\N	2026-02-08 12:55:40.174127+00
79665a2f-8d5e-4857-9c69-e6dc23f09808	e660c870-680d-4c0d-ac35-ad6c4e0740a6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 3"	\N	2026-02-08 12:59:14.46174+00
daab1953-8814-42ac-b093-0de8f9294c15	23644c4a-953b-46df-8f24-f28a6f04466e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | هواية 3"	\N	2026-02-08 14:23:13.549607+00
e206b2ee-435b-49fb-8e77-6a237b6e7c3c	8f92156d-4980-4897-a21d-6bb7a3001734	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جرجوري 3"	\N	2026-02-08 14:43:11.372835+00
85975790-88ad-43eb-b49c-15406c3ff600	8671c2bd-ccab-45f7-8ef1-6c75e1c56809	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	40.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 4"	\N	2026-02-08 12:58:43.480198+00
267c0e36-1c82-43a7-adb9-4737728abdf7	9a23640f-c9b3-4037-866f-df3e018fe0b6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة تسليك 4"	\N	2026-02-08 13:04:25.583595+00
6932324f-ac9b-4e96-b638-6c63fdc15fe1	182d1f97-9302-4f7b-9482-dbbd0206af9d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | هواية 4"	\N	2026-02-08 14:14:20.365837+00
409faab3-91ab-4fc4-b311-383c4f7d189c	8733206d-6230-4c5d-8b7d-eb3f9fd26123	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جرجوري 4"	\N	2026-02-08 14:41:12.668569+00
40fd96ae-7c47-4060-8094-1ec127df873b	ab4ea6d5-f256-48e0-ac8b-cfa800182482	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	158.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 1.5 * 3/4	\N	2026-02-08 13:13:45.774354+00
6a78eb10-5833-42a2-b3a3-9905f398f96d	53746d4e-4530-4d61-9b35-294b61f4618c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	382.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 1.5 * 1	\N	2026-02-08 13:21:56.575712+00
90e8739e-0d06-492a-ad85-e5cfec5c7908	57925e1a-2021-417f-8be6-34d1bdef1dfb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	170.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 2 * 1	\N	2026-02-08 13:24:04.046593+00
bdaf6538-1e26-4fd4-a90b-48042962d9c7	2f0bead1-730a-45f1-9ce9-71f11246b94f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بلاعة 2/3	\N	2026-02-08 13:31:44.286884+00
51f68770-a7c3-409a-8168-84695021683b	bb5f4a08-269d-41b4-993b-2ea33302507a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بلاعة 2/2	\N	2026-02-08 13:53:05.869834+00
61c3f676-e641-49ba-8437-1f511f46d00d	2de17cf9-3fe3-4533-a032-818ffdb0eea5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بلاعة 2/2 عالية	\N	2026-02-08 13:55:32.159269+00
446943b2-4f49-4041-b0bf-6c53148b93cd	9df6119f-d341-4c6d-a93e-674107276697	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	19.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بلاعة 2 * 1.5	\N	2026-02-08 14:01:15.933689+00
925fea65-7277-4681-b138-4e50821f4338	e3a7418f-9d48-48df-b265-6e20a4c0667a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بلاعة 2 * 1.5 عالية	\N	2026-02-08 14:01:55.965237+00
8be0f774-f6a2-4135-81fd-25fc86281e7c	40faef4c-37c9-4ecb-a603-b377687bed9c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	38.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بلاعة شاور 2"	\N	2026-02-08 14:02:36.061897+00
29c379c9-0f6a-4c29-ba3f-0917b81e7cd4	46653e57-d6d2-4fa1-9ea9-c4095da20503	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	731.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة 1/2 (يوسف)	\N	2026-01-22 11:22:34.239712+00
455e1bbe-fbcd-40ed-bcf2-0e7f72fc13e4	2efc200a-fa8f-4bc8-8b04-ddc3491110df	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	151.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 1/2 (يوسف)	\N	2026-01-22 11:23:13.728784+00
14bc08ac-531c-4b59-98c4-5a283d771aee	ea231ea8-7b79-4616-b5ff-7133ce3b9355	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن 1/2 (بلال)	\N	2026-01-22 11:24:56.592898+00
b8c4c260-02d9-4a04-8155-0d18e2387906	f9ab2612-e5b6-448b-b85b-a41883850361	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	290.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي بسن 1/2 (يوسف)	\N	2026-01-22 18:32:33.403478+00
7d636c5e-cdf5-43b5-aab4-0b8bdc6a7240	fbe38b09-fe9a-4053-9587-bbf370223390	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	708.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي نص بوصة (يوسف)	\N	2026-01-22 18:33:04.378991+00
f68188e9-586f-4bc7-a850-099228ef62ff	d144b604-d157-4c59-8006-25da0df08daf	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	888.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام نص بوصة (يوسف)	\N	2026-01-22 18:33:28.412125+00
5004d3ae-0336-43fe-bab1-81a4034008a3	5261d27a-2f3f-43db-97de-7d90d039facf	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	133.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كرنك 1/2" طويل (عمار)	\N	2026-01-25 10:37:33.986183+00
8f91463f-bf97-4758-9b89-a5f02c8d1623	f1ff0933-c92e-41d2-a794-809088048e47	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن داخلي 1/2" (عمار)	\N	2026-01-27 13:43:08.04037+00
5969a078-ea40-44e7-a24b-514320d12500	3fa1f00e-e4e3-4884-81b3-404b8de81e1b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	219.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع 3/4 (ادهم)	\N	2026-01-22 11:21:32.032575+00
0379d9ba-36cb-4146-9765-b0b442a0eff6	320e8a3d-d0df-4ac8-ba39-cc0fcd9e9b99	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	842.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة 3/4 (يوسف)	\N	2026-01-22 11:21:54.654868+00
edd35f56-397e-46ca-a01e-9d2fdf9b2ac7	e74dc2f7-3677-4e8c-912e-9ef271bbba67	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	382.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 3/4 (يوسف)	\N	2026-01-22 18:26:47.72345+00
957ee9cc-5bb8-4baf-94b8-efc0f7df573b	1a2576db-4e4b-4e7f-8c93-d601687d5cd3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كرنك 3/4" صغير (عمار)	\N	2026-01-25 10:38:47.313577+00
fb7e45e4-46ca-44fa-a693-7b1d0132f0a0	422b5b97-7734-4947-afd8-cd7171cdc1b3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كرنك 3/4" كبير (عمار)	\N	2026-01-25 10:39:07.953462+00
e8faf5db-3acd-45b8-a0cc-e6e2a3403fb2	a2afe05f-3beb-49bd-a5ba-36565fdd14cb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 3/4 (عمار)	\N	2026-01-27 14:37:19.811175+00
1f426e06-f606-4aa7-a6e3-cbb38c21f534	88fdb5d9-d19d-4087-aba0-19adfca71918	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	23.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 3/4 (عمار)	\N	2026-01-27 14:37:45.667488+00
d9080988-e0a8-43a0-a48c-1d165a29b2cd	f1e6d3ae-1a60-4187-af58-d0309ad4de89	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	571.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن خارجي 1/2*1/2 (يوسف)	\N	2026-01-22 11:23:52.353189+00
791b9bbb-0e3e-471b-86ec-07144bb10d84	d05db9fb-adba-4899-8736-7c7d1c8172e1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي سن داخلي 1/2 * 1/2	\N	2026-01-27 16:35:13.25749+00
2fdd054e-dd13-4547-81d7-5199846695f9	e124b922-be63-4889-9c39-d2c339ac546e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	23.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1/2 * 3/4 (عمار)	\N	2026-01-27 15:14:06.928674+00
a6d7d350-b63c-4be6-b54b-b77773ad5361	914922e9-da51-442c-9e3f-8839b9fa251f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	205.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن داخلي 3/4 * 3/4 (يوسف)	\N	2026-01-22 18:28:15.515477+00
041d19d0-d497-40d1-b7bf-2e41f3ad5204	f6de776c-d026-48e0-a682-85eebc4b4cbd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	97.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن داخلي 3/4 * 1/2 (يوسف)	\N	2026-01-22 18:27:26.332496+00
f4073fe2-b6fa-446f-8e98-7a0a429403d7	01466b3d-dd2f-47f7-991f-988d273d3a3b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 75 (3")	\N	2026-02-10 13:35:03.878094+00
759e6dd8-4d5a-401e-a17f-07269f8903de	b18c3367-ee65-4e16-8e4f-a1148284aaae	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 4"	\N	2026-02-10 13:36:40.870273+00
45fff5a4-8641-4f46-bbd2-719b389bcb70	e3171dc4-a972-40ef-8452-ade0250302fa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 2	\N	2026-02-10 13:37:28.557743+00
8870db54-76d4-43d6-a6d7-e63c06b896ec	4a86af6d-e32f-4b72-a561-f98020e19e26	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 1.5"	\N	2026-02-10 13:38:55.086831+00
140718a3-4f05-4641-a832-1999dd84d765	006eaf5f-789b-47a7-9106-944764fdc08b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 1"	\N	2026-02-10 13:39:16.678477+00
f8c4dec1-67f8-4c09-a2d4-58332d390955	74460fc9-5b94-427c-b129-876231ab5674	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قواطع ماسورة 75	\N	2026-02-10 13:40:19.983297+00
f6d906c8-7cbe-4423-b335-95949dc39802	ff0e6f72-8440-4a9c-9a71-470453065413	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قواطع ماسورة 2"	\N	2026-02-10 13:40:58.11851+00
07ecc12e-3d45-432d-b71d-5f02e21d8fca	54b51aca-a22a-4638-a14d-f4052eddb90a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	54.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1/2" (عمار)	\N	2026-01-26 20:30:04.076514+00
9d67cfac-f70d-40e8-91fa-64f39db0a920	d90ce028-6aeb-4cbe-916b-d5941eb564d3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1/2" (عمار)	\N	2026-01-26 20:31:02.904767+00
58452e5e-763a-4e32-96af-0ce8ff2a2c01	1d039edf-9ba6-45b7-ac98-cbf42cf7ef49	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1/2" (عمار)	\N	2026-01-26 20:32:42.822347+00
09cde2eb-c22f-4e29-ac0d-b9b2ad0da23f	efa431de-b26f-4add-b34c-b4bb0c6a1f3d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 1/2" (عمار)	\N	2026-01-26 20:34:09.788818+00
192c2ede-8599-4c79-b03e-ab208613bc86	ac0cbfea-84d2-4e19-9d5c-130b926174e9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس لاكور 1/2" (عمار)	\N	2026-01-26 20:36:07.194753+00
f0b81938-45d2-4c93-aa07-b252d35ca90e	3b4c474b-bcca-4785-8c8e-29b2b42e5a79	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كرنك 1/2" (عمار)	\N	2026-01-26 20:36:42.246455+00
ae931ebe-fde5-46dd-828f-4bebbc1e38cf	c43bc70d-9e2d-49b9-89df-7e8396361190	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	23.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كرنك طويل 1/2" (عمار)	\N	2026-01-26 20:40:30.035555+00
b5487be7-868a-42ab-abcd-6be6d52fed2f	a7c6cd69-4a08-4d2a-9ebf-817df83510f6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	105.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبه اختبار	\N	2026-01-26 21:22:29.439955+00
12759d92-2c41-4529-a504-fa9809791f96	f9f94c31-4ab6-4b16-860c-42b07f2fe7ac	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	61.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 3/4	\N	2026-01-26 21:15:16.749339+00
8ef0def3-a20b-4140-ba6f-63726ad79c91	bb6e8e5f-10ce-4074-a838-5afc4bfd8c9b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس دفن 3/4	\N	2026-01-26 21:15:45.928637+00
f2d3b14c-2fe8-4851-9055-00dfdf20846b	dc4dcdc4-6c4c-422a-b43a-64a95dd46387	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس لاكور 3/4	\N	2026-01-26 21:16:04.063738+00
5c630f39-fa4a-4aab-9d72-e1fc1692497a	43e5a9ca-78c2-4f05-affc-4c6e2491605a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	55.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 3/4	\N	2026-01-26 21:16:35.061885+00
94534e98-9722-4d25-be99-c70539b45d18	7568b958-f282-4aa1-85b5-24349625f9db	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	39.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 3/4	\N	2026-01-26 21:17:08.717317+00
cdb58593-51fd-45d9-bd80-a0b76144c57a	9cffbe6c-1071-48ce-8973-fcd035c61762	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبه كاب 3/4	\N	2026-01-26 21:19:54.664464+00
77f44baa-0783-42c9-98f6-54a426aa7d37	9cce9245-5bbe-42c5-b6b2-f4fc4e5ec8e3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كرنك 3/4	\N	2026-01-26 21:20:25.437116+00
5bd400c2-081a-4ffa-bc36-58a615605479	85a51c91-a72c-4762-91ee-38a342e74c48	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 3/4 مفتوح	\N	2026-01-31 14:28:28.462952+00
19267ace-21c4-47c1-a987-3061a7a52bf8	3a4c0ba0-e011-4496-b6b8-2cdc7dc89c88	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 3/4	\N	2026-01-31 14:33:59.537256+00
ecfd400a-d61d-4f92-acb6-2e23ebcbe32d	19ad03e8-e71e-4be7-90ef-08bd6572f06f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبه  1 بوصه	\N	2026-01-26 21:46:51.352013+00
d541bb37-586e-440b-80b6-e7952af31320	d2ffb803-9a86-4990-b834-9a3d7413444d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1 بوصه	\N	2026-01-26 21:50:05.188327+00
bc2ee8ba-f06d-4a8d-9ac0-616fc45c68c6	12d44342-c0ea-4093-8344-8a3fe616b946	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1 بوصة	\N	2026-01-26 21:50:32.28219+00
3f3f7101-ba42-4f20-b6e5-01666ef11e18	3b1471c3-f7f4-4a7d-a28d-06206542e170	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1 بوصه	\N	2026-01-26 21:50:57.378248+00
11a32e36-3ffe-4d9a-ba93-5d2f45127059	4fc7f1f8-8b6a-42fa-b439-eb37e404f119	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس لاكور 1"	\N	2026-01-28 10:10:59.544879+00
4e82ccaf-9fda-4963-a261-e4c263faf912	6a6a73a1-51e7-48ae-8455-0e176997bed6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف لاكور 1.5 بوصه	\N	2026-01-26 22:00:34.456897+00
54e949ff-bc0e-4397-910d-8ba9d6e02c1d	4d5e6616-df0c-41a0-a88c-bad074a514af	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة بسن خارجي 1.5	\N	2026-01-26 22:01:09.086358+00
ee626d7c-3f8b-4d88-9dbb-dd901743b7a4	868ab4a9-b2ef-435e-a292-fdbc7e3752d6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 3" (عمار)	\N	2026-01-26 20:41:47.014108+00
e5452257-334a-4085-b77b-be042bf3d45c	56ae25fe-9036-4f6d-a788-b665157a3301	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 3" (عمار)	\N	2026-01-26 20:43:20.189943+00
10b9b373-d36a-430e-a272-1dff522bf51f	5c2aab48-9df3-4dce-b31f-0ec0746050c0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 4" (عمار)	\N	2026-01-26 20:28:37.455045+00
441bdadb-2fa7-41e5-8c35-76d458ad0533	b3c35aa0-469b-4e4e-8560-1dec134adfbf	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	69.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن 1/2 * 1/2	\N	2026-01-26 21:03:06.498596+00
bd3f2636-4c2a-4b23-ac51-14823428a8bb	338cbd11-8f82-4e1f-851b-c36446f165a0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة بسن داخلي 1/2 * 1/2	\N	2026-01-26 21:04:39.88191+00
5652c630-b2d6-4a91-a62c-770e82f57465	45d11bd8-b3a6-42f3-8c0e-6db0e73093f0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة بسن خارجي 1/2 * 1/2	\N	2026-01-26 21:05:07.12304+00
cf4f97eb-5e62-4df0-9965-11c2d5877413	720df594-4b7f-46b4-b602-884e803ed8f9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	52.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي بسن 1/2 * 1/2	\N	2026-01-26 21:05:39.788358+00
4ece4895-ec7a-44d1-bb1a-1b3d378b41db	e6f44831-450b-4431-8b3b-898c83545db9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي محبس 1/2 * 3/4	\N	2026-01-26 21:23:09.209938+00
3e07e36c-a91a-4527-a35b-56d55e0d50af	d14d6889-b9b2-454e-a5eb-ac5744e8939b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة بسن خارجي 1/2 * 3/4	\N	2026-01-26 22:08:59.903959+00
f233edf2-329a-422a-b7c7-f888f4789cdc	6ae3a388-329b-4811-a338-c61a5d690642	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي محبس دفن 3/4 * 3/4	\N	2026-01-26 21:38:31.164992+00
997c46b7-ef61-44d4-9a1a-5bdeb5bf0a44	760b529d-dbde-4e70-919c-610ce46ee71a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة بسن خارجي 3/4 * 3/4	\N	2026-01-26 21:39:18.575886+00
1f5c6ac5-c0e6-4c52-8ccc-b4cb05fc1d2b	48662f9e-7606-4818-b2a8-375230a4923a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة بسن داخلي 3/4 * 3/4	\N	2026-01-26 21:39:48.229897+00
7821e5f3-d35f-4036-baa7-570b45a6381e	49e6c837-6ec8-4ff1-9b10-214b6df66b33	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 3/4 * 1/2 (عمار)	\N	2026-01-26 20:44:55.657012+00
b66f6535-4bc1-44d2-a9d4-05f84e56cec3	26a4f674-5c48-4ff6-8634-143def01cd85	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	80.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن 3/4 * 1/2 (عمار)	\N	2026-01-26 20:46:07.696375+00
2c70a21e-69a8-4255-b3f8-b8236a9d227d	c9835638-133e-40e3-86d5-76725f3b9751	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	35.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي بسن 3/4 * 1/2 (عمار)	\N	2026-01-26 20:46:48.177685+00
7fe0b4ea-4a42-4fbd-b765-7cbd563c5060	b771a653-3406-4c85-8d38-55002fcfc673	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 3/4 * 1/2 (عمار)	\N	2026-01-26 20:47:42.874794+00
c03d4194-a6ad-4e22-a213-1a017b9fe313	541617c9-27f4-4738-9d7f-dffd1fb8975e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 3/4 * 1/2	\N	2026-01-31 14:29:52.672492+00
da1e4685-9c40-4d70-857a-99d0f2bf4fc8	202995e6-bfba-49cd-9985-735486af9c35	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1" * 3/4" (عمار)	\N	2026-01-26 20:56:16.056423+00
f8b1071e-a7e8-47f7-a826-4637714c43c7	3a563ab6-c4d5-4458-bfca-5ac51e029c72	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1 * 3/4	\N	2026-01-26 21:08:49.904267+00
4d524449-de11-4cb3-977a-a38f9330d708	59c5ef97-35e2-45d5-bcbc-94c0a854195e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام  1* 1/2	\N	2026-01-26 21:07:34.70497+00
0d8fbf9f-c09f-4fa3-ac4d-f4dfc75e5250	2a583630-04db-4a74-927a-0f8ef4d83d03	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة 1.5 * 3/4	\N	2026-01-26 21:13:21.310816+00
4baae2e7-ecb4-4a35-abb4-95b5e3a962ff	7bbeec16-c5dd-434c-9415-643d647ed54c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1.5 * 1	\N	2026-01-26 21:14:47.991815+00
2c7d3835-a5a0-4313-b825-781ea1c61a53	afa1092c-9aba-4b1a-ac8e-8b91bb308469	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة بسن داخلي 1 * 1	\N	2026-01-26 21:58:53.401604+00
6c6237f2-5534-4d00-97f8-495bfbf6a940	198fe32c-37df-43bf-9d75-db5bf327abfb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة بسن خارجي 1 * 1	\N	2026-01-26 21:59:34.73245+00
5deb3d73-cb5e-4346-9aa5-8f6c59e709ee	4b615637-457b-4c61-b4c8-e69607aff352	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 1.5"	\N	2026-02-10 13:42:32.606727+00
97a5d217-1f96-47e8-ba1f-ceaca56710be	4a9db8a4-6cdf-4666-ae94-28002243bce6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 1"	\N	2026-02-10 13:43:36.471241+00
53956c2c-e813-4cc6-8bab-dd22899f06a8	d119f961-855e-4209-ae8f-00e30ed71e3c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 3/4"	\N	2026-02-10 13:44:16.949695+00
17dee81b-4162-42b3-a1c7-3f35f4c30f6a	3ba8e991-c7c9-4ee0-b3e8-265a9b8e13c4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	60.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماسورة 1/2"	\N	2026-02-10 13:45:01.933868+00
382cf1a4-9daa-4312-ad96-65a3c2b807d5	fc34d4b3-7215-42ae-9c64-eb7d8b003cda	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | عوامة خزان استانلس بوصة (الكوك)	\N	2026-02-20 16:41:50.944655+00
62f22907-bcc8-4057-8693-92e63db8952e	857d4856-aca0-4f69-89d8-59ed2d1b86d0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | عوامة خزان نحاس بالونة بلاستيك بوصة (الكوك)	\N	2026-02-20 16:41:50.944655+00
f57c358b-008d-49b9-91b6-7afd9b3032b6	da12de49-d1d6-4554-b5ae-43e76227ca90	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	27.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | عوامة نحاس بالونة بلاستيك 3/4 (الكوك)	\N	2026-02-20 16:41:50.944655+00
1ce82d89-97fd-4ea9-9aa1-7eac1d7b3b7c	ad598ec1-2ff3-43fd-97b7-c957aa24375f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	58.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | بشبوري (الكوك و ادهم)	\N	2026-02-20 16:41:50.944655+00
a4470e2d-9868-464d-8c43-30bd934ddb02	155fa0fb-6b2b-44db-8541-db6e2250448b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	132.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيخ شطاف الومونيوم (الكوك)	\N	2026-02-20 16:41:50.944655+00
9e3a28f9-839e-456e-a234-c3534f684a90	7e302e33-3bb9-436d-b2a6-f64f71fa113e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيخ شطاف نحاس (الكوك)	\N	2026-02-20 16:41:50.944655+00
2c5bd67e-5daf-4bab-810b-dfefbe15a5f7	15902323-3734-41df-bb0e-732074b9a1aa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خرطوم شطاف الوان	\N	2026-01-18 19:03:44.986461+00
2a975e6d-896a-439c-a420-037ce57f7bd3	e5bc8d66-e55d-4fe6-a17a-cf8f6ff8cd1b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي جروهي (الكوك)	\N	2026-01-22 14:19:45.630201+00
b782d24d-70c8-4cf0-829d-12bac4055e6d	55e08b76-5995-4930-91ae-2c3ab291202e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي نيكل سالمكو (ادهم)	\N	2026-01-29 12:49:38.080983+00
9a0a03fd-7268-4f76-8ec4-d850d808136c	a98b567b-37a4-4c42-9801-a5902cb3ef95	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي اسود ساليمكو (ادهم)	\N	2026-01-29 12:49:38.082003+00
845427fa-196e-4b47-b209-39997ff93b5a	9228f6d9-1d01-45dc-a79f-9b80a68c3c55	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي روما (ادهم)	\N	2026-01-29 12:49:38.082003+00
41e1ed5b-d990-4e4b-a149-cc97903c895e	9ad31176-b502-43b7-b47a-57cdaa1e623f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	39.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي كيس ستار (ادهم)	\N	2026-01-29 12:49:38.082003+00
aa2ec646-dc8e-44ae-adc6-92cd3df58688	c3887692-7b86-4407-a0ce-78ecc804fadc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي سولو	\N	2026-01-29 12:49:38.082003+00
e837d2dd-c912-49c6-9433-f684799e1fd7	6244a9bf-08bb-41a8-9bec-b8cc3df96f19	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي سوبر	\N	2026-01-29 12:49:38.082003+00
e8936740-eeb6-4efb-bb3f-54834695e7fe	48fba67d-dbc6-424b-b2eb-497fdc9b7bd1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي إينوفا	\N	2026-01-29 12:49:38.082003+00
33db5db8-fb2f-4219-9021-5872cb835a7f	d285b94f-1298-4c3a-b7ac-0042de1e97ea	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شطاف خارجي ماست	\N	2026-01-29 12:49:38.082003+00
2c947ee8-635a-4572-81ac-57e49b7c1bfd	65bfbf00-27bf-4323-ab25-1ccd994cddc4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	47.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | يد شطاف خارجي	\N	2026-01-29 12:49:38.082003+00
6a9a92d4-2234-4090-8b72-31adce6a46aa	6b464626-fbe4-4656-bd1a-d571d6836693	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	57.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 2" صيني رمادي	\N	2026-02-02 15:24:10.827742+00
7180e450-d1d4-4732-8605-f13800cd71cb	fb762949-d7b9-450d-982b-102fb9ceed95	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية جنب اسانسير	\N	2026-02-02 15:25:43.003892+00
5c3194a6-2a10-4b27-9ffc-27e41e5b0b0e	3ef92e16-40ee-44f0-98ca-671ee3a5805b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	128.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كاوتشة سيفون 1.5"	\N	2026-02-02 15:28:10.806647+00
5301f86b-a969-436d-a6af-0102a248f8a9	d50650fc-9afe-4e35-b5d9-eb8dd047b187	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	164.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كاوتشة سيفون 1"	\N	2026-02-02 15:28:23.912166+00
d0f0efcf-74d1-4a5c-afe9-31b2b0eaf2e8	32f48e5f-5ab9-419b-8916-585ded0e8320	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مكنة سيفون كاملة فيرست	\N	2026-02-02 15:28:48.340611+00
d6bce955-a8c3-4687-a943-e38bd27244cd	bf9ce757-b348-4b75-bbb4-0c6bf8efc605	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	36.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه كوع	\N	2026-02-02 15:29:08.6693+00
2c02dae4-da9c-42ec-8a41-8dd0fde638e8	fd1d4d05-a75f-4b1e-bab1-26b542487294	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه استانلس	\N	2026-02-02 15:29:25.074519+00
52014469-6a56-4346-b8dc-b1a60345184e	c3c27efc-96b1-4a23-bdab-93e04c7e9940	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه فار	\N	2026-02-02 15:29:39.724353+00
86463d4f-c87a-4feb-bbb1-f69ec7689f49	1db05d34-4a6f-4897-9a7c-619aa7351406	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه عادية	\N	2026-02-02 15:29:48.842245+00
8a881495-f69f-4790-9afa-9742571394c0	c7423fe8-0195-4f61-894f-5692b13601c9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	86.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حامل سماعة متحرك	\N	2026-02-02 15:30:06.112259+00
502bd7f3-e33e-4438-b5d5-6ecc221315b4	29837797-dac6-4388-b18f-4513160e8d31	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	78.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حامل شطاف عادي	\N	2026-02-02 15:30:30.859666+00
b288f2d0-933e-44a3-a844-7daca37e9f63	538af4af-6d6c-4210-be3c-0ffaecc7a7ed	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	27.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه قصيره	\N	2026-02-02 15:35:09.987893+00
6eff4689-38f3-46a7-8f2f-7827f99aec3c	cb81213b-7bb7-4274-abb4-2d974f8a60cb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	86.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شداد طويل	\N	2026-02-02 15:35:28.975017+00
2537a357-cce0-46ae-9366-17d213a79d5f	58991d0b-13f2-4dff-80e7-41c64abe1120	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه عدلة	\N	2026-02-02 15:35:46.899174+00
9a8bac04-ed1d-40de-82eb-4c96c5ec956d	6d01a666-06e8-4462-9315-00ba9f599a34	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه موجة	\N	2026-02-02 15:36:02.450285+00
214e0017-e27c-486b-bdc6-8611e5e64da1	fa3c71db-d1ce-4a46-9ee5-9b8b4c2158e1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار قعدة كيلوباترا	\N	2026-02-02 15:36:21.69907+00
35db52db-e1ea-4e3f-906d-3b7d15fb7619	30150049-3f07-44c8-a64d-f23fd7141fdc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	42.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار قعدة الما	\N	2026-02-02 15:36:35.687663+00
0c3b16fc-5615-4731-b9d9-c77c2a9f1528	f0a893bd-5ba6-4416-9f76-2f89c54a7767	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مسمار قعدة ايطالي	\N	2026-02-02 15:36:54.790817+00
2f6ed1e7-f66f-4925-b9b7-1f7b1f448648	111240d0-c336-4cf3-9cd2-6779a85cb709	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	82.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قفيز بولي مجوز 1/2"	\N	2026-02-02 15:37:24.090484+00
85cf4914-7ff3-48f7-b4b2-9536803c0647	6ec910b4-8783-403d-a1b3-3010fa7db258	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	315.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قفيز بولي لاتش 3/4"	\N	2026-02-02 15:38:08.931853+00
f0166cf7-10b5-4e8f-a1b5-5cabfcad1562	1743d3fb-848e-476a-8cab-5e48149abdc3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	95.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قفيز بولي لاتش 1"	\N	2026-02-02 15:39:26.862435+00
9aeb2e3c-7b56-4228-ab11-ebfab3c21b27	41c01f1c-ff76-4391-85d4-f5079c3787ce	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	100.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قفيز بولي فردي 1/2"	\N	2026-02-02 15:39:54.460178+00
06427e0b-063b-4953-bf55-09e0dd4b758d	32cac645-8208-4dac-9da8-01986e061b8c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	63.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 1.5 ماليزى	\N	2026-02-02 19:06:44.180499+00
4e72e6dd-422a-4ce0-9268-ef2fc693e224	3475e3b2-b002-47e6-88ee-85a33cd7f837	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	39.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 2 بوصه ماليزى	\N	2026-02-02 19:07:21.784587+00
1657f414-b053-43a6-a416-5bc67f5e70e8	625c7018-17e7-4090-9e8a-fbbedab8d3e2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	54.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 1.5 رمادى	\N	2026-02-02 19:09:46.434495+00
4740ab63-db22-4288-8344-62180310c31a	e0066fb9-2326-421b-a886-489c8b5863ab	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	32.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 2 بوصه رمادى	\N	2026-02-02 19:10:08.971445+00
0e7d14ac-fed8-4d6f-bb1f-955209b9036a	45b07094-6fd8-4438-aa7b-4ba17e5ed897	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	27.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 3 بوصه أبيض	\N	2026-02-02 19:10:48.025512+00
9e29e9fe-affd-49cd-ad39-c69594cbbd5d	3f69fa98-e1f0-4102-a092-d17b3924abf9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	32.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون3 بوصه بفايظ	\N	2026-02-02 19:13:58.857832+00
14f49a4a-1d23-4cf6-85b1-cc929806c3cd	f7f12634-4eb0-4c26-8f20-691639ed46fa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 3 بوصه بروحين	\N	2026-02-02 19:14:35.730526+00
a6ad4fe5-3522-455a-9f75-c46b82ec1646	a6701d83-54db-4c36-968d-2354d17328ec	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 2 بوصه بروحين	\N	2026-02-02 19:15:22.467925+00
a0403ed5-8e24-4340-8654-88c68f7499b5	89153ada-a2e6-45ff-965d-a610fca6a73f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 3 بوصه بزباله بلاستيك	\N	2026-02-02 19:16:05.314159+00
d64fc84b-370a-4b67-a89d-fc3cca26133c	b81afeec-6c16-455a-8aed-b6a43abd3b9b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	78.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 1.5 كبايه	\N	2026-02-02 19:16:38.530868+00
542bc493-8cbb-4d10-b34f-3e5af1c06268	cf75658d-4804-42d6-bd8f-edf3a77549be	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 3 بوصه رمادى	\N	2026-02-02 19:16:58.666155+00
247f86ad-77f0-4a3a-a9d3-b2dfd353e61f	d78e3631-becb-459d-bcb7-f626d9bdae58	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون بانيو	\N	2026-02-02 19:17:15.44432+00
1493b31f-b751-45bb-94d0-9c54db9c4524	2e9f519a-ab35-4cc7-a168-bd51332e9700	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 3 بوصه بزباله استالس	\N	2026-02-02 19:17:51.624571+00
caee11c5-a8ef-414a-a812-21312e2bad8a	605b00e5-e53a-42e8-b98d-53030c4f7284	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون صينى 1.5	\N	2026-02-02 19:19:01.181735+00
6b65aef0-53fb-49c3-b45d-f3b6b874696f	48745b7a-4ef7-4583-a151-234efc18dbe7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	57.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون صينى 2 بوصه	\N	2026-02-02 19:19:28.108334+00
978dea93-ca22-44d7-a986-c0e0fa5251ae	db4063c5-f89d-40d9-abd9-968984ad74f8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	174.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قفيز بولي فردي 3/4"	\N	2026-02-02 21:26:32.249983+00
9f719144-1a02-439c-ab8a-7821f6fb9d30	66e9c7ca-229c-4dbb-9f3a-345225214c9f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	234.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قفيز بولي مجوز 3/4"	\N	2026-02-02 21:30:11.403724+00
f76ca204-7a89-4e29-814f-498e0f58aa87	9ac24b13-ee09-4646-9bb8-249a9b471037	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خرطوم غسالة مياه 3 متر جولدن فلو (الكوك)	\N	2026-01-18 19:12:30.120497+00
e84ccfe1-7cc0-4895-a717-c7c4a6c45af1	19d71c4a-8090-4996-a85c-2df2eb0ee554	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خرطوم غسالة مياه متر ونص جولدن فلو (الكوك)	\N	2026-01-18 19:12:34.503756+00
d070aa5e-ec24-47f1-b911-b971aca501e7	a392d3d8-9dc7-4509-92c6-96e52892dc45	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خرطوم غسالة مياه متر ونص جولدن تركي (الكوك)	\N	2026-01-18 19:12:45.952747+00
64fe435e-c77a-4795-acb3-577cc007e953	543dae04-a219-44b2-a24c-8e663ec4c865	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خرطوم غسالة مياه 3 متر جولدن تركي (الكوك)	\N	2026-01-18 19:12:52.496582+00
9263a33a-e7aa-40b6-8bac-18c034ddb8f4	c9d9c6cf-9b3c-464e-acb8-89e7b9e60117	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خرطوم غسالة صرف 3 متر (ادهم)	\N	2026-01-18 19:14:53.843401+00
b3757ef6-5cb4-463e-9932-675741791c0e	a677536b-b254-402f-861c-caa5d4baf82f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خرطوم غسالة صرف متر ونص (ادهم)	\N	2026-01-18 19:15:24.714112+00
714bbfcb-88c0-46d2-805f-3c9ae8ce6cc8	189b8e6e-6161-40ba-ab29-98d73b32232e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية غسالة (عمار)	\N	2026-01-21 09:35:22.486394+00
a6a0492c-4a2c-41dd-89d5-a166cf636924	8fae6b9b-5008-41b4-a965-9a6c1ded4518	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية غسالة روفا (بلال)	\N	2026-01-21 19:38:43.959582+00
9744ddbf-0113-445d-8165-a9e1029592db	aaa9b0ea-6fca-4ea2-9b68-59b22b719e6c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 1 بوصة	\N	2026-01-19 19:05:44.248619+00
1227df58-7aa7-4754-b359-d7b7e4f36679	aebc30af-cb2d-40a1-a4aa-7a7f438a864a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	93.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك سن داخلي - سن 1/2 * 3/4 (عمر)	\N	2026-01-19 19:03:41.558684+00
c36565f1-0a7f-4c07-8627-4be10e1b226e	bfde9b7d-4434-46e2-9972-bc39262ad6ac	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	181.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع سن داخلي - سن 1/2 * 3/4  (عمار)	\N	2026-01-19 19:03:52.399587+00
c97363c0-2aaf-43a4-addd-a0c21593cc0e	04584170-0c95-4aec-9669-fc9bc5778b8e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	291.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي - سن 1/2 * 3/4 (عمار)	\N	2026-01-19 19:04:00.511238+00
259f6810-5a1a-4ffe-a9d3-c6f126615c3d	855d8d44-57d9-4704-9908-8fdefbf12615	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	424.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن خارجي - سن 1/2 * 3/4 (عمار)	\N	2026-01-19 19:04:07.237227+00
738b48df-5903-4654-b91b-ae1442704d40	62f17a04-2661-4859-8678-a0d17bbc0a0d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	59.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 3/4 * 3/4 سن داخلي (عمار)	\N	2026-01-19 19:04:13.150707+00
c1157b71-a18c-4732-a359-7ba3e64a1f39	3ccc958f-8b6a-4bd8-a9d0-47bba9de7485	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط دش روكا (الكوك)	\N	2026-01-22 12:10:41.758539+00
3c038fa7-ab2d-4579-b514-22f6b91f3a65	751a8dd7-078f-4709-9144-9c29d8b89762	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط موكا دش (الكوك)	\N	2026-01-22 14:00:28.285706+00
5cd0fc92-4ae6-4db9-8b81-32a75e56b8d3	cbb6ab60-767c-4ddb-be13-89063020cabc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط مطبخ روكا (الكوك)	\N	2026-01-22 14:02:07.150454+00
fd73e2a9-61f8-4e80-b8b0-a43ea10d8327	06095b8b-ee17-4436-9942-c9976657fd63	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط مطبخ لومي (الكوك)	\N	2026-01-22 14:02:47.405899+00
354e7b3a-2864-490f-befd-c5fd5d0dc45b	1b0a5385-3616-4c3a-b745-a85f92393217	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط مطبخ موكا (الكوك)	\N	2026-01-22 14:04:02.189476+00
4d1e524f-5561-4a4e-911b-da362e69422d	1cda0ceb-91d1-46c2-966c-39fb3afa37af	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط مطبخ سالمكو ابيض (الكوك)	\N	2026-01-22 14:07:27.101698+00
8d86f02d-2942-4f0c-ba54-36f6d10c8608	0f6dcd53-d686-43ae-8d75-54b1a8d2fcfe	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط مطبخ جولد روكا (الكوك)	\N	2026-01-22 14:09:49.421859+00
d84a1257-76fd-4fd2-a878-811c67479a7f	ca3d769f-2e88-4ab4-a664-10168fd3f444	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط وش جولد روكا (الكوك)	\N	2026-01-22 14:10:24.3023+00
a9276ad6-4bc3-4f31-9342-c546e3230074	42080636-8663-44f5-b4c1-9b39aaac1507	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط وش اوكر لومي (الكوك)	\N	2026-01-22 14:13:25.965227+00
22e9567a-52f3-488d-9f97-478552e1fc3f	6fbb04b8-4330-4c11-bfa4-8b1109d55f89	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط اوكر سالمكو ابيض (الكوك)	\N	2026-01-22 14:16:39.260973+00
6778f9ef-12ca-47c0-8875-870be4fb19eb	21f29f18-4d31-44eb-8cbe-787b049dfa55	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط وش كوكو موكا (الكوك)	\N	2026-01-22 14:40:53.885962+00
ae2d2cfa-adee-4d37-a7ce-2457af4d20c7	6c320719-401e-47ac-bee3-21e7b61769b5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط وش ساليمكو (الكوك)	\N	2026-01-22 14:43:18.814499+00
ad615e21-95a2-48c2-935e-e339f103b768	10fad07e-e235-4c23-8975-fbf164f85ea0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط وش روكا (الكوك)	\N	2026-01-22 14:46:39.725569+00
9047a5ba-155a-4df4-94fc-f083bbb21ed2	e4a2fec7-1530-4b1c-b279-8ea6e7fb894e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط مطبخ فيتو (الكوك)	\N	2026-01-22 14:53:15.741383+00
3cde30a8-91d2-46bc-b7c0-01d619c5e65f	9b47cbd8-d805-47d6-bd39-8452ad291acc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط مطبخ سينزو (الكوك)	\N	2026-01-22 14:53:53.533228+00
25545fe7-d1c5-4a37-82b0-8e4f5d221041	0053a86b-d8a7-4da3-92dd-fd92a4e9bcc8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط مطبخ موكا احمر  (الكوك)	\N	2026-01-22 14:54:17.309819+00
0320d24d-0d4c-4890-bbd5-bd86465713eb	dad20297-7d49-4231-bfd1-812ecb3ded63	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شطاف ليمار (الكوك)	\N	2026-01-22 14:55:06.989326+00
9b112981-9f23-4921-a73d-7b6b3a6990ef	a4e213ae-e816-4c03-a379-402ec0d79454	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شطاف سينزو (الكوك)	\N	2026-01-22 14:55:27.229806+00
5fed145b-8480-48fe-9bfc-458e04159d31	95070eb6-92ac-49bb-9242-b9d24fcfd7bb	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شطاف روك MG (الكوك)	\N	2026-01-22 14:56:20.109743+00
5b4fe14a-f3af-453a-b4c0-562e7ca8488f	5cd2a754-00cb-4a1c-a7bd-3ea5e0147927	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شطاف سينيور (الكوك)	\N	2026-01-22 14:56:58.253773+00
714469f6-6870-4f2a-a42c-25e647fafdc4	f1f57c68-4a58-447a-85ac-8147d2acd1d9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شطاف النيل (الكوك)	\N	2026-01-22 14:57:26.765701+00
2b47accf-8c7d-463a-ab8c-a8af5b1b93e1	c412d1be-d6c6-417b-9f67-48f9129e145d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط 1/2 بارد جنا (الكوك)	\N	2026-01-22 15:01:58.830456+00
c4e9b527-95ca-474e-9599-6da19f4a65ff	d3fec787-b312-4d8d-83f4-918c4b1add15	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شجرة دش ديتوريا (الكوك)	\N	2026-01-22 15:03:06.732934+00
1184e817-050d-4ef8-b4b8-b66a9c94e063	24fb14a1-81cd-4bff-934c-979871903865	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	24.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شجرة وش 1/2 محمل ديتوريا (الكوك)	\N	2026-01-22 15:06:35.725891+00
a9507586-845e-4a67-8824-60ec5ff992d9	97565e26-97a2-4284-ba09-ae9b8f8b6be2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شجرة دش اوكر (الكوك)	\N	2026-01-22 15:08:25.838261+00
d8b316dd-1871-471f-9b7f-adf2688031ed	58a4a59e-3495-4e62-b2d0-472aaebd65d6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط دش سينزو (الكوك)	\N	2026-01-22 15:08:55.197365+00
65b709b9-c952-4634-8e4e-9b4ca46d0908	06ddd19d-3ce2-4821-af81-09a1691dbd66	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط وش جولدن ايجل (الكوك)	\N	2026-01-22 15:13:20.237613+00
c6766f98-b97b-40dc-9d89-15a475d19bd3	112dcd47-c1b5-48e5-8c35-a607803fbab9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة حوض ستار (ادهم)	\N	2026-01-25 17:00:28.989011+00
1ce0671a-4f31-4c92-80a5-9dd2431fa237	f03dd423-06f8-47ff-9f3f-38aeac20a897	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس مجوز محمل (ادهم)	\N	2026-01-25 17:03:16.445111+00
a38437a6-4201-4639-926f-d5fc961eac8f	9f43f345-bb0d-4097-9ce2-8fc11499c952	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس مجوز خفيف (ادهم)	\N	2026-01-25 17:03:29.659999+00
8feb83a5-7eed-4ee2-8db0-5cf298c9f992	0022d9ed-8597-4847-aa41-496c0f5f6fdc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خزان شاور (ادهم)	\N	2026-01-25 17:04:10.236359+00
4a9767ba-f358-48d5-ab19-de980f1459ef	acd67601-084b-4d50-9c35-121344944338	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس جولد (ادهم)	\N	2026-01-25 17:04:35.499663+00
762baaec-1888-4560-94fc-43b3fc2e6d54	11cbf451-8e09-4ceb-b1d6-1093e8704a2f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية غسالة هواي (ادهم)	\N	2026-01-25 17:04:54.796142+00
cb1ba3cf-7517-48b0-9b72-198d2b7f3193	364cf46d-c57a-4d8e-bb4d-76c81c41110b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	72.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس هاينز (ادهم)	\N	2026-01-25 17:05:12.299668+00
29f3c4ff-c6f3-44a0-a30c-62da2f7561b1	f9e48d97-167b-443e-bb9f-0dcc047bad58	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	39.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة حمام هاند ميكسر وش (يوسف)	\N	2026-01-29 12:36:28.051655+00
e94023ae-dd41-4fc7-81e9-9ad888587607	39a64571-ec16-476d-be59-88ceef71426a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	32.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة مطبخ هاند ميكسر وش (يوسف)	\N	2026-01-29 12:36:28.051655+00
1dd88c1d-a61c-4eb4-b1d3-e732219dd295	de2a4366-eab4-4c04-9bd0-362a29eab7e8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة عكاز هاند ميكسر (يوسف)	\N	2026-01-29 12:36:28.051655+00
40fcbc4d-3593-4891-9f82-5e5a747fe18a	5d31eb67-6989-4113-8936-43dc6ae1a959	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	97.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة 5 لينيا وش	\N	2026-01-29 12:36:28.051655+00
21ab6e6f-4f5c-4eb6-a2ca-04098d87409b	66dfac46-fd00-4ebf-93de-f48f6110b778	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة 5 لينيا مطبخ	\N	2026-01-29 12:36:28.051655+00
35c1e17f-8177-4077-a5cf-45d6b25bf1a9	85d12824-8b4e-4805-a439-94123944367c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	102.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة 6 لينيا مطبخ	\N	2026-01-29 12:36:28.051655+00
f0d5f8a7-8a3e-45ec-a7ed-fa72b249d4ec	2a0cb6d2-3bf2-48b5-9454-37cd53b23c9e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	19.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة 6 لينيا وش	\N	2026-01-29 12:36:28.051655+00
813200fc-6a09-4245-ac73-3f36d1a5a9a4	0a184115-b9d7-4ab5-9d82-c864eb702b45	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	124.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة وش هاند ميكسر قصيرة	\N	2026-01-29 12:36:28.051655+00
dccb255d-0946-40bc-a9e0-ad4c9b19e8a6	b656dab6-3e5f-43f4-9405-9c2dd680411f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة مطبخ هاند ميكسر مقلوبة صغيرة	\N	2026-01-29 12:36:28.051655+00
c53ed649-3f84-4578-9808-2e1b584b9021	9d992477-0510-4e5d-82c2-89b66cc8658c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	31.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة وش هاند ميكسر طويلة	\N	2026-01-29 12:36:28.051655+00
45db3b91-4fdd-4946-aa65-19d572cdefa4	8bfd6725-3128-4c54-b869-fc2a959df714	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة هاند ميكسر مطبخ	\N	2026-01-29 12:36:28.051655+00
06e75b9b-abd0-4321-86ea-ec031ccbb08e	37ee2418-56bb-4d8e-b0ec-fe9ffb1fc333	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة عكاز وش صغير	\N	2026-01-29 12:36:28.051655+00
70ea411d-42fc-484e-80ab-753cea3471c2	d6a1126f-180e-480d-9924-1fb69414f686	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة عكاز وش كبير	\N	2026-01-29 12:36:28.051655+00
dd6ebc75-3cc1-44c6-bbf2-7fc496cc44d4	729d42f1-7d09-46f9-a4bf-58d11104de7b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	23.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة مطبخ هاند ميكسر مقلوبة كبيرة	\N	2026-01-29 12:36:28.051655+00
c2513459-8692-411e-9218-039630248904	f28d6018-f8ef-4e25-b404-1830ea0d3708	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | قنطرة هاند ميكسر غكاز مطبخ	\N	2026-01-29 12:50:51.761397+00
bcd5a10d-d739-451b-9e4f-6fa3cfff59b2	3facfe2f-f0db-410c-b679-7e7082704488	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | هلاله مسمار 1	\N	2026-02-01 17:06:07.674285+00
51b4570f-7712-4de9-bdcd-b638abf1f1ef	bf8c300e-e7d6-4072-9c5f-c1745542bf46	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	53.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | هلاله 2 مسمار	\N	2026-02-01 17:06:27.799151+00
4be3dde0-fc39-443e-ba9e-f58cdedac556	7dbbf287-1956-44eb-8f05-20c48068fa87	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	20.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طقم كرنك خلاط استالس	\N	2026-02-01 17:07:27.044835+00
76a906cf-ecb8-42c0-907f-a10675180a5c	1d30a4fe-fbfe-4d3e-886d-d7c5ec544240	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	244.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | صامولة قنطرة 6 لنيا	\N	2026-02-01 17:09:23.581078+00
9abfdf07-9e34-4fdf-8cb1-1da3a928f028	6c53ac78-8c67-4b7d-9417-fe21bb9cad2c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	440.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | صامولة زنق هاند ميكسر نحاس	\N	2026-02-01 17:10:35.219759+00
a1ad5e46-7719-4e7c-bf35-d39ac3b3a836	e196b412-5f2c-4a18-81ee-3c50385a03fc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | وصلت خلاط 5 لنيا	\N	2026-02-01 17:11:27.335241+00
8f8c6f43-2f66-4326-8757-ecbfc2999560	87d4538d-0e02-44ee-976a-53651c8e11ab	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	44.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبلة خزان 1"	\N	2026-01-29 13:04:56.586921+00
126012b0-18d0-40df-a4c1-f84dab5dc664	015510b5-5c17-40eb-8099-378255764017	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	50.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك نحاس 1/2 محمل	\N	2026-01-29 13:05:20.202709+00
66373ea5-269a-4b55-93cc-d863e5ac80dc	eabea370-6202-46ed-836d-89822831f083	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	120.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع عادة محمل 1/2	\N	2026-01-29 13:06:01.8035+00
3b821d50-453f-4f9e-ae39-ef014831d687	fbc41295-0338-4e49-b61e-79e99e9f5667	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	128.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبل نحاس 1/2	\N	2026-01-29 13:09:04.443198+00
e8ffbc97-223c-4fa0-9dfa-a19754f7f261	a2cdd98c-fbff-4718-bb70-ebb3eb940b55	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	47.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبل نحاس 3/5 * 1/2	\N	2026-01-29 13:11:59.962066+00
9e5ff686-50d0-44f2-b527-3f6b31100e7a	6652a94b-e908-4557-a060-95e8a2d1c9c3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	56.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع صنارة محمل	\N	2026-01-29 13:26:04.321138+00
6fa95a4b-a03f-44c7-bce7-67b726811bbf	2bd5ddec-5128-4551-a96d-f826eaaec686	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6080.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبل 3/4 نحاس	\N	2026-01-29 13:31:32.249287+00
23e29621-c6e4-47d3-8834-823753e2ac32	129089d7-95d4-42cc-94ef-2e54da0be9f1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1280.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة 1/2 نحاس	\N	2026-01-29 13:33:31.976981+00
76228047-314c-4a3a-be58-fb8c091bbdb9	b4d85961-96ba-4080-aa56-285b5489712c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	126.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سماعة نيكل 3/4 * 1/2	\N	2026-01-29 13:39:26.104821+00
14913823-2057-4c8b-8b1e-71b7e1394a50	e0e6359a-6bf8-43ed-bb47-0b0e63e10d65	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	130.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سماعة نيكل 3/4 * 1/2 نحاس	\N	2026-01-29 13:40:02.808686+00
6f70987b-31a5-4d14-adfe-52032709721d	fc080463-994d-4137-87fb-c0544751b8ac	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	355.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبل خلاط صغير	\N	2026-01-29 13:40:16.840735+00
4ce0773c-0269-433d-8fb0-43afcd9f432e	4c4aa1f7-2214-4e18-86fc-792298942132	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	138.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نبل خلاط كبير	\N	2026-01-29 13:40:35.207902+00
ad1b7980-32dc-46da-8c64-a89a2011ad8e	731e6d42-8a1f-466f-b80e-97784861e90c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	879.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كعب خلاط نحاس	\N	2026-01-29 13:40:51.095914+00
9bbb5f50-c43c-47a7-8c7f-785207b0c4a7	242e2fb5-5a2d-4d00-ba37-e9f08f40c31f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	87.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع 1" عادة سمارت	\N	2026-02-04 14:10:14.72849+00
7a447b82-af17-4121-aadf-3bf8c33f5167	2a10fa6f-8cec-43fc-868a-d9c6b614e101	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	61.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع 1" مفتوح سمارت	\N	2026-02-04 14:12:26.727776+00
8189ad01-2faa-49e8-b0b5-ffd766e1d537	3896b31c-7763-425a-8bc2-d52a6b6ed94f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة 1" سمارت	\N	2026-02-04 14:12:55.784626+00
4d7fe852-bdea-47b0-bf1f-74d86436fa47	48ff7790-a0dc-4c11-b27f-e1c8c92ca52f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك تي 1" سمارت	\N	2026-02-04 14:13:35.832428+00
9e3b2d7d-00be-4aad-8d0f-f61e78be8ac4	2d83aef3-45b0-41bb-9475-b1b64ab3bded	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	51.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك واي 1" سمارت	\N	2026-02-04 14:14:42.896833+00
3a045e5f-e0d8-4955-a73a-d35cb63b9a3d	58972db3-c507-4f0a-a8aa-77ba90cd06fd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع عادة 1.5" سمارت	\N	2026-02-04 14:16:09.84822+00
d5dc13d0-745c-4e70-85c2-d25779850d28	8e2e8783-9d76-478b-b10f-e9342e98e16f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك واي 1.5" سمارت	\N	2026-02-04 14:16:44.775591+00
23f2a52c-da29-4b64-aea7-f0df654a9439	5a69faeb-91af-4ec9-85f2-6939c22df3d1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع مفتوح 1.5" سمارت	\N	2026-02-04 15:09:53.89195+00
2dee170d-ad8b-4bfc-a0cb-17998b34dea9	8f7aafa6-b4da-421c-a7bd-f27fa96b1974	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة عادة 1.5" سمارت	\N	2026-02-04 15:22:56.563347+00
03ecbe0d-3585-4ea1-aea7-50b6670da052	16215c47-6d07-4eab-a055-de8f98d0b6d8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	38.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع 2" عادة سمارت	\N	2026-02-04 16:02:16.529075+00
492eb6a8-79a1-460c-92ca-af65e1cef453	75f27b8f-be6b-4bb7-90cd-6604cf2a14c1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	54.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 1.5" سمارت	\N	2026-02-04 16:05:12.25651+00
17f863f9-29f2-49fb-b52e-94f3278c7c01	9bdfe990-a632-4e4a-a461-c97627f66aa2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	59.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع مفتوح 2" سمارت	\N	2026-02-04 16:05:35.775817+00
d2480f8d-7ab3-4dfb-99b6-7baaaf4dfcf9	6bce2691-dbf2-484b-bd68-b1ca3e7404ed	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع عادة بباب 2" سمارت	\N	2026-02-04 16:17:36.974994+00
94574c23-3335-47a9-85d8-87fd57f592f9	8c61aff3-78b7-499c-a20c-f2e2d06f31c2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 2" سمارت	\N	2026-02-04 16:19:43.150728+00
54aad05f-02d4-4327-ac5f-ccc4275144f0	04955fdd-d0f5-4355-a51b-4c78e6fa51b5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | واي 2" سمارت	\N	2026-02-04 16:20:17.1682+00
61e562de-4e5b-497e-a42b-cf5492c67bae	74f991b9-037e-480f-b6d4-e47da50d2e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي بباب 2" سمارت	\N	2026-02-04 16:24:20.57455+00
6644ba56-5e9d-4134-9802-e23003cf115a	c9d4bbe8-5763-41f3-8fca-6328191b54c6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بباب 4" سمارت	\N	2026-02-04 16:26:10.590267+00
e4a3216b-01ac-43ea-912c-08ff3cacbc1b	01345ffe-fb1e-4b0b-9ccc-b52ce0716020	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 4" سمارت	\N	2026-02-04 16:33:49.525696+00
bd2f9de5-19ed-4a4e-9a9e-03563836b84a	ef927bc2-dd52-4c27-af97-abef6001cb3d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة 2" سمارت	\N	2026-02-04 16:38:33.48579+00
83f1c861-1d28-49a3-9ff4-10670bba2ba9	7da00ad0-bb2c-4d44-b9d0-52caf278cd55	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة تسليك سمارت	\N	2026-02-04 16:40:02.365338+00
31a2e9fe-f264-475d-8257-bdd7d406ea94	95397be8-d564-4c4d-a4d4-52bc321fb9e5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي بباب 4" سمارت	\N	2026-02-04 19:15:36.281301+00
b0ff7f12-d388-4877-8766-71daa919c8a1	7516d39d-1ba9-4514-8694-b156c4b3f404	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 4" سمارت	\N	2026-02-04 19:16:50.471338+00
df81021b-89dc-4451-b16d-7426b50583f7	446eca70-ca36-48ac-86a0-10f6e18c01a9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 4" عادة سمارت	\N	2026-02-04 19:18:56.727941+00
0a7cac20-4b5a-4e95-b2e2-93b464ce7aa1	8d300a64-8928-47af-9d61-e8cda073dcc3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع مفتوح 4" سمارت	\N	2026-02-04 19:20:28.168356+00
0f03c7d5-6c22-4915-bf7d-84f11c263ede	4d4366c5-3ee6-44bf-ac5a-a341aaf15057	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | برقع بلاعة سمارت	\N	2026-02-04 19:22:12.903896+00
880f4d89-b5ba-4ca6-98db-45555e38fcbc	1cd6083f-f377-478d-b54e-a3a0b8a66595	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 2 * 1.5 سمارت	\N	2026-02-04 19:23:01.208091+00
f812b2e0-0f3f-450f-810f-b99a1e88ffea	2653d564-e6ce-4bd7-86f0-f84f09d3c529	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 1.5 * 1 سمارت	\N	2026-02-04 19:23:32.151448+00
ac04cde9-61e4-4d94-93d3-775ecac50ce8	0df5e9da-aa4e-44b8-aa5b-bf926888b7c6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | هواية 4" سمارت	\N	2026-02-04 19:24:15.993677+00
8bee1fd0-6d16-47f0-b5fa-1fb40b3cb286	b2695def-80ca-4556-85df-e9cf5440d08d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | هواية 1" سمارت	\N	2026-02-04 19:25:31.479382+00
fdd46306-5fc0-4d12-8398-5363427de5cd	a092d113-7153-47dd-8589-2a48f7807e6d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | واي 4" سمارت	\N	2026-02-04 19:27:36.55209+00
601b14f8-2e9b-40bc-a386-04137a7c8c29	ea08286a-83e1-4151-8221-3ad4cbf6fd9d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | وصلة تمدد 4" سمارت	\N	2026-02-04 19:32:54.583146+00
f83a8630-eb41-4a9f-842e-e05ebd2cd897	a01fae38-7472-40c8-a340-7915a7359b6b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن داخلي 1.5" سمارت	\N	2026-02-04 19:34:37.70368+00
1c268f55-ba4d-4c6e-8028-f632316a5f05	1697cc2b-8aa6-40c8-8d42-412bcb10dca9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	50.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | اختبار	\N	2026-02-06 22:00:13.12123+00
9c68aee7-1a78-4378-aa80-9a8b92bdeae1	cca800ba-631f-49da-94c9-8ea5b8e8ea6b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	139.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة 1"	\N	2026-02-05 16:25:42.309536+00
d440134d-bd31-4136-82d3-244cdd9e7a10	ffd44b52-646c-48dd-ad49-7a955a9dcb21	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	252.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 3/4	\N	2026-02-05 16:30:06.145087+00
dfd15276-4811-482c-aca1-a21ddfdafcdb	d468aa72-a661-4d6a-bac0-431892931b0b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	253.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة كاب 1/2"	\N	2026-02-05 17:06:40.193488+00
35ed391a-35f4-4a8c-b3be-79dde14be92a	fdbf99f3-062b-4011-814f-e8e50634b02d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 1.5 * 0.5	\N	2026-02-05 17:08:11.609015+00
37fc70c8-0104-4688-bb2c-d45e0fc444bf	74d2c47d-ad15-41de-98b4-b4d6d98c659c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 2" * 1.5	\N	2026-02-05 17:55:14.189288+00
46d216fb-2fd2-4b54-96c2-c95c5ab2aa52	f305a965-af31-433c-9514-e050f4508875	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 2" * 3/4	\N	2026-02-05 17:55:44.690649+00
95aa2c81-af66-431e-9af7-d84769276e3e	df868d6f-bda5-4441-893a-9fe733f91e32	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	118.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 1.5 * 1	\N	2026-02-05 17:59:49.503819+00
2bbc8e25-65f4-4408-a489-ca97fea6fa73	1f687959-dffd-407a-83d6-63980b3fb35e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	32.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 2 * 1/2	\N	2026-02-05 18:07:35.726949+00
52e34f3f-84a0-474d-8b2b-d7fe52614841	7e96927a-e82c-40dd-b730-40452540550b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 2 * 3/4	\N	2026-02-05 18:09:45.183057+00
42f8aeed-80c3-42fa-8832-1312af62ce3a	b93d809f-b9c2-462f-b50f-584a05e408f7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 1.5 * 3/4	\N	2026-02-05 18:10:11.359066+00
9b07a86a-c08b-40fd-9cbe-8987ec8b8c3e	7e82c0ee-eb1a-48c8-8c31-d57c4ee62112	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	124.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة اختبار الوان	\N	2026-02-05 18:12:26.36636+00
8ce2a7a8-53ad-495d-b54e-7b093b136624	5582619d-2012-4f07-83c0-c904f6e57bc3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طبة 2 * 1/2	\N	2026-02-05 18:13:57.381539+00
4df18a4b-5b78-466a-9708-241b3d08584f	ffa0d3cc-9d21-44ee-8ac7-5e3b17ddee92	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	56.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1.5 * 1/2	\N	2026-02-05 18:15:28.382625+00
bae34303-4596-4665-9fea-e12ce70065dc	3da95089-bfa4-407c-ba9d-8b096302c4ef	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي 2 * 3/4	\N	2026-02-05 18:16:10.846336+00
96051713-f630-4390-9023-8a1b2d69d0f4	46401744-e12c-435b-baa4-5fd53469118e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	53.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 2 * 1.5	\N	2026-02-05 18:18:47.855139+00
47e0bdc8-807a-4ec6-8d3f-c5e18ba41579	658992d5-1f93-4309-afb5-22dd41777f6c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	87.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 3/4 * 1/2	\N	2026-02-05 18:19:46.542462+00
0ae484d3-033a-46e7-974c-7d8255ce7409	9dcdf30e-a5b5-4636-af3b-a8491cb82704	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1" * 1/2"	\N	2026-02-05 18:21:11.054137+00
35d07d3e-ab0e-42ec-8701-3b7ce5d9e46c	429fcc2b-56f4-4e32-a3bf-3437b64a3201	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	27.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1 * 3/4	\N	2026-02-05 18:21:36.974283+00
7fa25fa3-182c-43c9-a901-8771e1df8c36	99bec8cc-8f51-4bff-b8c4-6c79bef4892e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	148.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 1.5 * 3/4	\N	2026-02-05 18:25:47.389968+00
62159f3c-6496-4e93-866e-3c12def2a428	9fa7f793-227b-44d7-a95c-c88c5705e89c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	76.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1 * 0.5	\N	2026-02-05 18:26:25.710839+00
fcf45c70-e4a2-4aa9-ab52-3ff077cce056	b0010911-a553-4480-9d0d-d51e432e61b6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	73.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 1 * 3/4	\N	2026-02-05 18:27:11.517947+00
8c79e7b3-73b6-4215-bee2-4eed7ddc09e8	4ff0fa6b-1b53-4064-98b5-30bba06b1dfa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	72.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع 1 * 3/4	\N	2026-02-05 18:27:37.822443+00
8ed1cc07-b27e-47fd-8246-23decad6786b	92565437-4f18-408f-ac3d-ffc4624663ed	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	78.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 1.5 * 1/2	\N	2026-02-05 18:28:53.022014+00
c53cef1b-8cbf-4a7b-b219-d4b68e574c4f	55612a96-6a02-474c-ac65-009a45ab9d9f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	94.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 1 * 1/2	\N	2026-02-05 18:30:26.142125+00
ea263eee-b529-4e4b-9883-7ecd1356d510	55747c66-cd99-453d-be45-ecd7ce155ec3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	213.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 3/4 * 1/2	\N	2026-02-05 18:33:01.949471+00
2dee85d9-73c0-4fcc-afff-1b7fcaf30e29	64c281e1-8184-463e-bee6-0e83f1b9b7aa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع عادة 4" BFS	\N	2026-02-17 17:27:12.223007+00
2ded6696-ead4-4434-a42f-5e12c1197e06	48d5fc8b-2739-48e2-9ee4-3c0fab0d6bf7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	31.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع مفتوح 4" روك	\N	2026-02-17 17:27:41.838572+00
86c738e0-6993-499c-a759-db02862bbe43	dfa66d4f-7243-48a9-a33c-5e072222cac4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بباب 4" BFS	\N	2026-02-17 17:28:08.527426+00
11daa0e1-511c-4866-b82d-f0b4c4d52960	6567f7cf-c146-4df8-a3be-8650e082cad7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع باب 4" روك	\N	2026-02-17 17:28:35.854887+00
289b3643-3b90-45dd-965a-650dc8de9004	dcaf8c13-ddc1-4fb6-849b-694a0c59edc2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 4" روك	\N	2026-02-17 17:29:00.27245+00
0cc613ba-eb5c-411f-8627-7bd31b02e10d	fc3a49eb-0812-42b7-9f84-08333b2559d8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	199.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة اصلاح 3" روك	\N	2026-02-17 17:30:02.215396+00
066f35a4-254c-4d29-b3cd-53544c8da8d0	ca29c5d5-7258-4543-9775-474b7a2e2256	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	74.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 3" روك	\N	2026-02-17 17:30:43.439673+00
a144ea00-66b7-4a22-96db-c7353d37057d	597008d4-6870-4765-96e9-29436230b29e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 3 على 2 روك	\N	2026-02-17 17:34:22.734638+00
a7ec94e1-4fcf-4c31-aa96-f695887477cf	9f1b35b7-6bd2-40cd-8453-c6288391b2a8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	49.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 3 على 2 باب روك	\N	2026-02-17 17:37:19.487416+00
c38160e1-21a1-44c6-95b1-9088592720ba	63f63c8e-27f5-479a-a4ed-48d8ef15c1e0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	42.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 6 على 4	\N	2026-02-17 17:37:36.206737+00
a4796084-af76-46bd-b94d-be48a7d3841c	9230b14e-5c16-482b-998a-c3cc6242c67a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	29.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | صليبة 3" روك	\N	2026-02-17 17:39:44.590162+00
6871b5a9-a569-4a75-a6b5-55c54bff8fc0	9838af29-0eeb-401b-b8b9-e7272e248cc2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	95.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 4 على 3	\N	2026-02-17 17:40:22.670993+00
71c24630-b25c-408f-9651-0848733ee4de	89c711d3-026a-4080-90e5-5854aadbfad2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	174.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 3 على 2	\N	2026-02-17 17:40:54.669555+00
6c66b0ba-54ad-4af2-9423-9fafd00d8d63	80955f9e-f1a7-4dd6-b254-d0aae0786059	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	102.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | نقاص 4 على 2	\N	2026-02-17 17:41:33.598368+00
7cf23d84-5036-4529-b7a6-f92733c04b37	5d19848f-34eb-48f2-8d0e-bff2658bb264	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	49.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 3" بباب روك	\N	2026-02-17 17:41:50.718026+00
ca80913e-d061-4e78-b0f7-427a0b69cdc1	71e6c269-0b0a-4ff3-95bd-a105988cdda0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	34.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | واي 3" روك	\N	2026-02-17 17:42:12.735868+00
cdb9f290-87ef-4c0a-9067-b4156b41cd63	150417bc-5700-4216-b3b2-8025ab306799	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	28.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1" BFS	\N	2026-02-17 16:17:16.570873+00
ee1a667a-04b6-467b-9e5c-8e8f75e1c989	7637f2f6-5553-4362-9abe-b79b9b211e66	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	39.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 2" اكوا روك	\N	2026-02-17 16:17:58.17133+00
6c317ed3-e37e-43e4-be6e-58d0ede78057	612e2397-4ece-4c57-a7f9-842843bed5be	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1.5" اكوا روك	\N	2026-02-17 16:19:05.506041+00
e0cfbc15-46f6-40d3-9826-f9c3b3b71d58	955997b7-2036-4f64-adf6-26ee55975902	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	46.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن خارجي 1.5 اكوا روك	\N	2026-02-17 16:21:11.874888+00
f5d38a69-cb9c-42c7-a386-775114da13d6	25786994-56ff-4a82-9b45-c8d30fc092c8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	91.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن داخلي 1*3/4"	\N	2026-02-17 16:22:12.169365+00
a9049ba3-fca3-482c-934f-e08530c1fb99	8f6beea1-072b-4f7d-9bc6-8591373b292e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	32.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 2" اكوا روك	\N	2026-02-17 16:24:05.394756+00
bef01d80-90d0-49ed-a162-1fcbe80568ac	3d6cff07-15a4-4c75-992d-ce195ec48a0c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	233.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1" اكوا روك	\N	2026-02-17 16:25:41.826927+00
67118e18-c803-4a68-bfa2-d1fd31591f97	d2a03983-48c8-42f0-8675-2b0aeec3e469	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	57.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن خارجي 1" كايرو ثيرم	\N	2026-02-17 16:26:24.833411+00
fa1000c0-3931-47dd-b972-106dd0d7eaa9	356ad760-f17e-4108-aa87-3f44b452fbd0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	129.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن خارجي 1" اكوا روك	\N	2026-02-17 16:27:24.738933+00
9b4e29e6-5ad2-4ddf-9e89-c0540315e07e	511fc549-b298-481f-ae1a-d0cc9b4dfe9d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	79.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 1.5" اكوا روك	\N	2026-02-17 16:28:24.929834+00
e614e2ae-a8d3-46aa-88d7-dd35a6f8de00	3fc85ed1-884e-4034-9ac6-2dd78c114a4b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	84.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1.5" اكوا روك	\N	2026-02-17 16:29:08.465047+00
d38d1499-0d3f-4ab6-9932-350e8f06f0b9	4c046095-bd35-4fe7-ba57-b3fe61d3b3b9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1.5" معزول BFS	\N	2026-02-17 16:30:14.513404+00
851d2f71-f60c-4126-8929-1b4396292daf	fb5099b2-64e9-452e-b4d6-2c3591a1b042	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	65.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي سن 1 * 1/2"	\N	2026-02-17 16:31:07.986514+00
299cba52-4c63-4dfe-bfb7-01a099372445	556f835a-5c2b-44a5-a3a2-086a96b984d3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن 1" اكوا روك	\N	2026-02-17 16:31:57.905305+00
c3843b3d-e9dc-426b-918d-e78dbe8ff4b5	2cc00c44-0fde-4eaf-9a50-927b79ab7097	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	208.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1" اكوا روك	\N	2026-02-17 16:33:34.561086+00
80f59174-8527-4782-9d8d-74f7cb386c2e	46051af4-1f3c-4cb8-8018-08c7158d73c4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	54.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 2" BFS	\N	2026-02-17 16:34:17.409953+00
738a1dd6-5b9c-48ba-b4a9-6796c9452dcf	762e3eca-4c16-438c-bde5-49aebf6d8be9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي لحام 1" BFS	\N	2026-02-17 16:35:01.264861+00
8511a12a-b65f-4331-be30-dbbc4dcd78f0	8f408e6d-5856-4378-a341-ef62648949ea	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 2" اكوا روك	\N	2026-02-17 16:35:32.866681+00
a98159ea-267e-4ece-947f-7a3e6c6982b3	6bacb56d-ae76-419f-93ce-564835dd276f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	129.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1.5" اكوا روك	\N	2026-02-17 16:36:26.161745+00
ddbf8f90-9934-4a15-86de-76c87b5b5178	50092680-cdcf-4383-8803-ec896ba51cb9	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	206.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 1" روك	\N	2026-02-17 16:37:15.041683+00
5a7b2694-054f-4915-bb27-95e45b7a62fe	d60038ee-8ce8-44e1-8e87-3e0e75660752	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	132.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 1*3/4" روك	\N	2026-02-17 16:39:37.13686+00
dbb24e93-65d5-4952-9424-8f1d08db626a	44a29ecc-7b57-44f8-9298-01d1a42f76d4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	386.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1" روك	\N	2026-02-17 16:40:24.241494+00
3906ba0e-c21e-4b8e-993f-94333eff9ed0	9f22d4f4-5c38-4ca7-9078-a9d451317a5f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	127.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 1*3/4 كايرو ثيرم	\N	2026-02-17 16:42:32.658476+00
25e6454f-d99b-4260-a4c2-077ffed56837	92a0b6e4-83c5-4abe-8dad-32bdf4c0df62	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 1" كايرو ثيرم	\N	2026-02-17 16:43:09.825812+00
ce3d45a4-f60f-4b5a-8ac2-b7a2dfbbed35	6416cbb3-ef5c-4b48-910c-e1f891054f13	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1.5 بوصة BFS	\N	2026-02-17 16:43:37.217406+00
16e462f1-6388-4b3b-b167-65bd98c440e1	9430efeb-9681-4466-b405-c11f7fd0411e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1.5" معزول اكوا جرين	\N	2026-02-17 16:44:19.088721+00
39900079-0c42-4424-8a40-03f2809154b7	3041ec21-6f51-4485-8515-b10a24942254	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	48.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي سن داخلي عادي 1" اكوا ستار	\N	2026-02-17 16:44:59.408798+00
963cf011-c666-45a0-a0d1-6875b165c425	753605cc-8cdb-4fa2-a0c3-174686ddedf4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	37.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي سن داخلي عالي 1" اكوا ستار	\N	2026-02-17 16:45:23.904255+00
562a1def-b25d-4b1a-9bde-2101e53c5f5f	a4924db4-ea93-4351-9379-4280a11f5b6f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	42.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع بسن داخلي 1*3/4" لافيستا	\N	2026-02-17 17:07:52.017481+00
7e4da84e-c704-4e55-8c52-194d7a5c89e7	51d95493-39bf-475c-9813-c22378608033	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	50.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 2" اكوا روك	\N	2026-02-17 17:08:23.232776+00
3af3ff09-317a-4feb-9186-e726b0a3b468	a42630ba-4abb-49ad-b469-7860b870c6bd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	178.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 2" BFS	\N	2026-02-17 17:17:27.78349+00
fe152df7-338a-4009-958d-ddc068dd0a18	81b8e587-43f6-4aa7-89f4-2a959a309ccd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	89.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تي محبس دفن 1*3/4	\N	2026-02-17 17:20:28.3524+00
343dd59e-580c-4d86-9847-87ef12966a82	bba112a6-5123-4eec-8359-ab2005280f18	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	36.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن خارجي 3/4 ستار ثيرم	\N	2026-02-17 17:22:52.6234+00
369c93e3-22ed-4723-aa9f-7a46a16c5e44	dc7a612e-4896-4e1b-992c-445b206f40f7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	70.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن داخلي 3/4 ستار ثيرم	\N	2026-02-17 17:23:34.527814+00
5add6009-34f2-4ffd-95cc-952a8975cf1e	3c49a84e-2451-459c-81a9-50577aa031ff	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 1" معزول BFS	\N	2026-02-17 17:24:27.167207+00
9898642d-6087-4f9a-9b39-66ffe1cc3cb7	5a108d5a-5cd0-4061-a61a-8487514cd407	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع لحام 1" معزول BFS	\N	2026-02-17 17:25:02.719521+00
121c682e-365d-4daa-b965-a9f74ea8d485	6aa50703-922e-4b64-a284-90ed8be49d64	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سن خارجي 2" روك	\N	2026-02-17 17:26:08.143744+00
6f65250c-188a-459e-b1e5-2733f0ee2912	ea4801eb-2031-4f2d-a875-16e122174ba1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك واي 4"	\N	2026-02-20 19:00:06.469912+00
87d8ff86-0d2d-4dca-a25e-f4f3cd76623b	27ae4b21-56ff-449e-bdc0-e3412e63d57c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	33.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4 على 2 بباب	\N	2026-02-20 19:00:37.78151+00
cb7c6a64-a4cd-4776-ac8b-1fc334a0e1cb	5a9a1c42-136b-45d4-93f1-0ca22ca48e21	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4 على 2 عادة	\N	2026-02-20 19:01:26.605874+00
060c38d5-e8d8-4f3a-b113-628fe81eddb9	53a965c4-ec9f-4331-8c09-7ae3eb11c2bc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4 على 3 بباب	\N	2026-02-20 19:03:19.581906+00
4b950e8b-ac31-44b3-bc8d-94cb7cc8972b	0b532dc7-1461-473d-a967-fca1cef3817c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام 6" 168	\N	2026-02-20 19:09:15.685113+00
8851a4c3-68a4-47c3-bbc7-d474859dd0a5	d886bc4f-a8d0-425d-8919-b03e171ca969	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة لحام  6" 160	\N	2026-02-20 19:10:13.045315+00
d43e6c38-eeae-484d-b167-229942c28c25	f3d9f278-2361-45dc-b5c3-9b12be2f20e8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 6" 160 بباب	\N	2026-02-20 19:10:38.32447+00
12be4140-cc15-4c80-aa41-40f5e0b7ad77	18ef625c-0276-44dd-890c-8917d875580e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 6" 168	\N	2026-02-20 19:11:15.28564+00
93659cfd-6d19-47da-b345-fe133375a96f	19df2fa4-493a-4977-9f28-df694c4fa19e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 6" عادة 160	\N	2026-02-20 19:11:29.877766+00
9218ec27-554f-44a3-a38b-bd361220e184	c48b78b3-b5bf-41f2-8a1e-dd3cb2497de6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	13.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع 6" بباب 168	\N	2026-02-20 19:11:42.548745+00
5c8d75c8-4a5f-4d48-b9c8-92a1b8f32ca0	9d9a0a7f-d9f6-4032-89ba-e04abc66217f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع 6" بوصة بباب 160	\N	2026-02-20 19:11:53.589739+00
5374ace2-6e71-4b1f-b144-1f4409e050ba	274c2b30-5c67-452d-8668-d0e04a0f3752	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع مفتوح 6"بباب 168	\N	2026-02-20 19:12:24.357203+00
9240fb9f-ee05-48ca-87e4-705a753f9bb8	d936244e-daa6-4f8e-a484-e8976bd04eb7	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	18.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4/2 عاده	\N	2026-02-21 21:11:53.080656+00
8398846d-4b46-4aef-b502-2730090482ab	f2dee181-2ff3-4ca5-a5eb-610dc49f5969	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4/3 باب	\N	2026-02-21 21:12:37.221354+00
4791e6ef-af73-4ef9-9ed1-54ff07429263	c3e347d9-49ce-471d-95b9-e53b8aef5a65	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	25.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4/3 عاده	\N	2026-02-21 21:13:39.109783+00
0fb9ac03-dc5d-419b-bc1d-127222f582b9	87d7c4ab-4a5e-4140-9b56-693d38a64a63	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبه لحام 6 بوصه168	\N	2026-02-21 21:17:12.917242+00
488e8909-5399-42d8-8dee-6a786b2bd3a1	a44e2af6-528b-4e34-9e0e-a8b4a4ab7198	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبه لحام 6 بوصه 160	\N	2026-02-21 21:17:53.237769+00
fd853681-0197-4199-9cc9-ea9bb2bfa77b	c8ed0258-b82f-46df-b1d5-a9cca14ff8fa	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 6 بوصه 168	\N	2026-02-21 21:18:37.299647+00
fb4e41e8-8dff-4aeb-8f9f-fac18ad3f51d	6deedd3b-0c5a-4535-b6e9-df2e2ae52399	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك باب 6 بوصه 160	\N	2026-02-21 21:19:32.292231+00
85edc03a-1692-46d1-8969-caf447777c55	b6cc78ec-f150-4350-90b6-f3ae1f4068d3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	8.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 6بوصه 160	\N	2026-02-21 21:20:26.886073+00
135579bb-cbb9-4781-b995-c3ac382c6f6b	1ce1c5c8-03bb-4f93-8e4c-84a6b69f386c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع باب 6 بوصه 168 روك	\N	2026-02-21 21:21:26.531987+00
0626465a-ba14-43c8-a473-2947c027d937	1587c12f-d8dc-40f5-8d22-d051af0287fd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع باب 6 بوصه 160 روك	\N	2026-02-21 21:22:21.540549+00
2f88b222-f3e3-496a-b755-484ce167e124	433f723b-d4d3-4dbe-9866-49c9fcd6c040	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع مفتوح 6 بوصه 168	\N	2026-02-21 21:23:01.828092+00
3159497b-c972-4fb1-a18c-0953b1f2b358	c973aa90-e274-4a13-bd63-fb0141d26fb5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع عاده 6 بوصه 168	\N	2026-02-21 21:23:38.899672+00
1b07183b-beb8-4ed5-9fb3-c20c2e9de6d7	429a54f9-6312-4e78-a0f0-3621129feb75	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	11.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع مفتوح 6 بوصه 160	\N	2026-02-21 21:24:14.886048+00
37b97998-990d-4d2d-b16f-039788f7741e	48272cca-653d-4506-b8fd-d5e3a4f1835f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 6/4 160*110	\N	2026-02-21 21:25:05.66843+00
264fb8eb-6e11-4c5e-a821-2cb2fa4df905	4e81ce7f-47a6-4813-ae27-30d0d1753051	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	3.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 6/4 168*114	\N	2026-02-21 21:25:54.564452+00
b8958468-c4fb-46c1-8625-4733ced770bb	125dffb9-8af1-4a61-b5b6-89d48a631935	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	9.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4/3BFS	\N	2026-02-21 21:26:58.852132+00
c4a7312d-bfad-41c0-b7c5-533d7fdc6228	c987d093-12be-452d-b2b7-bc0eebcf8389	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك باب 4/3 البحر الأحمر	\N	2026-02-21 21:28:06.131785+00
5099bd21-f28d-42a9-bc3d-349021b8ae5a	c7f3e93a-438f-480a-977a-4b1c03769984	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | صليبه 4/2 الأهرام	\N	2026-02-21 21:28:45.65167+00
1a65c329-e0cc-4e17-a585-1d2f5b86dad0	c1a296c0-6471-45fd-bb5e-5f91f68e77fd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبه لحام 4 بوصه روك	\N	2026-02-21 21:29:27.395828+00
14da727f-375a-4449-bcd0-af1bfd1fbd44	e8064580-f5a5-42d8-a083-bd3e3d3f4481	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	35.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبه اصلاح 4 بوصه روك	\N	2026-02-21 21:30:08.77231+00
e01d03e5-a138-4256-833f-8ef5038f7709	7bd70918-ce49-4b75-b72c-18154bd2f79a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	17.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | واى 4 بوصه	\N	2026-02-21 21:32:32.709138+00
c273646a-9885-448a-9c93-2a6d23eeee7b	0fe7c2a0-f60e-4f15-b284-2c8b1b12d7dc	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	26.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك باب 4/2	\N	2026-02-21 21:33:11.363362+00
7e40ac25-fcbb-4afc-b403-f329d17cd2cf	ec568ee9-0b5f-4dc4-a628-fd3f5fe9db4d	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	16.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4/2	\N	2026-02-21 21:33:51.187818+00
0b22c6b8-1e93-468c-974d-e15611d08986	de486650-4431-4dde-aa4d-4ce6be1554d8	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	21.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك باب 4/3	\N	2026-02-21 21:34:49.379716+00
aa058a4d-1f60-406f-b602-a025938b1a2b	e7cb2e9b-10a3-42a5-9c43-04f5fc233e88	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	22.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشترك 4/3	\N	2026-02-21 21:35:23.395697+00
e28467d1-50d5-4b4c-9a32-0d563c586a3a	3475e3b2-b002-47e6-88ee-85a33cd7f837	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	purchase	18.000	0.00	0.00	\N	\N	\N	\N	2026-02-25 22:17:49.398086+00
caf4be5e-f516-4ce8-9030-777feff6f3bb	e3ef3606-53ce-4847-a9ae-7357efdea79a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	31.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيجه سوسته تركى	\N	2026-02-25 23:14:04.662874+00
1b8aab3a-2fdb-48fe-ac6e-f37088f4843e	27e4b81d-9590-4576-b818-2a69da7afafd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	4.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مانيحه استالس	\N	2026-02-25 23:16:10.366716+00
cab6aa3a-c4bf-4824-96a9-40f421bf69f6	11ebff6a-eec6-4331-92fe-aac2c3373c9c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماكينه تركي	\N	2026-03-04 13:58:49.261182+00
98648ab9-d14e-418a-bcf5-4c1645034a0e	38e871be-2c5b-4e85-b0a6-f5c1eceb0b50	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماكينة ايديال	\N	2026-03-04 13:59:01.060385+00
e604de0c-fe8c-499b-8ec4-1aaaf7a181ff	4ee4ef31-bccf-4cf0-b768-53db7d80ea36	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | فلوماك صيني	\N	2026-03-04 13:55:21.374679+00
458a2843-49cf-4151-a40f-0c60b62d015d	65d744cb-8b17-49e8-b485-e114e01b9987	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	7.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | فلوماك ايطالي	\N	2026-03-04 13:58:06.724196+00
32d99fe5-bf95-4df4-bf0f-ed940859226a	db501a5e-8889-470a-abac-1aae9f62414b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | فلوماك كوباية	\N	2026-03-04 13:58:19.357574+00
3ff9bc74-cdf3-4419-bbba-6ac9418dcd3b	dd7fe2ec-0f4e-4de5-8f45-a7891f0bce59	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	6.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماتور ايطالي 1 حصان	\N	2026-03-04 13:45:50.975615+00
d7b0c59c-79e0-45d0-ad7a-1c94ab9f7612	f8dd4fea-855d-402a-8de3-c62d5dc51df0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماتور ايطالي 1/2 حصان	\N	2026-03-04 13:46:14.534908+00
f03761de-1b93-4bd0-a016-9fb12d55ec31	45f0395c-d566-4c2b-b586-3cd2d1d99f7b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	1.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | ماتور صيني 1/2 حصان	\N	2026-03-04 13:48:13.142898+00
decf5391-33c7-4b0b-a6b3-8355f4cc02e2	1bdf30f3-f488-4e03-a464-31e600a3c012	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	12.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط دش جولدن ايجل	\N	2026-03-04 13:59:26.741401+00
712bc2ff-4481-4f43-8938-d0d08ccd97bb	858d8c6c-94bc-4b7b-9bf6-f5aaf4cc7aca	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	purchase	133.000	0.00	0.00	\N	\N	\N	\N	2026-03-07 13:56:06.523837+00
166f65bc-f643-489c-a878-a8c4a314cdc9	a392d3d8-9dc7-4509-92c6-96e52892dc45	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	purchase	9.000	0.00	0.00	\N	\N	\N	\N	2026-03-07 14:21:10.436279+00
5742fefe-e8b0-43ad-8540-660b8c8e8258	543dae04-a219-44b2-a24c-8e663ec4c865	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	purchase	3.000	0.00	0.00	\N	\N	\N	\N	2026-03-07 14:21:10.44981+00
0f0f0c84-1dbc-4035-a930-80540d5060a4	982d6fa2-8c29-4580-863a-215600003c9b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	purchase	80.000	0.00	0.00	\N	\N	\N	\N	2026-03-08 17:36:55.129238+00
2440cbae-da5a-4f0a-8ff6-711c81410dd5	c3fa9713-cfff-4df1-a1be-e67923363d0a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	30.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خرطوم سوستة	\N	2026-03-10 00:59:41.182496+00
6b60ba2d-aadb-4e6d-ae68-f43e38cdfbb9	69c84270-5d73-406f-a0f6-4509aa6ffd14	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	15.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مشتمل دفن	\N	2026-03-10 00:59:53.495774+00
10735c34-984f-4f4a-ad6f-a0e08cc1dae4	5b317e75-8dcd-4ae8-8a1e-ee0de4afc793	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	2.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف 1.5"	\N	2026-03-10 01:01:03.95927+00
4cf2d539-fbc9-449e-bf2f-f1ec55655c2c	a2f62574-cda1-4f08-b38e-4cb5d32188b6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	10.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مجرى خرج مجوز	\N	2026-03-10 01:01:18.567212+00
8e52d3db-1950-45ce-9d76-7e6c5bef54ce	c5f83958-3304-4314-a56f-7fe15431bc7b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	50.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | كوع نزل	\N	2026-03-10 01:01:28.455547+00
081998c6-089c-40d5-9619-048edc8493ea	81f74c2a-1ec7-4771-9329-92b0d0eb7ddd	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف لاكور 3/4	\N	2026-03-10 01:01:52.695222+00
73a21f84-8634-422a-a43e-cc8ffded9d77	561a1696-03a7-4801-8efd-a117a2121f3b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	5.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | شيك بلف لاكور 1"	\N	2026-03-10 01:02:12.903167+00
4b9f697c-8dcd-4e8a-a69e-17f0fad2369a	92d27d2a-5f22-47c2-a167-4b6fc0908e3e	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حنفية بلية 1/2 فيدمار	\N	2026-03-15 16:46:04.748045+00
269871e4-9bb4-4543-9065-4d5227ca23fc	6c1a7601-4298-4f3f-be83-c3e4abdedaf4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | محبس زاوية	\N	2026-03-15 17:12:44.252251+00
b3466a8a-8e7f-4c76-b51b-aae433255f8b	309e1a4a-3b5b-4aba-a3f0-375f8bb26b69	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حله 0.5 مللي فيدمار ك	\N	2026-03-15 16:37:15.629092+00
b07aa422-5f8e-4d05-ac6b-808ed0409a7c	f9256353-ac61-4e15-8dff-4cad2591bda2	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حله 0.5 فيدمار ص	\N	2026-03-15 16:40:15.885174+00
88ba5e3d-2b8a-4de9-9e05-c52642f01886	35f48cd9-aa95-45dc-91f8-239baa9e8572	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حله 1 ملي فيدمار ص	\N	2026-03-15 16:42:33.251321+00
c1d8a9b9-873d-4f98-9600-f91f332f2588	ff573b1e-dc23-4f5c-b48b-ca3aa2ae1a1a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | حله 5 زرار فيدمار	\N	2026-03-15 16:47:55.014009+00
3100df49-0059-4f58-afd0-b6e11982859a	7ff32213-f0de-403c-a2b4-df7c66a07a1f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة تطويل استالس	\N	2026-03-15 17:00:35.852613+00
c65126d7-46d3-4693-af8f-baf099d2cf11	9eff5877-e547-41bf-980d-10c679112e9c	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة لوكس تكات	\N	2026-03-15 17:15:33.643842+00
e98280c2-2c95-4a4c-ad8b-3ef184baa350	1d1a007d-0b0d-40fe-9be0-7116cf80a675	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سماعة عادية	\N	2026-03-15 17:17:02.331845+00
8438920d-5dc4-4685-bc33-98fe02e433aa	980318ab-6084-4cf4-9ee7-b095ffcf96e6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | جلبة سوستة طويلة	\N	2026-03-15 17:21:28.131328+00
88934dd4-8c4b-4c87-9b5c-e7ad27bda73d	88420337-987a-48a0-a9db-fb0769395f8b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سخان 50 سم	\N	2026-03-15 17:27:24.635008+00
7d606218-5b23-45fd-96b4-95f54d641530	e529e2cf-83ac-4047-a94a-d0089030b1a4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة سخان 30 سم	\N	2026-03-15 17:28:34.179202+00
f90297a1-d752-40a5-bcb7-f58c434daa87	85be72d3-5d91-4bc1-8bc8-73b53c083490	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 70 سم	\N	2026-03-15 17:30:24.066428+00
5931e42e-0d5d-4b3d-ac14-8fed68744c79	200ed75f-470f-490a-9dbb-56886e13ecd0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 80 سم	\N	2026-03-15 17:32:35.923758+00
d1d69299-c826-48d9-a89e-80056be84a42	50d2a42b-4735-4fb8-924d-8d86cbdcd133	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سوستة 100 سم	\N	2026-03-15 17:33:50.515367+00
e114f630-25fe-43c3-94eb-16c6a76c3e08	43b85fea-b00f-4300-b4e2-48505f28e8c5	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تفلون شنطة ص	\N	2026-03-15 17:02:41.692515+00
3c3f7914-8fdb-48db-8ef2-ca64762b7b7d	79901430-1032-480c-b559-9ddc203f643f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | تفلون مضغوط (بوش)	\N	2026-03-15 17:04:59.620263+00
a5b59006-6ae6-4174-8e14-57e896055b21	1220b394-a688-46f9-a9c5-6c815cef43d0	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | زرار ضغط	\N	2026-03-15 16:58:42.15504+00
2738c2c5-e6be-4a7b-8d17-61a86512d999	33f55188-0fe1-4788-9809-3591288e60f3	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مكنة تربو	\N	2026-03-15 16:55:34.652521+00
8c271883-4bfe-4753-b2c8-c122c11fb5d6	6638cc77-52db-4850-8515-7336252846cf	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | مكنة ضغط نوفا	\N	2026-03-15 16:56:59.683521+00
695896e8-fad9-4c33-931b-463ba221f2c8	0c3f197e-b856-4f1f-b96f-fdb8e806da50	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون 3" ماليزي	\N	2026-03-15 17:09:04.979474+00
4c55873e-e9d9-4574-b446-de1f92742492	ec82ff6e-c170-46cd-8bf4-56341eb31632	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | سيفون رمادي 2"	\N	2026-03-15 17:36:40.441539+00
f3e3d503-6b6e-469b-be5a-c9bfce6af554	ecdbb38a-6d75-4400-85a5-3aab9d88372b	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط دوش اوكر	\N	2026-03-15 16:51:10.228907+00
c9fec15b-6538-4645-99cc-b79ae08b454a	9270a294-f2ee-4bf5-8871-ba778fc8e784	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | طقم خلاط اوكر	\N	2026-03-15 16:53:55.748347+00
28c9621f-fac5-47a5-bbc7-cc1316a26876	f12652f3-f3c6-43ae-8afa-04fafd701c2f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط شجرة استالس	\N	2026-03-15 17:06:36.203073+00
3b17c272-0b0d-4075-9c27-caa2f1d42e6d	a0bb2d53-4a9c-4d5f-bce9-69f0f7092fa4	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	opening_stock	14.000	0.00	0.00	\N	\N	رصيد افتتاحي — migration | خلاط 1/2 استالس مط	\N	2026-03-15 17:20:14.050966+00
2f5d2bed-3449-4e75-8cce-6b290f6c5f9c	ffa8d86a-6352-4d4c-a6f1-76622d09b032	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	5.000	0.00	0.00	\N	\N	\N	\N	2026-03-24 10:56:08.492442+00
327e8a9e-3435-447f-9a7d-f477bddf5043	4008a90d-eda0-4bc9-b7d9-0401c419b3e1	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	2.000	0.00	0.00	\N	\N	\N	\N	2026-03-24 10:56:08.506387+00
b887ecc5-01b9-4f4a-9b88-7a02724d2e15	313c6041-991c-4284-86ba-400fc94cb85f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	15.000	0.00	0.00	\N	\N	\N	\N	2026-03-24 11:28:36.765033+00
15cc041d-2c43-4603-8db0-9360ff6ced19	d8fa1a59-0a7c-4137-a9fb-d33d5b88dbf6	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	70.00	90.00	678a4d14-d028-4c24-a72f-0dbaa1bbb258	sale	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-29 17:18:55.672741+00
f46e0dac-45f8-4a34-8609-518cb5d1a58b	c8b78e53-a457-4b32-8897-c449f3fe1e4f	59a2b8d7-e26b-4979-ae0e-3984f1b711b2	purchase	5.000	10.00	0.00	362b6e0d-4f17-4662-875b-1e63005a2d44	purchase	\N	f00d039c-caa7-5b00-adba-365ed90c5f10	2026-03-30 04:16:18.96905+00
3403c02b-9561-49d6-a361-f4f4cf14ab05	b9b32325-fda4-46a7-b4f4-6da187863e4a	122f5b3b-9519-5b1e-a3fd-0ddacba7e157	sale	1.000	40.00	50.00	deec8934-2282-4a63-bff3-44e6123420fb	sale	\N	7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	2026-03-30 13:33:52.40389+00
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
contact_phones	[{"name": "مؤمن", "phone": "01065324979"}, {"name": "محمد", "phone": "01202456394"}, {"name": "مصطفى", "phone": "01145838183"}]	2026-03-30 13:19:59.968018+00
store_phone	01114439625	2026-03-30 13:20:25.505404+00
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
050bb5e5-f1a8-52e7-a072-eb46dd3fdbd0	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 1/2 بوصة	2026-03-25 18:13:41.323568+00
597bf33c-ec64-5dba-8ffb-445954664942	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 3/4 بوصة	2026-03-25 18:13:41.323568+00
46fb48bd-0b27-5fb8-998d-33101da799c7	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 1 بوصة	2026-03-25 18:13:41.323568+00
eb6d598d-dcc3-5828-a356-28415a27dd22	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 1 و 1/2 بوصة	2026-03-25 18:13:41.323568+00
b143c3c0-a8cb-5fbd-8e74-e70c87f6cc3c	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 2 بوصة	2026-03-25 18:13:41.323568+00
cf81d60b-63ae-5a62-90e4-459bc73ac29d	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 75 (3 بوصة)	2026-03-25 18:13:41.323568+00
fe7ccd42-3ac8-5504-9621-c389b607d815	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 90 (3 بوصة)	2026-03-25 18:13:41.323568+00
02ba0100-85cb-5329-8523-901c8e61094a	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 110 (4 بوصة)	2026-03-25 18:13:41.323568+00
1c6d6a22-9b90-5845-9ad6-3f5c216e4299	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 114 (4 بوصة)	2026-03-25 18:13:41.323568+00
9eefe542-d4a5-54e7-bd85-440d7bb6f89a	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 160 (6 بوصة)	2026-03-25 18:13:41.323568+00
0761f051-8fd3-5a6d-a1e1-fdb8f6969632	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 168 (6 بوصة)	2026-03-25 18:13:41.323568+00
e9ddb9d6-1470-54fc-9717-55e0f7c090ff	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 1/2 * 1/2	2026-03-25 18:13:41.323568+00
ef595fa0-5c9a-5c38-8754-d28adeb31b07	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 1/2 * 3/4	2026-03-25 18:13:41.323568+00
7b86f3e2-6483-5faf-9250-8c11f8248182	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 3/4 * 3/4	2026-03-25 18:13:41.323568+00
c68a8f63-9fef-523a-b558-3726b92c0af0	f9dd5401-59f7-539e-b5d3-dc0274ce1802	قطع 3/4 * 1/2	2026-03-25 18:13:41.323568+00
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
916e8dbf-c920-4cfd-a9af-f2f76d16417b	belal	بلال عادل	manager	$2b$12$1jNCIVungQKzbyT2G2ZUwepRtY/YfjINVvGpIL6MRIlYMF2.aPPQK	t	2026-03-28 16:24:44.334465+00	2026-03-28 16:30:56.440758+00	["pos", "inventory", "reports", "archive", "settings"]	f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
ee31f134-c885-42b4-950b-53284e09a25b	dalia	داليا السيد	cashier	$2b$12$oJ2IhJJN0W.UCbvYeCAa0.LU0OUgdApWUjDJdfHy39nT4Ek3aIOmK	t	2026-03-28 16:05:35.145099+00	2026-03-28 16:31:02.117895+00	["pos", "inventory", "reports", "archive", "settings"]	f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
f00d039c-caa7-5b00-adba-365ed90c5f10	ammar	عمار محمد السيد	admin	$2b$12$XqisxnWbwfVZOJjFhoKF6ejOzvTaJSNRx/iYHdT6oXQRBCkxpXgY.	t	2026-02-06 19:14:38.254017+00	2026-03-28 16:31:08.170784+00	["pos", "inventory", "reports", "archive", "settings", "users", "payroll", "admin", "operations", "quotations", "sales", "customers", "shifts"]	t	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
658196d5-857d-493c-94e4-e604b01764ab	habiba	حبيبة عماد	cashier	$2b$12$gm0QtHbMU5arX8DzXwxbaehHeKYW2J3/HEKNMJ148Dehn1I09nKES	t	2026-03-28 16:04:57.856624+00	2026-03-28 16:31:12.968001+00	["pos", "inventory", "reports", "archive", "settings"]	f	536e6eba-c111-4d60-b812-ead42ab23883
d17b4b23-b266-4f91-9091-fdbb6506a628	ibrahim	الشيخ ابراهيم	manager	$2b$12$rtudnLSoanWlYi2zpA8HhO8vzIz.lZUgJaRHs7JRWpNx/TT66qQL2	t	2026-03-28 16:32:18.850313+00	2026-03-28 16:34:32.060389+00	["pos", "inventory", "reports", "archive", "settings"]	f	536e6eba-c111-4d60-b812-ead42ab23883
7a04031f-e0fa-4c26-880c-a2b287929a8e	aldeeb	عبد اللطيف	cashier	$2b$12$1qp7yajq6gJzU6PzIKsmGuIvDlUk2ZU7trNkXzK6hh4gKr8wCTGwq	t	2026-03-28 16:35:26.487894+00	2026-03-28 16:35:34.477203+00	["pos", "inventory", "reports", "archive", "settings"]	f	59a2b8d7-e26b-4979-ae0e-3984f1b711b2
6a11d77b-24cc-577e-9ec3-4b0088eb7585	nada	ندا خالد احمد النجار	accountant	$2b$12$.gy6XGdVrk/SAC0lIa4fjOLc48r03Hq7Y8jDobCJOwdArkEFPDE.S	t	2026-02-28 16:21:52.170677+00	2026-03-29 15:10:50.279855+00	["pos", "inventory", "reports", "archive", "settings", "users", "payroll", "admin", "operations", "quotations", "sales", "customers", "shifts"]	t	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
7ef659d3-53f7-48b1-aca3-538ef5a1b3cd	alkok	احمد الكوك	manager	$2b$12$2PtWLZlbisP7z3MDpFS4sO.P6/eudl9aOgHzwu13kPwtP0IkyZJP6	t	2026-03-28 16:03:53.959822+00	2026-03-30 15:09:30.99527+00	["pos", "sales", "inventory", "archive"]	f	122f5b3b-9519-5b1e-a3fd-0ddacba7e157
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
536e6eba-c111-4d60-b812-ead42ab23883	R02	معرض العبور	t	2026-03-26 10:36:00.475856+00	showroom
cb6d74a5-2aab-473e-8acb-3b559fa4fea4	R03	معرض شارع ناصر	t	2026-03-26 10:36:27.904509+00	showroom
\.


--
-- Name: dispatch_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dispatch_seq', 1001, true);


--
-- Name: invoice_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoice_seq', 1027, true);


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
-- Name: idx_pph_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pph_product ON public.purchase_price_history USING btree (product_id);


--
-- Name: idx_sup_tx_supplier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sup_tx_supplier ON public.supplier_transactions USING btree (supplier_id);


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
-- PostgreSQL database dump complete
--

\unrestrict 81eVqdV4iSXUzMBJq2tQQpepS9oXZtzcIlfRa8rOz4jE31qjouOdte7uH2Ttgnp

