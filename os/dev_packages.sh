#!/usr/bin/env bash

set -euo pipefail

# Configuration
# DOT="$HOME/dotfiles" # You likely don't need this here if install.sh sets the context

# Source utility functions
source "$(dirname "${BASH_SOURCE[0]}")/../setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function to install a DNF package
install_dnf_package() {
    local package="$1"
    local options="${@:2}"
    print_info "Installing DNF package '$package'..."
    if cmd_exists dnf; then
        sudo dnf install -y "$package" "${options[@]}"
        if [ $? -eq 0 ]; then
            print_success "DNF package '$package' installed."
        else
            print_error "Failed to install DNF package '$package'."
            # No return here, to allow script to continue
        fi
    else
        print_warning "dnf not found. Please install the package '$package' manually."
        # No return here, to allow script to continue
    fi
}

# Function to install development tools and packages
install_dev_tools() {
    print_in_purple " • Installing development tools and packages"
    sudo dnf groupinstall 'Development Tools' -y
    local result=$?
    sudo dnf install -y git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
    result=$((result + $?))
    if [ $result -ne 0 ]; then
        print_error "Failed to install development tools."
        # No return here, to allow script to continue
    fi
}

# Function to install a DNF group
install_dnf_group() {
    local group="$1"
    sudo dnf group install -y "$group"
}

# Function to update a DNF group
update_dnf_group() {
    local group="$1"
    print_in_yellow "Updating DNF group '$group'..."
    if cmd_exists dnf; then
        sudo dnf group update -y "$group"
        if [ $? -eq 0 ]; then
            print_success "DNF group '$group' updated."
        else
            print_error "Failed to update DNF group '$group'."
            # No return here, to allow script to continue
        fi
    else
        print_warning "dnf not found. Please update the group '$group' manually."
        # No return here, to allow script to continue
    fi
}

# Function to upgrade a DNF group with optional components
upgrade_dnf_group_with_optional() {
    local group="$1"
    print_in_yellow "Upgrading DNF group '$group' with optional components..."
    if cmd_exists dnf; then
        sudo dnf group upgrade -y --with-optional "$group"
        if [ $? -eq 0 ]; then
            print_success "DNF group '$group' upgraded with optional components."
        else
            print_error "Failed to upgrade DNF group '$group' with optional components."
            # No return here, to allow script to continue
        fi
    else
        print_warning "dnf not found. Please upgrade the group '$group' manually with optional components."
        # No return here, to allow script to continue
    fi
}

# Function to check if the system is a laptop
is_laptop() {
    if [[ -f "/sys/class/dmi/id/chassis_type" ]]; then
        case $(</sys/class/dmi/id/chassis_type) in
        8 | 9 | 10 | 11) return 0 ;; # It's a laptop
        *) return 1 ;;               # It's not a laptop
        esac
    else
        print_warning "Cannot determine chassis type. Assuming this is not a laptop."
        return 1 # Unable to determine, assume it's not a laptop
    fi
}

# Function to install TLP for battery management on laptops
install_tlp() {
    print_in_purple " • Installing TLP for battery management"
    if is_laptop; then
        install_dnf_package tlp tlp-rdw
        if [ $? -ne 0 ]; then

            print_error "TLP installation failed."
            # No return here, to allow script to continue
        fi
    else
        print_warning "This device is not a laptop. TLP installation skipped."
    fi
}

# Function to install multimedia codecs
install_multimedia_codecs() {
    print_in_purple " • Installing multimedia codecs"
    sudo dnf group update -y sound-and-video
    if [ $? -ne 0 ]; then
        print_error "Failed to update sound-and-video group."
        # No return here, to allow script to continue
    fi
    sudo dnf install -y libdvdcss gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
    if [ $? -ne 0 ]; then
        print_error "Failed to install multimedia codecs."
        # No return here, to allow script to continue
    fi
    sudo dnf install -y lame\* --exclude=lame-devel
    if [ $? -ne 0 ]; then
        print_error "Failed to install lame."
        # No return here, to allow script to continue
    fi

    sudo dnf group upgrade -y --with-optional Multimedia
    if [ $? -ne 0 ]; then
        print_error "Failed to upgrade Multimedia group."
        # No return here, to allow script to continue
    fi
}

