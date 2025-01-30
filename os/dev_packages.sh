#!/usr/bin/env bash

set -euo pipefail

declare DOT="$HOME/dotfiles"

# Source utility functions
source "$(dirname "${BASH_SOURCE[0]}")/$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function to install development tools and packages
install_dev_tools() {
    print_in_purple "\n • Installing development tools and packages\n\n"
    sudo dnf groupinstall 'Development Tools' -y
    sudo dnf install -y git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
}

# Function to install and configure GNU Stow
install_and_configure_stow() {
    print_in_purple "\n • Installing and configuring GNU Stow\n\n"

    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y stow
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y stow
    elif command -v yum &>/dev/null; then
        sudo yum install -y stow
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy stow
    else
        echo "Unable to detect package manager. Please install Stow manually."
        return 1
    fi

    # Create Stow directory and configure alias
    sudo mkdir -p /usr/local/stow
    echo "alias stow='sudo STOW_DIR=/usr/local/stow /usr/bin/stow'" >>~/.bashrc

    # Reload .bashrc for changes to take effect
    source ~/.bashrc

    echo "GNU Stow has been installed and configured."
}

# Function to install TypeScript globally
install_typescript() {
    print_in_purple "\n • Installing TypeScript globally\n\n"
    npm install -g typescript
}

# Function to install Bun
install_bun() {
    print_in_purple "\n • Installing Bun\n\n"
    curl -fsSL https://bun.sh/install | bash
}

# Function to install Visual Studio Code and configure inotify settings
install_vscode_and_configure_inotify() {
    print_in_purple "\n • Installing Visual Studio Code\n\n"

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo "[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo

    sudo dnf check-update && sudo dnf install -y code

    # Increase inotify user watches limit
    echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
    sudo sysctl --system

}

# Function to install miscellaneous useful tools
install_misc_tools() {
    print_in_purple "\n • Installing miscellaneous useful tools\n\n"

    local tools=(
        lazygit
        tldr
        neofetch
        htop
        s
    )

    sudo dnf install -y "${tools[@]}"
}

# Function to install Starship for Fish shell
install_starship_for_fish() {
    print_in_purple "\n • Installing Starship...\n"

    curl --proto '=https' --tlsv1.2 -sSf https://starship.rs/install.sh | sh

    if ! command -v starship &>/dev/null; then
        echo "Starship installation failed. Please check your internet connection and try again."
        return 1
    fi

    mkdir -p ~/.config/fish

    echo "starship init fish | source" >>~/.config/fish/config.fish

    echo "Starship has been installed and configured for Fish shell."
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

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
