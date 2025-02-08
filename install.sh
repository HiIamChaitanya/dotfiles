#!/bin/bash

set -euo pipefail

# Import utils and settings
cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "setup/utils.sh" && . "os/settings.sh"

# Functions
init_fedora_setup() {
    print_in_purple "\n • Starting initial Fedora setup \n\n"
    ./os/fedora/init_fedora_setup.sh
    print_in_green "\n • Initial setup done! \n\n"
    sleep 5
}

install_extensions_and_pkg_managers() {
    print_in_purple "\n • Installing basic extensions and pkg managers \n\n"
    ./os/fedora/extensions_and_pkg_managers.sh
    print_in_green "\n • Finished installing basic extensions and pkg managers! \n\n"
    sleep 5
}

install_dev_packages() {
    print_in_purple "\n • Installing dev packages \n\n"
    ./os/dev_packages.sh
    print_in_green "\n  Dev packages installed! \n\n"
    sleep 5
}

setup_os_theme_and_terminal_style() {
    print_in_purple "\n • Setting up OS theme and terminal tweaks \n\n"
    ./os/theme/main.sh
    print_in_green "\n Theme and terminal setup done! \n\n"
    sleep 5
}

install_apps() {
    print_in_purple "\n • Installing applications \n\n"
    ./os/apps.sh
    print_in_green "\n Apps installed! \n\n"
    sleep 5
}

fedora_setup_final() {
    # cleanup
    sudo dnf autoremove

    # final tweaks
    source ~/.bashrc
    general_settings_tweaks
    custom_workspace_keybindings
    custom_keybindings

    print_in_green "\n • All done! Install the suggested extensions and restart. \n"
}

install_nvidia_drivers() {
    print_in_purple "\n •Check for Installing  NVIDIA GPU drivers\n\n"

    # Check for NVIDIA GPU
    if lspci | grep -i nvidia >/dev/null; then
        echo "NVIDIA GPU detected. Installing drivers..."

        # Enable RPM Fusion repositories
        sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

        # Update package cache
        sudo dnf update -y

        # Install NVIDIA drivers and necessary packages
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs

        # For CUDA support (optional)
        sudo dnf install -y xorg-x11-drv-nvidia-cuda

        echo "NVIDIA drivers installed. Please reboot your system to apply changes."
    else
        echo "No NVIDIA GPU detected. Skipping driver installation."
    fi
}

ask_reboot() {
    while true; do
        read -p "Do you want to reboot the system now? (y/n): " choice
        case "$choice" in
            y|Y)
                echo "Rebooting the system..."
                sudo reboot
                break
                ;;
            n|N)
                echo "Reboot cancelled. Please remember to reboot later for changes to take effect."
                break
                ;;
            *)
                echo "Invalid input. Please enter 'y' for yes or 'n' for no."
                ;;
        esac
    done
}

main() {
    init_fedora_setup
    install_extensions_and_pkg_managers
    install_dev_packages
    setup_os_theme_and_terminal_style
    install_apps
    fedora_setup_final
    install_nvidia_drivers
    ask_reboot
}

main
