# Caelestia Installer - CachyOS Complete Workstation Setup

**Thiết lập tự động hoàn chỉnh** cho hệ thống CachyOS với Hyprland, tối ưu cho gaming, phát triển phần mềm, AI/ML, và sáng tạo nội dung 3D/2D.

## 🖥️ Cấu Hình Phần Cứng Mục Tiêu

- **Bo mạch chủ**: ASUS ROG STRIX B550-XE GAMING WIFI
- **CPU**: AMD Ryzen 7 5800X (8 cores / 16 threads)
- **GPU**: NVIDIA GeForce RTX 3060 12GB
- **RAM**: 32GB DDR4 (khuyến nghị)
- **Hệ điều hành**: CachyOS (Arch-based)

---

## 🚀 Cài Đặt

### Yêu Cầu Trước Khi Cài
- CachyOS đã được cài đặt
- Kết nối internet ổn định
- Quyền sudo

### Cài đặt bằng một dòng lệnh (Khuyến nghị)
```bash
curl -fsSL https://raw.githubusercontent.com/hoangducdt/caelestia/main/caelestia-install.sh | bash
```

### Cài đặt thủ công
```bash
git clone https://github.com/hoangducdt/caelestia.git
cd caelestia
chmod +x caelestia-install.sh
./caelestia-install.sh
```

### Tính Năng Script
- ✅ **State Management**: Tự động lưu tiến trình, có thể tiếp tục nếu bị gián đoạn
- ✅ **Auto Backup**: Sao lưu các file cấu hình quan trọng
- ✅ **Conflict Resolution**: Tự động xử lý xung đột gói
- ✅ **Retry Mechanism**: Tự động thử lại khi cài đặt thất bại
- ✅ **Comprehensive Logging**: Log chi tiết tại `~/setup_complete_*.log`

⏱️ **Thời gian cài đặt**: 30-90 phút (tùy thuộc vào tốc độ mạng)

---

## 📦 Các Thành Phần Được Cài Đặt

### 1. System Update & Base Setup
- Cập nhật hệ thống với CachyOS keyrings
- Cài đặt các công cụ cơ bản: `yay`, `base-devel`, `git`, `wget`, `curl`

### 2. NVIDIA Optimization (Chỉ Cấu Hình - Không Thay Đổi Driver)
**Điều quan trọng**: Script chỉ tối ưu hóa cấu hình, **KHÔNG cài đặt driver NVIDIA**. Driver phải được cài qua CachyOS installer hoặc thủ công.

**Tối ưu hóa được áp dụng**:
```bash
# Modprobe configuration
- nvidia_drm modeset=1 fbdev=1
- NVreg_PreserveVideoMemoryAllocations=1
- NVreg_UsePageAttributeTable=1
- NVreg_DynamicPowerManagement=0x02
- NVreg_EnableGpuFirmware=0

# Mkinitcpio modules
- nvidia, nvidia_modeset, nvidia_uvm, nvidia_drm

# Power management services
- nvidia-suspend.service
- nvidia-hibernate.service
- nvidia-resume.service
```

### 3. Caelestia Configurations
**Desktop Environment**: Hyprland + Caelestia configs từ repository

**Config Files được cài đặt**:
- Symbolic links từ `~/.local/share/caelestia/Configs/*` → `~/.config/*`
- Auto backup configs cũ với timestamp
- Hyprland scripts với quyền thực thi
- Fastfetch với logo tùy chỉnh
- Kitty terminal configuration
- GTK-3.0 themes và bookmarks

### 4. Meta Packages (180+ gói)

#### Caelestia Core
```
caelestia-cli, caelestia-shell, hyprland
xdg-desktop-portal-gtk, xdg-desktop-portal-hyprland
hyprpicker, cliphist, inotify-tools
app2unit, trash-cli, eza, jq
adw-gtk-theme, papirus-icon-theme
qt5ct-kde, qt6ct-kde
todoist-appimage, uwsm, direnv
```

