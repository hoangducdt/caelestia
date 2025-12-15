# CachyOS/Hyprland/Caelestia Auto Setup - Toàn Diện Cho Game, Phát Triển & AI/ML

**Thiết lập một lệnh** hoàn chỉnh cho hệ thống chơi game, phát triển phần mềm và làm việc với AI/ML trên CachyOS.

## 🖥️ Cấu Hình Phần Cứng Mục Tiêu

- **Bo mạch chủ**: ASUS ROG STRIX B550-XE GAMING WIFI
- **CPU**: AMD Ryzen 7 5800X (8 Nhân / 16 Luồng)
- **GPU**: NVIDIA GeForce RTX 3060 12GB
- **RAM**: 32GB DDR4
- **Hệ điều hành**: CachyOS (nền tảng Arch)

---

## 🚀 Cài Đặt Nhanh

### Cài đặt bằng một dòng lệnh (Khuyến nghị)
```bash
curl -fsSL https://raw.githubusercontent.com/hoangducdt/caelestia/main/install.sh | bash
```

### Cài đặt thủ công
```bash
git clone https://github.com/hoangducdt/caelestia.git
cd caelestia
chmod +x setup.sh
./setup.sh
```

⏱️ **Thời gian cài đặt**: 25-45 phút tùy tốc độ mạng

---

## ✨ Tổng Quan Tính Năng

### 🎮 Chơi Game
- **Môi trường Desktop**: Hyprland Caelestia (Trình tổng hợp Wayland)
- **Driver**: NVIDIA độc quyền với hỗ trợ CUDA
- **Công cụ Game**: Steam, Lutris, Wine, Proton-GE, GameMode, MangoHud
- **Hiệu năng**: Gói `cachyos-gaming-meta`
- **Tối ưu hóa**: CPU governor, I/O scheduler, điều chỉnh mạng

### 💻 Môi Trường Phát Triển
- **.NET**: SDK, Runtime, ASP.NET Core
- **C++/C#**: Mono, MSBuild, JetBrains Rider
- **Trình soạn thảo**: VS Code, Neovim
- **Công cụ**: Docker, Docker Compose, Git, GitHub CLI

### 🎬 Hỗ Trợ Unreal Engine 5
- **Phụ thuộc**: Vulkan, libicu, clang, cmake, ninja
- **Thư viện Runtime**: OpenAL, SDL2, FFmpeg, GStreamer + hơn 40 gói
- **Tính năng**: Sẵn sàng cho Nanite, Lumen, Ray Tracing
- **Tích hợp**: Thiết lập VS Code, các script hỗ trợ

### 🤖 Ngăn xếp AI/ML (cho RTX 3060 12GB)
- **CUDA**: Bộ công cụ đầy đủ + cuDNN
- **Framework**: PyTorch (CUDA), TensorFlow (GPU)
- **LLM**: Ollama (Llama, Mistral, CodeLlama)
- **Tạo ảnh**: Stable Diffusion WebUI (AUTOMATIC1111)
- **Tạo văn bản**: Text Generation WebUI (Oobabooga)
- **Quy trình làm việc**: Giao diện dạng nút ComfyUI
- **Công cụ**: Jan, Koboldcpp, Jupyter Notebook

### 🎥 Phát Trực Tuyến & Ghi Hình
- **OBS Studio**: Mã hóa phần cứng NVIDIA NVENC
- **Camera ảo**: Bật `v4l2loopback`
- **Plugin**: obs-vkcapture, obs-websocket, nguồn trình duyệt
- **Âm thanh**: Backend độ trễ thấp PipeWire
- **Bộ giải mã**: x264, x265, FFmpeg với VA-API

### 💬 Giao Tiếp
- **Vesktop/Vencord**: Ứng dụng Discord được nâng cao
- **Tính năng**: Hỗ trợ Wayland, hiệu năng tốt hơn, chủ đề tùy chỉnh
- **Chia sẻ màn hình**: Hoạt động hoàn hảo trên Wayland

