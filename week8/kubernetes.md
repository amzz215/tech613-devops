# Kubernetes

## Some of the biggest challenges facing enterprises

- Handling traffic and load on applications.
- Cybersecurity and using AI to assist.
- Migrating to the cloud:
  - Controlling costs and auditing resources.
  - Managing data governance.
- Using AI to speed up development, testing and deployment safely.
- Shadow AI: employees using AI tools without organisational approval or oversight.
- Knowing where data is stored and how to secure it.
- Deciding whether to use Kubernetes:
  - Having enough expertise to manage it.
  - Abstracting complexity away from developers.

## Intro to Kubernetes

### Why Kubernetes is needed

Kubernetes manages containerised applications, especially when they need to be resilient and scalable.

### Benefits

- Orchestrates, schedules and manages containers across nodes.
- Open-source.
- Can run locally, on physical servers, on virtual machines or in the cloud.
- **Self-healing:** replaces failed Pods to maintain the desired state.
- **Autoscaling:** adjusts resources when configured.
- **Load balancing:** distributes traffic across application Pods.
- **Rolling updates:** gradually replaces old application versions.
- **Rollbacks:** returns to a previous Deployment version.
- **Desired state:** I describe what should run, and Kubernetes works to maintain it.
- Can improve deployment speed and resource efficiency.
- Can help applications handle increased demand; performance still depends on the application and configuration.

### Success story

- Pokémon Go used Google Kubernetes Engine to support its application.

## Kubernetes architecture

### What is a cluster?

- A cluster consists of a control plane and nodes running workloads.
- A **node** is a physical or virtual machine.
- One node can perform both control plane and worker roles.
- Single-node clusters are useful for learning and development.
- Production clusters usually use multiple nodes for availability.

### Control plane vs data plane

- **Control plane:** manages the cluster and makes decisions.
- **Data plane:** runs applications and handles their traffic.

### Control plane nodes

Previously called master nodes.

| Component | What it does |
|---|---|
| API server | Receives requests, including commands from `kubectl`. |
| etcd | Stores cluster configuration and state. |
| Scheduler | Chooses a suitable node for an unscheduled Pod. |
| Controller manager | Runs controllers that bring the actual state towards the desired state. |

- Three control plane nodes are commonly used for a highly available, self-managed setup.
- Three is not a requirement for every production cluster.
- With managed Kubernetes, the provider manages the control plane.

### Worker nodes

- Often simply called nodes.
- Run application Pods.
- Form the data plane.

| Component | What it does |
|---|---|
| kubelet | Makes sure the containers assigned to its node are running. |
| Container runtime | Runs containers, for example using containerd. |
| kube-proxy | Implements Service networking rules, where used. |

### Azure Kubernetes Service (AKS)

- Azure manages the control plane.
- Worker nodes commonly run on Azure virtual machines.
- AKS has Free, Standard and Premium cluster management tiers.
- Worker resources, storage and networking can still cost money.
- Azure provides portal tools for managing and monitoring the cluster.

### Amazon EKS and Google GKE

- EKS is Amazon Elastic Kubernetes Service.
- GKE is Google Kubernetes Engine.
- Both provide managed Kubernetes.
- Cluster management and workload resources can have separate charges.
- Pricing depends on the provider, service mode and plan, so I should check current prices rather than assume a fixed hourly charge.

### Minikube

- Runs a local Kubernetes cluster for learning, experimentation and development.
- Supports single-node and multi-node setups.
- Depending on its driver, nodes can run in containers or virtual machines.
- In a single-node setup, the same node can perform control plane and worker roles.

### Docker Desktop

- Provides a local Kubernetes environment.
- My Docker Desktop Kubeadm setup uses one node for control plane and worker roles.

### Managed service vs setting up Kubernetes myself

**Managed service benefits:**

- Less control plane maintenance.
- Provider handles much of the control plane operation and patching.
- Less specialist work needed to operate the control plane.
- More time to focus on delivering applications.

**Managed service disadvantages:**

- Cluster management charges can apply.
- Provider-specific features can create dependencies.
- I still need to manage application configuration, access, security and costs.

## Kubernetes objects

