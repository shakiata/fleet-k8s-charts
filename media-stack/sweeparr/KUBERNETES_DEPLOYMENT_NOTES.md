# Kubernetes Deployment Issue & Solution

## Problem Encountered

When deploying Sweeparr to Kubernetes with a PersistentVolumeClaim (PVC), the application fails to start with the following error:

```
Error [PrismaClientKnownRequestError]:
Invalid `prisma.settings.findUnique()` invocation:
unable to open database file
code: 'SQLITE_CANTOPEN'
```

## Root Cause

The issue occurs because Kubernetes PersistentVolumes (especially with storage providers like Longhorn, NFS, or CSI drivers) often mount with restrictive ownership and permissions that don't match the user/group running inside the container. When the Node.js process (running Prisma) attempts to create or access `/app/data/db.sqlite`, it lacks write permissions to the mounted volume directory.

This doesn't happen with Docker Compose because Docker named volumes are typically created with more permissive defaults, and Docker automatically handles permission mapping between the host and container.

## Solution Implemented

### Primary Solution: SecurityContext (Recommended)

The Dockerfile creates and runs as user `nextjs` (UID 1001) and group `nodejs` (GID 1001). The proper solution is to use Kubernetes `securityContext` to ensure the mounted volume has matching ownership:

**Kubernetes Deployment Example:**

```yaml
spec:
  template:
    spec:
      securityContext:
        fsGroup: 1001 # Matches nodejs group
        runAsUser: 1001 # Matches nextjs user
        runAsGroup: 1001 # Matches nodejs group
        runAsNonRoot: true # Security best practice
      containers:
        - name: sweeparr
          image: ghcr.io/jtmb/sweeparr:latest
          env:
            - name: DATABASE_URL
              value: "file:/app/data/db.sqlite"
            - name: NODE_ENV
              value: "production"
          ports:
            - containerPort: 3000
          volumeMounts:
            - name: data
              mountPath: /app/data
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: sweeparr-data-pvc
```

This approach:

- Matches the container's built-in user/group (1001:1001)
- Maintains proper security by running as non-root
- Ensures the PVC is mounted with correct ownership
- No additional containers or overly permissive permissions needed

## Alternative Solutions

### 1. InitContainer Approach (If SecurityContext Doesn't Work)

If your storage provider doesn't respect fsGroup, use an initContainer to set permissions:

```yaml
spec:
  template:
    spec:
      initContainers:
        - name: init-permissions
          image: busybox:latest
          command:
            ["sh", "-c", "mkdir -p /app/data && chown -R 1001:1001 /app/data"]
          volumeMounts:
            - name: data
              mountPath: /app/data
      containers:
        - name: sweeparr
          # ... rest of container config
```

Note: Avoid `chmod 777` for security reasons. Use `chown 1001:1001` to match the container user.

### 2. Storage Class Configuration

Some storage providers allow setting default mount permissions, but this varies by provider and requires cluster-level configuration.

## Recommendation for README

Consider adding a "Kubernetes Deployment" section to the README that documents:

- The **recommended securityContext configuration** matching the container's built-in user (UID/GID 1001)
- Complete example manifests (Deployment, Service, PVC, Ingress)
- Notes about common storage providers (Longhorn, NFS, etc.)
- The initContainer alternative for edge cases where fsGroup doesn't work

The securityContext approach is the most secure and idiomatic Kubernetes solution. It leverages the user/group already defined in the Dockerfile (nextjs:nodejs = 1001:1001).

## Complete Example Manifests

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sweeparr
  namespace: media-stack
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sweeparr
  template:
    metadata:
      labels:
        app: sweeparr
    spec:
      securityContext:
        fsGroup: 1001
        runAsUser: 1001
        runAsGroup: 1001
        runAsNonRoot: true
      containers:
        - name: sweeparr
          image: ghcr.io/jtmb/sweeparr:latest
          env:
            - name: DATABASE_URL
              value: "file:/app/data/db.sqlite"
            - name: NODE_ENV
              value: "production"
            - name: PORT
              value: "3000"
          ports:
            - containerPort: 3000
              protocol: TCP
          volumeMounts:
            - name: data
              mountPath: /app/data
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: sweeparr-data-pvc
```

### PersistentVolumeClaim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sweeparr-data-pvc
  namespace: media-stack
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: longhorn # Use your storage class
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sweeparr-service
  namespace: media-stack
spec:
  selector:
    app: sweeparr
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
  type: ClusterIP
```

### Ingress (Optional)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sweeparr-ingress
  namespace: media-stack
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: sweeparr.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sweeparr-service
                port:
                  number: 3000
```