### 🖥️ Hỗ Trợ Phần Cứng (ROG STRIX B550-XE)
- **Chipset**: AMD B550 với hỗ trợ driver đầy đủ
- **Âm thanh**: Realtek ALC4080 SupremeFX
- **Mạng**: Dual Ethernet 2.5G (Intel I225-V + Realtek RTL8125B)
- **WiFi**: Intel AX210 WiFi 6E (2.4/5/6GHz)
- **Bluetooth**: 5.2 với blueman
- **RGB**: OpenRGB với hỗ trợ ASUS Aura Sync

### ⌨️ Nhập Liệu & Hiển Thị
- **Tiếng Việt**: Fcitx5 + Bộ gõ Bamboo
- **Đa màn hình**: Tự động phát hiện với công cụ GUI
- **Màn hình đăng nhập**: SDDM với chủ đề Sugar Candy

---

## 📦 Danh Sách Gói Đầy Đủ

### Hệ Thống Cơ Bản
```
yay, gnome-keyring, polkit-gnome, nautilus
microsoft-edge, github-desktop
```

### Môi Trường Desktop
```
Hyprland Caelestia (bộ đầy đủ)
SDDM + chủ đề Sugar Candy
```

### Game & Phát Triển
```
# NVIDIA
nvidia-dkms, nvidia-utils, lib32-nvidia-utils
opencl-nvidia, libva-nvidia-driver

# Game
cachyos-gaming-meta, cachyos-gaming-applications
steam, lutris, wine, gamemode, mangohud

# Phát triển
dotnet-sdk, mono, rider, code, docker
```

### Unreal Engine 5
```
# Lõi
vulkan-devel, clang, cmake, libicu

# Runtime (tổng 53 gói)
openal, sdl2, ffmpeg, gstreamer
libxcursor, libxi, libxrandr
freetype2, fontconfig, harfbuzz
curl, openssl, zlib, bzip2, xz, zstd
+ tất cả các biến thể lib32-*
```

### AI/ML
```
# CUDA
cuda, cudnn, python-pytorch-cuda

# Python
python, pip, virtualenv, numpy, pandas
jupyter-notebook, scikit-learn

# Công cụ AI
ollama-cuda, jan-bin, koboldcpp-cuda
```

### Công Cụ Streaming
```
# OBS
obs-studio, obs-vkcapture, obs-websocket
v4l2loopback-dkms, pipewire

# Discord
vesktop-bin (Vencord)

# Bộ giải mã
ffmpeg, x264, x265, gstreamer-vaapi
```

### Hỗ Trợ Phần Cứng
```
# Firmware
amd-ucode, linux-firmware, sof-firmware

# Mạng
r8168-dkms, ethtool, iw, bluez

# RGB
openrgb-bin, i2c-tools

# Âm thanh
pipewire, pavucontrol, alsa-utils
```

### Tiện Ích
```
htop, btop, nvtop, neofetch
tmux, starship, eza, bat, ripgrep
unzip, p7zip, rsync, fzf, zoxide
```

---

## 🎯 Hiệu Năng & Tối Ưu Hóa

### CPU (Ryzen 7 5800X)
```bash
# Governor: Hiệu suất (Performance)
tần_số_tối_thiểu: 800MHz
tần_số_tối_đa: 4.7GHz (boost)

# Scheduler tối ưu cho 8C/16T
kernel.sched_autogroup_enabled=1
kernel.sched_migration_cost_ns=5000000

# Hiệu năng dự kiến
Single-core: 4.7 GHz
All-core: 4.4-4.5 GHz duy trì
Nhiệt độ: 70-80°C khi chơi game, 40-50°C khi nhàn rỗi
Công suất: 105W TDP, 142W PPT
```

### GPU (RTX 3060 12GB)
```bash
# Bật mã hóa phần cứng NVENC
# Quản lý năng lượng được tối ưu

# Hiệu năng dự kiến
Boost: 1777 MHz
Bộ nhớ: 12GB GDDR6 @ 15 Gbps
Nhiệt độ: 60-75°C khi chơi game, 30-40°C khi nhàn rỗi
Công suất: 170W TDP

# Khả năng tính toán CUDA: 8.6
# Tensor Cores: Có (tăng tốc AI)
```

