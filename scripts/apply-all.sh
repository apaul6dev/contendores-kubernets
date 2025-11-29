#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="fintech"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Aplicando namespace..."
kubectl apply -f "${ROOT_DIR}/k8s/infra/namespace.yaml"

echo "Aplicando configuración y seguridad..."
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/security/rbac.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/security/configmap.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/security/secrets.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/security/networkpolicy-db.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/security/networkpolicy-backend.yaml"

echo "Aplicando almacenamiento y base de datos..."
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/db/db-pvc.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/db/db-service.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/db/db-statefulset.yaml"

echo "Aplicando aplicaciones..."
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/app/backend-deployment.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/app/backend-service.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/app/frontend-deployment.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/app/frontend-service.yaml"

echo "Aplicando recursos de infraestructura..."
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/infra/ingress.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/infra/hpa-backend.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/infra/hpa-frontend.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/infra/pdb-backend.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/infra/pdb-frontend.yaml"
kubectl apply -n "${NAMESPACE}" -f "${ROOT_DIR}/k8s/infra/pdb-db.yaml"

echo "Listo. Manifiestos aplicados en el namespace '${NAMESPACE}'."