#### System Essentials
```
fish, kitty, wl-clipboard
qt5-wayland, qt6-wayland
gnome-keyring, polkit-gnome
thunar, tumbler, ffmpegthumbnailer, libgsf
```

#### File Systems & Compression
```
btrfs-progs, exfatprogs, ntfs-3g, dosfstools
zip, unzip, p7zip, unrar, rsync, tmux
```

#### Shell Tools
```
starship, eza, bat, ripgrep, fd, fzf, zoxide
```

#### Monitoring Tools
```
htop, btop, neofetch, fastfetch
nvtop, amdgpu_top, iotop, iftop
```

#### Disk Management
```
gparted, gnome-disk-utility
```

#### PDF Tools
```
zathura, zathura-pdf-poppler
```

#### Network
```
networkmanager, network-manager-applet
nm-connection-editor
```

### 5. Python & AI/ML Stack

#### Python Essentials
```
python, python-pip, python-virtualenv
python-numpy, python-pandas
jupyter-notebook, python-scikit-learn
python-matplotlib, python-pillow, python-scipy
```

#### CUDA & Deep Learning
```
cuda, cudnn
python-pytorch-cuda
python-torchvision-cuda
python-torchaudio-cuda
python-transformers, python-accelerate
```

#### AI Tools
```
ollama-cuda
```

### 6. Audio Stack
```
pipewire, pipewire-pulse, pipewire-alsa, pipewire-jack
wireplumber, pavucontrol, helvum
v4l2loopback-dkms
gstreamer-vaapi
noise-suppression-for-voice
```

### 7. Multimedia

#### Video Players
```
mpv, vlc
```

#### Image Viewers/Editors
```
imv, gimp, inkscape
```

#### Audio Production
```
audacity, ardour
```

#### Video Editing
```
kdenlive, obs-studio
```

#### Codecs & Multimedia Libraries
```
gst-plugins-good, gst-plugins-bad
gst-plugins-ugly, gst-libav
ffmpeg, lib32-ffmpeg
gstreamer, gst-plugins-base
libvorbis, lib32-libvorbis
opus, lib32-opus
flac, lib32-flac
x264, x265
```

#### Hardware Acceleration
```
libva-nvidia-driver
```

### 8. Development Tools

#### Code Editors
```
neovim, codium (VS Code alternative)
```

#### Version Control
```
git, github-cli
```

#### Build Tools
```
cmake, ninja, meson
```

#### Compilers
```
gcc, clang
```

#### Languages
```
nodejs, npm, rust, go
```

#### Containers
```
docker, docker-compose
```

#### Database
```
postgresql, redis
```

#### API Testing
```
postman-bin
```

#### .NET Development
```
dotnet-sdk, dotnet-runtime
dotnet-sdk-9.0, dotnet-sdk-8.0
aspnet-runtime
mono, mono-msbuild
```

### 9. Gaming Stack

#### CachyOS Gaming Meta
```
cachyos-gaming-meta
  ├─ alsa-plugins
  ├─ giflib, lib32-giflib
  ├─ glfw
  ├─ gst-plugins-base-libs, lib32-gst-plugins-base-libs
  ├─ gtk3, lib32-gtk3
  ├─ libjpeg-turbo, lib32-libjpeg-turbo
  ├─ libva, lib32-libva
  ├─ mpg123, lib32-mpg123
  ├─ ocl-icd, opencl-icd-loader, lib32-opencl-icd-loader
  ├─ openal, lib32-openal
  ├─ proton-cachyos-slr
  ├─ umu-launcher
  ├─ protontricks
  ├─ ttf-liberation
  ├─ wine-cachyos-opt
  ├─ winetricks
  └─ vulkan-tools

cachyos-gaming-applications
  ├─ gamescope
  ├─ goverlay
  ├─ heroic-games-launcher
  ├─ lib32-mangohud, mangohud
  ├─ lutris
  ├─ steam
  └─ wqy-zenhei
```

#### Additional Gaming Components
```
lib32-vulkan-icd-loader
lib32-nvidia-utils
vulkan-icd-loader
gamemode, lib32-gamemode
xpadneo-dkms (Xbox controller support)
protonup-qt (Proton-GE manager)
```

