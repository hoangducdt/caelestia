#!/bin/bash

# CachyOS Auto Setup Script - Creative Suite Enhanced Version
# Hệ thống: ASUS ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12G | 32GB RAM
# Mục đích: Gaming, C# Dev, AI/ML, UE5, 3D/Creative Work với RTX 3060 12GB

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

creative_info() {
    echo -e "${CYAN}[CREATIVE]${NC} $1" | tee -a "$LOG_FILE"
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
        icu \
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
        zlib-ng \
        lib32-zlib-ng \
        bzip2 \
        lib32-bzip2 \
        xz \
        lib32-xz \
        zstd \
        lib32-zstd

    
    # Cài libicu50 từ AUR (required cho UE5)
    yay -S --noconfirm --needed libicu50
yay -S --noconfirm --needed lib32-ffmpeg
    
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
    sudo pacman -S --needed --noconfirm \
        cuda \
        cudnn \
        python-pytorch-cuda
    
    # Python development environment
    sudo pacman -S --needed --noconfirm \
        python \
        python-pip \
        python-virtualenv \
        python-numpy \
        python-pandas \
        jupyter-notebook \
        python-scikit-learn \
        python-matplotlib \
        python-pillow
    
    # Ollama với CUDA support
    yay -S --noconfirm --needed ollama-cuda
    sudo systemctl enable --now ollama.service
    
    # Jan - Desktop AI interface
    yay -S --noconfirm --needed jan-bin
    
    # Koboldcpp với CUDA
    yay -S --noconfirm --needed koboldcpp-cuda
    
    ai_info "✓ Đã cài đặt AI/ML Stack cơ bản"
}

# 6. Setup AI environments
setup_ai_environments() {
    ai_info "Bước 6: Thiết lập môi trường AI/ML..."
    
    mkdir -p "$HOME/AI-Projects"
    mkdir -p "$HOME/AI-Models"
    
    # Stable Diffusion WebUI (AUTOMATIC1111)
    if [ ! -d "$HOME/AI-Projects/stable-diffusion-webui" ]; then
        ai_info "Cài đặt Stable Diffusion WebUI..."
        cd "$HOME/AI-Projects"
        git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
        
        cd stable-diffusion-webui
        python -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
        deactivate
    fi
    
    # Text Generation WebUI (Oobabooga)
    if [ ! -d "$HOME/AI-Projects/text-generation-webui" ]; then
        ai_info "Cài đặt Text Generation WebUI..."
        cd "$HOME/AI-Projects"
        git clone https://github.com/oobabooga/text-generation-webui.git
        
        cd text-generation-webui
        python -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
        pip install -r requirements.txt
        deactivate
    fi
    
    # ComfyUI
    if [ ! -d "$HOME/AI-Projects/ComfyUI" ]; then
        ai_info "Cài đặt ComfyUI..."
        cd "$HOME/AI-Projects"
        git clone https://github.com/comfyanonymous/ComfyUI.git
        
        cd ComfyUI
        python -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
        pip install -r requirements.txt
        deactivate
    fi
    
    ai_info "✓ Đã thiết lập các môi trường AI/ML"
}

