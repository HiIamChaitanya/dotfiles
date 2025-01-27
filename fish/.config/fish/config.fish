if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ~/.config/fish/config.fish

starship init fish | source

# get random art
colorscript -r


set -g fish_greeting


# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# rust
source "$HOME/.cargo/env.fish"

