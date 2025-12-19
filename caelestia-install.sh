#!/bin/bash

# ================================================================================================
# CAELESTIA INSTALLER - OPTIMIZED FOR CACHYOS
# ================================================================================================
# Target System: CachyOS + Hyprland + Caelestia dots file
# Hardware: ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB
# Optimizations: Conflict resolution, CachyOS-specific packages, performance tuning
# ================================================================================================

set -e

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

readonly LOG="$HOME/setup_complete_$(date +%Y%m%d_%H%M%S).log"
readonly STATE_DIR="$HOME/.cache/caelestia-setup"
readonly STATE_FILE="$STATE_DIR/setup_state.json"
readonly BACKUP_DIR="$HOME/Documents/caelestia-configs-$(date +%Y%m%d_%H%M%S)"

LOG_FILE="$HOME/caelestia_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${GREEN}▶${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
warning() { echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"; }
ai_info() { echo -e "${MAGENTA}[AI/ML]${NC} $1" | tee -a "$LOG_FILE"; }
creative_info() { echo -e "${CYAN}[CREATIVE]${NC} $1" | tee -a "$LOG_FILE"; }

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

clone_repo(){
    git clone https://github.com/hoangducdt/caelestia.git $HOME/.local/share/caelestia
    cd $HOME/.local/share/caelestia/
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

# ===== BANNER =====

show_banner() {
    clear
    echo -e "${MAGENTA}"
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

install_helper(){
    local helper_pkgs=(
        "base-devel"
        "git"
        "wget"
        "curl"
        "yay"
    )
    
    install_packages "${helper_pkgs[@]}"
}

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

install_packages() {
    local packages=("$@")
    local failed=()
    
    for pkg in "${packages[@]}"; do
        # Skip if already installed
        if pacman -Qi "$pkg" &>/dev/null; then
            continue
        fi
        
        # Check if package exists in official repos
        if pacman -Si "$pkg" &>/dev/null 2>&1; then
            # Package found in official repos, install with pacman
            if ! install_package "$pkg"; then
                failed+=("$pkg")
            fi
        else
            # Package not in official repos, try AUR with yay
            log "Package '$pkg' not found in official repos, trying AUR..."
            if ! install_aur_package "$pkg"; then
                failed+=("$pkg")
            fi
        fi
    done
    
    if [ ${#failed[@]} -gt 0 ]; then
        warn "Failed packages: ${failed[*]}"
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

# ===== SETUP FUNCTIONS =====

setup_nvidia_cleanup() {
    if [ "$(is_completed 'nvidia_cleanup')" = "yes" ]; then
        log "✓ NVIDIA cleanup already done"
        return 0
    fi
    
    log "Checking for NVIDIA driver conflicts..."
    
    # Only remove packages that ACTUALLY conflict
    # DO NOT remove nvidia-utils or other main packages that might already be installed correctly
    local conflict_pkgs=(
        "nvidia-open"                        # Open vs proprietary conflict
        "lib32-nvidia-open"                  
        "nvidia-open-dkms"                   
        "linux-cachyos-nvidia-open"          # Kernel-specific open drivers
        "linux-cachyos-lts-nvidia-open"     
    )
    
    local found_conflicts=false
    for pkg in "${conflict_pkgs[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            log "Removing conflicting package: $pkg"
            safe_remove_package "$pkg"
            found_conflicts=true
        fi
    done
    
    if [ "$found_conflicts" = false ]; then
        log "✓ No conflicts found"
    else
        log "✓ Conflicts resolved"
        sudo pacman -Sc --noconfirm 2>/dev/null || true
    fi
    
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
    
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "NVIDIA DRIVER INSTALLATION (CachyOS Official Method)"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if NVIDIA GPU exists
    if ! lspci | grep -i nvidia &>/dev/null; then
        log "⊘ No NVIDIA GPU detected, skipping driver installation"
        mark_completed "nvidia_drivers"
        return 0
    fi
    
    log "✓ NVIDIA GPU detected:"
    lspci | grep -i nvidia | head -1
    echo ""
    
    # Check if chwd is available
    if ! command -v chwd &>/dev/null; then
        log "Installing chwd (CachyOS Hardware Detection Tool)..."
        sudo pacman -S --needed --noconfirm chwd chwd-db
    fi
    
    log "Checking currently installed NVIDIA profiles..."
    chwd --list --installed | grep -i nvidia || log "No NVIDIA profile currently installed"
    echo ""
    
    log "Available NVIDIA driver profiles:"
    chwd --list | grep -i nvidia
    echo ""
    
    # Backup configs
    backup_file "/etc/mkinitcpio.conf"
    backup_file "/etc/modprobe.d/nvidia.conf"
    
    log "Installing NVIDIA drivers using chwd (official CachyOS method)..."
    log "This will automatically:"
    log "  • Install the correct driver version (latest stable)"
    log "  • Configure mkinitcpio properly"
    log "  • Set up CUDA support"
    log "  • Enable Wayland/Hyprland compatibility"
    log ""
    
    # Use chwd to automatically install the correct NVIDIA profile
    # -a = autoconfigure (installs all detected hardware)
    if sudo chwd -a pci 2>&1 | tee -a "$LOG"; then
        log "✓ chwd installation successful"
    else
        warn "chwd automatic installation had issues, trying manual profile selection..."
        
        # Fallback: Try to install the main nvidia profile manually
        if sudo chwd -i pci video-nvidia 2>&1 | tee -a "$LOG"; then
            log "✓ Manual NVIDIA profile installation successful"
        else
            error "Failed to install NVIDIA drivers. Check logs at: $LOG"
            return 1
        fi
    fi
    
    log "Verifying installation..."
    chwd --list --installed | grep -i nvidia
    
    # Additional optimizations for RTX 3060 (Gaming/AI/Blender/UE5)
    log "Applying RTX 3060 optimizations..."
    
    # Check if nvidia.conf exists, if not create it
    if [ ! -f /etc/modprobe.d/nvidia.conf ]; then
        sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<'EOF'
# NVIDIA RTX 3060 12GB Optimization
# Optimized for: Gaming, AI/ML, Blender, DaVinci Resolve, UE5
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_UsePageAttributeTable=1

# Power management for desktop (always max performance)
options nvidia NVreg_DynamicPowerManagement=0x02

# Disable GSP firmware (better compatibility with older apps)
options nvidia NVreg_EnableGpuFirmware=0
EOF
        log "✓ Created NVIDIA modprobe configuration"
    else
        log "✓ NVIDIA modprobe configuration already exists (managed by chwd)"
    fi
    
    # Enable NVIDIA services if they exist
    for service in nvidia-suspend nvidia-hibernate nvidia-resume nvidia-powerd; do
        if systemctl list-unit-files | grep -q "${service}.service"; then
            sudo systemctl enable "${service}.service" 2>/dev/null || true
        fi
    done
    
    log "Checking CUDA installation..."
    if pacman -Qi cuda &>/dev/null; then
        CUDA_VERSION=$(pacman -Q cuda | awk '{print $2}')
        log "✓ CUDA already installed: $CUDA_VERSION"
    else
        log "Installing CUDA for AI/ML workloads..."
        sudo pacman -S --needed --noconfirm cuda cudnn
    fi
    
    mark_completed "nvidia_drivers"
    
    echo ""
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "✓ NVIDIA DRIVERS INSTALLED SUCCESSFULLY!"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log ""
    log "Installed components:"
    pacman -Q | grep -E 'nvidia|cuda' | sed 's/^/  • /'
    log ""
    log "Features enabled:"
    log "  ✓ Gaming optimizations"
    log "  ✓ CUDA for AI/ML workloads"
    log "  ✓ Wayland/Hyprland support"
    log "  ✓ Hardware acceleration for video editing"
    log "  ✓ Blender CUDA rendering"
    log "  ✓ Unreal Engine 5 support"
    log ""
    warn "⚠️  REBOOT REQUIRED to load NVIDIA drivers!"
    log ""
}

setup_meta_packages() {
    if [ "$(is_completed 'base_packages')" = "yes" ]; then
        log "✓ Base packages already installed"
        return 0
    fi
    
    log "Installing base packages (CachyOS optimized)..."
	
    # CachyOS optimized packages (prefer cachyos- prefixed packages)
    local meta_pkgs=(
		#####
		"caelestia-cli"
		"caelestia-shell"
		"hyprland"
		"xdg-desktop-portal-gtk"
		"hyprpicker"
		"cliphist"
		"inotify-tools"
		"app2unit"
		"trash-cli"
		"eza"
		"jq"
		"adw-gtk-theme"
        "papirus-icon-theme"
		"qt5ct-kde"
		"qt6ct-kde"
		"todoist-appimage"
		"uwsm"
		"direnv"
		
	
        # System essentials
		"fish"
		"kitty"
        
		"wl-clipboard"
		"xdg-desktop-portal-hyprland"
		
		"qt5-wayland"
		"qt6-wayland"
		
		"gnome-keyring"
		"polkit-gnome"
		
		"tumbler"
		"ffmpegthumbnailer"
		"libgsf"
		"thunar"
		
        # File systems (with CachyOS optimizations where available)
        "btrfs-progs"
        "exfatprogs"
        "ntfs-3g"
        "dosfstools"
        
        # Compression
        "zip"
        "unzip"
        "p7zip"
        "unrar"
		"rsync"
		"tmux"
        "starship"
		"eza"
		"bat"
		"ripgrep"
		"fd"
		"fzf"
		"zoxide"
        "nvtop"
		"amdgpu_top"
		"iotop"
		"iftop"
		
        # System tools
        "htop"
        "btop" # NVIDIA GPU monitor
        "neofetch"
        "fastfetch"
		
		# Disk management
        "gparted"
        "gnome-disk-utility"
		
		# PDF viewer
        "zathura"
        "zathura-pdf-poppler"
        
        # Network
        "networkmanager"
        "network-manager-applet"
        "nm-connection-editor"
        
        # Python (essential for many tools)
        "python"
        "python-pip"
        "python-virtualenv"
		"python-numpy"
		"python-pandas"
		"jupyter-notebook"
        "python-scikit-learn"
		"python-matplotlib"
		"python-pillow"
		"python-scipy"
		
		"cuda"
		"cudnn"
		"python-pytorch-cuda"
		
		# Audio
        "pipewire"
        "pipewire-pulse"
        "pipewire-alsa"
        "pipewire-jack"
        "wireplumber"
        "pavucontrol"               # GUI volume control
        "helvum"                    # Pipewire patchbay
		"v4l2loopback-dkms"
		"gstreamer-vaapi"
		"noise-suppression-for-voice"
        
        # Video players
        "mpv"
        "vlc"
        
        # Image viewers/editors
        "imv"                       # Wayland image viewer
        "gimp"
        "inkscape"
        
        # Audio production
        "audacity"
        
        # Video editing
        "kdenlive"
        "obs-studio"
        
        # Codecs
        "gst-plugins-good"
        "gst-plugins-bad"
        "gst-plugins-ugly"
        "gst-libav"
        "ffmpeg"
        
        # Nvidia hardware acceleration
        "libva-nvidia-driver"
		
		"gstreamer"
		"gst-plugins-base"
        "libvorbis"
		"lib32-libvorbis"
		"opus"
		"lib32-opus"
        "flac"
		"lib32-flac"
		"x264"
		"x265"
		
		# Code editors
        "neovim"
        "codium" # VSCode
        
        # Version control
        "git"
        "github-cli"
        
        # Build tools (already in base-devel but ensure)
        "cmake"
        "ninja"
        "meson"
        
        # Compilers
        "gcc"
        "clang"
        
        # Languages
        "nodejs"
        "npm"
        "rust"
        "go"
        
        # Containers
        "docker"
        "docker-compose"
        
        # Database
        "postgresql"
        "redis"
        
        # API testing
        "postman-bin"
		
		"dotnet-sdk"
		"dotnet-runtime"
		"dotnet-sdk-9.0"
		"dotnet-sdk-8.0"
        "aspnet-runtime"
		"mono"
		"mono-msbuild"
        "docker"
		"docker-compose"
		
		# Gaming packages
		"cachyos-gaming-meta" #depends=alsa-plugins/giflib/glfw/gst-plugins-base-libs/lib32-alsa-plugins/lib32-giflib/lib32-gst-plugins-base-libs/lib32-gtk3/lib32-libjpeg-turbo/lib32-libva/lib32-mpg123/lib32-ocl-icd/lib32-opencl-icd-loader/lib32-openal/libjpeg-turbo/libva/libxslt/mpg123/opencl-icd-loader/openal/proton-cachyos-slr/umu-launcher/protontricks/ttf-liberation/wine-cachyos-opt/winetricks/vulkan-tools
		"cachyos-gaming-applications" #depends=gamescope/goverlay/heroic-games-launcher/lib32-mangohud/lutris/mangohud/steam/wqy-zenhei
		"lib32-vulkan-icd-loader"
        "lib32-nvidia-utils" 
        "vulkan-icd-loader"
        "gamemode"
        "lib32-gamemode"
        "xpadneo-dkms" # Xbox controller
		
		#AI/ML
		"ollama-cuda"
		
		"blender" # 3D sculpting
		"openimagedenoise"
		"opencolorio"
		"opensubdiv"
        "openvdb"
		"embree"
		"openimageio"
		"alembic"
		"openjpeg2"
        "openexr"
		"libspnav"
		
		"gimp"
		"gimp-plugin-gmic"
        "krita" # Digital painting
		"inkscape" # Vector graphics
        "kdenlive" # Video
		"frei0r-plugins"
		"mediainfo"
		"mlt"
        "audacity" # Audio
		"ardour" # DAW
		"scribus"
        "darktable" # Photo workflow
		"rawtherapee"
        "imagemagick"
		"graphicsmagick"
		"potrace"
		"fontforge"
		
		"irqbalance"                # IRQ load balancing
        "cpupower"                  # CPU frequency scaling
        "thermald"                  # Thermal management
        "tlp"                       # Power management
        "powertop"                  # Power analysis
        "preload"                   # Application preloader
		
		"wlr-randr"
		"kanshi"
		"nwg-displays"
		
		"lib32-ffmpeg"
		"protonup-qt" #Proton-GE manager
		"microsoft-edge-stable-bin"
		"docker-desktop"
		"rider"
		"github-desktop"
		"lmstudio"
		"davinci-resolve"
		"natron"
		"obs-vaapi"
		"obs-nvfbc"
		"obs-vkcapture"
		"obs-websocket"
		"vesktop-bin"
		"openrgb"
		
		#Vietnamese input
		"fcitx5"
		"fcitx5-qt"
		"fcitx5-gtk"
		"fcitx5-configtool"
		"fcitx5-bamboo-git"
		
		"gdm"
		
		# Fonts
		"ttf-jetbrains-mono-nerd"
        "adobe-source-code-pro-fonts"
        "ttf-liberation"
        "ttf-dejavu"
    )
	
    install_packages "${meta_pkgs[@]}"
	
    # Enable NetworkManager
    sudo systemctl enable NetworkManager
    
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
        log "✓ Gaming setup already done"
        return 0
    fi
    
    log "Setting up gaming environment..."
    
    # Kích hoạt multilib (hỗ trợ 32-bit để chơi game)
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        log "Enabling multilib repository..."
        sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
        sudo pacman -Sy
    fi
	# Configure gamemode
    sudo usermod -aG gamemode "$USER"
    
    # MangoHud config for RTX 3060
    mkdir -p "$HOME/.config/MangoHud"
    cat > "$HOME/.config/MangoHud/MangoHud.conf" <<EOF
# MangoHud Config for RTX 3060
legacy_layout=false
horizontal
gpu_stats
cpu_stats
ram
vram
fps
frametime=0
frame_timing=1
vulkan_driver
wine
engine_version
gamemode
no_display
EOF
    
    mark_completed "gaming"
    log "✓ Gaming setup completed"
}

setup_development() {
    if [ "$(is_completed 'development')" = "yes" ]; then
        log "✓ Development tools already installed"
        return 0
    fi
    
    log "Installing development tools..."
    
    # Docker setup
    sudo systemctl enable --now docker.service 2>/dev/null || true
    sudo usermod -aG docker "$USER" 2>/dev/null || true
    
    mark_completed "development"
    log "✓ Development tools installed"
    
    # Enable Docker
    sudo systemctl enable docker
    sudo usermod -aG docker "$USER"
    
    mark_completed "development"
    log "✓ Development tools installed"
}

setup_multimedia() {
    if [ "$(is_completed 'multimedia')" = "yes" ]; then
        log "✓ Multimedia already installed"
        return 0
    fi
    
    # Enable Pipewire
    systemctl --user enable pipewire
    systemctl --user enable pipewire-pulse
    systemctl --user enable wireplumber
    
    mark_completed "multimedia"
    log "✓ Multimedia installed"
}

setup_ai_ml() {
    if [ "$(is_completed 'ai_ml')" = "yes" ]; then
        log "✓ AI/ML already installed"
        return 0
    fi
    
    ai_info "Installing AI/ML stack (CUDA + PyTorch for RTX 3060)..."
    
    # Install PyTorch with CUDA support via pip
    ai_info "Installing PyTorch with CUDA 12 support..."
    pip install --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    
    # Install additional ML tools
    ai_info "Installing additional ML tools..."
    pip install --user transformers accelerate diffusers invisible-watermark
	
	sudo systemctl enable --now ollama.service 2>/dev/null || true
    
    mark_completed "ai_ml"
    ai_info "✓ AI/ML stack installed"
}

setup_streaming() {
    if [ "$(is_completed 'streaming')" = "yes" ]; then
        log "✓ Streaming tools already installed"
        return 0
    fi
    
    log "Installing streaming tools..."
	
    # Load v4l2loopback
    sudo modprobe v4l2loopback 2>/dev/null || true
    echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
    
    mark_completed "streaming"
    log "✓ Streaming tools installed"
}

setup_system_optimization() {
    if [ "$(is_completed 'system_optimization')" = "yes" ]; then
        log "✓ System optimization already done"
        return 0
    fi
    
    log "Applying system optimizations (Ryzen 7 5800X)..."
	
    # CPU governor (performance for desktop)
    sudo cpupower frequency-set -g performance
    
    # Create systemd service for CPU governor
    sudo tee /etc/systemd/system/cpupower-performance.service > /dev/null <<EOF
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl enable cpupower-performance.service
    
    # Enable services
    sudo systemctl enable irqbalance
    sudo systemctl enable thermald
    
    # TLP configuration (balanced)
    if [ -f /etc/tlp.conf ]; then
        backup_file "/etc/tlp.conf"
        sudo sed -i 's/^#CPU_SCALING_GOVERNOR_ON_AC=.*/CPU_SCALING_GOVERNOR_ON_AC=performance/' /etc/tlp.conf
        sudo sed -i 's/^#CPU_ENERGY_PERF_POLICY_ON_AC=.*/CPU_ENERGY_PERF_POLICY_ON_AC=performance/' /etc/tlp.conf
        sudo systemctl enable tlp.service
    fi
    
    # Kernel parameters for Ryzen 7 5800X (AMD Zen 3)
    sudo tee /etc/sysctl.d/99-ryzen-optimization.conf > /dev/null <<EOF
# Ryzen 7 5800X Optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5

# Network performance
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr

# File system
fs.inotify.max_user_watches=524288
EOF
    
    sudo sysctl -p /etc/sysctl.d/99-ryzen-optimization.conf
    
    # I/O scheduler (BFQ for responsiveness)
    echo 'ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="bfq"' | \
        sudo tee /etc/udev/rules.d/60-ioschedulers.rules
    echo 'ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"' | \
        sudo tee -a /etc/udev/rules.d/60-ioschedulers.rules
    
    mark_completed "system_optimization"
    log "✓ System optimization completed"
}

setup_gdm() {
    if [ "$(is_completed 'gdm')" = "yes" ]; then
        log "✓ GDM already configured"
        return 0
    fi
    
    log "Configuring GDM..."
    
	# Enable Wayland for GDM
    if [ -f /etc/gdm/custom.conf ]; then
        backup_file "/etc/gdm/custom.conf"
        sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=true/' /etc/gdm/custom.conf
    fi
    
    mark_completed "gdm"
    log "✓ GDM configured"
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
    
    curl -L -o "$HOME/.face" https://raw.githubusercontent.com/hoangducdt/caelestia/imgs/main/.face.png
    
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

setup_configs() {
    if [ "$(is_completed 'configs')" = "yes" ]; then
        log "✓ Configs already installed"
        return 0
    fi
    
    log "Installing configuration files..."
    
    # Define the repo Configs directory
    local repo_dir="$HOME/.local/share/caelestia"
    local configs_dir="$repo_dir/Configs"
    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    
    # Check if Configs directory exists
    if [ ! -d "$configs_dir" ]; then
        error "Configs directory not found at: $configs_dir"
        return 1
    fi
    
    # Function to confirm overwrite (similar to install.fish)
    confirm_overwrite() {
        local target_path="$1"
        
        if [ -e "$target_path" ] || [ -L "$target_path" ]; then
            # Backup existing config
            local backup_name="$(basename "$target_path").bak_$(date +%Y%m%d_%H%M%S)"
            log "Backing up existing: $target_path → $backup_name"
            mv "$target_path" "${target_path}_${backup_name}" 2>/dev/null || {
                warn "Could not backup $target_path"
                return 1
            }
        fi
        return 0
    }
    
    # Sync all directories from Configs/ to ~/.config/
    log "Syncing configuration directories..."
    
    # Find all directories in Configs/ (one level deep)
    for config_item in "$configs_dir"/*; do
        if [ ! -e "$config_item" ]; then
            continue
        fi
        
        local item_name=$(basename "$config_item")
        local target_path="$config_home/$item_name"
        
        log "Processing: $item_name"
        
        # Confirm overwrite and create symbolic link
        if confirm_overwrite "$target_path"; then
            # Create parent directory if needed
            mkdir -p "$(dirname "$target_path")"
            
            # Create symbolic link
            if ln -sf "$(realpath "$config_item")" "$target_path" 2>/dev/null; then
                log "  ✓ Linked: $item_name → $config_home/$item_name"
            else
                warn "  ✗ Failed to link: $item_name"
            fi
        else
            warn "  ⊘ Skipped: $item_name (backup failed)"
        fi
    done
    
    # Special handling for specific configs
    log "Applying special configurations..."
    
    # Reload Hyprland if running
    if pgrep -x "Hyprland" > /dev/null; then
        log "Reloading Hyprland configuration..."
        hyprctl reload 2>/dev/null || warn "Could not reload Hyprland"
    fi
    
    # Make executable scripts
    if [ -d "$config_home/hypr/scripts" ]; then
        chmod +x "$config_home/hypr/scripts"/*.sh 2>/dev/null || true
    fi
    
    if [ -f "$config_home/fastfetch/fastfetch.sh" ]; then
        chmod +x "$config_home/fastfetch/fastfetch.sh"
    fi
    
    # DNS configuration - modify existing values in resolved.conf
    log "Configuring system settings..."
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
    
    mark_completed "configs"
    log "✓ All configurations installed successfully"
}

# ===== MAIN =====

main() {
    show_banner
    init_state
    install_helper
    clone_repo
    # Execute all setup functions
    setup_nvidia_cleanup
    setup_system_update
    setup_nvidia_drivers
    setup_meta_packages
    setup_hyprland_caelestia
    setup_gaming
    setup_development
    setup_multimedia
    setup_ai_ml
    setup_streaming
    setup_system_optimization
    setup_gdm
    setup_directories
    setup_utilities
    setup_configs
    
    # Done
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      ✓ INSTALLATION COMPLETED SUCCESSFULLY!                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Logs: $LOG"
    echo "Backup: $BACKUP_DIR"
    echo ""
}

main "$@"