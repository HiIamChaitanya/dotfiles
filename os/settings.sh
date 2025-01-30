#!/bin/bash

set -e

apply_general_gnome_tweaks() {
    print_in_purple "\n • General Gnome tweaks... \n\n"

    gsettings set org.gnome.desktop.interface enable-hot-corners false
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    echo "Disable suspend when laptop lid is closed in Tweaks General."
}

load_custom_keybindings() {
    if [[ -f "$HOME/dotfiles/os/custom-keybindings.conf" ]]; then
        dconf load / < "$HOME/dotfiles/os/custom-keybindings.conf"
    else
        echo "Custom keybindings configuration file not found."
    fi
}

main() {
    apply_general_gnome_tweaks
    load_custom_keybindings
}

main

