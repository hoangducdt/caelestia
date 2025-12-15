#!/bin/bash

# Fix script cho lỗi xung đột NVIDIA drivers
# Giải quyết xung đột giữa nvidia-utils và nvidia-open

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║              NVIDIA Driver Conflict Fixer                     ║
║         Giải quyết xung đột nvidia-utils vs nvidia-open       ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: Không chạy script này với quyền root.${NC}"
    exit 1
fi

echo -e "${BLUE}Bước 1: Xóa các gói NVIDIA đang xung đột...${NC}"

# Xóa tất cả các gói nvidia-open nếu có
sudo pacman -Rdd --noconfirm linux-cachyos-lts-nvidia-open 2>/dev/null || true
sudo pacman -Rdd --noconfirm nvidia-open 2>/dev/null || true
sudo pacman -Rdd --noconfirm lib32-nvidia-open 2>/dev/null || true

# Xóa media-dkms package gây conflict
sudo pacman -Rdd --noconfirm media-dkms-500.119.02-2 2>/dev/null || true

echo -e "${GREEN}✓ Đã xóa các gói xung đột${NC}"

echo -e "${BLUE}Bước 2: Cài đặt NVIDIA proprietary drivers (khuyến nghị cho RTX 3060)...${NC}"

# Cài đặt nvidia-dkms và các dependencies chuẩn
sudo pacman -S --needed --noconfirm \
    nvidia-dkms \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings \
    opencl-nvidia \
    lib32-opencl-nvidia \
    libva-nvidia-driver \
    egl-wayland

echo -e "${GREEN}✓ Đã cài đặt NVIDIA proprietary drivers${NC}"

echo -e "${BLUE}Bước 3: Cấu hình kernel modules...${NC}"

# Thêm nvidia modules vào mkinitcpio
if [ -f /etc/mkinitcpio.conf ]; then
    sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
fi

echo -e "${GREEN}✓ Đã cấu hình kernel modules${NC}"

echo -e "${BLUE}Bước 4: Cấu hình Wayland support...${NC}"

# Thêm modprobe options cho nvidia
sudo mkdir -p /etc/modprobe.d
sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOF
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

echo -e "${GREEN}✓ Đã cấu hình Wayland support${NC}"

echo -e "${BLUE}Bước 5: Kiểm tra cài đặt...${NC}"

# Kiểm tra các package đã cài
if pacman -Qi nvidia-dkms &>/dev/null && pacman -Qi nvidia-utils &>/dev/null; then
    echo -e "${GREEN}✓ NVIDIA drivers đã được cài đặt thành công!${NC}"
    nvidia-smi 2>/dev/null || echo -e "${YELLOW}Note: nvidia-smi sẽ hoạt động sau khi reboot${NC}"
else
    echo -e "${RED}✗ Có lỗi trong quá trình cài đặt${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Fix hoàn tất!                              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Các bước tiếp theo:${NC}"
echo "  1. Reboot hệ thống: ${BLUE}sudo reboot${NC}"
echo "  2. Sau khi reboot, kiểm tra GPU: ${BLUE}nvidia-smi${NC}"
echo "  3. Tiếp tục chạy script setup.sh nếu bị dừng: ${BLUE}cd ~/cachyos-autosetup && ./setup.sh${NC}"
echo ""
echo -e "${YELLOW}Thông tin:${NC}"
echo "  - Driver: NVIDIA proprietary (khuyến nghị cho RTX 3060)"
echo "  - CUDA support: Có"
echo "  - Wayland support: Có (modeset=1)"
echo "  - OptiX support: Có (cho Blender rendering)"
echo ""
