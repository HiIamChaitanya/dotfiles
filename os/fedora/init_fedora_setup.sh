#!/bin/bash

readonly DOT="$HOME/dotfiles"

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set_hostname() {

    print_in_purple "\n • Setting hostname... \n\n"

    read -r -p "$(print_in_yellow "Type in your hostname: ") " HOSTNAME
    if [[ -z "$HOSTNAME" ]]; then
        print_in_red "Hostname cannot be empty. Exiting."
        return 1
    fi
    sudo hostnamectl set-hostname "$HOSTNAME"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set_dnf_configs() {

    print_in_purple "\n • Setting DNF configs... \n\n"

    sudo tee -a /etc/dnf/dnf.conf >/dev/null <<EOF
fastestmirror=1
max_parallel_downloads=10
EOF

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

upgrade_dnf() {

    print_in_purple "\n • Upgrading... \n\n"

    sudo dnf upgrade --refresh -y &&
        sudo dnf check &&
        sudo dnf autoremove -y

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update_device_firmware() {

    print_in_purple "\n • Updating device firmwares... \n\n"

    sudo fwupdmgr get-devices &&
        sudo fwupdmgr refresh --force &&
        sudo fwupdmgr get-updates &&
        sudo fwupdmgr update -y

    print_in_yellow "\n !!! Don't restart yet if doing full setup! \n\n"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

    if ! set_hostname; then
        return 1
    fi

    set_dnf_configs &&
        upgrade_dnf &&
        update_device_firmware

}

main
