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

# KITTY TERMINAL EMULATOR

install_terminal_and_prompt() {

        print_in_purple "\n • Installing kitty terminal emulator and starship prompt \n\n"

        # download and setup some additional fonts for kitty & starship prompt
        sudo mkdir /usr/share/fonts/nerd-fonts
        curl https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraMono.zip -o FiraMono.zip \
            && sudo unzip FiraMono.zip -d /usr/share/fonts/nerd-fonts

        sudo dnf install -y kitty

        mkdir ~/.config/kitty
        ln ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf

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

    sudo dnf install -y cronie
    sudo dnf install -y lazygit
    sudo dnf install -y tldr

}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

	dev_tools_group

    install_terminal_and_prompt

    install_typescript

    install_VSCode_and_set_inotify_max_user_watches

    install_misc_tools

}

main
