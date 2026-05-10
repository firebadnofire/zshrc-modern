# zshrc

Multi-distro Zsh deployment repository for installing a shared shell setup across several Linux distributions and FreeBSD.

## Overview

This repository is organized around a simple deployment pipeline:

1. `init.sh` is the remote bootstrap script.
2. `zsh.sh` is the interactive installer and deployment entry point.
3. `zshrc` is the runtime shell entry point.
4. `zshrc.d/*.zrc` contains shared shell modules.
5. `user-selection/*.zrc` contains distro-specific and optional feature overlays.

The installer deploys a common Zsh base, then adds overlays for the selected package manager and optional features.

The repository can now be used in two ways:

- remote-first through the published bootstrap URL
- locally from a checked-out clone, where `zsh.sh` copies assets from the repository instead of re-downloading them

## Bootstrap

To start from the published remote bootstrap script:

```bash
curl -fSsL https://raw.githubusercontent.com/firebadnofire/zshrc-modern/refs/heads/main/init.sh | bash
```
`init.sh` downloads the current installer payloads into `/tmp` and prompts you to run `/tmp/zsh.sh`.

You can also run the installer directly from a local checkout:

```bash
bash ./zsh.sh
```

When run locally, `zsh.sh` prefers repository files over remote downloads.

## Repository Layout

```text
.
├── README.md
├── init.sh
├── zsh.sh
├── zshrc
├── fastfetch.sh
├── golang.sh
├── firebadnofire.zsh-theme
├── zshrc.d/
│   ├── 00-paths.zrc
│   ├── 02-git-signing.zrc
│   ├── 03-system-aliases.zrc
│   ├── 05-tools.zrc
│   ├── 99-post.zrc
│   └── suppress-warning.zrc
└── user-selection/
    ├── 04-pkg-arch.zrc
    ├── 04-pkg-debian.zrc
    ├── 04-pkg-freebsd.zrc
    ├── 04-pkg-gentoo.zrc
    ├── 04-pkg-opensuse-tumble.zrc
    ├── 04-pkg-rhel.zrc
    ├── 06-mullvad.zrc
    └── 07-warn-docker.zrc
```

## Key Components

### `init.sh`

Remote bootstrap script intended to be fetched over `curl | bash`. It downloads:

- `zsh.sh`
- `fastfetch.sh`
- `golang.sh`

### `zsh.sh`

Main deployment script. It provides an interactive menu for:

- installing base packages for a supported distro
- deploying the shared Zsh configuration
- installing Rust
- installing Fastfetch
- installing Go
- enabling Mullvad aliases
- enabling Docker SELinux reminders
- generating a local SSH key

This script is the main place where distro package installation is defined. It now centralizes:

- shared remote asset path handling
- local-versus-remote asset deployment
- distro overlay selection
- backup of an existing `~/.zshrc` before replacement

### `zshrc`

Runtime shell entry point. It:

- exits for non-interactive shells
- sets common environment defaults
- bootstraps Oh My Zsh
- ensures the custom theme is present
- loads all `~/.zshrc.d/*.zrc` modules

If Oh My Zsh is missing, it exits cleanly instead of partially bootstrapping a broken shell.

### `zshrc.d/`

Shared modules loaded for every configured shell:

- `00-paths.zrc`: common `PATH` and tool environment setup
- `02-git-signing.zrc`: Git signing configuration using SSH or GPG
- `03-system-aliases.zrc`: general aliases and helper commands
- `05-tools.zrc`: network/tool variables and helper aliases
- `99-post.zrc`: startup diagnostics and final shell post-load actions
- `suppress-warning.zrc`: placeholder file to avoid empty-glob issues

### `user-selection/`

Selectable overlays copied into `~/.zshrc.d` by the installer.

Package manager overlays:

- `04-pkg-arch.zrc`
- `04-pkg-debian.zrc`
- `04-pkg-freebsd.zrc`
- `04-pkg-gentoo.zrc`
- `04-pkg-opensuse-tumble.zrc`
- `04-pkg-rhel.zrc`

Each package overlay defines a common user-facing interface:

- package upgrade count on shell startup
- `ins`
- `update`
- `upgrade`
- `search`
- `rem`
- `PKGMGR`

Optional overlays:

- `06-mullvad.zrc`: adds the `mlex` alias when `mullvad-exclude` is installed
- `07-warn-docker.zrc`: warns before selected Docker commands to remind about `:Z` flags

## Supported Distros

Current base package installation support in `zsh.sh`:

- Debian
- Arch Linux
- RHEL-compatible systems
- OpenSUSE
- FreeBSD
- Gentoo

Additional distro-aware support exists in `fastfetch.sh`, which includes several extra platforms for Fastfetch installation.

`golang.sh` is intentionally Linux-only and now exits clearly on unsupported operating systems.

## Deployment Model

The project separates installation from runtime behavior:

- installation logic lives in `zsh.sh`
- runtime shell behavior lives in `zshrc` plus the `.zshrc.d` modules
- distro-specific runtime behavior is injected by copying one of the `04-pkg-*.zrc` files into `~/.zshrc.d`

This means the runtime shell config stays mostly uniform while package-manager commands vary by selected distro.

## Typical Flow

1. Run the bootstrap command.
2. Execute `/tmp/zsh.sh`.
3. Select your distro to install base packages and the matching package-manager overlay.
4. Select `Install Zshrc` to deploy the runtime configuration.
5. Optionally install Rust, Fastfetch, Go, Mullvad aliases, or Docker reminders.
6. Start a new Zsh session.

## Notes and Caveats

- `init.sh` is still a remote bootstrap script, but `zsh.sh` can now deploy directly from a local checkout.
- Startup diagnostics remain enabled by default, but they can now be disabled by setting `ZSHRC_SHOW_STARTUP_INFO=0`.
- Some shared aliases assume Linux tooling such as `systemctl`, so not every shared module is fully portable across every supported platform.
- The theme fetch path is now aligned with the repository's raw asset path through `ZSHRC_REMOTE_BASE`.
- Install-time generated files still exist, such as `~/.zshrc.d/08-golang.zrc`.

## Development

When changing this repository, keep the current layering intact:

- update `zsh.sh` when changing installer behavior
- update `zshrc` for shell bootstrap/runtime changes
- update `zshrc.d/` for shared shell behavior
- update `user-selection/` for distro-specific or optional overlays

If you add a new distro, update both:

1. the package installation logic in `zsh.sh`
2. the matching `user-selection/04-pkg-*.zrc` overlay