# 7. Create AI helper scripts
create_ai_helper_scripts() {
    ai_info "Bước 7: Tạo helper scripts cho AI/ML..."
    
    mkdir -p "$HOME/.local/bin"
    
    # AI workspace overview
    cat > "$HOME/.local/bin/ai-workspace" <<'EOF'
#!/bin/bash
echo "=== AI/ML Workspace Overview ==="
echo ""
echo "📁 Directories:"
echo "  - AI Projects: $HOME/AI-Projects"
echo "  - AI Models: $HOME/AI-Models"
echo ""
echo "🤖 Available Tools:"
echo "  - Ollama (LLM): ollama-start"
echo "  - Jan (Desktop AI): jan"
echo "  - Stable Diffusion: sd-webui"
echo "  - Text Generation: text-gen-webui"
echo "  - ComfyUI: comfyui"
echo ""
echo "📊 Quick Commands:"
echo "  - Check AI setup: check-ai-setup"
echo "  - Monitor VRAM: monitor-vram"
echo "  - Download models: ollama-download-recommended"
EOF
    chmod +x "$HOME/.local/bin/ai-workspace"
    
    # Check AI setup
    cat > "$HOME/.local/bin/check-ai-setup" <<'EOF'
#!/bin/bash
echo "=== CUDA Check ==="
nvcc --version
echo ""
echo "=== PyTorch CUDA Check ==="
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA Available: {torch.cuda.is_available()}'); print(f'CUDA Version: {torch.version.cuda}'); print(f'Device Count: {torch.cuda.device_count()}'); print(f'Device Name: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
echo ""
echo "=== Ollama Service ==="
systemctl status ollama.service --no-pager
echo ""
echo "=== VRAM Status ==="
nvidia-smi --query-gpu=memory.used,memory.free,memory.total --format=csv
EOF
    chmod +x "$HOME/.local/bin/check-ai-setup"
    
    # Monitor VRAM
    cat > "$HOME/.local/bin/monitor-vram" <<'EOF'
#!/bin/bash
watch -n 1 'nvidia-smi --query-gpu=utilization.gpu,utilization.memory,memory.used,memory.free,memory.total,temperature.gpu --format=csv,noheader,nounits | awk -F, "{printf \"GPU: %s%% | VRAM: %s%% | Used: %sMB | Free: %sMB | Total: %sMB | Temp: %s°C\n\", \$1, \$2, \$3, \$4, \$5, \$6}"'
EOF
    chmod +x "$HOME/.local/bin/monitor-vram"
    
    # Ollama start
    cat > "$HOME/.local/bin/ollama-start" <<'EOF'
#!/bin/bash
echo "Starting Ollama service..."
sudo systemctl start ollama.service
echo "Ollama is running!"
echo "Usage: ollama run <model-name>"
echo "Example: ollama run llama3.2:3b"
EOF
    chmod +x "$HOME/.local/bin/ollama-start"
    
    # Download recommended models
    cat > "$HOME/.local/bin/ollama-download-recommended" <<'EOF'
#!/bin/bash
echo "Downloading recommended LLM models for RTX 3060 12GB..."
echo ""
echo "1. Llama 3.2 3B (Fast, ~3GB VRAM)"
ollama pull llama3.2:3b
echo ""
echo "2. Mistral 7B (Balanced, ~4-5GB VRAM)"
ollama pull mistral:7b
echo ""
echo "3. CodeLlama 7B (Coding, ~4-5GB VRAM)"
ollama pull codellama:7b
echo ""
echo "All recommended models downloaded!"
echo "Run with: ollama run <model-name>"
EOF
    chmod +x "$HOME/.local/bin/ollama-download-recommended"
    
    # Stable Diffusion WebUI launcher
    cat > "$HOME/.local/bin/sd-webui" <<'EOF'
#!/bin/bash
if [ -d "$HOME/AI-Projects/stable-diffusion-webui" ]; then
    cd "$HOME/AI-Projects/stable-diffusion-webui"
    source venv/bin/activate
    ./webui.sh --xformers --api
else
    echo "Stable Diffusion WebUI chưa được cài đặt!"
fi
EOF
    chmod +x "$HOME/.local/bin/sd-webui"
    
    # Text Generation WebUI launcher
    cat > "$HOME/.local/bin/text-gen-webui" <<'EOF'
#!/bin/bash
if [ -d "$HOME/AI-Projects/text-generation-webui" ]; then
    cd "$HOME/AI-Projects/text-generation-webui"
    source venv/bin/activate
    python server.py --listen --api
else
    echo "Text Generation WebUI chưa được cài đặt!"
fi
EOF
    chmod +x "$HOME/.local/bin/text-gen-webui"
    
    # ComfyUI launcher
    cat > "$HOME/.local/bin/comfyui" <<'EOF'
#!/bin/bash
if [ -d "$HOME/AI-Projects/ComfyUI" ]; then
    cd "$HOME/AI-Projects/ComfyUI"
    source venv/bin/activate
    python main.py --listen 0.0.0.0
else
    echo "ComfyUI chưa được cài đặt!"
fi
EOF
    chmod +x "$HOME/.local/bin/comfyui"
    
    ai_info "✓ Đã tạo AI helper scripts"
}

