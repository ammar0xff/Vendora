
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('hr_payroll_periods', 'hr_payroll_entries', 'employees', 'payroll_periods', 'payroll_entries')
ORDER BY table_name, ordinal_position;
