"""Schema drift checker: compares SQLAlchemy model metadata (from the repo)
against the live database and reports missing tables / missing columns /
type mismatches. Run from backend/ with DATABASE_URL + SECRET_KEY set.

    python ../../e2e/tools/schema_drift.py
"""
import asyncio
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "backend"))

import app.models.archive  # noqa: F401
import app.models.customer_payment  # noqa: F401
import app.models.device_token  # noqa: F401
import app.models.expense  # noqa: F401
import app.models.financial_category  # noqa: F401
import app.models.party  # noqa: F401
import app.models.payment_wallet  # noqa: F401
import app.models.payroll  # noqa: F401
import app.models.period  # noqa: F401
import app.models.product  # noqa: F401
import app.models.purchase  # noqa: F401
import app.models.safe  # noqa: F401
import app.models.sale  # noqa: F401
import app.models.sale_payment  # noqa: F401
import app.models.settings  # noqa: F401
import app.models.shift  # noqa: F401
import app.models.stock  # noqa: F401
import app.models.user  # noqa: F401
import app.models.warehouse  # noqa: F401

from sqlalchemy import text as sqlt
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import engine


async def main():
    async with AsyncSession(engine) as db:
        db_cols = {}
        rows = (await db.execute(sqlt(
            "SELECT table_name, column_name, data_type, is_nullable, column_default "
            "FROM information_schema.columns WHERE table_schema='public'"
        ))).fetchall()
        for r in rows:
            db_cols.setdefault(r[0], {})[r[1]] = r[2]

        from app.db.base import Base
        problems = []
        for table in Base.metadata.sorted_tables:
            tname = table.name
            if tname not in db_cols:
                problems.append(f"MISSING TABLE: {tname}")
                continue
            for col in table.columns:
                if col.name not in db_cols[tname]:
                    problems.append(f"  {tname}: missing column {col.name}")
        print("\n".join(problems) if problems else "NO DRIFT — all model tables/columns present in live DB")
    await engine.dispose()


asyncio.run(main())