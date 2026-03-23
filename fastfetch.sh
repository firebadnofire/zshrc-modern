#!/usr/bin/env bash
set -euo pipefail

main() {
    local choice=

    if [[ "$(uname -s)" == "FreeBSD" ]]; then
        choice=11
    elif [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release

        case "${ID}" in
            pop|ubuntu)
                choice=1
                ;;
            debian)
                if [[ "$(uname -m)" == "aarch64" ]]; then
                    choice=3
                else
                    choice=2
                fi
                ;;
            archarm|arch)
                choice=4
                ;;
            fedora|rhel|almalinux|fedora-asahi-remix)
                choice=5
                ;;
            gentoo)
                choice=6
                ;;
            alpine)
                choice=7
                ;;
            nixos)
                choice=8
                ;;
            opensuse*)
                choice=9
                ;;
            alt)
                choice=10
                ;;
            *)
                echo "Unsupported distribution. Exiting..."
                exit 1
                ;;
        esac
    else
        echo "OS release file (/etc/os-release) not found. Exiting..."
        exit 1
    fi

    case "${choice}" in
        1)
            echo "Installing for Ubuntu"
            sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
            sudo apt update
            sudo apt install -y fastfetch
            ;;
        2)
            echo "Installing for Debian x86-64"
            curl -fsSL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -o "${HOME}/fastfetch.deb"
            sudo dpkg -i "${HOME}/fastfetch.deb"
            rm -f "${HOME}/fastfetch.deb"
            ;;
        3)
            echo "Installing for Debian ARM64"
            curl -fsSL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-aarch64.deb -o "${HOME}/fastfetch.deb"
            sudo dpkg -i "${HOME}/fastfetch.deb"
            rm -f "${HOME}/fastfetch.deb"
            ;;
        4)
            echo "Installing for Arch"
            sudo pacman -S fastfetch
            ;;
        5)
            echo "Installing for Fedora/RHEL"
            sudo dnf install fastfetch
            ;;
        6)
            echo "Installing for Gentoo"
            sudo emerge --ask app-misc/fastfetch
            ;;
        7)
            echo "Installing for Alpine"
            apk add --upgrade fastfetch
            ;;
        8)
            echo "Installing for NixOS"
            nix-shell -p fastfetch
            ;;
        9)
            echo "Installing for OpenSUSE"
            sudo zypper install fastfetch
            ;;
        10)
            echo "Installing for ALT Linux"
            sudo apt-get install fastfetch
            ;;
        11)
            echo "Installing for FreeBSD"
            sudo pkg install -y fastfetch
            ;;
        *)
            echo "Invalid platform selection."
            exit 1
            ;;
    esac
}

main "$@"
