#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LAB_NAMESPACE="deploy-strategies-lab"

MANIFEST_DIRS=(
  "manifests/07-headless-service"
  "manifests/06-statefulset-volume-retention"
  "manifests/05-statefulset"
  "manifests/04-cronjob"
  "manifests/03-job-advanced"
  "manifests/02-job"
  "manifests/01-daemonset"
)

info() {
  echo "[INFO] $1"
}

warn() {
  echo "[WARN] $1"
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

confirm() {
  local prompt="$1"
  local response=""

  read -r -p "${prompt} [y/N]: " response
  [[ "${response}" =~ ^[Yy]$ ]]
}

delete_manifest_dir() {
  local relative_dir="$1"
  local absolute_dir="${REPO_ROOT}/${relative_dir}"

  if [[ -d "${absolute_dir}" ]]; then
    info "Removing resources defined in ${relative_dir}"
    kubectl delete -f "${absolute_dir}" --ignore-not-found=true
  fi
}

require_kubectl

if ! kubectl get namespace "${LAB_NAMESPACE}" >/dev/null 2>&1; then
  warn "Namespace '${LAB_NAMESPACE}' was not found. Nothing to clean up."
  exit 0
fi

info "Removing workloads and services from namespace '${LAB_NAMESPACE}'..."

for dir in "${MANIFEST_DIRS[@]}"; do
  delete_manifest_dir "${dir}"
done

remaining_pvcs="$(kubectl get pvc -n "${LAB_NAMESPACE}" -o name 2>/dev/null || true)"

if [[ -n "${remaining_pvcs}" ]]; then
  warn "PersistentVolumeClaims can contain persistent data."
  warn "Do not delete PVCs from production environments without a valid backup."
  info "PVCs currently present in '${LAB_NAMESPACE}':"
  kubectl get pvc -n "${LAB_NAMESPACE}"

  if confirm "Do you want to delete these PVCs?"; then
    kubectl delete pvc --all -n "${LAB_NAMESPACE}" --ignore-not-found=true
    success "PVCs deleted."

    info "Deleting namespace '${LAB_NAMESPACE}'..."
    kubectl delete namespace "${LAB_NAMESPACE}" --ignore-not-found=true
    success "Namespace deletion requested."
  else
    warn "PVC deletion skipped. The namespace will be kept to avoid deleting persistent data implicitly."
    warn "If you later decide to remove the PVCs, review them first with: kubectl get pvc -n ${LAB_NAMESPACE}"
    exit 0
  fi
else
  info "No PVCs found in '${LAB_NAMESPACE}'."
  info "Deleting namespace '${LAB_NAMESPACE}'..."
  kubectl delete namespace "${LAB_NAMESPACE}" --ignore-not-found=true
  success "Namespace deletion requested."
fi

success "Cleanup completed."
