#!/bin/bash

# Exit on errors
set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

DOT_REPO_URL="https://github.com/Calsjunior/dotfiles.git"
WPP_REPO_URL="https://github.com/mylinuxforwork/wallpaper.git"
INSTALL_DIR="$HOME/athena-dotfiles"
WPP_DIR="$HOME/Pictures/Wallpapers"
LOG_FILE="$HOME/caelestia_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${GREEN}▶${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
warning() { echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"; }
gaming_info() { echo -e "${BLUE}[GAMING]${NC} $1" | tee -a "$LOG_FILE"; }

clear
echo -e "${GREEN}"
cat << "EOF"
╭─────────────────────────────────────────────────────────────────────────────╮
│    ▄████████     ███        ▄█    █▄       ▄████████ ███▄▄▄▄      ▄████████ │
│   ███    ███ ▀█████████▄   ███    ███     ███    ███ ███▀▀▀██▄   ███    ███ │
│   ███    ███    ▀███▀▀██   ███    ███     ███    █▀  ███   ███   ███    ███ │
│   ███    ███     ███   ▀  ▄███▄▄▄▄███▄▄  ▄███▄▄▄     ███   ███   ███    ███ │
│ ▀███████████     ███     ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ███   ███ ▀███████████ │
│   ███    ███     ███       ███    ███     ███    █▄  ███   ███   ███    ███ │
│   ███    ███     ███       ███    ███     ███    ███ ███   ███   ███    ███ │
│   ███    █▀     ▄████▀     ███    █▀      ██████████  ▀█   █▀    ███    █▀  │
│   COMPLETE INSTALLER - CachyOS Compatible Gaming Edition                    │
│             ROG STRIX B550-XE │ Ryzen 7 5800X │ RTX 3060 12GB               │
╰─────────────────────────────────────────────────────────────────────────────╯
EOF
echo -e "${NC}"

log "Starting CachyOS-compatible gaming installation..."

# ═══════════════════════════════════════════════════════════════════════════
#  🔍 SMART DETECTION - CachyOS NVIDIA DRIVERS
# ═══════════════════════════════════════════════════════════════════════════

gaming_info "Detecting NVIDIA driver configuration..."

# Check for CachyOS NVIDIA kernel modules
CACHYOS_NVIDIA_KERNEL=false
if pacman -Q linux-cachyos-nvidia &>/dev/null || \
   pacman -Q linux-cachyos-lts-nvidia &>/dev/null || \
   pacman -Q linux-cachyos-nvidia-open &>/dev/null || \
   pacman -Q linux-cachyos-lts-nvidia-open &>/dev/null; then
    CACHYOS_NVIDIA_KERNEL=true
    gaming_info "✓ CachyOS NVIDIA kernel modules detected"
fi

# Check for standard NVIDIA drivers
NVIDIA_DKMS_INSTALLED=false
if pacman -Q nvidia-dkms &>/dev/null || pacman -Q nvidia &>/dev/null; then
    NVIDIA_DKMS_INSTALLED=true
    gaming_info "✓ Standard NVIDIA drivers detected"
fi

# Determine NVIDIA installation strategy
NEED_NVIDIA_UTILS=false
if [ "$CACHYOS_NVIDIA_KERNEL" = true ] || [ "$NVIDIA_DKMS_INSTALLED" = true ]; then
    gaming_info "✓ NVIDIA kernel module already present"
    # Only need userspace utilities
    NEED_NVIDIA_UTILS=true
else
    gaming_info "⚠ No NVIDIA drivers detected"
    echo ""
    echo -e "${YELLOW}NVIDIA Driver Installation Options:${NC}"
    echo -e "  1) Use CachyOS NVIDIA kernel (recommended for CachyOS)"
    echo -e "  2) Install standard nvidia-dkms"
    echo -e "  3) Skip NVIDIA installation"
    echo ""
    
    # Safe read with fallback
    NVIDIA_CHOICE=""
    read -p "Choose option (1-3): " -r NVIDIA_CHOICE || NVIDIA_CHOICE="3"
    echo ""
    
    case "$NVIDIA_CHOICE" in
        1)
            gaming_info "Will install CachyOS NVIDIA kernel"
            INSTALL_CACHYOS_NVIDIA=true
            ;;
        2)
            gaming_info "Will install standard nvidia-dkms"
            INSTALL_NVIDIA_DKMS=true
            ;;
        *)
            gaming_info "Skipping NVIDIA installation (option: ${NVIDIA_CHOICE:-3})"
            ;;
    esac
