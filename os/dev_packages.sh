#!/usr/bin/env bash

set -euo pipefail

# Configuration
DOT="$HOME/dotfiles"

# Source utility functions
source "$(dirname "${BASH_SOURCE[0]}")/$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function to install development tools and packages
install_dev_tools() {
    print_in_purple "\n • Installing development tools and packages\n\n"
    sudo dnf groupinstall 'Development Tools' -y
    sudo dnf install -y git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
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
    install_dev_tools
    install_and_configure_stow
    install_typescript
    install_bun
    install_vscode_and_configure_inotify
    install_misc_tools
    install_starship_for_fish

}

main "$@"
