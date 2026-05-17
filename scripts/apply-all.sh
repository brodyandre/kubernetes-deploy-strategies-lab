#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LAB_NAMESPACE="deploy-strategies-lab"

MANIFEST_PATHS=(
  "manifests/00-namespace"
  "manifests/01-daemonset"
  "manifests/02-job"
  "manifests/03-job-advanced"
  "manifests/04-cronjob"
  "manifests/05-statefulset/service.yaml"
  "manifests/05-statefulset/statefulset.yaml"
  "manifests/06-statefulset-volume-retention/service.yaml"
  "manifests/06-statefulset-volume-retention/statefulset-retention.yaml"
  "manifests/07-headless-service/headless-service.yaml"
  "manifests/07-headless-service/statefulset-headless-demo.yaml"
)

info() {
  echo "[INFO] $1"
}

success() {
  echo "[OK] $1"
}

error() {
  echo "[ERROR] $1" >&2
}

require_kubectl() {
  if ! command -v kubectl >/dev/null 2>&1; then
    error "kubectl not found in PATH."
    exit 1
  fi
}

current_context() {
  kubectl config current-context 2>/dev/null || true
}

apply_path() {
  local relative_path="$1"
  local absolute_path="${REPO_ROOT}/${relative_path}"

  info "Applying ${relative_path}"
  kubectl apply -f "${absolute_path}"
}

require_kubectl

context_name="$(current_context)"
if [[ -z "${context_name}" ]]; then
  error "No active Kubernetes context found."
  exit 1
fi

info "Applying lab manifests to context: ${context_name}"

for path in "${MANIFEST_PATHS[@]}"; do
  apply_path "${path}"
done

success "All manifests applied successfully."
info "You can inspect the lab with: ./scripts/check.sh"
info "Namespace in use: ${LAB_NAMESPACE}"
