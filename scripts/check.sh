#!/usr/bin/env bash

set -euo pipefail

LAB_NAMESPACE="deploy-strategies-lab"

info() {
  echo
  echo "[INFO] $1"
}

warn() {
  echo "[WARN] $1"
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

require_kubectl

info "Cluster nodes"
kubectl get nodes -o wide

info "Namespaces"
kubectl get namespaces

if ! kubectl get namespace "${LAB_NAMESPACE}" >/dev/null 2>&1; then
  warn "Namespace '${LAB_NAMESPACE}' not found. Cluster-level checks completed, but there are no lab resources to display."
  exit 0
fi

info "Pods in ${LAB_NAMESPACE}"
kubectl get pods -n "${LAB_NAMESPACE}" -o wide

info "DaemonSets in ${LAB_NAMESPACE}"
kubectl get daemonsets -n "${LAB_NAMESPACE}"

info "Jobs in ${LAB_NAMESPACE}"
kubectl get jobs -n "${LAB_NAMESPACE}"

info "CronJobs in ${LAB_NAMESPACE}"
kubectl get cronjobs -n "${LAB_NAMESPACE}"

info "StatefulSets in ${LAB_NAMESPACE}"
kubectl get statefulsets -n "${LAB_NAMESPACE}"

info "Services in ${LAB_NAMESPACE}"
kubectl get services -n "${LAB_NAMESPACE}"

info "PersistentVolumeClaims in ${LAB_NAMESPACE}"
kubectl get pvc -n "${LAB_NAMESPACE}"
