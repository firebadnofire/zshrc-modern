#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_PATH="${ROOT_DIR}/downloads.sha256sum"
TMP_MANIFEST="$(mktemp)"

sha256_cmd() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1"
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1"
    else
        echo "No SHA-256 tool found. Install sha256sum or shasum." >&2
        exit 1
    fi
}

cd "$ROOT_DIR"

while IFS= read -r file; do
    sha256_cmd "$file" >> "$TMP_MANIFEST"
done < <(find downloads -maxdepth 1 -type f | sort)

mv "$TMP_MANIFEST" "$MANIFEST_PATH"
