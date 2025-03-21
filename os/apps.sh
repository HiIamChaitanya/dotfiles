#!/usr/bin/env bash

declare DOT="$HOME/dotfiles"

# Source utils.sh from the same directory as this script
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

is_laptop() {
    [[ -f "/sys/class/dmi/id/chassis_type" ]] &&
        case $(</sys/class/dmi/id/chassis_type) in
        8 | 9 | 10 | 11) return 0 ;; # It's a laptop
        *) return 1 ;;               # It's not a laptop
        esac
    return 1 # Unable to determine, assume it's not a laptop
}

install_tlp() {
    if is_laptop; then
        print_in_purple "\n • Installing TLP for battery management\n"
        sudo dnf install -y tlp tlp-rdw
    else
        print_warning "This device is not a laptop. TLP installation skipped."
    fi
}

install_multimedia_codecs() {
    print_in_purple "\n • Installing multimedia codecs\n"
    sudo dnf groupupdate -y sound-and-video
    sudo dnf install -y libdvdcss gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
    sudo dnf install -y lame\* --exclude=lame-devel
    sudo dnf group upgrade -y --with-optional Multimedia
}

install_media_players() {
    print_in_purple "\n • Installing media players\n"
    sudo dnf install -y vlc mpv
}

install_ulauncher() {
    print_in_purple "\n • Installing Ulauncher\n"
    sudo dnf install -y ulauncher wmctrl

    # Create a custom shortcut for Wayland
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Ulauncher"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "ulauncher-toggle"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Control>space"

    print_success "Ulauncher has been installed and the hotkey (Ctrl+Space) has been set up for Wayland."
    print_info "Please log out and log back in for the changes to take effect."
}

install_chrome() {
    print_in_purple "\n • Installing Chrome\n"
    sudo dnf config-manager --set-enabled google-chrome
    sudo dnf install -y google-chrome-stable
}

install_cad_software() {
    print_in_purple "\n • Installing KiCad & FreeCAD\n"
    sudo dnf install -y kicad freecad
}

install_jupyterlab() {
    print_in_purple "\n • Installing JupyterLab\n"
    sudo dnf install -y jupyterlab

    print_success "JupyterLab has been installed."
}

main() {
    local install_functions=(
        install_tlp
        install_multimedia_codecs
        install_media_players
        install_ulauncher
        install_chrome
        install_cad_software
        install_jupyterlab
    )

    for func in "${install_functions[@]}"; do
        $func
    done
}

main

