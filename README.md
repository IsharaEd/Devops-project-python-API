# DevOps Mastery — Project 1: Flask API & Local Lab

![Project](https://img.shields.io/badge/Project-1%20of%206-blue)
![Stack](https://img.shields.io/badge/Stack-Python%20%7C%20Flask%20%7C%20Nginx%20%7C%20Vagrant-orange)
![Status](https://img.shields.io/badge/Status-In%20Progress-green)

A hands-on DevOps learning project — 3 Ubuntu servers, a REST API, and a
reverse proxy setup. Part of a structured 6-month DevOps curriculum.

---

## Architecture

Your Windows Host Machine
┌──────────────────────────────────────────────────────┐
│  Vagrantfile                                         │
│       │ vagrant up                                   │
│       ▼                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │control-plane │  │  app-server  │  │ db-server │  │
│  │192.168.56.10 │  │192.168.56.11 │  │192.168.56 │  │
│  │              │  │              │  │    .12    │  │
│  │ Ansible      │──│ Nginx :80    │  │ PostgreSQL│  │
│  │ AWS CLI      │  │ Gunicorn     │  │ (soon)   │  │
│  │ kubectl      │  │ Flask :5000  │  │           │  │
│  └──────────────┘  └──────────────┘  └───────────┘  │
└──────────────────────────────────────────────────────┘
Request flow:
Browser → Nginx :80 → proxy_pass → Gunicorn :5000 → Flask app

---

## Server Specs

| Server        | IP             | RAM | CPU | Role                       |
|---------------|----------------|-----|-----|----------------------------|
| control-plane | 192.168.56.10  | 4GB | 2   | Ansible, CLI tools         |
| app-server    | 192.168.56.11  | 2GB | 1   | Flask API, Nginx, Gunicorn |
| db-server     | 192.168.56.12  | 2GB | 1   | PostgreSQL (coming soon)   |

---

## Prerequisites

Install these on your Windows host machine:

| Tool       | Download                                  | Purpose        |
|------------|-------------------------------------------|----------------|
| VirtualBox | https://www.virtualbox.org/wiki/Downloads | Runs the VMs   |
| Vagrant    | https://www.vagrantup.com/downloads       | Provisions VMs |
| Git        | https://git-scm.com/download/win          | Version control|

---

## Quick Start

### 1. Clone the repo
```bash
git clone https://github.com/YOUR-USERNAME/devops-lab.git
cd devops-lab
```

### 2. Spin up all 3 servers
```bash
vagrant up
```

### 3. Verify all VMs are running
```bash
vagrant status
```

Expected output:
control-plane    running (virtualbox)
app-server       running (virtualbox)
db-server        running (virtualbox)

### 4. SSH into the app server
```bash
vagrant ssh app-server
```

---

## Setting Up the App (app-server)

```bash
# Install dependencies
sudo apt update
sudo apt install python3-full python3-venv nginx -y

# Create app directory and clone repo
sudo mkdir -p /opt/devops-app
sudo chown vagrant:vagrant /opt/devops-app
cd /opt/devops-app
git clone https://github.com/YOUR-USERNAME/devops-lab.git .

# Set up virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run the app
gunicorn --workers 2 --bind 0.0.0.0:5000 python-app:app
```

---

## API Endpoints

Base URL: `http://192.168.56.11`

| Method | Endpoint  | Description         | Response                                     |
|--------|-----------|---------------------|----------------------------------------------|
| GET    | /health   | Health check        | `{"status": "ok"}`                           |
| GET    | /items    | List of items       | `{"items": ["item1", "item2", "item3"]}`     |
| GET    | /users    | List of users       | `{"users": ["alice", "bob", "charlie"]}`     |
| POST   | /echo     | Echoes request body | `{"you_sent": {"key": "value"}}`             |
| GET    | /version  | App version         | `{"version": "1.0.0", "app": "devops-app"}}` |

### Test with curl
```bash
curl http://192.168.56.11/health
curl http://192.168.56.11/items
curl http://192.168.56.11/users
curl http://192.168.56.11/version

curl -X POST http://192.168.56.11/echo \
  -H "Content-Type: application/json" \
  -d '{"message": "hello devops"}'
```

---

## 6-Month Roadmap

| Month | Project                        | Status         |
|-------|--------------------------------|----------------|
| 1     | Flask API + Local Lab Setup    | ✅ In Progress  |
| 2     | AWS Infrastructure (Terraform) | 🔜 Up Next      |
| 3     | Kubernetes on EKS              | ⏳ Planned      |
| 4     | Monitoring & Observability     | ⏳ Planned      |
| 5     | DevSecOps Pipeline             | ⏳ Planned      |
| 6     | GitOps with ArgoCD             | ⏳ Planned      |

---

## Key Concepts Covered (Project 1)

- **Reverse proxy** — Nginx forwards requests to Gunicorn, not serving files
- **Virtual environments** — isolates Python dependencies per project
- **Gunicorn** — production WSGI server vs Flask's built-in dev server
- **Infrastructure as code** — one Vagrantfile recreates the entire lab
- **Git fundamentals** — init, add, commit, push

---

## License
MIT
