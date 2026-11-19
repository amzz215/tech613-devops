# Build and publish a custom Nginx image with a Dockerfile

I used a Dockerfile to package my custom homepage into an Nginx image. This means I can rebuild the image from my files and get the same homepage without editing a running container.

## 1. Create my project folder

```bash
mkdir tech613-mod-nginx-dockerfile
cd tech613-mod-nginx-dockerfile
```

- `mkdir` creates the folder where I keep my homepage and Dockerfile.
- `cd` moves me into that folder so the files I create go in the right place.

## 2. Create my homepage and Dockerfile

```bash
nano index.html
nano Dockerfile
ls
```

- `nano index.html` opens my homepage file so I can write the HTML. The `<h1>` sets the visible heading, and `<title>` sets the text in the browser tab.
- `nano Dockerfile` opens the file where I write the instructions Docker will follow when building the image. The filename is `Dockerfile`, with no extension.
- `ls` lists the files in my current folder. I use it to check that `index.html` and `Dockerfile` are next to each other.

In Nano, I press **Ctrl+O**, then **Enter** to save, and **Ctrl+X** to exit.

My Dockerfile contains:

```dockerfile
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
```

- `FROM nginx` uses the Nginx image as the starting point, so Nginx is already installed and configured to serve its default page.
- `COPY index.html /usr/share/nginx/html/index.html` takes my local HTML file and replaces the default homepage **inside the new image**.

## 3. Build my image

With Docker Desktop running, I run these commands from my project folder:

```bash
docker build -t amz101/tech613-nginx-auto:1.0 .
docker images
```

- `docker build` creates an image using my Dockerfile. `-t` gives it the name `amz101/tech613-nginx-auto` and the version tag `1.0`. The `.` uses my current folder as the build context, giving Docker access to `index.html`.
- `docker images` lists my local images so I can check that `tech613-nginx-auto` exists with the `1.0` tag.

## 4. Run and test my container

```bash
docker run -d -p 90:80 --name ameen_nginx_auto amz101/tech613-nginx-auto:1.0
docker ps
```

- `docker run` creates and starts a container from my image. `-d` runs it in the background. `-p 90:80` maps port `90` on my laptop to port `80` inside the container, where Nginx listens. `--name` gives the container a name I can use to stop or remove it later.
- `docker ps` lists running containers. I use it to check that my container is **Up** and shows the `90->80/tcp` mapping.

I open `http://localhost:90` to check that Nginx serves my custom homepage straight away.

## 5. Publish my image to Docker Hub

```bash
docker login
docker push amz101/tech613-nginx-auto:1.0
```

- `docker login` signs me in to Docker Hub so I can upload images to my account.
- `docker push` uploads my local image with the `1.0` tag. I make the repository public so other people can pull and run it.

```bash
docker run -d -p 90:80 amz101/tech613-nginx-auto:1.0
```

Anyone running it can open `http://localhost:90` to see my custom page. If port `90` is busy on their machine, they can change the **first** port number.
