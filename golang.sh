#!/usr/bin/env bash
set -euo pipefail

VERSION=$(curl -sL "https://go.dev/dl/" \
  | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+(?=\.linux-amd64\.tar\.gz)' \
  | grep -vE 'beta|rc' \
  | head -n 1)

TAR="${VERSION}.linux-amd64.tar.gz"
URL="https://go.dev/dl/${TAR}"

echo "Latest Go version: ${VERSION}"
echo "Downloading ${URL}"

curl -LO "${URL}"

echo "Removing old /usr/local/go"
sudo rm -rf /usr/local/go

echo "Extracting ${TAR}"
sudo tar -C /usr/local -xzf "${TAR}"

ZRC="$HOME/.zshrc.d/08-golang.zrc"
mkdir -p "$HOME/.zshrc.d"

# Write file with no fancy quoting issues
printf 'export PATH=$PATH:/usr/local/go/bin\n' > "$ZRC"

echo "Installed Go ${VERSION}"
echo "Config written to $ZRC"
