# Creación de clúster (1 control + 1 worker)

Guía breve para levantar un clúster kubeadm con un nodo de control y uno trabajador, validar conectividad y dejar el contexto listo para desplegar los manifiestos de `k8s/`.

## Prerrequisitos en ambos nodos
- SO: Linux x86_64/aarch64 con systemd.
- Paquetes: `kubeadm`, `kubelet`, `kubectl` instalados y versionados igual.
- Runtime: containerd/Docker configurado para cgroup driver `systemd`.
- Ajustes:
  - Desactivar swap: `sudo swapoff -a` y comentar en `/etc/fstab`.
  - Cargar módulos: `br_netfilter`, `overlay`.
  - Sysctl: `sudo tee /etc/sysctl.d/k8s.conf <<'EOF'\nnet.bridge.bridge-nf-call-iptables = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.ipv4.ip_forward = 1\nEOF\nsudo sysctl --system`.
  - Sin firewall bloqueando puertos kubeadm (6443, 10250, etc.).

## Paso 1: Inicializar nodo de control
```bash
# En el nodo de control (reemplaza 10.0.0.10 con su IP privada):
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.0.0.10

# Configurar kubectl para el usuario actual:
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Paso 2: Instalar red de pods (CNI)
Ejemplo con Calico:
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
```

## Paso 3: Unir el nodo trabajador
Tras el `kubeadm init` se mostró un comando `kubeadm join ...`. Ejemplo:
```bash
# En el nodo worker (ajusta IP/puerto/token/hash):
sudo kubeadm join 10.0.0.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```
Si ya expiró el token, crea otro en el control:
```bash
kubeadm token create --print-join-command
```

## Paso 4: Validar estado y conectividad
```bash
kubectl get nodes
kubectl get pods -A
kubectl get cs   # en versiones que aún lo exponen, o usa:
kubectl get componentstatuses || true
```
Espera a ver ambos nodos `Ready` y los pods del CNI en `Running`.

## Paso 5: Preparar para desplegar la app
- Instala Ingress Controller nginx (ejemplo Helm o manifest oficial).
- Asegura una StorageClass por defecto.
- Opcional: crea entrada `/etc/hosts` para `fintech.local` apuntando al LoadBalancer/Ingress IP (en lab, quizá NodePort + hosts).

## Paso 6: Despliegue de la aplicación
Con el contexto apuntando al clúster y los prerrequisitos listos:
```bash
./scripts/apply-all.sh
```
Luego verifica:
```bash
kubectl get pods,svc,ingress,hpa,pdb -n fintech
```

## Paso 7: Acceso y pruebas
- Port-forward (local): `./scripts/port-forward.sh` → frontend `http://localhost:8080`, backend `http://localhost:9091`, DB `localhost:5432`.
- Ingress (si configurado): `http://fintech.local/` y `/api`.

## Limpieza del clúster
```bash
./scripts/delete-all.sh
# Para resetear la instalación kubeadm (cuidado, borra el clúster):
sudo kubeadm reset -f
sudo rm -rf ~/.kube
```
