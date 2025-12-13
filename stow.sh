#!/usr/bin/env bash

# Single files
stow -t $HOME -v files

# Directories should be added separately (Like, .config/???)
stow -t $HOME -d dirs -v nvim
