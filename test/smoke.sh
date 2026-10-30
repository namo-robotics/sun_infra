#!/usr/bin/env bash
# Verify the applied template's user, mounted cache, and startup hook.
set -euo pipefail
source /etc/os-release
test "$ID:$VERSION_ID" = ubuntu:26.04
test "$(id -un)" = ubuntu
test "$CCACHE_MAXSIZE" = 10G
test -d "$HOME/.config/dconf"
test -w "$CCACHE_DIR"
test "$(stat -c %u "$CCACHE_DIR")" = "$(id -u)"
touch "$CCACHE_DIR/sun-infra-smoke-test"
rm "$CCACHE_DIR/sun-infra-smoke-test"
test -f .devcontainer/devcontainer.json
