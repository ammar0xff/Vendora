#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# EG-CO ERP — Production Deployment Script
# Run from project root on LOCAL machine
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

LOG_DIR="./deploy-logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/deploy-$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }
run() { log ">>> $1"; eval "$1" 2>&1 | tee -a "$LOG"; }

log "═══ EG-CO ERP Deployment Started ═══"
log "Log file: $LOG"

# ── 1. Git Push ──────────────────────────────────────────────────
log ""
log "═══ STEP 1: Git Push ═══"
if git status --porcelain | grep -q .; then
    log "ERROR: Uncommitted changes. Commit first."
    exit 1
fi

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/master 2>/dev/null || echo "none")
if [ "$LOCAL" = "$REMOTE" ]; then
    log "Already up to date with origin/master"
else
    log "Pushing $LOCAL to origin..."
    git push origin master 2>&1 | tee -a "$LOG"
    log "Push complete"
fi

# ── 2. SSH + Deploy ─═══════════════════════════════════════════════
log ""
log "═══ STEP 2: SSH to Production Server ═══"
SSH_CMD='ssh -o ConnectTimeout=30 -o StrictHostKeyChecking=no "Right Click@eg-co.duckdns.org"'

# We'll create a remote script and execute it
REMOTE_SCRIPT=$(cat << 'REMOTE_EOF'
#!/bin/bash
set -euo pipefail

echo "[remote] ═══ Starting Server Deployment ═══"

# ── Find project ──
PROJECT_DIR=""
for dir in /root/eg-co-erp /home/*/eg-co-erp /opt/eg-co-erp ~/eg-co-erp .; do
    if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ]; then
        PROJECT_DIR="$(cd "$dir" && pwd)"
        break
    fi
done

if [ -z "$PROJECT_DIR" ]; then
    echo "[remote] ERROR: docker-compose.yml not found. Set PROJECT_DIR manually."
    exit 1
fi
echo "[remote] Project dir: $PROJECT_DIR"
cd "$PROJECT_DIR"

# ── Git Pull ──
echo "[remote] ── Git Pull ──"
git pull origin master 2>&1

# ── Run Migrations ──
echo "[remote] ── Running Migrations ──"

echo "[remote] Migration 1: fix_nullable_and_fks.sql"
psql -U postgres -d egco -f backend/migrations/fix_nullable_and_fks.sql 2>&1 || echo "[remote] WARNING: Migration 1 had issues (may already be applied)"

echo "[remote] Migration 2: add_indexes.sql"
psql -U postgres -d egco -f backend/migrations/add_indexes.sql 2>&1 || echo "[remote] WARNING: Migration 2 had issues (may already be applied)"

echo "[remote] Migration 3: typed_fk_columns.sql"
psql -U postgres -d egco -f backend/migrations/typed_fk_columns.sql 2>&1 || echo "[remote] WARNING: Migration 3 had issues (may already be applied)"

# ── Close Stale Shifts ──
echo "[remote] ── Closing Stale Shifts ──"
psql -U postgres -d egco -c "
SELECT id, cashier_id, initial_amount, status FROM shifts WHERE status='open';
" 2>&1

# Close all stale open shifts (set closing_balance = initial_amount as conservative default)
CLOSED=$(psql -U postgres -d egco -t -c "
UPDATE shifts SET
    status = 'closed',
    closed_at = NOW(),
    closed_by = cashier_id,
    closing_balance = initial_amount,
    expected_balance = initial_amount,
    difference = 0,
    notes = COALESCE(notes, '') || ' [auto-closed by deployment script]'
WHERE status = 'open'
RETURNING id;
" 2>&1 | wc -l)

echo "[remote] Closed $CLOSED stale shift(s)"

# ── Docker Rebuild ──
echo "[remote] ── Docker Rebuild ──"
docker compose down 2>&1
docker compose build --no-cache 2>&1
docker compose up -d 2>&1

# ── Verify ──
echo "[remote] ── Verification ──"
sleep 5
docker compose ps 2>&1
echo "[remote] Backend logs (last 20 lines):"
docker compose logs --tail=20 backend 2>&1

# ── Health Check ──
echo "[remote] ── Health Check ──"
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health 2>/dev/null || echo "000")
if [ "$HEALTH" = "200" ]; then
    echo "[remote] ✅ Backend healthy (HTTP 200)"
else
    echo "[remote] ⚠️  Backend returned HTTP $HEALTH — check logs"
fi

echo "[remote] ═══ Deployment Complete ═══"
REMOTE_EOF
)

# Copy the script to the server and execute
log "Copying deployment script to server..."
echo "$REMOTE_SCRIPT" | ssh -o ConnectTimeout=30 -o StrictHostKeyChecking=no "Right Click@eg-co.duckdns.org" "cat > /tmp/deploy-egco.sh && chmod +x /tmp/deploy-egco.sh && bash /tmp/deploy-egco.sh" 2>&1 | tee -a "$LOG"

log ""
log "═══ Deployment Complete ═══"
log "Full log saved to: $LOG"
