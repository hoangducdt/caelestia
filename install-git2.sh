#!/usr/bin/env bash

# =============================================================================
# CAELESTIA INSTALLER v2.0 - Complete Refactored Version
# =============================================================================
# Target: CachyOS + Hyprland
# Hardware: ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB
# Author: Refactored & Improved
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

readonly SCRIPT_VERSION="2.0.0"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
readonly RED='\e[38;2;255;0;0m'
readonly GREEN='\e[38;2;0;255;0m'
readonly YELLOW='\e[38;2;255;255;0m'
readonly BLUE='\e[38;2;0;150;255m'
readonly MAGENTA='\e[38;2;234;0;255m'
readonly CYAN='\e[38;2;0;255;255m'
readonly NC='\e[0m'

# Directories
readonly STATE_DIR="$HOME/.cache/caelestia-setup"
readonly STATE_FILE="$STATE_DIR/state.json"
readonly LOG_DIR="$STATE_DIR/logs"
readonly BACKUP_DIR="$HOME/Documents/caelestia-backups/${TIMESTAMP}"

# Logs
readonly LOG_FILE="$LOG_DIR/install.log"
readonly ERROR_LOG="$LOG_DIR/errors.log"
readonly PKG_LOG="$LOG_DIR/packages.log"

# Repository
readonly REPO_URL="https://github.com/hoangducdt/Hyprland.git"
readonly REPO_DIR="$HOME/.local/share/Hyprland"

# Requirements
readonly MIN_DISK_GB=50
readonly MIN_RAM_GB=8

# Hardware flags
HAS_NVIDIA_GPU=false
HAS_AMD_CPU=false

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}⚠ [$(date +'%H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE" "$ERROR_LOG"
}

log_error() {
    echo -e "${RED}✗ [$(date +'%H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE" "$ERROR_LOG" >&2
}

log_success() {
    echo -e "${GREEN}✓ [$(date +'%H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${CYAN}ℹ [$(date +'%H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

error_exit() {
    log_error "$1"
    log_error "Logs: $LOG_FILE | $ERROR_LOG"
    exit 1
}

# =============================================================================
# SYSTEM VALIDATION
# =============================================================================

validate_system() {
    log_info "Running system validation..."
    
    # Check Arch-based
    [[ ! -f /etc/arch-release ]] && error_exit "Requires Arch-based system"
    
    # Check disk space
    local available_gb
    available_gb=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $available_gb -lt $MIN_DISK_GB ]]; then
        log_warn "Low disk: ${available_gb}GB (need ${MIN_DISK_GB}GB+)"
        read -rp "Continue? (y/N): " response
        [[ ! "$response" =~ ^[Yy]$ ]] && exit 1
    fi
    
    # Check internet
    ping -c 1 -W 2 archlinux.org &>/dev/null || error_exit "No internet connection"
    
    # Detect hardware
    lspci | grep -qi nvidia && HAS_NVIDIA_GPU=true
    lscpu | grep -qi "vendor.*amd" && HAS_AMD_CPU=true
    
    log_success "System validation passed"
    log_info "NVIDIA GPU: $HAS_NVIDIA_GPU | AMD CPU: $HAS_AMD_CPU"
}

# =============================================================================
# STATE MANAGEMENT
# =============================================================================

init_state() {
    mkdir -p "$STATE_DIR" "$LOG_DIR" "$BACKUP_DIR"
    
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" <<EOF
{
  "version": "$SCRIPT_VERSION",
  "start_time": "$(date -Iseconds)",
  "phases": {}
}
EOF
    fi
}

is_completed() {
    local phase="$1"
    python3 -c "
import json, sys
try:
    with open('$STATE_FILE') as f:
        state = json.load(f)
    print('yes' if state.get('phases', {}).get('$phase', {}).get('status') == 'completed' else 'no')
except: print('no')
" 2>/dev/null || echo "no"
}

