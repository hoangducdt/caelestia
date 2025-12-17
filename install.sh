#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="$HOME/caelestia_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${GREEN}▶${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
warning() { echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"; }
ai_info() { echo -e "${MAGENTA}[AI/ML]${NC} $1" | tee -a "$LOG_FILE"; }
creative_info() { echo -e "${CYAN}[CREATIVE]${NC} $1" | tee -a "$LOG_FILE"; }

clear
echo -e "${GREEN}"
cat << "EOF"
╭────────────────────────────────────────────────────────────────╮
│   CachyOS Complete Setup - DIRECT INSTALLER                    │
│   ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB           │
╰────────────────────────────────────────────────────────────────╯
EOF
echo -e "${NC}"

[ "$EUID" -eq 0 ] && error "KHÔNG chạy với sudo"

log "Starting installation..."
echo ""
log "Estimated time: 30-60 minutes"
echo ""

# ===== NVIDIA CLEANUP =====
log "Pre-check: NVIDIA conflicts..."
for p in linux-cachyos-nvidia-open nvidia-open lib32-nvidia-open media-dkms; do
    pacman -Qi "$p" &>/dev/null && sudo pacman -Rdd --noconfirm "$p" 2>/dev/null || true
done

# ===== SYSTEM UPDATE =====
log "System update..."
sudo pacman -Syu --noconfirm

# ===== NVIDIA DRIVERS =====
log "Installing NVIDIA proprietary drivers..."
sudo pacman -S --needed --noconfirm \
    nvidia-dkms nvidia-utils lib32-nvidia-utils \
    nvidia-settings opencl-nvidia lib32-opencl-nvidia \
    libva-nvidia-driver egl-wayland

if [ -f /etc/mkinitcpio.conf ]; then
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
        sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        sudo mkinitcpio -P &>/dev/null || true
    fi
fi

sudo mkdir -p /etc/modprobe.d
echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" | sudo tee -a /etc/modprobe.d/nvidia.conf >/dev/null

log "✓ NVIDIA"

# ===== BASE PACKAGES =====
log "Installing base packages..."
sudo pacman -S --needed --noconfirm \
    base-devel git wget curl yay fish \
    wl-clipboard xdg-desktop-portal-hyprland \
    qt5-wayland qt6-wayland \
    gnome-keyring polkit-gnome nautilus \
    gnome-disk-utility

log "✓ Base"

# ===== HYPRLAND CAELESTIA =====
log "Installing Hyprland Caelestia..."
if [ -d "$HOME/.local/share/caelestia" ]; then
    mv "$HOME/.local/share/caelestia" "$HOME/.local/share/caelestia.backup.$(date +%s)"
fi

if git clone --quiet https://github.com/caelestia-dots/caelestia.git "$HOME/.local/share/caelestia" 2>/dev/null; then
    cd "$HOME/.local/share/caelestia"
    
    if [ -f "install.fish" ]; then
        cp install.fish install.fish.backup
        sed -i '/nvidia-open/s/^/#/' install.fish
    fi
    
    command -v fish &>/dev/null || sudo pacman -S --needed --noconfirm fish
    fish ./install.fish --noconfirm --aur-helper=yay 2>&1 | tee -a "$LOG_FILE" || warning "Caelestia warnings"
    
    for p in linux-cachyos-nvidia-open nvidia-open lib32-nvidia-open; do
        pacman -Qi "$p" &>/dev/null && sudo pacman -Rdd --noconfirm "$p" 2>/dev/null || true
    done
fi

log "✓ Hyprland"

# ===== GAMING + DEV =====
log "Installing Gaming + Dev..."
sudo pacman -S --needed --noconfirm \
    cachyos-gaming-meta cachyos-gaming-applications \
    wine-staging \
    lib32-mangohud gamemode lib32-gamemode \
    dotnet-sdk dotnet-runtime aspnet-runtime mono mono-msbuild \
    code neovim docker docker-compose git github-cli

timeout 300 yay -S --noconfirm --needed rider || warning "Rider skip"
timeout 300 yay -S --noconfirm --needed microsoft-edge-stable-bin || warning "Edge skip"
timeout 300 yay -S --noconfirm --needed github-desktop || warning "GitHub Desktop skip"

sudo systemctl enable --now docker.service 2>/dev/null || true
sudo usermod -aG docker "$USER" 2>/dev/null || true

log "✓ Gaming + Dev"

# ===== AI/ML STACK =====
ai_info "Installing AI/ML Stack..."
sudo pacman -S --needed --noconfirm \
    cuda cudnn python-pytorch-cuda \
    python python-pip python-virtualenv \
    python-numpy python-pandas jupyter-notebook

timeout 300 yay -S --noconfirm --needed ollama-cuda || {
    curl -fsSL https://ollama.com/install.sh | sh || warning "Ollama skip"
}

sudo systemctl enable --now ollama.service 2>/dev/null || true

ai_info "✓ AI/ML Stack"

# ===== DONE =====
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✓ INSTALLATION COMPLETED SUCCESSFULLY!           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Logs: $LOG_FILE"
echo -e "${YELLOW}Next: ${GREEN}sudo reboot${NC}"
echo ""
