#!/bin/bash

# This script is to install fastfetch since it isn't in many repos by default

# In the rare case someone decides to curl this and pipe it to bash, this script has been wrapped in a main function and executes it at the bottom
# This is done to prevent code running before it is meant to or in an incomplete manner
# It doesn't even work right when curled to bash anyway

main() {
    # Detecting the distribution
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            pop|ubuntu)
                choice=1
                ;;
            debian)
                if [ "$(uname -m)" == "aarch64" ]; then
                    choice=3
                else
                    choice=2
                fi
                ;;
            archarm)
                choice=4
                ;;
            arch)
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
	    freebsd)
		choice=11
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

    
    # Use a case statement to handle the results
    case $choice in
        1)
            echo "Installing for Ubuntu"
            sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
            sudo apt update
            sudo apt install -y fastfetch
            ;;
        2)
            echo "Installing for Debian x86-64"
            curl -sLo ~/fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
            sudo dpkg -i ~/fastfetch.deb
            rm ~/fastfetch.deb
            ;;
        3)
            echo "Installing for Debian ARM64"
            curl -sLo ~/fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-aarch64.deb 
            sudo dpkg -i ~/fastfetch.deb
            rm ~/fastfetch.deb
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
            pkg install fastfetch
	    ;;
        e|E)
            echo "Exiting..."
            cd ~
            break
            ;;
        *)
            echo "Invalid selection. Please choose a number from 1 to 10, or 'e' to exit."
            ;;
        esac

}

# Execute the main function
main
