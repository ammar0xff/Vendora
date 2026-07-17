from fastapi import APIRouter
from app.api.routers import auth, users, products, stock, sales, shifts, reports, parties, purchases, archive, payroll, settings, operations
from app.api.routers import ledger as ledger_router
from app.api.routers import hr, finance, suppliers, admin_overview, safes, wallets, collections as collections_router
from app.api.routers import print_router, expenses, periods, export as export_router
from app.api.routers import notifications

router = APIRouter()

router.include_router(auth.router)
router.include_router(users.router)
router.include_router(products.router)
router.include_router(stock.router)
router.include_router(sales.router)
router.include_router(shifts.router)
router.include_router(reports.router)
router.include_router(parties.router)
router.include_router(purchases.router)
router.include_router(archive.router)
router.include_router(payroll.router)
router.include_router(settings.router)
router.include_router(operations.router)
router.include_router(ledger_router.router)
router.include_router(hr.router)
router.include_router(finance.router)
router.include_router(suppliers.router)
router.include_router(print_router.router)
router.include_router(admin_overview.router)
router.include_router(safes.router)
router.include_router(collections_router.router)
router.include_router(wallets.router)
router.include_router(expenses.router)
router.include_router(periods.router)
router.include_router(export_router.router)
router.include_router(notifications.router)
