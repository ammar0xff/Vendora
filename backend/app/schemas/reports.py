from datetime import datetime
from decimal import Decimal
from typing import Optional, List
from pydantic import BaseModel


class DailySalesReport(BaseModel):
    date: str
    total_sales: Decimal
    total_items: int
    invoice_count: int


class MonthlySalesReport(BaseModel):
    year: int
    month: int
    total_sales: Decimal
    invoice_count: int
    by_day: List[DailySalesReport] = []


class TopProduct(BaseModel):
    product_id: str
    product_name: str
    total_qty: Decimal
    total_revenue: Decimal


class InventoryValuation(BaseModel):
    total_cost_value: Decimal
    total_retail_value: Decimal
    product_count: int


class LowStockItem(BaseModel):
    product_id: str
    product_name: str
    current_qty: Decimal
    unit: str


class ProfitReport(BaseModel):
    from_date: str
    to_date: str
    total_revenue: Decimal
    total_cogs: Decimal
    gross_profit: Decimal
