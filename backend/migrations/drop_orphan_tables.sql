-- Drop legacy orphan tables (0 rows, superseded by hr_* tables)
-- payroll_entries → hr_payroll_entries, payroll_periods → hr_payroll_periods
-- NOTE: employees table kept because report_generator.py imports from legacy models.py
-- Idempotent: checks existence before dropping

DROP TABLE IF EXISTS payroll_entries CASCADE;
DROP TABLE IF EXISTS payroll_periods CASCADE;
