#!/bin/bash
# ============================================================================
# CAELESTIA ULTIMATE ONE-CLICK INSTALLER
# Chạy script này SAU KHI cài Arch xong → Reboot → Done!
# ============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${CYAN}[→]${NC} $1"; }

cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║   ______           __          __  _                          ║
║  / ____/___ ____  / /__  _____/ /_(_)___ _                    ║
║ / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/                    ║
║/ /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /                     ║
║\____/\__,_/\___/_/\___/____/\__/_/\__,_/                      ║
║                                                                ║
║   ULTIMATE ONE-CLICK INSTALLER                                ║
║   ROG STRIX B550-XE + Ryzen 5800X + RTX 3060 + Dual Monitors ║
╚════════════════════════════════════════════════════════════════╝
EOF

info "This will install EVERYTHING:"
echo "  • CachyOS BORE kernel + Nvidia drivers"
echo "  • AMD Ryzen optimizations"
echo "  • ROG STRIX features (RGB, sensors)"
echo "  • Dual monitor setup"
echo "  • Gaming optimizations"
echo "  • Caelestia Hyprland + all apps"
echo

warn "Prerequisites: You must have run 'archinstall' already!"
read -p "Continue? [Y/n] " -r
[[ ! $REPLY =~ ^[Nn]$ ]] || exit 1

# ============================================================================
# PHASE 1: UPDATE & SETUP CACHYOS
# ============================================================================

log "Phase 1/5: System update and CachyOS setup..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm git wget curl gcc make cmake nano vim fish base-devel ninja

info "Adding CachyOS repositories..."
cd /tmp
curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh
cd /tmp

if ! grep -q "cachyos" /etc/pacman.conf; then
    sudo sed -i '/^\[core\]/i \
[cachyos-v3]\nInclude = /etc/pacman.d/cachyos-v3-mirrorlist\n\n\
[cachyos-core-v3]\nInclude = /etc/pacman.d/cachyos-v3-mirrorlist\n\n\
[cachyos-extra-v3]\nInclude = /etc/pacman.d/cachyos-v3-mirrorlist\n\n\
[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n' /etc/pacman.conf
fi

sudo pacman -Sy
sudo pacman -S --needed --noconfirm yay

# ============================================================================
# PHASE 2: AMD + NVIDIA + KERNEL
# ============================================================================

log "Phase 2/5: Hardware setup (Ryzen + RTX 3060 + CachyOS kernel)..."

sudo pacman -S --needed --noconfirm amd-ucode cpupower lm_sensors
echo 'GOVERNOR="schedutil"' | sudo tee /etc/default/cpupower
sudo systemctl enable --now cpupower
yes | sudo sensors-detect

sudo tee /etc/sysctl.d/99-ryzen.conf > /dev/null << 'EOF'
kernel.sched_autogroup_enabled=1
kernel.sched_cfs_bandwidth_slice_us=500
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5
vm.page-cluster=0
EOF

sudo pacman -S --needed --noconfirm linux-cachyos-bore linux-cachyos-bore-headers
sudo pacman -Rs --noconfirm linux linux-headers 2>/dev/null || true

sudo pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'EOF'
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_InitializeSystemMemoryAllocations=0
options nvidia NVreg_EnableGpuFirmware=0
EOF

sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amd_pstate=active amd_iommu=on iommu=pt"/' /etc/default/grub

sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

# ============================================================================
# PHASE 3: CAELESTIA + DEPENDENCIES
# ============================================================================

log "Phase 3/5: Installing Caelestia and dependencies..."

sudo pacman -S --needed --noconfirm \
    gnome-keyring polkit-gnome nautilus gnome-disk-utility gsettings-desktop-schemas \
    gparted gammastep geoclue bluez-utils seahorse libsecret capitaine-cursors \
    qt6ct qt5ct micro pavucontrol mpv swappy grim slurp libqalculate libcava \
    aubio libpipewire libnotify dart-sass fuzzel glib2 python-build \
    python-installer python-hatch python-hatch-vcs ddcutil brightnessctl \
    networkmanager lm_sensors thunar-archive-plugin thunar-media-tags-plugin \
    thunar-volman tumbler ffmpegthumbnailer copyq nm-connection-editor \
    font-manager p7zip unrar unzip zip

yay -S --needed --noconfirm ttf-material-symbols-git nerd-fonts-caskaydia-cove gpu-screen-recorder || true

git clone https://github.com/hoangducdt/caelestia.git ~/.local/share/caelestia
cd ~/.local/share/caelestia

# Install metapackage
yay -Bi . --noconfirm || true

# Link configs
ln -sf $(pwd)/hypr ~/.config/hypr
ln -sf $(pwd)/starship.toml ~/.config/starship.toml
ln -sf $(pwd)/foot ~/.config/foot
ln -sf $(pwd)/fish ~/.config/fish
ln -sf $(pwd)/fastfetch ~/.config/fastfetch
ln -sf $(pwd)/btop ~/.config/btop

# ============================================================================
# PHASE 4: ROG + GAMING + APPS
# ============================================================================

log "Phase 4/5: ROG features, gaming, and applications..."

sudo pacman -S --needed --noconfirm cachyos-settings ananicy-cpp cachyos-ananicy-rules \
    cachyos-kernel-manager zram-generator gamemode lib32-gamemode wine-staging \
    winetricks dxvk-bin vkd3d linux-firmware bluez bluez-utils blueman \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    sof-firmware alsa-firmware alsa-ucm-conf easyeffects sddm fcitx5 \
    fcitx5-gtk fcitx5-qt fcitx5-configtool

