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
╭────────────────────────────────────────────────────────────────────────────────────────────────╮
│ ▀████    ███                                                 ▀█████████▄             █         │
│   ███    ███                 ▀▀▀▀                              ███    ███          █           │
│   ███    ███    ▄██████▄  ▀███████▄  ▀████████▄   ▄██████▄     ███    ███ ███   ███▀ ▄██████▄  │
│  ▄███▄▄▄▄███▄▄ ███    ███       ▀███  ███    ███ ███    ███   ▄███▄▄▄ ███ ███   ███ ███    ███ │
│ ▀▀███▀▀▀▀███▀  ███    ███  ▄████████  ███    ███ ███    ███  ▀▀███▀▀▀ ███ ███   ███ ███        │
│   ███    ███   ███    ███ ███    ███  ███    ███ ███    ███    ███    ███ ███   ███ ███        │
│   ███    ███   ███    ███ ███    ███  ███    ███ ███    ███    ███    ███ ███   ███ ███    ███ │
│   ███    ███    ▀██████▀   ▀████████▄ ███    ███  ▀████████  ▄█████████▀   ▀█████▀   ▀██████▀  │
│                                                        ▄███                                    │
│                                                 ▄████████▀                                     │
│   COMPLETE INSTALLER - Safe Gaming Optimizations                                               │
│                        ROG STRIX B550-XE │ Ryzen 7 5800X │ RTX 3060 12GB                       │
╰────────────────────────────────────────────────────────────────────────────────────────────────╯
EOF
echo -e "${NC}"

[ "$EUID" -eq 0 ] && error "KHÔNG chạy với sudo"

# ===== SUDO FIX: CHỈ NHẬP PASSWORD 1 LẦN =====
echo ""
echo -e "${YELLOW}Script cần quyền sudo. Vui lòng nhập password 1 LẦN DUY NHẤT:${NC}"
echo ""

if ! sudo -v; then
    error "Không có quyền sudo. Thoát."
fi

# Keep sudo alive - tự động refresh mỗi 60s
(
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null
) &
SUDO_REFRESH_PID=$!

trap "kill $SUDO_REFRESH_PID 2>/dev/null" EXIT

log "✓ Sudo access granted"

log "Starting complete installation..."
echo ""
log "Estimated time: 30-60 minutes"
echo ""

#yay -S lmstudio
#yay -S docker-desktop

readonly LOG="$HOME/setup_complete_$(date +%Y%m%d_%H%M%S).log"
readonly STATE_DIR="$HOME/.cache/caelestia-setup"
readonly STATE_FILE="$STATE_DIR/setup_state.json"
readonly BACKUP_DIR="$HOME/Documents/caelestia-configs-$(date +%Y%m%d_%H%M%S)"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Create directories
mkdir -p "$STATE_DIR" "$BACKUP_DIR"

# ===== STATE MANAGEMENT =====

init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" <<EOF
{
  "version": "1.0",
  "start_time": "$(date -Iseconds)",
  "completed": [],
  "failed": [],
  "warnings": []
}
EOF
    fi
}

mark_completed() {
    local step="$1"
    python3 -c "
import json
try:
    with open('$STATE_FILE', 'r') as f:
        state = json.load(f)
    if '$step' not in state['completed']:
        state['completed'].append('$step')
    with open('$STATE_FILE', 'w') as f:
        json.dump(state, f, indent=2)
except Exception as e:
    print(f'Warning: Could not update state: {e}')
" 2>/dev/null || true
}

is_completed() {
    local step="$1"
    python3 -c "
import json
try:
    with open('$STATE_FILE', 'r') as f:
        state = json.load(f)
    print('yes' if '$step' in state['completed'] else 'no')
except:
    print('no')
" 2>/dev/null || echo "no"
}

# ===== LOGGING =====

log() { 
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG"
}

warn() { 
    echo -e "${YELLOW}⚠ [$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG"
}

error() {
    echo -e "${RED}✗ [$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG"
    echo -e "${YELLOW}See log: $LOG${NC}"
    exit 1
}

ai_info() { 
    echo -e "${MAGENTA}[AI/ML]${NC} $1" | tee -a "$LOG"
}

creative_info() { 
    echo -e "${CYAN}[CREATIVE]${NC} $1" | tee -a "$LOG"
}

# ===== PACKAGE MANAGEMENT =====

safe_remove_package() {
    local pkg="$1"
    
    if ! pacman -Qi "$pkg" &>/dev/null; then
        return 0
    fi
    
    log "Removing conflicting package: $pkg"
    
    # Check dependencies
    local deps=$(pactree -r "$pkg" 2>/dev/null | tail -n +2 | wc -l)
    if [ "$deps" -gt 0 ]; then
        warn "$pkg has $deps dependent packages"
    fi
    
    sudo pacman -Rdd --noconfirm "$pkg" 2>&1 | tee -a "$LOG" || warn "Failed to remove $pkg"
}

install_package() {
    local pkg="$1"
    local max_retries=3
    local retry=0
    
    # Skip if installed
    if pacman -Qi "$pkg" &>/dev/null; then
        return 0
    fi
    
    while [ $retry -lt $max_retries ]; do
        if sudo pacman -S --needed --noconfirm "$pkg" 2>&1 | tee -a "$LOG"; then
            return 0
        fi
        
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            warn "Retry installing $pkg ($retry/$max_retries)..."
            sleep 2
        fi
    done
    
    warn "Failed to install $pkg"
    return 1
}

