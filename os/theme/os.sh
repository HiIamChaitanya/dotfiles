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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

	print_in_purple "\n • Start setting up OS theme...\n\n"

	install_fonts

	style_setup_help

}

main