sudo systemctl enable --now ananicy-cpp bluetooth
systemctl --user enable --now pipewire pipewire-pulse wireplumber

echo -e "[zram0]\nzram-size = ram / 2" | sudo tee /etc/systemd/zram-generator.conf
sudo systemctl daemon-reload

echo 'ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*|nvme[0-9]*", ATTR{queue/scheduler}="bfq"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules

yay -S --needed --noconfirm iwlwifi-firmware-git openrgb asus-ec-sensors-dkms-git \
    asusctl rog-control-center sddm-sugar-candy-git fcitx5-bamboo \
    nwg-displays ddcui monitorcontrol cachyos-rate-mirrors discord code || true

sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=sugar-candy" | sudo tee /etc/sddm.conf.d/theme.conf
sudo systemctl enable sddm asusd

# Udev rules
sudo tee /etc/udev/rules.d/60-openrgb.rules > /dev/null << 'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", MODE="0666"
SUBSYSTEM=="i2c-dev", MODE="0666"
EOF

sudo tee /etc/udev/rules.d/45-ddcutil-i2c.rules > /dev/null << 'EOF'
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
EOF

sudo tee /etc/modules-load.d/i2c.conf > /dev/null << 'EOF'
i2c-dev
i2c-i801
EOF

echo "asus_ec_sensors" | sudo tee /etc/modules-load.d/asus-ec-sensors.conf
echo "options e1000e EEE=0" | sudo tee /etc/modprobe.d/i225.conf

sudo udevadm control --reload-rules
sudo udevadm trigger
sudo usermod -aG i2c $USER

# ============================================================================
# PHASE 5: CONFIGS & FINALIZATION
# ============================================================================

log "Phase 5/5: Final configurations..."

mkdir -p ~/.config/{hypr,kanshi,gammastep,gamemode}

# Monitors config
tee ~/.config/hypr/monitors.conf > /dev/null << 'EOF'
monitor = DP-1, 2560x1440@144, 0x0, 1
monitor = DP-2, 1920x1080@60, 2560x0, 1
workspace = 1, monitor:DP-1, default:true
workspace = 2, monitor:DP-1
workspace = 3, monitor:DP-1
workspace = 4, monitor:DP-1
workspace = 5, monitor:DP-1
workspace = 6, monitor:DP-2, default:true
workspace = 7, monitor:DP-2
workspace = 8, monitor:DP-2
workspace = 9, monitor:DP-2
workspace = 10, monitor:DP-2
misc {
    vrr = 1
    mouse_move_focuses_monitor = true
}
EOF

# Kanshi
tee ~/.config/kanshi/config > /dev/null << 'EOF'
profile dual {
    output DP-1 mode 2560x1440@144Hz position 0,0 scale 1
    output DP-2 mode 1920x1080@60Hz position 2560,0 scale 1
}
EOF
systemctl --user enable kanshi

# Gammastep
tee ~/.config/gammastep/config.ini > /dev/null << 'EOF'
[general]
temp-day=6500
temp-night=3500
fade=1
gamma=0.8
adjustment-method=wayland
location-provider=manual
[manual]
lat=10.8
lon=106.6
EOF

# GameMode
tee ~/.config/gamemode.ini > /dev/null << 'EOF'
[general]
renice=10
ioprio=0
[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
[cpu]
cpu_governor=performance
EOF

# Scripts
sudo tee /usr/local/bin/lg-brightness > /dev/null << 'EOF'
#!/bin/bash
[ -z "$1" ] && echo "Usage: lg-brightness <0-100>" && exit 1
ddcutil --bus 8 setvcp 10 "$1" 2>/dev/null || true
ddcutil --bus 9 setvcp 10 "$1" 2>/dev/null || true
echo "Brightness: $1%"
EOF

sudo tee /usr/local/bin/game-mode > /dev/null << 'EOF'
#!/bin/bash
if [ "$1" = "on" ]; then
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    echo "Game mode: ON"
else
    echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    echo "Game mode: OFF"
fi
EOF

sudo chmod +x /usr/local/bin/{lg-brightness,game-mode}

# Wallpapers
mkdir -p ~/Pictures/Wallpapers
git clone https://github.com/mylinuxforwork/wallpaper.git ~/Pictures/Wallpapers/wallpaper 2>/dev/null || true

# Apply sysctl
sudo sysctl --system

# ============================================================================
# DONE!
# ============================================================================

log "Installation complete!"
echo
echo "════════════════════════════════════════════════════════════"
echo "  ${GREEN}✓ CachyOS BORE kernel installed${NC}"
echo "  ${GREEN}✓ Nvidia RTX 3060 driver configured${NC}"
echo "  ${GREEN}✓ Ryzen 5800X optimized${NC}"
echo "  ${GREEN}✓ ROG STRIX features enabled${NC}"
echo "  ${GREEN}✓ Dual monitors configured${NC}"
echo "  ${GREEN}✓ Gaming optimizations applied${NC}"
echo "  ${GREEN}✓ Caelestia installed${NC}"
echo "════════════════════════════════════════════════════════════"
echo
warn "IMPORTANT: Reboot required to:"
echo "  • Load CachyOS kernel"
echo "  • Activate Nvidia driver"
echo "  • Apply all optimizations"
echo
echo "After reboot:"
echo "  • Run: fcitx5-configtool  (setup Vietnamese)"
echo "  • Run: openrgb            (setup RGB)"
echo "  • Run: rog-control-center (ROG features)"
echo "  • Run: lg-brightness 70   (test monitors)"
echo
read -p "Reboot now? [Y/n] " -r
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    sudo reboot
fi