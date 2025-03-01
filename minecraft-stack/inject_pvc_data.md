# Restore Minecraft World From Backups

1. Exec into minecraft container and delete the following folders: `world` `world-nether` `world-end`
2. Make sure you have a kubectl config exported
3. kube copy your world folders from your local directory into the /data dir in the container (use th pod id)

    ```bash
    kubectl cp world minecraft-server-55554f9dbd-b84zx:/data
    kubectl cp world-nether minecraft-server-55554f9dbd-b84zx:/data
    kubectl cp world-end minecraft-server-55554f9dbd-b84zx:/data
    ```

  