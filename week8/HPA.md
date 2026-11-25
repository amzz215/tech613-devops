# Kubernetes: Autoscaling my Tic-Tac-Toe app

I configured a Horizontal Pod Autoscaler (HPA) to scale only my app between **2 and 10 replicas** based on CPU usage.

MongoDB stays at one replica.

All file paths below start from `week8/yaml-definitions`.

## 1. Install Metrics Server

```bash
kubectl top pods
```

Checks CPU and memory usage. Initially, this returned `Metrics API not available`.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Installs Metrics Server, which supplies the CPU readings needed by my HPA.

### Fix my local certificate error

```bash
kubectl logs -n kube-system deployment/metrics-server --tail=20
```

Shows recent Metrics Server logs. Mine showed a kubelet certificate verification error.

```bash
kubectl patch deployment metrics-server -n kube-system --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

Disables kubelet certificate verification for my local learning setup. This is not my production configuration.

```bash
kubectl rollout status deployment/metrics-server -n kube-system --timeout=120s
```

Waits for the updated Metrics Server to become ready.

```bash
kubectl top pods
```

Confirms CPU and memory readings are now available.

## 2. Update the app Deployment

In `local-ttt-app-mongo-pv-deploy/ttt-deploy.yaml`, I added this under the app container:

```yaml
          resources:
            requests:
              cpu: 100m
```

This requests **0.1 CPU** per app container. The HPA uses this request to calculate CPU utilisation.

I also removed:

```yaml
  replicas: 3
```

The HPA now manages the replica count.

## 3. Create the HPA

I created `local-ttt-app-mongo-pv-deploy/ttt-hpa.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ttt-deployment
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ttt-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

- `scaleTargetRef`: selects my app Deployment.
- `minReplicas`: keeps at least two app replicas.
- `maxReplicas`: allows up to ten app replicas.
- `averageUtilization: 50`: targets average CPU usage at 50% of the CPU request.

## 4. Apply the configuration

```bash
kubectl apply -f local-ttt-app-mongo-pv-deploy/ttt-deploy.yaml
kubectl apply -f local-ttt-app-mongo-pv-deploy/ttt-hpa.yaml
```

Updates my app Deployment and creates or updates the HPA.

```bash
kubectl rollout status deployment/ttt-deployment
```

Waits for the updated app Pods to become ready.

```bash
kubectl get hpa
```

Checks the CPU target, replica limits and current replica count. Metrics may take a minute to appear.

## 5. Test with Apache Bench

In one Git Bash window:

```bash
kubectl get hpa -w
```

Watches the HPA as CPU usage and replica counts change. `Ctrl+C` stops watching.

In a second Git Bash window:

```bash
docker run --rm httpd:2.4 ab -n 1000000 -t 180 -c 50 http://host.docker.internal:30001/
```

Runs Apache Bench against my app through Docker.

- `--rm`: removes the test container afterwards.
- `httpd:2.4`: image containing Apache Bench.
- `ab`: starts the load test.
- `-n 1000000`: maximum number of requests.
- `-t 180`: runs for up to three minutes.
- `-c 50`: sends up to 50 requests concurrently.
- `host.docker.internal:30001`: reaches my app through the laptop's NodePort.

## 6. Check the result

I check that:

- App replicas increase when CPU usage is high enough.
- Replicas stay within the configured range of 2–10.
- After the load stops, replicas reduce towards two.
- MongoDB remains at one replica.

If scaling does not happen:

```bash
kubectl describe hpa ttt-deployment
```

Shows the HPA's conditions and events to help identify the cause.