#!/bin/bash

# TO DO 
# custom keybindings 


apply_general_gnome_tweaks() {
    print_in_purple "\n • General Gnome tweaks... \n\n"

    gsettings set org.gnome.desktop.interface enable-hot-corners false
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface show-battery-percentage true
}


main() {
    apply_general_gnome_tweaks
}

main

