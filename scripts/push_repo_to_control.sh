#!/usr/bin/env bash
set -euo pipefail

REPO="${1:?OWNER/REPO missing}"
REF="${2:-main}"
GH_TOKEN_B64="${3:-}"   # for private repo

sudo install -d -m 755 /opt/stack
command -v curl >/dev/null 2>&1 || sudo dnf -y install curl
command -v tar  >/dev/null 2>&1 || sudo dnf -y install tar

TMP=/tmp/repo.tar.gz
URL="https://api.github.com/repos/${REPO}/tarball/${REF}"

if [[ -n "$GH_TOKEN_B64" ]]; then
  GH_TOKEN="$(printf '%s' "$GH_TOKEN_B64" | base64 -d)"
  curl -sSL -H "Authorization: Bearer ${GH_TOKEN}" "$URL" -o "$TMP"
else
  curl -sSL "$URL" -o "$TMP"
fi

rm -rf /opt/stack/repo
mkdir -p /opt/stack/repo
tar -xzf "$TMP" --strip-components=1 -C /opt/stack/repo