fi

# Check existing CachyOS gaming packages
if pacman -Q cachyos-gaming-meta &>/dev/null; then
    gaming_info "✓ cachyos-gaming-meta detected"
    CACHYOS_GAMING_INSTALLED=true
else
    CACHYOS_GAMING_INSTALLED=false
fi

if pacman -Q cachyos-gaming-applications &>/dev/null; then
    gaming_info "✓ cachyos-gaming-applications detected"
    CACHYOS_APPS_INSTALLED=true
else
    CACHYOS_APPS_INSTALLED=false
fi

# ═══════════════════════════════════════════════════════════════════════════
#  📦 BASE INSTALLATION (Original Script)
# ═══════════════════════════════════════════════════════════════════════════

# Install git
command -v git &>/dev/null || sudo pacman -S --needed --noconfirm git

log "Cloning needed repositories..."

# Clone repos
if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" && git pull --quiet || true
else
    git clone --depth 1 "$DOT_REPO_URL" "$INSTALL_DIR" || error "Clone dots failed"
    git clone --depth 1 "$WPP_REPO_URL" "$WPP_DIR" || error "Clone wallpapers failed"
    cd "$INSTALL_DIR"
fi

log "Updating system packages..."
sudo pacman -Syu --noconfirm
yay -Syu --noconfirm

log "Installing base dotfiles configuration..."
chmod +x install.sh
./install.sh --kitty --nvim --fastfetch --aur-helper=paru

log "Installing essential desktop packages..."
sudo pacman -S --needed --noconfirm \
    nautilus gnome-disk-utility \
    wlr-randr kanshi stow wtype inotify-tools \
    cachyos-gaming-meta cachyos-gaming-applications \
    fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool

yay -S --noconfirm --needed \
    nwg-displays fcitx5-bamboo-git \
    microsoft-edge-stable-bin github-desktop vesktop-bin

# ═══════════════════════════════════════════════════════════════════════════
#  🎮 NVIDIA DRIVER INSTALLATION (SMART)
# ═══════════════════════════════════════════════════════════════════════════

if [ "$INSTALL_CACHYOS_NVIDIA" = true ]; then
    gaming_info "Installing CachyOS NVIDIA kernel..."
    
    # Detect current kernel
    CURRENT_KERNEL=$(uname -r | cut -d'-' -f1-2)
    
    if [[ "$CURRENT_KERNEL" == *"lts"* ]]; then
        gaming_info "LTS kernel detected, installing LTS NVIDIA module..."
        sudo pacman -S --needed --noconfirm linux-cachyos-lts-nvidia-open
    else
        gaming_info "Standard kernel detected, installing NVIDIA module..."
        sudo pacman -S --needed --noconfirm linux-cachyos-nvidia-open
    fi
    
    NEED_NVIDIA_UTILS=true
    
elif [ "$INSTALL_NVIDIA_DKMS" = true ]; then
    gaming_info "Installing standard nvidia-dkms..."
    sudo pacman -S --needed --noconfirm nvidia-dkms
    NEED_NVIDIA_UTILS=true
fi

# Install NVIDIA userspace utilities (safe - no conflicts)
if [ "$NEED_NVIDIA_UTILS" = true ]; then
    gaming_info "Installing NVIDIA utilities..."
    
    sudo pacman -S --needed --noconfirm \
        nvidia-utils lib32-nvidia-utils \
        nvidia-settings \
        opencl-nvidia lib32-opencl-nvidia \
        libva-nvidia-driver
    
    # Enable NVIDIA services (if available)
    if [ -f /usr/lib/systemd/system/nvidia-suspend.service ]; then
        sudo systemctl enable nvidia-suspend.service
        sudo systemctl enable nvidia-hibernate.service
        sudo systemctl enable nvidia-resume.service
        gaming_info "✓ NVIDIA power management services enabled"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
#  🎮 SAFE GAMING OPTIMIZATIONS (No Conflicts)
# ═══════════════════════════════════════════════════════════════════════════

gaming_info "Installing additional gaming tools..."

# Install only supplementary tools (not in CachyOS packages)
yay -S --noconfirm --needed \
    bottles \
    protonup-qt \
    gwe \
    lib32-pipewire \
    obs-studio

