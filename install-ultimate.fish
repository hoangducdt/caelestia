#!/usr/bin/env fish

argparse -n 'install.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'spotify' \
    'vscode=?!contains -- "$_flag_value" codium code' \
    'discord' \
    'zen' \
    'full-setup' \
    'skip-cachyos' \
    'skip-gaming' \
    'aur-helper=!contains -- "$_flag_value" yay paru' \
    -- $argv
or exit

# Print help
if set -q _flag_h
    echo 'usage: ./install.fish [-h] [--noconfirm] [--spotify] [--vscode] [--discord] [--zen] [--full-setup] [--skip-cachyos] [--skip-gaming] [--aur-helper]'
    echo
    echo 'options:'
    echo '  -h, --help                  show this help message and exit'
    echo '  --noconfirm                 do not confirm package installation'
    echo '  --spotify                   install Spotify (Spicetify)'
    echo '  --vscode=[codium|code]      install VSCodium (or VSCode)'
    echo '  --discord                   install Discord (OpenAsar + Equicord)'
    echo '  --zen                       install Zen browser'
    echo '  --full-setup                install full gaming setup (CachyOS, Nvidia, ROG, Gaming)'
    echo '  --skip-cachyos              skip CachyOS kernel installation'
    echo '  --skip-gaming               skip gaming optimizations'
    echo '  --aur-helper=[yay|paru]     the AUR helper to use'

    exit
end


# Helper funcs
function _out -a colour text
    set_color $colour
    # Pass arguments other than text to echo
    echo $argv[3..] -- ":: $text"
    set_color normal
end

function log -a text
    _out cyan $text $argv[2..]
end

function input -a text
    _out blue $text $argv[2..]
end

function warn -a text
    _out yellow $text $argv[2..]
end

function error -a text
    _out red $text $argv[2..]
end

function sh-read
    sh -c 'read a && echo -n "$a"' || exit 1
end

function confirm-overwrite -a path
    if test -e $path -o -L $path
        # No prompt if noconfirm
        if set -q noconfirm
            input "$path already exists. Overwrite? [Y/n]"
            log 'Removing...'
            rm -rf $path
        else
            # Prompt user
            input "$path already exists. Overwrite? [Y/n] " -n
            set -l confirm (sh-read)

            if test "$confirm" = 'n' -o "$confirm" = 'N'
                log 'Skipping...'
                return 1
            else
                log 'Removing...'
                rm -rf $path
            end
        end
    end

    return 0
end


# Variables
set -q _flag_noconfirm && set noconfirm '--noconfirm'
set -q _flag_aur_helper && set -l aur_helper $_flag_aur_helper || set -l aur_helper paru
set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME || set -l config $HOME/.config
set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state

# Startup prompt
set_color magenta
echo '╭─────────────────────────────────────────────────╮'
echo '│      ______           __          __  _         │'
echo '│     / ____/___ ____  / /__  _____/ /_(_)___ _   │'
echo '│    / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/   │'
echo '│   / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /    │'
echo '│   \____/\__,_/\___/_/\___/____/\__/_/\__,_/     │'
echo '│                                                 │'
echo '│   Gaming Setup for:                             │'
echo '│                            ROG STRIX B550-XE    │'
echo '│                            Ryzen 7 5800X        │'
echo '│                            RTX 3060 12GB        │'
echo '╰─────────────────────────────────────────────────╯'
set_color normal
log 'Welcome to the Caelestia Ultimate Gaming installer!'
log 'Before continuing, please ensure you have made a backup of your config directory.'

# Prompt for backup
if ! set -q _flag_noconfirm
    log '[1] Two steps ahead of you!  [2] Make one for me please!'
    input '=> ' -n
    set -l choice (sh-read)

    if contains -- "$choice" 1 2
        if test $choice = 2
            log "Backing up $config..."

            if test -e $config.bak -o -L $config.bak
                input 'Backup already exists. Overwrite? [Y/n] ' -n
                set -l overwrite (sh-read)

                if test "$overwrite" = 'n' -o "$overwrite" = 'N'
                    log 'Skipping...'
                else
                    rm -rf $config.bak
                    cp -r $config $config.bak
                end
            else
                cp -r $config $config.bak
            end
        end
    else
        log 'No choice selected. Exiting...'
        exit 1
    end
