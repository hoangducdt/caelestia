# Caelestia Ultimate Gaming Setup

> **Ultimate Arch Linux setup for ROG STRIX B550-XE + Ryzen 7 5800X + RTX 3060 12GB**

Beautiful Hyprland desktop with CachyOS kernel, gaming optimizations, and ROG features.

![Caelestia](https://raw.githubusercontent.com/caelestia-dots/caelestia/main/.github/assets/showcase.png)

## ✨ Features

- 🚀 **CachyOS BORE Kernel** - Optimized for gaming and desktop performance
- 🎮 **Gaming Ready** - GameMode, zram, ananicy, wine/proton optimizations
- 💚 **Nvidia RTX 3060** - Open-source driver with full features
- ⚡ **AMD Ryzen 5800X** - Full optimizations (P-State, governor, sysctl)
- 🎨 **ROG STRIX B550-XE** - RGB control (Aura Sync), sensors, fan control
- 🖥️ **Dual Monitor** - Auto-detection, DDC/CI brightness control
- 🇻🇳 **Vietnamese Input** - Fcitx5 Bamboo pre-configured
- 💎 **Beautiful UI** - Caelestia Hyprland theme + SDDM Sugar Candy

## 🚀 Quick Start

### Prerequisites
- Arch Linux installed (using `archinstall`)
- Internet connection

### One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/hoangducdt/caelestia/main/setup-caelestia-ultimate.sh | bash
```

Or download and run:

```bash
wget https://raw.githubusercontent.com/hoangducdt/caelestia/main/setup-caelestia-ultimate.sh
chmod +x setup-caelestia-ultimate.sh
./setup-caelestia-ultimate.sh
```

**That's it!** After reboot, everything is ready to use.

---

## 📖 Manual Installation

If you prefer manual control:

### Step 1: Install Arch Linux
```bash
archinstall
```

### Step 2: Run the installer
```bash
git clone https://github.com/hoangducdt/caelestia.git ~/.local/share/caelestia
cd ~/.local/share/caelestia
./setup-caelestia-ultimate.sh
```

### Step 3: Reboot
```bash
sudo reboot
```

---

## 🎯 What Gets Installed

### System Base
- CachyOS repositories
- CachyOS BORE kernel (optimized for gaming)
- AMD microcode + optimizations
- Nvidia open-source driver (RTX 3060)

### Desktop Environment
- Hyprland (Wayland compositor)
- Caelestia dotfiles and configs
- SDDM with Sugar Candy theme
- PipeWire audio system

### Gaming
- GameMode + lib32-gamemode
- Wine-staging + DXVK + VKD3D
- GPU screen recorder
- Ananicy (process priority management)
- Zram (compressed swap)
- BFQ I/O scheduler

### ROG STRIX B550-XE Features
- OpenRGB (Aura Sync control)
- ASUS EC Sensors (VRM temps, chipset)
- Asusctl + ROG Control Center
- WiFi 6E firmware (Intel AX210)
- Bluetooth support
- Intel I225-V LAN optimization

### Multi-Monitor Tools
- DDC/CI control (ddcutil, ddcui)
- Kanshi (auto-configuration)
- Gammastep (night light)
- Monitor control GUI (nwg-displays)
- Brightness control script (`lg-brightness`)

### Vietnamese Input
- Fcitx5 framework
- Fcitx5-Bamboo input method
- Pre-configured environment variables

### Applications
- Discord (with Equicord)
- VSCode
- File manager (Thunar + Nautilus)
- Screenshot tools (Swappy, Grim, Slurp)
- Audio control (Pavucontrol, EasyEffects)
- Video player (MPV)
- And much more...

---

## ⚙️ Post-Installation Setup

### 1. Configure Vietnamese Input
```bash
fcitx5-configtool
```
- Add "Bamboo" to Input Method
- Set keyboard shortcut to switch

### 2. Control RGB Lighting
```bash
openrgb
```

### 3. ROG Features
```bash
rog-control-center
```

### 4. Test Monitor Brightness Control
```bash
lg-brightness 70  # Set brightness to 70%
```

### 5. Gaming Mode
```bash
game-mode on   # Enable performance mode
# Play your games
game-mode off  # Back to normal
```

---

## 🖥️ Monitor Configuration

### Dual LG Monitors Setup

The installer auto-configures dual monitors. Edit `~/.config/hypr/monitors.conf`:

```conf
# Primary monitor (left)
monitor = DP-1, 2560x1440@144, 0x0, 1

# Secondary monitor (right)
monitor = DP-2, 1920x1080@60, 2560x0, 1
```

### Adjust positions:
- **Side by side**: `position 2560x0` (right), `-1920x0` (left)
- **Vertical stack**: `position 0x1440` (below), `0x-1080` (above)

### Multi-monitor keybinds:
```
SUPER + comma/period     - Switch focus between monitors
SUPER + SHIFT + comma/period - Move workspace to other monitor
SUPER + CTRL + comma/period  - Move window to other monitor
SUPER + ALT + S          - Swap workspaces between monitors
```

---

## 🎮 Gaming Optimizations

### Steam Launch Options
```
gamemoderun %command%
```

### Proton with DXVK HUD
```
DXVK_HUD=fps gamemoderun %command%
```

### CPU Performance Mode
```bash
# Manual mode switching
game-mode on   # Performance governor
game-mode off  # Schedutil governor
```

---

## 🔧 Verification Commands

After reboot, verify everything:

```bash
# Check kernel
uname -r
# Expected: 6.x.x-cachyos-bore

# Check Nvidia
nvidia-smi
# Should show RTX 3060 info

# Check driver type
cat /proc/driver/nvidia/version
# Should contain "Open Kernel modules"

# Check PCIe 4.0
sudo lspci -vv | grep -A 10 NVIDIA | grep LnkSta
# Should show: Speed 16GT/s (Gen4), Width x16

# Check ReBAR
sudo dmesg | grep -i rebar
# Should show: Resizable BAR enabled

# Check AMD P-State
cat /sys/devices/system/cpu/amd_pstate/status
# Expected: active

# Check temperatures
sensors
# Should show: CPU, GPU, VRM, Chipset temps

# Check monitors
ddcutil detect
hyprctl monitors

# Check services
systemctl status ananicy-cpp
systemctl status bluetooth
systemctl status asusd
systemctl --user status pipewire
```

---

## 🎨 Customization

### Change Caelestia Theme
```bash
caelestia scheme set -n <theme-name>
```

### Wallpapers
Located in: `~/Pictures/Wallpapers/wallpaper/`

### Hyprland Configs
- Main config: `~/.config/hypr/hyprland.conf`
- Monitors: `~/.config/hypr/monitors.conf`
- Keybinds: `~/.config/hypr/keybinds.conf`
- Environment: `~/.config/hypr/env.conf`

---

## 🆘 Troubleshooting

### Nvidia driver not loading
```bash
lsmod | grep nvidia  # Check if modules loaded
sudo mkinitcpio -P   # Rebuild initramfs
sudo reboot
```

### Monitors not detected
```bash
sudo usermod -aG i2c $USER
# Logout and login again
```

### RGB not working
```bash
sudo modprobe i2c-dev
sudo modprobe i2c-i801
openrgb
```

### Fcitx5 not showing
Check `~/.config/hypr/env.conf`:
```conf
env = GTK_IM_MODULE, fcitx
env = QT_IM_MODULE, fcitx
env = XMODIFIERS, @im=fcitx
```

Then:
```bash
killall fcitx5
fcitx5 -d --replace
```

### Low gaming performance
```bash
# Enable game mode
game-mode on

# Check governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# Should be: performance

# Check GameMode is running
gamemoded -s
```

---

## 🖱️ BIOS Settings (Important!)

For optimal performance, configure these in BIOS:

### Performance
- **PBO (Precision Boost Overdrive)**: Enabled
- **CPB (Core Performance Boost)**: Enabled  
- **XMP/DOCP**: Enabled

### PCIe/GPU
- **Above 4G Decoding**: **Enabled** ✅
- **Re-Size BAR Support**: **Enabled** ✅
- **PCIe Gen**: Auto or Gen 4

### Power
- **C-States**: Enabled
- **Power Supply Idle Control**: Low Current Idle

### Boot
- **Fast Boot**: Disabled
- **CSM (Compatibility Support Module)**: Disabled

---

## 📁 Important Files & Locations

### Configs
- Hyprland: `~/.config/hypr/`
- Fcitx5: `~/.config/fcitx5/`
- GameMode: `~/.config/gamemode.ini`
- Kanshi: `~/.config/kanshi/config`
- Gammastep: `~/.config/gammastep/config.ini`

### Scripts
- Brightness: `/usr/local/bin/lg-brightness`
- Game mode: `/usr/local/bin/game-mode`

### System
- Nvidia: `/etc/modprobe.d/nvidia.conf`
- GRUB: `/etc/default/grub`
- Mkinitcpio: `/etc/mkinitcpio.conf`
- SDDM: `/etc/sddm.conf.d/theme.conf`
- Sysctl: `/etc/sysctl.d/99-ryzen.conf`

---

## 🤝 Credits

- **Original Caelestia**: [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia)
- **CachyOS**: [CachyOS](https://cachyos.org/)
- **OpenRGB**: [OpenRGB](https://openrgb.org/)
- **Hyprland**: [Hyprland](https://hyprland.org/)

---

## 📝 License

This fork maintains the original Caelestia license (GPL-3.0).

---

## 🎯 Hardware Specs (Tested On)

- **Motherboard**: ASUS ROG STRIX B550-XE GAMING WIFI
- **CPU**: AMD Ryzen 7 5800X
- **GPU**: NVIDIA GeForce RTX 3060 12GB
- **RAM**: 32GB DDR4 (or your specs)
- **Monitors**: Dual LG (2560x1440@144Hz + 1920x1080@60Hz)

---

## 💬 Support

If you encounter issues:
1. Check troubleshooting section above
2. Run verification commands
3. Check logs: `journalctl -xe`
4. Open an issue on GitHub

---

**Happy gaming! 🎮🚀**