# 8. Install Blender with GPU optimization
install_blender() {
    creative_info "Bước 8: Cài đặt Blender với tối ưu CUDA/OptiX..."
    
    # Install Blender
    sudo pacman -S --needed --noconfirm blender
    
    # Install Blender dependencies for better performance
    sudo pacman -S --needed --noconfirm \
        openimagedenoise \
        opencolorio \
        opensubdiv \
        openvdb \
        embree \
        openimageio \
        alembic \
        openjpeg2 \
        openexr \
        libspnav
    
    # Create Blender config directory
    mkdir -p "$HOME/.config/blender"
    
    # Create Blender launcher script with GPU optimization
    cat > "$HOME/.local/bin/blender-gpu" <<'EOF'
#!/bin/bash
# Launch Blender with CUDA/OptiX enabled
export CYCLES_CUDA_EXTRA_CFLAGS="-DCUDA_ENABLE_DEPRECATED_COMPUTE_TARGET"
blender "$@"
EOF
    chmod +x "$HOME/.local/bin/blender-gpu"
    
    # Create Blender preferences script
    cat > "$HOME/.local/bin/blender-setup-gpu" <<'EOF'
#!/bin/bash
echo "=== Blender GPU Setup Guide ==="
echo ""
echo "To enable CUDA/OptiX in Blender:"
echo "1. Open Blender"
echo "2. Go to Edit → Preferences"
echo "3. Select 'System' tab"
echo "4. Under 'Cycles Render Devices':"
echo "   - Set to 'CUDA' or 'OptiX' (OptiX recommended for RTX)"
echo "5. Check your GPU (NVIDIA GeForce RTX 3060)"
echo "6. Click 'Save Preferences'"
echo ""
echo "For rendering:"
echo "- Use OptiX for fastest ray tracing"
echo "- Enable denoising (OptiX Denoiser)"
echo "- Tile size: 256x256 or 512x512 for RTX"
echo ""
echo "Performance tips for RTX 3060 12GB:"
echo "- Max samples for viewport: 128-256"
echo "- Max samples for final render: 512-2048"
echo "- Enable adaptive sampling"
echo "- Use OptiX denoiser instead of more samples"
EOF
    chmod +x "$HOME/.local/bin/blender-setup-gpu"
    
    # Create Desktop Entry for Blender
    cat > "$HOME/.local/share/applications/blender-gpu.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Blender (GPU Optimized)
Comment=3D Creation Suite with CUDA/OptiX
Exec=$HOME/.local/bin/blender-gpu %f
Icon=blender
Terminal=false
Categories=Graphics;3DGraphics;
MimeType=application/x-blender;
EOF
    
    creative_info "✓ Đã cài đặt Blender với tối ưu GPU"
}

# 9. Install Adobe Creative Suite Alternatives
install_creative_suite() {
    creative_info "Bước 9: Cài đặt Adobe Creative Suite Alternatives..."
    
    # GIMP - Photoshop alternative
    creative_info "Cài đặt GIMP (Photoshop alternative)..."
    sudo pacman -S --needed --noconfirm \
        gimp \
        gimp-help-vi \
        gimp-plugin-gmic \
        gimp-nufraw
    
    # Krita - Digital painting
    creative_info "Cài đặt Krita (Digital painting)..."
    sudo pacman -S --needed --noconfirm krita
    
    # Inkscape - Illustrator alternative
    creative_info "Cài đặt Inkscape (Illustrator alternative)..."
    sudo pacman -S --needed --noconfirm inkscape
    
    # Kdenlive - Video editing (Premiere alternative)
    creative_info "Cài đặt Kdenlive (Premiere alternative)..."
    sudo pacman -S --needed --noconfirm \
        kdenlive \
        frei0r-plugins \
        mediainfo \
        mlt
    
    # DaVinci Resolve (Optional - Professional video editing)
    creative_info "Thêm DaVinci Resolve vào danh sách tùy chọn..."
    yay -S --noconfirm --needed davinci-resolve || warning "DaVinci Resolve không khả dụng hoặc cần cài thủ công"
    
    # Audacity - Audio editing
    creative_info "Cài đặt Audacity (Audio editing)..."
    sudo pacman -S --needed --noconfirm audacity
    
    # Ardour - Professional DAW
    sudo pacman -S --needed --noconfirm ardour
    
    # Scribus - InDesign alternative
    creative_info "Cài đặt Scribus (InDesign alternative)..."
    sudo pacman -S --needed --noconfirm scribus
    
    # Darktable - Lightroom alternative
    creative_info "Cài đặt Darktable (Lightroom alternative)..."
    sudo pacman -S --needed --noconfirm darktable
    
    # RawTherapee - RAW photo editor
    sudo pacman -S --needed --noconfirm rawtherapee
    
    # Natron - After Effects alternative
    yay -S --noconfirm --needed natron || warning "Natron không khả dụng từ AUR"
    
    # Supporting tools
    sudo pacman -S --needed --noconfirm \
        imagemagick \
        graphicsmagick \
        potrace \
        fontforge
    
    creative_info "✓ Đã cài đặt Creative Suite alternatives"
}

