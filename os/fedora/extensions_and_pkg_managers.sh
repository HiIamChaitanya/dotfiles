#!/usr/bin/env bash

set -euo pipefail

# Configuration
declare DOT="$HOME/dotfiles"

# Source utility functions
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
. "$DOT/setup/utils.sh" || exit 1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

enable_extra_rpm_pkgs_and_non_free() {
    print_in_purple " • Enable extra rpm pkgs / non-free options / 3rd party options"

    # Check if dnf is installed
    if ! command -v dnf &>/dev/null; then
        print_error "dnf package manager is not installed. This script is intended for Fedora systems."
        return 1 # Exit with error code
    fi

    # Define repositories.
    local free_repo="https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    local nonfree_repo="https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

    # Install free repository.
    sudo rpm -Uvh "$free_repo" || {
        print_error "Failed to install RPM Fusion free repository."
        # Don't return, continue to next task
    }

    # Install non-free repository.
    sudo dnf install -y "$nonfree_repo" || {
        print_error "Failed to install RPM Fusion non-free repository."
        # Don't return, continue to next task
    }

    # Upgrade system.
    sudo dnf upgrade --refresh -y || {
        print_error "Failed to upgrade packages."
        # Don't return, continue to next task
    }

    #upgrade core group
    sudo dnf group upgrade -y core || {
        print_error "Failed to update core group."
        # Don't return, continue to next task
    }

    # Install additional repositories and plugins.
    sudo dnf install -y rpmfusion-free-release-tainted dnf-plugins-core fedora-workstation-repositories || {
        print_error "Failed to install additional repositories."
        # Don't return, continue to next task
    }

    print_success "Extra RPM packages and non-free options enabled."
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

add_flatpak_store_and_update() {
    print_in_purple " • Add flatpak store and update"

    # Check if flatpak is installed
    if ! command -v flatpak &>/dev/null; then
        print_error "Flatpak is not installed. Installing Flatpak..."
        sudo dnf install -y flatpak || {
            print_error "Failed to install Flatpak."
            return 1 # Exit this function, Flatpak is essential
        }
    fi

    # Add flathub repository.
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || {
        print_error "Failed to add flathub remote."
        # Don't return, continue to next task
    }

    # Update flatpak.
    flatpak update -y || {
        print_error "Failed to update flatpak."
        # Don't return, continue to next task
    }

    print_success "Flatpak store added and updated."
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gnome_tweaks() {
    print_in_purple " • Installing some misc GNOME tweaks"

    # Install gnome tweaks and extension.
    sudo dnf install -y gnome-tweaks gnome-shell-extension-appindicator || {
        print_error "Failed to install GNOME tweaks."
        # Don't return, continue to next task
    }

    # Install extension manager.
    flatpak install -y flathub com.mattjakeman.ExtensionManager || {
        print_error "Failed to install Extension Manager from Flathub."
        # Don't return, continue to next task
    }

    print_success "GNOME tweaks installed."
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gnome_extensions() {
    print_in_purple " • Installing GNOME Extensions"

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

    # Install each extension.
    for ext_id in "${extensions[@]}"; do
        print_in_yellow "Checking if extension with ID: $ext_id is already installed..."

        if ! busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions GetExtensionState s "$ext_id" | grep -q 'installed'; then
            print_in_yellow "Installing extension with ID: $ext_id"
            busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s "$ext_id" || {
                print_error "Failed to install extension with ID: $ext_id"
                continue # Continue to the next extension
            }
            sleep 2 # Consider removing or reducing sleep
        else
            print_in_yellow "Extension with ID: $ext_id is already installed."
        fi
    done

    print_success "All extensions have been processed."
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

restart_gnome_shell() {
    print_in_purple " • Restarting GNOME Shell"
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")' || {
        print_error "Failed to restart GNOME Shell."
        # Don't return, continue to next task
    }

    print_success "GNOME Shell restarted."
    return 0
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
    # Array of functions to execute
    local functions=(
        enable_extra_rpm_pkgs_and_non_free
        add_flatpak_store_and_update
        install_gnome_tweaks
        install_gnome_extensions
        restart_gnome_shell
    )

    # Execute each function and check for errors
    for func in "${functions[@]}"; do
        if ! $func; then
            print_error "Function '$func' failed, continuing to next function."
        fi
    done
}

main
