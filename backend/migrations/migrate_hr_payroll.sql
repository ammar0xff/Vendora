-- Migration: Migrate 18 rows from old flat hr_payroll to normalized tables
-- hr_payroll_periods (2 rows) + hr_payroll_entries (18 rows)
-- Then drop old hr_payroll table + its FK constraints
-- Idempotent: checks if migration already done

-- ─── 1. Create periods for each unique month ─────────────────────────────────
INSERT INTO hr_payroll_periods (month, status, created_at, updated_at)
SELECT DISTINCT month, 'draft', NOW(), NOW()
FROM hr_payroll
WHERE NOT EXISTS (
    SELECT 1 FROM hr_payroll_periods WHERE month = hr_payroll.month
);

-- ─── 2. Create entries for each old payroll row ───────────────────────────────
INSERT INTO hr_payroll_entries (id, period_id, employee_id, base_salary, bonuses, deductions, notes)
SELECT
    hp.id,
    hpp.id,
    hp.employee_id,
    hp.base_salary,
    COALESCE(hp.bonus, 0),
    COALESCE(hp.deductions, 0),
    hp.notes
FROM hr_payroll hp
JOIN hr_payroll_periods hpp ON hpp.month = hp.month
WHERE NOT EXISTS (
    SELECT 1 FROM hr_payroll_entries WHERE employee_id = hp.employee_id AND period_id = hpp.id
);

-- ─── 3. Drop old hr_payroll table and its FK constraints ──────────────────────
DROP TABLE IF EXISTS hr_payroll CASCADE;