# Function to install media players
install_media_players() {
    print_in_purple " • Installing media players"
    sudo dnf install -y vlc mpv
    if [ $? -ne 0 ]; then
        print_error "Failed to install media players."
        # No return here, to allow script to continue
    fi
}

# Function to install Ulauncher application launcher
install_ulauncher() {
    print_in_purple " • Installing Ulauncher"
    sudo dnf install -y ulauncher wmctrl
    if [ $? -ne 0 ]; then
        print_error "Failed to install ulauncher and wmctrl."
        # No return here, to allow script to continue
    fi

    # Create a custom shortcut for Wayland
    if cmd_exists gsettings; then
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Ulauncher"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "ulauncher-toggle"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Control>space"
        if [ $? -ne 0 ]; then
            print_error "Failed to set Ulauncher hotkey."
            # No return here, to allow script to continue
        fi

        print_success "Ulauncher has been installed and the hotkey (Ctrl+Space) has been set up for Wayland."
        print_in_yellow "Please log out and log back in for the changes to take effect."
    else
        print_warning "gsettings not found. Skipping Ulauncher hotkey setup."
    fi
}

# Function to install Google Chrome browser
install_chrome() {
    print_in_purple " • Installing Chrome\n"
    if ! cmd_exists google-chrome-stable; then
        if cmd_exists dnf; then
            sudo dnf config-manager --set-enabled google-chrome
            if [ $? -ne 0 ]; then
                print_error "Failed to enable google-chrome repo."
                # No return here, to allow script to continue
            fi
            sudo dnf install -y google-chrome-stable
            if [ $? -ne 0 ]; then
                print_error "Failed to install chrome."
                # No return here, to allow script to continue
            fi
        else
            print_warning "dnf not found. Please follow the instructions on Google's website to install Chrome."
            # No return here, to allow script to continue
        fi
    else
        print_in_yellow "Google Chrome is already installed."
    fi
}

# Function to install CAD software (KiCad and FreeCAD)
install_cad_software() {
    print_in_purple " • Installing KiCad & FreeCAD"
    sudo dnf install -y kicad freecad
    if [ $? -ne 0 ]; then
        print_error "Failed to install KiCad and FreeCAD."
        # No return here, to allow script to continue
    fi
}

# Function to install JupyterLab
install_jupyterlab() {
    print_in_purple " • Installing JupyterLab"
    sudo dnf install -y jupyterlab
    if [ $? -ne 0 ]; then
        print_error "Failed to install JupyterLab."
        # No return here, to allow script to continue
    fi
    print_success "JupyterLab has been installed."
}

