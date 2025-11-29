# Fintech Kubernetes Manifests

Plantilla mínima para desplegar una app fintech (frontend + backend + base de datos) en Kubernetes con namespace dedicado, almacenamiento persistente y políticas básicas de red.

## Estructura
- `docs/`: adjunta aquí el informe (`informe.pdf`) y opcionalmente diagramas en `diagramas/`.
- `k8s/infra/`: namespace, ingress (ajusta host/clase), autoescalado del backend.
- `k8s/storage/`: `StorageClass` y PV de ejemplo (hostPath) para desarrollo.
- `k8s/security/`: `ConfigMap`, `Secret` con credenciales, y `NetworkPolicy` para la base de datos.
- `k8s/db/`: StatefulSet/Postgres, Service y PVC de datos.
- `k8s/app/`: Deployments y Services de frontend y backend.
- `scripts/`: helpers para aplicar o borrar todo con `kubectl`.

## Imágenes Docker usadas
Las imágenes publicadas en Docker Hub (origen: entorno Docker local con red `devsu-net`) se referencian en los Deployments:
- Base de datos: `apauldev/postgres-fintech:1.0`
- Backend: `apauldev/backdevsu-app:1.0`
- Frontend: `apauldev/frontdevsu-app:1.0`

## Despliegue rápido
Requisitos: `kubectl` apuntando al cluster correcto (contexto activo) y un Ingress Controller si usas `k8s/infra/ingress.yaml`.

1) Ajusta imágenes, host de Ingress (`fintech.local`) y credenciales en `k8s/security/secrets.yaml`.
2) Revisa el storage: por defecto se usa `hostPath` (`/mnt/data/fintech-db`) y `StorageClass` sin provisioner; cambia según tu cloud.
3) Aplica todo:
```bash
./scripts/apply-all.sh
```
4) Elimina todo:
```bash
./scripts/delete-all.sh
```

## Guía local (Minikube) cumpliendo los mínimos
- Creación del clúster: `minikube start` y contexto activo con `kubectl config use-context minikube`.
- Almacenamiento: crea la ruta hostPath en el nodo `minikube ssh "sudo mkdir -p /mnt/data/fintech-db && sudo chmod 777 /mnt/data/fintech-db"`.
- Ingress/Redes: habilita ingress `minikube addons enable ingress` y añade `/etc/hosts`: `echo "$(minikube ip) fintech.local" | sudo tee -a /etc/hosts`.
- Seguridad: revisa/edita `k8s/security/secrets.yaml` y `k8s/security/networkpolicy.yaml` antes de desplegar.
- Puesta en marcha (cargas de trabajo + servicios + balanceadores): `./scripts/apply-all.sh` aplica Deployments/StatefulSet, Services e Ingress/HPA.
- Verificación: `kubectl get pods -n fintech`, `kubectl get svc -n fintech`, `kubectl get ingress -n fintech`; prueba `curl http://fintech.local/` y `curl http://fintech.local/api`.
- Documentación del proceso: reemplaza `docs/informe.pdf` con tu informe y agrega diagramas en `docs/diagramas/` si lo deseas.

## Notas
- Los manifiestos usan el namespace `fintech` (crear primero o dejar que `apply-all.sh` lo aplique).
- `informe.pdf` es un placeholder vacío: reemplázalo con tu entrega real.
- Ajusta sondas, recursos y puertos conforme a tu app; las imágenes son ejemplos.
