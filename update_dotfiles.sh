#!/usr/bin/env bash

# Update from remote git repository and install dotfiles
# Usage: ./update_dotfiles.sh
#
# Yu Shiyang <yu.shiyang@gnayihs.uy>

# Update from git repository and install
git pull --ff-only && ./install_dotfiles.sh

# Check if bash
if [ -n "$BASH" ]; then
	source "$HOME/.bash_profile"
fi
