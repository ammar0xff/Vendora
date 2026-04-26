"""Role definitions and default permissions."""

ROLE_LABELS = {
    "admin":       "مدير عام",
    "manager":     "مشرف",
    "cashier":     "كاشير",
    "storekeeper": "أمين مخازن",
    "accountant":  "محاسب",
}

# Default permissions per role (used when creating new users)
ROLE_DEFAULT_PERMISSIONS = {
    "admin": [
        "pos", "sales", "quotations", "inventory", "operations",
        "customers", "reports", "archive", "payroll", "users",
        "settings", "admin", "shifts", "finance",
    ],
    "manager": [
        "pos", "sales", "quotations", "inventory", "operations",
        "customers", "reports", "archive", "shifts", "finance", "settings", "payroll",
    ],
    "cashier": [
        "pos", "sales", "quotations", "customers", "shifts",
    ],
    "storekeeper": [
        "inventory", "operations", "archive",
    ],
    "accountant": [
        "reports", "finance", "archive", "customers", "inventory", "payroll",
    ],
}

# Home page redirect per role
ROLE_HOME = {
    "admin":       "/",
    "manager":     "/",
    "cashier":     "/pos",
    "storekeeper": "/inventory",
    "accountant":  "/reports",
}
