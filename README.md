# Minecraft

## Configuration


### Build Script
```docker build --tag minecraft:$(date '+%Y-%m-%d')-build . && docker tag minecraft:$(date '+%Y-%m-%d')-build minecraft:latest```

### Run Script
```docker run -Pit --rm --name redis minecraft:latest /bin/bash```

### Deploy Script
```docker tag minecraft:latest localhost:32000/minecraft:latest && docker push localhost:32000/minecraft:latest```


wget https://launcher.mojang.com/v1/objects/

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



kubectl edit -n ingress configmap/nginx-ingress-tcp-microk8s-conf
kubectl edit -n ingress daemonset/nginx-ingress-microk8s-controller




```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: minecraft-volume
spec:
  capacity:
    storage: 250Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /nas/prometheus/volumes/minecraft
    server: 192.168.4.200
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minecraft-claim
  namespace: games
spec:
  storageClassName: nfs
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
  volumeName: minecraft-volume