### 10. Blender & 3D Creation

#### Blender Core
```
blender
```

#### Blender Dependencies
```
openimagedenoise  # AI denoising
opencolorio       # Color management
opensubdiv        # Subdivision surfaces
openvdb           # Volumetric data
embree            # Ray tracing
openimageio       # Image I/O
alembic           # Animation exchange
openjpeg2         # JPEG 2000
openexr           # HDR images
libspnav          # 3D mouse support
```

### 11. Creative Suite

#### Image Editing
```
gimp, gimp-plugin-gmic
krita              # Digital painting
darktable          # RAW photo workflow
rawtherapee        # Advanced RAW editing
```

#### Vector Graphics
```
inkscape
```

#### Video Editing
```
kdenlive
frei0r-plugins
mediainfo, mlt
davinci-resolve
natron             # Compositing/VFX
```

#### Audio Production
```
audacity, ardour   # Digital Audio Workstation
```

#### Publishing
```
scribus            # Desktop publishing
```

#### Supporting Tools
```
imagemagick, graphicsmagick
potrace, fontforge
```

### 12. System Optimization

#### Performance Tools
```
irqbalance         # IRQ load balancing
cpupower           # CPU frequency scaling
thermald           # Thermal management
tlp                # Power management
powertop           # Power analysis
preload            # Application preloader
```

### 13. Display & Monitor Tools
```
wlr-randr, kanshi, nwg-displays
```

### 14. Professional Applications
```
microsoft-edge-stable-bin
docker-desktop
rider              # JetBrains C# IDE
github-desktop
lmstudio           # Local LLM interface
```

### 15. Streaming & Recording
```
obs-vaapi
obs-nvfbc
obs-vkcapture
obs-websocket
```

### 16. Communication
```
vesktop-bin        # Discord with Vencord
```

### 17. Hardware Control
```
openrgb            # RGB lighting control
```

### 18. Vietnamese Input Method
```
fcitx5
fcitx5-qt, fcitx5-gtk
fcitx5-configtool
fcitx5-bamboo-git
```

### 19. Display Manager
```
gdm, gdm-settings
```

### 20. Fonts
```
ttf-jetbrains-mono-nerd
adobe-source-code-pro-fonts
ttf-liberation
ttf-dejavu
```

---

## ⚙️ System Configurations

### 1. Gaming Optimization
- Multilib repository enabled (32-bit support)
- User added to `gamemode` group
- MangoHud configured for RTX 3060

**MangoHud Config** (`~/.config/MangoHud/MangoHud.conf`):
```
legacy_layout=false
horizontal
gpu_stats, cpu_stats, ram, vram
fps, frametime, frame_timing
vulkan_driver, wine, engine_version
gamemode
```

### 2. Development Setup
- Docker service enabled
- User added to `docker` group
- Docker Compose ready

### 3. Multimedia Configuration
- Pipewire services enabled (user-level):
  - pipewire.service
  - pipewire-pulse.service
  - wireplumber.service

### 4. AI/ML Setup
- Ollama service enabled and started
- CUDA toolkit configured

### 5. Streaming Configuration
- v4l2loopback kernel module loaded
- Module auto-loads on boot via `/etc/modules-load.d/v4l2loopback.conf`

### 6. System Optimization (Ryzen 7 5800X)

#### CPU Governor
```bash
# Performance mode for desktop
cpupower frequency-set -g performance

# Systemd service created:
/etc/systemd/system/cpupower-performance.service
```

#### Services Enabled
```bash
irqbalance.service
thermald.service
tlp.service
cpupower-performance.service
```

#### TLP Configuration
```
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_AC=performance
```

#### Kernel Parameters (`/etc/sysctl.d/99-ryzen-optimization.conf`)
```
# Ryzen 7 5800X Optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5

# Network Performance
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr

# File System
fs.inotify.max_user_watches=524288
```

