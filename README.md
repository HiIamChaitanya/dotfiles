# Dotfiles

## install

```
bash <(curl -Ls https://raw.githubusercontent.com/HiIamChaitanya/dotfiles/refs/heads/main/setup.sh) 
```

## TO-DOs

- add fonts to the list
- GTK config with extensions and themes ,keybindings ,etc.
- adding tilling manager config from current main workstation with wayland.
- adding nixpkg

## ❔ What does this do?

These are the base "dotfiles" that I use for setting up a new freshly installed [**Fedora OS**](https://getfedora.org/) (40+) to my tastes for development work. The goal of the setup.sh script is to basically setup everything the way I like. Broadly said it covers:

- initial updates
- installing some basic gnome tweaks, linux package managers and development related package managers
- installing dev tooling and packages
- installing various applications I find useful
- install pop shell for window tiling - [Pop!\_OS](https://pop.system76.com/)
- edits some settings and keyboard shortcuts
- creates bash and git config files + sets up an SSH key for Github
- installs some fonts
- installs kitty terminal emulator and starship prompt
- installs some neovim plugins
- installs some misc gnome tweaks

## 📝 Note

- clone the dotfiles repo into your home directory
- this scrip is ment to be used with Fedora 41

## ⚠️ Warning

**This script will delete and overwrite all of your existing dotfiles.**

## ✅ Setup complete

You should be good to go!
