# CachyOS/Hyprland/Caelestia Auto Setup - Complete Creative Workstation

**Thiết lập một lệnh** hoàn chỉnh cho hệ thống chơi game, phát triển phần mềm, làm việc với AI/ML, **và sáng tạo nội dung 3D/2D** trên CachyOS.

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

⏱️ **Thời gian cài đặt**: 30-60 phút tùy tốc độ mạng

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

### 🤖 AI/ML (cho RTX 3060 12GB)
- **CUDA**: Bộ công cụ đầy đủ + cuDNN
- **Framework**: PyTorch (CUDA), TensorFlow (GPU)
- **LLM**: Ollama (Llama, Mistral, CodeLlama)
- **Tạo ảnh**: Stable Diffusion WebUI (AUTOMATIC1111)
- **Tạo văn bản**: Text Generation WebUI (Oobabooga)
- **Quy trình làm việc**: Giao diện dạng nút ComfyUI
- **Công cụ**: Jan, Koboldcpp, Jupyter Notebook

### 🎨 **Creative Suite**
#### Blender (3D Creation)
- **Tối ưu GPU**: CUDA/OptiX cho RTX 3060
- **Render Engine**: Cycles với OptiX ray tracing
- **Denoising**: OptiX AI denoiser
- **Hiệu năng**: Viewport rendering tối ưu cho 12GB VRAM
- **Scripts**: `blender-gpu`, `blender-render`, `blender-setup-gpu`

#### Adobe Creative Cloud Alternatives
- **GIMP** (Thay thế Photoshop): Chỉnh sửa ảnh chuyên nghiệp
- **Krita** (Digital Painting): Vẽ kỹ thuật số và concept art
- **Inkscape** (Thay thế Illustrator): Thiết kế vector
- **Kdenlive** (Thay thế Premiere Pro): Chỉnh sửa video
- **DaVinci Resolve** (Tùy chọn): Chỉnh sửa video chuyên nghiệp
- **Darktable** (Thay thế Lightroom): Xử lý RAW photos
- **RawTherapee**: Chỉnh sửa RAW nâng cao
- **Scribus** (Thay thế InDesign): Desktop publishing
- **Audacity**: Chỉnh sửa audio
- **Ardour**: Digital Audio Workstation (DAW)
- **Natron** (Thay thế After Effects): Compositing và VFX

### 🎥 Phát Trực Tuyến & Ghi Hình
- **OBS Studio**: Mã hóa phần cứng NVIDIA NVENC
- **Camera ảo**: Bật `v4l2loopback`
- **Plugin**: obs-vkcapture, obs-websocket, nguồn trình duyệt
- **Âm thanh**: Backend độ trễ thấp PipeWire
- **Bộ giải mã**: x264, x265, FFmpeg với VA-API
- **Transcoding**: GPU-accelerated với NVENC

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

### **Blender & Creative Suite**
```
# 3D & Animation
blender, openimagedenoise, opencolorio
opensubdiv, openvdb, embree, openimageio

# Image Editing
gimp, gimp-plugin-gmic, krita, darktable, rawtherapee

# Vector & Design
inkscape, scribus

# Video Editing
kdenlive, frei0r-plugins, davinci-resolve

# Audio
audacity, ardour

# Compositing
natron

# Supporting Tools
imagemagick, graphicsmagick, potrace, fontforge
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

---

## 🎯 Hiệu Năng & Tối Ưu Hóa

### CPU (Ryzen 7 5800X)
```bash
# Governor: Hiệu suất (Performance)
tần_số_tối_thiểu: 800MHz
tần_số_tối_đa: 4.7GHz (boost)

# Hiệu năng dự kiến
Single-core: 4.7 GHz
All-core: 4.4-4.5 GHz duy trì
Nhiệt độ: 70-80°C khi chơi game, 40-50°C khi nhàn rỗi
Công suất: 105W TDP, 142W PPT
```

### GPU (RTX 3060 12GB)
```bash
# Bật CUDA/OptiX cho Blender
# NVENC mã hóa phần cứng cho video
# Quản lý năng lượng được tối ưu

# Hiệu năng dự kiến
Boost: 1777 MHz
Bộ nhớ: 12GB GDDR6 @ 15 Gbps
Nhiệt độ: 60-75°C khi render/game, 30-40°C khi nhàn rỗi
Công suất: 170W TDP

# Khả năng tính toán CUDA: 8.6
# Tensor Cores: Có (tăng tốc AI + OptiX denoising)
# RT Cores: Gen 2 (Ray tracing)
```

### **Blender Rendering Performance (RTX 3060 12GB)**
```bash
# Cycles OptiX Rendering
Simple scene (1M polygons): ~2-5 minutes
Complex scene (10M+ polygons): ~10-30 minutes
Animation (250 frames): ~2-8 hours (depending on complexity)

