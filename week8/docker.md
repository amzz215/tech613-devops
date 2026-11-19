## What is virtualisation 

Virtualisation layer controls hardware usage, dependent on the personal physical hardware. 

- Portability: No need to re-write code for different systems 
- Scalability: Lightweight and efficient compared to VMs
- Fault Tolerance: You can isolate individual parts of software. One faulty container will not be a big problem. 
- Agility: Changes can be made without interfering  with OS or hardware. 

## What is docker 

A way to create, monitor and manage our containers. 
Run your app from anywhere.

Intro to  microservices, containers and Docker

## Virtualisation vs containerisation

### Traditional setup

If I run one app per physical server, each app gets its own machine. The downside is that spare CPU and memory can sit unused, even if another app needs those resources.

### Virtual machines

A hypervisor lets me run several virtual machines (VMs) on one physical server. Each VM has its own guest operating system, including its own kernel, plus the app and its dependencies.

This makes better use of the hardware than giving every app its own physical server. The trade-off is that each VM needs resources to run and maintain a full operating system.

### Containers

A container runs my app with the libraries and files it needs. It shares the kernel of the environment running it, so it doesn't need to boot a separate operating system. This generally makes containers lighter and quicker to start than VMs.

I can use both together. For example, I can run Docker containers inside an EC2 VM. The VM gives me a separate environment, and the containers package and run my apps inside it.

## Microservices

Microservices split an application into smaller services based on what each part does. They can communicate through APIs.

If I split my code into different files but still deploy it all as one app, it can still be a monolith. With microservices, I can deploy the services independently. Containers make this easier by packaging each service with its own dependencies, but microservices can also run on VMs.

The benefit is that I can update or scale one part on its own. For example, if payments get busy, I can run more copies of the payments service without scaling the whole shop. The trade-off is that I have more services to manage and troubleshoot.

## What is Docker and why use it?

Docker is a tool I can use to build images and create, run, inspect and manage containers. I can package my app with its dependencies so the same image can run in different compatible environments without me setting everything up again by hand.

- **Image:** The packaged files and settings used to create a container.
- **Container:** An instance created from that image.
- **Registry:** A place where images are stored and shared. Docker Hub is an example.
- **Tag:** A label that identifies which version I want, such as `v1`.

I think of it like an AMI and an EC2 instance: I can create multiple instances from the same image. If I edit a file inside one container, the original image doesn't change.

Containers are **replaceable**. They can run for a long time, but when I update my app, I can build a new image and replace the old container.

## Docker alternative: Podman

Podman can also run containers, and many of its commands look like Docker commands. It can run without a central background service and supports running containers without root privileges. 

## How Docker works

1. I enter a command in the **Docker CLI**, such as `docker run nginx`.
2. The CLI sends the request through the **Docker API** to the **Docker daemon**, the background service that manages images and containers.
3. Docker checks whether the image is already available locally. If it isn't, Docker normally pulls it from a registry such as Docker Hub.
4. Docker uses the image to create and start a container.

Most images build on an existing **base image**. Different organisations publish these images, so I can choose one that already includes what my app needs.

## Security

Containers share a kernel, so I need to account for that when deciding how to isolate workloads. A VM has its own guest kernel and can provide a separate boundary. Ramon pointed out that running containers inside a VM lets me use both approaches together.

Expedia. 