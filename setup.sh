#!/bin/bash

# Function to check if the user's answer is 'yes'
answer_is_yes() {
    read -r -p "" user_answer
    if [[ "$user_answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        return 0
    fi
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

# Function to clone the dotfiles repository
clone_dotfiles_repo() {
    git clone --depth=1 https://github.com/HiIamChaitanya/dotfiles.git ~/
}

# Function to install dotfiles
install_dotfiles() {
    bash ~/dotfiles/install.sh
}

# Main script execution
main() {
    print_banner
    clone_dotfiles_repo
    install_dotfiles
}

main
