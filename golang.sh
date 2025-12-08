#!/usr/bin/env bash
set -euo pipefail

# Find latest stable Go version (linux-amd64)
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

# Install PATH file
ZRC="$HOME/.zshrc.d/08-
