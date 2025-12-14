# ============================================================================
# CAELESTIA ULTIMATE INSTALLER - HƯỚNG DẪN SỬ DỤNG
# ============================================================================

## CÀI ĐẶT ĐƠN GIẢN (CHỈ 3 BƯỚC)

### BƯỚC 1: Cài Arch Linux
```bash
archinstall
```

### BƯỚC 2: Clone Caelestia và thay thế install.fish
```bash
# Update system
sudo pacman -Syu

# Clone Caelestia
git clone https://github.com/caelestia-dots/caelestia.git ~/.local/share/caelestia
cd ~/.local/share/caelestia

# Backup install.fish gốc
mv install.fish install.fish.original

# Tải install-ultimate.fish và đổi tên
# (Copy nội dung từ install-ultimate.fish vào)
nano install.fish
# Hoặc download từ đâu đó
chmod +x install.fish
```

### BƯỚC 3: Chạy installer với --full-setup
```bash
./install.fish --full-setup --noconfirm --discord --vscode=code
```

**XONG! Reboot và tận hưởng!** 🚀

---

## CHI TIẾT CÁC OPTION

### CÀI ĐẶT FULL (TẤT CẢ MỌI THỨ)
```bash
./install.fish --full-setup --noconfirm --discord --vscode=code --spotify --zen
```

**Bao gồm:**
- ✅ CachyOS BORE kernel
- ✅ Nvidia RTX 3060 open driver
- ✅ AMD Ryzen 5800X optimizations
- ✅ ROG STRIX B550-XE features (RGB, sensors, fan control)
- ✅ Dual LG monitor setup
- ✅ Gaming optimizations (GameMode, zram, ananicy)
- ✅ Vietnamese input (Fcitx5 Bamboo)
- ✅ SDDM Sugar Candy theme
- ✅ Discord + VSCode + Spotify + Zen browser
- ✅ Tất cả Caelestia configs

---

### CÀI ĐẶT CƠ BẢN (CHỈ CAELESTIA)
```bash
./install.fish --noconfirm
```

**Bao gồm:**
- ✅ Caelestia dotfiles
- ✅ Hyprland configs
- ✅ Basic dependencies

---

### CÀI ĐẶT CUSTOM

#### Bỏ qua CachyOS kernel (giữ kernel hiện tại)
```bash
./install.fish --full-setup --skip-cachyos --noconfirm
```

#### Bỏ qua gaming optimizations
```bash
./install.fish --full-setup --skip-gaming --noconfirm
```

#### Dùng yay thay vì paru
```bash
./install.fish --full-setup --aur-helper=yay --noconfirm
```

#### Kết hợp nhiều options
```bash
./install.fish --full-setup --skip-gaming --aur-helper=yay --discord --vscode=code --noconfirm
```

---

## TẤT CẢ OPTIONS

```
Options:
  -h, --help                  Hiện help
  --noconfirm                 Không hỏi xác nhận
  --full-setup                Cài đặt FULL (CachyOS + Nvidia + ROG + Gaming)
  --skip-cachyos              Bỏ qua CachyOS kernel
  --skip-gaming               Bỏ qua gaming optimizations
  --spotify                   Cài Spotify + Spicetify
  --vscode=[codium|code]      Cài VSCodium hoặc VSCode
  --discord                   Cài Discord + Equicord
  --zen                       Cài Zen browser
  --aur-helper=[yay|paru]     Chọn AUR helper (mặc định: paru)
```

---

## WORKFLOW KHUYẾN NGHỊ

### Setup mới hoàn toàn (từ Arch mới cài)
```bash
# 1. Cài Arch Linux
archinstall

# 2. Reboot vào Arch
# 3. Clone và cài
git clone https://github.com/caelestia-dots/caelestia.git ~/.local/share/caelestia
cd ~/.local/share/caelestia

# Thay install.fish bằng install-ultimate.fish
# Rồi chạy:
./install.fish --full-setup --noconfirm --discord --vscode=code

# 4. Reboot
sudo reboot

# 5. Sau reboot, cấu hình Fcitx5
fcitx5-configtool
# Thêm Bamboo vào Input Method

# 6. Test everything
uname -r              # Kiểm tra kernel
nvidia-smi            # Kiểm tra Nvidia
sensors               # Kiểm tra nhiệt độ
ddcutil detect        # Kiểm tra monitors
lg-brightness 70      # Test điều chỉnh độ sáng
openrgb               # Chạy RGB control
rog-control-center    # Chạy ROG Control
```

### Đã có Caelestia, thêm full setup
```bash
cd ~/.local/share/caelestia

# Backup install.fish cũ
cp install.fish install.fish.backup

# Thay bằng install-ultimate.fish
# Rồi chạy:
./install.fish --full-setup --noconfirm

# Reboot
sudo reboot
```

### Chỉ cập nhật Caelestia dotfiles
```bash
cd ~/.local/share/caelestia
git pull
./install.fish --noconfirm
```

---

## KIỂM TRA SAU KHI CÀI

