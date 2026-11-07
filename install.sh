#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting installation of umbriel-dotfiles:"

echo "enabling coprs for noctalia and umbriel"
sudo dnf copr enable -y lionheartp/Hyprland
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
# 1. Install Packages
echo "Installing required packages via dnf..."
sudo dnf install -y kitty fastfetch grim slurp wl-clipboard brightnessctl fuzzel fish git neovim noctalia-git umbriel thunar
# Note: Umbriel and Noctalia are not in the default Fedora repos.
# You must have their COPRs enabled or build them from source before running this.
# 2. Create Configuration Directories
echo "Creating configuration directories.."
mkdir -p ~/.config/umbriel
mkdir -p ~/.config/kitty
mkdir -p ~/.config/fastfetch
mkdir -p ~/.config/nvim
mkdir -p ~/.local/state/noctalia
mkdir -p ~/.config/fuzzel
mkdir -p ~/.config/Thunar
mkdir -p ~/.config/xfce4
mkdir -p ~/.local/bin
mkdir -p ~/Pictures

# 3. Copy Configurations
echo "Copying configurations..."
cp -r config/umbriel/* ~/.config/umbriel/ 2>/dev/null || true
cp -r config/kitty/* ~/.config/kitty/ 2>/dev/null || true
cp -r config/fastfetch/* ~/.config/fastfetch/ 2>/dev/null || true
cp -r config/nvim/* ~/.config/nvim/ 2>/dev/null || true
cp -r config/noctalia/* ~/.local/state/noctalia/ 2>/dev/null || true
cp -r config/fuzzel/* ~/.config/fuzzel/ 2>/dev/null || true
cp -r config/Thunar/* ~/.config/Thunar/ 2>/dev/null || true
cp -r config/xfce4/* ~/.config/xfce4/ 2>/dev/null || true

# 4. Copy Wallpapers
echo "Copying wallpapers..."
cp -r pictures/wallpapers/* ~/Pictures/ 2>/dev/null || true

# 5. Enabling plugins IF YOU'R not A MUSLIM disable THE MAWAQIT one
echo "Enabling Noctalia plugins..."
noctalia msg plugins enable h465855hgg/lyrics || true
noctalia msg plugins enable goatnath/spotify-lyrics || true
noctalia msg plugins enable noctalia/notes || true
noctalia msg plugins enable shangshui0302/github-kanban || true
noctalia msg plugins enable ycf/mawaqit || true
noctalia msg plugins enable thepunkoff/pomodoro || true

# 6. HOLY SHIT
echo "Installation complete. congrats"
echo "have fun"