end


# ============================================================================
# FULL SETUP MODE
# ============================================================================

if set -q _flag_full_setup
    warn 'Running FULL SETUP mode...'
    warn 'This will install: CachyOS kernel, Nvidia drivers, ROG tools, Gaming optimizations'
    
    if ! set -q _flag_noconfirm
        input 'Continue? [Y/n] ' -n
        set -l confirm (sh-read)
        if test "$confirm" = 'n' -o "$confirm" = 'N'
            log 'Aborting...'
            exit 1
        end
    end

    # Update system
    log 'Updating system...'
    sudo pacman -Syu $noconfirm

    # Install base tools
    log 'Installing base development tools...'
    sudo pacman -S --needed $noconfirm git wget curl gcc make cmake nano vim base-devel ninja

    # ========== CACHYOS SETUP ==========
    if ! set -q _flag_skip_cachyos
        log 'Setting up CachyOS repositories...'
        
        if ! test -d /tmp/cachyos-repo
            cd /tmp
            wget -q https://mirror.cachyos.org/cachyos-repo.tar.xz
            tar xf cachyos-repo.tar.xz
            cd cachyos-repo
            sudo ./cachyos-repo.sh
            cd /tmp
        end

        # Add repos to pacman.conf if not exists
        if ! grep -q "cachyos" /etc/pacman.conf
            log 'Adding CachyOS repos to pacman.conf...'
            sudo sed -i '/^\[core\]/i \
# CachyOS repos\n\
[cachyos-v3]\n\
Include = /etc/pacman.d/cachyos-v3-mirrorlist\n\
\n\
[cachyos-core-v3]\n\
Include = /etc/pacman.d/cachyos-v3-mirrorlist\n\
\n\
[cachyos-extra-v3]\n\
Include = /etc/pacman.d/cachyos-v3-mirrorlist\n\
\n\
[cachyos]\n\
Include = /etc/pacman.d/cachyos-mirrorlist\n' /etc/pacman.conf
        end

        log 'Updating package database...'
        sudo pacman -Sy

        # Install yay if using yay and not installed
        if test "$aur_helper" = "yay"
            if ! pacman -Q yay &> /dev/null
                log 'Installing yay from CachyOS repos...'
                sudo pacman -S --needed $noconfirm yay
            end
        end

        # ========== AMD RYZEN 5800X OPTIMIZATIONS ==========
        log 'Installing AMD Ryzen optimizations...'
        sudo pacman -S --needed $noconfirm amd-ucode cpupower lm_sensors

        log 'Configuring CPU governor...'
        echo 'GOVERNOR="schedutil"' | sudo tee /etc/default/cpupower
        sudo systemctl enable cpupower
        sudo systemctl start cpupower

        log 'Detecting sensors...'
        yes | sudo sensors-detect

        log 'Applying Ryzen sysctl optimizations...'
        sudo tee /etc/sysctl.d/99-ryzen-optimizations.conf > /dev/null << 'EOF'
