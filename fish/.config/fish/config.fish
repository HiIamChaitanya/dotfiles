if status is-interactive
    # Commands to run in interactive sessions can go here

    # get random art
    colorscript -r
end

# ~/.config/fish/config.fish

set fish_greeting

# starship
starship init fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# rust
source "$HOME/.cargo/env.fish"
starship init fish | source
