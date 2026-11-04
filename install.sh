#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting installation of umbriel-dotfiles:"

# 1. Install Packages
echo "Installing required packages via dnf..."
sudo dnf install -y kitty fastfetch grim slurp wl-clipboard brightnessctl fuzzel fish git

# Note: Umbriel and Noctalia are not in the default Fedora repos.
# You must have their COPRs enabled or build them from source before running this.

# 2. Create Configuration Directories
echo "Creating configuration directories.."
mkdir -p ~/.config/umbriel
mkdir -p ~/.config/kitty
mkdir -p ~/.config/fastfetch
mkdir -p ~/.local/state/noctalia
mkdir -p ~/.local/bin
mkdir -p ~/Pictures

# 3. Copy Configurations
echo "Copying configurations..."
cp -r config/umbriel/* ~/.config/umbriel/ 2>/dev/null || true
cp -r config/kitty/* ~/.config/kitty/ 2>/dev/null || true
cp -r config/fastfetch/* ~/.config/fastfetch/ 2>/dev/null || true
cp -r config/noctalia/* ~/.local/state/noctalia/ 2>/dev/null || true

# 4. Copy Wallpapers
echo "Copying wallpapers..."
cp -r pictures/wallpapers/* ~/Pictures/ 2>/dev/null || true

# 5. Setup Ly (Requires sudo)
echo "Setting up Ly Display Manager"
sudo mkdir -p /etc/ly
sudo cp config/ly/config.lua /etc/ly/config.lua 2>/dev/null || true

# 6. Enable Ly (Uncomment to apply automatically)
echo "Enabling Ly on tty2..."
sudo systemctl disable gdm
sudo systemctl enable ly@tty2.service
sudo systemctl disable getty@tty2.service

echo "Installation complete. congrats"
echo "Please READ about SELlinux in the GITHUB REPO before restarting, review your configs and log out or reboot to apply changes."
echo "have fun larping this shi"
