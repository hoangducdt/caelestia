#!/bin/bash

set -e

# Colors
readonly RED='\e[38;2;255;0;0m'        # Đỏ thuần
readonly GREEN='\e[38;2;0;255;0m'      # Xanh lá thuần
readonly YELLOW='\e[38;2;255;255;0m'   # Vàng thuần
readonly MAGENTA='\e[38;2;234;0;255m'  # Hồng tím
readonly CYAN='\e[38;2;0;255;255m'    # Xanh lơ
readonly NC='\e[0m'                    # Reset màu

LOG_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG="$HOME/setup_complete_${LOG_TIMESTAMP}.log"
readonly STATE_DIR="$HOME/.cache/caelestia-setup"
readonly STATE_FILE="$STATE_DIR/setup_state.json"
readonly BACKUP_DIR="$HOME/Documents/caelestia-configs-${BACKUP_TIMESTAMP}"

# Define functions before use
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

# Check sudo
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

trap 'kill $SUDO_REFRESH_PID 2>/dev/null' EXIT

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
    local repo_dir="$HOME/.local/share/caelestia"
    
    if [ -d "$repo_dir/.git" ]; then
        log "Repository already exists, pulling latest changes..."
        cd "$repo_dir" || error "Failed to cd to $repo_dir"
        git pull || warn "Failed to pull latest changes, continuing with existing version"
    else
        log "Cloning repository..."
        git clone https://github.com/hoangducdt/caelestia.git "$repo_dir" || error "Failed to clone repository"
        cd "$repo_dir" || error "Failed to cd to $repo_dir"
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

# ===== BANNER =====

show_banner() {
    clear
    echo -e "${MAGENTA}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════════════════════════╗
║ ▀████    ███                                                 ▀█████████▄             █         ║
║   ███    ███                 ▀▀▀▀                              ███    ███          █           ║
║   ███    ███    ▄██████▄  ▀███████▄  ▀████████▄   ▄██████▄     ███    ███ ███   ███▀ ▄██████▄  ║
║  ▄███▄▄▄▄███▄▄ ███    ███       ▀███  ███    ███ ███    ███   ▄███▄▄▄ ███ ███   ███ ███    ███ ║
║ ▀▀███▀▀▀▀███▀  ███    ███  ▄████████  ███    ███ ███    ███  ▀▀███▀▀▀ ███ ███   ███ ███        ║
║   ███    ███   ███    ███ ███    ███  ███    ███ ███    ███    ███    ███ ███   ███ ███        ║
║   ███    ███   ███    ███ ███    ███  ███    ███ ███    ███    ███    ███ ███   ███ ███    ███ ║
║   ███    ███    ▀██████▀   ▀████████▄ ███    ███  ▀████████  ▄█████████▀   ▀█████▀   ▀██████▀  ║
║                                                        ▄███                                    ║
║                                                 ▄████████▀                                     ║
║   Caelestia Installer - Optimized For CachyOS                                                  ║
║   • Target System: CachyOS + Hyprland + Caelestia                                              ║
║   • Hardware: ROG STRIX B550-XE GAMING WIFI | Ryzen 7 5800X | RTX 3060 12GB                    ║
║   • Optimizations: Performance adjustments, Vietnamese input methods...                        ║
╚════════════════════════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
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
    local deps
    deps=$(pactree -r "$pkg" 2>/dev/null | tail -n +2 | wc -l)
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
        if sudo pacman -S --noconfirm "$pkg" 2>&1 | tee -a "$LOG"; then
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
    
    if timeout "$timeout_seconds" yay -S --noconfirm "$pkg" 2>&1 | tee -a "$LOG"; then
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
    local backup_path
    backup_path="$BACKUP_DIR/$(basename "$file").backup"
    
    if [ -f "$file" ]; then
        cp "$file" "$backup_path" 2>/dev/null || warn "Failed to backup $file"
        log "Backed up: $file"
    fi
}

backup_dir() {
    local dir="$1"
    local backup_path
    backup_path="$BACKUP_DIR/$(basename "$dir")"
    
    if [ -d "$dir" ]; then
        cp -r "$dir" "$backup_path" 2>/dev/null || warn "Failed to backup $dir"
        log "Backed up: $dir"
    fi
}

# ===== SETUP FUNCTIONS =====

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

