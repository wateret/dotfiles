#!/usr/bin/env bash

set -e

# Single files
echo "stow files ~/"
stow -v -t $HOME files

# Directories
echo "stow dir ~/.config"
stow -v -t $HOME/.config -d dirs .config
