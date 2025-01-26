#!/bin/bash

cd 

# clone dotfile repo to $HOME

git clone https://github.com/HiIamChaitanya/dotfiles.git --depth=1 ~/

cd dotfiles/ 

# install dotfiles

chmod +x install.sh

 ./install.sh