### Mạng
```bash
# Ethernet 2.5G
- Offloading TCP/UDP: BẬT
- Điều khiển tắc nghẽn BBR
- qdisc CAKE (độ trễ thấp)
- Thực tế: ~2.3 Gbps
- Độ trễ: <1ms có dây

# WiFi 6E (Intel AX210)
- Ba băng tần: 2.4/5/6GHz
- Tốc độ: Lên đến 2400 Mbps
- Thực tế: ~1.5-2 Gbps
- Độ trễ: ~5ms
```

### Lưu Trữ
```bash
# Bộ lập lịch I/O
NVMe: none (tốt nhất cho PCIe 4.0)
SSD: bfq (cân bằng)
HDD: mq-deadline (truyền tải)

# Hiệu năng dự kiến
NVMe PCIe 4.0: Trên 5000 MB/s đọc/ghi
SATA SSD: 550 MB/s đọc/ghi
```

### Bộ Nhớ
```bash
# Tối ưu cho game
vm.swappiness=10
vm.vfs_cache_pressure=50

# Hỗ trợ AI/ML (mô hình lớn)
kernel.shmmax=68719476736  # Bộ nhớ chia sẻ 64GB
```

---

## 🎮 Hiệu Năng Chơi Game

### Game Linux Bản Địa
```
Độ phân giải: 1920x1080
Chất lượng: Ultra/High
FPS: 60-144 FPS (esports)
      40-90 FPS (AAA)
```

### Game Proton/Wine
```
Khả năng tương thích: 80%+ game hoạt động
Hiệu năng: 90-95% so với Windows
Công cụ: Proton-GE, Wine-GE, DXVK, VKD3D
```

### Game UE5
```
Tính năng: Nanite, Lumen, Ray Tracing
Độ phân giải: 1080p
FPS: 30-60 (medium-high)
     20-45 (ultra + ray tracing)

Khuyến nghị:
- Chế độ Lumen Software
- Tỷ lệ co giãn Medium-High
- Virtual Shadow Maps
```

---

## 🤖 Khả Năng AI/ML (RTX 3060 12GB)

### LLM (Tạo Văn Bản)
```
✅ Llama 3.2 3B      - 3GB VRAM - Nhanh
✅ Mistral 7B        - 4-5GB VRAM - Cân bằng
✅ Llama 3.1 8B      - 5-6GB VRAM - Chất lượng cao
✅ CodeLlama 7B      - 4-5GB VRAM - Lập trình
⚠️ Mixtral 8x7B     - 6-8GB VRAM - lượng tử hóa 4-bit
⚠️ Llama 13B        - 8-10GB VRAM - lượng tử hóa 4-bit
```

### Tạo Ảnh
```
✅ Stable Diffusion 1.5   - 512x512 - Nhanh
✅ SDXL                   - 1024x1024 - Dùng --medvram
✅ ControlNet             - Hoạt động tốt
✅ Quy trình ComfyUI     - Pipeline phức tạp OK
⚠️ Nhiều mô hình cùng lúc - Cần quản lý VRAM
```

### Tinh Chỉnh Mô Hình (Fine-tuning)
```
✅ Huấn luyện LoRA        - Stable Diffusion
✅ Mô hình 7B (4-bit)     - Llama, Mistral
⚠️ Mô hình 13B+          - Yêu cầu lượng tử hóa 4-bit
```

---

## 🎥 Thiết Lập Streaming

### Cài Đặt OBS NVENC

**Twitch 1080p60:**
```
Encoder: NVIDIA NVENC H.264
Rate Control: CBR
Bitrate: 6000 Kbps
Keyframe: 2s
Preset: Quality
Profile: high
Look-ahead: BẬT
```

**YouTube 1080p60:**
```
Encoder: NVIDIA NVENC H.264
Rate Control: CBR
Bitrate: 9000 Kbps
Preset: Max Quality
```

