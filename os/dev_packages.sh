#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# DEV TOOLS

dev_tools_group() {

    print_in_purple "\n • Installing dev tools and pkgs\n\n"

    sudo yum groupinstall 'Development Tools'
    sudo dnf install -y git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_and_configure_stow() {
    # Install Stow
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y stow
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y stow
    elif command -v yum &> /dev/null; then
        sudo yum install -y stow
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy stow
    else
        echo "Unable to detect package manager. Please install Stow manually."
        return 1
    fi

    # Create Stow directory
    sudo mkdir -p /usr/local/stow

    # Configure Stow alias
    echo "alias stow='sudo STOW_DIR=/usr/local/stow /usr/bin/stow'" >> ~/.bashrc

    # Reload .bashrc
    source ~/.bashrc

    echo "GNU Stow has been installed and configured."
    echo "Stow directory: /usr/local/stow"
    echo "Stow alias added to ~/.bashrc"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# TYPESCRIPT 

install_typescript() {

    print_in_purple "\n • Installing typescript globally\n\n"

    npm install -g typescript

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# BUN

install_bun() {

    print_in_purple "\n • Installing bun \n\n"

   curl -fsSL https://bun.sh/install | bash

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_VSCode_and_set_inotify_max_user_watches() {

        print_in_purple "\n • Installing VSCode \n\n"

        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update
        sudo dnf install -y code

        echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MISC

install_misc_tools() {

    print_in_purple "\n • Installing miscallenous useful tools\n\n"

    sudo dnf install -y lazygit
    sudo dnf install -y tldr

    sudo dnf install -y neofetch

    sudo dnf install -y htop

    sudo dnf install -y s

}

# ----------------------------------------------------------------------

install_starship_for_fish() {
    echo "Installing Starship..."
    
    # Install Starship
    curl -sS https://starship.rs/install.sh | sh

    # Check if installation was successful
    if ! command -v starship &> /dev/null; then
        echo "Starship installation failed. Please check your internet connection and try again."
        return 1
    fi

    # Configure Starship for Fish shell
    if [ ! -d ~/.config/fish ]; then
        mkdir -p ~/.config/fish
    fi

    echo "starship init fish | source" >> ~/.config/fish/config.fish

    echo "Starship has been installed and configured for Fish shell."
    echo "Please restart your Fish shell or run 'source ~/.config/fish/config.fish' to apply changes."
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

	dev_tools_group
 
    install_and_configure_stow
 
    install_typescript
    
    install_bun

    install_VSCode_and_set_inotify_max_user_watches

    install_misc_tools

    install_starship_for_fish

}

main
