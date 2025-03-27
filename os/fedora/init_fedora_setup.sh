#!/usr/bin/env bash

set -euo pipefail

# Configuration
readonly DOT="$HOME/dotfiles"

# Source utility functions
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
. "$DOT/setup/utils.sh" || exit 1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set_hostname() {
    print_in_purple " • Setting hostname..."

    if [[ -z $(hostname) ]]; then
        read -r -p "$(print_in_yellow "Type in your hostname: ") " HOSTNAME
        if [[ -z "$HOSTNAME" ]]; then
            print_error "Hostname cannot be empty. Exiting."
            return 1
        fi
        sudo hostnamectl set-hostname "$HOSTNAME"
        if [ $? -ne 0 ]; then
            print_error "Failed to set hostname."
            return 1
        fi
        print_success "Hostname set to $HOSTNAME"
    else
       print_in_green "Hostname already set to $(hostname), skipping."
    fi
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

upgrade_dnf() {
    print_in_purple " • Upgrading DNF packages... "

    sudo dnf upgrade -y || {
        print_error "Failed to upgrade packages."
        # Soft fail: Continue even if this fails
    }

    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update_device_firmware() {
    print_in_purple " • Updating device firmwares... "

    sudo fwupdmgr get-devices || {
        print_error "Failed to get device list."
        # Soft fail: Continue even if this fails
    }
    sudo fwupdmgr refresh --force || {
        print_error "Failed to refresh firmware metadata."
        # Soft fail: Continue even if this fails
    }
    sudo fwupdmgr get-updates || {
        print_error "Failed to get firmware updates."
        # Soft fail: Continue even if this fails
    }
    sudo fwupdmgr update -y || {
        print_error "Failed to update firmware."
        # Soft fail: Continue even if this fails
    }

    print_in_yellow " !!! Don't restart yet if doing full setup! "
    print_success "Firmware update process completed."

    return 0
   
}


# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
   
    #set hostname
    if ! set_hostname; then
        exit 1
    fi

    set_dnf_configs
    upgrade_dnf
    # update_device_firmware
    
}

main
