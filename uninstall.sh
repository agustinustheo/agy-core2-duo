#!/usr/bin/env bash
# Remove the launcher, the binary and the binfmt_misc rule. Keeps ~/.gemini (sign-in and settings).
set -euo pipefail
rm -f "$HOME/.local/bin/agy"
rm -rf "$HOME/.local/lib/antigravity"
[[ -e /proc/sys/fs/binfmt_misc/agy-qemu ]] && echo -1 | sudo tee /proc/sys/fs/binfmt_misc/agy-qemu >/dev/null
sudo rm -f /etc/binfmt.d/agy-qemu.conf
echo 'agy removed.'
