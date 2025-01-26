#!/bin/bash

cd ~/dotfiles/gnome-themes 

# Install Gnome theme 
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1

cd ~/dotfiles/gnome-themes/WhiteSur-gtk-theme 

chmod +x install.sh

./install.sh -c dark --shell -i fedora -h smaller -sf -a all -m -l -HD --round --darker

chmod +x tweak.sh

./tweaks.sh -F -c dark

sudo flatpak override --filesystem=xdg-config/gtk-3.0 && sudo flatpak override --filesystem=xdg-config/gtk-4.0

cd .. && rm -rf WhiteSur-gtk-theme