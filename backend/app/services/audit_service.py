"""Central audit logging service."""
import json
import uuid

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession


async def log(
    db: AsyncSession,
    entity_type: str,
    action: str,
    user_id: uuid.UUID | None = None,
    user_name: str | None = None,
    entity_id: uuid.UUID | None = None,
    changes: dict | None = None,
    note: str | None = None,
):
    await db.execute(text("""
        INSERT INTO audit_log (entity_type, entity_id, action, user_id, user_name, changes, note)
        VALUES (:etype, :eid, :action, :uid, :uname, CAST(:changes AS jsonb), :note)
    """), {
        "etype": entity_type,
        "eid": entity_id,
        "action": action,
        "uid": user_id,
        "uname": user_name,
        "changes": json.dumps(changes) if changes else None,
        "note": note,
    })
