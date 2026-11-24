# Kubernetes: My Tic-Tac-Toe Deployment

I built this in three layers:

1. App only.
2. App with MongoDB.
3. App with MongoDB and persistent storage.

Each layer updates the same Kubernetes resources. My folders keep separate copies of each configuration.

## Before starting: Create the cluster

I opened Docker Desktop, enabled Kubernetes and selected **Kubeadm**.

Docker Desktop created a single-node cluster. I waited for it to show Running.

```bash
kubectl config use-context docker-desktop
```

Selects my Docker Desktop cluster.

```bash
kubectl get nodes
```

Checks that my node shows `Ready`.

My node handles cluster management and runs my Pods. Three replicas means three app Pods, not three nodes.

From my `tech613-learning` repo folder:

```bash
cd week8/yaml-definitions
```

Moves into my YAML folder. All remaining terminal commands run here.

## Layer 1: App only

### Create the folder

```bash
mkdir -p local-ttt-app-deploy
```

Creates a folder for my app-only configuration.

### Create `local-ttt-app-deploy/ttt-deploy.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ttt-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ttt
  template:
    metadata:
      labels:
        app: ttt
    spec:
      containers:
        - name: ttt
          image: amz101/tech613-tttapp:1.2.0
          ports:
            - containerPort: 3000
```

- Requests three app Pods.
- Uses my Docker Hub image.
- Uses matching labels and selectors.
- Declares my app’s listening port as `3000`.

### Create `local-ttt-app-deploy/ttt-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ttt-service
spec:
  type: NodePort
  selector:
    app: ttt
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
      nodePort: 30001
