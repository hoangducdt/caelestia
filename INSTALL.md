# 🚀 Quick Installation Guide

## One-Command Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/hoangducdt/caelestia/main/setup-caelestia-ultimate.sh | bash
```

## Step-by-Step Install

### 1. Install Arch Linux
```bash
archinstall
```

### 2. Run installer
```bash
wget https://raw.githubusercontent.com/hoangducdt/caelestia/main/setup-caelestia-ultimate.sh
chmod +x setup-caelestia-ultimate.sh
./setup-caelestia-ultimate.sh
```

### 3. Reboot
```bash
sudo reboot
```

## After Reboot

### Configure Vietnamese Input
```bash
fcitx5-configtool
```
Add "Bamboo" to Input Method

### Test Everything
```bash
uname -r                # Check kernel
nvidia-smi              # Check GPU
sensors                 # Check temps
lg-brightness 70        # Test monitors
openrgb                 # RGB control
rog-control-center      # ROG features
```

---

**That's it! Full documentation in [README.md](README.md)**