# Restore Minecraft World From Backups

1. Exec into minecraft container and delete the following folders: `world` `world-nether` `world-end`
2. Make sure you have a kubectl config exported
    ```bash
    export KUBECONFIG=/path/to/your/kubeconfig
    ```
3. Navigate to the directory where your world backup is located:
    ```bash
    cd /path/to/your/world-backup
    ```

4. Now kube copy your world folders from your local directory into the /data dir in the container (use th pod id)

    ```bash
    kubectl cp -n minecraft-stack world minecraft-server-55554f9dbd-b84zx:/data
    kubectl cp -n minecraft-stack world_nether minecraft-server-55554f9dbd-b84zx:/data
    kubectl cp -n minecraft-stack world_end minecraft-server-55554f9dbd-b84zx:/data
    ```

5. Scale the deployment to 0 and then back up to 1 to redploy.

    ```bash
    kubectl scale deployment minecraft-server --replicas=0 -n minecraft-stack
    wait 10s
    kubectl scale deployment minecraft-server --replicas=1 -n minecraft-stack

    ```

  