# ─────────────────────────────────────────────────────────────────────────────
# PERFORMANCE OPTIMIZATION TOOLS
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Installing performance tools..."

sudo pacman -S --needed --noconfirm corectrl

# Ananicy-CPP for process priority management
yay -S --noconfirm --needed ananicy-cpp
sudo systemctl enable --now ananicy-cpp 2>/dev/null || true

# ─────────────────────────────────────────────────────────────────────────────
# KERNEL PARAMETERS
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring kernel parameters..."

GRUB_FILE="/etc/default/grub"
GRUB_MODIFIED=false

# NVIDIA DRM modeset (safe for both dkms and CachyOS kernel)
if ! grep -q "nvidia_drm.modeset=1" "$GRUB_FILE" 2>/dev/null; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 /' "$GRUB_FILE"
    GRUB_MODIFIED=true
    gaming_info "Added nvidia_drm.modeset=1"
fi

# NVIDIA video memory preservation
if ! grep -q "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "$GRUB_FILE" 2>/dev/null; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia.NVreg_PreserveVideoMemoryAllocations=1 /' "$GRUB_FILE"
    GRUB_MODIFIED=true
    gaming_info "Added video memory preservation"
fi

# AMD P-State (safe for Ryzen)
if ! grep -q "amd_pstate" "$GRUB_FILE" 2>/dev/null; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="amd_pstate=active /' "$GRUB_FILE"
    GRUB_MODIFIED=true
    gaming_info "Added AMD P-State driver"
fi

# Optional: Performance vs Security
echo ""
echo -e "${YELLOW}⚠️  OPTIONAL: Performance Optimization${NC}"
echo -e "Adding ${CYAN}mitigations=off${NC} can increase FPS by 5-10%"
echo -e "but reduces security against CPU vulnerabilities."
echo ""

# Safe read with fallback
MITIGATIONS_REPLY=""
read -p "Enable mitigations=off? (y/N): " -r MITIGATIONS_REPLY || MITIGATIONS_REPLY="N"
echo ""

if [[ "$MITIGATIONS_REPLY" =~ ^[Yy]$ ]]; then
    if ! grep -q "mitigations=off" "$GRUB_FILE" 2>/dev/null; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="mitigations=off /' "$GRUB_FILE"
        GRUB_MODIFIED=true
        gaming_info "Added mitigations=off"
    fi
else
    gaming_info "Keeping mitigations enabled (secure)"
fi

# Rebuild GRUB if modified
if [ "$GRUB_MODIFIED" = true ]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    gaming_info "GRUB configuration updated"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SYSCTL OPTIMIZATIONS
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring system parameters..."

sudo tee /etc/sysctl.d/99-gaming.conf > /dev/null << 'SYSCTL'
# Network optimizations for gaming (reduce latency)
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_congestion_control = bbr

# Memory optimizations (32GB RAM system)
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5

# File system limits
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
SYSCTL

sudo sysctl -p /etc/sysctl.d/99-gaming.conf 2>/dev/null || true

# ─────────────────────────────────────────────────────────────────────────────
# I/O SCHEDULER OPTIMIZATION
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Optimizing I/O schedulers..."

sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null << 'UDEV'
# NVMe: none scheduler (best for NVMe drives)
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"

# SSD: mq-deadline
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"

# HDD: bfq (if you have any)
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
UDEV

# ─────────────────────────────────────────────────────────────────────────────
# NVIDIA MODULE CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
if [ "$NEED_NVIDIA_UTILS" = true ]; then
    gaming_info "Configuring NVIDIA modules..."
    
    # Only for standard nvidia-dkms, CachyOS kernel handles this differently
    if [ "$INSTALL_NVIDIA_DKMS" = true ]; then
        sudo tee /etc/modules-load.d/nvidia.conf > /dev/null << 'NVMODULES'
nvidia
nvidia_modeset
nvidia_uvm
nvidia_drm
NVMODULES
    fi
    
    # Modprobe settings (works for both)
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'NVMODPROBE'
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
NVMODPROBE
fi

# ─────────────────────────────────────────────────────────────────────────────
# HYPRLAND ENVIRONMENT (NVIDIA + Gaming)
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Creating Hyprland gaming environment..."

mkdir -p ~/.config/hypr

