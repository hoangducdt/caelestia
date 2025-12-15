#!/bin/bash

# ========================================================================
# SMART INSTALLER - Wrapper tự động xử lý mọi xung đột
# ========================================================================
# Chạy: bash auto-install.sh
# Script này sẽ TỰ ĐỘNG xử lý xung đột nvidia-open vs nvidia-dkms
# ========================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}▶${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }

clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║          SMART AUTO INSTALLER - Zero Manual Intervention      ║
║              ROG STRIX B550-XE | Ryzen 5800X | RTX 3060       ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

[ "$EUID" -eq 0 ] && error "Không chạy với sudo/root"

# ========================================================================
# BƯỚC 1: XÓA TẤT CẢ XUNG ĐỘT NVIDIA TRƯỚC
# ========================================================================
log "BƯỚC 1: Dọn dẹp xung đột NVIDIA..."

nvidia_conflict_packages=(
    "linux-cachyos-nvidia-open"
    "linux-cachyos-lts-nvidia-open"
    "nvidia-open"
    "lib32-nvidia-open"
    "nvidia-open-dkms"
    "media-dkms"
)

for pkg in "${nvidia_conflict_packages[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        warning "Xóa $pkg..."
        sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    fi
done

log "✓ Xung đột đã được xóa"

# ========================================================================
# BƯỚC 2: CÀI NVIDIA PROPRIETARY TRƯỚC TIÊN
# ========================================================================
log "BƯỚC 2: Cài NVIDIA proprietary drivers..."

sudo pacman -S --needed --noconfirm \
    nvidia-dkms \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings \
    opencl-nvidia \
    lib32-opencl-nvidia \
    libva-nvidia-driver \
    egl-wayland || error "Lỗi cài NVIDIA"

log "✓ NVIDIA drivers OK"

# Cấu hình kernel
if [ -f /etc/mkinitcpio.conf ]; then
    log "Cấu hình kernel modules..."
    sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
    
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        sudo mkinitcpio -P >/dev/null 2>&1
    fi
fi

sudo mkdir -p /etc/modprobe.d
cat << EOF | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

log "✓ Kernel config OK"

# ========================================================================
# BƯỚC 3: PATCH CAELESTIA INSTALL SCRIPT
# ========================================================================
log "BƯỚC 3: Chuẩn bị Caelestia (patched để skip nvidia-open)..."

CAELESTIA_DIR="$HOME/.local/share/caelestia"

if [ -d "$CAELESTIA_DIR" ]; then
    warning "Backup caelestia cũ..."
    mv "$CAELESTIA_DIR" "$CAELESTIA_DIR.backup.$(date +%s)"
fi

log "Clone Caelestia..."
git clone --quiet https://github.com/caelestia-dots/caelestia.git "$CAELESTIA_DIR" 2>/dev/null || \
    error "Lỗi clone Caelestia"

cd "$CAELESTIA_DIR"

# PATCH install.fish - comment out mọi thứ liên quan nvidia-open
if [ -f "install.fish" ]; then
    log "Patching install.fish..."
    cp install.fish install.fish.original
    
    # Comment out nvidia-open lines
    sed -i \
        -e '/nvidia-open/s/^/#/' \
        -e '/linux-cachyos.*nvidia/s/^/#/' \
        install.fish
    
    log "✓ Patched install.fish"
fi

# ========================================================================
# BƯỚC 4: CHẠY CAELESTIA (VỚI ERROR HANDLING)
# ========================================================================
log "BƯỚC 4: Cài Hyprland Caelestia..."

# Cài fish nếu chưa có
command -v fish &>/dev/null || sudo pacman -S --needed --noconfirm fish

# Run với error handling
info "Đang chạy Caelestia installer... (có thể mất 5-10 phút)"

if ! fish ./install.fish --noconfirm --aur-helper=yay 2>&1 | tee /tmp/caelestia_install.log; then
    warning "Caelestia install có warnings - kiểm tra..."
    
    # Check nếu là lỗi nvidia
    if grep -q "nvidia" /tmp/caelestia_install.log; then
        warning "Phát hiện vấn đề nvidia - fixing..."
        
        # Xóa nvidia-open lần nữa
        for pkg in "${nvidia_conflict_packages[@]}"; do
            sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
        done
        
        # Reinstall nvidia-dkms
        sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils
    fi
fi

log "✓ Caelestia installed"

# ========================================================================
# BƯỚC 5: FINAL NVIDIA CHECK
# ========================================================================
log "BƯỚC 5: Final NVIDIA check..."

# Đảm bảo nvidia-dkms vẫn còn
if ! pacman -Qi nvidia-dkms &>/dev/null; then
    warning "nvidia-dkms bị mất - reinstall..."
    sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils
fi

# Xóa nvidia-open nếu nó lại xuất hiện
for pkg in "${nvidia_conflict_packages[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        warning "Phát hiện $pkg - xóa..."
        sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    fi
done

log "✓ NVIDIA proprietary confirmed"

# ========================================================================
# BƯỚC 6: CHẠY SETUP.SH CHÍNH
# ========================================================================
log "BƯỚC 6: Chạy setup script chính..."

if [ ! -f "$SCRIPT_DIR/setup.sh" ]; then
    error "Không tìm thấy setup.sh trong thư mục hiện tại"
fi

info "Đang chạy full setup... (15-30 phút tùy mạng)"
echo ""

# Backup setup.sh gốc
cp "$SCRIPT_DIR/setup.sh" "$SCRIPT_DIR/setup.sh.original"

# Patch setup.sh để skip Hyprland Caelestia (đã cài rồi)
sed -i 's/^    install_hyprland_caelestia$/    log "Skip Hyprland (already installed)"/' "$SCRIPT_DIR/setup.sh"

# Run setup.sh
if ! bash "$SCRIPT_DIR/setup.sh"; then
    error "Setup script failed - check log"
fi

# ========================================================================
# DONE!
# ========================================================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✓ CÀI ĐẶT HOÀN TẤT THÀNH CÔNG!                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
info "NVIDIA drivers: proprietary (nvidia-dkms) ✓"
info "Hyprland Caelestia: installed ✓"
info "All packages: installed ✓"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Reboot: ${BLUE}sudo reboot${NC}"
echo "  2. Login to Hyprland from SDDM"
echo "  3. Check GPU: ${BLUE}nvidia-smi${NC}"
echo "  4. Start creating! 🚀"
echo ""

exit 0
