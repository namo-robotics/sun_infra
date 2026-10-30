#!/usr/bin/env bash
# Make the persistent compiler cache writable by the development user.
# Container startup preserves the compiler and project dependencies in the image.
set -euo pipefail

cache_dir="${CCACHE_DIR:-$HOME/.cache/ccache}"
sudo chown -R "$(id -u):$(id -g)" "$cache_dir"
mkdir -p "$HOME/.config/dconf"
