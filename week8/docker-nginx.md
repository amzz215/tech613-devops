## Week 8: Docker Nginx code-along

### 1. Check that Docker works

I ran these commands in Git Bash with Docker Desktop open:

```bash
docker run hello-world
docker ps -a
```

- `docker run hello-world` downloads the `hello-world` image if it isn’t already on my laptop, then creates and starts a container from it. I used it to check that Docker could pull an image and run a container.
- `docker ps -a` lists all containers, including stopped ones. I used it to check that `hello-world` showed `Exited (0)`, meaning it finished successfully after printing its message.

### 2. Download the Nginx image and start a container

```bash
docker pull nginx
docker run -d -p 80:80 nginx
docker ps
```

- `docker pull nginx` downloads the Nginx image from Docker Hub. Without a tag, Docker uses `latest`. I downloaded it first so it was available locally before I started the container.
- `docker run -d -p 80:80 nginx` creates and starts a container from that image. `-d` runs it in the background. `-p 80:80` maps port `80` on my laptop to port `80` inside the container, where Nginx listens.
- `docker ps` lists running containers. I used it to check that Nginx was **Up** and that the port was mapped. Docker named this container `sweet_euler` because I hadn’t given it a name.

I opened `http://localhost` to check that Nginx was serving its default homepage.

### 3. Practise stopping, starting and removing a container

```bash
docker stop sweet_euler
docker start sweet_euler
docker rm sweet_euler
docker rm --help
docker rm -f sweet_euler
docker ps -a
```

- `docker stop sweet_euler` stops the container but keeps it available to start again. I used it to take the page offline without deleting the container.
- `docker start sweet_euler` starts the same stopped container. I used it to bring the page back without creating a new container.
- `docker rm sweet_euler` attempts to remove the container. I tried it while the container was running, so Docker refused as expected.
- `docker rm --help` shows the options for removing a container. I used it to check what `-f` does.
- `docker rm -f sweet_euler` forcibly stops and removes the running container. I used it to remove the practice container. The Nginx image stayed on my laptop.
- `docker ps -a` confirms the container is gone, even from the list of stopped containers.

### 4. Create a new container and open a shell inside it

```bash
docker run -d -p 80:80 --name ameen_nginx nginx
docker exec -it ameen_nginx sh
```

- `docker run -d -p 80:80 --name ameen_nginx nginx` creates a fresh Nginx container on port `80`. I used `--name` so I could refer to it as `ameen_nginx` when opening a shell or saving it as an image.
- `docker exec -it ameen_nginx sh` opens a shell inside my running container. `-i` keeps input open so I can type, and `-t` gives me a terminal. I used it to edit the files Nginx was serving.

### 5. Check the container and edit the homepage

I ran these commands **inside the container**:

```bash
ls
uname
apt-get update
apt-get upgrade -y
sudo systemctl status nginx
apt-get install sudo
```

- `ls` lists the files and folders in my current directory. I used it to see what was inside the container.
- `uname` prints the kernel name. I used it to confirm that the container was running with a Linux kernel.
- `apt-get update` refreshes the package lists so the package manager knows what versions are available.
- `apt-get upgrade -y` upgrades installed packages. `-y` automatically answers yes to confirmation prompts. This was part of the demo; it wasn’t needed to edit the homepage.
- `sudo systemctl status nginx` was the demo’s check for whether `sudo` was available. It failed with `sudo: not found`.
- `apt-get install sudo` installs `sudo`. I followed the demo, although I was already root inside the container and didn’t need it for the homepage edit.

I then went to the homepage folder and opened the file:

```bash
cd /usr/share/nginx/html
apt-get install nano
nano index.html
```

- `cd /usr/share/nginx/html` moves me into the folder containing the default homepage.
- `apt-get install nano` installs the text editor because it wasn’t included in the container.
- `nano index.html` opens the homepage so I can edit it. I changed the `<h1>` for the visible heading. The `<title>` controls the browser tab text.

I pressed **Ctrl+O -> Enter -> Ctrl+X** to save and exit Nano, then refreshed `http://localhost` to check the change.

```bash
exit
docker ps
```

- `exit` closes the shell I opened inside the container and returns me to Git Bash.
- `docker ps` runs back on my laptop. I used it to confirm that Nginx was still running after I closed the shell.

### 6. Run a second container on a different port

```bash
docker run -d -p 90:80 --name ameen_nginx2 nginx
```

I started a separate container from the original Nginx image. `-p 90:80` maps port `90` on my laptop to port `80` inside this second container. This let me open it at `http://localhost:90` while my customised `ameen_nginx` container stayed on `http://localhost`.

### 7. Save and publish my customised image

```bash
docker commit ameen_nginx amz101/tech613-nginx:v1
docker images
docker login
docker push amz101/tech613-nginx:v1
```

- `docker commit ameen_nginx amz101/tech613-nginx:v1` saves my edited container as a new local image. I chose `ameen_nginx` because it contained my personalised homepage. `amz101` is my Docker Hub username, `tech613-nginx` is the repository name, and `v1` is the tag.
- `docker images` lists my local images so I can check that the new image and tag exist.
- `docker login` authenticates me with Docker Hub so I can upload the image. Docker reused my saved credentials.
- `docker push amz101/tech613-nginx:v1` uploads that image tag to Docker Hub. I use a public repository so others can pull it.

### 8. Test the published image and share my run command

```bash
docker run --pull=always -d -p 8080:80 amz101/tech613-nginx:v1
```

I used `--pull=always` to check Docker Hub before starting the container. I tested on port `8080` because my other containers were using ports `80` and `90`.

```bash
docker stop ameen_nginx2
docker run -d -p 90:80 amz101/tech613-nginx:v1
```

- `docker stop ameen_nginx2` frees port `90` so I can test the command I’m sharing.
- `docker run -d -p 90:80 amz101/tech613-nginx:v1` starts a new container from my custom image. I opened `http://localhost:90` to check that it showed my personalised heading. This is the command I share so others can run the same image.