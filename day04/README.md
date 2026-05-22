# Day 4 — Docker Compose

## What we did
Instead of running each container manually with separate `docker run` commands,
we defined both the Flask app and Postgres database in a single
`docker-compose.yml` file and spun them both up with one command.

## The problem Docker Compose solves

Without Compose, running a multi-container setup looks like this:

```bash
docker run -d -p 5000:5000 --name python-api python-api-app
docker run -d -p 5432:5432 --name postgres-db postgres
```

Add Nginx, Redis, a queue — now you're running 5-6 commands every time.
And tearing it all down is just as painful.

Docker Compose replaces all of that with:

```bash
docker compose up    ← starts everything
docker compose down  ← stops and removes everything
```

---

## The docker-compose.yml explained

```yaml
services:
  app:
    container_name: python-api-container  # name of the running container
    build: .                              # build image from Dockerfile at root
    ports:
      - "5000:5000"                       # host:container port mapping
    networks:
      - flask-network                     # attach to shared network
    depends_on:
      - db                                # start db first, then app

  db:
    container_name: postgres-db
    image: postgres                       # official postgres image from Docker Hub
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: flask-db               # database name to create
      POSTGRES_USER: flask                # username
      POSTGRES_PASSWORD: test@123         # password
    networks:
      - flask-network

networks:
  flask-network:
    driver: bridge                        # isolated internal network
```

---

## Key concepts

**Services** — each container is defined as a service. Services are the
building blocks of a Compose file.

**build: .** — tells Compose to build the image from the Dockerfile in the
current directory instead of pulling a pre-built image.

**depends_on** — controls startup order. The app service waits for db to
start before it launches. Prevents the app from crashing because the
database isn't ready yet.

**networks** — by default two containers cannot talk to each other. Attaching
both services to the same network allows them to communicate using the
service name as the hostname. The Flask app connects to Postgres at `db:5432`
not at an IP address.

**environment** — passes configuration into the container at runtime. Postgres
uses these to create the database, user, and password on first startup.

**driver: bridge** — creates an isolated internal network between containers
on the same host.

---

## Successful output

After running `docker compose up`, `docker compose ps` should show:
NAME          IMAGE            COMMAND                  SERVICE   CREATED        STATUS        PORTS
postgres-db   postgres         "docker-entrypoint.s…"   db        1 minute ago   Up 1 minute   0.0.0.0:5432->5432/tcp
python-api    python-api-app   "gunicorn --workers …"   app       1 minute ago   Up 59 seconds 0.0.0.0:5000->5000/tcp

---

## Commands to practise

```bash
# Start all containers in foreground (see logs)
docker compose up

# Start all containers in background
docker compose up -d

# Stop and remove containers
docker compose down

# Check running containers
docker compose ps

# See logs from all services
docker compose logs

# See logs from one service only
docker compose logs app
docker compose logs db

# Rebuild image and start
docker compose up --build
```

Practise `docker compose up` and `docker compose down` until it's
muscle memory. That's the goal of this day.

---

## Important note on file location

The `docker-compose.yml` lives at the **root** of the project — not inside
this day04 folder. Always run docker compose commands from the project root:

```bash
cd /opt/devops-app
docker compose up
```

Running from inside day04/ will fail because `build: .` won't find
the Dockerfile.

---

## What's next — Day 5

Write 3–4 basic unit tests for your API endpoints using pytest. These will be triggered automatically in your
pipeline later
