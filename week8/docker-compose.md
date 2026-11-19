# Tic-Tac-Toe and MongoDB with Docker Compose

I use Docker Compose to run my app and MongoDB in separate containers using one configuration file.

## Create my project

```bash
mkdir docker-compose-sparta-app
cd docker-compose-sparta-app
nano docker-compose.yml
```

- `mkdir` creates my project folder.
- `cd` moves me into it.
- `nano` opens the Compose file so I can add the settings below.

```yaml
services:
  db:
    image: mongo:7.0
    volumes:
      - mongo-data:/data/db

  app:
    image: amz101/tech613-tttapp:1.2.0
    ports:
      - "3000:3000"
    environment:
      MONGODB_URI: mongodb://db:27017/tictactoe
    depends_on:
      - db

volumes:
  mongo-data:
```

I use `db` as the database address because Compose lets containers find each other by service name. The app uses port `27017` to reach MongoDB.

`3000:3000` connects port `3000` on my laptop to port `3000` inside the app container. I don’t publish a database port because only the app needs to reach it.

`mongo-data` keeps my database files when the containers are removed. `depends_on` starts the database container first, but it doesn’t wait until MongoDB is ready.

## Start my app and database

With Docker Desktop running, I run these commands from my project folder:

```bash
docker compose up -d
docker compose ps
```

- `docker compose up -d` reads my Compose file and starts both services in the background. It downloads missing images.
- `docker compose ps` shows whether the project’s containers are running.

I open http://localhost:3000 to check the app.

## Seed my database

```bash
docker compose exec app node seeds/seed.js
```

This runs `node seeds/seed.js` inside my running app container. The script uses `MONGODB_URI` to connect to MongoDB and add the starter scoreboard records. I check the output to confirm seeding succeeded.

## Check logs and images

```bash
docker compose logs app
docker compose logs -f
docker compose images
```

- `docker compose logs app` shows the app’s output so I can check for errors.
- `docker compose logs -f` follows new output from both services. Ctrl+C stops following the logs without stopping the containers.
- `docker compose images` lists the images used by my project’s containers.

## Stop and restart

```bash
docker compose down
docker compose up -d
```

- `docker compose down` stops and removes the project’s containers and network. It keeps my named database volume.
- `docker compose up -d` recreates the containers and reuses the stored database data.

I check the scoreboard without seeding again to test that my data survived. I avoid `docker compose down -v` because it also deletes the named volume.


