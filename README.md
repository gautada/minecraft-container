# Minecraft

ff3

## Server Setup

This is a minecraft server based on [PaperMC](https://papermc.io) patches for performance and uses [GeyserMC Spigot](https://geysermc.org) as a Bedrock proxy with [GeyserMC Floodgate](https://geysermc.org) to bypass Java paid edition login.

- [PaperMC](https://papermc.io): The most widely used, high-performance Minecraft server that aims to fix gameplay and mechanics inconsistencies.
- [GeyserMC Spigot](https://geysermc.org): Enable clients from Minecraft Bedrock Edition to join your Minecraft Java server.
- [GeyserMC Floodgate](https://geysermc.org): Allows Geyser players to join servers without needing to log into a paid Java Edition account.

## Notes
- 2024-02-08: Rebuilt currently not using the geysermc proxy
  - Uses screen to lunch the server so you can attach to a running server using `screen -x`.
  - Simplified server options in the environment variable MINECRAFT_SERVER_OPTIONS for future use options where:
  ```
  -Xms1G -Xmx3G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true
  ```
  - Another option that was in the old configs `--nojline nogui`
  - "Failed to get system info for Microarchitecture" warning seems to be related to https://github.com/PaperMC/Paper/issues/9785
  - Testing the auto build
  - 2024-02-27: Possible backup strategy

  


### Kubernetes
```
apiVersion: v1
kind: Service
metadata:
  name: minecraft
  namespace: games
spec:
  ports:
  - port: 25565
    name: tcp-java
    protocol: TCP
    targetPort: 25565
  - port: 19132
    name: udp-bedrock
    protocol: UDP
    targetPort: 19132
  selector:
    app: minecraft
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: minecraft
  namespace: games
  labels:
    app: minecraft
spec:
  serviceName: minecraft
  replicas: 1
  selector:
    matchLabels:
      app: minecraft
  template:
    metadata:
      labels:
        app: minecraft
    spec:
      containers:
      - name: minecraft
        image: localhost:32000/minecraft:latest
        ports:
        - containerPort: 25565
          name: tcp-java
          protocol: TCP
        - containerPort: 19132
          name: udp-bedrock
          protocol: UDP
        volumeMounts:
        - name: minecraft-data
          mountPath: /opt/minecraft-data
      volumes:
      - name: minecraft-data
        persistentVolumeClaim:
          claimName: minecraft-claim 
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minecraft-claim
  namespace: games
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
```