# Function to install and configure Stow
install_and_configure_stow() {
    print_in_purple " • Installing and configuring Stow for dotfiles"
    if ! cmd_exists stow; then
        install_dnf_package stow
        if [ $? -ne 0 ]; then
            print_error "Failed to install stow."
            # No return here, to allow script to continue
        fi
    fi

    # Define the dotfiles directory
    local dotfiles_dir="$HOME/dotfiles"

    # Create the dotfiles directory if it doesn't exist
    if [ ! -d "$dotfiles_dir" ]; then
        mkdir -p "$dotfiles_dir"
        if [ $? -ne 0 ]; then
            print_error "Failed to create dotfiles directory."
            # No return here, to allow script to continue
        fi
        print_in_yellow "Created dotfiles directory at $dotfiles_dir"
    else
        print_info "Dotfiles directory already exists at $dotfiles_dir"
    fi

    # Create the necessary subdirectories within the dotfiles directory
    mkdir -p "$dotfiles_dir/fish/.config/fish"
    mkdir -p "$dotfiles_dir/ghostty"
    mkdir -p "$dotfiles_dir/nvim/.config/nvim"
    mkdir -p "$dotfiles_dir/starship"
    mkdir -p "$dotfiles_dir/tmux"
    if [ $? -ne 0 ]; then
        print_error "Failed to create subdirectories in dotfiles directory."
        # No return here, to allow script to continue
    fi

    #  Change to the dotfiles directory.
    cd "$dotfiles_dir" || {
        print_error "Failed to change directory to $dotfiles_dir"
        return 1 # This is a critical error
    }

    # Stow the configurations
    stow fish
    stow ghostty
    stow nvim
    stow starship
    stow tmux
    if [ $? -ne 0 ]; then
        print_error "Failed to stow configuration files."
        # No return here, to allow script to continue.
    fi

    print_success "Stow has been installed and dotfiles structure has been set up in $dotfiles_dir."
    print_in_yellow "Please ensure your dotfiles are correctly placed in the created subdirectories."
}

# Function to install TypeScript
install_typescript() {
    print_in_purple " • Installing TypeScript"
    if ! cmd_exists npm; then
        install_dnf_package nodejs # Installs npm along with nodejs
        if [ $? -ne 0 ]; then
            print_error "Failed to install nodejs."
            # No return here, to allow script to continue
        fi
    fi
    if cmd_exists npm; then
        sudo npm install -g typescript
        if [ $? -ne 0 ]; then
            print_error "Failed to install TypeScript."
            # No return here, to allow script to continue
        fi
        print_success "TypeScript has been installed."
    else
        print_warning "npm not found.  Install nodejs to get npm."
        # No return here, to allow script to continue
    fi

}

# Function to install Bun
install_bun() {
    print_in_purple " • Installing Bun"
    # Bun installation requires curl and running a shell script.
    if cmd_exists curl; then
        # This script installs bun and also sets it up in $HOME/.bun/bin
        curl -fsSL https://bun.sh/install | bash
        if [ $? -ne 0 ]; then
            print_error "Failed to install Bun."
            # No return here, to allow script to continue
        fi
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >>~/.bashrc
        print_success "Bun has been installed.  Make sure to source ~/.bashrc"
    else
        print_warning "curl is required to install Bun.  Install curl and try again."
        # No return here, to allow script to continue
    fi
}

