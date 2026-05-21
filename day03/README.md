# Day 3 — Multi-Stage Docker Build

## What we did
Refactored the single-stage Dockerfile from Day 2 into a multi-stage build
to produce a leaner, cleaner production image.

## Why multi-stage builds matter

Single-stage builds carry everything into the final image — build tools,
pip cache, unnecessary files. In complex apps with compilers or heavy build
tools this can mean hundreds of MB of bloat in production.

Multi-stage builds solve this:
Stage 1 (builder)  →  install everything needed to BUILD the app
Stage 2 (runtime)  →  copy ONLY what's needed to RUN the app

Think of it like building a house — you don't leave the cranes and
scaffolding inside after construction is done.

## Size comparison

| Version      | Image Size |
|--------------|------------|
| Single stage | 55.9MB     |
| Multi stage  | 49.5MB     |

6.4MB smaller on a simple Flask app. On a real production app with heavy
build dependencies the difference can be 300-400MB.

## The Dockerfile explained

```dockerfile
# ── Stage 1: Builder ─────────────────────────────────────────────
FROM python:3.12-slim AS builder
WORKDIR /app

COPY requirements.txt .

# Create isolated virtual environment
RUN python3 -m venv /opt/venv

# Activate venv for all following commands
ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies INTO the venv
RUN pip install -r requirements.txt

# ── Stage 2: Runtime ─────────────────────────────────────────────
FROM python:3.12-slim
WORKDIR /app

# Copy ONLY the venv from stage 1 — no build tools, no pip cache
COPY --from=builder /opt/venv /opt/venv

# Activate the venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy app code
COPY python-app.py .

# Start the app with Gunicorn
CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:5000", "python-app:app"]
```

## Key concepts

**Layer caching** — requirements.txt copied before app code so pip install
is cached and only reruns when dependencies actually change.

**Virtual environment in /opt/venv** — isolated folder containing all
installed packages and executables. Copied cleanly into stage 2.

**ENV PATH="/opt/venv/bin:$PATH"** — tells the container where to find
executables like gunicorn and python. Required in BOTH stages.

**COPY --from=builder** — copies files from a previous stage instead of
from your local machine. This is what makes multi-stage builds work.

## Commands used

```bash
# Build the multi-stage image
docker build -f day03/Dockerfile.multistage -t devops-app:multistage .

# Run the container
docker run -d -p 5000:5000 --name devops-app-multistage devops-app:multistage

# Compare image sizes
docker images

# Test the app
curl http://192.168.56.11:5000/health
```

## Why /opt/venv/bin and not just /opt/venv

Linux virtual environments have a specific structure:
/opt/venv/
├── bin/     ← executables live here (gunicorn, python, pip)
├── lib/     ← installed packages live here (flask, gunicorn code)
└── include/ ← C headers for compiled packages

PATH needs to point to /bin specifically because that's where
the executables are — not the parent folder.
