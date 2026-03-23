#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_RAW_BASE="${ZSHRC_REMOTE_BASE:-https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main}"

declare -A PKGS=(
    [debian]="aria2 zip make gnupg gnupg2 curl zsh git unzip sudo lsb-release p7zip-full fzy"
    [arch]="aria2 zip curl zsh make git unzip sudo fzy lsb-release"
    [rhel]="aria2 zip make gnupg gnupg2 curl zsh git unzip sudo lsb_release"
    [opensuse]="aria2 zip make gpg2 curl zsh git unzip sudo lsb-release fzy"
    [freebsd]="aria2 zip gmake gnupg curl zsh git unzip sudo fzy"
    [gentoo]="app-arch/zip app-arch/p7zip net-misc/curl app-shells/zsh dev-vcs/git app-arch/unzip app-admin/sudo app-misc/fzy"
)

declare -A DISTRO_OVERLAYS=(
    [debian]="user-selection/04-pkg-debian.zrc"
    [arch]="user-selection/04-pkg-arch.zrc"
    [rhel]="user-selection/04-pkg-rhel.zrc"
    [opensuse]="user-selection/04-pkg-opensuse-tumble.zrc"
    [freebsd]="user-selection/04-pkg-freebsd.zrc"
    [gentoo]="user-selection/04-pkg-gentoo.zrc"
)

SHARED_MODULES=(
    "zshrc.d/00-paths.zrc"
    "zshrc.d/02-git-signing.zrc"
    "zshrc.d/03-system-aliases.zrc"
    "zshrc.d/05-tools.zrc"
    "zshrc.d/99-post.zrc"
    "zshrc.d/suppress-warning.zrc"
)

copy_asset() {
    local relative_path=$1
    local destination=$2
    local source_path="${SCRIPT_DIR}/${relative_path}"

    mkdir -p "$(dirname "${destination}")"

    if [[ -f "${source_path}" ]]; then
        cp "${source_path}" "${destination}"
    else
        curl -fsSL "${REMOTE_RAW_BASE}/${relative_path}" -o "${destination}"
    fi
}

backup_existing_file() {
    local target=$1
    local backup_path

    [[ -f "${target}" ]] || return 0

    backup_path="${target}.bak.$(date +%Y%m%d%H%M%S)"
    cp "${target}" "${backup_path}"
    printf 'Backed up %s to %s\n' "${target}" "${backup_path}"
}

install_packages() {
    local os_type=$1

    echo "Installing packages for ${os_type}..."
    mkdir -p "${HOME}/.zshrc.d"

    case "${os_type}" in
        debian)
            sudo apt update
            sudo apt install -y ${PKGS[$os_type]}
            ;;
        arch)
            sudo pacman --noconfirm -S ${PKGS[$os_type]}
            ;;
        rhel)
            sudo dnf install -y ${PKGS[$os_type]} epel-release
            ;;
        opensuse)
            sudo zypper refresh
            sudo zypper --non-interactive install ${PKGS[$os_type]}
            ;;
        freebsd)
            sudo pkg update
            sudo pkg install -y ${PKGS[$os_type]}
            ;;
        gentoo)
            sudo emerge -av ${PKGS[$os_type]}
            ;;
        *)
            echo "Unsupported OS selection."
            return 1
            ;;
    esac
}

install_distro_overlay() {
    local os_type=$1
    local overlay_rel="${DISTRO_OVERLAYS[$os_type]:-}"

    if [[ -z "${overlay_rel}" ]]; then
        echo "No overlay defined for ${os_type}."
        return 1
    fi

    copy_asset "${overlay_rel}" "${HOME}/.zshrc.d/$(basename "${overlay_rel}")"
}

install_distro() {
    local os_type=$1

    install_packages "${os_type}"
    install_distro_overlay "${os_type}"
}

install_rust() {
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh
}

install_zshrc() {
    local module

    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo "Deploying Zsh config files..."
    mkdir -p "${HOME}/.zshrc.d" "${HOME}/.oh-my-zsh/themes" "${HOME}/.oh-my-zsh/plugins"

    backup_existing_file "${HOME}/.zshrc"
    copy_asset "zshrc" "${HOME}/.zshrc"
    copy_asset "firebadnofire.zsh-theme" "${HOME}/.oh-my-zsh/themes/firebadnofire.zsh-theme"

    for module in "${SHARED_MODULES[@]}"; do
        copy_asset "${module}" "${HOME}/.zshrc.d/$(basename "${module}")"
    done

    if [[ ! -d "${HOME}/.oh-my-zsh/plugins/cmdtime" ]]; then
        git clone https://github.com/tom-auger/cmdtime "${HOME}/.oh-my-zsh/plugins/cmdtime"
    fi
}

install_fastfetch() {
    echo "Installing fastfetch..."

    if [[ -x "/tmp/fastfetch.sh" ]]; then
        /tmp/fastfetch.sh
    elif [[ -x "${SCRIPT_DIR}/fastfetch.sh" ]]; then
        "${SCRIPT_DIR}/fastfetch.sh"
    else
        echo "Fastfetch script not found."
        return 1
    fi
}

install_rpi_extras() {
    echo "Installing Argon One case script..."
    curl -fsSL https://download.argon40.com/argon1.sh -o argon1.sh
    chmod +x argon1.sh
    sudo ./argon1.sh
    rm -f argon1.sh
}

install_local_ssh_key() {
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"

    if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
        echo "SSH ed25519 key already exists. Skipping."
        return
    fi

    echo "Generating new SSH ed25519 key..."
    ssh-keygen -t ed25519 -f "${HOME}/.ssh/id_ed25519" -N ""
    echo "Public key:"
    cat "${HOME}/.ssh/id_ed25519.pub"
}

install_optional_overlay() {
    local relative_path=$1

    copy_asset "${relative_path}" "${HOME}/.zshrc.d/$(basename "${relative_path}")"
}

install_golang() {
    if [[ -x "/tmp/golang.sh" ]]; then
        /tmp/golang.sh
    elif [[ -x "${SCRIPT_DIR}/golang.sh" ]]; then
        "${SCRIPT_DIR}/golang.sh"
    else
        echo "golang.sh not found."
        return 1
    fi
}

show_menu() {
    local choice

    while true; do
        cat <<'EOF'

Menu:
1. Install for Debian
2. Install for Arch
3. Install for RHEL
4. Install for OpenSUSE
5. Install for FreeBSD
6. Install for Gentoo
7. Raspberry Pi Extras
8. Install Rust
9. Install Zshrc
10. Install Fastfetch
11. Install Mullvad aliases
12. Install Docker warn for SELinux
13. Install GoLang
0. Generate SSH Key (ed25519)
e. Exit
EOF

        read -r -p "Select an option: " choice

        case "${choice}" in
            1) install_distro "debian" ;;
            2) install_distro "arch" ;;
            3) install_distro "rhel" ;;
            4) install_distro "opensuse" ;;
            5) install_distro "freebsd" ;;
            6) install_distro "gentoo" ;;
            7) install_rpi_extras ;;
            8) install_rust ;;
            9) install_zshrc ;;
            10) install_fastfetch ;;
            11) install_optional_overlay "user-selection/06-mullvad.zrc" ;;
            12) install_optional_overlay "user-selection/07-warn-docker.zrc" ;;
            13) install_golang ;;
            0) install_local_ssh_key ;;
            e|E) break ;;
            *) echo "Invalid selection." ;;
        esac
    done
}

show_menu
