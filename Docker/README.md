# 🏠 Homelab Docker Compose Stack

Complete Docker Compose setup for CachyOS + Hyprland + Caelestia with RTX 3060 12GB

## 📋 Services Included

### 🔐 Reverse Proxy & Networking
- **Nginx Proxy Manager** - Easy SSL and reverse proxy management
- **Cloudflare DDNS** - Automatic DNS updates

### 🛠️ Management & Monitoring
- **Portainer** - Container management UI
- **Watchtower** - Automatic container updates
- **Autoheal** - Automatic container healing
- **DIUN** - Docker image update notifications
- **Dozzle** - Real-time log viewer

### 📊 Observability
- **Grafana** - Metrics visualization
- **Prometheus** - Metrics collection
- **Netdata** - Real-time performance monitoring
- **Uptime Kuma** - Uptime monitoring

### 🔒 Security
- **CrowdSec** - Behavioral IPS
- **Authelia** - SSO authentication

### 🗄️ Databases
- **PostgreSQL** - Primary relational database
- **MariaDB** - MySQL-compatible database
- **Redis** - In-memory data store

### 🤖 Automation & Workflows
- **n8n** - Workflow automation

### 🧰 Utilities & Tools
- **IT-Tools** - Developer tools collection
- **Homarr** - Dashboard homepage
- **File Browser** - Web-based file manager
- **Snippet Box** - Code snippet manager
- **Change Detection** - Website change monitoring
- **Playwright Chrome** - Browser automation
- **Wetty** - Web-based terminal

### 🤖 AI & ML (GPU-Accelerated)
- **Open WebUI** - ChatGPT-like interface for local LLMs
- **ComfyUI** - Node-based Stable Diffusion UI
- **Stable Diffusion WebUI** - Image generation

### 💾 Backup & Sync
- **PostgreSQL Backup** - Automated database backups
- **Duplicati** - Backup solution
- **Syncthing** - File synchronization

### 📄 Document Management
- **Paperless-ngx** - Document management system

## 🚀 Quick Start

### Prerequisites

1. **Docker & Docker Compose** (already installed via install.sh)
2. **NVIDIA Container Toolkit** (already installed via install.sh)
3. **Sufficient disk space** (recommended 100GB+ free)

### Installation Steps

1. **Clone or download these files to your homelab directory:**
   ```bash
   mkdir -p ~/homelab
   cd ~/homelab
   # Copy docker-compose.yml, .env.example, homelab.sh here
   ```

2. **Create your .env file:**
   ```bash
   cp .env.example .env
   ```

3. **Generate secure keys:**
   ```bash
   chmod +x homelab.sh
   ./homelab.sh keys
   ```

4. **Edit .env file with your values:**
   ```bash
   nano .env  # or use your preferred editor
   ```

   **Required variables to configure:**
   - `POSTGRES_PASSWORD` - PostgreSQL password
   - `REDIS_PASSWORD` - Redis password
   - `MYSQL_ROOT_PASSWORD` - MariaDB root password
   - `N8N_BASIC_AUTH_PASSWORD` - n8n authentication
   - `PAPERLESS_SECRET_KEY` - Paperless-ngx secret
   - `PAPERLESS_ADMIN_PASSWORD` - Paperless admin password
   
   **Optional but recommended:**
   - Cloudflare credentials (for DDNS)
   - Authelia secrets (for SSO)
   - OpenAI API key (for Open WebUI)

5. **Create prometheus directory and config:**
   ```bash
   mkdir -p prometheus
   # Copy prometheus.yml to prometheus/ directory
   ```

6. **Start the stack:**
   ```bash
   ./homelab.sh start
   ```

## 📖 Usage

### Management Script Commands

