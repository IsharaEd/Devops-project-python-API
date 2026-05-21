# Day 2 — Dockerizing the Flask App

## What we did
Took the Flask app from Day 1 and packaged it into a Docker container.

## Why Docker
The app runs identically on any machine. No more "works on my machine" problems.

## The Dockerfile explained

```dockerfile
FROM python:3.12-slim        # base image - Python on minimal Debian
WORKDIR /app                 # set working directory inside container
COPY requirements.txt .      # copy dependencies list first (layer caching)
RUN pip install -r requirements.txt  # install dependencies
COPY . .                     # copy app code
CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:5000", "python-app:app"]
```

## Key concepts

**Layer caching** — requirements.txt is copied before app code so pip install
is cached. It only reruns when requirements.txt changes, not every code change.

**Gunicorn over python3 app.py** — Flask's built-in server is for development
only. Gunicorn is production grade and handles multiple requests simultaneously.

**Workers formula** — (2 x CPU cores) + 1. App server has 1 core so 3 workers
is ideal. We use 2 here to keep it light for the lab environment.

**.dockerignore** — excludes venv/, .git/, __pycache__ from the image.
Keeps the image small and clean.

## Commands used

```bash
# Build the image
docker build -t devops-app .

# Run the container
docker run -d -p 5000:5000 --name devops-app devops-app

# Check running containers
docker ps

# Check image size
docker images

# Test the app
curl http://192.168.56.11:5000/health
```

## Image size
54.8MB — kept lean by using slim base image and .dockerignore

