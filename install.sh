#!/bin/bash
# install.sh — Run once on a fresh server to install everything and start the ERP system
# Supports: Ubuntu 20.04/22.04/24.04, Debian 11/12
# Usage: bash install.sh

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
step()    { echo -e "\n${YELLOW}━━━ $1 ━━━${NC}"; }

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

step "Checking OS"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    info "Detected: $PRETTY_NAME"
else
    error "Cannot detect OS. This script supports Ubuntu/Debian only."
fi

step "Updating package list"
sudo apt-get update -qq

step "Installing system dependencies"
sudo apt-get install -y -qq \
    curl wget git ca-certificates gnupg lsb-release \
    python3 python3-pip python3-venv \
    2>/dev/null
info "System packages installed"

step "Installing Docker"
if command -v docker &>/dev/null; then
    info "Docker already installed: $(docker --version)"
else
    # Official Docker install script
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker "$USER"
    info "Docker installed"
fi

step "Installing Docker Compose plugin"
if docker compose version &>/dev/null 2>&1; then
    info "Docker Compose already available: $(docker compose version)"
else
    sudo apt-get install -y -qq docker-compose-plugin
    info "Docker Compose installed"
fi

step "Starting Docker service"
sudo systemctl enable docker --quiet
sudo systemctl start docker
info "Docker service running"

step "Installing Python dependencies for manage.py"
cd "$DIR"
python3 -m pip install --quiet --break-system-packages requests 2>/dev/null || \
python3 -m pip install --quiet requests 2>/dev/null || true
info "Python ready"

step "Building and starting ERP system"
# Run docker with sudo if current user not in docker group yet
DOCKER_CMD="docker"
if ! docker info &>/dev/null 2>&1; then
    DOCKER_CMD="sudo docker"
fi

$DOCKER_CMD compose -f "$DIR/docker-compose.yml" up -d --build

step "Waiting for system to be ready"
echo -n "Waiting"
for i in $(seq 1 30); do
    if curl -sf http://localhost/api/health &>/dev/null; then
        echo ""
        break
    fi
    echo -n "."
    sleep 2
done

step "Setting up auto-start on boot"
# Create systemd service
sudo tee /etc/systemd/system/erp.service > /dev/null <<EOF
[Unit]
Description=ERP System
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DIR
ExecStart=/usr/bin/docker compose -f $DIR/docker-compose.yml up -d
ExecStop=/usr/bin/docker compose -f $DIR/docker-compose.yml stop
TimeoutStartSec=120

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable erp.service --quiet
info "Auto-start on boot enabled"

step "Creating manage shortcut"
sudo tee /usr/local/bin/erp > /dev/null <<EOF
#!/bin/bash
python3 $DIR/manage.py "\$@"
EOF
sudo chmod +x /usr/local/bin/erp
info "You can now use: erp status | erp backup | erp restart"

step "Done!"
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ERP System is ready! 🎉          ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  URL:      http://$(hostname -I | awk '{print $1}')         ${NC}"
echo -e "${GREEN}║  Login:    ammar                     ║${NC}"
echo -e "${GREEN}║  Password: changeme                  ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  Commands:                           ║${NC}"
echo -e "${GREEN}║    erp status                        ║${NC}"
echo -e "${GREEN}║    erp backup                        ║${NC}"
echo -e "${GREEN}║    erp restore <file>                ║${NC}"
echo -e "${GREEN}║    erp restart                       ║${NC}"
echo -e "${GREEN}║    erp logs                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
warn "If this is your first login, change the password immediately!"
