#!/bin/bash

# Define OS-specific package lists using associative arrays
declare -A PKGS=(
    [debian]="aria2 zip make gnupg gnupg2 curl zsh git unzip sudo lsb-release p7zip-full fzy"
    [arch]="aria2 zip curl zsh make git unzip sudo fzy lsb-release"
    [rhel]="aria2 zip make gnupg gnupg2 curl zsh git unzip sudo lsb_release"
    [opensuse]="aria2 zip make gpg2 curl zsh git unzip sudo lsb-release fzy"
    [freebsd]="aria2 zip gmake gnupg curl zsh git unzip sudo fzy"
)

install_packages() {
    local os_type=$1
    echo "Installing packages for $os_type..."

    mkdir -p ~/.zshrc.d

    case "$os_type" in
        debian)
            sudo apt update
            sudo apt install -y ${PKGS[$os_type]}
            curl -Lo ~/.zshrc.d/04-pkg-debian.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-debian.zrc
            curl -Lo ~/.zshrc.d/06-mullvad.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/06-mullvad.zrc
            curl -Lo ~/.zshrc.d/07-warn-docker.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/07-warn-docker.zrc

            echo "Installing apt-fast..."
            curl -sLo apt-fast-installer.sh https://git.io/vokNn
            bash apt-fast-installer.sh
            sudo curl -o /etc/apt-fast.conf https://archuser.org/aptf
            rm -f apt-fast-installer.sh
            ;;

        arch)
            sudo pacman --noconfirm -S ${PKGS[$os_type]}
            curl -Lo ~/.zshrc.d/04-pkg-arch.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-arch.zrc
            curl -Lo ~/.zshrc.d/06-mullvad.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/06-mullvad.zrc
            curl -Lo ~/.zshrc.d/07-warn-docker.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/07-warn-docker.zrc

            cd /opt
            sudo git clone https://aur.archlinux.org/yay-git.git
            sudo chown -R $USER:$USER yay-git
            cd yay-git
            makepkg -si --noconfirm
            yay --noconfirm -S pamac-aur
            ;;

        rhel)
            sudo dnf install -y ${PKGS[$os_type]} epel-release
            curl -Lo ~/.zshrc.d/04-pkg-rhel.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-rhel.zrc
            curl -Lo ~/.zshrc.d/06-mullvad.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/06-mullvad.zrc
            curl -Lo ~/.zshrc.d/07-warn-docker.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/07-warn-docker.zrc

            sudo dnf install -y \
                https://ftp.lysator.liu.se/pub/opensuse/distribution/leap/15.5/repo/oss/x86_64/fzy-0.9-bp155.2.10.x86_64.rpm
            ;;

        opensuse)
            sudo zypper refresh
            sudo zypper --non-interactive install ${PKGS[$os_type]}
            curl -Lo ~/.zshrc.d/04-pkg-opensuse-tumble.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-opensuse-tumble.zrc
            curl -Lo ~/.zshrc.d/06-mullvad.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/06-mullvad.zrc
            curl -Lo ~/.zshrc.d/07-warn-docker.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/07-warn-docker.zrc
            ;;

        freebsd)
            sudo pkg update
            sudo pkg install -y ${PKGS[$os_type]}
            curl -Lo ~/.zshrc.d/04-pkg-freebsd.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/04-pkg-freebsd.zrc
            curl -Lo ~/.zshrc.d/06-mullvad.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/06-mullvad.zrc
            curl -Lo ~/.zshrc.d/07-warn-docker.zrc \
                https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/user-selection/07-warn-docker.zrc
            ;;

        *)
            echo "Unsupported OS selection."
            ;;
    esac
}
            echo "Installing apt-fast..."
            curl -sLo apt-fast-installer.sh https://git.io/vokNn
            bash apt-fast-installer.sh
            sudo curl -o /etc/apt-fast.conf https://archuser.org/aptf
            rm -f apt-fast-installer.sh
            ;;

        arch)
            sudo pacman --noconfirm -S ${PKGS[$os_type]}
            echo "Installing yay and pamac..."
            cd /opt
            sudo git clone https://aur.archlinux.org/yay-git.git
            sudo chown -R $USER:$USER yay-git
            cd yay-git
            makepkg -si --noconfirm
            yay --noconfirm -S pamac-aur
            ;;

        rhel)
            sudo dnf install -y ${PKGS[$os_type]} epel-release
            sudo dnf install -y https://ftp.lysator.liu.se/pub/opensuse/distribution/leap/15.5/repo/oss/x86_64/fzy-0.9-bp155.2.10.x86_64.rpm
            ;;

        opensuse)
            sudo zypper refresh
            sudo zypper --non-interactive install ${PKGS[$os_type]}
            ;;

        freebsd)
            sudo pkg update
            sudo pkg install -y ${PKGS[$os_type]}
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
    curl -Lo ~/.zshrc_bpk https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/zshrc_bpk
    curl -Lo ~/.cow https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/cow
    curl -Lo ~/.oh-my-zsh/themes/firebadnofire.zsh-theme \
        https://pubcode.archuser.org/firebadnofire/zsh-theme/raw/branch/main/firebadnofire.zsh-theme

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
        echo "6. Raspberry Pi Extras"
        echo "7. Install Rust"
        echo "8. Install Zshrc"
        echo "9. Install Fastfetch"
        echo "0. Generate SSH Key (ed25519)"
        echo "e. Exit"

        read -p "Select an option: " choice

        case "$choice" in
            1) install_packages "debian" ;;
            2) install_packages "arch" ;;
            3) install_packages "rhel" ;;
            4) install_packages "opensuse" ;;
            5) install_packages "freebsd" ;;
            6) install_rpi_extras ;;
            7) install_rust ;;
            8) install_zshrc ;;
            9) install_fastfetch ;;
            0) install_local_ssh_key ;;
            e|E) break ;;
            *) echo "Invalid selection." ;;
        esac
    done
}

show_menu