kernel.sched_autogroup_enabled = 1
kernel.sched_cfs_bandwidth_slice_us = 500
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.page-cluster = 0
EOF

        # ========== CACHYOS BORE KERNEL ==========
        log 'Installing CachyOS BORE kernel...'
        sudo pacman -S --needed $noconfirm linux-cachyos-bore linux-cachyos-bore-headers

        # Remove old kernel
        if pacman -Q linux &> /dev/null
            if ! set -q _flag_noconfirm
                warn 'Remove old linux kernel? [Y/n] ' -n
                set -l remove_kernel (sh-read)
                if test "$remove_kernel" != 'n' -a "$remove_kernel" != 'N'
                    sudo pacman -Rs --noconfirm linux linux-headers || true
                end
            else
                sudo pacman -Rs --noconfirm linux linux-headers || true
            end
        end

        # ========== NVIDIA RTX 3060 SETUP ==========
        log 'Installing Nvidia open-source driver...'
        sudo pacman -S --needed $noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

        log 'Configuring Nvidia...'
        sudo tee /etc/modprobe.d/nvidia.conf > /dev/null << 'EOF'
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_InitializeSystemMemoryAllocations=0
options nvidia NVreg_EnableGpuFirmware=0
EOF

        log 'Configuring mkinitcpio...'
        sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

        log 'Configuring GRUB...'
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amd_pstate=active amd_iommu=on iommu=pt"/' /etc/default/grub

        log 'Rebuilding initramfs...'
        sudo mkinitcpio -P

        log 'Updating GRUB...'
        sudo grub-mkconfig -o /boot/grub/grub.cfg

        # ========== CACHYOS OPTIMIZATIONS ==========
        log 'Installing CachyOS optimizations...'
        sudo pacman -S --needed $noconfirm cachyos-settings ananicy-cpp cachyos-ananicy-rules cachyos-kernel-manager

        log 'Enabling ananicy...'
        sudo systemctl enable ananicy-cpp
        sudo systemctl start ananicy-cpp

        log 'Setting up zram...'
        sudo pacman -S --needed $noconfirm zram-generator
        echo -e "[zram0]\nzram-size = ram / 2" | sudo tee /etc/systemd/zram-generator.conf
        sudo systemctl daemon-reload

        log 'Optimizing I/O scheduler...'
        echo 'ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*|nvme[0-9]*", ATTR{queue/scheduler}="bfq"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules

        log 'Installing CachyOS rate mirrors...'
        $aur_helper -S --needed $noconfirm cachyos-rate-mirrors || true

        # ========== ROG STRIX B550-XE SPECIFIC ==========
        log 'Setting up ROG STRIX B550-XE features...'
        
        log 'Installing WiFi 6E firmware...'
        sudo pacman -S --needed $noconfirm linux-firmware
        $aur_helper -S --needed $noconfirm iwlwifi-firmware-git || true

        log 'Setting up Bluetooth...'
        sudo pacman -S --needed $noconfirm bluez bluez-utils blueman
        sudo systemctl enable bluetooth

        log 'Setting up PipeWire audio...'
        sudo pacman -S --needed $noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber sof-firmware alsa-firmware alsa-ucm-conf easyeffects
        systemctl --user enable pipewire pipewire-pulse wireplumber

        log 'Installing OpenRGB for Aura Sync...'
        $aur_helper -S --needed $noconfirm openrgb || true

        sudo tee /etc/udev/rules.d/60-openrgb.rules > /dev/null << 'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ATTR{idProduct}=="1939", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", MODE="0666"
SUBSYSTEM=="i2c-dev", MODE="0666"
EOF

        sudo tee /etc/modules-load.d/i2c.conf > /dev/null << 'EOF'
i2c-dev
i2c-i801
EOF

        sudo udevadm control --reload-rules
        sudo udevadm trigger
        sudo modprobe i2c-dev
        sudo modprobe i2c-i801

        log 'Installing ASUS EC sensors...'
        $aur_helper -S --needed $noconfirm asus-ec-sensors-dkms-git || true
        echo "asus_ec_sensors" | sudo tee /etc/modules-load.d/asus-ec-sensors.conf

        log 'Installing fwupd for BIOS updates...'
        sudo pacman -S --needed $noconfirm fwupd

        log 'Installing asusctl (ROG Control Center)...'
        $aur_helper -S --needed $noconfirm asusctl rog-control-center || true
        sudo systemctl enable asusd

        log 'Fixing Intel I225-V LAN...'
        echo "options e1000e EEE=0" | sudo tee /etc/modprobe.d/i225.conf

        # ========== MULTI-MONITOR SETUP ==========
        log 'Setting up dual monitor tools...'
        sudo pacman -S --needed $noconfirm wlr-randr kanshi swayidle
        $aur_helper -S --needed $noconfirm nwg-displays ddcui monitorcontrol || true

        log 'Configuring DDC/CI...'
        sudo usermod -aG i2c $USER

        sudo tee /etc/udev/rules.d/45-ddcutil-i2c.rules > /dev/null << 'EOF'
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
EOF

        sudo udevadm control --reload-rules
        sudo udevadm trigger

        log 'Creating brightness control script...'
        sudo tee /usr/local/bin/lg-brightness > /dev/null << 'EOF'
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: lg-brightness <0-100>"
    exit 1