setup_nvidia_optimization() {
    if [ "$(is_completed 'nvidia_optimization')" = "yes" ]; then
        log "✓ NVIDIA optimization already applied"
        return 0
    fi
    
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "NVIDIA OPTIMIZATION (Config Only - No Driver Changes)"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check GPU
    if ! lspci | grep -i nvidia &>/dev/null; then
        log "⊘ No NVIDIA GPU, skipping"
        mark_completed "nvidia_optimization"
        return 0
    fi
    
    log "✓ NVIDIA GPU detected:"
    lspci | grep -i nvidia | head -1
    echo ""
    
    # Verify driver installed
    log "Checking driver status..."
    
    if ! pacman -Qi nvidia-utils &>/dev/null; then
        error << "EROR"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NVIDIA driver NOT found!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Please install via CachyOS installer or manually:
  sudo pacman -S linux-cachyos-nvidia-open
EROR
    fi
    
    log "✓ Driver found:"
    pacman -Q | grep -E '^(linux-cachyos-nvidia|nvidia-utils|lib32-nvidia)' | sed 's/^/  • /'
    echo ""
    
    # Backup
    [ -f "/etc/mkinitcpio.conf" ] && backup_file "/etc/mkinitcpio.conf"
    [ -f "/etc/modprobe.d/nvidia.conf" ] && backup_file "/etc/modprobe.d/nvidia.conf"
    
    log "Applying optimizations..."
    
    # 1. Modprobe
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<'EOF'
# NVIDIA RTX 3060 Optimization
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia NVreg_EnableGpuFirmware=0
EOF
    log "✓ Modprobe config"
    
    # 2. Mkinitcpio
    if grep -q "^MODULES=" /etc/mkinitcpio.conf; then
        if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
            sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
            sudo mkinitcpio -P
            log "✓ Mkinitcpio updated & rebuilt"
        else
            log "✓ Mkinitcpio already configured"
        fi
    fi
    
    # 3. Services
    for svc in nvidia-suspend nvidia-hibernate nvidia-resume; do
        if systemctl list-unit-files | grep -q "${svc}.service"; then
            sudo systemctl enable "${svc}.service" 2>/dev/null || true
        fi
    done
    log "✓ Services enabled"
    
    mark_completed "nvidia_optimization"
    
    echo ""
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "✓ OPTIMIZATION COMPLETE!"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log ""
    log "Applied:"
    log "  • Modprobe parameters"
    log "  • Early boot modules"
    log "  • Power management"
    log "  • NO driver changes (safe!)"
    log ""
    warn "⚠️  Reboot to apply changes"
    log "   Verify: nvidia-smi"
}

