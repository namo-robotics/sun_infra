#!/usr/bin/env bash
# Verify the shared image's platform, toolchain, permissions, and native linking.
set -euo pipefail

source /etc/os-release
test "$ID:$VERSION_ID" = ubuntu:26.04
test "$(id -un)" = ubuntu
test "$(sudo -n id -u)" = 0

for tool in clang clang++ clangd clang-format-20 lldb-20 ld.lld-20 llvm-config-20 \
    cmake ninja git ssh curl python3 pkg-config protoc ccache gdb \
    x86_64-linux-musl-gcc x86_64-linux-musl-g++ x86_64-linux-musl-readelf; do
    command -v "$tool" >/dev/null
done

[[ $(llvm-config-20 --version) == 20.* ]]
test "$(readlink -f /usr/bin/clang)" = "$(readlink -f /usr/bin/clang-20)"

test -w "$HOME/.cache/ccache"
test -w "$HOME/.config/dconf"
test -w "$HOME/.vscode-server/data/User"

mkdir -p tmp
scratch=$(mktemp -d "$PWD/tmp/dev-image.XXXXXX")
trap 'rm -rf "$scratch"' EXIT

cat > "$scratch/main.cpp" <<'CPP'
#include <iostream>

/** Checks that the C++ standard library links and runs. */
int main() {
    std::cout << "toolchain ready";
}
CPP

clang++ "$scratch/main.cpp" -o "$scratch/check"
test "$("$scratch/check")" = 'toolchain ready'

# Exercise the musl C++ runtime and verify that no dynamic loader or libraries are needed.
x86_64-linux-musl-g++ -static "$scratch/main.cpp" -o "$scratch/static-check"
test "$("$scratch/static-check")" = 'toolchain ready'
x86_64-linux-musl-readelf -l "$scratch/static-check" > "$scratch/program-headers"
x86_64-linux-musl-readelf -d "$scratch/static-check" > "$scratch/dynamic-section"
if grep -q INTERP "$scratch/program-headers" || grep -q NEEDED "$scratch/dynamic-section"; then
    echo 'The musl test binary requires dynamic linking.' >&2
    exit 1
fi

printf '%s\n' 'Shared development image smoke test passed.'