#### I/O Scheduler Rules (`/etc/udev/rules.d/60-ioschedulers.rules`)
```
# BFQ for HDD/SSD responsiveness
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="bfq"

# None for NVMe (already optimal)
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
```

### 7. DNS Configuration

**Systemd-resolved** (`/etc/systemd/resolved.conf`):
```
DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 
    2606:4700:4700::1111#cloudflare-dns.com 
    2606:4700:4700::1001#cloudflare-dns.com

FallbackDNS=9.9.9.9#dns.quad9.net 2620:fe::9#dns.quad9.net 
            1.1.1.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 
            8.8.8.8#dns.google 2001:4860:4860::8888#dns.google

DNSOverTLS=yes
```

### 8. Static IP Configuration

**NetworkManager Profile** (`/etc/NetworkManager/system-connections/static-ethernet.nmconnection`):
```
[connection]
id=static-ethernet
type=ethernet
interface-name=<detected-interface>
autoconnect=true

[ipv4]
method=manual
address1=192.168.1.2/24,192.168.1.1
dns=1.1.1.1;1.0.0.1;

[ipv6]
method=auto
```

### 9. Directory Structure

#### User Directories
```
~/Desktop
~/Documents
~/Downloads
~/Music
~/Videos
~/Pictures/Wallpapers (với git clone từ mylinuxforwork)
~/OneDrive
```

#### Project Directories
```
~/AI-Projects
~/AI-Models
~/Creative-Projects
~/Blender-Projects
```

#### Config Directories
```
~/.local/bin
~/.config/hypr/scripts
~/.config/caelestia
~/.config/hypr/hyprland
~/.config/fastfetch/logo
~/.config/kitty
~/.config/xfce4
~/.config/gtk-3.0
```

#### GTK Bookmarks (`~/.config/gtk-3.0/bookmarks`)
```
file://$HOME/Downloads
file://$HOME/Documents
file://$HOME/Pictures
file://$HOME/Videos
file://$HOME/Music
file://$HOME/OneDrive
```

---

## 🔧 Post-Installation Steps

### 1. Reboot Required
```bash
sudo reboot
```
Các thay đổi sau cần reboot:
- NVIDIA kernel module configurations
- CPU governor settings
- Systemd services
- Network configurations

### 2. Verify NVIDIA Setup
```bash
nvidia-smi
```
Nên thấy GPU được nhận diện và driver version.

### 3. Test Gaming
```bash
# Enable gamemode for Steam
gamemoderun %command%

# Check MangoHud
mangohud glxgears
```

### 4. Configure Blender GPU
```bash
# Launch Blender
blender

# Go to: Edit → Preferences → System → Cycles Render Devices
# Select: OptiX
# Enable: GeForce RTX 3060
```

### 5. Start AI Services
```bash
# Verify Ollama is running
sudo systemctl status ollama

# Test CUDA
python -c "import torch; print(torch.cuda.is_available())"
```

### 6. Configure Vietnamese Input
```bash
# Launch Fcitx5 Configuration
fcitx5-configtool

# Add Bamboo input method
# Configure hotkey (default: Ctrl+Space)
```

### 7. Setup GDM
```bash
# GDM should auto-start on next boot
# Configure with:
gdm-settings
```

---

## 📊 Expected Performance

### CPU (Ryzen 7 5800X)
```
Base: 3.8 GHz
Boost: Up to 4.7 GHz (single-core)
All-core sustained: 4.4-4.5 GHz
Temperature (idle): 40-50°C
Temperature (load): 70-80°C
Power: 105W TDP, 142W PPT
```

### GPU (RTX 3060 12GB)
```
Boost clock: 1777 MHz
Memory: 12GB GDDR6 @ 15 Gbps
Temperature (idle): 30-40°C
Temperature (load): 60-75°C
Power: 170W TDP
CUDA Compute: 8.6
Tensor Cores: Yes (AI acceleration)
RT Cores: Gen 2
```

### Blender Rendering (Cycles OptiX)
```
Simple scene (1M polygons): 2-5 minutes
Complex scene (10M+ polygons): 10-30 minutes
Animation (250 frames): 2-8 hours
Viewport: Real-time with 128-256 samples
```