setup_meta_packages() {
    if [ "$(is_completed 'base_packages')" = "yes" ]; then
        log "✓ Base packages already installed"
        return 0
    fi
    
    log "Installing base packages (CachyOS optimized)..."
    local meta_pkgs=(
		# ==========================================================================
		# PHASE 1: CORE SYSTEM DEPENDENCIES (Cài đầu tiên - Foundation)
		# ==========================================================================
		
		## 1.1 Base System Libraries
		"python"                        # Core Python runtime - Dependency của nhiều tools
		"python-pip"                    # Python package manager
		"python-virtualenv"             # Virtual environments
		
		## 1.2 Essential System Tools
		"git-lfs"                       # Git Large File Storage - BẮT BUỘC cho UE5 assets
		"rsync"                         # File synchronization
		"tmux"                          # Terminal multiplexer
		"jq"                            # JSON processor - Dependency của scripts
        "i2c-tools"                     # I2C/SMBus utilities for sensors/RGB
        "dmidecode"                     # Hardware information decoder
        "fwupd"                         # Firmware update manager
		"inotify-tools"                 # File system event monitoring
		
		## 1.3 Compression Tools (Dependencies cho nhiều packages)
		"zip"                           # ZIP compression
		"unzip"                         # ZIP extraction
		"p7zip"                         # 7-Zip compression
		"unrar"                         # RAR extraction
        "ark"                           # KDE archive manager - GUI for all formats
		
		## 1.4 File System Support
		"btrfs-progs"                   # Btrfs file system utilities
		"exfatprogs"                    # exFAT file system support
		"ntfs-3g"                       # NTFS read/write support
		"dosfstools"                    # FAT/FAT32 utilities
		
		# ==========================================================================
		# PHASE 2: DISPLAY & GRAPHICS FOUNDATION
		# ==========================================================================
		
		## 2.1 Wayland Core
		"qt5-wayland"                   # Qt5 Wayland support
		"qt6-wayland"                   # Qt6 Wayland support
		"wl-clipboard"                  # Wayland clipboard utilities
		"xdg-desktop-portal-gtk"        # XDG portal for file dialogs
		"xdg-desktop-portal-hyprland"   # Hyprland-specific portal
		
		## 2.2 Graphics Libraries (Cài trước GPU drivers/apps)
		"vulkan-icd-loader"             # Vulkan loader - BẮT BUỘC cho gaming/UE5
		"lib32-vulkan-icd-loader"       # 32-bit Vulkan support
		
		## 2.3 NVIDIA Hardware Acceleration
		"libva-nvidia-driver"           # VA-API for NVIDIA - Video acceleration
		"lib32-nvidia-utils"            # 32-bit NVIDIA utilities - Cho gaming
		
		# ==========================================================================
		# PHASE 3: AUDIO FOUNDATION (Cài trước multimedia apps)
		# ==========================================================================
		
		## 3.1 PipeWire Core (Modern audio server)
		"pipewire"                      # Core audio/video server
		"pipewire-pulse"                # PulseAudio replacement
		"pipewire-alsa"                 # ALSA support
		"pipewire-jack"                 # JACK audio support - Cho audio production
		"wireplumber"                   # Session manager for PipeWire
		
		## 3.2 Audio Tools
		"pavucontrol"                   # GUI volume control
		"helvum"                        # PipeWire patchbay GUI
        "easyeffects"                   # Audio effects for PipeWire
        "qpwgraph"                      # PipeWire graph editor
		"v4l2loopback-dkms"             # Virtual video device - Cho OBS
		"noise-suppression-for-voice"   # AI noise cancellation - Cho streaming
		
		# ==========================================================================
		# PHASE 4: MULTIMEDIA CODECS (Dependencies cho video/audio apps)
		# ==========================================================================
		
		## 4.1 GStreamer Framework
		"gstreamer"                     # Multimedia framework core
		"gstreamer-vaapi"               # VA-API acceleration for GStreamer
		"gst-plugins-base"              # Base plugins
		"gst-plugins-good"              # Good quality plugins
		"gst-plugins-bad"               # Experimental plugins
		"gst-plugins-ugly"              # Legally restricted plugins
		"gst-libav"                     # Libav wrapper plugin
		
		## 4.2 FFmpeg & Codecs
		"ffmpeg"                        # Complete multimedia solution
		"lib32-ffmpeg"                  # 32-bit FFmpeg - Cho gaming/Proton
		"x264"                          # H.264 encoder
		"x265"                          # HEVC encoder
		
		## 4.3 Audio Codecs
		"libvorbis"                     # Vorbis audio codec
		"lib32-libvorbis"               # 32-bit Vorbis
		"opus"                          # Opus audio codec
		"lib32-opus"                    # 32-bit Opus
		"flac"                          # FLAC lossless audio
		"lib32-flac"                    # 32-bit FLAC
		
		# ==========================================================================
		# PHASE 5: DEVELOPMENT TOOLS FOUNDATION
		# ==========================================================================
		
		## 5.1 Build System Core (Cài trước compilers)
		"cmake"                         # Cross-platform build system - UE5 dependency
		"ninja"                         # Fast build tool - UE5 build system
		"meson"                         # Modern build system
		"ccache"                        # Compiler cache - TĂNG TỐC build UE5
		
		## 5.2 Compilers & Linkers
		"gcc"                           # GNU C/C++ compiler
		"clang"                         # LLVM C/C++ compiler - UE5 prefer Clang
		"lld"                           # LLVM linker - NHANH hơn ld cho UE5
		
		## 5.3 Version Control
		"github-cli"                    # GitHub CLI tool
		"github-desktop"                # GitHub Desktop GUI
		
		## 5.4 Programming Languages
		"nodejs"                        # Node.js runtime
		"npm"                           # Node package manager
		"rust"                          # Rust language
		"go"                            # Go language
		
		## 5.5 Python Development
		"python-numpy"                  # Numerical computing
		"python-pandas"                 # Data analysis
		"python-matplotlib"             # Plotting library
		"python-pillow"                 # Image processing
		"python-scipy"                  # Scientific computing
		"python-scikit-learn"           # Machine learning
		"jupyter-notebook"              # Interactive notebooks
		
		## 5.6 3D Development Libraries (Cho UE5)
		"assimp"                        # 3D model import library - UE5 model import
		"fbx-sdk"                       # FBX SDK - Import/export FBX for UE5
		"helix-cli"                     # Perforce Helix client - Team collaboration
		
		# ==========================================================================
		# PHASE 6: .NET DEVELOPMENT STACK
		# ==========================================================================
		
		## 6.1 .NET Runtime & SDK (Theo thứ tự: Runtime → SDK cũ → SDK mới)
		"dotnet-runtime"                # .NET runtime
		"dotnet-sdk-8.0"                # .NET 8.0 LTS SDK
		"dotnet-sdk-9.0"                # .NET 9.0 Latest SDK
		"dotnet-sdk"                    # Latest SDK meta-package
		"aspnet-runtime"                # ASP.NET Core runtime
		"mono"                          # Mono framework - Cross-platform .NET
		"mono-msbuild"                  # MSBuild for Mono
		
		# ==========================================================================
		# PHASE 7: CONTAINERIZATION & DATABASES
		# ==========================================================================
		
		## 7.1 Container Platform
		"docker-desktop"                # Docker Desktop - Bao gồm docker + compose
										# ⚠️ KHÔNG cài riêng "docker" và "docker-compose"
		
		## 7.2 Databases
		"postgresql"                    # PostgreSQL database
		"redis"                         # Redis in-memory database
		
		# ==========================================================================
		# PHASE 8: AI/ML STACK
		# ==========================================================================
		
		## 8.1 CUDA Foundation (Cài trước PyTorch)
		"cuda"                          # NVIDIA CUDA Toolkit - BẮT BUỘC cho AI/ML
		"cudnn"                         # CUDA Deep Neural Network library
		
		## 8.2 PyTorch with CUDA
		"python-pytorch-cuda"           # PyTorch with CUDA support
		"python-torchvision-cuda"       # Computer vision for PyTorch
		"python-torchaudio-cuda"        # Audio processing for PyTorch
		"python-transformers"           # Hugging Face Transformers
		"python-accelerate"             # Training acceleration library
		
		## 8.3 Local AI Runtime
		"ollama-cuda"                   # Local LLM inference with CUDA
		
		# ==========================================================================
		# PHASE 9: GAMING STACK
		# ==========================================================================
		
		## 9.1 Gaming Core
		"gamemode"                      # CPU governor optimization for gaming
		"lib32-gamemode"                # 32-bit gamemode
		"xpadneo-dkms"                  # Xbox controller support
		
		## 9.2 CachyOS Gaming Meta-packages (Bao gồm nhiều dependencies)
		"cachyos-gaming-meta"           # Includes: Wine, Proton, Vulkan tools, lib32 libs
										# Dependencies: alsa-plugins, giflib, glfw, gst-plugins-base-libs
										#               lib32-* variants, proton-cachyos-slr, umu-launcher
										#               protontricks, wine-cachyos-opt, winetricks, vulkan-tools
		
		"cachyos-gaming-applications"   # Includes: Steam, Lutris, Heroic, MangoHud, Gamescope
										# Dependencies: gamescope, goverlay, heroic-games-launcher
										#               lib32-mangohud, mangohud, steam, wqy-zenhei
		
		## 9.3 Gaming Utilities
		"protonup-qt"                   # Proton-GE version manager GUI
		
		# ==========================================================================
		# PHASE 10: 3D CREATION & BLENDER ECOSYSTEM
		# ==========================================================================
		
		## 10.1 Blender Core
		"blender"                       # 3D creation suite - UE5 asset creation
		
		## 10.2 Blender Dependencies (Render & Import/Export)
		"openimagedenoise"              # AI-powered denoising - OptiX render
		"opencolorio"                   # Color management
		"opensubdiv"                    # Subdivision surfaces
		"openvdb"                       # Volumetric data structure
		"embree"                        # Ray tracing kernel
		"openimageio"                   # Image I/O library
		"alembic"                       # Animation interchange - UE5 ↔ Blender
		"openjpeg2"                     # JPEG 2000 codec
		"openexr"                       # HDR image format
		"libspnav"                      # 3D mouse support
		
		# ==========================================================================
		# PHASE 11: 2D GRAPHICS & DESIGN TOOLS
		# ==========================================================================
		
		## 11.1 Raster Graphics
		"imv"       					# Wayland-native image viewer - Lightweight & fast
        "gwenview"                      # KDE image viewer - Feature-rich with editing tools
		"gimp"                          # GNU Image Manipulation Program
		"gimp-plugin-gmic"              # G'MIC plugin for GIMP
		"krita"                         # Digital painting
		
		## 11.2 Vector Graphics
		"inkscape"                      # Vector graphics editor
		
		## 11.3 Photo Editing
		"darktable"                     # RAW photo workflow
		"rawtherapee"                   # Advanced RAW editor
		
		## 11.4 Image Processing
		"imagemagick"                   # Command-line image processing
		"graphicsmagick"                # Image processing fork
		"potrace"                       # Bitmap to vector tracing
		
		## 11.5 Font Tools
		"fontforge"                     # Font editor
		
		# ==========================================================================
		# PHASE 12: VIDEO & AUDIO PRODUCTION
		# ==========================================================================
		
		## 12.1 Video Editing
		"kdenlive"                      # Video editor
		"frei0r-plugins"                # Video effects plugins
		"mediainfo"                     # Media file information
		"mlt"                           # Multimedia framework for kdenlive
		"davinci-resolve"               # Professional video editor - GPU accelerated
		"natron"                        # Compositing & VFX
		
		## 12.2 Video Players
		"mpv"                           # Minimalist video player
		"vlc"                           # VLC media player
		
		## 12.3 Audio Production
		"audacity"                      # Audio wave editor (2 lần trong list - chỉ giữ 1)
		"ardour"                        # Digital Audio Workstation (DAW)
		
		## 12.4 Streaming & Recording
		"obs-studio"                    # Streaming/recording software
		"obs-vaapi"                     # VA-API plugin for OBS
		"obs-nvfbc"                     # NVIDIA capture plugin
		"obs-vkcapture"                 # Vulkan capture plugin
		"obs-websocket"                 # WebSocket plugin for OBS
		
		# ==========================================================================
		# PHASE 13: PUBLISHING & DOCUMENT TOOLS
		# ==========================================================================
		
		"scribus"                       # Desktop publishing
		
		## 13.1 PDF Tools
		"zathura"                       # Minimalist PDF viewer
		"zathura-pdf-poppler"           # Poppler backend for zathura
        "okular"                        # KDE document viewer - PDF/EPUB/DjVu/Comics support
		
		# ==========================================================================
		# PHASE 14: PROFESSIONAL DEVELOPMENT TOOLS
		# ==========================================================================
		
		## 14.1 Code Editors
		"neovim"                        # Modern Vim
		"codium"                        # VSCodium - Open-source VS Code
        "kate"                          # KDE Advanced Text Editor - Multi-document interface
		
		## 14.2 IDEs
		"rider"                         # JetBrains Rider - .NET/Unity/UE5 IDE
		"lmstudio"                      # Local LLM GUI
		
		## 14.3 API Testing
		"postman-bin"                   # API testing tool
		
		# ==========================================================================
		# PHASE 15: HYPRLAND DESKTOP ENVIRONMENT
		# ==========================================================================
		
		## 15.1 Hyprland Core
		"hyprland"                      # Dynamic tiling Wayland compositor
		"uwsm"                          # Wayland session manager
		
		## 15.2 Hyprland Utilities
		"hyprpicker"                    # Color picker for Hyprland
		"cliphist"                      # Clipboard manager
		"wlr-randr"                     # Display configuration
		"kanshi"                        # Dynamic display configuration
		"nwg-displays"                  # Display manager GUI
		
		## 15.3 Caelestia Configuration
		"caelestia-cli"                 # Caelestia CLI tools
		"caelestia-shell"               # Caelestia shell configuration
		
		# ==========================================================================
		# PHASE 16: GTK/QT THEMING & APPEARANCE
		# ==========================================================================
		
		## 16.1 Themes
		"adw-gtk-theme"                 # Adwaita GTK theme
		"papirus-icon-theme"            # Papirus icon theme
		"qt5ct-kde"                     # Qt5 configuration tool
		"qt6ct-kde"                     # Qt6 configuration tool
		
		## 16.2 Authentication
		"gnome-keyring"                 # Password manager
		"polkit-gnome"                  # Polkit authentication agent
		
		# ==========================================================================
		# PHASE 17: FILE MANAGER & THUMBNAILS
		# ==========================================================================
		
		"thunar"                        # Lightweight file manager
		"tumbler"                       # Thumbnail generator
		"ffmpegthumbnailer"             # Video thumbnail generator
		"libgsf"                        # Structured file library
		
		# ==========================================================================
		# PHASE 18: TERMINAL & SHELL ENHANCEMENTS
		# ==========================================================================
		
		## 18.1 Terminal Emulator
		"fish"                          # Friendly shell
		"kitty"                         # GPU-accelerated terminal
		
		## 18.2 Shell Utilities
		"starship"                      # Cross-shell prompt
		"eza"                           # Modern ls replacement
		"bat"                           # Cat with syntax highlighting
		"ripgrep"                       # Fast grep alternative
		"fd"                            # Fast find alternative
		"fzf"                           # Fuzzy finder
		"zoxide"                        # Smart cd command
		"direnv"                        # Directory-based environments
		"trash-cli"                     # CLI trash management
		"app2unit"                      # Systemd unit generator
		
		# ==========================================================================
		# PHASE 19: SYSTEM MONITORING & MANAGEMENT
		# ==========================================================================
		
		## 19.1 System Monitors
		"htop"                          # Interactive process viewer
		"btop"                          # Resource monitor
		"neofetch"                      # System information
		"fastfetch"                     # Fast system information
		"nvtop"                         # NVIDIA GPU monitor
        "lm_sensors"                    # Hardware monitoring sensors
        "zenmonitor"                    # AMD Ryzen monitor GUI
        "corectrl"                      # AMD GPU/CPU control center
		"amdgpu_top"                    # AMD GPU monitor
		"iotop"                         # I/O monitor
		"iftop"                         # Network monitor
		
		## 19.2 Power Management
		"irqbalance"                    # IRQ load balancing
		"cpupower"                      # CPU frequency scaling
		"thermald"                      # Thermal management
		"tlp"                           # Power management
		"powertop"                      # Power consumption analyzer
        "ryzenadj"                      # Ryzen power adjustment
        "auto-cpufreq"                  # Automatic CPU frequency optimization
		"preload"                       # Application preloader
		
		# ==========================================================================
		# PHASE 20: DISK & STORAGE MANAGEMENT
		# ==========================================================================
		
		"gparted"                       # Partition editor GUI
		"gnome-disk-utility"            # Disk management GUI
		
		# ==========================================================================
		# PHASE 21: NETWORK MANAGEMENT
		# ==========================================================================
		
		"networkmanager"                # Network connection manager
        "iwd"                           # Intel Wireless Daemon
        "bluez"                         # Bluetooth protocol stack
        "bluez-utils"                   # Bluetooth utilities
        "blueman"                       # Bluetooth manager GUI
		"network-manager-applet"        # NetworkManager tray applet
		"nm-connection-editor"          # NetworkManager GUI editor
		
		# ==========================================================================
		# PHASE 22: DISPLAY MANAGER & LOGIN
		# ==========================================================================
		
		"gdm"                           # GNOME Display Manager
		"gdm-settings"                  # GDM configuration tool
		
		# ==========================================================================
		# PHASE 23: RGB & PERIPHERAL CONTROL
		# ==========================================================================
		
		"openrgb"                       # RGB lighting control
		
		# ==========================================================================
		# PHASE 24: INPUT METHOD (Vietnamese)
		# ==========================================================================
		
		## 24.1 Fcitx5 Core
		"fcitx5"                        # Input method framework
		"fcitx5-qt"                     # Qt5/Qt6 support
		"fcitx5-gtk"                    # GTK support
		"fcitx5-configtool"             # Configuration GUI
		"fcitx5-bamboo-git"             # Vietnamese input method
		
		# ==========================================================================
		# PHASE 25: WEB BROWSER & COMMUNICATION
		# ==========================================================================
		
		"microsoft-edge-stable-bin"     # Microsoft Edge browser
		"vesktop-bin"                   # Discord with Vencord
		
		# ==========================================================================
		# PHASE 26: PRODUCTIVITY APPS
		# ==========================================================================
		
		"todoist-appimage"              # Task management
		
		# ==========================================================================
		# PHASE 27: FONTS
		# ==========================================================================
		
		"ttf-jetbrains-mono-nerd"       # JetBrains Mono Nerd Font
		"adobe-source-code-pro-fonts"   # Adobe Source Code Pro
		"ttf-liberation"                # Liberation fonts
		"ttf-dejavu"                    # DejaVu fonts
	)
	
    install_packages "${meta_pkgs[@]}"
	
    # Enable NetworkManager
    sudo systemctl enable NetworkManager
    
    mark_completed "base_packages"
    log "✓ Base packages installed"
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

setup_i2c_for_rgb() {
    if [ "$(is_completed 'i2c_setup')" = "yes" ]; then
        log "✓ i2c already configured"
        return 0
    fi
    
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "Configuring i2c for RGB Control (OpenRGB)"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 1. Load i2c modules immediately
    log "Loading i2c kernel modules..."
    sudo modprobe i2c-dev 2>&1 | tee -a "$LOG" || warn "Failed to load i2c-dev"
    sudo modprobe i2c-piix4 2>&1 | tee -a "$LOG" || warn "Failed to load i2c-piix4"
    
    # 2. Configure modules to load at boot
    log "Configuring i2c modules for autoload..."
    
    # Create i2c.conf if doesn't exist
    if [ ! -f /etc/modules-load.d/i2c.conf ]; then
        echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c.conf > /dev/null
        echo "i2c-piix4" | sudo tee -a /etc/modules-load.d/i2c.conf > /dev/null
        log "✓ Created /etc/modules-load.d/i2c.conf"
    else
        # File exists, append if not already present
        if ! grep -q "i2c-dev" /etc/modules-load.d/i2c.conf; then
            echo "i2c-dev" | sudo tee -a /etc/modules-load.d/i2c.conf > /dev/null
        fi
        if ! grep -q "i2c-piix4" /etc/modules-load.d/i2c.conf; then
            echo "i2c-piix4" | sudo tee -a /etc/modules-load.d/i2c.conf > /dev/null
        fi
        log "✓ Updated /etc/modules-load.d/i2c.conf"
    fi
    
    # 3. Create i2c group if doesn't exist and add user
    log "Configuring i2c group permissions..."
    
    if ! getent group i2c > /dev/null 2>&1; then
        sudo groupadd i2c
        log "✓ Created i2c group"
    fi
    
    # Add user to i2c group
    sudo usermod -aG i2c "$USER" 2>&1 | tee -a "$LOG"
    sudo sensors-detect --auto

    log "✓ Added $USER to i2c group"
    
    # 4. Create udev rules for i2c devices
    log "Creating udev rules for i2c devices..."
    
    sudo tee /etc/udev/rules.d/99-i2c.rules > /dev/null <<'EOF'
# i2c device permissions for OpenRGB and other RGB control software
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
EOF
    
    log "✓ Created /etc/udev/rules.d/99-i2c.rules"
    
    # 5. Reload udev rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    log "✓ Reloaded udev rules"
    
    # 6. Verify i2c devices
    
    log "Verifying i2c devices..."
    if find /dev -maxdepth 1 -type c -name 'i2c-*' | grep -q .; then
        log "✓ i2c devices found:"
        find /dev -maxdepth 1 -type c -name 'i2c-*' \
            -printf "%M %u %g %s %TY-%Tm-%Td %TH:%TM %p\n" \
            | sed 's/^/  /' | tee -a "$LOG"
    else
        warn "⚠ No i2c devices found (may appear after reboot)"
    fi
    
    # 7. Check if modules are loaded
    log "Checking loaded modules..."
    if lsmod | grep -q i2c_dev; then
        log "✓ i2c-dev module loaded"
    else
        warn "⚠ i2c-dev module not loaded"
    fi
    
    if lsmod | grep -q i2c_piix4; then
        log "✓ i2c-piix4 module loaded"
    else
        warn "⚠ i2c-piix4 module not loaded (normal for some systems)"
    fi
    
    mark_completed "i2c_setup"
    
    echo ""
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "✓ i2c CONFIGURATION COMPLETE!"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log ""
    log "OpenRGB can now access i2c devices for RGB control"
    log "⚠️  REBOOT REQUIRED for group membership to take effect"
    log ""
}

setup_gdm() {
    if [ "$(is_completed 'gdm')" = "yes" ]; then
        log "✓ GDM already installed"
        return 0
    fi
    
    log "Installing GDM..."
    
    # Bật GDM
    sudo systemctl enable gdm.service
    
    mark_completed "gdm"
    log "✓ GDM installed and enabled"
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
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "/var/lib/AccountsService/users"
    
    # Wallpapers
    if [ ! -d "$HOME/Pictures/Wallpapers/.git" ]; then
        git clone --quiet --depth 1 https://github.com/mylinuxforwork/wallpaper.git \
            "$HOME/Pictures/Wallpapers" 2>&1 | tee -a "$LOG" || warn "Wallpapers clone failed"
    fi
    
    # Thêm bookmarks
    cat >> "$HOME/.config/gtk-3.0/bookmarks" <<EOF
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
	local config_home="${XDG_CONFIG_HOME:-$HOME}"
	
	# Check if Configs directory exists
	if [ ! -d "$configs_dir" ]; then
	    error "Configs directory not found at: $configs_dir"
	fi
	
	confirm_overwrite() {
	    local target_path="$1"
	    
	    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
	        local backup_name
	        backup_name="$(basename "$target_path").bak_$(date +%Y%m%d_%H%M%S)"
	        log "Backing up existing: $target_path → $backup_name"
	        mv "$target_path" "${target_path}_${backup_name}" 2>/dev/null || {
	            warn "Could not backup $target_path"
	            return 1
	        }
	    fi
	    return 0
	}
	
	# Sync EVERYTHING recursively using find
	log "Syncing ALL configuration items recursively..."
	find "$configs_dir" -mindepth 1 -print0 | while IFS= read -r -d '' item; do
	    # Calculate relative path
	    local relative_path="${item#$configs_dir/}"
	    local target_path="$config_home/$relative_path"
	    
	    # Skip broken symlinks
	    [ -L "$item" ] && [ ! -e "$item" ] && continue
	    
	    log "Processing: $relative_path"
	    
	    if confirm_overwrite "$target_path"; then
	        mkdir -p "$(dirname "$target_path")"
	        if ln -sf "$(realpath "$item")" "$target_path" 2>/dev/null; then
	            log "  ✓ Linked: $relative_path → $target_path"
	        else
	            warn "  ✗ Failed to link: $relative_path"
	        fi
	    else
	        warn "  ⊘ Skipped: $relative_path (backup failed)"
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
    if [ -d "$config_home/.config/hypr/scripts" ]; then
        chmod +x "$config_home/.config/hypr/scripts"/*.sh 2>/dev/null || true
    fi
    
    if [ -f "$config_home/.config/fastfetch/fastfetch.sh" ]; then
        chmod +x "$config_home/.config/fastfetch/fastfetch.sh"
    fi

    chmod 644 "$config_home/.face"

    # Setup GDM avatar via AccountsService
    local username="$USER"
    local accountsservice_dir="/var/lib/AccountsService/users"
    local accountsservice_file="$accountsservice_dir/$username"

    if [ -f "$accountsservice_file" ]; then
        # File đã tồn tại - kiểm tra và cập nhật
        if sudo grep -q "^\[User\]" "$accountsservice_file"; then
            # Có section [User]
            if sudo grep -q "^Icon=" "$accountsservice_file"; then
                # Đã có dòng Icon, thay thế
                sudo sed -i "s|^Icon=.*|Icon=$HOME/.face|" "$accountsservice_file"
            else
                # Chưa có dòng Icon, thêm vào sau [User]
                sudo sed -i "/^\[User\]/a Icon=$HOME/.face" "$accountsservice_file"
            fi
        else
            # Không có section [User], thêm section mới
            echo -e "\n[User]\nIcon=$HOME/.face" | sudo tee -a "$accountsservice_file" > /dev/null
        fi
    else
        # File chưa tồn tại - tạo mới
        sudo tee "$accountsservice_file" > /dev/null <<EOF
[User]
Icon=$HOME/.face
EOF
    fi
    
    chmod 644 "$accountsservice_file"
    
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
    local primary_interface
    primary_interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    
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
    setup_system_update
    setup_nvidia_optimization
    setup_meta_packages
    setup_gaming
    setup_multimedia
    setup_ai_ml
    setup_streaming
    setup_system_optimization
    setup_i2c_for_rgb
    setup_gdm
    setup_directories
    setup_configs
    
    # Done
    echo ""
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║           INSTALLATION COMPLETED SUCCESSFULLY!             ║
╚════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
    echo "Logs: $LOG"
    echo "Backup: $BACKUP_DIR"
    echo ""
}

main "$@"