**Ghi Hình Cục Bộ (Chất lượng tốt nhất):**
```
Encoder: NVIDIA NVENC H.264
Rate Control: CQP
CQ Level: 18
Preset: Max Quality
Look-ahead: BẬT
Psycho Visual: BẬT
```

### Ảnh Hưởng Đến Hiệu Năng
```
CPU: ~5-10% (Giao diện OBS)
GPU: ~2-5% (Mã hóa NVENC)
RAM: ~500MB
Mất FPS: <5% (mã hóa phần cứng!)
```

---

## 🌈 Điều Khiển RGB

### OpenRGB (ASUS Aura Sync)
```bash
# Khởi chạy điều khiển RGB
rgb-control

# Điều khiển qua CLI
openrgb --list-devices
openrgb --device 0 --mode static --color FF0000
openrgb --device 0 --mode breathing --color 00FF00
openrgb --profile ~/.config/openrgb/gaming.orp

# Hiệu ứng được hỗ trợ
Static, Breathing, Strobing, Cycling, Rainbow, Tùy chỉnh
```

### Tự động khởi động với Profile
```bash
# Thêm vào cấu hình Hyprland
echo 'exec-once = openrgb --profile ~/.config/openrgb/profile.orp' >> ~/.config/hypr/hyprland.conf
```

---

## 💡 Điểm Mạnh Của Thiết Lập Này

### 1. Mã Hóa Phần Cứng (NVENC)
- ✅ Stream/ghi hình mà **không mất FPS**
- ✅ Chất lượng tương đương x264 medium
- ✅ Độ trễ thấp cho streaming
- ✅ CPU rảnh cho gaming

### 2. Dual Ethernet 2.5G
- ✅ **Độ trễ thấp** (<1ms) cho game cạnh tranh
- ✅ **Tải lên ổn định** cho streaming
- ✅ **Dự phòng** nếu một cổng lỗi
- ✅ **Đáp ứng tương lai** về băng thông

### 3. WiFi 6E (Intel AX210)
- ✅ **Băng tần 6GHz** - ít nhiễu
- ✅ **Nhanh** - 2400 Mbps tối đa
- ✅ **Ổn định** - Hỗ trợ driver Intel
- ✅ **Bluetooth 5.2** được bao gồm

### 4. Điểm Ngọt VRAM 12GB
- ✅ **Phát triển UE5** - Nanite + Lumen
- ✅ **AI/ML** - LLM 8B, SDXL
- ✅ **Gaming** - Texture Ultra @ 1080p/1440p
- ✅ **Đa nhiệm** - Game + Stream + AI

### 5. Ryzen 5800X (8C/16T)
- ✅ **Single-thread** - 4.7GHz cho gaming
- ✅ **Multi-thread** - Huấn luyện AI, biên dịch
- ✅ **Hiệu quả** - Kiến trúc Zen 3
- ✅ **Giá trị** - Hiệu năng tốt nhất trên mỗi đô la

### 6. Hệ Sinh Thái Mã Nguồn Mở
- ✅ **OpenRGB** - Điều khiển RGB đầy đủ
- ✅ **Pipewire** - Âm thanh hiện đại
- ✅ **Wayland** - Trình tổng hợp mượt mà
- ✅ **CachyOS** - Kernel được tối ưu

---

## 📝 Lệnh Nhanh

### Hệ Thống
```bash
# Giám sát GPU
nvidia-smi
nvtop
monitor-vram

# Thông tin CPU
cpupower frequency-info
sensors | grep Tdie

# Tốc độ mạng
ethtool eth0 | grep Speed

# Chế độ game
game-mode-on    # Hiệu năng tối đa
game-mode-off   # Tiết kiệm năng lượng
```

### Streaming
```bash
# Khởi chạy ứng dụng
obs             # OBS Studio
vesktop         # Vencord/Discord
rgb-control     # Đèn RGB

# Kiểm tra camera ảo
ls /dev/video*
```