### Kiểm tra kernel
```bash
uname -r
# Expected: 6.x.x-cachyos-bore
```

### Kiểm tra Nvidia
```bash
nvidia-smi
# Phải hiện driver và GPU info

# Kiểm tra open-source driver
cat /proc/driver/nvidia/version
# Phải có chữ "Open Kernel modules"

# Kiểm tra PCIe 4.0
sudo lspci -vv | grep -A 10 NVIDIA | grep LnkSta
# Phải thấy: Speed 16GT/s (Gen4), Width x16
```

### Kiểm tra AMD P-State
```bash
cat /sys/devices/system/cpu/amd_pstate/status
# Expected: active
```

### Kiểm tra CPU governor
```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# Expected: schedutil
```

### Kiểm tra nhiệt độ
```bash
sensors
# Phải thấy: CPU temp, GPU temp, VRM temp, Chipset temp
```

### Kiểm tra ReBAR
```bash
sudo dmesg | grep -i rebar
# Phải thấy: Resizable BAR enabled
```

### Kiểm tra monitors
```bash
ddcutil detect
hyprctl monitors
```

### Test brightness control
```bash
lg-brightness 50
```

### Kiểm tra services
```bash
systemctl status ananicy-cpp
systemctl status bluetooth
systemctl status asusd
systemctl --user status pipewire
```

---

## TROUBLESHOOTING

### Lỗi: yay not found
```bash
# CachyOS repos chưa được thêm đúng
# Thêm lại manually:
sudo nano /etc/pacman.conf
# Thêm CachyOS repos như trong script
sudo pacman -Sy
sudo pacman -S yay
```

### Lỗi: Nvidia driver không load
```bash
# Kiểm tra modules
lsmod | grep nvidia

# Rebuild initramfs
sudo mkinitcpio -P

# Reboot
sudo reboot
```

### Lỗi: Monitors không detect
```bash
# Thêm user vào i2c group
sudo usermod -aG i2c $USER

# Logout và login lại
# Hoặc reboot
```

### Lỗi: RGB không hoạt động
```bash
# Load i2c modules
sudo modprobe i2c-dev
sudo modprobe i2c-i801

# Chạy OpenRGB
openrgb
```

### Lỗi: Fcitx5 không hiện
```bash
# Kiểm tra env variables trong ~/.config/hypr/env.conf
# Phải có:
# env = GTK_IM_MODULE, fcitx
# env = QT_IM_MODULE, fcitx
# env = XMODIFIERS, @im=fcitx

# Restart Fcitx5
killall fcitx5
fcitx5 -d --replace
```

### Game performance thấp
```bash
# Bật game mode
game-mode on

# Chạy game
# ...

# Tắt game mode
game-mode off
```

---

## BIOS SETTINGS QUAN TRỌNG

Sau khi cài xong, vào BIOS và set:

### Performance
- **PBO**: Enabled
- **CPB**: Enabled
- **XMP/DOCP**: Enabled

### PCIe/GPU
- **Above 4G Decoding**: Enabled ✅
- **Re-Size BAR Support**: Enabled ✅
- **PCIe Gen**: Auto hoặc Gen 4

### Power
- **C-States**: Enabled

### Boot
- **Fast Boot**: Disabled
- **CSM**: Disabled

---

## POST-INSTALLATION TIPS

### Tối ưu Steam gaming
```bash
# Thêm launch options trong Steam:
gamemoderun %command%

# Hoặc với Proton:
DXVK_HUD=fps gamemoderun %command%
```

### Wallpaper đẹp
```bash
cd ~/Pictures/Wallpapers/wallpaper
# Chọn wallpaper yêu thích
```

### Themes
```bash
# Chuyển theme qua Caelestia CLI
caelestia scheme set -n <theme-name>
```

### Font tweaking
```bash
# Install thêm fonts
yay -S nerd-fonts-complete
```

---

## FILES QUAN TRỌNG

### Config locations
- Hyprland: `~/.config/hypr/`
- Monitors: `~/.config/hypr/monitors.conf`
- Fcitx5: `~/.config/fcitx5/`
- GameMode: `~/.config/gamemode.ini`
- Kanshi: `~/.config/kanshi/config`
- Gammastep: `~/.config/gammastep/config.ini`

### Scripts
- Brightness: `/usr/local/bin/lg-brightness`
- Game mode: `/usr/local/bin/game-mode`

### System configs
- Nvidia: `/etc/modprobe.d/nvidia.conf`
- GRUB: `/etc/default/grub`
- Mkinitcpio: `/etc/mkinitcpio.conf`
- SDDM: `/etc/sddm.conf.d/theme.conf`
- Sysctl: `/etc/sysctl.d/99-ryzen-optimizations.conf`

---

## SUPPORT

Nếu gặp vấn đề:
1. Kiểm tra logs: `journalctl -xe`
2. Kiểm tra Hyprland: `hyprctl`
3. Kiểm tra systemd: `systemctl --failed`
4. Reboot lại (seriously, it helps!)

---

**Chúc bạn gaming vui vẻ! 🎮🚀✨**