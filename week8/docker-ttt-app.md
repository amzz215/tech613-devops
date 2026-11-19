## 1. Set up my project folder

```bash
mkdir docker-run-sparta-app
cd docker-run-sparta-app
cp -r "/c/path/to/your/repo/app" .
ls app
```

- `mkdir docker-run-sparta-app` creates a separate folder for this exercise.
- `cd docker-run-sparta-app` moves me into that folder so I can create my Docker files there.
- `cp -r "/c/path/to/your/repo/app" .` copies my existing `app` folder and everything inside it. I replace the example path with my actual app path. The `.` means the destination is my current folder.
- `ls app` shows what I copied. I check that `package.json`, `package-lock.json`, and `index.js` are directly inside `app/`.

## 2. Keep local files out of the image

I used `nano .dockerignore` to create this file next to the `app` folder:

```text
**/node_modules
**/.env
**/.env.*
**/.git
```

This keeps my laptop’s installed packages, environment files, and Git metadata out of the Docker build. Docker installs its own copy of the dependencies. The `**/` patterns also match files or folders inside `app/`.

## 3. Write my Dockerfile

I used `nano Dockerfile` to create this file next to `.dockerignore` and `app/`. In Nano, I used **Ctrl+O → Enter → Ctrl+X** to save and exit. I ran `ls -a` to check that all three were there, including the hidden `.dockerignore` file.

```dockerfile
FROM node:20

WORKDIR /app

COPY app/package.json app/package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY app/ ./

USER node
EXPOSE 3000

CMD ["node", "index.js"]
```

| Instruction | What it does and why I used it |
|---|---|
| `FROM node:20` | Uses Node.js 20 as the base image so Node.js and npm are already available. |
| `WORKDIR /app` | Sets `/app` as my working directory inside the image. The following commands use that directory. |
| `COPY app/package.json app/package-lock.json ./` | Copies the two package files into `/app` before the rest of the code. Docker can reuse the dependency installation when I change only the app code. |
| `RUN npm ci --omit=dev --ignore-scripts` | Installs dependencies using the lockfile. `--omit=dev` skips development dependencies. `--ignore-scripts` skips install hooks, including the app’s scoreboard seeding hook, so seeding doesn’t run during the build. |
| `COPY app/ ./` | Copies the contents of my local `app/` folder into `/app`, excluding what I listed in `.dockerignore`. |
| `USER node` | Runs the app as the `node` user so it doesn’t need root privileges. |
| `EXPOSE 3000` | Documents that the app uses port `3000` inside the container. I still use `-p` when I run it to publish the port on my laptop. |
| `CMD ["node", "index.js"]` | Starts the Node.js app when the container starts. |

## 4. Build and check my image

With Docker Desktop running, I ran these commands from `docker-run-sparta-app`:

```bash
docker build -t amz101/tech613-tttapp:1.2.0 .
docker images
```

- `docker build` follows my Dockerfile to package the app and its dependencies into a local image. `-t` gives the image its name and version tag. The final `.` tells Docker to use the current folder as the build context so it can access `app/`.
- `docker images` lists my local images. I use it to check that `amz101/tech613-tttapp` has the `1.2.0` tag.

## 5. Run and test my app

```bash
docker run -d -p 3000:3000 --name ameen_tttapp amz101/tech613-tttapp:1.2.0
docker ps
```

- `docker run` creates and starts a container from my image. `-d` runs it in the background. `-p 3000:3000` maps port `3000` on my laptop to port `3000` inside the container. `--name ameen_tttapp` gives the container a name I can use to check its logs or stop it.
- `docker ps` lists running containers. I check that `ameen_tttapp` is **Up** and shows `3000->3000/tcp`.

I open `http://localhost:3000` to check that the Tic-Tac-Toe page loads. If it doesn’t, I can run `docker logs ameen_tttapp` to see the app’s startup output and any errors.

## 6. Push my image to Docker Hub

```bash
docker login
docker push amz101/tech613-tttapp:1.2.0
```

- `docker login` signs me in to Docker Hub so I can upload the image to my account.
- `docker push amz101/tech613-tttapp:1.2.0` uploads the image with the `1.2.0` tag. I make the repository public so other people can pull it.

## 7. 

```bash
docker run -d -p 3000:3000 amz101/tech613-tttapp:1.2.0
```