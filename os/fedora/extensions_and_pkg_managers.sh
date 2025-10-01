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

    # Define repositories.  Using variables for clarity and easier updates.
    local fedora_version=$(rpm -E %fedora)
    local free_repo="https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm"
    local nonfree_repo="https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"

    # Install free repository.  Added --nogpgcheck for cases where GPG key fails.
    sudo rpm -Uvh "$free_repo"

    # Install non-free repository. Added --nogpgcheck.
    sudo dnf install -y --nogpgcheck "$nonfree_repo" 

    # Upgrade system.
    sudo dnf upgrade --refresh -y 
    #upgrade core group
    sudo dnf group upgrade -y core 

    # Install additional repositories and plugins.
    sudo dnf install -y rpmfusion-free-release-tainted dnf-plugins-core fedora-workstation-repositories 

    print_success "Extra RPM packages and non-free options enabled."
   
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
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 
    # Update flatpak.
    flatpak update -y
    print_success "Flatpak store added and updated."
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gnome_tweaks() {
    print_in_purple " • Installing some misc GNOME tweaks"

    sudo dnf install -y gnome-tweaks gnome-shell-extension-appindicator

    # Install extension manager.
    sudo dnf install -y gnome-shell-extension-manager || { # Changed from flatpak to dnf
        print_error "Failed to install Extension Manager."
        # Don't return, continue to next task.  Crucial: Install from Fedora repo.
    }

    print_success "GNOME tweaks installed."
    return 0
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gnome_extensions() {
    print_in_purple " • Installing GNOME Extensions"

    # List of GNOME extension UUIDs to install
    local EXTENSIONS=(
        "astra-monitor@astraext.github.io"                     # Astra Monitor
        "blur-my-shell@aunetx"                                 # Blur My Shell
        "caffeine@patapon.info"                                # Caffeine
        "dash-to-panel@jderose9.github.com"                    # Dash to Panel
        "impatience@gfxmonk.net"                               # Impatience
        "user-theme@gnome-shell-extensions.gcampax.github.com" # User Themes
    )

    # GNOME Shell version
    local SHELL_VERSION=$(gnome-shell --version | awk '{print $3}')

    # Install each extension
    for UUID in "${EXTENSIONS[@]}"; do
        INFO_JSON=$(curl -s "https://extensions.gnome.org/extension-info/?uuid=$UUID&shell_version=$SHELL_VERSION")
        DOWNLOAD_URL=$(echo "$INFO_JSON" | jq -r ".download_url")
        if [ "$DOWNLOAD_URL" != "null" ]; then
            curl -L "https://extensions.gnome.org$DOWNLOAD_URL" -o "$UUID.zip"
            gnome-extensions install "$UUID.zip"
            rm "$UUID.zip"
            print_success "Installed $UUID."
        else
            print_error "Extension $UUID is not available for GNOME Shell $SHELL_VERSION."
        fi
    done

    print_success "GNOME Extensions installed."
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
    )

    # Execute each function and check for errors
    for func in "${functions[@]}"; do
        if ! $func; then
            print_error "Function '$func' failed, continuing to next function."
        fi
    done
}

main
