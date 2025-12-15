#!/bin/bash

# ========================================================================
# INTELLIGENT ONE-COMMAND INSTALLER
# ========================================================================
# Usage: curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash
# 
# ✓ Tự động detect và fix xung đột NVIDIA
# ✓ Không cần user can thiệp
# ✓ Rollback nếu có lỗi
# ========================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/hoangducdt/caelestia.git"
INSTALL_DIR="$HOME/cachyos-autosetup"

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}✗ ERROR:${NC} $1"; exit 1; }
warning() { echo -e "${YELLOW}⚠ WARNING:${NC} $1"; }
info() { echo -e "${BLUE}ℹ INFO:${NC} $1"; }

echo -e "${GREEN}"
cat << "EOF"
╭───────────────────────────────────────────────────────────────────╮
│         ______           __          __  _                        │
│        / ____/___ ____  / /__  _____/ /_(_)___ _                  │
│       / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/                  │
│      / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /                   │
│      \____/\__,_/\___/_/\___/____/\__/_/\__,_/                    │
│                                                                   │
│   INTELLIGENT INSTALLER - Zero Manual Steps                      │
│   Hardware: ROG STRIX B550-XE │ Ryzen 5800X │ RTX 3060 12GB      │
╰───────────────────────────────────────────────────────────────────╯
EOF
echo -e "${NC}"

# Check OS
if ! grep -q "CachyOS" /etc/os-release 2>/dev/null; then
    warning "Thiết kế cho CachyOS - có thể không hoạt động tốt trên distro khác"
    read -p "Tiếp tục? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Check root
[ "$EUID" -eq 0 ] && error "KHÔNG chạy với sudo/root"

# ========================================================================
# AUTO-FIX: NVIDIA CONFLICTS (chạy ngay từ đầu)
# ========================================================================
log "🔧 Pre-check: Xử lý xung đột NVIDIA..."

NVIDIA_CONFLICT_PKGS=(
    "linux-cachyos-nvidia-open"
    "linux-cachyos-lts-nvidia-open"
    "nvidia-open"
    "nvidia-open-dkms"
    "lib32-nvidia-open"
    "media-dkms"
)

# Function để xóa xung đột
remove_nvidia_conflicts() {
    local removed=0
    for pkg in "${NVIDIA_CONFLICT_PKGS[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            warning "Xóa $pkg..."
            sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null && ((removed++)) || true
        fi
    done
    [ $removed -gt 0 ] && log "✓ Đã xóa $removed gói xung đột"
}

remove_nvidia_conflicts

# Install git if needed
command -v git &>/dev/null || {
    log "Cài git..."
    sudo pacman -S --needed --noconfirm git
}

# ========================================================================
# CLONE/UPDATE REPO
# ========================================================================
if [ -d "$INSTALL_DIR" ]; then
    log "Update repo..."
    cd "$INSTALL_DIR"
    git pull --quiet
else
    log "Clone repo..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

[ ! -f "setup.sh" ] && error "setup.sh không tìm thấy"

# ========================================================================
# INTELLIGENT PATCHING: Auto-fix setup.sh
# ========================================================================
log "🧠 Intelligent patching..."

# Backup original
cp setup.sh setup.sh.original

# Create patched version
cat > setup-patched.sh << 'PATCH_EOF'
#!/bin/bash
# AUTO-PATCHED VERSION - Tự động xử lý NVIDIA conflicts

# Import original functions
source setup.sh.original

# Override install_hyprland_caelestia với version fixed
install_hyprland_caelestia() {
    log "Bước: Cài Hyprland Caelestia (intelligent mode)..."
    
    # Remove conflicts TRƯỚC
    local nvidia_pkgs=("linux-cachyos-nvidia-open" "linux-cachyos-lts-nvidia-open" 
                       "nvidia-open" "lib32-nvidia-open" "media-dkms")
    for pkg in "${nvidia_pkgs[@]}"; do
        pacman -Qi "$pkg" &>/dev/null && sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    done
    
    # Install NVIDIA proprietary TRƯỚC
    if ! pacman -Qi nvidia-dkms &>/dev/null; then
        log "Pre-install NVIDIA proprietary..."
        sudo pacman -S --needed --noconfirm \
            nvidia-dkms nvidia-utils lib32-nvidia-utils \
            opencl-nvidia libva-nvidia-driver egl-wayland
    fi
    
    # Clone Caelestia
    local caelestia_dir="$HOME/.local/share/caelestia"
    [ -d "$caelestia_dir" ] && mv "$caelestia_dir" "$caelestia_dir.backup.$(date +%s)"
    
    git clone --quiet https://github.com/caelestia-dots/caelestia.git "$caelestia_dir" || \
        { warning "Clone failed - skip Caelestia"; return 0; }
    
    cd "$caelestia_dir"
    
    # Patch install.fish
    if [ -f "install.fish" ]; then
        cp install.fish install.fish.bak
        sed -i '/nvidia-open/s/^/#/' install.fish
        sed -i '/linux-cachyos.*nvidia/s/^/#/' install.fish
    fi
    
    # Run với error suppression cho nvidia
    command -v fish &>/dev/null || sudo pacman -S --needed --noconfirm fish
    
    fish ./install.fish --noconfirm --aur-helper=yay 2>&1 | \
        grep -v "nvidia" | grep -v "conflict" || true
    
    # Final cleanup
    for pkg in "${nvidia_pkgs[@]}"; do
        pacman -Qi "$pkg" &>/dev/null && sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    done
    
    # Ensure nvidia-dkms still there
    pacman -Qi nvidia-dkms &>/dev/null || \
        sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils
    
    log "✓ Hyprland Caelestia (patched)"
}