```bash
./homelab.sh start          # Start all services
./homelab.sh stop           # Stop all services
./homelab.sh restart        # Restart all services
./homelab.sh restart nginx-proxy-manager  # Restart specific service
./homelab.sh status         # Show service status
./homelab.sh logs           # Show all logs
./homelab.sh logs grafana   # Show logs for specific service
./homelab.sh update         # Update all images and containers
./homelab.sh backup         # Backup all volumes
./homelab.sh stats          # Show resource usage
./homelab.sh urls           # Show all service URLs
./homelab.sh cleanup        # Clean up Docker
./homelab.sh keys           # Generate secure keys
./homelab.sh help           # Show help
```

### Service Access URLs

After starting, access services at:

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| Nginx Proxy Manager | http://localhost:81 | admin@example.com / changeme |
| Portainer | http://localhost:9000 | Set on first run |
| Grafana | http://localhost:3000 | admin / admin |
| Prometheus | http://localhost:9090 | - |
| Netdata | http://localhost:19999 | - |
| Uptime Kuma | http://localhost:3001 | Set on first run |
| Dozzle | http://localhost:8888 | - |
| CrowdSec | http://localhost:8080 | - |
| Authelia | http://localhost:9091 | Configure via config |
| n8n | http://localhost:5678 | From .env |
| IT-Tools | http://localhost:8282 | - |
| Homarr | http://localhost:7575 | - |
| File Browser | http://localhost:8081 | admin / admin |
| Snippet Box | http://localhost:5000 | - |
| Change Detection | http://localhost:5050 | - |
| Wetty | http://localhost:3002 | SSH credentials |
| Open WebUI | http://localhost:3030 | Register on first run |
| ComfyUI | http://localhost:8188 | - |
| SD WebUI | http://localhost:7860 | - |
| Duplicati | http://localhost:8200 | - |
| Syncthing | http://localhost:8384 | - |
| Paperless-ngx | http://localhost:8010 | From .env |

## 🎨 Initial Configuration

