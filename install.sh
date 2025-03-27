#!/bin/bash

set -euo pipefail

# Import utils and settings
cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "setup/utils.sh" && . "os/settings.sh"

# Functions
init_fedora_setup() {
    print_in_purple " • Starting initial Fedora setup "
    ./os/fedora/init_fedora_setup.sh
    print_in_green " • Initial setup done! "
}

install_extensions_and_pkg_managers() {
    print_in_purple " • Installing basic extensions and pkg managers "
    ./os/fedora/extensions_and_pkg_managers.sh
    print_in_green " • Finished installing basic extensions and pkg managers! "
    sleep 2
}

install_dev_packages() {
    print_in_purple " • Installing dev packages "
    ./os/dev_packages.sh
    print_in_green "  Dev packages installed! "
    sleep 2
}

setup_os_theme_and_terminal_style() {
    print_in_purple " • Setting up OS theme and terminal tweaks "
    ./os/theme/main.sh
    print_in_green " Theme and terminal setup done! "
    sleep 2
}


fedora_setup_final() {
    # cleanup 
    sudo dnf autoremove -y

   # Enable and start services
   print_in_yellow " • Enabling and starting services "

   # to do : add services to enable and start here
    
    print_in_green "\n • All done! Install the suggested extensions and restart. \n"
}

install_nvidia_drivers() {
    print_in_purple " • Checking for NVIDIA GPU drivers"

    # Check for NVIDIA GPU
    if lspci | grep -i nvidia &>/dev/null; then
        echo "NVIDIA GPU detected. Installing drivers..."

        # Enable RPM Fusion repositories
        sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
        sudo dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

        # Update package cache
        sudo dnf update -y

        # Install NVIDIA drivers and necessary packages
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs

        # For CUDA support (optional)
        sudo dnf install -y xorg-x11-drv-nvidia-cuda

        echo "NVIDIA drivers installed. Please reboot your system to apply changes."
    elif lspci | grep -i "Advanced Micro Devices" &>/dev/null || lspci | grep -i "AMD" &>/dev/null; then
        echo "AMD GPU detected. No need to install drivers manually on Fedora."
        echo "Fedora already includes open-source AMD drivers. You're good to go!"

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
    init_fedora_setup || exit 1 
    install_extensions_and_pkg_managers || exit 1
    install_dev_packages || exit 1 
    setup_os_theme_and_terminal_style || exit 1
    fedora_setup_final  || exit 1
    install_nvidia_drivers  || exit 1
    ask_reboot  
}

if [ "$#" -gt 0 ]; then
  "$@"
else
  main
fi
