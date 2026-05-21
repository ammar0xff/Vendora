from datetime import datetime
from typing import List, Dict
from models import Employee, Attendance
import os

class ReportGenerator:
    @staticmethod
    def _format_time_12(s: str) -> str:
        if not s:
            return ''
        # Try ISO first
        try:
            dt = datetime.fromisoformat(s)
            return dt.strftime('%I:%M %p')
        except Exception:
            pass
        # Try common formats
        for fmt in ('%Y-%m-%d %H:%M:%S', '%Y-%m-%dT%H:%M:%S', '%Y-%m-%d %H:%M'):
            try:
                dt = datetime.strptime(s[:19], fmt)
                return dt.strftime('%I:%M %p')
            except Exception:
                continue
        # Fallback: return original
        return s

    @staticmethod
    def generate_payroll_report(employees_payroll: List[Dict], month: str = None) -> str:
        """Generate an HTML payroll report in landscape format with detailed totals"""
        if not month:
            month = datetime.now().strftime("%Y-%m")
        
        # Calculate comprehensive totals
        total_employees = len(employees_payroll)
        total_base_salary = sum(p['base_salary'] for p in employees_payroll)
        sum(p['working_days'] for p in employees_payroll)
        total_actual_days = sum(p.get('actual_working_days', p['working_days']) for p in employees_payroll)
        total_vacation_days = sum(p.get('vacation_days', 0) for p in employees_payroll)
        total_lateness_mins = sum(p['lateness_minutes'] for p in employees_payroll)
        total_early_leave_mins = sum(p.get('early_leave_minutes', 0) for p in employees_payroll)
        total_missing_scan_mins = sum(p.get('missing_scan_minutes', 0) for p in employees_payroll)
        total_lateness_deduction = sum(p['lateness_deduction'] for p in employees_payroll)
        total_advance = sum(p.get('advance', 0) for p in employees_payroll)
        total_overtime_hours = sum(p['overtime_hours'] for p in employees_payroll)
        total_overtime_payment = sum(p['overtime_payment'] for p in employees_payroll)
        total_bonus_payment = sum(p['bonus_payment'] for p in employees_payroll)
        total_other_bonus = sum(p['bonus'] for p in employees_payroll)
        total_deductions = sum(p['deduction'] for p in employees_payroll)
        total_final_salary = sum(p['final_salary'] for p in employees_payroll)
        
        html = f"""
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تقرير الرواتب الشهري - {month}</title>
    <style>
        :root {{
            --primary-color: #2c3e50;
            --accent-color: #3498db;
            --success-color: #27ae60;
            --warning-color: #e67e22;
            --danger-color: #c0392b;
            --bg-color: #f5f7fa;
        }}
        
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: #333;
            line-height: 1.6;
            padding: 20px;
        }}
        
        .container {{
            max-width: 100%;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            overflow: hidden;
        }}
        
        .header {{
            background: linear-gradient(135deg, var(--primary-color) 0%, #34495e 100%);
            color: white;
            padding: 25px 30px;
            text-align: center;
            border-bottom: 4px solid var(--accent-color);
        }}
        
        .header h1 {{
            margin-bottom: 8px;
            font-size: 2em;
            font-weight: 700;
        }}
        
        .header p {{
            font-size: 0.95em;
            opacity: 0.9;
        }}
        
        .summary {{
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 15px;
            padding: 20px 25px;
            background: #fff;
            border-bottom: 2px solid #eee;
        }}
        
        .summary-card {{
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            padding: 15px;
            border-radius: 8px;
            border-right: 3px solid var(--accent-color);
            text-align: center;
        }}
        
        .summary-card h3 {{
            font-size: 0.8em;
            color: #7f8c8d;
            margin-bottom: 8px;
            font-weight: 600;
        }}
        
        .summary-card .value {{
            font-size: 1.4em;
            font-weight: 700;
            color: var(--primary-color);
        }}
        
        .content {{
            padding: 20px 25px;
        }}
        
        table {{
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85em;
        }}
        
        thead {{
            background: var(--primary-color);
            color: white;
        }}
        
        th {{
            padding: 10px 8px;
            text-align: right;
            font-weight: 600;
            font-size: 0.9em;
            white-space: nowrap;
        }}
        
        td {{
            padding: 10px 8px;
            border-bottom: 1px solid #eee;
            text-align: right;
        }}
        
        tbody tr:hover {{
            background-color: #f8f9fa;
            transition: background-color 0.2s;
        }}
        
        tbody tr:nth-child(odd) {{
            background-color: #fff;
        }}
        
        tbody tr:nth-child(even) {{
            background-color: #f8f9fa;
        }}
        
        .salary-cell {{
            font-weight: 700;
            color: var(--success-color);
            font-size: 1.05em;
        }}
        
        .total-row {{
            background: linear-gradient(135deg, #34495e 0%, var(--primary-color) 100%) !important;
            color: white !important;
            font-weight: 700;
            font-size: 1.05em;
        }}
        
        .total-row td {{
            padding: 14px 8px;
            border-top: 3px solid var(--accent-color);
            border-bottom: 3px solid var(--accent-color);
        }}
        
        .footer {{
            background: #f8f9fa;
            padding: 15px;
            text-align: center;
            border-top: 1px solid #ecf0f1;
            color: #7f8c8d;
            font-size: 0.85em;
        }}
        
        .no-print {{
            text-align: left;
            padding: 15px 25px;
        }}
        
        .print-btn {{
            background: var(--primary-color);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            transition: background 0.3s;
        }}
        
        .print-btn:hover {{
            background: #34495e;
        }}
        
        @media print {{
            @page {{
                size: landscape;
                margin: 1cm;
            }}
            
            body {{
                background: white;
                padding: 0;
            }}
            
            .container {{
                box-shadow: none;
                width: 100%;
                max-width: none;
            }}
            
            .no-print {{
                display: none;
            }}
            
            table {{
                font-size: 0.75em;
            }}
            
            .header h1 {{
                font-size: 1.8em;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 تقرير الرواتب الشهري</h1>
            <p>الشهر: {month} | تاريخ الإنشاء: {datetime.now().strftime('%d/%m/%Y %I:%M %p')}</p>
        </div>
        
        <div class="summary">
            <div class="summary-card">
                <h3>عدد الموظفين</h3>
                <div class="value">{total_employees}</div>
            </div>
            <div class="summary-card">
                <h3>أيام العمل الفعلي</h3>
                <div class="value">{total_actual_days}</div>
            </div>
            <div class="summary-card">
                <h3>أيام الإجازات</h3>
                <div class="value" style="color: var(--accent-color);">{total_vacation_days}</div>
            </div>
            <div class="summary-card">
                <h3>إجمالي الرواتب الأساسية</h3>
                <div class="value">{total_base_salary:,.2f}</div>
            </div>
            <div class="summary-card special">
                <h3>صافي المستحقات</h3>
                <div class="value">{total_final_salary:,.2f}</div>
            </div>
        </div>
        
        <div class="content">
            <table>
                <thead>
                    <tr>
                        <th>الموظف</th>
                        <th>الراتب</th>
                        <th>أيام(فعلي)</th>
                        <th>إجازة</th>
                        <th>تأخير (د)</th>
                        <th>مبكر (د)</th>
                        <th>نسيان (د)</th>
                        <th>خصم تأخير</th>
                        <th>سلفية</th>
                        <th>إضافي (س)</th>
                        <th>مستحق إضافي</th>
                        <th>بونص أيام</th>
                        <th>مكافآت</th>
                        <th>خصومات</th>
                        <th>الصافي</th>
                    </tr>
                </thead>
                <tbody>
"""
        
        # Add employee rows
        for payroll in employees_payroll:
            # Format display values
            late_mins = payroll['lateness_minutes']
            late_display = str(late_mins) if late_mins > 0 else "-"
            
            early_mins = payroll.get('early_leave_minutes', 0)
            early_display = str(early_mins) if early_mins > 0 else "-"
            
            missing_scan = payroll.get('missing_scan_minutes', 0)
            missing_display = str(missing_scan) if missing_scan > 0 else "-"
            
            ot_hours = payroll['overtime_hours']
            ot_display = f"{ot_hours:.1f}" if ot_hours > 0 else "-"
            
            html += f"""
                    <tr>
                        <td><strong>{payroll['emp_name']}</strong><br><small>{payroll['emp_id']} - {payroll['position']}</small></td>
                        <td>{payroll['base_salary']:,.0f}</td>
                        <td style="background-color: #e8f5e9; font-weight: bold; text-align: center;">{payroll.get('actual_working_days', payroll['working_days'])}</td>
                        <td style="background-color: #e3f2fd; font-weight: bold; text-align: center;">{payroll.get('vacation_days', 0)}</td>
                        <td>{late_display}</td>
                        <td>{early_display}</td>
                        <td>{missing_display}</td>
                        <td style="color: var(--danger-color);">{payroll['lateness_deduction']:,.2f}</td>
                        <td>{payroll.get('advance', 0):,.2f}</td>
                        <td>{ot_display}</td>
                        <td style="color: var(--success-color);">{payroll['overtime_payment']:,.2f}</td>
                        <td>{payroll['bonus_payment']:,.2f}</td>
                        <td>{payroll['bonus']:,.2f}</td>
                        <td>{payroll['deduction']:,.2f}</td>
                        <td class="salary-cell">{payroll['final_salary']:,.2f}</td>
                    </tr>
"""
        
        # Add totals row
        total_ot_display = f"{total_overtime_hours:.1f}" if total_overtime_hours > 0 else "-"
        
        html += f"""
                    <tr class="total-row">
                        <td><strong>المجموع الكلي</strong></td>
                        <td><strong>{total_base_salary:,.0f}</strong></td>
                        <td style="text-align: center;"><strong>{total_actual_days}</strong></td>
                        <td style="text-align: center;"><strong>{total_vacation_days}</strong></td>
                        <td><strong>{total_lateness_mins if total_lateness_mins > 0 else '-'}</strong></td>
                        <td><strong>{total_early_leave_mins if total_early_leave_mins > 0 else '-'}</strong></td>
                        <td><strong>{total_missing_scan_mins if total_missing_scan_mins > 0 else '-'}</strong></td>
                        <td><strong>{total_lateness_deduction:,.2f}</strong></td>
                        <td><strong>{total_advance:,.2f}</strong></td>
                        <td><strong>{total_ot_display}</strong></td>
                        <td><strong>{total_overtime_payment:,.2f}</strong></td>
                        <td><strong>{total_bonus_payment:,.2f}</strong></td>
                        <td><strong>{total_other_bonus:,.2f}</strong></td>
                        <td><strong>{total_deductions:,.2f}</strong></td>
                        <td class="salary-cell"><strong>{total_final_salary:,.2f}</strong></td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <div class="footer">
            <p>هذا التقرير تم إنشاؤه بواسطة نظام إدارة الموارد البشرية والرواتب</p>
            <p>© 2026 جميع الحقوق محفوظة</p>
        </div>
    </div>
    
    <div class="no-print">
        <button class="print-btn" onclick="window.print()">🖨️ طباعة التقرير / PDF</button>
    </div>
</body>
</html>
"""
        return html
    
    @staticmethod
    def generate_employee_report(employee: Employee, attendances: List[Attendance], payroll: Dict, sections: List[str] = None, finances: List[Dict] = None) -> str:
        """Generate an individual employee report.
        sections: list of sections to include ('info', 'calc', 'summary', 'breakdown', 'attendance'). 
                  If None, include all.
        finances: list of finance records (advances/bonuses/deductions) to show item by item.
        """
        if sections is None:
            sections = ['info', 'calc', 'summary', 'breakdown', 'attendance']
        if finances is None:
            finances = []
        
        # Helper to safely format numbers
        def fmt(val, decimals=2):
            try:
                return f"{float(val):,.{decimals}f}"
            except Exception:
                return "0.00"

        # Prepare sections HTML to avoid nested f-string complexity
        html_info = ""
        if 'info' in sections:
            html_info = f"""
        <div class="grid-info">
            <div class="info-card">
                <div class="info-label">الموظف</div>
                <div class="info-value">{employee.name}</div>
            </div>
            <div class="info-card">
                <div class="info-label">الرقم الوظيفي</div>
                <div class="info-value">{employee.emp_id}</div>
            </div>
             <div class="info-card">
                <div class="info-label">المناوبة</div>
                <div class="info-value">{employee.shift}</div>
            </div>
            <div class="info-card">
                <div class="info-label">الراتب الأساسي التعاقدي</div>
                <div class="info-value">{fmt(payroll['base_salary'])}</div>
            </div>
        </div>
"""

        html_calc = ""
        if 'calc' in sections:
            html_calc = f"""
        <div class="section">
            <h2 class="section-title"><span>1</span> أسس الحساب (Calculation Factors)</h2>
            <div class="grid-info" style="background: transparent; padding: 0;">
                <div class="info-card">
                    <div class="info-label">أيام العمل المطلوبة</div>
                    <div class="info-value">
                        {fmt(payroll.get('effective_days_in_month', 26))} يوم
                    </div>
                </div>
                <div class="info-card">
                    <div class="info-label">ساعات المناوبة</div>
                    <div class="info-value">{payroll.get('shift_length', 0)} ساعات</div>
                </div>
                <div class="info-card">
                    <div class="info-label">إجمالي الساعات المطلوبة</div>
                    <div class="info-value">{fmt(payroll['scheduled_month_hours'])} ساعة</div>
                    <div class="formula">{fmt(payroll.get('effective_days_in_month', 26))} × {payroll.get('shift_length', 0)}</div>
                </div>
                <div class="info-card">
                <div class="info-label">استثناء من التأخير</div>
                <div class="info-value">{"نعم (تجاهل)" if employee.ignore_lateness else "لا (محسوب)"}</div>
            </div>
            <div class="info-card">
                <div class="info-label">سعر الساعة الأساسي</div>
                    <div class="info-value">{fmt(payroll['hourly_rate'], 4)}</div>
                    <div class="formula">الراتب / الساعات المطلوبة</div>
                </div>
            </div>
        </div>
"""

        html_summary = ""
        if 'summary' in sections:
            html_summary = f"""
        <div class="section">
            <h2 class="section-title"><span>2</span> ملخص الدوام والعمليات</h2>
            <table style="width: 100%;">
                <tr>
                    <td>أيام العمل الفعلي: <strong>{payroll.get('actual_working_days', payroll['working_days'])}</strong></td>
                    <td>أيام الإجازات: <strong>{payroll.get('vacation_days', 0)}</strong></td>
                    <td>ساعات العمل الفعلية: <strong>{fmt(payroll.get('normal_hours_worked', 0))}</strong></td>
                    <td>إضافي: <strong>{fmt(payroll['overtime_hours'])}</strong></td>
                </tr>
                <tr>
                    <td>تأخير: <strong style="color: var(--danger-color);">{payroll['lateness_minutes']}</strong> د</td>
                    <td>انصراف مبكر: <strong style="color: var(--warning-color);">{payroll.get('early_leave_minutes', 0)}</strong> د</td>
                    <td>أيام البونص: <strong style="color: var(--success-color);">{payroll['bonus_days']}</strong></td>
                    <td></td>
                </tr>
            </table>
        </div>
"""

        html_breakdown = ""
        if 'breakdown' in sections:
            # Build individual finance item rows
            bonus_items   = [f for f in finances if f.get('type') == 'مكافأة']
            deduct_items  = [f for f in finances if f.get('type') == 'خصم']
            advance_items = [f for f in finances if f.get('type') == 'سلفة']

            # Generate rows for bonuses
            bonus_rows_html = ""
            for item in bonus_items:
                note = item.get('note', '') or '-'
                dt   = item.get('date', '')
                bonus_rows_html += f"""
                    <tr class="calc-row" style="background-color:#f0fff0;">
                        <td>مكافأة <div class="info-label">{dt} {f'| {note}' if note != '-' else ''}</div></td>
                        <td>-</td>
                        <td class="amount-positive">+{fmt(item.get('amount', 0))}</td>
                    </tr>"""
            if not bonus_rows_html:
                bonus_rows_html = f"""
                    <tr class="calc-row">
                        <td>مكافآت أخرى</td><td>-</td>
                        <td class="amount-positive">+{fmt(payroll['bonus'])}</td>
                    </tr>"""

            # Generate rows for deductions
            deduct_rows_html = ""
            for item in deduct_items:
                note = item.get('note', '') or '-'
                dt   = item.get('date', '')
                deduct_rows_html += f"""
                    <tr class="calc-row" style="background-color:#fff5f5;">
                        <td>خصم إداري <div class="info-label">{dt} {f'| {note}' if note != '-' else ''}</div></td>
                        <td>-</td>
                        <td class="amount-negative">-{fmt(item.get('amount', 0))}</td>
                    </tr>"""
            if not deduct_rows_html:
                deduct_rows_html = f"""
                    <tr class="calc-row">
                        <td>خصومات إدارية / جزاءات</td><td>-</td>
                        <td class="amount-negative">-{fmt(payroll['deduction'])}</td>
                    </tr>"""

            # Generate rows for advances
            advance_rows_html = ""
            for item in advance_items:
                note = item.get('note', '') or '-'
                dt   = item.get('date', '')
                advance_rows_html += f"""
                    <tr class="calc-row" style="background-color:#fffbe6;">
                        <td>سلفة <div class="info-label">{dt} {f'| {note}' if note != '-' else ''}</div></td>
                        <td>-</td>
                        <td class="amount-negative">-{fmt(item.get('amount', 0))}</td>
                    </tr>"""
            if not advance_rows_html:
                advance_rows_html = f"""
                    <tr class="calc-row">
                        <td>سلف مسحوبة</td><td>-</td>
                        <td class="amount-negative">-{fmt(payroll.get('advance', 0))}</td>
                    </tr>"""

            html_breakdown = f"""
        <div class="section">
            <h2 class="section-title"><span>3</span> تفاصيل الاستحقاقات والاستقطاعات</h2>
            <table>
                <thead>
                    <tr>
                        <th style="width: 40%">البند</th>
                        <th style="width: 35%">طريقة الحساب / المعادلة</th>
                        <th style="width: 25%">القيمة</th>
                    </tr>
                </thead>
                <tbody>
                    <tr class="calc-row">
                        <td>
                            الراتب المستحق عن ساعات العمل
                            <div class="info-label">يتم احتسابه بناءً على الساعات الفعلية ضمن الدوام الرسمي</div>
                        </td>
                        <td>
                            <div class="formula">
                                {fmt(payroll.get('normal_hours_worked', 0))} ساعة عمل × ({fmt(payroll['base_salary'])} ÷ {fmt(payroll['scheduled_month_hours'])})<br>
                                = ساعات العمل الفعلية × نسبة الراتب
                            </div>
                        </td>
                        <td class="amount-positive">{fmt(payroll.get('base_pay_prorated', 0))}</td>
                    </tr>
                    
                    <tr class="calc-row">
                        <td>
                            مستحقات العمل الإضافي
                            <div class="info-label">ساعات العمل خارج أوقات الدوام الرسمي</div>
                        </td>
                        <td>
                            <div class="formula">
                                {fmt(payroll['overtime_hours'])} ساعة × {fmt(payroll['hourly_rate'], 4)} سعر الساعة
                            </div>
                        </td>
                        <td class="amount-positive">+{fmt(payroll['overtime_payment'])}</td>
                    </tr>
                    
                    <tr class="calc-row">
                        <td>
                            مكافآت أيام البونص
                            <div class="info-label">أيام عمل إضافية فوق الـ 26 يوم</div>
                        </td>
                        <td>
                            <div class="formula">
                                {payroll['bonus_days']} يوم × {payroll.get('shift_length', 0)} ساعات × {fmt(payroll['hourly_rate'], 4)}
                            </div>
                        </td>
                        <td class="amount-positive">+{fmt(payroll['bonus_payment'])}</td>
                    </tr>

                    {bonus_rows_html}

                    <tr class="calc-row">
                        <td>
                            خصم التأخير (مضاعف)
                            {"<br><small style='color:green'>(مستثنى بناءً على إعدادات الموظف)</small>" if employee.ignore_lateness else ""}
                        </td>
                        <td>
                            <div class="formula">
                                {payroll['lateness_minutes']} د ÷ 60 × {fmt(payroll.get('late_penalty_multiplier', 2))} × {fmt(payroll['hourly_rate'], 4)}
                            </div>
                        </td>
                        <td class="amount-negative">-{fmt( (payroll['lateness_minutes'] / 60) * payroll.get('late_penalty_multiplier', 2) * payroll['hourly_rate'] )}</td>
                    </tr>
                    
                    <tr class="calc-row">
                        <td>خصم الانصراف المبكر</td>
                        <td>
                            <div class="formula">
                                {payroll.get('early_leave_minutes', 0)} د ÷ 60 × 1 × {fmt(payroll['hourly_rate'], 4)}
                            </div>
                        </td>
                        <td class="amount-negative">-{fmt( (payroll.get('early_leave_minutes', 0) / 60) * payroll['hourly_rate'] )}</td>
                    </tr>

                    <tr class="calc-row">
                        <td>خصم نسيان البصمة</td>
                        <td>
                            <div class="formula">
                                {payroll.get('missing_scan_minutes', 0)} د ÷ 60 × 1 × {fmt(payroll['hourly_rate'], 4)}
                            </div>
                        </td>
                        <td class="amount-negative">-{fmt( (payroll.get('missing_scan_minutes', 0) / 60) * payroll['hourly_rate'] )}</td>
                    </tr>

                    <tr class="calc-row" style="background-color: #f9f9f9; font-weight: bold;">
                        <td>إجمالي خصومات الحضور</td>
                        <td>
                            <div class="formula">مجموع الخصومات أعلاه</div>
                        </td>
                        <td class="amount-negative">-{fmt(payroll['lateness_deduction'])}</td>
                    </tr>

                    {deduct_rows_html}

                    {advance_rows_html}
                    
                    <tr class="total-row">
                        <td colspan="2">صــــافي الراتـــــب النهائي</td>
                        <td style="direction: ltr; text-align: right;">{fmt(payroll['final_salary'])} EGP</td>
                    </tr>
                </tbody>
            </table>
        </div>
"""

        html_attendance = ""
        if 'attendance' in sections:
            rows_html = ""
            daily = payroll.get('daily', [])
            for d in sorted(daily, key=lambda x: x.get('date') or ''):
                if not d.get('date'):
                    continue
                date_str = datetime.fromisoformat(d.get('date')).strftime('%Y-%m-%d')
                
                status_raw = d.get('status', 'regular')
                status_map = {
                    'regular': 'عمل عادي',
                    'leave': '<span style="color:var(--success-color); font-weight:bold;">إجازة</span>',
                    'mission': '<span style="color:var(--warning-color); font-weight:bold;">مأمورية</span>',
                    'excuse': '<span style="color:var(--accent-color);">عذر</span>',
                    'absent': '<span style="color:var(--danger-color); font-weight:bold;">غياب</span>',
                    'pre-hire': '<span style="color:#7f8c8d;">قبل التعيين</span>'
                }
                status_display = status_map.get(status_raw, status_raw)

                time_in = ReportGenerator._format_time_12(d.get('check_in')) if d.get('check_in') else '-'
                time_out = ReportGenerator._format_time_12(d.get('check_out')) if d.get('check_out') else '-'
                
                # Late minutes display
                late_mins = int(d.get('late_minutes', 0))
                if late_mins > 0:
                    late_display = f"<span style='color:red'>{late_mins}</span>"
                else:
                    late_display = "-"
                
                # Overtime display
                ot_hours = float(d.get('overtime_hours', 0))
                if ot_hours > 0:
                    ot_display = f"<span style='color:green; font-weight:bold'>{ot_hours:.2f}</span>"
                else:
                    ot_display = "-"

                # Early leave display
                early_mins = int(d.get('early_minutes', 0))
                if early_mins > 0:
                    early_display = f"<span style='color:orange'>{early_mins}</span>"
                else:
                    early_display = "-"
                
                rows_html += f"""
                        <tr>
                            <td>{date_str}</td>
                            <td>{status_display}</td>
                            <td>{time_in}</td>
                            <td>{time_out}</td>
                            <td>{d.get('work_hours', 0):.2f}</td>
                            <td>{late_display}</td>
                            <td>{early_display}</td>
                            <td>{ot_display}</td>
                            <td style="font-size: 0.8em; color: #666;">{d.get('note', '')}</td>
                        </tr>
                """
            
            html_attendance = f"""
            <div class="section">
                <h2 class="section-title"><span>4</span> تفاصيل الحضور اليومي</h2>
                <table class="attendance-table">
                    <thead>
                        <tr>
                            <th>التاريخ</th>
                            <th>الحالة</th>
                            <th>الدخول</th>
                            <th>الخروج</th>
                            <th>ساعات العمل</th>
                            <th>تأخير (د)</th>
                            <th>مبكر (د)</th>
                            <th>إضافي (ساعة)</th>
                            <th>ملاحظات</th>
                        </tr>
                    </thead>
                    <tbody>
                        {rows_html}
                    </tbody>
                </table>
            </div>
            """

        html = f"""
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تقرير تفصيلي - {employee.name}</title>
    <style>
        :root {{
            --primary-color: #2c3e50;
            --accent-color: #3498db;
            --success-color: #27ae60;
            --warning-color: #e67e22;
            --danger-color: #c0392b;
            --bg-color: #f5f7fa;
        }}
        
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: #333;
            line-height: 1.6;
            padding: 20px;
        }}
        
        .container {{
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            overflow: hidden;
        }}
        
        .header {{
            background: linear-gradient(135deg, var(--primary-color) 0%, #34495e 100%);
            color: white;
            padding: 30px;
            text-align: center;
            border-bottom: 4px solid var(--accent-color);
        }}
        
        .header h1 {{
            margin-bottom: 10px;
            font-size: 2.2em;
        }}
        
        .grid-info {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 25px;
            background: #fff;
            border-bottom: 1px solid #eee;
        }}
        
        .info-card {{
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border-right: 3px solid var(--accent-color);
        }}
        
        .info-label {{
            font-size: 0.85em;
            color: #7f8c8d;
            margin-bottom: 5px;
        }}
        
        .info-value {{
            font-size: 1.2em;
            font-weight: 600;
            color: var(--primary-color);
        }}
        
        .section {{
            padding: 25px;
            border-bottom: 1px solid #eee;
        }}
        
        .section-title {{
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            color: var(--primary-color);
            font-size: 1.4em;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }}
        
        .section-title span {{
            background: var(--accent-color);
            color: white;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            margin-left: 10px;
            font-size: 0.8em;
        }}

        table {{
            width: 100%;
            border-collapse: collapse;
            font-size: 0.95em;
        }}
        
        th {{
            background: var(--primary-color);
            color: white;
            padding: 12px;
            text-align: right;
            font-weight: 500;
        }}
        
        td {{
            padding: 12px;
            border-bottom: 1px solid #eee;
            vertical-align: middle;
        }}
        
        tr:last-child td {{
            border-bottom: none;
        }}
        
        .calc-row {{
            background-color: #fff;
        }}
        
        .calc-row:hover {{
            background-color: #f8f9fa;
        }}
        
        .formula {{
            color: #7f8c8d;
            font-size: 0.85em;
            font-family: Consolas, monospace;
            display: block;
            margin-top: 4px;
        }}
        
        .amount-positive {{
            color: var(--success-color);
            font-weight: 600;
        }}
        
        .amount-negative {{
            color: var(--danger-color);
            font-weight: 600;
        }}
        
        .total-row td {{
            background: var(--primary-color);
            color: white;
            font-size: 1.2em;
            font-weight: bold;
        }}
        
        .attendance-table th {{
            background: #34495e;
        }}
        
        .attendance-table tr:nth-child(even) {{
            background: #f8f9fa;
        }}

        @media print {{
            body {{
                background: white;
                padding: 0;
            }}
            .container {{
                box-shadow: none;
                width: 100%;
                max-width: none;
            }}
             .no-print {{
                display: none;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>كشف راتب تفصيلي</h1>
            <p>{employee.name} | {datetime.now().strftime('%B %Y')}</p>
        </div>
        
        {html_info}

        <!-- Calculation Bases -->
        {html_calc}

        <!-- Work Summary -->
        {html_summary}

        <!-- Detailed Breakdown -->
        {html_breakdown}
        
        <div class="section no-print" style="text-align: left;">
            <button onclick="window.print()" style="background: var(--primary-color); color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-size: 1em;">
                🖨️ طباعة التقرير / PDF
            </button>
        </div>

        <!-- Attendance Detail -->
         {html_attendance}
    </div>
</body>
</html>
"""
        return html

    @staticmethod
    def generate_payslip_ticket(employee: Employee, payroll: Dict, finances: List[Dict] = None) -> str:
        """Generate a compact, beautiful receipt/ticket style payslip."""
        if finances is None:
            finances = []

        def fmt(val):
            try:
                return f"{float(val):,.2f}"
            except Exception:
                return "0.00"

        def fmti(val):
            try:
                v = float(val)
                return f"{int(v):,}" if v == int(v) else f"{v:,.2f}"
            except Exception:
                return "0"

        # ── Categorise finance records ──────────────────────────────────
        bonus_items   = [f for f in finances if f.get('type') == 'مكافأة']
        deduct_items  = [f for f in finances if f.get('type') == 'خصم']
        advance_items = [f for f in finances if f.get('type') == 'سلفة']

        # ── Row builders that use <table> so text never breaks mid-word ─
        def earn_row(label, amount, sub=''):
            sub_html = f'<br><small class="sub">{sub}</small>' if sub else ''
            return (f'<tr class="earn">'
                    f'<td class="lbl">{label}{sub_html}</td>'
                    f'<td class="amt earn-c">+&nbsp;{fmt(amount)}</td>'
                    f'</tr>')

        def ded_row(label, amount, sub='', cls='ded-c'):
            sub_html = f'<br><small class="sub">{sub}</small>' if sub else ''
            return (f'<tr class="ded">'
                    f'<td class="lbl">{label}{sub_html}</td>'
                    f'<td class="amt {cls}">-&nbsp;{fmt(amount)}</td>'
                    f'</tr>')

        def S(title, bg):
            return f'<tr><td colspan="2" class="sh" style="background:{bg}">{title}</td></tr>'

        rows = ''

        # Earnings
        rows += S('▲ المستحقات', '#1e5fa8')
        rows += earn_row('الراتب الأساسي', payroll['base_salary'])
        ot = payroll.get('overtime_payment', 0)
        bp = payroll.get('bonus_payment', 0)
        if ot > 0:
            rows += earn_row('عمل إضافي', ot, f"{fmt(payroll.get('overtime_hours', 0))} ساعة")
        if bp > 0:
            rows += earn_row('بونص أيام', bp, f"{fmti(payroll.get('bonus_days', 0))} يوم")
        if bonus_items:
            for item in bonus_items:
                sub = ' | '.join(filter(None, [item.get('date', '')[:10], item.get('note', '')]))
                rows += earn_row('مكافأة', item.get('amount', 0), sub)
        elif payroll.get('bonus', 0) > 0:
            rows += earn_row('مكافآت', payroll['bonus'])

        # Deductions
        rows += S('▼ الاستقطاعات', '#9b1c1c')
        if payroll.get('lateness_deduction', 0) > 0:
            rows += ded_row('خصم تأخير', payroll['lateness_deduction'],
                            f"{fmti(payroll.get('lateness_minutes', 0))} دقيقة")
        if deduct_items:
            for item in deduct_items:
                sub = ' | '.join(filter(None, [item.get('date', '')[:10], item.get('note', '')]))
                rows += ded_row('خصم إداري', item.get('amount', 0), sub)
        elif payroll.get('deduction', 0) > 0:
            rows += ded_row('خصومات', payroll['deduction'])
        if advance_items:
            for item in advance_items:
                sub = ' | '.join(filter(None, [item.get('date', '')[:10], item.get('note', '')]))
                rows += ded_row('سلفة', item.get('amount', 0), sub, cls='adv-c')
        elif payroll.get('advance', 0) > 0:
            rows += ded_row('سُلف', payroll.get('advance', 0), cls='adv-c')

        # Attendance bar
        att_days = payroll.get('actual_working_days', payroll.get('working_days', 0))
        vac_days = payroll.get('vacation_days', 0)
        ot_h     = payroll.get('overtime_hours', 0)
        parts = [f"حضور <b>{fmti(att_days)}</b> يوم"]
        if vac_days:
            parts.append(f"إجازة <b>{fmti(vac_days)}</b>")
        if ot_h:
            parts.append(f"إضافي <b>{fmt(ot_h)}</b> س")
        att_bar_html = '&nbsp;&nbsp;·&nbsp;&nbsp;'.join(parts)

        now_str   = datetime.now().strftime('%d / %m / %Y')
        month_str = datetime.now().strftime('%Y·%m')

        html = f"""\
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
<title>إيصال راتب – {employee.name}</title>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{
  font-family:'Cairo','Segoe UI',Tahoma,sans-serif;
  background:#d8dfe8;
  min-height:100vh;
  display:flex;flex-direction:column;
  align-items:center;
  padding:28px 16px;
}}
/* ── Card ── */
.card{{
  background:#fff;
  width:min(380px,96vw);
  border-radius:16px;
  box-shadow:0 12px 40px rgba(0,0,0,.22),0 2px 8px rgba(0,0,0,.10);
  overflow:hidden;
  position:relative;
}}
/* side notch cuts */
.card::before,.card::after{{
  content:'';position:absolute;
  width:26px;height:26px;background:#d8dfe8;
  border-radius:50%;
  bottom:118px;z-index:4;
}}
.card::before{{right:-13px}}
.card::after{{left:-13px}}
/* ── Header ── */
.hdr{{
  background:linear-gradient(135deg,#0f2d5e 0%,#1e5fa8 55%,#3b82c4 100%);
  color:#fff;text-align:center;
  padding:22px 20px 16px;
}}
.hdr .ico{{font-size:2.2em;line-height:1;margin-bottom:4px}}
.hdr h1{{font-size:1.22em;font-weight:900;letter-spacing:.05em;margin-bottom:3px}}
.hdr .mo{{font-size:.84em;opacity:.82;font-weight:600;letter-spacing:.08em}}
/* ── Employee strip ── */
.emp{{
  background:#eef3fb;
  border-bottom:2px dashed #b8cce0;
  padding:10px 18px;
}}
.emp table{{width:100%;border-collapse:collapse}}
.emp td{{padding:0;vertical-align:middle;line-height:1.35}}
.emp .nm{{font-weight:800;color:#0f2d5e;font-size:1.0em}}
.emp .id{{color:#7a8fa8;font-size:.78em}}
.emp .ps{{color:#444;font-size:.82em;font-weight:600;text-align:left}}
/* ── Attendance bar ── */
.att{{
  background:#0f2d5e;color:#c5d9f5;
  font-size:.76em;text-align:center;
  padding:5px 14px;font-weight:600;
  letter-spacing:.03em;
}}
/* ── Main rows table ── */
.body{{padding:0 0 4px}}
.body table{{width:100%;border-collapse:collapse;font-size:.87em}}
.body td{{
  padding:7px 17px;
  vertical-align:top;
  line-height:1.45;
}}
.lbl{{text-align:right;color:#2d3748;width:63%;word-break:break-word}}
.amt{{
  text-align:left;font-weight:700;
  white-space:nowrap;width:37%;
  font-size:.93em;padding-left:14px;
}}
.earn-c{{color:#14532d}}
.ded-c{{color:#7f1d1d}}
.adv-c{{color:#713f12}}
.earn td{{background:#f0fff6;border-bottom:1px solid #dcfce7}}
.ded  td{{background:#fff5f5;border-bottom:1px solid #fecaca}}
.sh{{
  font-weight:800;font-size:.74em;color:#fff;
  letter-spacing:.10em;text-align:center;padding:5px 16px;
}}
.sub{{color:#888;font-size:.78em}}
/* ── Dashed perforated line ── */
.perf{{border:none;border-top:2px dashed #b8cce0;margin:0 16px}}
/* ── Total ── */
.total{{
  background:linear-gradient(135deg,#0f2d5e,#1e5fa8);
  color:#fff;
  padding:15px 20px;
  display:flex;justify-content:space-between;align-items:center;
}}
.total .tl{{font-size:1.0em;font-weight:800;letter-spacing:.04em}}
.total .tv{{font-size:1.32em;font-weight:900}}
.total .tc{{font-size:.62em;opacity:.8;margin-right:4px;font-weight:600}}
/* ── Footer ── */
.ftr{{
  text-align:center;font-size:.74em;color:#8a9ab0;
  padding:10px 18px 16px;
}}
.bar{{font-size:2.4em;letter-spacing:-3px;color:#c4ccd8;margin:5px 0 3px;user-select:none}}
.sig{{
  display:inline-block;width:74%;
  border-top:1px solid #dde;padding-top:5px;
  margin-top:5px;letter-spacing:.06em;color:#aab;font-size:.95em;
}}
/* ── Print button ── */
.no-print{{margin-top:22px;text-align:center}}
.pbtn{{
  font-family:inherit;
  background:linear-gradient(135deg,#0f2d5e,#1e5fa8);
  color:#fff;border:none;
  padding:12px 40px;border-radius:50px;
  font-size:1.0em;font-weight:800;
  cursor:pointer;
  box-shadow:0 5px 18px rgba(30,95,168,.38);
  transition:transform .14s,box-shadow .14s;
  letter-spacing:.04em;
}}
.pbtn:hover{{transform:translateY(-3px);box-shadow:0 9px 24px rgba(30,95,168,.50)}}
.pbtn:active{{transform:translateY(0)}}
@media print {{
  @page {{
    size: auto;
    margin: 0mm;
  }}
  body {{
    background: #fff;
    padding: 0;
    display: block;
  }}
  .card {{
    box-shadow: none;
    border-radius: 0;
    width: 380px !important;
    margin: 0;
    border: 1px solid #eee;
  }}
  .card::before, .card::after, .no-print {{
    display: none;
  }}
}}
</style>
</head>
<body>
<div class="card">

  <div class="hdr">
    <div class="ico">🧾</div>
    <h1>إيصال راتب</h1>
    <div class="mo">{month_str}</div>
  </div>

  <div class="emp">
    <table>
      <tr>
        <td>
          <div class="nm">{employee.name}</div>
          <div class="id">#{employee.emp_id}</div>
        </td>
        <td class="ps">{getattr(employee,'position','')}</td>
      </tr>
    </table>
  </div>

  <div class="att">{att_bar_html}</div>

  <div class="body">
    <table>{rows}</table>
  </div>

  <hr class="perf">

  <div class="total">
    <span class="tl">💰 صافي الراتب</span>
    <span class="tv"><span class="tc">EGP</span>{fmt(payroll['final_salary'])}</span>
  </div>

  <div class="ftr">
    <div>تاريخ الإصدار: {now_str}</div>
    <div class="bar">||||||||||||||||||||||||||||||||</div>
    <div><span class="sig">التوقيع: .............................</span></div>
  </div>

</div>
<div class="no-print">
  <button class="pbtn" onclick="window.print()">🖨️ &nbsp; طباعة / PDF</button>
</div>
</body>
</html>"""
        return html


    @staticmethod
    def save_report(html_content: str, filename: str):
        """Save HTML report to file"""
        os.makedirs("reports", exist_ok=True)
        filepath = os.path.join("reports", filename)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html_content)
        return filepath

    @staticmethod
    def generate_attendance_report(rows: List[Dict], month: str = None, title: str = "تقرير الحضور") -> str:
        """Generate a comprehensive attendance HTML report in landscape format with statistics."""
        if month is None:
            month = datetime.now().strftime("%Y-%m")

        # Calculate statistics
        total_records = len(rows)
        unique_employees = len(set(r.get('uid', '') for r in rows if r.get('uid')))
        sum(int(r.get('rec_count', 0)) for r in rows if r.get('rec_count'))
        sum(1 for r in rows if r.get('checkin'))
        records_complete = sum(1 for r in rows if r.get('checkin') and r.get('checkout'))
        
        # New: Work days vs Weekends (Assuming Fri/Sat are weekends)
        work_days_count = 0
        weekend_days_count = 0
        total_worked_hours = 0
        fmt = '%Y-%m-%d %H:%M:%S'
        
        ar_days = {
            0: "الإثنين", 1: "الثلاثاء", 2: "الأربعاء", 3: "الخميس", 
            4: "الجمعة", 5: "السبت", 6: "الأحد"
        }

        html = f"""
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} - {month}</title>
    <style>
        :root {{
            --primary-color: #2c3e50;
            --accent-color: #3498db;
            --success-color: #27ae60;
            --warning-color: #e67e22;
            --danger-color: #c0392b;
            --bg-color: #f5f7fa;
            --in-color: #e8f5e9;
            --out-color: #e3f2fd;
            --weekend-bg: #fff9c4;
        }}
        
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: var(--bg-color); color: #333; line-height: 1.6; padding: 20px; }}
        .container {{ max-width: 100%; margin: 0 auto; background: white; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); overflow: hidden; }}
        .header {{ background: linear-gradient(135deg, var(--primary-color) 0%, #34495e 100%); color: white; padding: 25px 30px; text-align: center; border-bottom: 4px solid var(--accent-color); }}
        .summary {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; padding: 20px 25px; background: #fff; border-bottom: 2px solid #eee; }}
        .summary-card {{ background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); padding: 12px; border-radius: 8px; border-right: 3px solid var(--accent-color); text-align: center; }}
        .summary-card.special {{ border-right-color: var(--warning-color); }}
        .summary-card h3 {{ font-size: 0.75em; color: #7f8c8d; margin-bottom: 5px; font-weight: 600; }}
        .summary-card .value {{ font-size: 1.2em; font-weight: 700; color: var(--primary-color); }}
        .content {{ padding: 20px 25px; }}
        table {{ width: 100%; border-collapse: collapse; font-size: 0.85em; }}
        thead {{ background: var(--primary-color); color: white; }}
        th {{ padding: 12px 10px; text-align: right; }}
        td {{ padding: 10px; border-bottom: 1px solid #eee; text-align: right; }}
        tr.weekend {{ background-color: var(--weekend-bg) !important; }}
        .day-tag {{ display: inline-block; padding: 2px 6px; border-radius: 3px; font-size: 0.8em; background: #eee; color: #666; margin-left: 5px; }}
        .weekend-tag {{ background: #fbc02d; color: #000; font-weight: bold; }}
        .time-badge {{ display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 0.9em; font-weight: 600; }}
        .check-in {{ background-color: var(--in-color); color: var(--success-color); border: 1px solid #c8e6c9; }}
        .check-out {{ background-color: var(--out-color); color: var(--accent-color); border: 1px solid #bbdefb; }}
        .hours-badge {{ background-color: #fff3e0; color: #e65100; padding: 4px 8px; border-radius: 4px; font-weight: 700; border: 1px solid #ffe0b2; }}
        .footer {{ background: #f8f9fa; padding: 15px; text-align: center; color: #7f8c8d; font-size: 0.85em; }}
        @media print {{ @page {{ size: landscape; margin: 1cm; }} .no-print {{ display: none; }} }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 {title}</h1>
            <p>الشهر: {month} | تاريخ الإنشاء: {datetime.now().strftime('%d/%m/%Y %I:%M %p')}</p>
        </div>
        
        <div class="summary" id="stats-summary">
            <!-- Stats will be populated after row processing to get accurate work day counts -->
        </div>
        
        <div class="content">
            <table>
                <thead>
                    <tr>
                        <th>اليوم / التاريخ</th>
                        <th>رقم الموظف</th>
                        <th>اسم الموظف</th>
                        <th>وقت الدخول</th>
                        <th>وقت الخروج</th>
                        <th>ساعات العمل</th>
                        <th>الحالة</th>
                    </tr>
                </thead>
                <tbody>
"""

        rows_html = ""
        for r in rows:
            date_str = r.get('date','')
            # Identify Day and Weekend
            day_name = ""
            is_weekend = False
            try:
                dt_obj = datetime.strptime(date_str, '%Y-%m-%d')
                day_name = ar_days.get(dt_obj.weekday(), "")
                if dt_obj.weekday() in [4, 5]: # Friday, Saturday
                    is_weekend = True
                    weekend_days_count += 1
                else:
                    work_days_count += 1
            except Exception:
                pass

            ci = r.get('checkin') or ''
            co = r.get('checkout') or ''
            
            try:
                ci_disp = f'<span class="time-badge check-in">{ReportGenerator._format_time_12(ci)}</span>' if ci else '-'
            except Exception:
                ci_disp = f'<span class="time-badge check-in">{ci}</span>' if ci else '-'
            
            try:
                co_disp = f'<span class="time-badge check-out">{ReportGenerator._format_time_12(co)}</span>' if co else '-'
            except Exception:
                co_disp = f'<span class="time-badge check-out">{co}</span>' if co else '-'
            
            duration_disp = "-"
            if ci and co:
                try:
                    dt_ci = datetime.strptime(ci, fmt)
                    dt_co = datetime.strptime(co, fmt)
                    hours = (dt_co - dt_ci).total_seconds() / 3600
                    duration_disp = f'<span class="hours-badge">{hours:.2f} ساعة</span>'
                    total_worked_hours += hours
                except Exception:
                    pass

            status = '<span style="color: green;">✓ كامل</span>' if ci and co else '<span style="color: orange;">⚠ ناقص</span>'
            row_class = "weekend" if is_weekend else ""
            day_tag_class = "day-tag weekend-tag" if is_weekend else "day-tag"
            
            rows_html += f"""
                <tr class="{row_class}">
                    <td><span class="{day_tag_class}">{day_name}</span> {date_str}</td>
                    <td>{r.get('uid','')}</td>
                    <td>{r.get('name','')}</td>
                    <td>{ci_disp}</td>
                    <td>{co_disp}</td>
                    <td>{duration_disp}</td>
                    <td>{status}</td>
                </tr>
"""

        # Build summary now that we have counts
        summary_html = f"""
            <div class="summary-card">
                <h3>إجمالي السجلات</h3>
                <div class="value">{total_records}</div>
            </div>
            <div class="summary-card">
                <h3>أيام العمل الفعلي</h3>
                <div class="value">{work_days_count}</div>
            </div>
            <div class="summary-card special">
                <h3>سجلات العطلات (ج/س)</h3>
                <div class="value">{weekend_days_count}</div>
            </div>
            <div class="summary-card">
                <h3>إجمالي الساعات</h3>
                <div class="value">{total_worked_hours:.2f}</div>
            </div>
            <div class="summary-card">
                <h3>عدد الموظفين</h3>
                <div class="value">{unique_employees}</div>
            </div>
            <div class="summary-card">
                <h3>بصمات كاملة</h3>
                <div class="value">{records_complete}</div>
            </div>
            <div class="summary-card special">
                <h3>بصمات ناقصة</h3>
                <div class="value">{total_records - records_complete}</div>
            </div>
"""
        html = html.replace('<!-- Stats will be populated after row processing to get accurate work day counts -->', summary_html)
        html += rows_html
        html += f"""
                </tbody>
            </table>
        </div>
        <div class="footer">
            <p>تقرير الحضور - إجمالي الساعات المسجلة للشهر: {total_worked_hours:.2f} ساعة</p>
            <p>© {datetime.now().year} نظام إدارة الموارد البشرية</p>
        </div>
    </div>
    <div class="no-print" style="padding: 20px; text-align: left;">
        <button class="print-btn" onclick="window.print()" style="background: #2c3e50; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer;">🖨️ طباعة التقرير</button>
    </div>
</body>
</html>
"""
        return html
