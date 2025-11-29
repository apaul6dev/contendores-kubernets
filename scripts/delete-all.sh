#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="fintech"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Eliminando recursos de infraestructura..."
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/infra/hpa-backend.yaml" --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/infra/ingress.yaml" --ignore-not-found

echo "Eliminando aplicaciones..."
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/app/frontend-service.yaml" --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/app/frontend-deployment.yaml" --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/app/backend-service.yaml" --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/app/backend-deployment.yaml" --ignore-not-found

echo "Eliminando base de datos..."
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/db/db-service.yaml" --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/db/db-statefulset.yaml" --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/db/db-pvc.yaml" --ignore-not-found

echo "Eliminando configuración y seguridad..."
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/security/networkpolicy.yaml" --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/security/secrets.yaml" --ignore-not-found
kubectl delete -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/security/configmap.yaml" --ignore-not-found

echo "Eliminando storage (cluster-scope)..."
kubectl delete -f "${ROOT_DIR}/k8s/storage/pv.yaml" --ignore-not-found
kubectl delete -f "${ROOT_DIR}/k8s/storage/storageclass.yaml" --ignore-not-found

echo "Eliminando namespace..."
kubectl delete -f "${ROOT_DIR}/k8s/infra/namespace.yaml" --ignore-not-found

echo "Listo. Recursos eliminados."
