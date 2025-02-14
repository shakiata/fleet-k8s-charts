# Add these secrets to rancher if they are missing and not part of your deployment

```bash
kubectl create secret generic plex-claim-secret --from-literal=PLEX_CLAIM=claim-_-sxwjS7pgzkLT4X_UpB -n media-stack


kubectl create secret generic samba-secret \
  --namespace media-stack \
  --from-literal=username=username \
  --from-literal=password=password
```