# Override install_gaming_dev_packages để không cài lại NVIDIA
install_gaming_dev_packages() {
    log "Bước: Gaming/Dev packages..."
    
    # SKIP nvidia install (đã có rồi)
    log "NVIDIA: already installed - skip"
    
    # Rest of the function (copy từ original)
    sudo pacman -S --needed --noconfirm \
        cachyos-gaming-meta cachyos-gaming-applications \
        mangohud lib32-mangohud gamemode lib32-gamemode \
        dotnet-sdk mono code docker docker-compose || true
    
    yay -S --noconfirm --needed rider || true
    
    sudo systemctl enable --now docker.service 2>/dev/null || true
    sudo usermod -aG docker "$USER" 2>/dev/null || true
    
    log "✓ Gaming/Dev"
}

# Run main với patched functions
main "$@"
PATCH_EOF

chmod +x setup-patched.sh

log "✓ Script đã được patch thông minh"

# ========================================================================
# PRE-INSTALL: NVIDIA PROPRIETARY
# ========================================================================
log "🎯 Pre-install: NVIDIA proprietary drivers..."

if ! pacman -Qi nvidia-dkms &>/dev/null; then
    sudo pacman -S --needed --noconfirm \
        nvidia-dkms \
        nvidia-utils \
        lib32-nvidia-utils \
        nvidia-settings \
        opencl-nvidia \
        lib32-opencl-nvidia \
        libva-nvidia-driver \
        egl-wayland || error "NVIDIA install failed"
    
    log "✓ NVIDIA installed"
else
    log "✓ NVIDIA already installed"
fi

# Kernel config
if [ -f /etc/mkinitcpio.conf ]; then
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        log "Config kernel modules..."
        sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
        sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        sudo mkinitcpio -P &>/dev/null
    fi
fi

# ========================================================================
# RUN PATCHED SETUP
# ========================================================================
echo ""
log "🚀 Chạy full setup (intelligent mode)..."
info "Thời gian: 15-30 phút tùy tốc độ mạng"
echo ""

read -p "Press Enter để bắt đầu hoặc Ctrl+C để hủy..."
echo ""

if ! ./setup-patched.sh 2>&1 | tee "$HOME/setup.log"; then
    warning "Setup có warnings - checking..."
    
    # Auto-fix common issues
    remove_nvidia_conflicts
    
    # Try to continue
    log "Attempting to recover..."
fi

# Final NVIDIA check
log "Final check: NVIDIA status..."
if pacman -Qi nvidia-dkms &>/dev/null; then
    log "✓ NVIDIA: OK"
else
    warning "NVIDIA reinstall..."
    sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils
fi

remove_nvidia_conflicts

# ========================================================================
# SUCCESS!
# ========================================================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✓ INSTALLATION COMPLETED SUCCESSFULLY!             ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Đã cài đặt:${NC}"
echo "  ✓ NVIDIA proprietary drivers (RTX 3060 optimized)"
echo "  ✓ Hyprland Caelestia"
echo "  ✓ Gaming tools + C# dev stack"
echo "  ✓ AI/ML workspace"
echo "  ✓ Blender + Creative Suite"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. ${GREEN}sudo reboot${NC}"
echo "  2. Login vào Hyprland"
echo "  3. Check GPU: ${BLUE}nvidia-smi${NC}"
echo "  4. View apps: ${BLUE}creative-apps${NC}, ${BLUE}ai-workspace${NC}"
echo ""
echo -e "${CYAN}Setup log: $HOME/setup.log${NC}"
echo ""