# Recommended settings:
Render engine: Cycles + OptiX
Tile size: 256x256 or 512x512
Samples: 512-2048 (with OptiX denoiser)
Denoiser: OptiX (GPU accelerated)
Viewport samples: 128-256
```

---

## 🎨 Blender & Creative Workflows

### Blender Setup
```bash
# Khởi chạy Blender với GPU
blender-gpu

# Thiết lập GPU rendering
blender-setup-gpu

# Render project từ command line
blender-render project.blend ./output 1 250
```

### Blender Performance Tips
1. **Enable OptiX**: Edit → Preferences → System → Cycles Render Devices → OptiX
2. **Use GPU Memory Efficiently**:
   - Tiết kiệm VRAM: 8-10GB cho viewport + rendering
   - Dành 2-4GB cho hệ thống và ứng dụng khác
3. **Optimize Viewport**:
   - Samples: 128-256
   - Simplify settings cho preview
4. **Final Rendering**:
   - Samples: 512-2048
   - Enable OptiX denoiser
   - Adaptive sampling ON

### Creative Suite Commands
```bash
# Xem tất cả ứng dụng creative
creative-apps

# Image editing
gimp                          # Photoshop alternative
krita                         # Digital painting
darktable                     # Lightroom alternative

# Vector design
inkscape                      # Illustrator alternative

# Video editing
kdenlive                      # Premiere alternative
davinci-resolve              # Professional NLE (if installed)

# Audio
audacity                      # Audio editor
ardour                        # Professional DAW

# 3D
blender-gpu                   # Optimized Blender

# Batch operations
batch-convert-images jpg png 95
video-transcode input.mov output.mp4 fast
gimp-batch-resize 1920 1080 *.jpg
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

---

## 🤖 Khả Năng AI/ML (RTX 3060 12GB)

### LLM (Tạo Văn Bản)
```
✅ Llama 3.2 3B      - 3GB VRAM - Nhanh
✅ Mistral 7B        - 4-5GB VRAM - Cân bằng
✅ Llama 3.1 8B      - 5-6GB VRAM - Chất lượng cao
✅ CodeLlama 7B      - 4-5GB VRAM - Lập trình
⚠️ Mixtral 8x7B     - 6-8GB VRAM - lượng tử hóa 4-bit
```

### Tạo Ảnh
```
✅ Stable Diffusion 1.5   - 512x512 - Nhanh
✅ SDXL                   - 1024x1024 - Dùng --medvram
✅ ControlNet             - Hoạt động tốt
✅ Quy trình ComfyUI     - Pipeline phức tạp OK
```

---

## 🎥 Thiết Lập Streaming & Video Production

### OBS NVENC Settings
**Twitch 1080p60:**
```
Encoder: NVIDIA NVENC H.264
Rate Control: CBR
Bitrate: 6000 Kbps
Preset: Quality
```

### Video Transcoding với GPU
```bash
# Transcode với NVENC
video-transcode input.mov output.mp4 fast

# FFmpeg NVENC command
ffmpeg -hwaccel cuda -i input.mp4 \
    -c:v h264_nvenc -preset fast -b:v 10M \
    -c:a aac -b:a 192k output.mp4
```

---

## 🌈 Điều Khiển RGB

### OpenRGB (ASUS Aura Sync)
```bash
# Khởi chạy điều khiển RGB
rgb-control

# Hiệu ứng được hỗ trợ
Static, Breathing, Strobing, Cycling, Rainbow
```

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

# Chế độ game
game-mode-on
game-mode-off
```

### Creative Suite
```bash
# Xem ứng dụng
creative-apps

# Blender
blender-gpu
blender-setup-gpu
blender-render project.blend ./output

# Image tools
batch-convert-images jpg png
gimp-batch-resize 1920 1080 *.jpg

# Video tools
video-transcode input.mov output.mp4
```

### AI/ML
```bash
# Workspace overview
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

---

## 🔧 Các Bước Sau Khi Cài Đặt

### 1. Khởi Động Lại
```bash
sudo reboot
```

### 2. Thiết Lập Blender GPU
```bash
blender-setup-gpu
# Làm theo hướng dẫn để enable OptiX trong Blender
```

### 3. Tải Mô Hình AI/ML (Tùy chọn)
```bash
ollama-download-recommended
```

### 4. Cấu Hình OBS
```bash
obs
# Settings → Output → Enable NVENC
# Settings → Video → 1920x1080 @ 60fps
```

