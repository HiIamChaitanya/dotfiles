#!/bin/bash

readonly THEME_DIR="$HOME/dotfiles/gnome-themes"
readonly THEME_NAME="WhiteSur-gtk-theme"
readonly THEME_REPO="https://github.com/vinceliuice/$THEME_NAME.git"

# Clone the theme repository
git clone --depth=1 "$THEME_REPO" "$THEME_DIR/$THEME_NAME"

# Install the theme
cd "$THEME_DIR/$THEME_NAME"
chmod +x install.sh
./install.sh -c dark --shell -i fedora -h smaller -sf -a all -m -l -HD --round --darker

# Tweak the theme
chmod +x tweaks.sh
./tweaks.sh -F -c dark

# Allow flatpak to use the theme
sudo flatpak override --filesystem=xdg-config/gtk-3.0
sudo flatpak override --filesystem=xdg-config/gtk-4.0

# Clean up
cd .. && rm -rf "$THEME_NAME"

