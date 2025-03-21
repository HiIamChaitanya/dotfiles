#!/bin/bash

# Configuration
DOT="$HOME/dotfiles"
FONT_DIR="$DOT/fonts"
THEME_DIR="$DOT/gnome-themes"
THEME_NAME="WhiteSur-gtk-theme"
THEME_REPO="https://github.com/vinceliuice/$THEME_NAME.git"
CURSOR_NAME="WhiteSur-cursors"
CURSOR_REPO="https://github.com/vinceliuice/$CURSOR_NAME.git"

# Source utility functions
cd "$(dirname "${BASH_SOURCE[0]}")" && . "$DOT/setup/utils.sh"

# Function: Install Fonts
install_fonts() {
    print_in_purple "\n • Install Fonts\n\n"

    sudo dnf install -y fira-code-fonts 'mozilla-fira*' 'google-roboto*'

    mkdir -p ~/.local/share/fonts
    find "$FONT_DIR" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -exec cp {} ~/.local/share/fonts/ \;

    sudo fc-cache -fv
}

# Function: Display Style Setup Help
style_setup_help() {
    cat <<EOF

        Setup fonts:
        First start by going to the comic-code-fonts folder and installing the fonts (gnome-font-viewer).
        Remember to move the fontconfig folder under .config

        Go to Gnome Tweaks and change the following in Fonts:

        - Interface Text: Fira Sans Book 10
        - Document Text: Roboto Slab Regular 11
        - Monospace Text: Fira Mono Regular 11 OR Comic Code 11
        - Hinting: Slight
        - Antialiasing: Standard (greyscale)
        - Scaling Factor: 1.00
EOF
}

# Function: Setup Gnome Shell Theme
gnome_shell_theme_setup() {
    print_in_purple "\n • Gnome Shell Theme Setup\n\n"

    git clone --depth=1 "$THEME_REPO" "$THEME_DIR/$THEME_NAME"
    (
        cd "$THEME_DIR/$THEME_NAME"
        chmod +x install.sh tweaks.sh
        ./install.sh -c dark --shell -i fedora -h smaller -sf -a all -m -l -HD --round --darker
        ./tweaks.sh -F -c dark
    )

    sudo flatpak override --filesystem=xdg-config/gtk-3.0
    sudo flatpak override --filesystem=xdg-config/gtk-4.0

    rm -rf "$THEME_DIR/$THEME_NAME"

    print_success "Gnome theme setup complete."
}

# Function: Setup Gnome Cursor Theme
gnome_cursor_theme_setup() {
    print_in_purple "\n • Gnome Cursor Theme Setup\n\n"

    git clone --depth=1 "$CURSOR_REPO" "$THEME_DIR/$CURSOR_NAME"
    (
        cd "$THEME_DIR/$CURSOR_NAME"
        chmod +x install.sh
        sudo ./install.sh
    )
    rm -rf "$THEME_DIR/$CURSOR_NAME"

    print_success "Gnome cursor theme setup complete."
}

# Function: Interactive Selection
select_function() {
    local options=("install_fonts" "style_setup_help" "gnome_shell_theme_setup" "gnome_cursor_theme_setup" "all" "exit")
    PS3="Select a function to run: "
    select opt in "${options[@]}"; do
        case "$opt" in
            "install_fonts") install_fonts; break ;;
            "style_setup_help") style_setup_help; break ;;
            "gnome_shell_theme_setup") gnome_shell_theme_setup; break ;;
            "gnome_cursor_theme_setup") gnome_cursor_theme_setup; break ;;
            "all") main; break ;;
            "exit") exit 0 ;;
            *) echo "Invalid option: $REPLY";;
        esac
    done
}

# Function: Main Execution
main() {
    print_in_purple "\n • Start setting up OS theme...\n\n"
    install_fonts
    style_setup_help
    gnome_shell_theme_setup
    gnome_cursor_theme_setup
}

# Entry Point
select_function