```

- Selects Pods labelled `app: ttt`.
- Provides Service port `3000` inside the cluster.
- Sends traffic to the app on port `3000`.
- Exposes the Service through NodePort `30001`.

### Deploy and check

```bash
kubectl apply -f local-ttt-app-deploy/
```

Creates or updates the resources from this folder.

```bash
kubectl get deployments,pods,services
```

Lists the resources and their status.

I checked for three app Pods showing `1/1 Running` and my Deployment showing `3/3` ready.

I opened http://localhost:30001 and tested the app.

## Layer 2: Add MongoDB

### Copy the app configuration

```bash
mkdir -p local-ttt-app-mongo-deploy
cp local-ttt-app-deploy/*.yaml local-ttt-app-mongo-deploy/
```

Creates a new folder and copies my app files into it.

### Create `local-ttt-app-mongo-deploy/mongo-deploy.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
        - name: mongo
          image: mongo:7.0
          ports:
            - containerPort: 27017
```

Requests one MongoDB Pod listening on port `27017`.

### Create `local-ttt-app-mongo-deploy/mongo-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongo-service
spec:
  type: ClusterIP
  selector:
    app: mongo
  ports:
    - protocol: TCP
      port: 27017
      targetPort: 27017
```

Gives MongoDB a stable internal address: `mongo-service:27017`.

I use ClusterIP because I do not need to expose MongoDB through a NodePort.

### Update the copied `ttt-deploy.yaml`

I added `env` beneath the container’s `image` line:

```yaml
          env:
            - name: MONGODB_URI
              value: mongodb://mongo-service:27017/tictactoe
```

Provides the database address to my app.

- `mongo-service`: database hostname.
- `27017`: database port.
- `tictactoe`: database name.

### Deploy and check

```bash
kubectl apply -f local-ttt-app-mongo-deploy/
```

Updates my app configuration and creates MongoDB.

```bash
kubectl get deployments,pods,services
```

I checked for three ready app replicas and one ready MongoDB replica.

### Seed MongoDB

Once the app and database are ready:

```bash
kubectl exec deployment/ttt-deployment -- node seeds/seed.js
```

Runs the seed script inside one app Pod to populate the database.

I checked the command succeeded and refreshed the scoreboard at http://localhost:30001.

This layer has no persistent volume. Database data can be lost when MongoDB’s Pod is replaced.

## Layer 3: Add persistent storage

I added a PV and PVC so database data could survive MongoDB Pod replacement.

- **PV:** defines storage.
- **PVC:** requests storage for the Pod.
- **Volume mount:** connects that storage to MongoDB’s database directory.

### Copy layer 2

```bash
mkdir -p local-ttt-app-mongo-pv-deploy
cp local-ttt-app-mongo-deploy/*.yaml local-ttt-app-mongo-pv-deploy/
```

Creates a third folder and copies my working app and MongoDB configuration.

### Create `local-ttt-app-mongo-pv-deploy/mongo-storage.yaml`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongo-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /var/lib/ttt-mongo
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  volumeName: mongo-pv
  resources:
    requests:
      storage: 1Gi
```

- Defines a PV and a PVC requesting `1Gi`.
- `---` separates the resources.
- `volumeName` connects the PVC to `mongo-pv`.
- `DirectoryOrCreate` creates the node directory if needed.
- `Retain` keeps backing data for manual recovery after claim deletion.
- The host directory does not enforce a `1Gi` disk quota.

This storage is inside my Docker Desktop node. It survives Pod replacement but does not protect against node loss or cluster resets.

### Replace layer 3’s `mongo-deploy.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo-deployment
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
        - name: mongo
          image: mongo:7.0
          ports:
            - containerPort: 27017
          volumeMounts:
            - name: mongo-data
              mountPath: /data/db
      volumes:
        - name: mongo-data
          persistentVolumeClaim:
            claimName: mongo-pvc
```

- `claimName` selects my PVC.
- `mountPath` attaches it at `/data/db`, where MongoDB stores database files.
- `Recreate` stops the old database Pod before starting its replacement during an update.

### Deploy and check

```bash
kubectl apply -f local-ttt-app-mongo-pv-deploy/
```

Creates the storage resources and updates MongoDB to use them.

```bash
kubectl get pv
kubectl get pvc
kubectl get pods
```

Checks the storage and Pods.

I looked for both storage resources showing `Bound` and MongoDB showing `1/1 Running`.

The new storage starts empty. It does not automatically copy the database from layer 2.

### Seed the new database

```bash
kubectl exec deployment/ttt-deployment -- node seeds/seed.js
```

Populates the database on the new storage.

I checked the scoreboard and took a screenshot.

### Test persistence

```bash
kubectl delete pod -l app=mongo
```

Deletes the MongoDB Pod. Its Deployment creates a replacement using the same PVC.

```bash
kubectl get pods -w
```

Watches the Pods until the replacement MongoDB Pod shows `1/1 Running`.

I pressed `Ctrl+C` to stop watching, then refreshed the scoreboard.

The same scores remained without reseeding, so my persistence test passed.

## Problem I fixed during layer 3

MongoDB entered `CrashLoopBackOff`.

```bash
kubectl logs deployment/mongo-deployment --previous --tail=80
```

Shows logs from the previous failed container run.

The error was `No space left on device`.

My original PV path was `/mnt/data/ttt-mongo`. The filesystem containing `/mnt` was only 126MB and was full.

This filesystem had enough available space, so I changed the PV path to `/var/lib/ttt-mongo`.

After saving that change, I recreated the old resources in this order:

```bash
kubectl delete deployment mongo-deployment
kubectl delete pvc mongo-pvc
kubectl delete pv mongo-pv
kubectl apply -f local-ttt-app-mongo-pv-deploy/
```

Removes the old database Deployment and storage definitions, then recreates them using the updated path. Existing database files are not migrated.

MongoDB then started successfully.

I also removed the temporary diagnostic Pods:

```bash
kubectl delete pod node-debugger-docker-desktop-2bpbz node-debugger-docker-desktop-x9kdg
```

Deletes the diagnostic Pods created during my checks.

## Useful troubleshooting commands

```bash
kubectl logs deployment/ttt-deployment --tail=30
```

Shows recent logs from one app Pod.

```bash
kubectl logs deployment/mongo-deployment --tail=30
```

Shows recent MongoDB logs.

```bash
kubectl describe pods -l app=mongo
```

Shows MongoDB Pod details and events.

## Cleanup when finished

I have kept the deployment for now.

After finishing my demo and saving the evidence:

```bash
kubectl delete -f local-ttt-app-mongo-pv-deploy/
```

Deletes the deployed app, MongoDB, Services, PVC and PV.

```bash
kubectl get pv,pvc
```

Checks that the storage resources have been removed.

My local YAML files remain available for redeployment. Because I used Retain, backing files can remain on the node after cleanup.