### AI/ML
```bash
# Tổng quan không gian làm việc
ai-workspace

# Kiểm tra CUDA
check-ai-setup

# Tải LLM
ollama-download-recommended

# Chạy Ollama
ollama-start

# Stable Diffusion
sd-webui

# Giám sát VRAM
monitor-vram
```

### Unreal Engine
```bash
# Khởi chạy UE5
ue5

# Kiểm tra GPU
check-gpu
```

---

## 🔧 Các Bước Sau Khi Cài Đặt

### 1. Khởi Động Lại
```bash
sudo reboot
```

### 2. Đăng Nhập Vào Hyprland (SDDM)
Chọn phiên "Hyprland"

### 3. Cài Đặt Unreal Engine 5 (Tùy chọn)
```bash
# 1. Tạo tài khoản Epic Games: https://www.epicgames.com
# 2. Liên kết GitHub: https://www.epicgames.com/account/connections
# 3. Tải UE5: https://www.unrealengine.com/linux
# 4. Giải nén vào ~/UnrealEngine/
unzip Linux_Unreal_Engine_*.zip -d ~/UnrealEngine/
# 5. Khởi chạy
ue5
```

### 4. Tải Mô Hình AI/ML (Tùy chọn)
```bash
# Tải các LLM được đề xuất (mỗi cái 3-7GB)
ollama-download-recommended

# Hoặc thủ công
ollama pull llama3.2:3b
ollama pull mistral:7b
ollama pull codellama:7b
```

### 5. Cấu Hình Đa Màn Hình (Nếu cần)
```bash
# Tự động phát hiện
~/.config/hypr/scripts/detect-monitors.sh

# Công cụ GUI
nwg-displays
```

### 6. Thiết Lập Nhập Liệu Tiếng Việt
```bash
# Cấu hình Fcitx5
fcitx5-configtool

# Chuyển đổi: Ctrl + Space
```

### 7. Cấu Hình OBS
```bash
# Lần chạy đầu tiên
obs

# Settings → Output → Bật NVENC
# Settings → Video → 1920x1080 @ 60fps
# Settings → Advanced → Process Priority: High
```

---

## ⚠️ Khắc Phục Sự Cố

### Vấn Đề Với NVIDIA
```bash
# Kiểm tra driver
nvidia-smi

# Cài đặt lại
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils
sudo reboot
```

### OBS NVENC không hoạt động
```bash
# Cài đặt CUDA
sudo pacman -S cuda

# Khởi động lại OBS
```

### Camera ảo không phát hiện
```bash
# Nạp module
sudo modprobe v4l2loopback

# Kiểm tra
ls /dev/video*
```

### OpenRGB không thể phát hiện thiết bị
```bash
# Chạy một lần với quyền root
sudo openrgb --list-devices

# Khởi động lại
sudo reboot
```

### Mạng chậm (Ethernet 2.5G không hoạt động)
```bash
# Kiểm tra cáp (cần Cat5e trở lên)
ethtool eth0 | grep Speed

# Ép 2.5G
sudo ethtool -s eth0 speed 2500 duplex full autoneg on
```

### Âm thanh bị nhiễu
```bash
# Khởi động lại PipeWire
systemctl --user restart pipewire
```

### Nhiệt độ CPU cao (>85°C)
```bash
# Kiểm tra lắp đặt tản nhiệt
# Kiểm tra keo tản nhiệt
# BIOS: Bật PBO, Curve Optimizer -15 đến -30
```

### Ollama không khởi động
```bash
# Kiểm tra dịch vụ
sudo systemctl status ollama

# Khởi động lại
sudo systemctl restart ollama

# Nhật ký
journalctl -u ollama -f
```

---

## 📊 Yêu Cầu Dung Lượng Ổ Đĩa

### Cài Đặt Mới
```
Hệ thống cơ bản: ~15GB
Công cụ game: ~5GB
Phát triển: ~8GB
Công cụ AI/ML: ~10GB
Unreal Engine: ~25GB (nếu cài đặt)
Tổng: ~38GB (63GB với UE5)
```

