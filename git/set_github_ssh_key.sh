#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

add_ssh_configs() {

    printf "%s\n" \
        "Host github.com" \
        "  IdentityFile $1" \
        "  LogLevel ERROR" >> ~/.ssh/config

    print_result $? "Add SSH configs"

}

copy_public_ssh_key_to_clipboard() {

    if cmd_exists "xclip"; then

        xclip -selection clip < "$1"
        print_result $? "Copy public SSH key to clipboard"

    else
        print_warning "Please copy the public SSH key ($1) to clipboard"
    fi

}

generate_ssh_keys() {

    ask "Please provide an email address: " && printf "\n"
    ssh-keygen -t ed25519 -C "$(get_answer)" -f "$1"

    print_result $? "Generate SSH keys"

}

open_github_ssh_page() {

    declare -r GITHUB_SSH_URL="https://github.com/settings/ssh"

    if cmd_exists "xdg-open"; then
        xdg-open "$GITHUB_SSH_URL"
    else
        print_warning "Please add the public SSH key to GitHub ($GITHUB_SSH_URL)"
    fi

}

set_github_ssh_key() {

    local sshKeyFileName="$HOME/.ssh/github"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # If there is already a file with that
    # name, generate another, unique, file name.

    if [ -f "$sshKeyFileName" ]; then
        sshKeyFileName="$(mktemp -u "$HOME/.ssh/github_XXXXX")"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    generate_ssh_keys "$sshKeyFileName"
    add_ssh_configs "$sshKeyFileName"
    copy_public_ssh_key_to_clipboard "${sshKeyFileName}.pub"
    open_github_ssh_page
    test_ssh_connection \
        && rm "${sshKeyFileName}.pub"

}

test_ssh_connection() {

    while true; do

	chmod 600 ~/.ssh/config
	chown $USER ~/.ssh/config

        ssh -T git@github.com
        [ $? -eq 1 ] && break

        sleep 5

    done

}

main() {

    print_in_purple "\n • Set up GitHub SSH keys\n\n"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # ssh -T git@github.com &> /dev/null

    # if [ $? -ne 1 ]; then
    #     set_github_ssh_key
    # fi

    # # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # print_result $? "Set up GitHub SSH keys"

}

main
