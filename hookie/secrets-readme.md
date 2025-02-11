
# Add these secrets to rancher if they are missing and not part of your deployment
```bash
kubectl create secret generic github-token-secret --from-literal=GITHUB_TOKEN=githubtoken -n media-stack

kubectl create secret generic notification-webhook-secret --from-literal=NOTIFICATION_WEBHOOK=webhookaddress -n media-stack
```