cat > ~/.config/hypr/gaming-env.conf << 'HYPRENV'
# ═══════════════════════════════════════════════════════════════════════════
#  NVIDIA Configuration for Hyprland/Wayland
# ═══════════════════════════════════════════════════════════════════════════
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# VRR/G-SYNC Support
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1

# ═══════════════════════════════════════════════════════════════════════════
#  Gaming Optimizations (Compatible with CachyOS Wine/Proton)
# ═══════════════════════════════════════════════════════════════════════════
# NVIDIA features
env = PROTON_ENABLE_NVAPI,1
env = PROTON_ENABLE_NGX_UPDATER,1

# DXVK optimizations
env = DXVK_ASYNC,1

# FSR upscaling
env = WINE_FULLSCREEN_FSR,1

# Uncomment to always show MangoHud
# env = MANGOHUD,1
HYPRENV

# Add to Hyprland config
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONF" ]; then
    if ! grep -q "gaming-env.conf" "$HYPR_CONF"; then
        echo "source = ~/.config/hypr/gaming-env.conf" >> "$HYPR_CONF"
        gaming_info "✓ Added gaming-env.conf to Hyprland"
    fi
else
    warning "Hyprland config not found - source gaming-env.conf manually"
fi

# ─────────────────────────────────────────────────────────────────────────────
# MANGOHUD CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring MangoHud..."

mkdir -p ~/.config/MangoHud
cat > ~/.config/MangoHud/MangoHud.conf << 'MANGOHUD'
# Display
fps
frametime=0
frame_timing=1
gpu_stats
gpu_temp
cpu_stats
cpu_temp
ram
vram

# Style
position=top-left
font_size=24
background_alpha=0.4

# Controls
toggle_hud=Shift_R+F12
toggle_logging=Shift_L+F2

# Logging
log_duration=60
output_folder=/home/$USER/mangohud_logs
MANGOHUD

mkdir -p ~/mangohud_logs

# ─────────────────────────────────────────────────────────────────────────────
# GAMEMODE CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
if command -v gamemoded &>/dev/null; then
    gaming_info "Configuring GameMode..."
    
    mkdir -p ~/.config
    cat > ~/.config/gamemode.ini << 'GAMEMODE'
[general]
renice=10

[gpu]
apply_gpu_optimisations=accept
gpu_device=0

[custom]
start=notify-send "GameMode" "Performance mode enabled"
end=notify-send "GameMode" "Normal mode restored"
GAMEMODE
fi

# ─────────────────────────────────────────────────────────────────────────────
# SYSTEM LIMITS
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Configuring system limits..."

sudo tee /etc/security/limits.d/99-gaming.conf > /dev/null << 'LIMITS'
* soft nofile 1048576
* hard nofile 1048576
LIMITS

# ─────────────────────────────────────────────────────────────────────────────
# SHADER CACHE DIRECTORIES
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Setting up shader cache..."

mkdir -p ~/.cache/mesa_shader_cache
mkdir -p ~/.cache/nvidia/GLCache
mkdir -p ~/.local/share/Steam/steamapps/shadercache

# ─────────────────────────────────────────────────────────────────────────────
# GAMING MODE TOGGLE SCRIPT
# ─────────────────────────────────────────────────────────────────────────────
gaming_info "Creating gaming mode script..."

sudo tee /usr/local/bin/gaming-mode > /dev/null << 'GAMESCRIPT'
#!/bin/bash

if [ "$1" == "on" ]; then
    echo "🎮 Activating Gaming Mode..."
    
    # CPU performance governor
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        echo "✓ CPU governor: performance"
    fi
    
    # Stop non-essential services
    sudo systemctl stop bluetooth.service 2>/dev/null && echo "✓ Bluetooth stopped"
    
    # Clear cache
    sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    echo "✓ Cache cleared"
    
    notify-send "Gaming Mode" "Performance optimizations active" -u normal
    
elif [ "$1" == "off" ]; then
    echo "🔧 Deactivating Gaming Mode..."
    
    # Restore governor
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        echo "✓ CPU governor: schedutil"
    fi
    
    # Restart services
    sudo systemctl start bluetooth.service 2>/dev/null && echo "✓ Bluetooth started"
    
    notify-send "Gaming Mode" "Normal mode restored" -u normal
else
    echo "Usage: gaming-mode [on|off]"