# 10. Create Creative Suite helper scripts
create_creative_suite_scripts() {
    creative_info "Bước 10: Tạo helper scripts cho Creative Suite..."
    
    # Creative apps overview
    cat > "$HOME/.local/bin/creative-apps" <<'EOF'
#!/bin/bash
echo "=== Creative Suite Applications ==="
echo ""
echo "🎨 Image Editing:"
echo "  - GIMP (Photoshop): gimp"
echo "  - Krita (Digital Painting): krita"
echo "  - Darktable (Lightroom): darktable"
echo "  - RawTherapee (RAW): rawtherapee"
echo ""
echo "🎬 Video Editing:"
echo "  - Kdenlive (Premiere): kdenlive"
echo "  - DaVinci Resolve: davinci-resolve (if installed)"
echo "  - Natron (After Effects): natron (if installed)"
echo ""
echo "✏️ Vector & Design:"
echo "  - Inkscape (Illustrator): inkscape"
echo "  - Scribus (InDesign): scribus"
echo ""
echo "🎵 Audio:"
echo "  - Audacity: audacity"
echo "  - Ardour (DAW): ardour"
echo ""
echo "🔮 3D:"
echo "  - Blender: blender-gpu"
echo "  - Setup Blender GPU: blender-setup-gpu"
EOF
    chmod +x "$HOME/.local/bin/creative-apps"
    
    # Batch image converter using ImageMagick
    cat > "$HOME/.local/bin/batch-convert-images" <<'EOF'
#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: batch-convert-images <input-format> <output-format> [quality]"
    echo "Example: batch-convert-images jpg png"
    echo "Example: batch-convert-images png jpg 95"
    exit 1
fi

INPUT_FORMAT="$1"
OUTPUT_FORMAT="$2"
QUALITY="${3:-95}"

echo "Converting all .$INPUT_FORMAT files to .$OUTPUT_FORMAT (quality: $QUALITY)..."
for file in *."$INPUT_FORMAT"; do
    if [ -f "$file" ]; then
        output="${file%.*}.$OUTPUT_FORMAT"
        echo "Converting: $file -> $output"
        convert "$file" -quality "$QUALITY" "$output"
    fi
done
echo "Conversion complete!"
EOF
    chmod +x "$HOME/.local/bin/batch-convert-images"
    
    # Video transcode helper
    cat > "$HOME/.local/bin/video-transcode" <<'EOF'
#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: video-transcode <input-file> <output-file> [preset]"
    echo "Presets: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow"
    echo "Example: video-transcode input.mov output.mp4 fast"
    exit 1
fi

INPUT="$1"
OUTPUT="$2"
PRESET="${3:-medium}"

echo "Transcoding video with NVENC (GPU accelerated)..."
ffmpeg -hwaccel cuda -i "$INPUT" \
    -c:v h264_nvenc -preset "$PRESET" -b:v 10M \
    -c:a aac -b:a 192k \
    "$OUTPUT"
echo "Transcoding complete: $OUTPUT"
EOF
    chmod +x "$HOME/.local/bin/video-transcode"
    
    # GIMP batch processor
    cat > "$HOME/.local/bin/gimp-batch-resize" <<'EOF'
#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: gimp-batch-resize <width> <height> *.jpg"
    echo "Example: gimp-batch-resize 1920 1080 *.jpg"
    exit 1
fi

WIDTH="$1"
HEIGHT="$2"
shift 2

for img in "$@"; do
    if [ -f "$img" ]; then
        output="resized_${img}"
        echo "Resizing: $img -> $output"
        gimp -i -b "(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE \"$img\" \"$img\"))) \
                           (drawable (car (gimp-image-get-active-layer image)))) \
                     (gimp-image-scale image $WIDTH $HEIGHT) \
                     (gimp-file-save RUN-NONINTERACTIVE image drawable \"$output\" \"$output\") \
                     (gimp-image-delete image))" -b "(gimp-quit 0)"
    fi
done
echo "Batch resize complete!"
EOF
    chmod +x "$HOME/.local/bin/gimp-batch-resize"
    
    # Blender render script
    cat > "$HOME/.local/bin/blender-render" <<'EOF'
#!/bin/bash
if [ $# -lt 1 ]; then
    echo "Usage: blender-render <file.blend> [output-dir] [start-frame] [end-frame]"
    echo "Example: blender-render project.blend ./renders 1 250"
    exit 1
fi

BLEND_FILE="$1"
OUTPUT_DIR="${2:-.}"
START_FRAME="${3:-1}"
END_FRAME="${4:-1}"

mkdir -p "$OUTPUT_DIR"

echo "Rendering $BLEND_FILE with GPU (CUDA/OptiX)..."
blender -b "$BLEND_FILE" -o "$OUTPUT_DIR/frame_####" -s "$START_FRAME" -e "$END_FRAME" -a -- --cycles-device OPTIX

echo "Render complete! Output: $OUTPUT_DIR"
EOF
    chmod +x "$HOME/.local/bin/blender-render"
    
    creative_info "✓ Đã tạo Creative Suite helper scripts"
}

# 11. Optimize system
optimize_system() {
    log "Bước 11: Tối ưu hệ thống..."
    
    # CPU Governor
    sudo pacman -S --needed --noconfirm cpupower
    sudo systemctl enable --now cpupower.service
    
    # Set performance governor
    echo "governor='performance'" | sudo tee /etc/default/cpupower
    sudo cpupower frequency-set -g performance
    
    # Sysctl optimizations
    sudo tee /etc/sysctl.d/99-gaming.conf > /dev/null <<EOF
# Gaming optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5

# Network optimizations
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864

# AI/ML optimizations (large models)
kernel.shmmax=68719476736
kernel.shmall=16777216
EOF
    
    sudo sysctl --system
    
    # I/O Scheduler optimization
    sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null <<EOF
# NVMe - none scheduler (best for PCIe 4.0)
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"

# SSD - bfq scheduler
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"

# HDD - mq-deadline scheduler
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
EOF
    
    log "✓ Đã tối ưu hệ thống"
}

# 12. Setup multi-monitor
setup_multi_monitor() {
    log "Bước 12: Cài đặt công cụ multi-monitor..."
    
    sudo pacman -S --needed --noconfirm \
        wlr-randr \
        kanshi
    
    yay -S --noconfirm --needed nwg-displays
    
    mkdir -p "$HOME/.config/hypr/scripts"
    
    cat > "$HOME/.config/hypr/scripts/detect-monitors.sh" <<'EOF'
#!/bin/bash
wlr-randr
EOF
    chmod +x "$HOME/.config/hypr/scripts/detect-monitors.sh"
    
    log "✓ Đã cài đặt công cụ multi-monitor"
}

# 13. Install Vietnamese input
install_vietnamese_input() {
    log "Bước 13: Cài đặt Fcitx5 Bamboo..."
    
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

# 14. Install SDDM
install_sddm() {
    log "Bước 14: Cài đặt SDDM và Sugar Candy theme..."
    
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

# 15. Setup directories
setup_directories() {
    log "Bước 15: Tạo thư mục và tải wallpapers..."
    
    mkdir -p "$HOME/Desktop"
    mkdir -p "$HOME/Documents"
    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Music"
    mkdir -p "$HOME/Videos"
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/.config/hypr/scripts"
    mkdir -p "$HOME/AI-Projects"
    mkdir -p "$HOME/AI-Models"
    mkdir -p "$HOME/Creative-Projects"
    mkdir -p "$HOME/Blender-Projects"
    
    if [ ! -d "$HOME/Pictures/Wallpapers/.git" ]; then
        git clone https://github.com/mylinuxforwork/wallpaper.git "$HOME/Pictures/Wallpapers"
    else
        cd "$HOME/Pictures/Wallpapers" && git pull
    fi
    
    log "✓ Đã tạo thư mục và tải wallpapers"
}

# 16. Install streaming tools
install_streaming_tools() {
    log "Bước 16: Cài đặt OBS Studio và streaming tools..."
    
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
    
    # Vencord (Discord mod)
    log "Cài đặt Vencord..."
    yay -S --noconfirm --needed vesktop-bin
    
    # Streaming utilities
    sudo pacman -S --needed --noconfirm \
        ffmpeg \
        x264 \
        x265 \
        libva-mesa-driver \
        mesa-vdpau
    
    # Load v4l2loopback module
    sudo modprobe v4l2loopback
    echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf
    
    log "✓ Đã cài đặt OBS Studio và Vencord"
}

# 17. Install utilities
install_utilities() {
    log "Bước 17: Cài đặt các công cụ bổ sung..."
    
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
        zoxide \
        nvtop \
        amdgpu_top \
        iotop \
        iftop
    
    log "✓ Đã cài đặt các công cụ bổ sung"
}

# 18. Create helper scripts
create_helper_scripts() {
    log "Bước 18: Tạo các helper scripts..."
    
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
cp -r ~/.config/blender "$BACKUP_DIR/" 2>/dev/null
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
    echo -e "${GREEN}║    CachyOS Creative Suite Setup (Gaming+Dev+AI/ML+3D)         ║${NC}"
    echo -e "${GREEN}║    Hardware: Ryzen 7 5800X | RTX 3060 12GB | 32GB RAM         ║${NC}"
    echo -e "${MAGENTA}║   ✨ Blender + Adobe Alternatives + AI/ML + UE5              ║${NC}"
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
    install_blender
    install_creative_suite
    create_creative_suite_scripts
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
    echo -e "${CYAN}  🎨 Creative Suite Applications:${NC}"
    echo "  - View all apps: creative-apps"
    echo "  - Blender (GPU): blender-gpu"
    echo "  - Setup Blender GPU: blender-setup-gpu"
    echo "  - GIMP: gimp"
    echo "  - Inkscape: inkscape"
    echo "  - Kdenlive: kdenlive"
    echo ""
    echo -e "${MAGENTA}  🤖 AI/ML Quick Start:${NC}"
    echo "  - Xem workspace: ai-workspace"
    echo "  - Kiểm tra setup: check-ai-setup"
    echo "  - Download models: ollama-download-recommended"
    echo "  - Chạy Ollama: ollama-start"
    echo "  - Stable Diffusion: sd-webui"
    echo "  - Monitor VRAM: monitor-vram"
    echo ""
    echo -e "${MAGENTA}  🎮 Unreal Engine 5:${NC}"
    echo "  - Download: https://www.unrealengine.com/linux"
    echo "  - Giải nén vào: ~/UnrealEngine/"
    echo "  - Chạy: ue5"
    echo ""
    echo -e "${CYAN}  🎥 Streaming & Recording:${NC}"
    echo "  - OBS Studio: obs (NVIDIA NVENC support)"
    echo "  - Vencord/Vesktop: vesktop"
    echo "  - Virtual camera: Enabled (v4l2loopback)"
    echo ""
    echo -e "${CYAN}  🌈 ROG RGB Control:${NC}"
    echo "  - OpenRGB: rgb-control"
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