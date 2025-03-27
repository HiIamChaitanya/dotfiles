#!/bin/bash

________          __    _____.__.__                 
\______ \   _____/  |__/ ____\__|  |   ____   ______
 |    |  \ /  _ \   __\   __\|  |  | _/ __ \ /  ___/
 |    `   (  <_> )  |  |  |  |  |  |_\  ___/ \___ \ 
/_______  /\____/|__|  |__|  |__|____/\___  >____  >
        \/                                \/     \/ 


# Function to handle dotfiles directory
handle_dotfiles_directory() {
    local dotfiles_dir="$HOME/dotfiles"

    if [ -d "$dotfiles_dir" ]; then
        ask_for_confirmation "Dotfiles directory already exists. Do you want to overwrite it? (y/n)"
        if answer_is_yes; then
            echo "Overwriting existing dotfiles directory..."
            # Compress existing dotfiles directory
            tar -czvf dotfiles_backup_$(date +%Y%m%d%H%M%S).tar.gz "$dotfiles_dir"
            echo "Backed up existing dotfiles to dotfiles_backup_$(date +%Y%m%d%H%M%S).tar.gz"
            rm -rf "$dotfiles_dir"
        else
            echo "Keeping existing dotfiles directory. Exiting..."
            exit 0
        fi
    fi
}

# Main script execution
main() {
    handle_dotfiles_directory
    # clone dotfile repo to $HOME
    git clone --depth=1 https://github.com/HiIamChaitanya/dotfiles.git ~/dotfiles

    # install dotfiles
    ~/dotfiles/install.sh
}

main