### Gaming Performance
```
1080p Ultra: 60-144 FPS (esports)
1080p High/Ultra: 40-90 FPS (AAA titles)
Proton/Wine compatibility: 80%+ games work
Performance vs Windows: 90-95%
```

### AI/ML Capabilities (12GB VRAM)
```
✅ Llama 3.2 3B (3GB VRAM) - Fast
✅ Mistral 7B (4-5GB VRAM) - Balanced
✅ Llama 3.1 8B (5-6GB VRAM) - High quality
✅ CodeLlama 7B (4-5GB VRAM) - Programming
⚠️ Mixtral 8x7B (6-8GB VRAM) - 4-bit quantization
✅ Stable Diffusion 1.5 (512x512) - Fast
✅ SDXL (1024x1024) - Use --medvram
✅ ControlNet - Works well
```

---

## 🛠️ Troubleshooting

### NVIDIA Driver Issues
```bash
# Check driver status
pacman -Qi nvidia-utils

# Verify kernel modules
lsmod | grep nvidia

# Check if optimization was applied
cat /etc/modprobe.d/nvidia.conf
cat /etc/mkinitcpio.conf
```

### Gaming Performance Issues
```bash
# Enable gamemode
systemctl --user status gamemoded

# Check MangoHud
cat ~/.config/MangoHud/MangoHud.conf

# Verify multilib
grep -A1 "\[multilib\]" /etc/pacman.conf
```

### Docker Permission Denied
```bash
# Check docker group
groups $USER

# If not in docker group, log out and log back in
# Or run:
newgrp docker
```

### Blender Not Using GPU
```bash
# Check CUDA
nvidia-smi

# Verify CUDA toolkit
pacman -Qi cuda

# In Blender:
# Edit → Preferences → System → Cycles Render Devices → OptiX
```

### Vietnamese Input Not Working
```bash
# Start Fcitx5
fcitx5 &

# Set environment variables (add to ~/.profile or ~/.bash_profile):
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
```

### OBS NVENC Not Available
```bash
# Install CUDA
sudo pacman -S cuda

# Check ffmpeg hardware acceleration
ffmpeg -hwaccels

# Restart OBS
```

---

## 📁 Important File Locations

### Logs & State
```
~/setup_complete_*.log              # Installation log
~/.cache/caelestia-setup/setup_state.json  # Setup state (for resume)
~/Documents/caelestia-configs-*     # Config backups
```

### Configuration Files
```
~/.local/share/caelestia/           # Caelestia repository
~/.config/                          # User configurations (symlinked)
/etc/modprobe.d/nvidia.conf         # NVIDIA modprobe settings
/etc/mkinitcpio.conf                # Early boot modules
/etc/systemd/resolved.conf          # DNS configuration
/etc/NetworkManager/system-connections/  # Network profiles
/etc/sysctl.d/99-ryzen-optimization.conf  # Kernel parameters
/etc/udev/rules.d/60-ioschedulers.rules   # I/O scheduler
```

---

## 🎯 Use Cases

### 1. 3D Artist / Animator
- Blender with OptiX rendering (3-5x faster than CPU)
- Real-time viewport performance
- 12GB VRAM for complex scenes
- GPU-accelerated compositing

### 2. Graphic Designer
- GIMP for photo editing
- Inkscape for vector graphics
- Krita for digital painting
- Darktable for RAW workflow

### 3. Video Editor / Streamer
- Kdenlive/DaVinci for editing
- OBS with NVENC (no FPS loss)
- GPU effects rendering
- Low-latency streaming

