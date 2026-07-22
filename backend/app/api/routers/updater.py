import json
import os
from pathlib import Path
from packaging.version import Version

from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse

router = APIRouter(prefix="/updater", tags=["updater"])

UPDATES_DIR = Path(os.environ.get("UPDATES_DIR", "./updates"))


def _load_manifest():
    manifest_path = UPDATES_DIR / "manifest.json"
    if not manifest_path.exists():
        raise HTTPException(status_code=404, detail="No updates available")
    with open(manifest_path, "r", encoding="utf-8") as f:
        return json.load(f)


@router.get("/{target}/{current_version}")
async def check_update(target: str, current_version: str):
    manifest = _load_manifest()
    latest_version = manifest.get("version", "0.0.0")

    try:
        if Version(latest_version) <= Version(current_version):
            return {}
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid version format")

    platform = manifest.get("platforms", {}).get(target)
    if not platform:
        return {}

    return {
        "version": latest_version,
        "notes": manifest.get("notes", ""),
        "pub_date": manifest.get("pub_date", ""),
        "platforms": {target: platform},
    }


@router.get("/download/{filename:path}")
async def download_update(filename: str):
    safe_name = os.path.basename(filename)
    file_path = (UPDATES_DIR / safe_name).resolve()
    if not file_path.is_relative_to(UPDATES_DIR.resolve()):
        raise HTTPException(status_code=400, detail="Invalid filename")
    if not file_path.exists() or not file_path.is_file():
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(
        path=str(file_path),
        filename=file_path.name,
        media_type="application/octet-stream",
    )
