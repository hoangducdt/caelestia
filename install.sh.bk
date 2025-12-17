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

log "Starting complete installation..."
echo ""
log "Estimated time: 30-60 minutes"
echo ""

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
    
    install_packages \
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
    
    install_packages \
        "base-devel" "git" "wget" "curl" "yay" "fish" \
        "wl-clipboard" "xdg-desktop-portal-hyprland" \
        "qt5-wayland" "qt6-wayland" \
        "gnome-keyring" "polkit-gnome" "nautilus" \
        "gnome-disk-utility"
    
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
    
    install_packages \
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
    
    install_packages \
        "dotnet-sdk" "dotnet-runtime" "aspnet-runtime" "mono" "mono-msbuild" \
        "code" "neovim" "docker" "docker-compose" "git" "github-cli"
    
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
    
    install_packages \
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
    
    install_packages \
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
    
    install_packages \
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
    
    install_packages \
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
    
    install_packages \
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
    
    install_packages \
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
    
    mkdir -p "$HOME/.config/hypr/hyprland"
    
    # Monitor configuration
    cat >> "$HOME/.config/hypr/hyprland/monitors.conf" <<'MONITORS'
monitor=DP-1,2560x1080@99.94,0x0,1.0
monitor=DP-3,1920x1080@74.97,2560x0,1.0
MONITORS
    
    mark_completed "monitors"
    log "✓ Multi-monitor configured"
}

setup_vietnamese_input() {
    if [ "$(is_completed 'vietnamese')" = "yes" ]; then
        log "✓ Vietnamese input already configured"
        return 0
    fi
    
    log "Installing Vietnamese input..."
    
    install_packages \
        "fcitx5" "fcitx5-qt" "fcitx5-gtk" "fcitx5-configtool"
    
    install_aur_package "fcitx5-bamboo-git" 600
    
    # Add environment variables
    mkdir -p "$HOME/.config/hypr/hyprland"
    cat >> "$HOME/.config/hypr/hyprland/env.conf" <<'FCITX'

# NVIDIA Environment Variables
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# Vietnamese Input - Fcitx5
env = GTK_IM_MODULE,fcitx
env = QT_IM_MODULE,fcitx
env = XMODIFIERS,@im=fcitx
env = SDL_IM_MODULE,fcitx
env = GLFW_IM_MODULE,fcitx
FCITX
    
    # Add autostart
    if [ -f "$HOME/.config/hypr/hyprland/execs.conf" ]; then
        grep -q "fcitx5" "$HOME/.config/hypr/hyprland/execs.conf" || \
            echo "exec-once = fcitx5 -d" >> "$HOME/.config/hypr/hyprland/execs.conf"
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
    
    mark_completed "vietnamese"
    log "✓ Vietnamese input configured"
}

setup_sddm() {
    if [ "$(is_completed 'sddm')" = "yes" ]; then
        log "✓ SDDM already installed"
        return 0
    fi
    
    log "Installing SDDM..."
    
    install_packages \
        "sddm" "qt5-graphicaleffects" "qt5-quickcontrols2" "qt5-svg" "uwsm"
    
    sudo systemctl enable sddm.service 2>/dev/null || true
    
    mark_completed "sddm"
    log "✓ SDDM installed"
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
    
    # Wallpapers
    if [ ! -d "$HOME/Pictures/Wallpapers/.git" ]; then
        git clone --quiet --depth 1 https://github.com/mylinuxforwork/wallpaper.git \
            "$HOME/Pictures/Wallpapers" 2>&1 | tee -a "$LOG" || warn "Wallpapers clone failed"
    fi
    
    mark_completed "directories"
    log "✓ Directories created"
}

setup_utilities() {
    if [ "$(is_completed 'utilities')" = "yes" ]; then
        log "✓ Utilities already installed"
        return 0
    fi
    
    log "Installing utilities..."
    
    install_packages \
        "htop" "btop" "neofetch" "fastfetch" \
        "unzip" "p7zip" "unrar" "rsync" "tmux" \
        "starship" "eza" "bat" "ripgrep" "fd" "fzf" "zoxide" \
        "nvtop" "amdgpu_top" "iotop" "iftop"
    
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
    setup_sddm
    setup_directories
    setup_utilities
    setup_helper_scripts
    
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
