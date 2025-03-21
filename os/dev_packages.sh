#!/usr/bin/env bash

# Script to install various desktop applications and utilities

set -euo pipefail

# Configuration
DOT="$HOME/dotfiles"

# Source utils.sh from the same directory as this script
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$script_dir/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function to check if the system is a laptop
is_laptop() {
    if [[ -f "/sys/class/dmi/id/chassis_type" ]]; then
        local chassis_type
        chassis_type=$(</sys/class/dmi/id/chassis_type)
        case "$chassis_type" in
            8 | 9 | 10 | 11) return 0 ;; # It's a laptop
            *) return 1 ;;               # It's not a laptop
        esac
    fi
    print_warning "Could not reliably determine if this is a laptop. Assuming it's not."
    return 1 # Unable to determine, assume it's not a laptop
}

# Function to install a package using dnf
install_dnf_package() {
    local package="$1"
    print_info "Installing $package..."
    if command_exists dnf; then
        sudo dnf install -y "$package"
        print_success "$package installed."
    else
        print_warning "dnf not found. Please install $package manually."
    fi
}

# Function to install a DNF group
install_dnf_group() {
    local group="$1"
    print_info "Installing DNF group '$group'..."
    if command_exists dnf; then
        sudo dnf group install -y "$group"
        print_success "DNF group '$group' installed."
    else
        print_warning "dnf not found. Please install the group '$group' manually."
    fi
}

# Function to update a DNF group
update_dnf_group() {
    local group="$1"
    print_info "Updating DNF group '$group'..."
    if command_exists dnf; then
        sudo dnf group update -y "$group"
        print_success "DNF group '$group' updated."
    else
        print_warning "dnf not found. Please update the group '$group' manually."
    fi
}

# Function to upgrade a DNF group with optional components
upgrade_dnf_group_with_optional() {
    local group="$1"
    print_info "Upgrading DNF group '$group' with optional components..."
    if command_exists dnf; then
        sudo dnf group upgrade -y --with-optional "$group"
        print_success "DNF group '$group' upgraded with optional components."
    else
        print_warning "dnf not found. Please upgrade the group '$group' manually with optional components."
    fi
}

# Function to install TLP for battery management on laptops
install_tlp() {
    print_in_purple "\n • Installing TLP for battery management\n"
    if is_laptop; then
        install_dnf_package tlp
        install_dnf_package tlp-rdw
    else
        print_warning "This device is not a laptop. TLP installation skipped."
    fi
}

# Function to install multimedia codecs
install_multimedia_codecs() {
    print_in_purple "\n • Installing multimedia codecs\n"
    update_dnf_group sound-and-video

    local base_plugins="gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base}"
    local libav_plugin="gstreamer1-libav"
    local ffmpeg_package="ffmpeg"
    local lame_packages="lame\*"

    install_dnf_package "$base_plugins"
    install_dnf_package "$libav_plugin"
    install_dnf_package "$ffmpeg_package"
    install_dnf_package "$lame_packages" --exclude=lame-devel

    upgrade_dnf_group_with_optional Multimedia
}

# Function to install media players
install_media_players() {
    print_in_purple "\n • Installing media players\n"
    install_dnf_package vlc
    install_dnf_package mpv
}

# Function to install Ulauncher application launcher
install_ulauncher() {
    print_in_purple "\n • Installing Ulauncher\n"
    install_dnf_package ulauncher
    install_dnf_package wmctrl

    # Create a custom shortcut for Wayland (GNOME)
    if command_exists gsettings; then
        print_info "Setting up Ulauncher hotkey (Ctrl+Space) for Wayland (GNOME)..."
        local custom_binding_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"

        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$custom_binding_path']"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$custom_binding_path" name "Ulauncher"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$custom_binding_path" command "ulauncher-toggle"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$custom_binding_path" binding "<Control>space"

        print_success "Ulauncher has been installed and the hotkey (Ctrl+Space) has been set up for Wayland."
        print_info "Please log out and log back in for the changes to take effect."
    else
        print_warning "gsettings not found. Skipping Ulauncher hotkey setup."
    fi
}

# Function to install Google Chrome browser
install_chrome() {
    print_in_purple "\n • Installing Chrome\n"
    if ! command_exists google-chrome-stable; then
        if command_exists dnf; then
            sudo dnf config-manager --set-enabled google-chrome
            install_dnf_package google-chrome-stable
        else
            print_warning "dnf not found. Please follow the instructions on Google's website to install Chrome."
        fi
    else
        print_info "Google Chrome is already installed."
    fi
}

# Function to install CAD software (KiCad and FreeCAD)
install_cad_software() {
    print_in_purple "\n • Installing KiCad & FreeCAD\n"
    install_dnf_package kicad
    install_dnf_package freecad
}

# Function to install JupyterLab
install_jupyterlab() {
    print_in_purple "\n • Installing JupyterLab\n"
    install_dnf_package jupyterlab
    print_success "JupyterLab has been installed."
}

# Main function to orchestrate the installation process
main() {
    print_in_purple "\n ---------------------------------------------------\n"
    print_in_purple "|         Installing Desktop Applications           |\n"
    print_in_purple " ---------------------------------------------------\n\n"

    install_tlp
    install_multimedia_codecs
    install_media_players
    install_ulauncher
    install_chrome
    install_cad_software
    install_jupyterlab

    print_in_purple "\n • Desktop application installation complete!\n"
}

# Execute the main function if the script is run directly
main "$@"