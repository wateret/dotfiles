#!/usr/bin/env bash

set -e

# Single files
echo "stow files ~/"
stow -v -t $HOME files

# Directories
echo "stow dir ~/.config"

# Ensure each top-level package dir under dirs/.config is foldable:
# if the target already exists as a real directory (not a symlink), abort.
for pkg in dirs/.config/*/; do
  name=$(basename "$pkg")
  target="$HOME/.config/$name"
  if [ -e "$target" ] && [ ! -L "$target" ] && [ -d "$target" ]; then
    echo "error: $target exists as a real directory; remove or move it before stowing" >&2
    exit 1
  fi
done

stow -v -t $HOME/.config -d dirs .config
