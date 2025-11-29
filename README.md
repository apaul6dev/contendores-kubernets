# Fintech Kubernetes Manifests (desde docker-compose)

Manifiestos para desplegar la app fintech (frontend + backend + Postgres) que en `docker-compose` expone los puertos 8080/9091/5432 y usa las variables `POSTGRES_DB/USER/PASSWORD`. Incluye escalado, disponibilidad y políticas de red.

## Estructura
- `k8s/infra/`: namespace, Ingress, HPAs y PodDisruptionBudgets.
- `k8s/security/`: ConfigMap, Secret, ServiceAccounts y NetworkPolicies.
- `k8s/db/`: StatefulSet de Postgres, Service y PVC.
- `k8s/app/`: Deployments y Services de backend y frontend.
- `scripts/`: `apply-all.sh` y `delete-all.sh`.

## Variables (igual que docker-compose)
- Puertos: frontend 8080 (target 80), backend 9091 (target 9091), base de datos 5432.
- Credenciales y DB por defecto: `POSTGRES_DB=devsudb`, `POSTGRES_USER=admin`, `POSTGRES_PASSWORD=admin`.
- Ajusta valores en `k8s/security/secrets.yaml` y `k8s/security/configmap.yaml` si cambia tu entorno.

## Requisitos previos
- Cluster Kubernetes activo (2 nodos recomendado) y `kubectl` apuntando al contexto correcto.
- Ingress Controller nginx operativo. En minikube: `minikube addons enable ingress`.
- StorageClass por defecto configurada (PVC usa la default). Si necesitas otra, edita `k8s/db/db-pvc.yaml`.
- Resolver `fintech.local` al Ingress IP. En minikube: `echo "$(minikube ip) fintech.local" | sudo tee -a /etc/hosts`.
- TLS opcional: si quieres HTTPS, crea `fintech-tls` en `fintech` y añade bloque `tls` al Ingress.

## Despliegue
```bash
chmod +x scripts/apply-all.sh scripts/delete-all.sh
./scripts/apply-all.sh
```

## Verificación
- Estado general: `kubectl get pods,svc,ingress,hpa,pdb -n fintech`.
- Ingress HTTP: `curl http://fintech.local/` y `curl http://fintech.local/api`.
- Logs: `kubectl logs -n fintech deploy/backend -f`, `kubectl logs -n fintech deploy/frontend -f`, `kubectl logs -n fintech sts/fintech-db -c postgres -f`.
- Base de datos (pruebas): `kubectl port-forward -n fintech svc/db-service 5432:5432`.

## Limpieza
```bash
./scripts/delete-all.sh
```

## Cómo se cubren los objetivos
- Configurar y administrar clúster: namespace dedicado, scripts de despliegue/borrado.
- Automatizar despliegues y escalabilidad: Deployments/StatefulSet + HPAs + PDBs, sondas y requests/limits.
- Seguridad y supervisión: ServiceAccounts con `automount=false`, NetworkPolicies para DB y backend, configuración/secretos separados; métricas anotadas para Prometheus si existe en el clúster.