### 1. Nginx Proxy Manager
1. Access http://localhost:81
2. Login with: `admin@example.com` / `changeme`
3. Change admin password immediately
4. Add proxy hosts for your services
5. Configure SSL certificates (Let's Encrypt)

### 2. Portainer
1. Access http://localhost:9000
2. Create admin account
3. Connect to local Docker environment

### 3. Grafana
1. Access http://localhost:3000
2. Login: admin / admin
3. Add Prometheus data source:
   - URL: http://prometheus:9090
4. Import dashboards (recommended):
   - Docker Container & Host Metrics (ID: 10619)
   - Node Exporter Full (ID: 1860)
   - Netdata (ID: 2701)

### 4. Uptime Kuma
1. Access http://localhost:3001
2. Create admin account
3. Add monitors for all your services

### 5. n8n
1. Access http://localhost:5678
2. Login with credentials from .env
3. Start creating workflows

### 6. Open WebUI
1. Install Ollama on host:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
2. Pull a model:
   ```bash
   ollama pull llama3.2
   ```
3. Access http://localhost:3030
4. Register account
5. Start chatting

### 7. Paperless-ngx
1. Access http://localhost:8010
2. Login with credentials from .env
3. Configure consumption folder
4. Set up document types and tags

## 🔧 Advanced Configuration

### Enable GPU for AI Services

The docker-compose.yml already includes GPU support for:
- ComfyUI
- Stable Diffusion WebUI

Verify GPU access:
```bash
docker exec -it comfyui nvidia-smi
```

### Backup Strategy

1. **Automated PostgreSQL backups:**
   - Configured via postgres-backup service
   - Daily backups kept for 7 days
   - Weekly backups kept for 4 weeks
   - Monthly backups kept for 6 months

2. **Manual volume backup:**
   ```bash
   ./homelab.sh backup
   ```

3. **Duplicati for selective backups:**
   - Configure via http://localhost:8200
   - Set up encrypted backups to cloud storage

### Resource Limits

The stack is optimized for:
- **CPU:** Ryzen 7 5800X (8C/16T)
- **RAM:** 32GB recommended minimum
- **GPU:** RTX 3060 12GB
- **Storage:** SSD recommended for volumes

Monitor resources:
```bash
./homelab.sh stats
```

### Network Configuration

**Static IPs assigned (172.20.0.0/16):**
- Prevents IP conflicts
- Consistent service discovery
- Easy firewall rules

**Exposed ports:**
- Only necessary ports are exposed
- Use Nginx Proxy Manager for external access
- Consider setting up VPN (WireGuard) for secure remote access

## 🔐 Security Best Practices

1. **Change all default passwords in .env**
2. **Use strong, unique passwords (use ./homelab.sh keys)**
3. **Enable Authelia for SSO**
4. **Configure CrowdSec for IPS**
5. **Set up SSL certificates via Nginx Proxy Manager**
6. **Restrict Docker socket access**
7. **Regular backups**
8. **Keep containers updated**
9. **Use firewall rules (UFW/firewalld)**
10. **Monitor with Uptime Kuma and Grafana**

## 📝 Maintenance

### Regular Tasks

**Daily (automated):**
- Watchtower checks for updates
- PostgreSQL backups
- Container health checks

**Weekly:**
```bash
./homelab.sh update    # Update all containers
./homelab.sh cleanup   # Clean up unused resources
```

**Monthly:**
```bash
./homelab.sh backup    # Full backup
docker system df       # Check disk usage
```

### Troubleshooting

**Container won't start:**
```bash
./homelab.sh logs [service-name]
docker compose ps -a
```

**Database connection issues:**
```bash
docker compose restart postgres redis mariadb
```

**GPU not detected:**
```bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

**Port conflicts:**
```bash
sudo netstat -tlnp | grep [port-number]
```

**Reset service data:**
```bash
docker compose down
docker volume rm [volume-name]
docker compose up -d
```

## 🔄 Updating

### Update all services:
```bash
./homelab.sh update
```

### Update specific service:
```bash
docker compose pull [service-name]
docker compose up -d [service-name]
```

## 📊 Monitoring Setup

### Grafana Dashboards

Import these dashboard IDs in Grafana:

1. **Docker monitoring:**
   - Dashboard ID: 10619 (Docker Container & Host Metrics)
   - Dashboard ID: 893 (Docker monitoring)

2. **System metrics:**
   - Dashboard ID: 1860 (Node Exporter Full)
   - Dashboard ID: 11074 (Node Exporter)

3. **PostgreSQL:**
   - Dashboard ID: 9628 (PostgreSQL Database)

4. **Redis:**
   - Dashboard ID: 11835 (Redis Dashboard)

### Uptime Kuma Monitors

Add HTTP(s) monitors for all services:
- Set check interval to 60 seconds
- Configure notifications (Discord, Telegram, email)
- Set up heartbeat for critical services

## 🐛 Known Issues

1. **First start may be slow** - Containers need to pull images and initialize
2. **GPU containers require nvidia-container-toolkit** - Already installed via install.sh
3. **Some services need manual configuration** - Follow initial configuration steps
4. **Volume permissions** - Run with proper user permissions (PUID/PGID 1000)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is provided as-is for personal use.

## 🙏 Credits

- CachyOS Team
- Hyprland Community
- Caelestia Project
- All the amazing open-source projects included

## 📞 Support

For issues related to:
- **Docker Compose setup:** Check this README
- **Individual services:** Refer to their official documentation
- **CachyOS/Hyprland:** Visit their respective communities

## 🔗 Useful Links

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Proxy Manager](https://nginxproxymanager.com/)
- [Portainer](https://www.portainer.io/)
- [Grafana](https://grafana.com/)
- [n8n](https://n8n.io/)
- [Paperless-ngx](https://docs.paperless-ngx.com/)

---

**Last Updated:** December 2025
**Compatible with:** CachyOS + Hyprland + Caelestia
**Hardware:** ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB