#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
installing TLP 
is_laptop() {
    if [ -f "/sys/class/dmi/id/chassis_type" ]; then
        chassis_type=$(cat /sys/class/dmi/id/chassis_type)
        case $chassis_type in
            8|9|10|11)
                return 0  # It's a laptop
                ;;
            *)
                return 1  # It's not a laptop
                ;;
        esac
    else
        return 1  # Unable to determine, assume it's not a laptop
    fi
}

install_tlp_battery_management() {
    if is_laptop; then
        echo "This is a laptop. Installing TLP..."
        print_in_purple "\n • Installing tlp battery management \n\n"

        sudo dnf install -y tlp tlp-rdw
    else
        echo "This Device is not a laptop. TLP installation skipped."
    fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_multimedia_codecs() {

        print_in_purple "\n • Installing multimedia codecs... \n\n"

        sudo dnf groupupdate sound-and-video
        sudo dnf install -y libdvdcss
        sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
        sudo dnf install -y lame\* --exclude=lame-devel
        sudo dnf group upgrade --with-optional Multimedia

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_VLC() {

        print_in_purple "\n • Installing VLC \n\n"

        sudo dnf install -y vlc
        sudo dnf install -y mpv

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_ulauncher() {

        print_in_purple "\n • Installing Ulauncher \n\n"

        sudo dnf install -y ulauncher

        # https://github.com/Ulauncher/Ulauncher/wiki/Hotkey-In-Wayland

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_chrome() {

        print_in_purple "\n • Installing Chrome \n\n"

        sudo dnf config-manager --set-enabled google-chrome

        sudo dnf install -y google-chrome-stable

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Install_KiCad_FreeCad() {
        print_in_purple "\n • Installing KiCad & FreeCad \n\n"

        sudo dnf install kicad -y

        sudo dnf install freecad -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -




# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -




# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -




# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

        install_tlp_battery_management

        install_multimedia_codecs

        install_VLC

        install_ulauncher

        install_chrome

        Install_KiCad_FreeCad

}

main
