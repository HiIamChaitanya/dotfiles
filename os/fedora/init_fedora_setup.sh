#!/usr/bin/env bash

# Configuration
readonly DOT="$HOME/dotfiles"

# Source utility functions
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
. "$DOT/setup/utils.sh" || exit 1


set_dnf_configs() {
    print_in_purple " • Setting DNF configs... "

    sudo tee -a /etc/dnf/dnf.conf >/dev/null <<EOF
fastestmirror=1
max_parallel_downloads=10
EOF
    if [ $? -ne 0 ]; then
        print_error "Failed to set DNF configs."
        # Soft fail: Continue even if this fails
    fi
    print_success "DNF configs set"
    return 0
}


upgrade_dnf() {
    print_in_purple " • Upgrading DNF packages... "

    sudo dnf upgrade -y || {
        print_error "Failed to upgrade packages."
        # Soft fail: Continue even if this fails
    }

    return 0
}


main() {
   
    set_dnf_configs
    upgrade_dnf
   
}

main
