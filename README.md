# zshrc

Multi-distro Zsh deployment repository for installing a shared shell setup across several Linux distributions and FreeBSD.

## Overview

This repository is organized around a simple deployment pipeline:

1. `init.sh` is the remote bootstrap script.
2. `downloads/zsh.sh` is the interactive installer and deployment entry point.
3. `downloads/zshrc` is the runtime shell entry point.
4. `downloads/*.zrc` contains shared shell modules plus distro-specific and optional overlays.

The installer deploys a common Zsh base, then adds overlays for the selected package manager and optional features.

The repository can now be used in two ways:

- remote-first through the published bootstrap URL
- locally from a checked-out clone, where `downloads/zsh.sh` copies assets from the repository instead of re-downloading them

Repository updates are handled separately from distro package refreshes:

- `zupdate` checks the SHA-256 manifest and only re-downloads changed files from `downloads/`
- `update` remains the distro-specific package manager refresh command inside each `04-pkg-*.zrc`

## Bootstrap

To start from the published remote bootstrap script:

```bash
curl -fSsL https://raw.githubusercontent.com/firebadnofire/zshrc-modern/refs/heads/main/init.sh | bash
```
`init.sh` downloads the current installer payloads from `downloads/` into `/tmp` and prompts you to run `/tmp/zsh.sh`.

You can also run the installer directly from a local checkout:

```bash
bash ./downloads/zsh.sh
```

When run locally, `downloads/zsh.sh` prefers repository files over remote downloads.

## Repository Layout

```text
.
├── README.md
├── init.sh
├── downloads/
│   ├── 00-paths.zrc
│   ├── 02-git-signing.zrc
│   ├── 03-system-aliases.zrc
│   ├── 04-pkg-arch.zrc
│   ├── 04-pkg-debian.zrc
│   ├── 04-pkg-freebsd.zrc
│   ├── 04-pkg-gentoo.zrc
│   ├── 04-pkg-opensuse-tumble.zrc
│   ├── 04-pkg-rhel.zrc
│   ├── 05-tools.zrc
│   ├── 06-mullvad.zrc
│   ├── 07-warn-docker.zrc
│   ├── 99-post.zrc
│   ├── fastfetch.sh
│   ├── firebadnofire.zsh-theme
│   ├── golang.sh
│   ├── suppress-warning.zrc
│   ├── zsh.sh
│   └── zshrc
```

## Key Components

### `init.sh`

Remote bootstrap script intended to be fetched over `curl | bash`. It downloads:

- `zsh.sh`
- `fastfetch.sh`
- `golang.sh`

### `downloads/zsh.sh`

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

### `downloads/zshrc`

Runtime shell entry point. It:

- exits for non-interactive shells
- sets common environment defaults
- bootstraps Oh My Zsh
- ensures the custom theme is present
- loads all `~/.zshrc.d/*.zrc` modules
- exports `ZMODULES` and `PRETTY_ZMODULE_NAMES`
- exposes `zupdate` for SHA-based per-file repository updates
- prints `zmodules: ...` after startup so the loaded module order is visible

If Oh My Zsh is missing, it exits cleanly instead of partially bootstrapping a broken shell.

### `downloads/*.zrc`

Flat payload directory for modules and overlays copied into `~/.zshrc.d` by the installer.

Shared modules:

- `00-paths.zrc`: common `PATH` and tool environment setup
- `02-git-signing.zrc`: Git signing configuration using SSH or GPG
- `03-system-aliases.zrc`: general aliases and helper commands
- `05-tools.zrc`: network/tool variables and helper aliases
- `99-post.zrc`: startup diagnostics and final shell post-load actions
- `suppress-warning.zrc`: placeholder file to avoid empty-glob issues

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

### `downloads.sha256sum`

Root-level SHA-256 manifest for every file under `downloads/`. It is used by `zupdate` to compare the local state against upstream and only fetch files whose hashes differ.

To refresh it locally, run:

```bash
./refresh-sha256sum.sh
```

## Supported Distros

Current base package installation support in `downloads/zsh.sh`:

- Debian
- Arch Linux
- RHEL-compatible systems
- OpenSUSE
- FreeBSD
- Gentoo

Additional distro-aware support exists in `downloads/fastfetch.sh`, which includes several extra platforms for Fastfetch installation.

`downloads/golang.sh` is intentionally Linux-only and now exits clearly on unsupported operating systems.

## Deployment Model

The project separates installation from runtime behavior:

- installation logic lives in `downloads/zsh.sh`
- runtime shell behavior lives in `downloads/zshrc` plus the `.zshrc.d` modules
- distro-specific runtime behavior is injected by copying one of the `04-pkg-*.zrc` files from `downloads/` into `~/.zshrc.d`

This means the runtime shell config stays mostly uniform while package-manager commands vary by selected distro.

## Typical Flow

1. Run the bootstrap command.
2. Execute `/tmp/zsh.sh`.
3. Select your distro to install base packages and the matching package-manager overlay.
4. Select `Install Zshrc` to deploy the runtime configuration.
5. Optionally install Rust, Fastfetch, Go, Mullvad aliases, or Docker reminders.
6. Start a new Zsh session.

## Notes and Caveats

- `init.sh` is still a remote bootstrap script, but `downloads/zsh.sh` can deploy directly from a local checkout.
- Startup diagnostics remain enabled by default, but they can now be disabled by setting `ZSHRC_SHOW_STARTUP_INFO=0`.
- Some shared aliases assume Linux tooling such as `systemctl`, so not every shared module is fully portable across every supported platform.
- The theme fetch path is now aligned with `downloads/` under `ZSHRC_REMOTE_BASE`.
- `update` stays tied to distro package managers; use `zupdate` for repository file refreshes.
- Install-time generated files still exist, such as `~/.zshrc.d/08-golang.zrc`.

## Development

When changing this repository, keep the current layering intact:

- update `downloads/zsh.sh` when changing installer behavior
- update `downloads/zshrc` for shell bootstrap/runtime changes
- update files in `downloads/` for shared shell behavior and overlays
- update `downloads.sha256sum` whenever the contents of `downloads/` change

If you add a new distro, update both:

1. the package installation logic in `downloads/zsh.sh`
2. the matching `downloads/04-pkg-*.zrc` overlay
