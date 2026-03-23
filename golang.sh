#!/usr/bin/env bash
set -euo pipefail

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" != "Linux" ]]; then
    echo "Go installer currently supports Linux only. Detected ${OS}."
    exit 1
fi

case "${ARCH}" in
    x86_64)
        GOARCH="amd64"
        ;;
    aarch64|arm64)
        GOARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

VERSION=$(curl -fsSL "https://go.dev/dl/" \
  | grep -oP "go[0-9]+\.[0-9]+\.[0-9]+(?=\.linux-${GOARCH}\.tar\.gz)" \
  | grep -vE 'beta|rc' \
  | head -n 1)

if [[ -z "${VERSION}" ]]; then
    echo "Failed to determine the latest Go release."
    exit 1
fi

TAR="${VERSION}.linux-${GOARCH}.tar.gz"
URL="https://go.dev/dl/${TAR}"

echo "Detected architecture: ${ARCH} which maps to Go arch: ${GOARCH}"
echo "Latest Go version: ${VERSION}"
echo "Downloading ${URL}"

curl -fsSLO "${URL}"

echo "Removing old /usr/local/go"
sudo rm -rf /usr/local/go

echo "Extracting ${TAR}"
sudo tar -C /usr/local -xzf "${TAR}"
rm -f "${TAR}"

ZRC="$HOME/.zshrc.d/08-golang.zrc"
mkdir -p "$HOME/.zshrc.d"

printf '%s\n' 'export PATH=$PATH:/usr/local/go/bin' > "$ZRC"

echo "Installed Go ${VERSION} for ${ARCH}"
echo "Config written to $ZRC"
