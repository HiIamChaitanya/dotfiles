#!/bin/bash

# Function to check if the user's answer is 'yes'
answer_is_yes() {
    read -r user_answer
    [[ "$user_answer" =~ ^([yY][eE][sS]|[yY])$ ]]
}

print_banner() {
    cat << "EOF"
________          __    _____.__.__                 
\______ \   _____/  |__/ ____\__|  |   ____   ______
 |    |  \ /  _ \   __\   __\|  |  | _/ __ \ /  ___/
 |    `   (  <_> )  |  |  |  |  |  |_\  ___/ \___ \ 
/_______  /\____/|__|  |__|  |__|____/\___  >____  >
        \/                                \/     \/ 
EOF

}
# Function to handle dotfiles directory
handle_dotfiles_directory() {
    local dotfiles_dir="$HOME/dotfiles"

    if [ -d "$dotfiles_dir" ]; then
         echo "Dotfiles directory already exists. Do you want to overwrite it? (y/n)"
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

# Function to clone the dotfiles repository
clone_dotfiles_repo() {
    git clone --depth=1 https://github.com/HiIamChaitanya/dotfiles.git ~/dotfiles
}

# Function to install dotfiles
install_dotfiles() {
    bash ~/dotfiles/install.sh
}

# Main script execution
main() {
    print_banner
    handle_dotfiles_directory
    clone_dotfiles_repo
    install_dotfiles
}

main
