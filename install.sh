#!/bin/bash

# Quick Install Script for CachyOS Auto Setup
# Usage: curl -fsSL https://raw.githubusercontent.com/hoangducdt/caelestia/main/install.sh | bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/hoangducdt/caelestia.git"
INSTALL_DIR="$HOME/cachyos-autosetup"

echo -e "${GREEN}"
cat << "EOF"
╭───────────────────────────────────────────────────────────────────╮
│               ______           __          __  _                  │
│              / ____/___ ____  / /__  _____/ /_(_)___ _            │
│             / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/            │
│            / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /             │
│            \____/\__,_/\___/_/\___/____/\__/_/\__,_/              │
│                                                                   │
│   Gaming Setup for: ROG STRIX B550-XE │ Ryzen 7 5800X │ RTX 3060  │
╰───────────────────────────────────────────────────────────────────╯
EOF
echo -e "${NC}"

# Kiểm tra OS
if [ ! -f /etc/os-release ] || ! grep -q "CachyOS" /etc/os-release; then
    echo -e "${YELLOW}Warning: This script is designed for CachyOS.${NC}"
    echo -e "${YELLOW}Continue at your own risk.${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Kiểm tra quyền root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: Do not run this script as root.${NC}"
    exit 1
fi

# Cài đặt git nếu chưa có
if ! command -v git &> /dev/null; then
    echo -e "${BLUE}Installing git...${NC}"
    sudo pacman -S --needed --noconfirm git
fi

# Clone hoặc update repository
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${BLUE}Updating existing repository...${NC}"
    cd "$INSTALL_DIR"
    git pull
else
    echo -e "${BLUE}Cloning repository...${NC}"
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Kiểm tra setup script
if [ ! -f "setup.sh" ]; then
    echo -e "${RED}Error: setup.sh not found in repository.${NC}"
    exit 1
fi

# Chạy setup script
chmod +x setup.sh

echo ""
echo -e "${GREEN}Starting full system setup...${NC}"
echo -e "${YELLOW}This will take 15-30 minutes depending on your internet speed.${NC}"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

./setup.sh

echo ""
echo -e "${GREEN}Installation completed!${NC}"
echo -e "${BLUE}Please reboot your system: sudo reboot${NC}"