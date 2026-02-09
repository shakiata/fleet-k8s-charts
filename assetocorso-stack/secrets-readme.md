# Assetto Corsa Stack - Secrets Setup

This stack requires the following Kubernetes secrets to be created before deployment.

## 1. Steam Credentials Secret

Required for downloading Assetto Corsa Dedicated Server from Steam.

> **Important**: You need a Steam account **without Steam Guard enabled**. 
> It's recommended to create a new Steam account since the dedicated server app is free.

```bash
kubectl create secret generic assetto-corsa-steam-secret \
  --namespace=assetocorso-stack \
  --from-literal=STEAM_USER='your-steam-username' \
  --from-literal=STEAM_PASSWORD='your-steam-password'
```

## 2. Assetto Corsa Server Secret

Server passwords for joining and administration.

```bash
kubectl create secret generic assetto-corsa-server-secret \
  --namespace=assetocorso-stack \
  --from-literal=AC_PASSWORD='your-server-join-password' \
  --from-literal=AC_ADMIN_PASSWORD='your-admin-password'
```

## 3. Stracker Secret

Credentials for the stracker web interface (statistics tracking).

```bash
kubectl create secret generic assetto-corsa-stracker-secret \
  --namespace=assetocorso-stack \
  --from-literal=ST_USERNAME='admin' \
  --from-literal=ST_PASSWORD='your-stracker-password'
```

## 4. Cloudflare Tunnel Secret (Optional)

If using Cloudflare Tunnel for external access:

```bash
kubectl create secret generic cloudflare-tunnel-secret \
  --namespace=assetocorso-stack \
  --from-literal=TUNNEL_TOKEN='your-cloudflare-tunnel-token'
```

## Create Namespace First

Before creating secrets, ensure the namespace exists:

```bash
kubectl create namespace assetocorso-stack
```

## Ports Reference

| Port | Protocol | Service |
|------|----------|---------|
| 8081 | TCP | AC HTTP Server |
| 9600 | TCP | AC Game (TCP) |
| 9600 | UDP | AC Game (UDP) |
| 50041 | TCP | Stracker Web UI |
| 50042 | TCP | Ptracker |

## NodePort Mappings

- **30960** → AC TCP (9600)
- **30961** → AC UDP (9600)
