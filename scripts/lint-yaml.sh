#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if command -v yamllint >/dev/null 2>&1; then
  echo "[INFO] Using local yamllint installation."
  yamllint -c "${REPO_ROOT}/.yamllint.yml" "${REPO_ROOT}"
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  echo "[INFO] Local yamllint not found. Using Docker image cytopia/yamllint:latest."
  docker run --rm \
    -v "${REPO_ROOT}:/data" \
    cytopia/yamllint:latest \
    -c /data/.yamllint.yml /data
  exit 0
fi

echo "[ERROR] Neither yamllint nor Docker is available."
echo "[ERROR] Install yamllint locally or run this script on a machine with Docker."
exit 1
