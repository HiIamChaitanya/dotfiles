#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
	. "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fonts() {

	print_in_purple "\n • Install Fonts\n\n"

	sudo dnf install -y fira-code-fonts 'mozilla-fira*' 'google-roboto*'

	# Installing fonts for dotfiles/fonts

	mkdir -p ~/.local/share/fonts

	find ~/dotfiles/fonts -type f \( -iname "*.ttf" -o -iname "*.otf" \) -exec cp {} ~/.local/share/fonts/ \;

	sudo fc-cache -fv

}

style_setup_help() {
	echo "
		Setup fonts:
		First start by going to the comic-code-fonts folder and installing the fonts (gnome-font-viewer).
		Remenber to move the fontconfig folder under .config

		Go to Gnome Tweaks and change the following in Fonts

		- Interface Text: Fira Sans Book 10
		- Document Text: Roboto Slab Regular 11
		- Monospace Text: Fira Mono Regular 11 OR Comic Code 11
		- Hinting: Slight
		- Antialiasing: Standard (greyscale)
		- Scaling Factor: 1.00
	"
}

gnome_theme_setup() {
	print_in_purple "\n • Gnome Theme Setup\n\n"

	readonly THEME_DIR="$HOME/dotfiles/gnome-themes"
	readonly THEME_NAME="WhiteSur-gtk-theme"
	readonly THEME_REPO="https://github.com/vinceliuice/$THEME_NAME.git"

	# Clone the theme repository
	git clone --depth=1 "$THEME_REPO" "$THEME_DIR/$THEME_NAME"

	# Install the theme
	cd "$THEME_DIR/$THEME_NAME"
	chmod +x install.sh
	./install.sh -c dark --shell -i fedora -h smaller -sf -a all -m -l -HD --round --darker

	# Tweak the theme
	chmod +x tweaks.sh
	./tweaks.sh -F -c dark

	# Allow flatpak to use the theme
	sudo flatpak override --filesystem=xdg-config/gtk-3.0
	sudo flatpak override --filesystem=xdg-config/gtk-4.0

	# Clean up
	cd .. && rm -rf "$THEME_NAME"

	print_success "Gnome theme setup complete."

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

	print_in_purple "\n • Start setting up OS theme...\n\n"

	install_fonts

	style_setup_help

	gnome_theme_setup

}

main