fi
ddcutil --bus 8 setvcp 10 "$1" 2>/dev/null || true
ddcutil --bus 9 setvcp 10 "$1" 2>/dev/null || true
echo "Brightness set to $1%"
EOF
        sudo chmod +x /usr/local/bin/lg-brightness

        log 'Configuring kanshi for auto-monitor detection...'
        mkdir -p $config/kanshi
        tee $config/kanshi/config > /dev/null << 'EOF'
profile dual {
    output DP-1 mode 2560x1440@144Hz position 0,0 scale 1
    output DP-2 mode 1920x1080@60Hz position 2560,0 scale 1
}
EOF
        systemctl --user enable kanshi

        log 'Configuring gammastep...'
        mkdir -p $config/gammastep
        tee $config/gammastep/config.ini > /dev/null << 'EOF'
[general]
temp-day=6500
temp-night=3500
fade=1
gamma=0.8
adjustment-method=wayland
location-provider=manual

[manual]
lat=10.8
lon=106.6
EOF

    end  # End of skip-cachyos check

    # ========== GAMING OPTIMIZATIONS ==========
    if ! set -q _flag_skip_gaming
        log 'Installing gaming optimizations...'
        
        log 'Installing gaming packages...'
        sudo pacman -S --needed $noconfirm gamemode lib32-gamemode wine-staging winetricks dxvk-bin vkd3d

        log 'Configuring GameMode...'
        mkdir -p $config
        tee $config/gamemode.ini > /dev/null << 'EOF'
[general]
renice=10
ioprio=0

