# Antigravity CLI on a Core 2 Duo

Runs Google's Antigravity CLI (`agy`) on an x86-64 CPU without PCLMUL, SSE4.2 or AVX
(tested: Core 2 Duo P8600, Linux Mint 22.3). The official binary stops with
`This binary was compiled with pclmul enabled`. QEMU translates the missing instructions.
Same approach as `opencode-core2-duo`; the two do not share files.

## Install
    bash setup.sh   # downloads QEMU into tools/, no root
    ./install.sh    # sudo once for the binfmt_misc rule; downloads agy
    agy             # first start: sign in with the link it prints

## How it works
- The real binary is `~/.local/lib/antigravity/agy.agyqemu`.
- `/etc/binfmt.d/agy-qemu.conf` makes the kernel run every `*.agyqemu` file with
  `bin/agy-qemu`, which runs `qemu-x86_64 -cpu max`. If agy starts itself again, that also goes through QEMU.
- `~/.local/bin/agy` is a small launcher. It sets `AGY_CLI_DISABLE_AUTO_UPDATE=true`,
  because a self-update would install a native binary that crashes.

## Upgrade
    agy upgrade     # latest release; checks SHA-512 and test-runs it before switching
Roll back: `cp ~/.local/lib/antigravity/agy.previous.agyqemu ~/.local/lib/antigravity/agy.agyqemu`

## Remove
    ./uninstall.sh