---

## 💡 Điểm Mạnh Của Thiết Lập Này

### 1. **Blender OptiX Rendering**
- ✅ **3-5x nhanh hơn** CPU rendering
- ✅ **OptiX AI denoiser** - chất lượng cao với ít samples
- ✅ **12GB VRAM** - đủ cho cảnh phức tạp
- ✅ **Real-time viewport** rendering

### 2. **Complete Creative Suite**
- ✅ **GIMP** - Thay thế Photoshop miễn phí
- ✅ **Inkscape** - Vector design chuyên nghiệp
- ✅ **Kdenlive/DaVinci** - Video editing mạnh mẽ
- ✅ **Tích hợp GPU** - Tăng tốc mọi workflow

### 3. Mã Hóa Phần Cứng (NVENC)
- ✅ Stream/ghi hình **không mất FPS**
- ✅ Transcode video nhanh chóng
- ✅ Độ trễ thấp cho streaming

### 4. VRAM 12GB
- ✅ **Blender rendering** - Cảnh phức tạp
- ✅ **Phát triển UE5** - Nanite + Lumen
- ✅ **AI/ML** - LLM 8B, SDXL
- ✅ **Gaming** - Texture Ultra
- ✅ **Đa nhiệm** - Render + AI + Game

### 5. Ryzen 5800X (8C/16T)
- ✅ **Multi-thread** - Render, compile, AI training
- ✅ **Single-thread** - Gaming, viewport
- ✅ **Hiệu quả** - Zen 3 architecture

---

## 🎯 Các Trường Hợp Sử Dụng

### 1. 3D Artist / Animator
```
✅ Blender với OptiX rendering
✅ Real-time viewport performance
✅ GPU-accelerated compositing
✅ Fast iteration cycles
✅ Export cho UE5/Unity
```

### 2. Graphic Designer
```
✅ GIMP cho photo editing
✅ Inkscape cho vector work
✅ Krita cho digital painting
✅ Color management với Darktable
✅ Print-ready với Scribus
```

### 3. Video Editor / Content Creator
```
✅ Kdenlive/DaVinci cho editing
✅ NVENC hardware encoding
✅ GPU effects rendering
✅ AI upscaling và denoising
✅ OBS cho streaming
```

### 4. Game Developer
```
✅ UE5 development
✅ Blender cho asset creation
✅ GIMP cho textures
✅ Full C# stack
✅ Docker cho builds
```

### 5. AI/ML Developer
```
✅ Local LLM inference
✅ Stable Diffusion generation
✅ Model fine-tuning
✅ Jupyter notebooks
✅ PyTorch/TensorFlow GPU
```

---

## ⚠️ Khắc Phục Sự Cố

### Blender không nhận GPU
```bash
# Kiểm tra CUDA
nvidia-smi
check-ai-setup

# Chạy Blender GPU setup
blender-setup-gpu

# Khởi động lại Blender
```

### NVENC không hoạt động trong OBS/FFmpeg
```bash
# Cài đặt CUDA
sudo pacman -S cuda

# Test NVENC
ffmpeg -hwaccels
```

### Blender crash khi render
```bash
# Giảm tile size
# Enable progressive refine
# Giảm samples
# Check VRAM usage: monitor-vram
```

---

## 📊 Yêu Cầu Dung Lượng Ổ Đĩa

### Cài Đặt Mới
```
Hệ thống cơ bản: ~15GB
Công cụ game: ~5GB
Phát triển: ~8GB
Công cụ AI/ML: ~10GB
Creative Suite: ~5GB
Unreal Engine: ~25GB (nếu cài đặt)
Tổng: ~43GB (68GB với UE5)
```

### Sau Khi Sử Dụng
```
Blender projects: 5-50GB
AI models: 20-50GB
Game installations: varies
Video projects: 50-200GB
Khuyến nghị: 200-500GB free
```

---

## 🌟 Tại Sao Chọn Thiết Lập Này?

### RTX 3060 12GB
- ✅ **12GB VRAM** - Perfect cho Blender + AI/ML
- ✅ **OptiX** - AI-accelerated ray tracing
- ✅ **NVENC** - Hardware video encoding
- ✅ **Tensor Cores** - AI denoising
- ✅ **CUDA 8.6** - Tương thích mọi creative app

---

## 📞 Hỗ Trợ

- **Issues**: [GitHub Issues](https://github.com/hoangducdt/caelestia/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hoangducdt/caelestia/discussions)

---

## 📝 Giấy Phép

MIT License

---

**Made with ❤️ for ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB**

**Ready to game, stream, develop, create, and render! 🚀🎮🤖🎨🎬**