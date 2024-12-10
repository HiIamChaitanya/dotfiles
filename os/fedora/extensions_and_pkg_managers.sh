#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

enable_extra_rpm_pkgs_and_non_free() {

	print_in_purple "\n • Enable extra rpm pkgs / non-free options / 3rd party options\n\n"

	sudo rpm -Uvh https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	sudo dnf upgrade --refresh
	sudo dnf groupupdate core
	sudo dnf install -y rpmfusion-free-release-tainted
	sudo dnf install -y dnf-plugins-core
	sudo dnf install -y fedora-workstation-repositories

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

add_flatpak_store_and_update() {

	print_in_purple "\n • Add flatpak store and update\n\n"

	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak update

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gnome_tweaks() {

	print_in_purple "\n • Installing some misc gnome tweaks\n\n"

	sudo dnf install -y gnome-tweaks
	sudo dnf install -y gnome-shell-extension-appindicator
	flatpak install -y https://flathub.org/apps/com.mattjakeman.ExtensionManager.flatpakref

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
        echo "Installing extension with ID: $ext_id"
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s "$ext_id"
        sleep 2
    done

    echo "All extensions have been installed. You may need to restart GNOME Shell or log out and back in for changes to take effect."
}

# ---------------------------------------------------------------------- 

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

	enable_extra_rpm_pkgs_and_non_free

	add_flatpak_store_and_update

	install_gnome_tweaks

	install_gnome_extensions

}

main