[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0

[cpu]
cpu_governor=performance
EOF

        log 'Creating game mode script...'
        sudo tee /usr/local/bin/game-mode > /dev/null << 'EOF'
#!/bin/bash
if [ "$1" = "on" ]; then
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
    echo "Game mode ON - Performance governor active"
else
    echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
    echo "Game mode OFF - Schedutil governor active"
fi
EOF
        sudo chmod +x /usr/local/bin/game-mode

        log 'Installing GPU screen recorder...'
        $aur_helper -S --needed $noconfirm gpu-screen-recorder || true

    end  # End of skip-gaming check

    # ========== ADDITIONAL DEPENDENCIES ==========
    log 'Installing additional tools and dependencies...'
    sudo pacman -S --needed $noconfirm \
        gnome-keyring polkit-gnome nautilus gnome-disk-utility \
        gsettings-desktop-schemas gparted gammastep geoclue bluez-utils \
        seahorse libsecret capitaine-cursors qt6ct qt5ct micro pavucontrol mpv \
        swappy grim slurp libqalculate libcava aubio libpipewire libnotify \
        dart-sass fuzzel glib2 python-build python-installer python-hatch \
        python-hatch-vcs ddcutil brightnessctl networkmanager lm_sensors \
        thunar-archive-plugin thunar-media-tags-plugin thunar-volman \
        tumbler ffmpegthumbnailer copyq nm-connection-editor font-manager \
        p7zip unrar unzip zip

    log 'Installing additional fonts...'
    $aur_helper -S --needed $noconfirm ttf-material-symbols-git nerd-fonts-caskaydia-cove || true

    # ========== SDDM + SUGAR CANDY ==========
    log 'Installing SDDM display manager...'
    sudo pacman -S --needed $noconfirm sddm
    $aur_helper -S --needed $noconfirm sddm-sugar-candy-git || true

    sudo mkdir -p /etc/sddm.conf.d
    echo -e "[Theme]\nCurrent=sugar-candy" | sudo tee /etc/sddm.conf.d/theme.conf
    sudo systemctl enable sddm

    # ========== FCITX5 VIETNAMESE INPUT ==========
    log 'Installing Fcitx5 for Vietnamese input...'
    sudo pacman -S --needed $noconfirm fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool
    $aur_helper -S --needed $noconfirm fcitx5-bamboo || true

    # ========== WALLPAPERS ==========
    log 'Setting up wallpapers...'
    mkdir -p $HOME/Pictures/Wallpapers
    if ! test -d $HOME/Pictures/Wallpapers/wallpaper
        git clone https://github.com/mylinuxforwork/wallpaper.git $HOME/Pictures/Wallpapers/wallpaper
    end

    # Apply sysctl
    log 'Applying sysctl optimizations...'
    sudo sysctl --system

    log 'Full setup completed!'
    warn 'System will need to REBOOT after Caelestia installation to load new kernel and drivers.'

end  # End of full-setup


# ============================================================================
# STANDARD CAELESTIA INSTALLATION
# ============================================================================

# Install AUR helper if not already installed
if ! pacman -Q $aur_helper &> /dev/null
    log "$aur_helper not installed. Installing..."

    # Install
    sudo pacman -S --needed git base-devel $noconfirm
    cd /tmp
    git clone https://aur.archlinux.org/$aur_helper.git
    cd $aur_helper
    makepkg -si
    cd ..
    rm -rf $aur_helper

    # Setup
    if test $aur_helper = yay
        $aur_helper -Y --gendb
        $aur_helper -Y --devel --save
    else
        $aur_helper --gendb
    end
end

# Cd into dir
cd (dirname (status filename)) || exit 1

# Install metapackage for deps
log 'Installing metapackage...'
if test $aur_helper = yay
    $aur_helper -Bi . $noconfirm
else
    $aur_helper -Ui $noconfirm
end
fish -c 'rm -f caelestia-meta-*.pkg.tar.zst' 2> /dev/null

# Install hypr* configs
if confirm-overwrite $config/hypr
    log 'Installing hypr* configs...'
    ln -s (realpath hypr) $config/hypr
    
    # Create monitors.conf if full-setup was run
    if set -q _flag_full_setup
        log 'Creating monitors.conf for dual LG setup...'
        tee $config/hypr/monitors.conf > /dev/null << 'EOF'
# Màn hình chính (LG Primary)
monitor = DP-1, 2560x1440@144, 0x0, 1

# Màn hình phụ (LG Secondary) - bên phải
monitor = DP-2, 1920x1080@60, 2560x0, 1

# Workspace bindings
workspace = 1, monitor:DP-1, default:true
workspace = 2, monitor:DP-1
workspace = 3, monitor:DP-1
workspace = 4, monitor:DP-1
workspace = 5, monitor:DP-1

workspace = 6, monitor:DP-2, default:true
workspace = 7, monitor:DP-2
workspace = 8, monitor:DP-2
workspace = 9, monitor:DP-2
workspace = 10, monitor:DP-2

# VRR
misc {
    vrr = 1
    mouse_move_focuses_monitor = true
}
EOF
    end
    
    hyprctl reload 2>/dev/null || true
end

# Starship
if confirm-overwrite $config/starship.toml
    log 'Installing starship config...'
    ln -s (realpath starship.toml) $config/starship.toml
end

# Foot
if confirm-overwrite $config/foot
    log 'Installing foot config...'
    ln -s (realpath foot) $config/foot
end

# Fish
if confirm-overwrite $config/fish
    log 'Installing fish config...'
    ln -s (realpath fish) $config/fish
end

# Fastfetch
if confirm-overwrite $config/fastfetch
    log 'Installing fastfetch config...'
    ln -s (realpath fastfetch) $config/fastfetch
end

# Uwsm
if confirm-overwrite $config/uwsm
    log 'Installing uwsm config...'
    ln -s (realpath uwsm) $config/uwsm
end

# Btop
if confirm-overwrite $config/btop
    log 'Installing btop config...'
    ln -s (realpath btop) $config/btop
end

# Install spicetify
if set -q _flag_spotify
    log 'Installing spotify (spicetify)...'

    set -l has_spicetify (pacman -Q spicetify-cli 2> /dev/null)
    $aur_helper -S --needed spotify spicetify-cli spicetify-marketplace-bin $noconfirm

    # Set permissions and init if new install
    if test -z "$has_spicetify"
        sudo chmod a+wr /opt/spotify
        sudo chmod a+wr /opt/spotify/Apps -R
        spicetify backup apply
    end

    # Install configs
    if confirm-overwrite $config/spicetify
        log 'Installing spicetify config...'
        ln -s (realpath spicetify) $config/spicetify

        # Set spicetify configs
        spicetify config current_theme caelestia color_scheme caelestia custom_apps marketplace 2> /dev/null
        spicetify apply
    end
end

# Install vscode
if set -q _flag_vscode
    test "$_flag_vscode" = 'code' && set -l prog 'code' || set -l prog 'codium'
    test "$_flag_vscode" = 'code' && set -l packages 'code' || set -l packages 'vscodium-bin' 'vscodium-bin-marketplace'
    test "$_flag_vscode" = 'code' && set -l folder 'Code' || set -l folder 'VSCodium'
    set -l folder $config/$folder/User

    log "Installing vs$prog..."
    $aur_helper -S --needed $packages $noconfirm

    # Install configs
    if confirm-overwrite $folder/settings.json && confirm-overwrite $folder/keybindings.json && confirm-overwrite $config/$prog-flags.conf
        log "Installing vs$prog config..."
        ln -s (realpath vscode/settings.json) $folder/settings.json
        ln -s (realpath vscode/keybindings.json) $folder/keybindings.json
        ln -s (realpath vscode/flags.conf) $config/$prog-flags.conf

        # Install extension
        $prog --install-extension vscode/caelestia-vscode-integration/caelestia-vscode-integration-*.vsix
    end
end

# Install discord
if set -q _flag_discord
    log 'Installing discord...'
    $aur_helper -S --needed discord equicord-installer-bin $noconfirm

    # Install OpenAsar and Equicord
    sudo Equilotl -install -location /opt/discord
    sudo Equilotl -install-openasar -location /opt/discord

    # Remove installer
    $aur_helper -Rns equicord-installer-bin $noconfirm
end

# Install zen
if set -q _flag_zen
    log 'Installing zen...'
    $aur_helper -S --needed zen-browser-bin $noconfirm

    # Install userChrome css
    set -l chrome $HOME/.zen/*/chrome
    if confirm-overwrite $chrome/userChrome.css
        log 'Installing zen userChrome...'
        ln -s (realpath zen/userChrome.css) $chrome/userChrome.css
    end

    # Install native app
    set -l hosts $HOME/.mozilla/native-messaging-hosts
    set -l lib $HOME/.local/lib/caelestia

    if confirm-overwrite $hosts/caelestiafox.json
        log 'Installing zen native app manifest...'
        mkdir -p $hosts
        cp zen/native_app/manifest.json $hosts/caelestiafox.json
        sed -i "s|{{ \$lib }}|$lib|g" $hosts/caelestiafox.json
    end

    if confirm-overwrite $lib/caelestiafox
        log 'Installing zen native app...'
        mkdir -p $lib
        ln -s (realpath zen/native_app/app.fish) $lib/caelestiafox
    end

    # Prompt user to install extension
    log 'Please install the CaelestiaFox extension from https://addons.mozilla.org/en-US/firefox/addon/caelestiafox if you have not already done so.'
end

# Generate scheme stuff if needed
if ! test -f $state/caelestia/scheme.json
    caelestia scheme set -n shadotheme
    sleep .5
    hyprctl reload 2>/dev/null || true
end

# Start the shell
caelestia shell -d > /dev/null 2>&1 || true

log 'Done!'

if set -q _flag_full_setup
    echo
    warn '════════════════════════════════════════════════════════════'
    warn '  IMPORTANT: System needs to REBOOT to apply all changes!'
    warn '  After reboot, run these commands to verify:'
    warn '    uname -r              # Check CachyOS kernel'
    warn '    nvidia-smi            # Check Nvidia driver'
    warn '    sensors               # Check temperatures'
    warn '    ddcutil detect        # Check monitors'
    warn '    fcitx5-configtool     # Configure Vietnamese input'
    warn '════════════════════════════════════════════════════════════'
    echo
    
    if ! set -q _flag_noconfirm
        input 'Reboot now? [Y/n] ' -n
        set -l reboot_now (sh-read)
        if test "$reboot_now" != 'n' -a "$reboot_now" != 'N'
            sudo reboot
        end
    end
end