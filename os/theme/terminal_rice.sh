#!/usr/bin/env bash

set -o pipefail

print_header() {
    echo "
    Setup shell colorscripts
    "
}

install_colorscripts() {
    local repo_url="https://gitlab.com/dwt1/shell-color-scripts.git"
    local install_dir="/opt/shell-color-scripts"
    local bin_dir="/usr/local/bin"

    echo "Installing shell colorscripts..."

    # Create temporary directory
    local temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT

    # Clone repository
    git clone --depth 1 "$repo_url" "$temp_dir"

    # Remove existing installation
    sudo rm -rf "$install_dir"

    # Create installation directory
    sudo mkdir -p "$install_dir/colorscripts"

    # Copy colorscripts
    sudo cp -r "$temp_dir/colorscripts" "$install_dir"

    # Install colorscript command
    sudo cp "$temp_dir/colorscript.sh" "$bin_dir/colorscript"
    sudo chmod +x "$bin_dir/colorscript"

    echo "Shell colorscripts installed successfully!"
}

main() {
    print_header
    install_colorscripts
}

main
