#!/bin/bash

________          __    _____.__.__                 
\______ \   _____/  |__/ ____\__|  |   ____   ______
 |    |  \ /  _ \   __\   __\|  |  | _/ __ \ /  ___/
 |    `   (  <_> )  |  |  |  |  |  |_\  ___/ \___ \ 
/_______  /\____/|__|  |__|  |__|____/\___  >____  >
        \/                                \/     \/ 

# clone dotfile repo to $HOME
git clone --depth=1 https://github.com/HiIamChaitanya/dotfiles.git ~/dotfiles

# install dotfiles
~/dotfiles/install.sh
