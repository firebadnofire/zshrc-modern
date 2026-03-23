#!/usr/bin/env bash
set -euo pipefail

REMOTE_RAW_BASE="${ZSHRC_REMOTE_BASE:-https://pubcode.archuser.org/firebadnofire/zshrc/raw/branch/main}"
TMP_DIR="${TMPDIR:-/tmp}"

main() {
    local script

    for script in zsh.sh fastfetch.sh golang.sh; do
        curl -fsSL "${REMOTE_RAW_BASE}/${script}" -o "${TMP_DIR}/${script}"
        chmod +x "${TMP_DIR}/${script}"
    done

    clear
    printf 'Run %s/zsh.sh\n' "${TMP_DIR}"
}

main "$@"
