#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
. "$DOT/setup/utils.sh" || exit 1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

enable_extra_rpm_pkgs_and_non_free() {
    print_in_purple "\n • Enable extra rpm pkgs / non-free options / 3rd party options\n\n"

    if ! command -v dnf &> /dev/null; then
        print_error "dnf package manager is not installed. This script is intended for Fedora systems."
        exit 1
    fi

    sudo rpm -Uvh https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm || {
        print_error "Failed to install RPM Fusion free repository."
        exit 1
    }

    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || {
        print_error "Failed to install RPM Fusion non-free repository."
        exit 1
    }

    sudo dnf upgrade --refresh || {
        print_error "Failed to upgrade packages."
        exit 1
    }

    sudo dnf groupupdate -y core || {
        print_error "Failed to update core group."
        exit 1
    }

    sudo dnf install -y rpmfusion-free-release-tainted dnf-plugins-core fedora-workstation-repositories || {
        print_error "Failed to install additional repositories."
        exit 1
    }

    print_success "Extra RPM packages and non-free options enabled."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

add_flatpak_store_and_update() {
    print_in_purple "\n • Add flatpak store and update\n\n"

    if ! command -v flatpak &> /dev/null; then
        print_error "Flatpak is not installed. Installing Flatpak..."
        sudo dnf install -y flatpak || {
            print_error "Failed to install Flatpak."
            exit 1
        }
    fi

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || {
        print_error "Failed to add Flathub repository."
        exit 1
    }

    flatpak update -y || {
        print_error "Failed to update Flatpak packages."
        exit 1
    }

    print_success "Flatpak store added and updated."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gnome_tweaks() {
    print_in_purple "\n • Installing some misc GNOME tweaks\n\n"

    sudo dnf install -y gnome-tweaks gnome-shell-extension-appindicator || {
        print_error "Failed to install GNOME tweaks."
        exit 1
    }

    flatpak install -y flathub com.mattjakeman.ExtensionManager || {
        print_error "Failed to install Extension Manager from Flathub."
        exit 1
    }

    print_success "GNOME tweaks installed."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gnome_extensions() {
    print_in_purple "\n • Installing GNOME Extensions\n\n"

    local extensions=(
        "4158" # GNOME 40 UI Improvements
        "6"    # Applications Menu
        "6682" # Astra Monitor
        "307"  # Dash to Dock
        "1319" # GSConnect
        "277"  # Impatience
        "3193" # Blur My Shell
        "19"   # User Themes
    )

    for ext_id in "${extensions[@]}"; do
        print_info "Installing extension with ID: $ext_id"
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s "$ext_id" || {
            print_error "Failed to install extension with ID: $ext_id"
            continue
        }
        sleep 2
    done

    print_success "All extensions have been installed. You may need to restart GNOME Shell or log out and back in for changes to take effect."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

restart_gnome_shell() {
    print_in_purple "\n • Restarting GNOME Shell\n\n"
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")' || {
        print_error "Failed to restart GNOME Shell."
        exit 1
    }

    print_success "GNOME Shell restarted."
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
    enable_extra_rpm_pkgs_and_non_free
    add_flatpak_store_and_update
    install_gnome_tweaks
    install_gnome_extensions
    restart_gnome_shell
}

main