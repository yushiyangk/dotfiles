#!/usr/bin/env bash

# Update from remote git repository and install dotfiles
# Usage: ./update_dotfiles.sh
#
# Yu Shiyang <yu.shiyang@gnayihs.uy>

# Update from git repository and install
git pull --ff-only && ./install_dotfiles.sh

# Check if bash
if [ -n "$BASH" ] || [ -n "$BASH_VERSION"]; then
	profiled=0
	if [ "$profiled" -eq 0 ] && [ -x "$HOME/.bash_profile" ]; then
		source "$HOME/.bash_profile"
		profiled=1
	fi
	if [ "$profiled" -eq 0 ] && [ -x "$HOME/.bash_login" ]; then
		source "$HOME/.bash_login"
		profiled=1
	fi
	if [ "$profiled" -eq 0 ] && [ -x "$HOME/.profile" ]; then
		source "$HOME/.profile"
		profiled=1
	fi
fi
