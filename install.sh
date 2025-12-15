#!/bin/bash

# ============================================================================
# CachyOS Complete Setup - ONE-COMMAND INSTALLER
# ============================================================================
# FULL FEATURES:
# - NVIDIA fix
# - AI/ML Stack (Ollama, Stable Diffusion, Text Gen, ComfyUI)
# - Creative Suite (Blender, GIMP, Kdenlive, etc.)
# - Multi-monitor support
# - Vietnamese input
# - SDDM + Sugar Candy theme
# - Wallpapers
# - All helper scripts
# ============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_URL="https://github.com/hoangducdt/caelestia.git"
INSTALL_DIR="$HOME/cachyos-autosetup"
LOG_FILE="$HOME/caelestia_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${GREEN}▶${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}✗${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
warning() { echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG_FILE"; }
ai_info() { echo -e "${MAGENTA}[AI/ML]${NC} $1" | tee -a "$LOG_FILE"; }
creative_info() { echo -e "${CYAN}[CREATIVE]${NC} $1" | tee -a "$LOG_FILE"; }

clear
echo -e "${GREEN}"
cat << "EOF"
╭───────────────────────────────────────────────────────────────────╮
│         ______           __          __  _                        │
│        / ____/___ ____  / /__  _____/ /_(_)___ _                  │
│       / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/                  │
│      / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /                   │
│      \____/\__,_/\___/_/\___/____/\__/_/\__,_/                    │
│                                                                   │
│   COMPLETE INSTALLER - All Features Included                     │
│   ROG STRIX B550-XE │ Ryzen 7 5800X │ RTX 3060 12GB              │
╰───────────────────────────────────────────────────────────────────╯
EOF
echo -e "${NC}"

[ "$EUID" -eq 0 ] && error "KHÔNG chạy với sudo"

log "Starting complete installation..."

# Fix NVIDIA conflicts
log "Fixing NVIDIA conflicts..."
for pkg in linux-cachyos-nvidia-open linux-cachyos-lts-nvidia-open nvidia-open lib32-nvidia-open media-dkms; do
    pacman -Qi "$pkg" &>/dev/null && sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
done

# Install git
command -v git &>/dev/null || sudo pacman -S --needed --noconfirm git

# Clone repo
if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" && git pull --quiet || true
else
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" || error "Clone failed"
    cd "$INSTALL_DIR"
fi

# Create complete setup script
log "Creating complete setup script..."

cat > "$INSTALL_DIR/setup-complete.sh" << 'COMPLETE_SETUP'
#!/bin/bash
# Complete Setup Script with ALL Features

set -e

LOG="$HOME/setup_complete_$(date +%Y%m%d_%H%M%S).log"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG"; }
warn() { echo -e "${YELLOW}⚠${NC} $1" | tee -a "$LOG"; }
ai_info() { echo -e "${MAGENTA}[AI/ML]${NC} $1" | tee -a "$LOG"; }
creative_info() { echo -e "${CYAN}[CREATIVE]${NC} $1" | tee -a "$LOG"; }

clear
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      CachyOS Complete Setup - All Features                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"

# ===== NVIDIA CLEANUP =====
log "Pre-check: NVIDIA conflicts..."
for p in linux-cachyos-nvidia-open nvidia-open lib32-nvidia-open media-dkms; do
    pacman -Qi "$p" &>/dev/null && sudo pacman -Rdd --noconfirm "$p" 2>/dev/null || true
done

# ===== SYSTEM UPDATE =====
log "System update..."
sudo pacman -Syu --noconfirm

# ===== NVIDIA DRIVERS =====
log "Installing NVIDIA proprietary drivers..."
sudo pacman -S --needed --noconfirm \
    nvidia-dkms nvidia-utils lib32-nvidia-utils \
    nvidia-settings opencl-nvidia lib32-opencl-nvidia \
    libva-nvidia-driver egl-wayland

if [ -f /etc/mkinitcpio.conf ]; then
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
        sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
        sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        sudo mkinitcpio -P &>/dev/null || true
    fi
fi

sudo mkdir -p /etc/modprobe.d
echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" | sudo tee -a /etc/modprobe.d/nvidia.conf >/dev/null

log "✓ NVIDIA"

# ===== BASE PACKAGES =====
log "Installing base packages..."
sudo pacman -S --needed --noconfirm \
    base-devel git wget curl yay fish \
    wl-clipboard xdg-desktop-portal-hyprland \
    qt5-wayland qt6-wayland \
    gnome-keyring polkit-gnome nautilus \
    gnome-disk-utility

log "✓ Base"

# ===== HYPRLAND CAELESTIA =====
log "Installing Hyprland Caelestia..."
if [ -d "$HOME/.local/share/caelestia" ]; then
    mv "$HOME/.local/share/caelestia" "$HOME/.local/share/caelestia.backup.$(date +%s)"
fi

if git clone --quiet https://github.com/caelestia-dots/caelestia.git "$HOME/.local/share/caelestia" 2>/dev/null; then
    cd "$HOME/.local/share/caelestia"
    
    if [ -f "install.fish" ]; then
        cp install.fish install.fish.backup
        sed -i '/nvidia-open/s/^/#/' install.fish
    fi
    
    command -v fish &>/dev/null || sudo pacman -S --needed --noconfirm fish
    fish ./install.fish --noconfirm --aur-helper=yay 2>&1 | tee -a "$LOG" || warn "Caelestia warnings"
    
    for p in linux-cachyos-nvidia-open nvidia-open lib32-nvidia-open; do
        pacman -Qi "$p" &>/dev/null && sudo pacman -Rdd --noconfirm "$p" 2>/dev/null || true
    done
fi

log "✓ Hyprland"

# ===== GAMING + DEV =====
log "Installing Gaming + Dev..."
sudo pacman -S --needed --noconfirm \
    cachyos-gaming-meta cachyos-gaming-applications \
    wine-staging \
    lib32-mangohud gamemode lib32-gamemode \
    dotnet-sdk dotnet-runtime aspnet-runtime mono mono-msbuild \
    code neovim docker docker-compose git github-cli

timeout 300 yay -S --noconfirm --needed rider || warn "Rider skip"
timeout 300 yay -S --noconfirm --needed microsoft-edge-stable-bin || warn "Edge skip"
timeout 300 yay -S --noconfirm --needed github-desktop || warn "GitHub Desktop skip"

sudo systemctl enable --now docker.service 2>/dev/null || true
sudo usermod -aG docker "$USER" 2>/dev/null || true

log "✓ Gaming + Dev"

# ===== UNREAL ENGINE DEPENDENCIES =====
log "Installing Unreal Engine dependencies..."
sudo pacman -S --needed --noconfirm \
    clang make cmake ninja vulkan-devel vulkan-tools \
    vulkan-validation-layers lib32-vulkan-icd-loader icu \
    openal lib32-openal libpulse lib32-libpulse \
    alsa-lib lib32-alsa-lib sdl2 lib32-sdl2 \
    libxcursor lib32-libxcursor libxi lib32-libxi \
    libxinerama lib32-libxinerama libxrandr lib32-libxrandr \
    libxss lib32-libxss libglvnd lib32-libglvnd \
    mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader \
    freetype2 lib32-freetype2 fontconfig lib32-fontconfig \
    harfbuzz lib32-harfbuzz curl lib32-curl \
    openssl lib32-openssl libidn lib32-libidn \
    zlib bzip2 lib32-bzip2 xz lib32-xz zstd lib32-zstd

timeout 300 yay -S --noconfirm --needed libicu50 || warn "libicu50 skip"

mkdir -p "$HOME/UnrealEngine"

log "✓ UE5 dependencies"

# ===== MULTIMEDIA =====
log "Installing multimedia..."
sudo pacman -S --needed --noconfirm \
    ffmpeg gstreamer gst-plugins-{base,good,bad,ugly} \
    libvorbis lib32-libvorbis opus lib32-opus flac lib32-flac \
    x264 x265 obs-studio

timeout 300 yay -S --noconfirm --needed lib32-ffmpeg || warn "lib32-ffmpeg skip"

log "✓ Multimedia"

# ===== AI/ML STACK =====
ai_info "Installing AI/ML Stack..."
sudo pacman -S --needed --noconfirm \
    cuda cudnn python-pytorch-cuda \
    python python-pip python-virtualenv \
    python-numpy python-pandas jupyter-notebook \
    python-scikit-learn python-matplotlib python-pillow

timeout 300 yay -S --noconfirm --needed ollama-cuda || {
    curl -fsSL https://ollama.com/install.sh | sh || warn "Ollama skip"
}

sudo systemctl enable --now ollama.service 2>/dev/null || true

timeout 300 yay -S --noconfirm --needed jan-bin || warn "Jan skip"
timeout 300 yay -S --noconfirm --needed koboldcpp-cuda || warn "Koboldcpp skip"

ai_info "✓ AI/ML Stack"

# ===== AI ENVIRONMENTS =====
ai_info "Setting up AI environments..."
mkdir -p "$HOME"/{AI-Projects,AI-Models}

# Stable Diffusion WebUI
if [ ! -d "$HOME/AI-Projects/stable-diffusion-webui" ]; then
    cd "$HOME/AI-Projects"
    git clone --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git 2>/dev/null || warn "SD WebUI skip"
fi

# Text Generation WebUI
if [ ! -d "$HOME/AI-Projects/text-generation-webui" ]; then
    cd "$HOME/AI-Projects"
    git clone --depth 1 https://github.com/oobabooga/text-generation-webui.git 2>/dev/null || warn "Text Gen WebUI skip"
fi

# ComfyUI
if [ ! -d "$HOME/AI-Projects/ComfyUI" ]; then
    cd "$HOME/AI-Projects"
    git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git 2>/dev/null || warn "ComfyUI skip"
fi

ai_info "✓ AI environments"

# ===== BLENDER =====
creative_info "Installing Blender with GPU optimization..."
sudo pacman -S --needed --noconfirm \
    blender openimagedenoise opencolorio opensubdiv \
    openvdb embree openimageio alembic openjpeg2 \
    openexr libspnav

mkdir -p "$HOME/.config/blender"

creative_info "✓ Blender"

# ===== CREATIVE SUITE =====
creative_info "Installing Creative Suite..."
sudo pacman -S --needed --noconfirm \
    gimp gimp-help-vi gimp-plugin-gmic gimp-nufraw \
    krita inkscape \
    kdenlive frei0r-plugins mediainfo mlt \
    audacity ardour scribus \
    darktable rawtherapee \
    imagemagick graphicsmagick potrace fontforge

timeout 300 yay -S --noconfirm --needed davinci-resolve || warn "DaVinci skip"
timeout 300 yay -S --noconfirm --needed natron || warn "Natron skip"

creative_info "✓ Creative Suite"

# ===== STREAMING =====
log "Installing streaming tools..."
sudo pacman -S --needed --noconfirm \
    v4l2loopback-dkms pipewire pipewire-pulse \
    pipewire-jack wireplumber gstreamer-vaapi

timeout 300 yay -S --noconfirm --needed obs-vkcapture || warn "obs-vkcapture skip"
timeout 300 yay -S --noconfirm --needed obs-websocket || warn "obs-websocket skip"
timeout 300 yay -S --noconfirm --needed vesktop-bin || warn "Vesktop skip"

sudo modprobe v4l2loopback 2>/dev/null || true
echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null

log "✓ Streaming"

# ===== SYSTEM OPTIMIZATION =====
log "System optimization..."
sudo pacman -S --needed --noconfirm cpupower
sudo systemctl enable --now cpupower.service

echo "governor='performance'" | sudo tee /etc/default/cpupower >/dev/null
sudo cpupower frequency-set -g performance 2>/dev/null || true

sudo tee /etc/sysctl.d/99-gaming.conf > /dev/null <<SYSCTL
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864
kernel.shmmax=68719476736
kernel.shmall=16777216
SYSCTL

sudo sysctl --system >/dev/null 2>&1 || true

log "✓ System optimization"

# ===== MULTI-MONITOR =====
log "Installing multi-monitor tools..."
sudo pacman -S --needed --noconfirm wlr-randr kanshi
timeout 300 yay -S --noconfirm --needed nwg-displays || warn "nwg-displays skip"

mkdir -p "$HOME/.config/hypr/scripts"

log "✓ Multi-monitor"

# ===== VIETNAMESE INPUT =====
log "Installing Vietnamese input..."
sudo pacman -S --needed --noconfirm \
    fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool

timeout 300 yay -S --noconfirm --needed fcitx5-bamboo-git || warn "Fcitx5 Bamboo skip"

mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/fcitx5.conf" <<FCITX
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=fcitx
FCITX

if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
    grep -q "fcitx5" "$HOME/.config/hypr/hyprland.conf" || \
        echo "exec-once = fcitx5 -d" >> "$HOME/.config/hypr/hyprland.conf"
fi

log "✓ Vietnamese input"

# ===== SDDM + SUGAR CANDY =====
log "Installing SDDM + Sugar Candy theme..."
sudo pacman -S --needed --noconfirm sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

sudo mkdir -p /usr/share/sddm/themes
cd /tmp
rm -rf sddm-sugar-candy
git clone --depth 1 https://github.com/Kangie/sddm-sugar-candy.git 2>/dev/null || warn "Sugar Candy clone skip"

if [ -d "sddm-sugar-candy" ]; then
    sudo cp -r sddm-sugar-candy /usr/share/sddm/themes/sugar-candy
fi

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<SDDM_CONF
[Theme]
Current=sugar-candy

[General]
DisplayServer=wayland

[Wayland]
SessionDir=/usr/share/wayland-sessions
SDDM_CONF

sudo systemctl enable sddm.service 2>/dev/null || true

log "✓ SDDM + Sugar Candy"

# ===== DIRECTORIES & WALLPAPERS =====
log "Creating directories & downloading wallpapers..."
mkdir -p "$HOME"/{Desktop,Documents,Downloads,Music,Videos}
mkdir -p "$HOME/Pictures/Wallpapers"
mkdir -p "$HOME"/{AI-Projects,AI-Models,Creative-Projects,Blender-Projects}
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/hypr/scripts"

if [ ! -d "$HOME/Pictures/Wallpapers/.git" ]; then
    git clone --depth 1 https://github.com/mylinuxforwork/wallpaper.git "$HOME/Pictures/Wallpapers" 2>/dev/null || \
        warn "Wallpapers skip"
fi

log "✓ Directories & wallpapers"

# ===== UTILITIES =====
log "Installing utilities..."
sudo pacman -S --needed --noconfirm \
    htop btop neofetch fastfetch \
    unzip p7zip unrar rsync tmux \
    starship eza bat ripgrep fd fzf zoxide \
    nvtop amdgpu_top iotop iftop

timeout 300 yay -S --noconfirm --needed openrgb || warn "OpenRGB skip"

log "✓ Utilities"

# ===== HELPER SCRIPTS =====
log "Creating ALL helper scripts..."
mkdir -p "$HOME/.local/bin"

# GPU check
cat > "$HOME/.local/bin/check-gpu" <<'HELPER_GPU'
#!/bin/bash
echo "=== NVIDIA GPU Status ==="
nvidia-smi
echo ""
echo "=== Vulkan Info ==="
vulkaninfo --summary 2>/dev/null || echo "Vulkaninfo not available"
echo ""
echo "=== OpenGL Info ==="
glxinfo | grep "OpenGL renderer" 2>/dev/null || echo "glxinfo not available"
HELPER_GPU
chmod +x "$HOME/.local/bin/check-gpu"

# RGB control
cat > "$HOME/.local/bin/rgb-control" <<'HELPER_RGB'
#!/bin/bash
openrgb
HELPER_RGB
chmod +x "$HOME/.local/bin/rgb-control"

# Game mode
cat > "$HOME/.local/bin/game-mode-on" <<'HELPER_GAME_ON'
#!/bin/bash
echo "Enabling gaming optimizations..."
sudo cpupower frequency-set -g performance
sudo sysctl vm.swappiness=1
echo "Gaming mode enabled!"
HELPER_GAME_ON
chmod +x "$HOME/.local/bin/game-mode-on"

cat > "$HOME/.local/bin/game-mode-off" <<'HELPER_GAME_OFF'
#!/bin/bash
echo "Disabling gaming optimizations..."
sudo cpupower frequency-set -g schedutil
sudo sysctl vm.swappiness=10
echo "Gaming mode disabled!"
HELPER_GAME_OFF
chmod +x "$HOME/.local/bin/game-mode-off"

# Blender GPU
cat > "$HOME/.local/bin/blender-gpu" <<'HELPER_BLENDER_GPU'
#!/bin/bash
export CYCLES_CUDA_EXTRA_CFLAGS="-DCUDA_ENABLE_DEPRECATED_COMPUTE_TARGET"
blender "$@"
HELPER_BLENDER_GPU
chmod +x "$HOME/.local/bin/blender-gpu"

# Blender setup guide
cat > "$HOME/.local/bin/blender-setup-gpu" <<'HELPER_BLENDER_SETUP'
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
HELPER_BLENDER_SETUP
chmod +x "$HOME/.local/bin/blender-setup-gpu"

# Blender render
cat > "$HOME/.local/bin/blender-render" <<'HELPER_BLENDER_RENDER'
#!/bin/bash
if [ $# -lt 1 ]; then
    echo "Usage: blender-render <file.blend> [output-dir] [start-frame] [end-frame]"
    exit 1
fi
BLEND_FILE="$1"
OUTPUT_DIR="${2:-.}"
START_FRAME="${3:-1}"
END_FRAME="${4:-1}"
mkdir -p "$OUTPUT_DIR"
echo "Rendering with GPU..."
blender -b "$BLEND_FILE" -o "$OUTPUT_DIR/frame_####" -s "$START_FRAME" -e "$END_FRAME" -a -- --cycles-device OPTIX
HELPER_BLENDER_RENDER
chmod +x "$HOME/.local/bin/blender-render"

# AI workspace
cat > "$HOME/.local/bin/ai-workspace" <<'HELPER_AI_WS'
#!/bin/bash
echo "=== AI/ML Workspace ==="
echo ""
echo "📁 Directories:"
echo "  - AI Projects: $HOME/AI-Projects"
echo "  - AI Models: $HOME/AI-Models"
echo ""
echo "🤖 Tools:"
echo "  - Ollama: ollama-start"
echo "  - Stable Diffusion: sd-webui"
echo "  - Text Generation: text-gen-webui"
echo "  - ComfyUI: comfyui"
echo ""
echo "📊 Commands:"
echo "  - Check setup: check-ai-setup"
echo "  - Monitor VRAM: monitor-vram"
echo "  - Download models: ollama-download-recommended"
HELPER_AI_WS
chmod +x "$HOME/.local/bin/ai-workspace"

# Check AI setup
cat > "$HOME/.local/bin/check-ai-setup" <<'HELPER_AI_CHECK'
#!/bin/bash
echo "=== CUDA Check ==="
nvcc --version
echo ""
echo "=== PyTorch CUDA Check ==="
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA Available: {torch.cuda.is_available()}'); print(f'Device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
echo ""
echo "=== Ollama Service ==="
systemctl status ollama.service --no-pager 2>/dev/null || echo "Ollama not running"
HELPER_AI_CHECK
chmod +x "$HOME/.local/bin/check-ai-setup"

# Monitor VRAM
cat > "$HOME/.local/bin/monitor-vram" <<'HELPER_VRAM'
#!/bin/bash
watch -n 1 'nvidia-smi --query-gpu=utilization.gpu,utilization.memory,memory.used,memory.free,memory.total,temperature.gpu --format=csv,noheader,nounits | awk -F, "{printf \"GPU: %s%% | VRAM: %s%% | Used: %sMB | Free: %sMB | Total: %sMB | Temp: %s°C\n\", \$1, \$2, \$3, \$4, \$5, \$6}"'
HELPER_VRAM
chmod +x "$HOME/.local/bin/monitor-vram"

# Ollama commands
cat > "$HOME/.local/bin/ollama-start" <<'HELPER_OLLAMA_START'
#!/bin/bash
sudo systemctl start ollama.service
echo "Ollama started. Usage: ollama run <model>"
HELPER_OLLAMA_START
chmod +x "$HOME/.local/bin/ollama-start"

cat > "$HOME/.local/bin/ollama-download-recommended" <<'HELPER_OLLAMA_DL'
#!/bin/bash
echo "Downloading recommended models for RTX 3060 12GB..."
ollama pull llama3.2:3b
ollama pull mistral:7b
ollama pull codellama:7b
echo "Models downloaded!"
HELPER_OLLAMA_DL
chmod +x "$HOME/.local/bin/ollama-download-recommended"

# AI WebUI launchers
cat > "$HOME/.local/bin/sd-webui" <<'HELPER_SD'
#!/bin/bash
[ -d "$HOME/AI-Projects/stable-diffusion-webui" ] && cd "$HOME/AI-Projects/stable-diffusion-webui" && ./webui.sh --xformers --api || echo "Not installed"
HELPER_SD
chmod +x "$HOME/.local/bin/sd-webui"

cat > "$HOME/.local/bin/text-gen-webui" <<'HELPER_TEXTGEN'
#!/bin/bash
[ -d "$HOME/AI-Projects/text-generation-webui" ] && cd "$HOME/AI-Projects/text-generation-webui" && source venv/bin/activate && python server.py --listen --api || echo "Not installed"
HELPER_TEXTGEN
chmod +x "$HOME/.local/bin/text-gen-webui"

cat > "$HOME/.local/bin/comfyui" <<'HELPER_COMFY'
#!/bin/bash
[ -d "$HOME/AI-Projects/ComfyUI" ] && cd "$HOME/AI-Projects/ComfyUI" && source venv/bin/activate && python main.py --listen 0.0.0.0 || echo "Not installed"
HELPER_COMFY
chmod +x "$HOME/.local/bin/comfyui"

# Creative apps overview
cat > "$HOME/.local/bin/creative-apps" <<'HELPER_CREATIVE'
#!/bin/bash
echo "=== Creative Suite ==="
echo ""
echo "🎨 Image: gimp, krita, darktable, rawtherapee"
echo "🎬 Video: kdenlive, davinci-resolve (if installed)"
echo "✏️ Vector: inkscape, scribus"
echo "🎵 Audio: audacity, ardour"
echo "🔮 3D: blender-gpu, blender-setup-gpu"
HELPER_CREATIVE
chmod +x "$HOME/.local/bin/creative-apps"

# Image converter
cat > "$HOME/.local/bin/batch-convert-images" <<'HELPER_CONVERT'
#!/bin/bash
[ $# -lt 2 ] && echo "Usage: batch-convert-images <in-fmt> <out-fmt> [quality]" && exit 1
for file in *."$1"; do
    [ -f "$file" ] && convert "$file" -quality "${3:-95}" "${file%.*}.$2"
done
HELPER_CONVERT
chmod +x "$HOME/.local/bin/batch-convert-images"

# Video transcode
cat > "$HOME/.local/bin/video-transcode" <<'HELPER_VIDEO'
#!/bin/bash
[ $# -lt 2 ] && echo "Usage: video-transcode <input> <output> [preset]" && exit 1
ffmpeg -hwaccel cuda -i "$1" -c:v h264_nvenc -preset "${3:-medium}" -b:v 10M -c:a aac -b:a 192k "$2"
HELPER_VIDEO
chmod +x "$HOME/.local/bin/video-transcode"

# UE5 launcher
cat > "$HOME/.local/bin/ue5" <<'HELPER_UE5'
#!/bin/bash
if [ -f "$HOME/UnrealEngine/Engine/Binaries/Linux/UnrealEditor" ]; then
    cd "$HOME/UnrealEngine"
    ./Engine/Binaries/Linux/UnrealEditor "$@"
else
    echo "UE5 not installed. Download from: https://www.unrealengine.com/linux"
fi
HELPER_UE5
chmod +x "$HOME/.local/bin/ue5"

# Backup configs
cat > "$HOME/.local/bin/backup-configs" <<'HELPER_BACKUP'
#!/bin/bash
BACKUP_DIR="$HOME/Documents/config-backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r ~/.config/hypr "$BACKUP_DIR/" 2>/dev/null
cp -r ~/.config/fcitx5 "$BACKUP_DIR/" 2>/dev/null
cp -r ~/.config/blender "$BACKUP_DIR/" 2>/dev/null
echo "Backed up to: $BACKUP_DIR"
HELPER_BACKUP
chmod +x "$HOME/.local/bin/backup-configs"

# Add to PATH
grep -q ".local/bin" "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

log "✓ Helper scripts created"

# ===== DESKTOP ENTRIES =====
mkdir -p "$HOME/.local/share/applications"

cat > "$HOME/.local/share/applications/blender-gpu.desktop" <<DESKTOP_BLENDER
[Desktop Entry]
Type=Application
Name=Blender (GPU Optimized)
Comment=3D Creation Suite with CUDA/OptiX
Exec=$HOME/.local/bin/blender-gpu %f
Icon=blender
Terminal=false
Categories=Graphics;3DGraphics;
MimeType=application/x-blender;
DESKTOP_BLENDER

cat > "$HOME/.local/share/applications/unreal-engine.desktop" <<DESKTOP_UE5
[Desktop Entry]
Type=Application
Name=Unreal Engine 5
Comment=Game Development Platform
Exec=$HOME/.local/bin/ue5
Icon=unreal-engine
Terminal=false
Categories=Development;IDE;
DESKTOP_UE5

log "✓ Desktop entries"

# ===== DONE =====
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✓ INSTALLATION COMPLETED SUCCESSFULLY!           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Installed Features:${NC}"
echo "  ✓ NVIDIA proprietary drivers (CUDA + OptiX)"
echo "  ✓ Hyprland Caelestia desktop"
echo "  ✓ Gaming suite (Steam, Lutris, Wine, MangoHud)"
echo "  ✓ C# Development (dotnet, Rider, VS Code)"
echo "  ✓ Unreal Engine 5 dependencies"
echo "  ✓ AI/ML stack (Ollama, Stable Diffusion, Text Gen, ComfyUI)"
echo "  ✓ Blender with GPU optimization"
echo "  ✓ Creative Suite (GIMP, Inkscape, Kdenlive, etc.)"
echo "  ✓ Streaming tools (OBS, Vesktop)"
echo "  ✓ Multi-monitor support"
echo "  ✓ Vietnamese input (Fcitx5 Bamboo)"
echo "  ✓ SDDM + Sugar Candy theme"
echo "  ✓ Wallpapers collection"
echo "  ✓ System optimizations"
echo "  ✓ All helper scripts"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. ${GREEN}sudo reboot${NC}"
echo "  2. Login to Hyprland from SDDM"
echo "  3. Check GPU: ${BLUE}nvidia-smi${NC}"
echo "  4. View apps: ${BLUE}creative-apps${NC}, ${BLUE}ai-workspace${NC}"
echo "  5. Setup Blender GPU: ${BLUE}blender-setup-gpu${NC}"
echo "  6. Vietnamese input: ${BLUE}fcitx5-configtool${NC} (Ctrl+Space to toggle)"
echo ""
echo "Logs: $LOG"
echo ""
COMPLETE_SETUP

chmod +x "$INSTALL_DIR/setup-complete.sh"

# Run setup
echo ""
log "Running complete setup (30-60 minutes)..."
echo ""
read -p "Press Enter to start or Ctrl+C to cancel..."
echo ""

bash "$INSTALL_DIR/setup-complete.sh" || error "Setup failed"

# Done
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      ✓ COMPLETE INSTALLATION FINISHED SUCCESSFULLY!           ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Logs:"
echo "  - $LOG_FILE"
echo "  - $HOME/setup_complete_*.log"
echo ""
echo -e "${YELLOW}${GREEN}sudo reboot${NC} to complete installation"
echo ""
