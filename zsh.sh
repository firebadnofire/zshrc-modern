#!/bin/bash

# Define OS-specific package lists using associative arrays
declare -A PKGS=(
    [debian]="aria2 zip make gnupg gnupg2 curl zsh git unzip sudo lsb-release p7zip-full fzy"
    [arch]="aria2 zip curl zsh make git unzip sudo fzy lsb-release"
    [rhel]="aria2 zip make gnupg gnupg2 curl zsh git unzip sudo lsb_release"
    [opensuse]="aria2 zip make gpg2 curl zsh git unzip sudo lsb-release fzy"
    [freebsd]="aria2 zip gmake gnupg curl zsh git unzip sudo fzy"
    [gentoo]="app-arch/zip app-arch/p7zip net-misc/curl app-shells/zsh dev-vcs/git app-arch/unzip app-admin/sudo app-misc/fzy"
)

install_packages() {
    local os_type=$1
    echo "Installing packages for $os_type..."

    mkdir -p ~/.zshrc.d

    case "$os_type" in
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
            ;;
    esac
}

install_rust() {
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh
}

install_zshrc() {
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo "Deploying Zsh config files..."
    curl -Lo ~/.zshrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/zshrc
    curl -Lo ~/.oh-my-zsh/themes/firebadnofire.zsh-theme \
        https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/firebadnofire.zsh-theme

    for f in 00-paths.zrc 02-git-signing.zrc 03-system-aliases.zrc 05-tools.zrc 99-post.zrc suppress-warning.zrc; do
        curl -Lo ~/.zshrc.d/$f https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/zshrc.d/$f
    done


    git clone https://github.com/tom-auger/cmdtime ~/.oh-my-zsh/plugins/cmdtime
}

install_fastfetch() {
    echo "Installing fastfetch..."
    if [[ -x /tmp/fastfetch.sh ]]; then
        /tmp/fastfetch.sh
    else
        echo "Fastfetch script not found at /tmp/fastfetch.sh"
    fi
}

install_rpi_extras() {
    echo "Installing Argon One case script..."
    curl -Lo argon1.sh https://download.argon40.com/argon1.sh
    chmod +x argon1.sh
    sudo ./argon1.sh
    rm -f argon1.sh
}

install_local_ssh_key() {
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    if [[ -f ~/.ssh/id_ed25519 ]]; then
        echo "SSH ed25519 key already exists. Skipping."
        return
    fi

    echo "Generating new SSH ed25519 key..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    echo "Public key:"
    cat ~/.ssh/id_ed25519.pub
}

show_menu() {
    while true; do
        echo ""
        echo "Menu:"
        echo "1. Install for Debian"
        echo "2. Install for Arch"
        echo "3. Install for RHEL"
        echo "4. Install for OpenSUSE"
        echo "5. Install for FreeBSD"
        echo "6. Install for Gentoo"
        echo "7. Raspberry Pi Extras"
        echo "8. Install Rust"
        echo "9. Install Zshrc"
        echo "10. Install Fastfetch"
        echo "11. Install Mullvad aliases"
        echo "12. Install Docker warn for SELinux"
        echo "13. Install GoLang"
        echo "0. Generate SSH Key (ed25519)"
        echo "e. Exit"

        read -p "Select an option: " choice

        case "$choice" in
            1) install_packages "debian"; curl -Lo ~/.zshrc.d/04-pkg-debian.zrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-debian.zrc ;;
            2) install_packages "arch"; curl -Lo ~/.zshrc.d/04-pkg-arch.zrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-arch.zrc ;;
            3) install_packages "rhel"; curl -Lo ~/.zshrc.d/04-pkg-rhel.zrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-rhel.zrc ;;
            4) install_packages "opensuse"; curl -Lo ~/.zshrc.d/04-pkg-opensuse-tumble.zrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-opensuse-tumble.zrc ;;
            5) install_packages "freebsd"; curl -Lo ~/.zshrc.d/04-pkg-freebsd.zrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-freebsd.zrc ;;
            6) install_packages "gentoo"; curl -Lo ~/.zshrc.d/04-pkg-gentoo.zrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-gentoo.zrc ;;
            7) install_rpi_extras ;;
            8) install_rust ;;
            9) install_zshrc ;;
            10) install_fastfetch ;;
            11) curl -Lo ~/.zshrc.d/06-mullvad.zrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/06-mullvad.zrc ;;
            12) curl -Lo ~/.zshrc.d/07-warn-docker.zrc https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/07-warn-docker.zrc ;;
            13) if [[ -x /tmp/golang.sh ]]; then /tmp/golang.sh; else echo "golang.sh not found at /tmp/golang.sh"; fi ;;
            0) install_local_ssh_key ;;
            e|E) break ;;
            *) echo "Invalid selection." ;;
        esac
    done
}

show_menu
