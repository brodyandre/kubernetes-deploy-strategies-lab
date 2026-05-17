#!/usr/bin/env bash

set -euo pipefail

LAB_NAMESPACE="deploy-strategies-lab"

info() {
  echo "[INFO] $1"
}

success() {
  echo "[OK] $1"
}

error() {
  echo "[ERROR] $1" >&2
}

require_command() {
  local cmd="$1"

  if ! command -v "${cmd}" >/dev/null 2>&1; then
    error "Command '${cmd}' not found in PATH."
    exit 1
  fi
}

info "Checking local Kubernetes tooling for the lab..."

require_command kubectl
success "kubectl found."

require_command docker
success "Docker CLI found."

if ! docker info >/dev/null 2>&1; then
  error "Docker is installed but not available. Start Docker Desktop and try again."
  exit 1
fi
success "Docker daemon is available."

current_context="$(kubectl config current-context 2>/dev/null || true)"

if [[ -z "${current_context}" ]]; then
  error "No active Kubernetes context found. Configure kubectl before continuing."
  exit 1
fi

success "Active Kubernetes context: ${current_context}"

info "kubectl client version:"
kubectl version --client

info "Cluster nodes detected:"
kubectl get nodes -o wide

info "Namespace '${LAB_NAMESPACE}' will be used by the lab manifests."
success "Environment checks completed successfully."
