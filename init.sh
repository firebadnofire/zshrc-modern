#!/bin/bash

# This script is actually meant to be fetched by curl and piped to bash, therefore this script has been wrapped in a main function and executes it at the bottom
# This is done to prevent code running before it is meant to or in an incomplete manner 

main() {
    wget -O /tmp/zsh.sh https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/zsh.sh
    wget -O /tmp/fastfetch.sh https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/fastfetch.sh
    wget -O /tmp/golang.sh https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main/golang.sh
    clear
    chmod +x /tmp/zsh.sh
    chmod +x /tmp/fastfetch.sh
    echo "run /tmp/zsh.sh"
}

# Execute the main function
main