# Function to install VSCode
install_vscode() {
    print_in_purple " • Installing VSCode"
    if ! cmd_exists code; then
        # Get the latest stable VSCode rpm
        VSCODE_RPM_URL=$(curl -s https://code.visualstudio.com/api/update | jq -r '.versions.stable.rpm' 2>/dev/null)
        if [ -n "$VSCODE_RPM_URL" ]; then
            echo "wget $VSCODE_RPM_URL"
            wget "$VSCODE_RPM_URL" -O vscode.rpm
            if [ $? -ne 0 ]; then
                print_error "Failed to download VSCode rpm."
                # No return here, to allow script to continue
            fi
            sudo rpm -i vscode.rpm
            if [ $? -ne 0 ]; then
                print_error "Failed to install VSCode rpm."
                # No return here, to allow script to continue
            fi
            rm vscode.rpm
            print_success "VSCode has been installed."
        else
            print_error "Failed to retrieve VSCode RPM URL."
            # No return here, to allow script to continue
        fi
    else
        print_in_yellow "VSCode is already installed."
    fi

}

# Function to install miscellaneous tools
install_misc_tools() {
    print_in_purple " • Installing miscellaneous tools"
    sudo dnf install -y neovim tmux ripgrep fd-find tree
    if [ $? -ne 0 ]; then
        print_error "Failed to install miscellaneous tools."
        # No return here, to allow script to continue
    fi
    print_success "Miscellaneous tools (neovim, tmux, ripgrep, fd-find, tree) have been installed."

}

# Function to install Fish shell and make it the default
install_fish_shell() {
    print_in_purple " • Installing Fish shell and making it the default shell"

    # Install fish using the helper function
    install_dnf_package fish
    # Check the exit status of the install_dnf_package function itself
    if [ $? -ne 0 ]; then
        print_error "Fish shell installation failed. Cannot set as default."
        return 1 # Exit this function if installation failed
    fi

    # Check if chsh command exists
    if ! cmd_exists chsh; then
        print_warning "'chsh' command not found. Cannot set Fish as default shell automatically."
        print_info "Please set Fish as your default shell manually after logging in."
        return 1 # Indicate that setting default failed
    fi

    # Get the full path to the fish executable
    local fish_path
    fish_path=$(command -v fish)
    if [ -z "$fish_path" ]; then
        print_error "Could not find the path to the fish executable after installation."
        return 1
    fi

    # Get the current username
    local current_user
    current_user=$(whoami)
    if [ -z "$current_user" ]; then
        print_error "Could not determine the current user."
        return 1
    fi


    # Change the default shell for the *current* user
    # Note: chsh might prompt for a password interactively
    print_info "Attempting to change the default shell to Fish for user '$current_user'..."
    if sudo chsh -s "$fish_path" "$current_user"; then
        print_success "Fish shell has been installed and set as the default shell for '$current_user'."
        print_in_yellow "You will need to log out and log back in for the change to take effect."
    else
        print_error "Failed to change the default shell to Fish using 'chsh'."
        print_info "You may need to run 'sudo chsh -s $fish_path $current_user' manually."
        return 1 # Indicate that setting default failed
    fi

    return 0 # Success
}


# Function to install Starship for Fish shell
install_starship_for_fish() {
    print_in_purple " • Installing Starship for Fish shell"

    if ! cmd_exists fish; then
        print_warning "Fish shell is not installed.  Install fish shell to install starship for fish."
        return 1 # fish is a pre-requisite.
    fi
    if ! cmd_exists curl; then
        install_dnf_package curl
        if [ $? -ne 0 ]; then
            print_error "Failed to install curl."
            # No return here, to allow script to continue
        fi
    fi

    # Install starship
    if cmd_exists curl; then
        curl -sS https://starship.rs/install.sh | bash -s -- --yes
        if [ $? -ne 0 ]; then
            print_error "Failed to install starship."
            # No return here, to allow script to continue
        fi
        echo "starship init fish | source" >>~/.config/fish/config.fish
        print_success "Starship has been installed and configured for Fish shell. Add 'starship init fish | source' to your Fish config."
    else
        print_warning "Please install curl."
        return 1
    fi
}

# Function to install Zen Browser
install_zen_browser() {
    print_in_purple " • Installing Zen Browser"
    if cmd_exists flatpak; then
        sudo flatpak install flathub app.zen_browser.zen -y 2>&1
        if [ $? -ne 0 ]; then
            print_error "Failed to install Zen Browser."
            # No return here, to allow script to continue
        fi
        print_success "Zen Browser has been installed."
    else
        print_warning "flatpak is not installed.  Please install flatpak and add the flathub repository."
        # No return here, to allow script to continue
    fi
}

# Main function to orchestrate the installation process
main() {
    # Array of installation functions
    local install_functions=(
        install_dev_tools
        install_typescript
        install_bun
        install_chrome
        install_vscode
        install_misc_tools
        install_fish_shell 
        install_starship_for_fish
        install_tlp 
        install_multimedia_codecs
        install_media_players
        install_ulauncher
        install_cad_software
        install_jupyterlab
        install_zen_browser
        install_and_configure_stow
    )

    # Loop through the installation functions
    for func in "${install_functions[@]}"; do
        print_in_yellow "Calling function: $func"
        if ! $func; then
            print_error "Function '$func' failed, continuing..."
        fi
    done
}

main "$@"