mark_completed() {
    local phase="$1"
    python3 -c "
import json
try:
    with open('$STATE_FILE') as f:
        state = json.load(f)
    state.setdefault('phases', {})['$phase'] = {
        'status': 'completed',
        'time': '$(date -Iseconds)'
    }
    with open('$STATE_FILE', 'w') as f:
        json.dump(state, f, indent=2)
except: pass
" 2>/dev/null || true
}

# =============================================================================
# PACKAGE MANAGEMENT
# =============================================================================

is_installed() {
    pacman -Qi "$1" &>/dev/null
}

install_pkg() {
    local pkg="$1"
    local retries=3
    
    is_installed "$pkg" && return 0
    
    for ((i=1; i<=retries; i++)); do
        if sudo pacman -S --noconfirm --needed "$pkg" 2>&1 | tee -a "$PKG_LOG"; then
            return 0
        fi
        [[ $i -lt $retries ]] && sleep 2
    done
    
    log_warn "Failed: $pkg"
    return 1
}

install_aur() {
    local pkg="$1"
    is_installed "$pkg" && return 0
    
    command -v yay &>/dev/null || return 1
    timeout 600 yay -S --noconfirm --needed "$pkg" 2>&1 | tee -a "$PKG_LOG"
}

batch_install() {
    local -n pkgs=$1
    local total=${#pkgs[@]}
    local failed=0
    
    log_info "Installing ${total} packages..."
    
    for ((i=0; i<total; i++)); do
        local pkg="${pkgs[$i]}"
        local progress=$(((i+1)*100/total))
        
        if is_installed "$pkg"; then
            log_info "[$progress%] ✓ $pkg"
            continue
        fi
        
        log_info "[$progress%] Installing $pkg..."
        
        if pacman -Si "$pkg" &>/dev/null; then
            install_pkg "$pkg" || ((failed++))
        else
            install_aur "$pkg" || ((failed++))
        fi
    done
    
    [[ $failed -eq 0 ]] && log_success "All installed: $total/$total" || log_warn "Partial: $((total-failed))/$total"
}

# =============================================================================
# SUDO KEEPALIVE
# =============================================================================

setup_sudo() {
    sudo -v || error_exit "sudo required"
    
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &
    SUDO_PID=$!
    trap 'kill $SUDO_PID 2>/dev/null' EXIT
}

# =============================================================================
# BANNER
# =============================================================================

show_banner() {
    clear
    echo -e "${MAGENTA}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║   ██████╗ █████╗ ███████╗██╗     ███████╗███████╗████████╗██╗ █████╗   ║
║  ██╔════╝██╔══██╗██╔════╝██║     ██╔════╝██╔════╝╚══██╔══╝██║██╔══██╗  ║
║  ██║     ███████║█████╗  ██║     █████╗  ███████╗   ██║   ██║███████║  ║
║  ██║     ██╔══██║██╔══╝  ██║     ██╔══╝  ╚════██║   ██║   ██║██╔══██║  ║
║  ╚██████╗██║  ██║███████╗███████╗███████╗███████║   ██║   ██║██║  ██║  ║
║   ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═╝  ║
║                                                                          ║
║  Installer v2.0 - Optimized for CachyOS + Hyprland                      ║
║  Hardware: ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB           ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# =============================================================================
# PHASE IMPLEMENTATIONS
# =============================================================================

phase_system_update() {
    [[ "$(is_completed system_update)" == "yes" ]] && { log_success "✓ System update"; return 0; }
    
    log_info "━━━ PHASE 1: SYSTEM UPDATE ━━━"
    
    sudo pacman -Sy --noconfirm archlinux-keyring cachyos-keyring 2>&1 | tee -a "$LOG_FILE" || true
    
    for i in {1..3}; do
        if sudo pacman -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"; then
            mark_completed system_update
            log_success "System updated"
            return 0
        fi
        [[ $i -lt 3 ]] && sudo pacman -Syy && sleep 3
    done
    
    log_warn "Update issues, continuing..."
    mark_completed system_update
}

phase_base_packages() {
    [[ "$(is_completed base_packages)" == "yes" ]] && { log_success "✓ Base packages"; return 0; }
    
    log_info "━━━ PHASE 2: BASE PACKAGES ━━━"
    
    # Enable multilib
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
        sudo pacman -Sy
    fi
    
    local packages=(
        base-devel git git-lfs wget curl rsync tmux jq i2c-tools dmidecode
        fwupd libnotify inotify-tools paru yay zip unzip p7zip unrar ark
        btrfs-progs exfatprogs ntfs-3g dosfstools
        python python-pip python-virtualenv python-build python-installer
    )
    
    batch_install packages
    mark_completed base_packages
}

phase_nvidia() {
    [[ "$(is_completed nvidia)" == "yes" ]] && { log_success "✓ NVIDIA"; return 0; }
    
    log_info "━━━ PHASE 3: NVIDIA OPTIMIZATION ━━━"
    
    if [[ "$HAS_NVIDIA_GPU" != "true" ]]; then
        log_info "No NVIDIA GPU, skipping"
        mark_completed nvidia
        return 0
    fi
    
    is_installed "nvidia-utils" || error_exit "NVIDIA drivers not installed"
    
    # Backup
    [[ -f /etc/mkinitcpio.conf ]] && sudo cp /etc/mkinitcpio.conf "$BACKUP_DIR/"
    
    # Modprobe config
    sudo tee /etc/modprobe.d/nvidia.conf >/dev/null <<'NVIDIA'
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_DynamicPowerManagement=0x02
NVIDIA
    
    # Mkinitcpio
    if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
        sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        sudo mkinitcpio -P
    fi
    
    # Services
    for svc in nvidia-suspend nvidia-hibernate nvidia-resume; do
        sudo systemctl enable "${svc}.service" 2>/dev/null || true
    done
    
    mark_completed nvidia
    log_success "NVIDIA configured (reboot required)"
}

phase_display() {
    [[ "$(is_completed display)" == "yes" ]] && { log_success "✓ Display"; return 0; }
    
    log_info "━━━ PHASE 4: DISPLAY & GRAPHICS ━━━"
    
    local packages=(
        qt5-wayland qt6-wayland wl-clipboard
        xdg-desktop-portal-gtk xdg-desktop-portal-hyprland
        vulkan-icd-loader lib32-vulkan-icd-loader
        lib32-mesa lib32-libglvnd libva-utils mesa-utils
    )
    
    [[ "$HAS_NVIDIA_GPU" == "true" ]] && packages+=(libva-nvidia-driver lib32-nvidia-utils nvidia-settings)
    
    batch_install packages
    mark_completed display
}

phase_audio() {
    [[ "$(is_completed audio)" == "yes" ]] && { log_success "✓ Audio"; return 0; }
    
    log_info "━━━ PHASE 5: AUDIO (PipeWire) ━━━"
    
    is_installed jack2 && sudo pacman -Rdd --noconfirm jack2 2>&1 | tee -a "$LOG_FILE" || true
    
    local packages=(
        pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
        pavucontrol helvum easyeffects qpwgraph
        v4l2loopback-dkms noise-suppression-for-voice
    )
    
    batch_install packages
    
    systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
    
    mark_completed audio
}

phase_codecs() {
    [[ "$(is_completed codecs)" == "yes" ]] && { log_success "✓ Codecs"; return 0; }
    
    log_info "━━━ PHASE 6: MULTIMEDIA CODECS ━━━"
    
    local packages=(
        gstreamer gstreamer-vaapi gst-plugins-{base,good,bad,ugly} gst-libav
        ffmpeg lib32-ffmpeg x264 x265
        libvorbis lib32-libvorbis opus lib32-opus flac lib32-flac
    )
    
    batch_install packages
    mark_completed codecs
}

phase_development() {
    [[ "$(is_completed development)" == "yes" ]] && { log_success "✓ Development"; return 0; }
    
    log_info "━━━ PHASE 7: DEVELOPMENT TOOLS ━━━"
    
    local packages=(
        cmake ninja meson ccache gcc clang lld
        github-cli github-desktop nodejs npm go
        python-numpy python-pandas python-matplotlib python-pillow
        python-scipy python-scikit-learn jupyter-notebook
        dotnet-runtime dotnet-sdk-8.0 dotnet-sdk aspnet-runtime mono mono-msbuild
        neovim codium kate rider assimp fbx-sdk
    )
    
    batch_install packages
    
    # Rust via rustup
    if ! command -v rustc &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    dotnet new install "Avalonia.Templates" 2>&1 | tee -a "$LOG_FILE" || true
    
    mark_completed development
}

phase_docker() {
    [[ "$(is_completed docker)" == "yes" ]] && { log_success "✓ Docker"; return 0; }
    
    log_info "━━━ PHASE 8: DOCKER ━━━"
    
    local packages=(docker docker-compose postgresql redis)
    [[ "$HAS_NVIDIA_GPU" == "true" ]] && packages+=(nvidia-container-toolkit)
    
    batch_install packages
    
    # Configure
    getent group docker >/dev/null || sudo groupadd docker
    sudo usermod -aG docker "$USER"
    
    [[ -f /etc/docker/daemon.json ]] && sudo cp /etc/docker/daemon.json "$BACKUP_DIR/"
    
    if [[ "$HAS_NVIDIA_GPU" == "true" ]]; then
        sudo tee /etc/docker/daemon.json >/dev/null <<'DOCKER'
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {"max-size": "100m"},
  "storage-driver": "overlay2",
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
DOCKER
        sudo nvidia-ctk runtime configure --runtime=docker 2>&1 | tee -a "$LOG_FILE" || true
    else
        sudo tee /etc/docker/daemon.json >/dev/null <<'DOCKER'
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {"max-size": "100m"},
  "storage-driver": "overlay2"
}
DOCKER
    fi
    
    sudo systemctl enable --now docker.service docker.socket
    mkdir -p "$HOME/docker"/{compose,volumes/{postgres,redis,mysql}}
    
    mark_completed docker
    log_warn "⚠ Log out/in for docker group"
}

phase_gaming() {
    [[ "$(is_completed gaming)" == "yes" ]] && { log_success "✓ Gaming"; return 0; }
    
    log_info "━━━ PHASE 9: GAMING ━━━"
    
    local packages=(
        gamemode lib32-gamemode xpadneo-dkms
        cachyos-gaming-meta cachyos-gaming-applications
        protonup-qt asf
    )
    
    batch_install packages
    
    sudo usermod -aG gamemode "$USER"
    
    # Configure ASF
    if [[ -d /usr/lib/asf ]]; then
        sudo chown -R "$USER:$USER" /usr/lib/asf/
        cd /usr/lib/asf && mkdir -p www
        
        if [[ ! -d temp-ui/.git ]]; then
            git clone --depth 1 https://github.com/JustArchiNET/ASF-ui.git temp-ui 2>&1 | tee -a "$LOG_FILE" || true
            [[ -d temp-ui ]] && cd temp-ui && npm install && npm run build && cd .. && cp -r temp-ui/dist/* www/ && rm -rf temp-ui
        fi
    fi
    
    mark_completed gaming
}

phase_ai_ml() {
    [[ "$(is_completed ai_ml)" == "yes" ]] && { log_success "✓ AI/ML"; return 0; }
    
    log_info "━━━ PHASE 10: AI/ML ━━━"
    
    if [[ "$HAS_NVIDIA_GPU" != "true" ]]; then
        log_info "No NVIDIA GPU, skipping CUDA"
        mark_completed ai_ml
        return 0
    fi
    
    local packages=(
        cuda cudnn python-pytorch-cuda python-torchvision-cuda
        python-torchaudio-cuda python-transformers python-accelerate
    )
    
    batch_install packages
    
    # Ollama
    if ! command -v ollama &>/dev/null; then
        curl -fsSL https://ollama.com/install.sh | sh 2>&1 | tee -a "$LOG_FILE"
    fi
    
    local model_dir="$HOME/AI-Models/ollama"
    mkdir -p "$model_dir"
    
    id -u ollama &>/dev/null || sudo useradd -r -s /bin/false -U -m -d /usr/share/ollama ollama 2>/dev/null || true
    sudo usermod -a -G ollama "$USER"
    sudo chown -R ollama:ollama "$model_dir"
    sudo chmod -R 770 "$model_dir"
    
    sudo tee /etc/systemd/system/ollama.service >/dev/null <<OLLAMA
[Unit]
Description=Ollama Service
After=network-online.target docker.service

[Service]
ExecStart=/usr/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="OLLAMA_MODELS=$model_dir"

[Install]
WantedBy=multi-user.target
OLLAMA
    
    sudo systemctl daemon-reload
    sudo systemctl enable ollama
    
    mark_completed ai_ml
}

phase_creative() {
    [[ "$(is_completed creative)" == "yes" ]] && { log_success "✓ Creative"; return 0; }
    
    log_info "━━━ PHASE 11: CREATIVE SUITE ━━━"
    
    local packages=(
        blender openimagedenoise opencolorio opensubdiv openvdb embree
        openimageio alembic gimp gimp-plugin-gmic krita inkscape
        darktable rawtherapee imagemagick imv gwenview
        kdenlive frei0r-plugins mediainfo mlt davinci-resolve natron
        mpv vlc audacity ardour obs-studio obs-vaapi obs-nvfbc obs-vkcapture
        zathura zathura-pdf-poppler okular scribus
    )
    
    batch_install packages
    
    sudo modprobe v4l2loopback 2>/dev/null || true
    echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
    
    mark_completed creative
}

phase_hyprland() {
    [[ "$(is_completed hyprland)" == "yes" ]] && { log_success "✓ Hyprland"; return 0; }
    
    log_info "━━━ PHASE 12: HYPRLAND & DESKTOP ━━━"
    
    local packages=(
        hyprland uwsm hyprpicker cliphist wlr-randr kanshi nwg-displays
        brightnessctl ddcutil grim slurp swappy gpu-screen-recorder fuzzel
        caelestia-cli quickshell-git fish kitty starship
        eza bat ripgrep fd fzf zoxide direnv trash-cli
        htop btop fastfetch nvtop lm_sensors thunar thunar-archive-plugin
        tumbler ffmpegthumbnailer adw-gtk-theme papirus-icon-theme
        tela-circle-icon-theme-git qt5ct-kde qt6ct-kde nwg-look
        gnome-keyring polkit-gnome networkmanager network-manager-applet
        nm-connection-editor iwd bluez bluez-utils blueman gdm gdm-settings
        openrgb fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool fcitx5-bamboo-git
        microsoft-edge-stable-bin vesktop-bin todoist-appimage
        ttf-material-symbols-variable ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd
        ttf-rubik-vf adobe-source-code-pro-fonts ttf-liberation ttf-dejavu
        matugen cava libcava
    )
    
    [[ "$HAS_AMD_CPU" == "true" ]] && packages+=(zenmonitor corectrl ryzenadj auto-cpufreq)
    
    batch_install packages
    
    sudo systemctl enable NetworkManager gdm.service
    
    mark_completed hyprland
}

phase_optimization() {
    [[ "$(is_completed optimization)" == "yes" ]] && { log_success "✓ Optimization"; return 0; }
    
    log_info "━━━ PHASE 13: SYSTEM OPTIMIZATION ━━━"
    
    sudo cpupower frequency-set -g performance 2>&1 | tee -a "$LOG_FILE" || true
    
    sudo tee /etc/systemd/system/cpupower-performance.service >/dev/null <<'CPUPOWER'
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance

[Install]
WantedBy=multi-user.target
CPUPOWER
    
    sudo systemctl enable cpupower-performance.service
    sudo systemctl enable irqbalance thermald 2>/dev/null || true
    
    sudo tee /etc/sysctl.d/99-optimization.conf >/dev/null <<'SYSCTL'
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
fs.inotify.max_user_watches=524288
fs.file-max=2097152
SYSCTL
    
    sudo sysctl -p /etc/sysctl.d/99-optimization.conf
    
    sudo tee /etc/udev/rules.d/60-ioschedulers.rules >/dev/null <<'IOSCHED'
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="bfq"
IOSCHED
    
    mark_completed optimization
}

phase_i2c() {
    [[ "$(is_completed i2c)" == "yes" ]] && { log_success "✓ I2C"; return 0; }
    
    log_info "━━━ PHASE 14: I2C (RGB) ━━━"
    
    sudo modprobe i2c-dev i2c-piix4 2>&1 | tee -a "$LOG_FILE" || true
    
    sudo tee /etc/modules-load.d/i2c.conf >/dev/null <<'I2C'
i2c-dev
i2c-piix4
I2C
    
    getent group i2c >/dev/null || sudo groupadd i2c
    sudo usermod -aG i2c "$USER"
    
    sudo tee /etc/udev/rules.d/99-i2c.rules >/dev/null <<'I2C_UDEV'
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
I2C_UDEV
    
    sudo udevadm control --reload-rules && sudo udevadm trigger
    sudo sensors-detect --auto 2>&1 | tee -a "$LOG_FILE" || true
    
    mark_completed i2c
    log_warn "⚠ Reboot for I2C changes"
}

phase_repository() {
    [[ "$(is_completed repository)" == "yes" ]] && { log_success "✓ Repository"; return 0; }
    
    log_info "━━━ PHASE 15: CLONE REPOSITORY ━━━"
    
    if [[ -d "$REPO_DIR/.git" ]]; then
        cd "$REPO_DIR" && git pull 2>&1 | tee -a "$LOG_FILE" || log_warn "Pull failed"
    else
        git clone "$REPO_URL" "$REPO_DIR" 2>&1 | tee -a "$LOG_FILE" || error_exit "Clone failed"
    fi
    
    [[ ! -d "$REPO_DIR/Configs" ]] && log_warn "Missing Configs directory"
    
    mark_completed repository
}

phase_directories() {
    [[ "$(is_completed directories)" == "yes" ]] && { log_success "✓ Directories"; return 0; }
    
    log_info "━━━ PHASE 16: CREATE DIRECTORIES ━━━"
    
    mkdir -p "$HOME"/{Desktop,Documents,Downloads,Music,Videos,OneDrive}
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME"/{AI-Projects,AI-Models,Creative-Projects,Blender-Projects}
    mkdir -p "$HOME/.local/bin"
    
    mkdir -p "$HOME/.config"/{btop,caelestia,fastfetch/logo,fish/functions}
    mkdir -p "$HOME/.config/hypr"/{hyprland,scheme,scripts}
    mkdir -p "$HOME/.config"/{kitty,MangoHud,micro,Thunar,uwsm,vscode,xfce4}
    mkdir -p "$HOME/.config"/{gtk-3.0,qt5ct,qt6ct,VSCodium/User}
    mkdir -p "$HOME/.config/spicetify/Themes/caelestia"
    
    sudo mkdir -p /var/lib/AccountsService/users
    
    if [[ ! -d "$HOME/Pictures/Wallpapers/.git" ]]; then
        git clone --quiet --depth 1 https://github.com/mylinuxforwork/wallpaper.git 
"HOME/Pictures/Wallpapers" 2>&1 | tee -a "
LOG_FILE" || log_warn "Wallpapers failed"
    fi

mark_completed directories
}
phase_configs() {
[[ "$(is_completed configs)" == "yes" ]] && { log_success "✓ Configs"; return 0; }
log_info "━━━ PHASE 17: INSTALL CONFIGS ━━━"

local configs_dir="$REPO_DIR/Configs"
[[ ! -d "$configs_dir" ]] && error_exit "Configs directory not found"

# Symlink function
symlink_config() {
    local src="$1" tgt="$2" rel="$3"
    
    if [[ -L "$tgt" ]]; then
        local cur=$(readlink -f "$tgt" 2>/dev/null || echo "")
        local abs=$(realpath "$src" 2>/dev/null || echo "")
        [[ "$cur" == "$abs" ]] && { log_info "  ✓ $rel"; return 0; }
    fi
    
    if [[ -e "$tgt" ]] || [[ -L "$tgt" ]]; then
        local bkp="$BACKUP_DIR/configs/$rel"
        mkdir -p "$(dirname "$bkp")"
        cp -rL "$tgt" "$bkp" 2>/dev/null || true
        rm -rf "$tgt" 2>/dev/null || true
    fi
    
    mkdir -p "$(dirname "$tgt")"
    ln -sf "$(realpath "$src")" "$tgt" && log_info "  ✓ Linked: $rel"
}

# Process configs
find "$configs_dir" -mindepth 1 -maxdepth 1 ! -name '.*' -print0 | while IFS= read -r -d '' item; do
    local name=$(basename "$item")
    
    if [[ -d "$item" ]] && [[ ! -L "$item" ]]; then
        mkdir -p "$HOME/$name"
        find "$item" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' sub; do
            symlink_config "$sub" "$HOME/$name/$(basename "$sub")" "$name/$(basename "$sub")"
        done
    else
        symlink_config "$item" "$HOME/$name" "$name"
    fi
done

# Make scripts executable
[[ -d "$HOME/.config/hypr/scripts" ]] && chmod +x "$HOME/.config/hypr/scripts"/*.sh 2>/dev/null || true
[[ -f "$HOME/.config/fastfetch/fastfetch.sh" ]] && chmod +x "$HOME/.config/fastfetch/fastfetch.sh"

# GDM avatar
local icon_path="$HOME/.face"
[[ -L "$icon_path" ]] && icon_path=$(readlink -f "$icon_path")

local acc_file="/var/lib/AccountsService/users/$USER"
sudo tee "$acc_file" >/dev/null <<ACC
[User]
Icon=$icon_path
ACC
sudo chmod 644 "$acc_file"
# DNS configuration
sudo sed -i 's|^#\?DNS=.*|DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com|' /etc/systemd/resolved.conf
sudo sed -i 's|^#\?DNSOverTLS=.*|DNSOverTLS=yes|' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved 2>/dev/null || true

# Static IP (optional)
local iface=$(ip route | grep default | awk '{print $5}' | head -n1)
if [[ -n "$iface" ]]; then
    sudo tee /etc/NetworkManager/system-connections/static-ethernet.nmconnection >/dev/null <<STATIC
[connection]
id=static-ethernet
type=ethernet
interface-name=$iface
autoconnect=true
[ipv4]
method=manual
address1=192.168.1.2/24,192.168.1.1
dns=1.1.1.1;1.0.0.1;
[ipv6]
method=auto
STATIC
sudo chmod 600 /etc/NetworkManager/system-connections/static-ethernet.nmconnection
sudo systemctl reload NetworkManager 2>/dev/null || true
fi
# GTK bookmarks
cat >> "$HOME/.config/gtk-3.0/bookmarks" <<BOOKMARKS
file://$HOME/Downloads
file://$HOME/Documents
file://$HOME/Pictures
file://$HOME/Videos
file://$HOME/Music
BOOKMARKS
mark_completed configs
}
phase_caelestia() {
[[ "$(is_completed caelestia)" == "yes" ]] && { log_success "✓ Caelestia"; return 0; }
log_info "━━━ PHASE 18: CAELESTIA SHELL ━━━"

local shell_dir="$HOME/.config/quickshell/caelestia"
mkdir -p "$(dirname "$shell_dir")"

if [[ -d "$shell_dir/.git" ]]; then
    cd "$shell_dir" && git pull 2>&1 | tee -a "$LOG_FILE" || log_warn "Pull failed"
else
    git clone https://github.com/hoangducdt/shell.git "$shell_dir" 2>&1 | tee -a "$LOG_FILE" || error_exit "Clone failed"
fi

cd "$shell_dir"
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/ -DINSTALL_QSCONFDIR="$shell_dir" || error_exit "CMake failed"
cmake --build build || error_exit "Build failed"
sudo cmake --install build || error_exit "Install failed"
sudo chown -R "$USER:$USER" "$shell_dir"

mark_completed caelestia
}
=============================================================================
VERIFICATION & SUMMARY
=============================================================================
verify_install() {
log_info "━━━ VERIFICATION ━━━"
local critical=(hyprland docker python)
[[ "$HAS_NVIDIA_GPU" == "true" ]] && critical+=(nvidia-utils cuda)

local failed=()
for pkg in "${critical[@]}"; do
    is_installed "$pkg" || failed+=("$pkg")
done

[[ ${#failed[@]} -gt 0 ]] && log_warn "Missing critical: ${failed[*]}"

log_success "Verification complete"
}
generate_summary() {
local summary="$HOME/caelestia-install-summary.txt"
cat > "$summary" <<SUMMARY
╔══════════════════════════════════════════════════════════════════╗
║            CAELESTIA INSTALLATION SUMMARY                        ║
╚══════════════════════════════════════════════════════════════════╝
Installation completed: $(date '+%Y-%m-%d %H:%M:%S')
Version: $SCRIPT_VERSION
Hardware Detected:
• NVIDIA GPU: $HAS_NVIDIA_GPU
• AMD CPU: $HAS_AMD_CPU
Logs:
• Main: $LOG_FILE
• Errors: $ERROR_LOG
• Packages: $PKG_LOG
Backups:
• Location: $BACKUP_DIR
Next Steps:

Review any warnings in $ERROR_LOG
REBOOT to apply all changes
Log out/in for group memberships (docker, gamemode, i2c)
Test NVIDIA: nvidia-smi
Test Docker: docker run hello-world

Support:
• Report issues: https://github.com/hoangducdt/Hyprland/issues
SUMMARY
log_success "Summary saved: $summary"
}
=============================================================================
MAIN EXECUTION
=============================================================================
main() {
show_banner
# Initialize
validate_system
init_state
setup_sudo

# Execute phases
phase_system_update
phase_base_packages
phase_nvidia
phase_display
phase_audio
phase_codecs
phase_development
phase_docker
phase_gaming
phase_ai_ml
phase_creative
phase_hyprland
phase_optimization
phase_i2c
phase_repository
phase_directories
phase_configs
phase_caelestia

# Finalize
verify_install
generate_summary

echo -e "\n${GREEN}"
cat <<'DONE'
╔══════════════════════════════════════════════════════════════════╗
║         🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉               ║
╚══════════════════════════════════════════════════════════════════╝
DONE
echo -e "${NC}"
log_info "Logs: $LOG_FILE"
log_info "Backup: $BACKUP_DIR"
log_warn "⚠️  REBOOT REQUIRED to apply all changes"

read -rp "Reboot now? (y/N): " response
[[ "$response" =~ ^[Yy]$ ]] && sudo reboot
}
main "$@"