### Sau Khi Tải Mô Hình/Tài Nguyên
```
Mô hình AI: ~20-50GB (tùy mô hình)
Game: Khác nhau
Tổng: Nên có ~100-200GB
```

---

## 🎯 Các Trường Hợp Sử Dụng

### 1. Chơi Game Cạnh Tranh
```
✅ Mạng độ trễ thấp (<1ms)
✅ Hỗ trợ tần số làm tươi cao
✅ Tối ưu tự động với GameMode
✅ Overlay FPS MangoHud
✅ Không trễ đầu vào (Trình tổng hợp Wayland)
```

### 2. Stream Game
```
✅ Mã hóa phần cứng NVENC
✅ 1080p60 @ 6000-9000 Kbps
✅ Camera ảo cho facecam
✅ Chuyển cảnh bằng phím nóng
✅ Ảnh hưởng hiệu năng tối thiểu
```

### 3. Phát Triển Game (UE5)
```
✅ Hỗ trợ đầy đủ trình chỉnh sửa UE5
✅ Bật Nanite + Lumen
✅ Biên dịch dự án C++
✅ Tích hợp VS Code
✅ Quy trình làm việc Blueprint + C++
```

### 4. Phát Triển AI/ML
```
✅ Suy luận LLM cục bộ (mô hình 8B)
✅ Tạo ảnh Stable Diffusion
✅ Tinh chỉnh với LoRA
✅ Jupyter notebooks
✅ PyTorch/TensorFlow trên GPU
```

### 5. Sáng Tạo Nội Dung
```
✅ Ghi hình OBS (NVENC CQP 18)
✅ Chỉnh sửa video (tăng tốc GPU)
✅ Tạo nghệ thuật AI
✅ Streaming + Discord
✅ Quy trình làm việc đa màn hình
```

### 6. Phát Triển Phần Mềm
```
✅ Phát triển .NET Core
✅ Docker containers
✅ Quy trình làm việc Git/GitHub
✅ VS Code + Rider
✅ Nhiều dự án cùng lúc
```

---

## 🌟 Tại Sao Chọn Thiết Lập Này?

### ROG STRIX B550-XE
- ✅ VRM xuất sắc (12+2 pha)
- ✅ Hỗ trợ PCIe 4.0
- ✅ Dual Ethernet 2.5G
- ✅ WiFi 6E + Bluetooth 5.2
- ✅ Âm thanh cao cấp (ALC4080)
- ✅ RGB mọi thứ
- ✅ Tuyệt vời cho dòng Ryzen 5000

### Ryzen 7 5800X
- ✅ 8C/16T - Sự cân bằng hoàn hảo
- ✅ 4.7GHz boost - Hiệu năng gaming
- ✅ Zen 3 - Kiến trúc hiệu quả
- ✅ Hỗ trợ PCIe 4.0
- ✅ Giá trị tuyệt vời

### RTX 3060 12GB
- ✅ **12GB VRAM** - Làm được AI/ML + UE5
- ✅ Bộ mã hóa NVENC - Streaming phần cứng
- ✅ Tensor Cores - Tăng tốc AI
- ✅ Ray Tracing - Gaming hiện đại
- ✅ CUDA 8.6 - Sẵn sàng cho phát triển
- ✅ Giá cả phải chăng - VRAM tốt nhất trên mỗi đô la

### CachyOS
- ✅ Nền tảng Arch - Phát hành liên tục
- ✅ Kernel được tối ưu - Gaming tốt hơn
- ✅ Gói game - Được cấu hình sẵn
- ✅ Dễ thiết lập - Thân thiện với người dùng
- ✅ Cộng đồng tích cực

---

## 📞 Hỗ Trợ

- **Vấn đề**: [GitHub Issues](https://github.com/hoangducdt/caelestia/issues)
- **Thảo luận**: [GitHub Discussions](https://github.com/hoangducdt/caelestia/discussions)

---

## 📝 Giấy Phép

Giấy phép MIT

---

**Made with ❤️ for ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB**

**Ready to game, stream, develop, and creater! 🚀🎮🤖🎨**