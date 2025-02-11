# Add these secrets to rancher if they are missing and not part of your deployment
kubectl create secret generic plex-claim-secret --from-literal=plexclaimtoken -n media-stack
kubectl create secret generic samba-secret \
  --namespace media-stack \
  --from-literal=username=username \
  --from-literal=password=password