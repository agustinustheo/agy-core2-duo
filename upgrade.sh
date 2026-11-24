#!/usr/bin/env bash
# Download the latest Antigravity CLI (agy), check its SHA-512, test it through QEMU,
# then make it the active binary. Usage: agy upgrade   (or ./upgrade.sh)
set -euo pipefail
root=$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")
libexec="$HOME/.local/lib/antigravity"
real="$libexec/agy.agyqemu"
manifest_url="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_amd64.json"
field() { sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$manifest"; }
manifest=$(curl -fsSL "$manifest_url")
version=$(field version); url=$(field url); sha512=$(field sha512)
[[ -n "$url" && -n "$sha512" ]] || { echo 'Could not read the release manifest.' >&2; exit 1; }
if [[ -f "$real" ]] && [[ $("$real" --version 2>/dev/null | tail -1) == "$version" ]]; then
  echo "agy $version is already installed."; exit 0
fi
mkdir -p "$libexec"
scratch=$(mktemp -d "$libexec/.download-XXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
echo "Downloading agy $version"
curl -fsSL -o "$scratch/pkg" "$url"
[[ $(sha512sum "$scratch/pkg" | cut -d' ' -f1) == "$sha512" ]] || { echo 'Checksum mismatch. Nothing changed.' >&2; exit 1; }
case "$url" in
  *.tar.gz*) tar -xzf "$scratch/pkg" -C "$scratch" antigravity; mv "$scratch/antigravity" "$scratch/agy.agyqemu" ;;
  *) mv "$scratch/pkg" "$scratch/agy.agyqemu" ;;
esac
chmod +x "$scratch/agy.agyqemu"
got=$("$scratch/agy.agyqemu" --version | tail -1)
[[ "$got" == "$version" ]] || { echo "Test run printed '$got', expected $version. Nothing changed." >&2; exit 1; }
[[ -f "$real" ]] && cp -f "$real" "$libexec/agy.previous.agyqemu"
mv -f "$scratch/agy.agyqemu" "$real"
echo "agy $version is installed. The old version is kept as $libexec/agy.previous.agyqemu"