| Object or term | Simple meaning |
|---|---|
| Deployment | Manages ReplicaSets and application updates. |
| ReplicaSet | Maintains the required number of matching Pods. |
| Pod | The smallest deployable unit; contains one or more containers. |
| Replica | Another copy of an application Pod. |
| Service | Provides a stable network endpoint for reaching Pods. |
| Label | Identifies an object, such as `app: ttt`. |
| Selector | Finds objects with matching labels. |
| StatefulSet | Manages workloads needing stable Pod identities and storage associations. |

### What does ephemeral mean?

- Pods are temporary and can be removed and replaced.
- A replacement is a new Pod and can have a different IP address.
- A Service provides stable access to the application.
- Persistent storage keeps required data beyond an individual Pod’s lifetime.

## My Tic-Tac-Toe architecture

My planned app-only setup uses:

- One local Kubernetes cluster.
- One node called `docker-desktop`.
- One Deployment managing a ReplicaSet.
- Three Pods, each running one Tic-Tac-Toe app container.
- One NodePort Service to access the app from my browser.

### How the objects connect

- The Deployment manages the ReplicaSet.
- The ReplicaSet maintains three app Pods.
- Each app container listens on port `3000`.
- The Service selects Pods using matching labels, such as `app: ttt`.
- Browser traffic reaches the Pods through the Service.
- Traffic does not pass through the Deployment or ReplicaSet.
- `30001` is my chosen example NodePort.
- Three replicas is a fixed desired count until I change it or configure autoscaling.
- Three Pods on one node do not protect the app against that node failing.

## Kubernetes YAML configuration

I use YAML files to describe the objects I want Kubernetes to create.

- `apiVersion`: the API version for the object.
- `kind`: the object type, such as Deployment or Service.
- `metadata`: information such as its name and labels.
- `spec`: the desired configuration.
- A Deployment’s Pod template describes the Pods it should create.

Docker Compose and Kubernetes both use YAML, but their configuration structures are different.

## Persistent storage

- **PersistentVolume (PV):** storage with a lifecycle separate from an individual Pod.
- **PersistentVolumeClaim (PVC):** a request for storage that a Pod can use.
- For MongoDB, I mount persistent storage at its database directory so the stored data can survive Pod replacement.
- Persistent storage does not replace the need for backups.

## Container security and maintained images

### What are maintained images?

Images updated by an organisation, community or individual.

For example, Canonical maintains official Ubuntu images.

### Benefits

- Provide a maintained foundation for building and running applications.
- Receive bug fixes and security updates.
- Save me from building everything from scratch.

### Limitations and security considerations

- Maintained images can still contain vulnerabilities.
- Updates can introduce changes that need testing.
- I need to rebuild and redeploy my application to include updated base-image contents.
- I should use trusted images and scan them.
- I should run containers without root where practical.
- I should avoid storing credentials inside images.

## Types of autoscaling in Kubernetes

Autoscaling requires configuration and supporting components.

### Horizontal Pod Autoscaler (HPA)

- Changes the number of Pod replicas.
- Can target a Deployment, ReplicaSet or StatefulSet.
- Uses CPU, memory or configured custom/external metrics.
- Configured using Kubernetes resource definitions.
- CPU utilisation-based scaling needs CPU requests and a working metrics source, commonly Metrics Server.
- Example: adding more Tic-Tac-Toe Pods when CPU usage increases.

### Cluster Autoscaler

- Changes the number of nodes.
- Adds nodes when eligible pending Pods cannot fit on existing nodes.
- Can remove nodes when their workloads can safely run elsewhere.
- Configured at cluster level with infrastructure integration.
- HPA creates demand for more Pods; Cluster Autoscaler can provide additional node capacity when configured.

### Vertical Pod Autoscaler (VPA)

- Adjusts CPU and memory requests for containers.
- Changes resources per Pod rather than the number of Pods.
- Requires additional components and Kubernetes resource definitions.
- Example: giving each app container more requested memory.

### KEDA - Kubernetes Event-driven Autoscaling

- Scales workloads using events and external metrics.
- Can use event sources such as message queues.
- Integrates with HPA and requires additional installation and configuration.
- Example: increasing worker replicas when more messages are waiting.

### Simple comparison

| Type | What changes? |
|---|---|
| HPA | Number of Pods. |
| Cluster Autoscaler | Number of nodes. |
| VPA | Resources requested by containers. |
| KEDA | Workload scaling driven by configured events and metrics. |