#!/usr/bin/env bash
# Make agy run through QEMU: register the binfmt_misc rule (sudo, one time),
# write the ~/.local/bin/agy launcher, and download agy if it is missing.
set -euo pipefail
root=$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")
real="$HOME/.local/lib/antigravity/agy.agyqemu"
rule_name=agy-qemu
rule=":$rule_name:E::agyqemu::$root/bin/agy-qemu:"
conf="/etc/binfmt.d/$rule_name.conf"
[[ -x "$root/tools/qemu/usr/bin/qemu-x86_64" ]] || { echo "Missing QEMU. Run: bash $root/setup.sh" >&2; exit 1; }
[[ "$root" != *" "* ]] || { echo 'The repository path must not contain spaces.' >&2; exit 1; }
if ! { [[ -f "$conf" ]] && [[ $(cat "$conf") == "$rule" ]] && [[ -e /proc/sys/fs/binfmt_misc/$rule_name ]]; }; then
  echo "Registering binfmt_misc rule (sudo):"; echo "  $rule"
  echo "$rule" | sudo tee "$conf" >/dev/null
  [[ -e /proc/sys/fs/binfmt_misc/$rule_name ]] && echo -1 | sudo tee "/proc/sys/fs/binfmt_misc/$rule_name" >/dev/null
  echo "$rule" | sudo tee /proc/sys/fs/binfmt_misc/register >/dev/null
fi
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/agy" <<LAUNCHER
#!/bin/sh
# Installed by agy-core2-duo. The kernel runs the real binary through QEMU.
[ "\$1" = upgrade ] && { shift; exec "$root/upgrade.sh" "\$@"; }
export AGY_CLI_DISABLE_AUTO_UPDATE=true
exec "$real" "\$@"
LAUNCHER
chmod +x "$HOME/.local/bin/agy"
[[ -f "$real" ]] || "$root/upgrade.sh"
echo "agy $("$HOME/.local/bin/agy" --version | tail -1) runs through QEMU."