### 4. Game Developer
- .NET development (C#)
- Full toolchain: Rider, VS Code
- Docker for containerization
- Blender for asset creation

### 5. AI/ML Developer
- Local LLM inference (Ollama)
- Stable Diffusion generation
- PyTorch/TensorFlow GPU
- Jupyter notebooks
- CUDA 8.6 support

### 6. Gamer
- Steam + Proton-GE
- Lutris for non-Steam games
- GameMode for performance
- MangoHud for monitoring
- Full Xbox controller support

---

## 💾 Disk Space Requirements

### Fresh Installation
```
System base: ~15GB
Gaming tools: ~5GB
Development: ~8GB
AI/ML tools: ~10GB
Creative Suite: ~5GB
Total: ~43GB
```

### After Usage
```
Blender projects: 5-50GB
AI models: 20-50GB
Game installations: varies (10-100GB per game)
Video projects: 50-200GB
Recommended free space: 200-500GB
```

---

## 🔍 Script Features

### State Management
- JSON-based state tracking
- Resume capability on interruption
- Tracks completed/failed/warning steps
- Timestamp logging

### Backup System
- Automatic backup of modified system files
- Timestamped backups in `~/Documents/`
- Preserves original configurations

### Package Management
- Intelligent package detection (official repos vs AUR)
- Automatic conflict resolution
- Retry mechanism with exponential backoff
- Timeout protection for AUR builds
- Skip already-installed packages

### Error Handling
- Comprehensive logging
- Color-coded output
- Non-fatal warnings
- Critical error stopping with log reference

### Safety Features
- No automatic driver installation (user must install)
- Confirmation on config overwrites
- Backup before modifications
- Sudo keep-alive mechanism

---

## ⚠️ Important Notes

### About NVIDIA Drivers
⚠️ **CRITICAL**: This script does NOT install NVIDIA drivers. You must install them via:
```bash
# Option 1: CachyOS installer (recommended)
# Option 2: Manual installation
sudo pacman -S linux-cachyos-nvidia-open
```

The script only optimizes the configuration for better performance.

### Network Configuration
The script sets a static IP `192.168.1.2/24` with gateway `192.168.1.1`. Modify this in the script if your network uses different addressing.

### Multilib Repository
Automatically enabled for 32-bit gaming support. If you need to manually enable:
```bash
sudo nano /etc/pacman.conf
# Uncomment [multilib] section
sudo pacman -Sy
```

---

## 🌟 Highlights

### Performance
- ✅ **CPU Governor**: Performance mode for maximum speed
- ✅ **I/O Scheduler**: BFQ for responsiveness, none for NVMe
- ✅ **Network**: BBR congestion control + CAKE qdisc
- ✅ **Memory**: Optimized vm.swappiness and cache pressure

### Gaming
- ✅ **Proton-GE**: Latest compatibility layers
- ✅ **GameMode**: Automatic CPU optimization
- ✅ **MangoHud**: Real-time performance overlay
- ✅ **NVIDIA**: Hardware-accelerated everything

### Creative
- ✅ **Blender OptiX**: AI-accelerated ray tracing
- ✅ **NVENC**: Zero-performance-loss encoding
- ✅ **Complete Suite**: Professional alternatives to Adobe
- ✅ **12GB VRAM**: No limitations on complex projects

### Development
- ✅ **Full .NET Stack**: SDK 8.0 + 9.0 + ASP.NET
- ✅ **Containers**: Docker + Docker Compose
- ✅ **Multiple Languages**: C#, C++, Rust, Go, Node.js
- ✅ **Professional IDEs**: Rider, VS Code

### AI/ML
- ✅ **CUDA 12**: Latest toolkit + cuDNN
- ✅ **PyTorch**: Full CUDA support
- ✅ **Ollama**: Local LLM inference
- ✅ **12GB VRAM**: Run 7B-8B models comfortably

---

## 📞 Support

- **Repository**: [github.com/hoangducdt/caelestia](https://github.com/hoangducdt/caelestia)
- **Issues**: [GitHub Issues](https://github.com/hoangducdt/caelestia/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hoangducdt/caelestia/discussions)

---

## 📝 License

MIT License

---

## 🙏 Credits

- **CachyOS Team**: For the optimized Arch-based distribution
- **Hyprland**: For the excellent Wayland compositor
- **Community**: For testing and feedback

---

**Made with ❤️ for ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB**

**Ready to game, develop, create, and render! 🚀🎮💻🎨**