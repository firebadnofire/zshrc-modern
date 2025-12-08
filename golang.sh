#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        GOARCH="amd64"
        ;;
    aarch64 | arm64)
        GOARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

VERSION=$(curl -sL "https://go.dev/dl/" \
  | grep -oP "go[0-9]+\.[0-9]+\.[0-9]+(?=\.linux-${GOARCH}\.tar\.gz)" \
  | grep -vE 'beta|rc' \
  | head -n 1)

TAR="${VERSION}.linux-${GOARCH}.tar.gz"
URL="https://go.dev/dl/${TAR}"

echo "Detected architecture: $ARCH which maps to Go arch: $GOARCH"
echo "Latest Go version: ${VERSION}"
echo "Downloading ${URL}"

curl -LO "${URL}"

echo "Removing old /usr/local/go"
sudo rm -rf /usr/local/go

echo "Extracting ${TAR}"
sudo tar -C /usr/local -xzf "${TAR}"

ZRC="$HOME/.zshrc.d/08-golang.zrc"
mkdir -p "$HOME/.zshrc.d"

printf 'export PATH=$PATH:/usr/local/go/bin\n' > "$ZRC"

echo "Installed Go ${VERSION} for ${ARCH}"
echo "Config written to $ZRC"
