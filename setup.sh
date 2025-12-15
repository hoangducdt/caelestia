#!/bin/bash

# CachyOS Auto Setup Script - AI/ML Enhanced Version
# Hệ thống: ASUS ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12G | 32GB RAM
# Mục đích: Gaming & C# Development + AI/ML với RTX 3060 12GB

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/setup_log_$(date +%Y%m%d_%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

ai_info() {
    echo -e "${MAGENTA}[AI/ML]${NC} $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        error "Không chạy script này với quyền root. Sử dụng sudo khi cần."
    fi
}

# 1. Cài đặt các thành phần cơ bản
install_base_packages() {
    log "Bước 1: Cài đặt các gói cơ bản..."
    
    sudo pacman -Syu --noconfirm
    
    sudo pacman -S --needed --noconfirm \
        yay \
        gnome-keyring \
        polkit-gnome \
        nautilus \
        gnome-disk-utility \
        base-devel \
        git \
        wget \
        curl \
        fish \
        wl-clipboard \
        xdg-desktop-portal-hyprland \
        qt5-wayland \
        qt6-wayland
    
    log "✓ Đã cài đặt các gói cơ bản"
}

install_aur_packages() {
    log "Cài đặt Microsoft Edge và GitHub Desktop từ AUR..."
    
    yay -S --noconfirm --needed \
        microsoft-edge-stable-bin \
        github-desktop
    
    log "✓ Đã cài đặt các gói AUR"
}

# 2. Cài đặt Hyprland Caelestia
install_hyprland_caelestia() {
    log "Bước 2: Cài đặt Hyprland Caelestia..."
    
    if [ -d "$HOME/.local/share/caelestia" ]; then
        warning "Thư mục caelestia đã tồn tại. Backup..."
        mv "$HOME/.local/share/caelestia" "$HOME/.local/share/caelestia.backup.$(date +%s)"
    fi
    
    log "Clone caelestia dotfiles..."
    git clone https://github.com/caelestia-dots/caelestia.git "$HOME/.local/share/caelestia"
    
    cd "$HOME/.local/share/caelestia"
    
    log "Chạy install script của Caelestia..."
    fish ./install.fish --noconfirm --aur-helper=yay
    
    log "✓ Đã cài đặt Hyprland Caelestia"
}

# 3. Cài đặt driver và tối ưu cho gaming + C# development
install_gaming_dev_packages() {
    log "Bước 3: Cài đặt driver NVIDIA và môi trường gaming/dev..."
    
    # NVIDIA drivers với tất cả dependencies
    sudo pacman -S --needed --noconfirm \
        nvidia-dkms \
        nvidia-utils \
        lib32-nvidia-utils \
        nvidia-settings \
        opencl-nvidia \
        lib32-opencl-nvidia \
        libva-nvidia-driver \
        egl-wayland
    
    # CachyOS Gaming Packages
    log "Cài đặt cachyos-gaming-meta và cachyos-gaming-applications..."
    sudo pacman -S --needed --noconfirm \
        cachyos-gaming-meta \
        cachyos-gaming-applications
    
    # Additional gaming tools
    sudo pacman -S --needed --noconfirm \
        mangohud \
        lib32-mangohud \
        goverlay \
        gamemode \
        lib32-gamemode \
        gamescope
    
    # C# Development
    sudo pacman -S --needed --noconfirm \
        dotnet-sdk \
        dotnet-runtime \
        aspnet-runtime \
        mono \
        mono-msbuild
    
    # Development tools
    sudo pacman -S --needed --noconfirm \
        code \
        neovim \
        git \
        github-cli \
        docker \
        docker-compose
    
    # JetBrains Rider (optional)
    yay -S --noconfirm --needed rider
    
    # Enable services
    sudo systemctl enable --now docker.service
    sudo usermod -aG docker "$USER"
    
    log "✓ Đã cài đặt môi trường gaming và C# development"
}

# 4. Cài đặt Unreal Engine 5
install_unreal_engine() {
    log "Bước 4: Cài đặt Unreal Engine 5..."
    
    # Dependencies cho UE5 Editor
    sudo pacman -S --needed --noconfirm \
        dotnet-sdk \
        clang \
        make \
        cmake \
        ninja \
        vulkan-devel \
        vulkan-tools \
        vulkan-validation-layers \
        lib32-vulkan-icd-loader \
        libicu \
        xdg-user-dirs
    
    # Thư viện đồ họa và âm thanh cho UE games
    log "Cài đặt thư viện runtime cho UE games..."
    sudo pacman -S --needed --noconfirm \
        openal \
        lib32-openal \
        libpulse \
        lib32-libpulse \
        alsa-lib \
        lib32-alsa-lib \
        sdl2 \
        lib32-sdl2 \
        libxcursor \
        lib32-libxcursor \
        libxi \
        lib32-libxi \
        libxinerama \
        lib32-libxinerama \
        libxrandr \
        lib32-libxrandr \
        libxss \
        lib32-libxss \
        libglvnd \
        lib32-libglvnd \
        mesa \
        lib32-mesa \
        vulkan-icd-loader \
        lib32-vulkan-icd-loader
    
    # Codec và multimedia libraries
    log "Cài đặt codec multimedia..."
    sudo pacman -S --needed --noconfirm \
        ffmpeg \
        lib32-ffmpeg \
        gstreamer \
        gst-plugins-base \
        gst-plugins-good \
        gst-plugins-bad \
        gst-plugins-ugly \
        libvorbis \
        lib32-libvorbis \
        opus \
        lib32-opus \
        flac \
        lib32-flac
    
    # Thư viện networking và I/O
    log "Cài đặt thư viện networking..."
    sudo pacman -S --needed --noconfirm \
        curl \
        lib32-curl \
        openssl \
        lib32-openssl \
        libidn \
        lib32-libidn
    
    # Font và text rendering
    log "Cài đặt font libraries..."
    sudo pacman -S --needed --noconfirm \
        freetype2 \
        lib32-freetype2 \
        fontconfig \
        lib32-fontconfig \
        harfbuzz \
        lib32-harfbuzz
    
    # Compression libraries
    sudo pacman -S --needed --noconfirm \
        zlib \
        lib32-zlib \
        bzip2 \
        lib32-bzip2 \
        xz \
        lib32-xz \
        zstd \
        lib32-zstd
    
    # Cài libicu50 từ AUR (required cho UE5)
    yay -S --noconfirm --needed libicu50
    
    # Tạo thư mục cho UE5
    mkdir -p "$HOME/UnrealEngine"
    
    info "Để cài đặt Unreal Engine 5:"
    info "1. Đăng ký tài khoản Epic Games tại: https://www.epicgames.com"
    info "2. Link GitHub account tại: https://www.epicgames.com/account/connections"
    info "3. Download UE5 từ: https://www.unrealengine.com/linux"
    info "4. Giải nén file zip vào: $HOME/UnrealEngine/"
    info "5. Chạy: $HOME/UnrealEngine/Engine/Binaries/Linux/UnrealEditor"
    
    # Tạo helper script
    cat > "$HOME/.local/bin/ue5" <<'EOF'
#!/bin/bash
if [ -f "$HOME/UnrealEngine/Engine/Binaries/Linux/UnrealEditor" ]; then
    cd "$HOME/UnrealEngine"
    ./Engine/Binaries/Linux/UnrealEditor "$@"
else
    echo "Unreal Engine 5 chưa được cài đặt!"
    echo "Download từ: https://www.unrealengine.com/linux"
    echo "Giải nén vào: $HOME/UnrealEngine/"
fi
EOF
    chmod +x "$HOME/.local/bin/ue5"
    
    # Tạo desktop entry
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/unreal-engine.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Unreal Engine 5
Comment=Game Development Platform
Exec=$HOME/.local/bin/ue5
Icon=unreal-engine
Terminal=false
Categories=Development;IDE;
EOF
    
    log "✓ Đã chuẩn bị môi trường cho Unreal Engine 5"
}

# 5. Cài đặt AI/ML Stack cho RTX 3060 12GB
install_ai_ml_stack() {
    ai_info "Bước 5: Cài đặt AI/ML Stack cho RTX 3060 12GB..."
    
    # CUDA Toolkit và cuDNN
    ai_info "Cài đặt CUDA Toolkit và cuDNN..."
    sudo pacman -S --needed --noconfirm \
        cuda \
        cudnn \
        python-pytorch-cuda \
        python-tensorflow-cuda
    
    # Python và các dependencies
    sudo pacman -S --needed --noconfirm \
        python \
        python-pip \
        python-virtualenv \
        python-numpy \
        python-scipy \
        python-matplotlib \
        python-pandas \
        python-scikit-learn \
        jupyter-notebook
    
    # Ollama - Chạy LLMs local (Llama, Mistral, etc.)
    ai_info "Cài đặt Ollama..."
    yay -S --noconfirm --needed ollama-cuda
    sudo systemctl enable --now ollama.service
    
    # Stable Diffusion Web UI dependencies
    ai_info "Chuẩn bị cho Stable Diffusion..."
    sudo pacman -S --needed --noconfirm \
        python-pillow \
        python-requests \
        python-tqdm \
        ffmpeg
    
    # Text Generation WebUI dependencies
    sudo pacman -S --needed --noconfirm \
        python-transformers \
        python-accelerate \
        python-bitsandbytes
    
    # ComfyUI dependencies
    sudo pacman -S --needed --noconfirm \
        python-opencv \
        python-einops
    
    # LM Studio alternative - Jan
    yay -S --noconfirm --needed jan-bin
    
    # Koboldcpp cho text generation
    yay -S --noconfirm --needed koboldcpp-cuda
    
    ai_info "✓ Đã cài đặt AI/ML Stack"
}

# 6. Tạo môi trường AI/ML và cài các frameworks
setup_ai_environments() {
    ai_info "Bước 6: Thiết lập môi trường AI/ML..."
    
    mkdir -p "$HOME/AI-Projects"
    cd "$HOME/AI-Projects"
    
    # Stable Diffusion WebUI
    ai_info "Clone Stable Diffusion WebUI..."
    if [ ! -d "stable-diffusion-webui" ]; then
        git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
        cd stable-diffusion-webui
        
        # Tạo launch script tối ưu cho RTX 3060
        cat > "$HOME/.local/bin/sd-webui" <<'EOF'
#!/bin/bash
cd "$HOME/AI-Projects/stable-diffusion-webui"
./webui.sh --xformers --medvram --api
EOF
        chmod +x "$HOME/.local/bin/sd-webui"
    fi
    
    cd "$HOME/AI-Projects"
    
    # Text Generation WebUI (Oobabooga)
    ai_info "Clone Text Generation WebUI..."
    if [ ! -d "text-generation-webui" ]; then
        git clone https://github.com/oobabooga/text-generation-webui.git
        cd text-generation-webui
        
        cat > "$HOME/.local/bin/text-gen-webui" <<'EOF'
#!/bin/bash
cd "$HOME/AI-Projects/text-generation-webui"
./start_linux.sh
EOF
        chmod +x "$HOME/.local/bin/text-gen-webui"
    fi
    
    cd "$HOME/AI-Projects"
    
    # ComfyUI
    ai_info "Clone ComfyUI..."
    if [ ! -d "ComfyUI" ]; then
        git clone https://github.com/comfyanonymous/ComfyUI.git
        cd ComfyUI
        pip install -r requirements.txt
        
        cat > "$HOME/.local/bin/comfyui" <<'EOF'
#!/bin/bash
cd "$HOME/AI-Projects/ComfyUI"
python main.py
EOF
        chmod +x "$HOME/.local/bin/comfyui"
    fi
    
    # Tạo Python virtual environment cho AI projects
    ai_info "Tạo Python virtual environments..."
    cd "$HOME/AI-Projects"
    python -m venv ai-env
    
    # Cài các packages thông dụng
    source ai-env/bin/activate
    pip install --upgrade pip
    pip install \
        torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
        tensorflow \
        transformers \
        diffusers \
        accelerate \
        bitsandbytes \
        sentencepiece \
        protobuf \
        gradio \
        openai \
        anthropic \
        langchain \
        chromadb \
        faiss-gpu
    deactivate
    
    ai_info "✓ Đã thiết lập môi trường AI/ML"
}

# 7. Tạo helper scripts cho AI
create_ai_helper_scripts() {
    ai_info "Bước 7: Tạo AI helper scripts..."
    
    mkdir -p "$HOME/.local/bin"
    
    # Script kiểm tra CUDA và VRAM
    cat > "$HOME/.local/bin/check-ai-setup" <<'EOF'
#!/bin/bash
echo "=== CUDA & GPU Info ==="
nvidia-smi
echo ""
echo "=== CUDA Version ==="
nvcc --version
echo ""
echo "=== PyTorch CUDA Available ==="
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA Available: {torch.cuda.is_available()}'); print(f'CUDA Device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
echo ""
echo "=== TensorFlow GPU ==="
python -c "import tensorflow as tf; print(f'TensorFlow: {tf.__version__}'); print(f'GPU Available: {len(tf.config.list_physical_devices(\"GPU\"))}')"
echo ""
echo "=== Ollama Status ==="
systemctl status ollama.service --no-pager
EOF
    chmod +x "$HOME/.local/bin/check-ai-setup"
    
    # Script khởi động Ollama với model
    cat > "$HOME/.local/bin/ollama-start" <<'EOF'
#!/bin/bash
echo "Available models:"
ollama list
echo ""
echo "Popular models for RTX 3060 12GB:"
echo "  - llama3.2:3b (Fast, 3GB VRAM)"
echo "  - mistral:7b (Balanced, 4-5GB VRAM)"
echo "  - llama3.1:8b (Good quality, 5-6GB VRAM)"
echo "  - codellama:7b (Code, 4-5GB VRAM)"
echo ""
read -p "Enter model name to run (e.g., llama3.2:3b): " model
ollama run "$model"
EOF
    chmod +x "$HOME/.local/bin/ollama-start"
    
    # Script download models phổ biến
    cat > "$HOME/.local/bin/ollama-download-recommended" <<'EOF'
#!/bin/bash
echo "Downloading recommended models for RTX 3060 12GB..."
echo ""
echo "1. Llama 3.2 3B (Fast, general purpose)"
ollama pull llama3.2:3b
echo ""
echo "2. Mistral 7B (Balanced performance)"
ollama pull mistral:7b
echo ""
echo "3. CodeLlama 7B (Programming)"
ollama pull codellama:7b
echo ""
echo "Done! Run 'ollama list' to see installed models"
EOF
    chmod +x "$HOME/.local/bin/ollama-download-recommended"
    
    # Script monitor VRAM khi chạy AI
    cat > "$HOME/.local/bin/monitor-vram" <<'EOF'
#!/bin/bash
watch -n 1 'nvidia-smi --query-gpu=timestamp,name,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used --format=csv,noheader,nounits'
EOF
    chmod +x "$HOME/.local/bin/monitor-vram"
    
    # Script AI workspace
    cat > "$HOME/.local/bin/ai-workspace" <<'EOF'
#!/bin/bash
echo "=== AI/ML Workspace ==="
echo ""
echo "Available tools:"
echo "  1. Stable Diffusion WebUI    : sd-webui"
echo "  2. Text Generation WebUI     : text-gen-webui"
echo "  3. ComfyUI                   : comfyui"
echo "  4. Ollama (LLMs)             : ollama-start"
echo "  5. Jan (LM Studio)           : jan"
echo "  6. Koboldcpp                 : koboldcpp"
echo "  7. Jupyter Notebook          : jupyter notebook"
echo ""
echo "Helpers:"
echo "  - Check AI setup   : check-ai-setup"
echo "  - Monitor VRAM     : monitor-vram"
echo "  - Download models  : ollama-download-recommended"
echo ""
echo "AI Projects: $HOME/AI-Projects"
echo "Virtual env: source $HOME/AI-Projects/ai-env/bin/activate"
EOF
    chmod +x "$HOME/.local/bin/ai-workspace"
    
    ai_info "✓ Đã tạo AI helper scripts"
}

# 8. Tối ưu hệ thống cho Ryzen 7 5800X và RTX 3060
optimize_system() {
    log "Bước 8: Tối ưu hệ thống cho gaming, AI/ML và UE5..."
    
    # ROG STRIX B550-XE specific hardware support
    log "Cài đặt drivers cho ROG STRIX B550-XE..."
    sudo pacman -S --needed --noconfirm \
        amd-ucode \
        linux-firmware \
        linux-firmware-qlogic \
        alsa-firmware \
        sof-firmware
    
    # RGB Control cho ASUS ROG boards
    log "Cài đặt OpenRGB cho ASUS Aura Sync..."
    yay -S --noconfirm --needed \
        openrgb-bin \
        i2c-tools
    
    # Load i2c modules cho RGB control
    sudo modprobe i2c-dev
    sudo modprobe i2c-piix4
    echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c.conf
    echo "i2c-piix4" | sudo tee -a /etc/modules-load.d/i2c.conf
    
    # Add user to i2c group
    sudo groupadd -f i2c
    sudo usermod -aG i2c "$USER"
    
    # Udev rules cho OpenRGB
    sudo tee /etc/udev/rules.d/60-openrgb.rules > /dev/null <<'RGBEOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ATTR{idProduct}=="*", TAG+="uaccess"
KERNEL=="i2c-[0-9]*", TAG+="uaccess"
RGBEOF
    
    # Audio drivers cho Realtek ALC4080 (on ROG B550-XE)
    log "Cấu hình audio cho Realtek ALC4080..."
    sudo pacman -S --needed --noconfirm \
        pulseaudio-alsa \
        pavucontrol \
        alsa-utils \
        pipewire-alsa
    
    # Network drivers cho Intel I225-V 2.5G + Realtek RTL8125B
    log "Cài đặt network drivers..."
    sudo pacman -S --needed --noconfirm \
        ethtool \
        intel-media-driver \
        r8168-dkms
    
    # Enable 2.5G Ethernet offloading
    sudo tee /etc/systemd/network/99-ethernet-offload.link > /dev/null <<EOF
[Match]
Driver=r8169 igc

[Link]
ReceiveChecksumOffload=yes
TransmitChecksumOffload=yes
TCPSegmentationOffload=yes
GenericSegmentationOffload=yes
EOF
    
    # WiFi 6E support (Intel AX210)
    log "Cài đặt Intel WiFi 6E drivers..."
    sudo pacman -S --needed --noconfirm \
        linux-firmware \
        iw \
        wireless_tools \
        wpa_supplicant
    
    # Bluetooth support cho Intel AX210
    sudo pacman -S --needed --noconfirm \
        bluez \
        bluez-utils \
        blueman
    
    sudo systemctl enable --now bluetooth.service
    
    # Kernel parameters tối ưu cho Ryzen + Gaming + AI
    sudo tee /etc/sysctl.d/99-gaming-ai.conf > /dev/null <<EOF
# Gaming optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5

# Network optimizations (tối ưu cho 2.5G Ethernet)
net.core.netdev_max_backlog=16384
net.core.somaxconn=8192
net.core.rmem_default=1048576
net.core.rmem_max=16777216
net.core.wmem_default=1048576
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 1048576 2097152
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=cake
net.ipv4.tcp_fastopen=3

# Scheduler optimizations for Ryzen
kernel.sched_autogroup_enabled=1
kernel.sched_cfs_bandwidth_slice_us=500

# AI/ML optimizations - more shared memory
kernel.shmmax=68719476736
kernel.shmall=4294967296

# Ryzen 5800X specific - reduce latency
kernel.sched_migration_cost_ns=5000000
kernel.sched_nr_migrate=32
EOF
    
    sudo sysctl --system
    
    # Enable multilib
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
        sudo pacman -Sy
    fi
    
    # CPU frequency scaling cho Ryzen
    sudo pacman -S --needed --noconfirm cpupower
    sudo systemctl enable --now cpupower.service
    
    sudo tee /etc/default/cpupower > /dev/null <<EOF
governor='performance'
min_freq='800MHz'
max_freq='4.7GHz'
EOF
    
    # Ryzen power profile
    sudo tee /etc/modprobe.d/ryzen.conf > /dev/null <<EOF
options amd_pstate shared_mem=1
EOF
    
    # NVIDIA power management
    sudo tee /etc/modprobe.d/nvidia-power-management.conf > /dev/null <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
options nvidia NVreg_EnableGpuFirmware=0
options nvidia NVreg_DynamicPowerManagement=0x02
EOF
    
    # Enable NVIDIA services
    sudo systemctl enable nvidia-suspend.service
    sudo systemctl enable nvidia-hibernate.service
    sudo systemctl enable nvidia-resume.service
    
    # I/O Scheduler optimization (ROG boards thường có NVMe)
    sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null <<EOF
# HDD - mq-deadline
ACTION=="add|change", KERNEL=="sd[a-z]|hd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
# SSD - bfq
ACTION=="add|change", KERNEL=="sd[a-z]|hd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
# NVMe - none (best for PCIe 4.0)
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
EOF
    
    # USB optimization cho ROG board (nhiều USB ports)
    sudo tee /etc/udev/rules.d/50-usb-power.rules > /dev/null <<EOF
ACTION=="add", SUBSYSTEM=="usb", ATTR{power/autosuspend}="-1"
EOF
    
    log "✓ Đã tối ưu hệ thống cho ROG STRIX B550-XE"
}

# 9. Cấu hình Multi-Monitor cho Hyprland
setup_multi_monitor() {
    log "Bước 9: Cấu hình Multi-Monitor Support..."
    
    mkdir -p "$HOME/.config/hypr/conf.d"
    
    cat > "$HOME/.config/hypr/conf.d/monitors.conf" <<'EOF'
# Multi-Monitor Configuration
# Tự động phát hiện monitors hoặc cấu hình thủ công

# AUTO DETECTION (recommended)
# Hyprland sẽ tự động cấu hình tất cả monitors
monitor=,preferred,auto,1

# MANUAL CONFIGURATION
# Bỏ comment và chỉnh sửa theo monitors của bạn
# Cú pháp: monitor=NAME,RES@REFRESH,POSITION,SCALE

# Ví dụ: 2 monitors 1080p
# monitor=DP-1,1920x1080@144,0x0,1        # Monitor chính (trái)
# monitor=DP-3,1920x1080@60,1920x0,1  # Monitor phụ (phải)

# Ví dụ: 1 monitor 1440p + 1 monitor 1080p
# monitor=DP-1,2560x1440@144,0x0,1        # Monitor chính 1440p
# monitor=DP-3,1920x1080@60,2560x0,1  # Monitor phụ 1080p

# Ví dụ: 3 monitors
# monitor=DP-1,1920x1080@144,0x0,1        # Trái
# monitor=DP-2,1920x1080@144,1920x0,1     # Giữa (chính)
# monitor=DP-3,1920x1080@60,3840x0,1  # Phải

# Mirror mode (nhân bản màn hình)
# monitor=DP-1,1920x1080@144,0x0,1
# monitor=DP-3,mirror,DP-1

# Tắt một monitor cụ thể
# monitor=DP-3,disable

# Workspace binding (gán workspace cho monitor)
workspace=1,monitor:DP-1,default:true
workspace=2,monitor:DP-1
workspace=3,monitor:DP-1
workspace=4,monitor:DP-1
workspace=5,monitor:DP-1
workspace=6,monitor:DP-3
workspace=7,monitor:DP-3
workspace=8,monitor:DP-3
workspace=9,monitor:DP-3
workspace=10,monitor:DP-3
EOF
    
    cat > "$HOME/.config/hypr/scripts/detect-monitors.sh" <<'EOF'
#!/bin/bash
echo "Detecting monitors..."
hyprctl monitors | grep "Monitor"
echo ""
echo "Available outputs:"
hyprctl monitors -j | jq -r '.[] | "\(.name): \(.width)x\(.height)@\(.refreshRate)Hz"'
EOF
    
    chmod +x "$HOME/.config/hypr/scripts/detect-monitors.sh"
    
    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        if ! grep -q "source.*monitors.conf" "$HOME/.config/hypr/hyprland.conf"; then
            echo "source = ~/.config/hypr/conf.d/monitors.conf" >> "$HOME/.config/hypr/hyprland.conf"
        fi
    fi
    
    sudo pacman -S --needed --noconfirm wlr-randr nwg-displays
    
    log "✓ Đã cấu hình Multi-Monitor Support"
}

# 10. Cài đặt Fcitx5 Bamboo
install_vietnamese_input() {
    log "Bước 10: Cài đặt Fcitx5 Bamboo..."
    
    sudo pacman -S --needed --noconfirm \
        fcitx5 \
        fcitx5-qt \
        fcitx5-gtk \
        fcitx5-configtool
    
    yay -S --noconfirm --needed fcitx5-bamboo-git
    
    mkdir -p "$HOME/.config/environment.d"
    cat > "$HOME/.config/environment.d/fcitx5.conf" <<EOF
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=fcitx
EOF
    
    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        if ! grep -q "fcitx5" "$HOME/.config/hypr/hyprland.conf"; then
            echo "exec-once = fcitx5 -d" >> "$HOME/.config/hypr/hyprland.conf"
        fi
    fi
    
    log "✓ Đã cài đặt Fcitx5 Bamboo"
}

# 11. Cài đặt SDDM với Sugar Candy theme
install_sddm() {
    log "Bước 11: Cài đặt SDDM và Sugar Candy theme..."
    
    sudo pacman -S --needed --noconfirm sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
    
    sudo mkdir -p /usr/share/sddm/themes
    cd /tmp
    
    if [ -d "sddm-sugar-candy" ]; then
        rm -rf sddm-sugar-candy
    fi
    
    git clone https://github.com/Kangie/sddm-sugar-candy.git
    sudo cp -r sddm-sugar-candy /usr/share/sddm/themes/sugar-candy
    
    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<EOF
[Theme]
Current=sugar-candy

[General]
DisplayServer=wayland

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF
    
    sudo systemctl enable sddm.service
    
    log "✓ Đã cài đặt SDDM với Sugar Candy theme"
}

# 12. Tạo thư mục và tải wallpapers
setup_directories() {
    log "Bước 12: Tạo thư mục và tải wallpapers..."
    
    mkdir -p "$HOME/Desktop"
    mkdir -p "$HOME/Documents"
    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Music"
    mkdir -p "$HOME/Videos"
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/.config/hypr/scripts"
    mkdir -p "$HOME/AI-Projects"
    mkdir -p "$HOME/AI-Models"
    
    if [ ! -d "$HOME/Pictures/Wallpapers/.git" ]; then
        git clone https://github.com/mylinuxforwork/wallpaper.git "$HOME/Pictures/Wallpapers"
    else
        cd "$HOME/Pictures/Wallpapers" && git pull
    fi
    
    log "✓ Đã tạo thư mục và tải wallpapers"
}

# 13. Cài đặt OBS Studio và streaming tools
install_streaming_tools() {
    log "Bước 13: Cài đặt OBS Studio và streaming tools..."
    
    # OBS Studio với NVIDIA NVENC support
    sudo pacman -S --needed --noconfirm \
        obs-studio \
        libva-nvidia-driver \
        v4l2loopback-dkms \
        pipewire \
        pipewire-pulse \
        pipewire-jack \
        wireplumber \
        gstreamer-vaapi
    
    # OBS plugins từ AUR
    log "Cài đặt OBS plugins..."
    yay -S --noconfirm --needed \
        obs-vkcapture \
        obs-studio-browser \
        obs-websocket
    
    # Vencord (Discord mod) - Better Discord experience
    log "Cài đặt Vencord..."
    yay -S --noconfirm --needed \
        vesktop-bin
    
    # Streaming và recording utilities
    sudo pacman -S --needed --noconfirm \
        ffmpeg \
        x264 \
        x265 \
        libva-mesa-driver \
        mesa-vdpau
    
    # Load v4l2loopback module for virtual camera
    sudo modprobe v4l2loopback
    echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf
    
    log "✓ Đã cài đặt OBS Studio và Vencord"
}

# 14. Cài đặt utilities bổ sung
install_utilities() {
    log "Bước 14: Cài đặt các công cụ bổ sung..."
    
    sudo pacman -S --needed --noconfirm \
        htop \
        btop \
        neofetch \
        fastfetch \
        unzip \
        p7zip \
        unrar \
        rsync \
        tmux \
        starship \
        eza \
        bat \
        ripgrep \
        fd \
        fzf \
        zoxide
    
    sudo pacman -S --needed --noconfirm \
        nvtop \
        amdgpu_top \
        iotop \
        iftop
    
    log "✓ Đã cài đặt các công cụ bổ sung"
}

# 15. Tạo scripts hữu ích
create_helper_scripts() {
    log "Bước 15: Tạo các helper scripts..."
    
    mkdir -p "$HOME/.local/bin"
    
    cat > "$HOME/.local/bin/check-gpu" <<'EOF'
#!/bin/bash
echo "=== NVIDIA GPU Status ==="
nvidia-smi
echo ""
echo "=== Vulkan Info ==="
vulkaninfo --summary
echo ""
echo "=== OpenGL Info ==="
glxinfo | grep "OpenGL renderer"
EOF
    chmod +x "$HOME/.local/bin/check-gpu"
    
    cat > "$HOME/.local/bin/rgb-control" <<'EOF'
#!/bin/bash
echo "Starting OpenRGB for ASUS Aura Sync control..."
openrgb
EOF
    chmod +x "$HOME/.local/bin/rgb-control"
    
    cat > "$HOME/.local/bin/game-mode-on" <<'EOF'
#!/bin/bash
echo "Enabling gaming optimizations..."
sudo cpupower frequency-set -g performance
sudo sysctl vm.swappiness=1
echo "Gaming mode enabled!"
EOF
    chmod +x "$HOME/.local/bin/game-mode-on"
    
    cat > "$HOME/.local/bin/game-mode-off" <<'EOF'
#!/bin/bash
echo "Disabling gaming optimizations..."
sudo cpupower frequency-set -g schedutil
sudo sysctl vm.swappiness=10
echo "Gaming mode disabled!"
EOF
    chmod +x "$HOME/.local/bin/game-mode-off"
    
    cat > "$HOME/.local/bin/backup-configs" <<'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/Documents/config-backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r ~/.config/hypr "$BACKUP_DIR/"
cp -r ~/.config/fcitx5 "$BACKUP_DIR/"
echo "Configs backed up to: $BACKUP_DIR"
EOF
    chmod +x "$HOME/.local/bin/backup-configs"
    
    if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    
    log "✓ Đã tạo helper scripts"
}

# Main function
main() {
    clear
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    CachyOS Setup - Gaming, C# Dev, AI/ML & UE5 (RTX 3060)     ║${NC}"
    echo -e "${GREEN}║    Hardware: Ryzen 7 5800X | RTX 3060 12GB | 32GB RAM         ║${NC}"
    echo -e "${MAGENTA}║   ✨ AI/ML + Unreal Engine 5 Support                         ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_root
    
    log "Bắt đầu cài đặt tự động..."
    log "Log file: $LOG_FILE"
    
    install_base_packages
    install_aur_packages
    install_hyprland_caelestia
    install_gaming_dev_packages
    install_unreal_engine
    install_ai_ml_stack
    setup_ai_environments
    create_ai_helper_scripts
    optimize_system
    setup_multi_monitor
    install_vietnamese_input
    install_sddm
    setup_directories
    install_streaming_tools
    install_utilities
    create_helper_scripts
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║             Cài đặt hoàn tất thành công!                      ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    info "Các bước tiếp theo:"
    echo "  1. Khởi động lại hệ thống: sudo reboot"
    echo "  2. Đăng nhập vào Hyprland từ SDDM"
    echo ""
    echo -e "${MAGENTA}  🎮 Unreal Engine 5:${NC}"
    echo "  - Download: https://www.unrealengine.com/linux"
    echo "  - Giải nén vào: ~/UnrealEngine/"
    echo "  - Chạy: ue5"
    echo "  - Desktop: Launch từ menu Applications"
    echo ""
    echo -e "${MAGENTA}  🤖 AI/ML Quick Start:${NC}"
    echo "  - Xem workspace: ai-workspace"
    echo "  - Kiểm tra setup: check-ai-setup"
    echo "  - Download models: ollama-download-recommended"
    echo "  - Chạy Ollama: ollama-start"
    echo "  - Stable Diffusion: sd-webui"
    echo "  - Monitor VRAM: monitor-vram"
    echo ""
    echo -e "${CYAN}  🎥 Streaming & Recording:${NC}"
    echo "  - OBS Studio: obs (NVIDIA NVENC support)"
    echo "  - Vencord/Vesktop: vesktop"
    echo "  - Virtual camera: Enabled (v4l2loopback)"
    echo ""
    echo "  📺 Multi-Monitor:"
    echo "  - Phát hiện: ~/.config/hypr/scripts/detect-monitors.sh"
    echo "  - GUI tool: nwg-displays"
    echo ""
    echo -e "${CYAN}  🌈 ROG RGB Control:${NC}"
    echo "  - OpenRGB: rgb-control"
    echo "  - ASUS Aura Sync compatible"
    echo ""
    echo "  ⚡ Performance:"
    echo "  - Kiểm tra GPU: check-gpu"
    echo "  - Gaming mode: game-mode-on / game-mode-off"
    echo ""
    echo "  ⌨️ Tiếng Việt: fcitx5-configtool (Ctrl + Space)"
    echo ""
    echo "  Log file: $LOG_FILE"
}

main "$@"