fi
GAMESCRIPT

sudo chmod +x /usr/local/bin/gaming-mode

# ─────────────────────────────────────────────────────────────────────────────
# STEAM LAUNCH OPTIONS GUIDE
# ─────────────────────────────────────────────────────────────────────────────
cat > ~/steam-launch-options.txt << 'STEAM'
═══════════════════════════════════════════════════════════════════════════
  STEAM LAUNCH OPTIONS - CachyOS Compatible
═══════════════════════════════════════════════════════════════════════════

BASIC:
  Native Linux: mangohud %command%
  Proton games: PROTON_ENABLE_NVAPI=1 DXVK_ASYNC=1 mangohud %command%
  With GameMode: gamemoderun mangohud %command%

HIGH REFRESH:
  144Hz: DXVK_FRAME_RATE=144 mangohud %command%
  Unlimited: DXVK_FRAME_RATE=0 mangohud %command%

FSR UPSCALING:
  WINE_FULLSCREEN_FSR=1 WINE_FULLSCREEN_FSR_STRENGTH=2 mangohud %command%

RECOMMENDED:
  PROTON_ENABLE_NVAPI=1 DXVK_ASYNC=1 gamemoderun mangohud %command%

NOTE: CachyOS uses optimized Wine/Proton. Don't force other versions.
═══════════════════════════════════════════════════════════════════════════
STEAM

# ═══════════════════════════════════════════════════════════════════════════
#  📊 INSTALLATION SUMMARY
# ═══════════════════════════════════════════════════════════════════════════

log "Installation completed successfully!"
echo ""
gaming_info "═══════════════════════════════════════════════════════════════"
gaming_info "  ✅ CACHYOS-COMPATIBLE GAMING SETUP COMPLETE"
gaming_info "═══════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}Installed/Configured:${NC}"
echo ""

if [ "$INSTALL_CACHYOS_NVIDIA" = true ]; then
    echo -e "  ${GREEN}✓${NC} CachyOS NVIDIA kernel module"
elif [ "$INSTALL_NVIDIA_DKMS" = true ]; then
    echo -e "  ${GREEN}✓${NC} Standard NVIDIA dkms driver"
elif [ "$NEED_NVIDIA_UTILS" = true ]; then
    echo -e "  ${GREEN}✓${NC} NVIDIA utilities (kernel already present)"
fi

echo -e "  ${GREEN}✓${NC} Gaming tools: Bottles, ProtonUp-Qt, GWE, OBS"
echo -e "  ${GREEN}✓${NC} Performance: CoreCtrl, Ananicy-CPP"
echo -e "  ${GREEN}✓${NC} System optimizations: sysctl, I/O, limits"
echo -e "  ${GREEN}✓${NC} Hyprland gaming environment"
echo -e "  ${GREEN}✓${NC} MangoHud & GameMode configs"
echo -e "  ${GREEN}✓${NC} Gaming mode toggle script"
echo ""
echo -e "${YELLOW}📝 IMPORTANT NEXT STEPS:${NC}"
echo ""
echo -e "  1. ${CYAN}REBOOT REQUIRED${NC} to apply all changes"
echo -e "  2. After reboot: ${CYAN}gaming-mode on${NC}"
echo -e "  3. Configure CoreCtrl"
echo -e "  4. Test MangoHud: ${CYAN}mangohud glxgears${NC}"
echo -e "  5. Install Proton-GE: ${CYAN}protonup-qt${NC}"
echo ""
echo -e "${YELLOW}🎯 QUICK COMMANDS:${NC}"
echo ""
echo -e "  ${CYAN}gaming-mode on/off${NC}  - Toggle performance"
echo -e "  ${CYAN}nvidia-smi${NC}          - Check GPU"
echo -e "  ${CYAN}corectrl${NC}            - GPU control"
echo ""
gaming_info "═══════════════════════════════════════════════════════════════"
echo ""
log "Log saved: $LOG_FILE"

# Prompt for reboot
echo ""
REBOOT_REPLY=""
read -p "Reboot now to apply changes? (y/N): " -r REBOOT_REPLY || REBOOT_REPLY="N"
echo ""

if [[ "$REBOOT_REPLY" =~ ^[Yy]$ ]]; then
    log "Rebooting system..."
    sudo reboot
else
    warning "Please reboot manually: sudo reboot"
fi