install_packages() {
    local packages=("$@")
    local failed=()
    
    for pkg in "${packages[@]}"; do
        if ! install_package "$pkg"; then
            failed+=("$pkg")
        fi
    done
    
    if [ ${#failed[@]} -gt 0 ]; then
        warn "Failed packages: ${failed[*]}"
    fi
}

install_aur_package() {
    local pkg="$1"
    local timeout_seconds="${2:-600}"
    
    if pacman -Qi "$pkg" &>/dev/null; then
        return 0
    fi
    
    if ! command -v yay &>/dev/null; then
        warn "yay not available, skipping $pkg"
        return 1
    fi
    
    log "Installing AUR: $pkg (timeout: ${timeout_seconds}s)"
    
    if timeout "$timeout_seconds" yay -S --noconfirm --needed "$pkg" 2>&1 | tee -a "$LOG"; then
        return 0
    else
        warn "Failed to install AUR package: $pkg"
        return 1
    fi
}

# ===== BACKUP =====

backup_file() {
    local file="$1"
    local backup_path="$BACKUP_DIR/$(basename "$file").backup"
    
    if [ -f "$file" ]; then
        cp "$file" "$backup_path" 2>/dev/null || warn "Failed to backup $file"
        log "Backed up: $file"
    fi
}

backup_dir() {
    local dir="$1"
    local backup_path="$BACKUP_DIR/$(basename "$dir")"
    
    if [ -d "$dir" ]; then
        cp -r "$dir" "$backup_path" 2>/dev/null || warn "Failed to backup $dir"
        log "Backed up: $dir"
    fi
}

# ===== BANNER =====

show_banner() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   CachyOS Complete Setup - OPTIMIZED VERSION               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ===== SETUP FUNCTIONS =====

setup_nvidia_cleanup() {
    if [ "$(is_completed 'nvidia_cleanup')" = "yes" ]; then
        log "✓ NVIDIA cleanup already done"
        return 0
    fi
    
    log "Cleaning up NVIDIA conflicts..."
    
    local conflict_pkgs=(
        "linux-cachyos-nvidia-open"
        "nvidia-open"
        "lib32-nvidia-open"
        "media-dkms"
        "linux-cachyos-lts-nvidia-open"
    )
    
    for pkg in "${conflict_pkgs[@]}"; do
        safe_remove_package "$pkg"
    done
    
    sudo pacman -Sc --noconfirm 2>/dev/null || true
    
    mark_completed "nvidia_cleanup"
    log "✓ NVIDIA cleanup done"
}

setup_system_update() {
    if [ "$(is_completed 'system_update')" = "yes" ]; then
        log "✓ System already updated"
        return 0
    fi
    
    log "Updating system..."
    
    # Update keyrings first
    sudo pacman -Sy --noconfirm archlinux-keyring cachyos-keyring 2>&1 | tee -a "$LOG" || true
    
    # Full update with retry
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if sudo pacman -Syu --noconfirm 2>&1 | tee -a "$LOG"; then
            mark_completed "system_update"
            log "✓ System updated"
            return 0
        fi
        
        retry=$((retry + 1))
        warn "System update retry $retry/$max_retries"
        sudo pacman -Syy 2>&1 | tee -a "$LOG"
        sleep 3
    done
    
    warn "System update had issues but continuing..."
    mark_completed "system_update"
}

setup_nvidia_drivers() {
    if [ "$(is_completed 'nvidia_drivers')" = "yes" ]; then
        log "✓ NVIDIA drivers already installed"
        return 0
    fi
    
    log "Installing NVIDIA proprietary drivers..."
    
    # Backup mkinitcpio.conf
    backup_file "/etc/mkinitcpio.conf"
    
    sudo pacman -S --needed --noconfirm \
        "nvidia-dkms" "nvidia-utils" "lib32-nvidia-utils" \
        "nvidia-settings" "opencl-nvidia" "lib32-opencl-nvidia" \
        "libva-nvidia-driver" "egl-wayland"
    
    # Configure mkinitcpio
    if [ -f /etc/mkinitcpio.conf ]; then
        if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
            sudo sed -i.bak 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
            sudo mkinitcpio -P 2>&1 | tee -a "$LOG" || warn "mkinitcpio warnings"
        fi
    fi
    
    # Configure modprobe
    sudo mkdir -p /etc/modprobe.d
    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
    echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" | sudo tee -a /etc/modprobe.d/nvidia.conf >/dev/null
    
    mark_completed "nvidia_drivers"
    log "✓ NVIDIA drivers installed"
}

setup_base_packages() {
    if [ "$(is_completed 'base_packages')" = "yes" ]; then
        log "✓ Base packages already installed"
        return 0
    fi
    
    log "Installing base packages..."
    
    sudo pacman -S --needed --noconfirm \
        "base-devel" "git" "wget" "curl" "yay" "fish" \
        "wl-clipboard" "xdg-desktop-portal-hyprland" \
        "qt5-wayland" "qt6-wayland" \
        "gnome-keyring" "polkit-gnome" \
        "gnome-disk-utility" "kitty" "vlc" \
        "tumbler" "ffmpegthumbnailer" "libgsf" "thunar"

    yay -S youtube-dl
    sudo pacman -S xdman
    
    mark_completed "base_packages"
    log "✓ Base packages installed"
}

setup_hyprland_caelestia() {
    if [ "$(is_completed 'hyprland')" = "yes" ]; then
        log "✓ Hyprland already installed"
        return 0
    fi
    
    log "Installing Hyprland Caelestia..."
    
    local caelestia_dir="$HOME/.local/share/caelestia"
    
    # Backup existing
    if [ -d "$caelestia_dir" ]; then
        backup_dir "$caelestia_dir"
        mv "$caelestia_dir" "${caelestia_dir}.backup.$(date +%s)" 2>/dev/null || true
    fi
    
    # Clone repo
    if git clone --quiet --depth 1 https://github.com/caelestia-dots/caelestia.git "$caelestia_dir" 2>&1 | tee -a "$LOG"; then
        cd "$caelestia_dir"
        
        # Patch install script to avoid nvidia-open
        if [ -f "install.fish" ]; then
            cp install.fish install.fish.backup
            sed -i '/nvidia-open/s/^/#/' install.fish 2>/dev/null || true
        fi
        
        # Install fish if needed
        command -v fish &>/dev/null || install_package "fish"
        
        # Run installer
        fish ./install.fish --noconfirm --aur-helper=yay 2>&1 | tee -a "$LOG" || warn "Caelestia warnings"
        
        # Clean up nvidia-open again
        setup_nvidia_cleanup
    else
        warn "Failed to clone Caelestia"
    fi
    
    mark_completed "hyprland"
    log "✓ Hyprland installed"
}

setup_gaming() {
    if [ "$(is_completed 'gaming')" = "yes" ]; then
        log "✓ Gaming packages already installed"
        return 0
    fi
    
    log "Installing gaming packages..."
    
    sudo pacman -S --needed --noconfirm \
        "cachyos-gaming-meta" "cachyos-gaming-applications" \
        "wine-staging" \
        "lib32-mangohud" "gamemode" "lib32-gamemode"
    
    mark_completed "gaming"
    log "✓ Gaming packages installed"
}

setup_development() {
    if [ "$(is_completed 'development')" = "yes" ]; then
        log "✓ Development tools already installed"
        return 0
    fi
    
    log "Installing development tools..."
    
    sudo pacman -S --needed --noconfirm \
        "dotnet-sdk" "dotnet-runtime" "dotnet-sdk-9.0" "dotnet-sdk-8.0" \
        "aspnet-runtime" "mono" "mono-msbuild" \
        "neovim" "docker" "docker-compose" "git" "github-cli" "codium"
        #"code"

    #dotnet new install Avalonia.Templates
    #dotnet new install "Microsoft.AspNetCore.Blazor.Templates::3.0.0-*"
    
    # AUR packages
    install_aur_package "rider" 900
    install_aur_package "microsoft-edge-stable-bin" 900
    install_aur_package "github-desktop" 600
    
    # Docker setup
    sudo systemctl enable --now docker.service 2>/dev/null || true
    sudo usermod -aG docker "$USER" 2>/dev/null || true
    
    mark_completed "development"
    log "✓ Development tools installed"
}

setup_unreal_engine_deps() {
    if [ "$(is_completed 'ue_deps')" = "yes" ]; then
        log "✓ UE5 dependencies already installed"
        return 0
    fi
    
    log "Installing Unreal Engine dependencies..."
    
    sudo pacman -S --needed --noconfirm \
        "clang" "make" "cmake" "ninja" "vulkan-devel" "vulkan-tools" \
        "vulkan-validation-layers" "lib32-vulkan-icd-loader" "icu" \
        "openal" "lib32-openal" "libpulse" "lib32-libpulse" \
        "alsa-lib" "lib32-alsa-lib" "sdl2" "lib32-sdl2" \
        "libxcursor" "lib32-libxcursor" "libxi" "lib32-libxi" \
        "libxinerama" "lib32-libxinerama" "libxrandr" "lib32-libxrandr" \
        "libxss" "lib32-libxss" "libglvnd" "lib32-libglvnd" \
        "mesa" "lib32-mesa" "vulkan-icd-loader" "lib32-vulkan-icd-loader" \
        "freetype2" "lib32-freetype2" "fontconfig" "lib32-fontconfig" \
        "harfbuzz" "lib32-harfbuzz" "curl" "lib32-curl" \
        "openssl" "lib32-openssl" "libidn" "lib32-libidn" \
        "bzip2" "lib32-bzip2" "xz" "lib32-xz" "zstd" "lib32-zstd"
    
    install_aur_package "libicu50" 600
    
    mkdir -p "$HOME/UnrealEngine"
    
    mark_completed "ue_deps"
    log "✓ UE5 dependencies installed"
}

setup_multimedia() {
    if [ "$(is_completed 'multimedia')" = "yes" ]; then
        log "✓ Multimedia packages already installed"
        return 0
    fi
    
    log "Installing multimedia packages..."
    
    sudo pacman -S --needed --noconfirm \
        "ffmpeg" "gstreamer" "gst-plugins-base" "gst-plugins-good" \
        "gst-plugins-bad" "gst-plugins-ugly" \
        "libvorbis" "lib32-libvorbis" "opus" "lib32-opus" \
        "flac" "lib32-flac" "x264" "x265" "obs-studio"
    
    install_aur_package "lib32-ffmpeg" 600
    
    mark_completed "multimedia"
    log "✓ Multimedia packages installed"
}

setup_ai_ml() {
    if [ "$(is_completed 'ai_ml')" = "yes" ]; then
        log "✓ AI/ML stack already installed"
        return 0
    fi
    
    ai_info "Installing AI/ML stack..."
    
    sudo pacman -S --needed --noconfirm \
        "cuda" "cudnn" "python-pytorch-cuda" \
        "python" "python-pip" "python-virtualenv" \
        "python-numpy" "python-pandas" "jupyter-notebook" \
        "python-scikit-learn" "python-matplotlib" "python-pillow"
    
    # Ollama
    if ! install_aur_package "ollama-cuda" 900; then
        curl -fsSL https://ollama.com/install.sh | sh 2>&1 | tee -a "$LOG" || warn "Ollama install failed"
    fi
    
    sudo systemctl enable --now ollama.service 2>/dev/null || true
    
    # Optional AI tools
    install_aur_package "jan-bin" 600
    install_aur_package "koboldcpp-cuda" 600
    
    mark_completed "ai_ml"
    ai_info "✓ AI/ML stack installed"
}

setup_ai_environments() {
    if [ "$(is_completed 'ai_envs')" = "yes" ]; then
        log "✓ AI environments already set up"
        return 0
    fi
    
    ai_info "Setting up AI environments..."
    
    mkdir -p "$HOME"/{AI-Projects,AI-Models}
    
    # Stable Diffusion WebUI
    if [ ! -d "$HOME/AI-Projects/stable-diffusion-webui" ]; then
        cd "$HOME/AI-Projects"
        git clone --quiet --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git 2>&1 | tee -a "$LOG" || \
            warn "SD WebUI clone failed"
    fi
    
    # Text Generation WebUI
    if [ ! -d "$HOME/AI-Projects/text-generation-webui" ]; then
        cd "$HOME/AI-Projects"
        git clone --quiet --depth 1 https://github.com/oobabooga/text-generation-webui.git 2>&1 | tee -a "$LOG" || \
            warn "Text Gen WebUI clone failed"
    fi
    
    # ComfyUI
    if [ ! -d "$HOME/AI-Projects/ComfyUI" ]; then
        cd "$HOME/AI-Projects"
        git clone --quiet --depth 1 https://github.com/comfyanonymous/ComfyUI.git 2>&1 | tee -a "$LOG" || \
            warn "ComfyUI clone failed"
    fi
    
    mark_completed "ai_envs"
    ai_info "✓ AI environments set up"
}

setup_blender() {
    if [ "$(is_completed 'blender')" = "yes" ]; then
        log "✓ Blender already installed"
        return 0
    fi
    
    creative_info "Installing Blender..."
    
    sudo pacman -S --needed --noconfirm \
        "blender" "openimagedenoise" "opencolorio" "opensubdiv" \
        "openvdb" "embree" "openimageio" "alembic" "openjpeg2" \
        "openexr" "libspnav"
    
    mkdir -p "$HOME/.config/blender"
    
    mark_completed "blender"
    creative_info "✓ Blender installed"
}

setup_creative_suite() {
    if [ "$(is_completed 'creative')" = "yes" ]; then
        log "✓ Creative suite already installed"
        return 0
    fi
    
    creative_info "Installing creative suite..."
    
    sudo pacman -S --needed --noconfirm \
        "gimp" "gimp-plugin-gmic" \
        "krita" "inkscape" \
        "kdenlive" "frei0r-plugins" "mediainfo" "mlt" \
        "audacity" "ardour" "scribus" \
        "darktable" "rawtherapee" \
        "imagemagick" "graphicsmagick" "potrace" "fontforge"
    
    install_aur_package "davinci-resolve" 900
    install_aur_package "natron" 600
    
    mark_completed "creative"
    creative_info "✓ Creative suite installed"
}

setup_streaming() {
    if [ "$(is_completed 'streaming')" = "yes" ]; then
        log "✓ Streaming tools already installed"
        return 0
    fi
    
    log "Installing streaming tools..."
    
    sudo pacman -S --needed --noconfirm \
        "v4l2loopback-dkms" "pipewire" "pipewire-pulse" \
        "wireplumber" "gstreamer-vaapi"
    
    install_aur_package "obs-vkcapture" 600
    install_aur_package "obs-websocket" 600
    install_aur_package "vesktop-bin" 600
    
    # Load v4l2loopback
    sudo modprobe v4l2loopback 2>/dev/null || true
    echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
    
    mark_completed "streaming"
    log "✓ Streaming tools installed"
}

setup_system_optimization() {
    if [ "$(is_completed 'optimization')" = "yes" ]; then
        log "✓ System already optimized"
        return 0
    fi
    
    log "Applying system optimizations..."
    
    # CPUPower
    install_package "cpupower"
    sudo systemctl enable --now cpupower.service 2>/dev/null || true
    
    echo "governor='performance'" | sudo tee /etc/default/cpupower >/dev/null
    sudo cpupower frequency-set -g performance 2>&1 | tee -a "$LOG" || warn "CPUPower setup failed"
    
    sudo sysctl --system 2>&1 | tee -a "$LOG" || warn "Sysctl apply failed"
    
    mark_completed "optimization"
    log "✓ System optimized"
}

setup_monitors() {
    if [ "$(is_completed 'monitors')" = "yes" ]; then
        log "✓ Multi-monitor already configured"
        return 0
    fi
    
    log "Configuring multi-monitor setup..."
    
    install_packages "wlr-randr" "kanshi"
    install_aur_package "nwg-displays" 600
    
    mark_completed "monitors"
    log "✓ Multi-monitor configured"
}

setup_vietnamese_input() {
    if [ "$(is_completed 'vietnamese')" = "yes" ]; then
        log "✓ Vietnamese input already configured"
        return 0
    fi
    
    log "Installing Vietnamese input..."
    
    sudo pacman -S --needed --noconfirm \
        "fcitx5" "fcitx5-qt" "fcitx5-gtk" "fcitx5-configtool"
    
    install_aur_package "fcitx5-bamboo-git" 600
    
    mark_completed "vietnamese"
    log "✓ Vietnamese input configured"
}

setup_sddm() {
    if [ "$(is_completed 'sddm')" = "yes" ]; then
        log "✓ SDDM already installed"
        return 0
    fi
    
    log "Installing SDDM..."
    
    sudo pacman -S --needed --noconfirm \
        "sddm" "qt5-graphicaleffects" "qt5-quickcontrols2" "qt5-svg" "uwsm"
    
    sudo mkdir -p /usr/share/sddm/themes
    cd /tmp
    rm -rf sddm-sugar-candy
    git clone --depth 1 https://github.com/Kangie/sddm-sugar-candy.git 2>/dev/null || warn "Sugar Candy clone skip"

    if [ -d "sddm-sugar-candy" ]; then
        sudo cp -r sddm-sugar-candy /usr/share/sddm/themes/sugar-candy
    fi

    sudo systemctl enable sddm.service 2>/dev/null || true
    
    mark_completed "sddm"
    log "✓ SDDM installed"
}

setup_gdm() {
    if [ "$(is_completed 'gdm')" = "yes" ]; then
        log "✓ GDM already installed"
        return 0
    fi
    
    log "Installing GDM..."
    
    # Cài đặt GDM
    sudo pacman -S --needed --noconfirm gdm gdm-settings
    
    # Bật GDM
    sudo systemctl enable gdm.service
    
    mark_completed "gdm"
    log "✓ GDM installed and enabled"
}

setup_onedrive() {
    if [ "$(is_completed 'onedrive')" = "yes" ]; then
        log "✓ OneDrive already configured"
        return 0
    fi
    
    log "Installing and configuring OneDrive..."
    
    # Install onedrive-abraunegg
    install_aur_package "onedrive-abraunegg" 600
    install_aur_package "onedrivegui" 600
    
    mark_completed "onedrive"
    log "✓ OneDrive configured"
}

setup_directories() {
    if [ "$(is_completed 'directories')" = "yes" ]; then
        log "✓ Directories already created"
        return 0
    fi
    
    log "Creating directories & downloading wallpapers..."
    
    mkdir -p "$HOME"/{Desktop,Documents,Downloads,Music,Videos}
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME"/{AI-Projects,AI-Models,Creative-Projects,Blender-Projects}
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.config/hypr/scripts"
    mkdir -p "$HOME/.config/caelestia"
    mkdir -p "$HOME/OneDrive"
    mkdir -p "$HOME/.config/hypr/hyprland"
    mkdir -p "$HOME/.config/fastfetch/logo"
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/xfce4"
    
    # Wallpapers
    if [ ! -d "$HOME/Pictures/Wallpapers/.git" ]; then
        git clone --quiet --depth 1 https://github.com/mylinuxforwork/wallpaper.git \
            "$HOME/Pictures/Wallpapers" 2>&1 | tee -a "$LOG" || warn "Wallpapers clone failed"
    fi

    #install_aur_package "nautilus-open-any-terminal" 900
    #gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty
    
    curl -L -o "$HOME/.face" https://raw.githubusercontent.com/hoangducdt/caelestia/main/.face.png
    curl -L -o "$HOME/.config/fastfetch/logo/aisaka.icon" https://raw.githubusercontent.com/hoangducdt/caelestia/main/aisaka.icon
    curl -L -o "$HOME/.config/fastfetch/logo/hyprland.icon" https://raw.githubusercontent.com/hoangducdt/caelestia/main/hyprland.icon
    curl -L -o "$HOME/.config/fastfetch/logo/loli.icon" https://raw.githubusercontent.com/hoangducdt/caelestia/main/loli.icon
    
    chmod 644 ~/.face
    
    # Thêm bookmarks
    cat >> ~/.config/gtk-3.0/bookmarks <<EOF
file://$HOME/Downloads
file://$HOME/Documents
file://$HOME/Pictures
file://$HOME/Videos
file://$HOME/Music
file://$HOME/OneDrive
EOF

    mark_completed "directories"
    log "✓ Directories created"
}

setup_utilities() {
    if [ "$(is_completed 'utilities')" = "yes" ]; then
        log "✓ Utilities already installed"
        return 0
    fi
    
    log "Installing utilities..."
    
    sudo pacman -S --needed --noconfirm \
        htop btop neofetch fastfetch \
        unzip p7zip unrar rsync tmux \
        starship eza bat ripgrep fd fzf zoxide \
        nvtop amdgpu_top iotop iftop
    
    install_aur_package "openrgb" 600
    
    mark_completed "utilities"
    log "✓ Utilities installed"
}

setup_helper_scripts() {
    if [ "$(is_completed 'helpers')" = "yes" ]; then
        log "✓ Helper scripts already created"
        return 0
    fi
    
    log "Creating helper scripts..."
    
    mkdir -p "$HOME/.local/bin"
    
    # GPU check
    cat > "$HOME/.local/bin/check-gpu" <<'HELPER'
#!/bin/bash
echo "=== NVIDIA GPU Status ==="
nvidia-smi
echo ""
echo "=== Vulkan Info ==="
vulkaninfo --summary 2>/dev/null || echo "vulkaninfo N/A"
echo ""
echo "=== OpenGL Info ==="
glxinfo | grep "OpenGL renderer" 2>/dev/null || echo "glxinfo N/A"
HELPER
    chmod +x "$HOME/.local/bin/check-gpu"
    
    # AI workspace
    cat > "$HOME/.local/bin/ai-workspace" <<'HELPER'
#!/bin/bash
echo "=== AI/ML Workspace ==="
echo ""
echo "📁 Directories:"
echo "  - AI Projects: $HOME/AI-Projects"
echo "  - AI Models: $HOME/AI-Models"
echo ""
echo "🤖 Tools:"
echo "  - Ollama: ollama-start"
echo "  - Stable Diffusion: sd-webui"
echo "  - Text Generation: text-gen-webui"
echo "  - ComfyUI: comfyui"
HELPER
    chmod +x "$HOME/.local/bin/ai-workspace"
    
    # Creative apps
    cat > "$HOME/.local/bin/creative-apps" <<'HELPER'
#!/bin/bash
echo "=== Creative Suite ==="
echo ""
echo "🎨 Image: gimp, krita, darktable, rawtherapee"
echo "🎬 Video: kdenlive, davinci-resolve"
echo "✏️ Vector: inkscape, scribus"
echo "🎵 Audio: audacity, ardour"
echo "🔮 3D: blender"
HELPER
    chmod +x "$HOME/.local/bin/creative-apps"
    
    # Add more helpers as needed...
    
    # Add to PATH
    grep -q ".local/bin" "$HOME/.bashrc" || \
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    
    mark_completed "helpers"
    log "✓ Helper scripts created"
}

setup_configs() {
    # Sysctl optimizations
    sudo tee /etc/sysctl.d/99-gaming.conf > /dev/null <<'SYSCTL'
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864
kernel.shmmax=68719476736
kernel.shmall=16777216
SYSCTL

    # Monitor configuration
    cat > "$HOME/.config/hypr/hyprland/monitors.conf" <<'MONITORS'
monitor=DP-1,2560x1080@99.94,0x0,1.0
monitor=DP-3,1920x1080@74.97,2560x0,1.0
MONITORS
    
    local hypr_conf="$HOME/.config/hypr/hyprland.conf"
    
    if [ -f "$hypr_conf" ]; then
        if ! grep -q 'source = $hl/monitors.conf' "$hypr_conf"; then
            echo 'source = $hl/monitors.conf' >> "$hypr_conf"
            log "Added monitors.conf source to hyprland.conf"
        fi
    else
        warn "hyprland.conf not found at $hypr_conf"
    fi

    # Hypr variables configuration - modify existing values
    local hypr_vars="$HOME/.config/hypr/variables.conf"
    if [ -f "$hypr_vars" ]; then
        log "Updating Hyprland variables..."
        backup_file "$hypr_vars"

        # Update terminal
        if grep -q '^\$terminal' "$hypr_vars"; then
            sed -i 's|^\$terminal.*|$terminal = kitty|' "$hypr_vars"
        else
            echo '$terminal = kitty' >> "$hypr_vars"
        fi
        
        # Update browser
        if grep -q '^\$browser' "$hypr_vars"; then
            sed -i 's|^\$browser.*|$browser = microsoft-edge-stable-bin|' "$hypr_vars"
        else
            echo '$browser = microsoft-edge-stable-bin' >> "$hypr_vars"
        fi
        
        # Update editor
        #if grep -q '^\$editor' "$hypr_vars"; then
        #    sed -i 's|^\$editor.*|$editor = code|' "$hypr_vars"
        #else
        #    echo '$editor = code' >> "$hypr_vars"
        #fi
        
        # Update fileExplorer
        #if grep -q '^\$fileExplorer' "$hypr_vars"; then
        #    sed -i 's|^\$fileExplorer.*|$fileExplorer = nautilus|' "$hypr_vars"
        #else
        #    echo '$fileExplorer = nautilus' >> "$hypr_vars"
        #fi
        #
        
        log "✓ Updated Hyprland variables"
    else
        warn "Hyprland variables.conf not found at $hypr_vars"
    fi

    # DNS configuration - modify existing values in resolved.conf
    local resolved_conf="/etc/systemd/resolved.conf"
    if [ -f "$resolved_conf" ]; then
        log "Updating DNS configuration..."
        backup_file "$resolved_conf"
        
        # Update or add DNS
        if sudo grep -q '^DNS=' "$resolved_conf"; then
            sudo sed -i 's|^DNS=.*|DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com|' "$resolved_conf"
        elif sudo grep -q '^#DNS=' "$resolved_conf"; then
            sudo sed -i 's|^#DNS=.*|DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com|' "$resolved_conf"
        else
            echo "DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com" | sudo tee -a "$resolved_conf" >/dev/null
        fi
        
        # Update or add FallbackDNS
        if sudo grep -q '^FallbackDNS=' "$resolved_conf"; then
            sudo sed -i 's|^FallbackDNS=.*|FallbackDNS=9.9.9.9#dns.quad9.net 2620:fe::9#dns.quad9.net 1.1.1.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 8.8.8.8#dns.google 2001:4860:4860::8888#dns.google|' "$resolved_conf"
        elif sudo grep -q '^#FallbackDNS=' "$resolved_conf"; then
            sudo sed -i 's|^#FallbackDNS=.*|FallbackDNS=9.9.9.9#dns.quad9.net 2620:fe::9#dns.quad9.net 1.1.1.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 8.8.8.8#dns.google 2001:4860:4860::8888#dns.google|' "$resolved_conf"
        else
            echo "FallbackDNS=9.9.9.9#dns.quad9.net 2620:fe::9#dns.quad9.net 1.1.1.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 8.8.8.8#dns.google 2001:4860:4860::8888#dns.google" | sudo tee -a "$resolved_conf" >/dev/null
        fi
        
        # Update or add DNSOverTLS
        if sudo grep -q '^DNSOverTLS=' "$resolved_conf"; then
            sudo sed -i 's|^DNSOverTLS=.*|DNSOverTLS=yes|' "$resolved_conf"
        elif sudo grep -q '^#DNSOverTLS=' "$resolved_conf"; then
            sudo sed -i 's|^#DNSOverTLS=.*|DNSOverTLS=yes|' "$resolved_conf"
        else
            echo "DNSOverTLS=yes" | sudo tee -a "$resolved_conf" >/dev/null
        fi
        
        log "✓ Updated DNS configuration"
    else
        warn "systemd resolved.conf not found at $resolved_conf"
    fi

    # Restart systemd-resolved to apply DNS changes
    sudo systemctl restart systemd-resolved.service 2>/dev/null || warn "Failed to restart systemd-resolved"

    # Static IP configuration
    log "Configuring static IP address..."
    
    # Get the primary network interface
    local primary_interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    if [ -n "$primary_interface" ]; then
        log "Detected primary interface: $primary_interface"
        
        # Create NetworkManager connection profile for static IP
        sudo tee /etc/NetworkManager/system-connections/static-ethernet.nmconnection > /dev/null <<STATIC_IP
[connection]
id=static-ethernet
type=ethernet
interface-name=$primary_interface
autoconnect=true

[ipv4]
method=manual
address1=192.168.1.2/24,192.168.1.1
dns=1.1.1.1;1.0.0.1;
dns-search=

[ipv6]
method=auto

[proxy]
STATIC_IP
        
        # Set correct permissions
        sudo chmod 600 /etc/NetworkManager/system-connections/static-ethernet.nmconnection
        
        # Reload NetworkManager
        sudo systemctl reload NetworkManager 2>/dev/null || warn "Failed to reload NetworkManager"
        
        log "✓ Static IP configured: 192.168.1.2/24 with gateway 192.168.1.1"
    else
        warn "Could not detect primary network interface for static IP configuration"
    fi
    
    # Add theme config
    #sudo mkdir -p /etc/sddm.conf.d
    #sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<SDDM_CONF
#[Theme]
#Current=sugar-candy
#SDDM_CONF

    # Add environment variables
    cat >> "$HOME/.config/hypr/hyprland/env.conf" <<'NVIDIA_ENV'

# NVIDIA Environment Variables
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
NVIDIA_ENV
    
    cat >> "$HOME/.config/hypr/hyprland/env.conf" <<'FCITX_ENV'

# Vietnamese Input - Fcitx5
env = XMODIFIERS,@im=fcitx
env = SDL_IM_MODULE,fcitx
env = GLFW_IM_MODULE,fcitx
FCITX_ENV

    cat >> "$HOME/.config/xfce4/helpers.rc" <<'FXCE4'
TerminalEmulator=kitty
TerminalEmulatorDismissed=true
FXCE4
    
    # Add autostart
    if [ -f "$HOME/.config/hypr/hyprland/execs.conf" ]; then
        grep -q "fcitx5" "$HOME/.config/hypr/hyprland/execs.conf" || \
            echo "exec-once = sleep 2; fcitx5" >> "$HOME/.config/hypr/hyprland/execs.conf"
        grep -q "steam" "$HOME/.config/hypr/hyprland/execs.conf" || \
            echo "exec-once = sleep 3; steam" >> "$HOME/.config/hypr/hyprland/execs.conf"
        grep -q "vesktop" "$HOME/.config/hypr/hyprland/execs.conf" || \
            echo "exec-once = sleep 4; vesktop" >> "$HOME/.config/hypr/hyprland/execs.conf"
    fi
    
    # Configure VRR
    if [ -f "$HOME/.config/hypr/hyprland/misc.conf" ]; then
        sed -i 's/vrr = [0-9]/vrr = 0/' "$HOME/.config/hypr/hyprland/misc.conf"
    else
        cat > "$HOME/.config/hypr/hyprland/misc.conf" <<'MISC'
misc {
    vrr = 0
    disable_hyprland_logo = true
    disable_splash_rendering = true
}
MISC
    fi
    
    # shell.json
    cat > "$HOME/.config/caelestia/shell.json" <<'SHELL_JSON'
{
    "appearance": {
        "anim": {
            "durations": {
                "scale": 1
            }
        },
        "font": {
            "family": {
                "clock": "Rubik",
                "material": "Material Symbols Rounded",
                "mono": "CaskaydiaCove NF",
                "sans": "Rubik"
            },
            "size": {
                "scale": 1
            }
        },
        "padding": {
            "scale": 1
        },
        "rounding": {
            "scale": 2
        },
        "spacing": {
            "scale": 1
        },
        "transparency": {
            "enabled": true,
            "base": 0.5,
            "layers": 0.4
        }
    },
    "general": {
        "apps": {
            "terminal": ["kitty"],
            "audio": ["pavucontrol"],
            "playback": ["mpv"],
            "explorer": ["thunar"]
        },
        "battery": {
            "warnLevels": [
                {
                    "level": 20,
                    "title": "Low battery",
                    "message": "You might want to plug in a charger",
                    "icon": "battery_android_frame_2"
                },
                {
                    "level": 10,
                    "title": "Did you see the previous message?",
                    "message": "You should probably plug in a charger <b>now</b>",
                    "icon": "battery_android_frame_1"
                },
                {
                    "level": 5,
                    "title": "Critical battery level",
                    "message": "PLUG THE CHARGER RIGHT NOW!!",
                    "icon": "battery_android_alert",
                    "critical": true
                }
            ],
            "criticalLevel": 3
        },
        "idle": {
            "lockBeforeSleep": true,
            "inhibitWhenAudio": true,
            "timeouts": [
                {
                    "timeout": 180,
                    "idleAction": "lock"
                },
                {
                    "timeout": 300,
                    "idleAction": "dpms off",
                    "returnAction": "dpms on"
                },
                {
                    "timeout": 600,
                    "idleAction": ["systemctl", "suspend-then-hibernate"]
                }
            ]
        }
    },
    "background": {
        "desktopClock": {
            "enabled": true
        },
        "enabled": true,
        "visualiser": {
            "blur": true,
            "enabled": true,
            "autoHide": true,
            "rounding": 1,
            "spacing": 1
        }
    },
    "bar": {
        "clock": {
            "showIcon": true
        },
        "dragThreshold": 20,
        "entries": [
            {
                "id": "logo",
                "enabled": true
            },
            {
                "id": "workspaces",
                "enabled": true
            },
            {
                "id": "spacer",
                "enabled": true
            },
            {
                "id": "activeWindow",
                "enabled": true
            },
            {
                "id": "spacer",
                "enabled": true
            },
            {
                "id": "tray",
                "enabled": true
            },
            {
                "id": "clock",
                "enabled": true
            },
            {
                "id": "statusIcons",
                "enabled": true
            },
            {
                "id": "power",
                "enabled": true
            }
        ],
        "persistent": true,
        "popouts": {
            "activeWindow": true,
            "statusIcons": true,
            "tray": true
        },
        "scrollActions": {
            "brightness": true,
            "workspaces": true,
            "volume": true
        },
        "showOnHover": true,
        "status": {
            "showAudio": true,
            "showBattery": false,
            "showBluetooth": true,
            "showKbLayout": false,
            "showMicrophone": true,
            "showNetwork": true,
            "showLockStatus": true
        },
        "tray": {
            "background": false,
            "compact": false,
            "iconSubs": [],
            "recolour": false
        },
        "workspaces": {
            "activeIndicator": true,
            "activeLabel": "⬤",
            "activeTrail": false,
            "label": "󰄰 ",
            "occupiedBg": false,
            "occupiedLabel": "⬤",
            "perMonitorWorkspaces": true,
            "showWindows": true,
            "shown": 5,
            "specialWorkspaceIcons": [
                {
                    "name": "steam",
                    "icon": "sports_esports"
                }
            ]
        },
        "excludedScreens": [""],
        "activeWindow": {
            "inverted": false
        }
    },
    "border": {
        "rounding": 25,
        "thickness": 2.5
    },
    "dashboard": {
        "enabled": true,
        "dragThreshold": 50,
        "mediaUpdateInterval": 500,
        "showOnHover": true
    },
    "launcher": {
        "actionPrefix": ">",
        "actions": [
            {
                "name": "Calculator",
                "icon": "calculate",
                "description": "Do simple math equations (powered by Qalc)",
                "command": ["autocomplete", "calc"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Scheme",
                "icon": "palette",
                "description": "Change the current colour scheme",
                "command": ["autocomplete", "scheme"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Wallpaper",
                "icon": "image",
                "description": "Change the current wallpaper",
                "command": ["autocomplete", "wallpaper"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Variant",
                "icon": "colors",
                "description": "Change the current scheme variant",
                "command": ["autocomplete", "variant"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Transparency",
                "icon": "opacity",
                "description": "Change shell transparency",
                "command": ["autocomplete", "transparency"],
                "enabled": false,
                "dangerous": false
            },
            {
                "name": "Random",
                "icon": "casino",
                "description": "Switch to a random wallpaper",
                "command": ["caelestia", "wallpaper", "-r"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Light",
                "icon": "light_mode",
                "description": "Change the scheme to light mode",
                "command": ["setMode", "light"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Dark",
                "icon": "dark_mode",
                "description": "Change the scheme to dark mode",
                "command": ["setMode", "dark"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Shutdown",
                "icon": "power_settings_new",
                "description": "Shutdown the system",
                "command": ["systemctl", "poweroff"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Reboot",
                "icon": "cached",
                "description": "Reboot the system",
                "command": ["systemctl", "reboot"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Logout",
                "icon": "exit_to_app",
                "description": "Log out of the current session",
                "command": ["loginctl", "terminate-user", ""],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Lock",
                "icon": "lock",
                "description": "Lock the current session",
                "command": ["loginctl", "lock-session"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Sleep",
                "icon": "bedtime",
                "description": "Suspend then hibernate",
                "command": ["systemctl", "suspend-then-hibernate"],
                "enabled": true,
                "dangerous": false
            }
        ],
        "dragThreshold": 50,
        "vimKeybinds": false,
        "enableDangerousActions": false,
        "maxShown": 7,
        "maxWallpapers": 9,
        "specialPrefix": "@",
        "useFuzzy": {
            "apps": false,
            "actions": false,
            "schemes": false,
            "variants": false,
            "wallpapers": false
        },
        "showOnHover": false,
        "hiddenApps": []
    },
    "lock": {
        "recolourLogo": false
    },
    "notifs": {
        "actionOnClick": false,
        "clearThreshold": 0.3,
        "defaultExpireTimeout": 5000,
        "expandThreshold": 20,
        "expire": false
    },
    "osd": {
        "enabled": true,
        "enableBrightness": true,
        "enableMicrophone": false,
        "hideDelay": 2000
    },
    "paths": {
        "mediaGif": "root:/assets/bongocat.gif",
        "sessionGif": "root:/assets/kurukuru.gif",
        "wallpaperDir": "~/Pictures/Wallpapers"
    },
    "services": {
        "audioIncrement": 0.1,
        "maxVolume": 1.0,
        "defaultPlayer": "Spotify",
        "gpuType": "",
        "playerAliases": [{ "from": "com.github.th_ch.youtube_music", "to": "YT Music" }],
        "weatherLocation": "",
        "useFahrenheit": false,
        "useTwelveHourClock": true,
        "smartScheme": true,
        "visualiserBars": 45
    },
    "session": {
        "dragThreshold": 30,
        "enabled": true,
        "vimKeybinds": false,
        "commands": {
            "logout": ["loginctl", "terminate-user", ""],
            "shutdown": ["systemctl", "poweroff"],
            "hibernate": ["systemctl", "hibernate"],
            "reboot": ["systemctl", "reboot"]
        }
    },
    "sidebar": {
        "dragThreshold": 80,
        "enabled": true
    },
    "utilities": {
        "enabled": true,
        "maxToasts": 4,
        "toasts": {
            "audioInputChanged": true,
            "audioOutputChanged": true,
            "capsLockChanged": true,
            "chargingChanged": true,
            "configLoaded": false,
            "dndChanged": true,
            "gameModeChanged": true,
            "kbLayoutChanged": true,
            "numLockChanged": true,
            "vpnChanged": true,
            "nowPlaying": false
        },
        "vpn": {
            "enabled": false,
            "provider": [
                {
                    "name": "wireguard",
                    "interface": "your-connection-name",
                    "displayName": "Wireguard (Your VPN)"
                }
            ]
        }
    }
}
SHELL_JSON
    
    # cli.json
    cat > "$HOME/.config/caelestia/cli.json" <<'CLI_JSON'
{
    "record": {
        "extraArgs": []
    },
    "wallpaper": {
        "postHook": "echo $WALLPAPER_PATH"  
    },
    "theme": {
        "enableTerm": true,
        "enableHypr": true,
        "enableDiscord": true,
        "enableSpicetify": true,
        "enableFuzzel": true,
        "enableBtop": true,
        "enableGtk": true,
        "enableQt": true
    },
    "toggles": {
        "communication": {
            "discord": {
                "enable": true,
                "match": [{ "class": "discord" }],
                "command": ["discord"],
                "move": true
            },
            "whatsapp": {
                "enable": true,
                "match": [{ "class": "whatsapp" }],
                "move": true
            }
        },
        "music": {
            "spotify": {
                "enable": true,
                "match": [{ "class": "Spotify" }, { "initialTitle": "Spotify" }, { "initialTitle": "Spotify Free" }],
                "command": ["spicetify", "watch", "-s"],
                "move": true
            },
            "feishin": {
                "enable": true,
                "match": [{ "class": "feishin" }],
                "move": true
            }
        },
        "sysmon": {
            "btop": {
                "enable": true,
                "match": [{ "class": "btop", "title": "btop", "workspace": { "name": "special:sysmon" } }],
                "command": ["kitty", "-a", "btop", "-T", "btop", "fish", "-C", "exec btop"]
            }
        },
        "todo": {
            "todoist": {
                "enable": true,
                "match": [{ "class": "Todoist" }],
                "command": ["todoist"],
                "move": true
            }
        }
    }
}
CLI_JSON

    # config.jsonc
    cat > "$HOME/.config/fastfetch/config.jsonc" <<'FASTFETCH_CONFIG_JSON'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "source": "\"$(~/.config/fastfetch/fastfetch.sh logo)\"",
    "height": 18,
    "padding": {
        "top": 2,
        "left": 1
    }
  },
  "modules": [
    "break",
    {
      "type": "title",
      "key": "  ",
      "format": "Don't work hard - Work smart!"
    },
    {
      "type": "custom",
      "format": "╭───────────────────────────────────────────────╮"
    },
    {
      "type": "chassis",
      "key": "• 󰇺 Chassis",
      "format": "{1} {2} {3}"
    },
    {
      "type": "os",
      "key": "• 󰣇 OS",
      "format": "{2}",
      "keyColor": "red"
    },
    {
      "type": "kernel",
      "key": "•  Kernel",
      "format": "{2}",
      "keyColor": "red"
    },
    {
      "type": "packages",
      "key": "• 󰏗 Packages",
      "keyColor": "green"
    },
    {
      "type": "display",
      "key": "• 󰍹 Display",
      "format": "{1}x{2} @ {3}Hz [{7}]",
      "keyColor": "green"
    },
    {
      "type": "terminal",
      "key": "•  Terminal",
      "keyColor": "yellow"
    },
    {
      "type": "wm",
      "key": "• 󱗃 WM",
      "format": "{2}",
      "keyColor": "yellow"
    },
    {
      "type": "custom",
      "format": "╰───────────────────────────────────────────────╯"
    },
    "break",
    {
      "type": "title",
      "key": "  ",
      "format": "{6} {7} Hoàng Đức"
    },
    {
      "type": "custom",
      "format": "╭───────────────────────────────────────────────╮"
    },
    {
      "type": "cpu",
      "format": "{1} @ {7}",
      "key": "•  CPU",
      "keyColor": "blue"
    },
    {
      "type": "gpu",
      "format": "{1} {2}",
      "key": "• 󰊴 GPU",
      "keyColor": "blue"
    },
    {
      "type": "gpu",
      "format": "{3}",
      "key": "•  GPU Driver",
      "keyColor": "magenta"
    },
    {
      "type": "memory",
      "key": "•  Memory ",
      "keyColor": "magenta"
    },
    {
      "type": "disk",
      "key": "• 󱦟 OS Age ",
      "folders": "/",
      "keyColor": "red",
      "format": "{days} days"
    },
    {
      "type": "uptime",
      "key": "• 󱫐 Uptime ",
      "keyColor": "red"
    },
    {
      "type": "custom",
      "format": "╰───────────────────────────────────────────────╯"
    },
    {
      "type": "colors",
      "paddingLeft": 2,
      "symbol": "circle"
    },
    "break"
  ]
}
FASTFETCH_CONFIG_JSON

    cat > "$HOME/.config/fish/functions/fish_greeting.fish" << 'FISH_SCRIPT'
function fish_greeting
    set_color normal
    fastfetch --logo-type kitty
end
FISH_SCRIPT

    cat > "$HOME/.config/fastfetch/fastfetch.sh" << 'FASTFETCH_LOGO_SCRIPT'
if [ -z "${*}" ]; then
  clear
  exec fastfetch --logo-type kitty
  exit
fi

USAGE() {
  cat <<USAGE
Usage: fastfetch [commands] [options]

commands:
  logo    Display a random logo

options:
  -h, --help,     Display command's help message

USAGE
}

confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
image_dirs=()

case $1 in
logo) # eats around 13 ms
  random() {
    (
      image_dirs+=("${confDir}/fastfetch/logo")
      [ -f "$HOME/.face.icon" ] && image_dirs+=("$HOME/.face.icon")
      # also .bash_logout may be matched with this find
      find -L "${image_dirs[@]}" -maxdepth 1 -type f \( -name "wall.quad" -o -name "wall.sqre" -o -name "*.icon" -o -name "*logo*" -o -name "*.png" \) ! -path "*/wall.set*" ! -path "*/wallpapers/*.png" 2>/dev/null
    ) | shuf -n 1
  }
  help() {
    cat <<HELP
Usage: ${0##*/} logo [option]

options:
  --quad    Display a quad wallpaper logo
  --sqre    Display a square wallpaper logo
  --prof    Display your profile picture (~/.face.icon)
  --os      Display the distro logo
  --local   Display a logo inside the fastfetch logo directory
  --wall    Display a logo inside the wallbash fastfetch directory
  --theme   Display a logo inside the hyde theme directory
  --rand    Display a random logo
  *         Display a random logo
  *help*    Display this help message

Note: Options can be combined to search across multiple sources
Example: ${0##*/} logo --local --os --prof
HELP
  }

  shift
  [ -z "${*}" ] && random && exit
  [[ "$1" = "--rand" ]] && random && exit
  [[ "$1" = *"help"* ]] && help && exit
  (
    image_dirs=()
    for arg in "$@"; do
      case $arg in
      --prof)
        [ -f "$HOME/.face.icon" ] && image_dirs+=("$HOME/.face.icon")
        ;;
      --local)
        image_dirs+=("${confDir}/fastfetch/logo")
        ;;
      esac
    done
    find -L "${image_dirs[@]}" -maxdepth 1 -type f \( -name "wall.quad" -o -name "wall.sqre" -o -name "*.icon" -o -name "*logo*" -o -name "*.png" \) ! -path "*/wall.set*" ! -path "*/wallpapers/*.png" 2>/dev/null
  ) | shuf -n 1

  ;;
--select | -S)
  :

  ;;
help | --help | -h)
  USAGE
  ;;
*)
  clear
  exec fastfetch --logo-type kitty
  ;;
esac
FASTFETCH_LOGO_SCRIPT

    chmod +x $HOME/.config/fastfetch/fastfetch.sh

    cat > "$HOME/.config/kitty/kitty.conf" <<'KITTY_CONFIG'
# This is the configuration file for kitty terminal
# For more information, see https://sw.kovidgoyal.net/kitty/conf.html
# For your custom configurations, put it in ./kitty.conf
#font_family CaskaydiaCove Nerd Font Mono
#bold_font auto
#italic_font auto
#bold_italic_font auto
#enable_audio_bell no
#font_size 9.0
#window_padding_width 25
#cursor_trail 1

# Themes can override any settings in this file
include theme.conf
background_opacity 0.60
#hide_window_decorations yes
#confirm_os_window_close 0

# Minimal Tab bar styling 
tab_bar_edge                bottom
tab_bar_style               powerline
tab_powerline_style         slanted
tab_title_template          {title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}

# remap to open new kitty tab in the same directory (default is home dir)
# map ctrl+shift+t            new_tab_with_cwd

# Uncomment the following 4 lines to minimize kitty latency (higher energy usage)
# input_delay 0
# repaint_delay 2
# sync_to_monitor no
# wayland_enable_ime no
KITTY_CONFIG

    cat > "$HOME/.config/kitty/theme.conf" <<'KITTY_THEMES'

## name:     Catppuccin Mocha 🌿
## author:   Pocco81 (https://github.com/Pocco81)
## license:  MIT
## upstream: https://github.com/catppuccin/kitty/blob/main/mocha.conf
## blurb:    Soothing pastel theme for the high-spirited!



# The basic colors
foreground              #CDD6F4
background              #1E1E2E
selection_foreground    #1E1E2E
selection_background    #F5E0DC

# Cursor colors
cursor                  #F5E0DC
cursor_text_color       #1E1E2E

# URL underline color when hovering with mouse
url_color               #B4BEFE

# Kitty window border colors
active_border_color     #CBA6F7
inactive_border_color   #8E95B3
bell_border_color       #EBA0AC

# OS Window titlebar colors
wayland_titlebar_color system
macos_titlebar_color system

# Tab bar colors
active_tab_foreground   #11111B
active_tab_background   #CBA6F7
inactive_tab_foreground #CDD6F4
inactive_tab_background #181825
tab_bar_background      #11111B

# Colors for marks (marked text in the terminal)
mark1_foreground #1E1E2E
mark1_background #87B0F9
mark2_foreground #1E1E2E
mark2_background #CBA6F7
mark3_foreground #1E1E2E
mark3_background #74C7EC

# The 16 terminal colors

# black
color0 #43465A
color8 #43465A

# red
color1 #F38BA8
color9 #F38BA8

# green
color2  #A6E3A1
color10 #A6E3A1

# yellow
color3  #F9E2AF
color11 #F9E2AF

# blue
color4  #87B0F9
color12 #87B0F9

# magenta
color5  #F5C2E7
color13 #F5C2E7

# cyan
color6  #94E2D5
color14 #94E2D5

# white
color7  #CDD6F4
color15 #A1A8C9
KITTY_THEMES

}

# ===== MAIN =====

main() {
    show_banner
    
    init_state
    
    log "Starting complete setup..."
    log "Log file: $LOG"
    log "Backup directory: $BACKUP_DIR"
    echo ""
    
    # Execute all setup functions
    setup_nvidia_cleanup
    setup_system_update
    setup_nvidia_drivers
    setup_base_packages
    setup_hyprland_caelestia
    setup_gaming
    setup_development
    setup_unreal_engine_deps
    setup_multimedia
    setup_ai_ml
    setup_ai_environments
    setup_blender
    setup_creative_suite
    setup_streaming
    setup_system_optimization
    setup_monitors
    setup_vietnamese_input
    #setup_sddm
    setup_gdm
    setup_directories
    setup_utilities
    setup_helper_scripts
    setup_configs
    
    # Done
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      ✓ INSTALLATION COMPLETED SUCCESSFULLY!                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Installed Features:${NC}"
    echo "  ✓ NVIDIA drivers (proprietary)"
    echo "  ✓ Hyprland Caelestia desktop"
    echo "  ✓ Gaming suite"
    echo "  ✓ Development tools (C#, Docker, VS Code, Rider)"
    echo "  ✓ Unreal Engine 5 dependencies"
    echo "  ✓ AI/ML stack (Ollama, SD, Text Gen, ComfyUI)"
    echo "  ✓ Blender with GPU optimization"
    echo "  ✓ Creative Suite (GIMP, Inkscape, Kdenlive, etc.)"
    echo "  ✓ Streaming tools (OBS, Vesktop)"
    echo "  ✓ Multi-monitor support"
    echo "  ✓ Vietnamese input (Fcitx5)"
    echo "  ✓ SDDM"
    echo "  ✓ System optimizations"
    echo "  ✓ Helper scripts"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. ${GREEN}sudo reboot${NC}"
    echo "  2. Login to Hyprland from SDDM"
    echo "  3. Check GPU: ${BLUE}nvidia-smi${NC}"
    echo "  4. Vietnamese input: ${BLUE}fcitx5-configtool${NC} (Ctrl+Space to toggle)"
    echo ""
    echo "Logs: $LOG"
    echo "Backup: $BACKUP_DIR"
    echo ""
}

main "$@"
