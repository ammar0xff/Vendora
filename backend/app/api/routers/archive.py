from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.base import get_db
from app.models.archive import ArchivedDocument
from app.dependencies import get_current_user, require_role
from app.core.exceptions import NotFoundError
import uuid

router = APIRouter(prefix="/archive", tags=["archive"])


@router.get("")
async def list_documents(
    doc_type: str | None = None,
    search: str | None = None,
    from_date: str | None = None,
    to_date: str | None = None,
    limit: int = Query(200, le=1000),
    db: AsyncSession = Depends(get_db),
    _=Depends(get_current_user),
):
    from sqlalchemy import text as sqlt
    conditions = ["1=1"]
    params: dict = {"limit": limit}
    if doc_type:
        conditions.append("ad.doc_type = :doc_type")
        params["doc_type"] = doc_type
    if search:
        conditions.append("(ad.doc_number ILIKE :search OR ad.customer_name ILIKE :search)")
        params["search"] = f"%{search}%"
    if from_date:
        conditions.append("ad.created_at >= :from_date")
        params["from_date"] = from_date
    if to_date:
        conditions.append("ad.created_at <= :to_date")
        params["to_date"] = to_date
    rows = await db.execute(sqlt(f"""
        SELECT ad.*, u.full_name as created_by_name
        FROM archived_documents ad
        LEFT JOIN users u ON u.id = ad.created_by
        WHERE {' AND '.join(conditions)}
        ORDER BY ad.created_at DESC LIMIT :limit
    """), params)
    return [dict(r._mapping) for r in rows.fetchall()]


@router.get("/{doc_id}")
async def get_document(doc_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(get_current_user)):
    result = await db.execute(select(ArchivedDocument).where(ArchivedDocument.id == doc_id))
    doc = result.scalar_one_or_none()
    if not doc:
        raise NotFoundError()
    return doc


@router.delete("/{doc_id}", status_code=204)
async def delete_document(doc_id: uuid.UUID, db: AsyncSession = Depends(get_db), _=Depends(require_role("admin"))):
    result = await db.execute(select(ArchivedDocument).where(ArchivedDocument.id == doc_id))
    doc = result.scalar_one_or_none()
    if not doc:
        raise NotFoundError()
    await db.delete(doc)
    await db.commit()
