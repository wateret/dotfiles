#!/usr/bin/env bash

# Single files
stow -v -t $HOME files

# Directories should be handled in this way
stow -v -t $HOME/.config -d dirs .config
