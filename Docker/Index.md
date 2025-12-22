# 📚 HOMELAB DOCKER COMPOSE - INDEX

## 🎯 Tổng quan

**Complete Homelab Stack cho CachyOS + Hyprland + RTX 3060 12GB**

- **35 Services** tích hợp hoàn chỉnh
- **GPU Support** cho AI/ML workloads  
- **Auto-update** & Auto-healing
- **Complete monitoring** & backup solution
- **Tối ưu** cho ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB

---

## 📁 Danh sách Files

### 🔧 Core Files

#### **docker-compose.yml** (21KB)
- File cấu hình chính cho tất cả 35 services
- Network: bridge network với subnet 172.20.0.0/16
- Volumes: 40+ named volumes
- Health checks cho critical services
- GPU support cho AI containers

#### **.env.example** (4.3KB)
- Template cho biến môi trường
- Hướng dẫn tạo secure keys
- IP address plan
- Port mapping reference
- Cần copy thành `.env` và điền values

#### **homelab.sh** (9KB) - Executable
- Script quản lý toàn bộ stack
- Commands: start, stop, restart, logs, status, update, backup, stats, urls, cleanup, keys
- Color-coded output
- Error handling
- Automatic dependency management

#### **.gitignore** (496 bytes)
- Git ignore rules
- Bảo vệ .env và sensitive files
- Ignore backup và log files

---

### 📖 Documentation Files

#### **README.md** (11KB) - English
Hướng dẫn đầy đủ bao gồm:
- Complete service list với mô tả
- Prerequisites & installation steps
- Usage & management
- Initial configuration cho từng service
- Advanced configuration
- Security best practices
- Troubleshooting guide
- Update procedures
- Monitoring setup
- Backup strategy
- Useful links

#### **QUICK_START_VI.md** (6.8KB) - Tiếng Việt
Hướng dẫn nhanh bao gồm:
- Cài đặt trong 5 phút
- Cấu hình ban đầu
- Các lệnh thường dùng
- Services quan trọng nhất
- Lưu ý về hiệu năng & bảo mật
- Xử lý sự cố phổ biến
- Tips & tricks
- Tính năng nổi bật

#### **DIRECTORY_STRUCTURE.md** (6.3KB)
Hướng dẫn chi tiết về:
- Cấu trúc thư mục đề xuất
- Docker volumes layout
- Vị trí lưu trữ data
- Backup & restore volumes
- Quản lý dung lượng
- Storage monitoring
- Mount configurations
- Kế hoạch storage

#### **CHECKLIST.md** (8.1KB)
Danh sách kiểm tra đầy đủ:
- Files provided
- Các bước cài đặt
- Cấu hình bắt buộc trong .env
- Cấu hình ban đầu từng service
- Security checklist
- Monitoring setup
- Backup setup
- Network setup
- Troubleshooting checklist
- Success criteria
- Maintenance schedule

#### **INDEX.md** (File này) (3.5KB)
- Tổng quan toàn bộ stack
- Danh sách files và mô tả
- Service categories
- Quick reference
- Getting started guide

---

### ⚙️ Configuration Files

#### **prometheus/** (Directory)
Chứa file cấu hình Prometheus:

##### **prometheus/prometheus.yml** (1.7KB)
- Global scrape config (15s interval)
- Scrape configs cho tất cả services:
  - Prometheus, Grafana
  - Node Exporter, cAdvisor
  - Netdata
  - Nginx Proxy Manager
  - PostgreSQL, Redis
  - Docker daemon
- Alert manager config (placeholder)

---

## 🎨 Services Categories

### 🌐 Reverse Proxy & Networking (2)
- Nginx Proxy Manager (:81, :80, :443)
- Cloudflare DDNS

### 🛠️ Management & Monitoring (5)
- Portainer (:9000, :9443)
- Watchtower
- Autoheal
- DIUN
- Dozzle (:8888)

### 📊 Observability (4)
- Grafana (:3000)
- Prometheus (:9090)
- Netdata (:19999)
- Uptime Kuma (:3001)

### 🔒 Security (2)
- CrowdSec (:8080, :6060)
- Authelia (:9091)

### 🗄️ Databases (3)
- PostgreSQL (:5432)
- MariaDB (:3306)
- Redis (:6379)

### 🤖 Automation (1)
- n8n (:5678)

### 🧰 Utilities (7)
- IT-Tools (:8282)
- Homarr (:7575)
- File Browser (:8081)
- Snippet Box (:5000)
- Change Detection (:5050)
- Playwright Chrome (:3003)
- Wetty (:3002)

### 🤖 AI & ML (3) - GPU Accelerated
- Open WebUI (:3030)
- ComfyUI (:8188)
- Stable Diffusion WebUI (:7860)

### 💾 Backup & Sync (4)
- PostgreSQL Backup
- Duplicati (:8200)
- Syncthing (:8384, :22000, :21027)

### 📄 Document Management (1)
- Paperless-ngx (:8010)

**Total: 35 Services**

---

## 🚀 Quick Start

### 1. Setup Directory
```bash
mkdir -p ~/homelab
cd ~/homelab
# Copy all files here
```

### 2. Configure Environment
```bash
cp .env.example .env
chmod +x homelab.sh
./homelab.sh keys  # Generate secure keys
nano .env          # Fill in the values
```

### 3. Create Prometheus Config
```bash
# prometheus directory already included
# Just verify prometheus.yml exists
ls prometheus/prometheus.yml
```

### 4. Start Everything
```bash
./homelab.sh start
```

### 5. Access Services
```bash
./homelab.sh urls  # Show all URLs
```

---

## 📊 System Requirements

### Minimum
- **CPU:** 4 cores / 8 threads
- **RAM:** 16GB
- **Storage:** 100GB SSD
- **GPU:** Optional (for AI services)

### Recommended (Target System)
- **CPU:** Ryzen 7 5800X (8C/16T)
- **RAM:** 32GB DDR4
- **Storage:** 500GB NVMe SSD
- **GPU:** RTX 3060 12GB
- **Motherboard:** ROG STRIX B550-XE GAMING WIFI
- **OS:** CachyOS + Hyprland + Caelestia

---

## 🎯 Key Features

✅ **Complete Integration** - 35 services working together seamlessly
✅ **GPU Acceleration** - NVIDIA Container Toolkit for AI/ML
✅ **Automatic Updates** - Watchtower keeps everything current
✅ **Self-Healing** - Autoheal restarts failed containers
✅ **Monitoring** - Grafana + Prometheus + Netdata + Uptime Kuma
✅ **Security** - CrowdSec + Authelia + SSL via NPM
✅ **Backup** - Automated PostgreSQL backups + Duplicati
✅ **Logs** - Dozzle for real-time log viewing
✅ **Dashboards** - Homarr for beautiful homepage
✅ **Automation** - n8n for workflows
✅ **Document Management** - Paperless-ngx
✅ **File Sync** - Syncthing
✅ **AI Capabilities** - Open WebUI + ComfyUI + Stable Diffusion

---

## 🔧 Management Commands

```bash
./homelab.sh start          # Start all services
./homelab.sh stop           # Stop all services
./homelab.sh restart [name] # Restart service(s)
./homelab.sh status         # Show service status
./homelab.sh logs [name]    # Show logs
./homelab.sh update         # Update all services
./homelab.sh backup         # Backup all volumes
./homelab.sh stats          # Show resource usage
./homelab.sh urls           # Show all service URLs
./homelab.sh cleanup        # Clean up Docker
./homelab.sh keys           # Generate secure keys
./homelab.sh help           # Show help
```

---

## 📝 Documentation Reading Order

### For First Time Setup:
1. **QUICK_START_VI.md** (nếu đọc tiếng Việt) hoặc **README.md** (English)
2. **CHECKLIST.md** - Follow step by step
3. **.env.example** - Understand required variables
4. **DIRECTORY_STRUCTURE.md** - Understand storage layout

### For Daily Operations:
1. **homelab.sh help** - Quick command reference
2. **Dozzle** (:8888) - Real-time logs
3. **Grafana** (:3000) - Monitoring dashboards
4. **Homarr** (:7575) - Service access

### For Troubleshooting:
1. **README.md** - Troubleshooting section
2. **QUICK_START_VI.md** - Xử lý sự cố section
3. **./homelab.sh logs [service]** - Check specific logs

### For Advanced Configuration:
1. **README.md** - Advanced Configuration section
2. **DIRECTORY_STRUCTURE.md** - Storage management
3. **docker-compose.yml** - Modify service configs

---

## 🔐 Security Notes

⚠️ **CRITICAL:**
1. Change ALL default passwords in .env
2. Use strong keys (generate with ./homelab.sh keys)
3. Never commit .env to version control
4. Enable SSL via Nginx Proxy Manager
5. Configure firewall (UFW/firewalld)
6. Regular backups (./homelab.sh backup)
7. Monitor with Uptime Kuma
8. Review CrowdSec logs regularly

---

## 💡 Pro Tips

1. **Access everything through Homarr** (:7575) - Beautiful dashboard
2. **Monitor with Grafana** (:3000) - Import dashboards 10619, 1860, 2701
3. **Check logs with Dozzle** (:8888) - Real-time, easy filtering
4. **Automate with n8n** (:5678) - Workflows for everything
5. **Use Nginx Proxy Manager** for clean URLs and SSL
6. **Enable Authelia** for SSO across services
7. **Regular backups** - Weekly with ./homelab.sh backup
8. **Update regularly** - ./homelab.sh update every week

---

## 📞 Support & Resources

### Documentation
- All docs included in this package
- Service-specific docs: Check official websites

### Community
- Docker: https://docs.docker.com/
- CachyOS: https://cachyos.org/
- Hyprland: https://hyprland.org/

### Tools
- homelab.sh - Primary management tool
- Portainer - Visual management
- Dozzle - Log viewing
- Grafana - Monitoring

---

## ✅ Success Indicators

Your homelab is successful when:
- ✅ All 35 services show "Up" status
- ✅ No errors in logs
- ✅ Grafana dashboards showing data
- ✅ Uptime Kuma monitors all green
- ✅ Backups running automatically
- ✅ GPU detected in AI containers
- ✅ SSL certificates working
- ✅ Resource usage < 70%

---

## 🎉 Next Steps

After successful setup:

**Week 1:** Explore & Configure
- Access each service
- Configure basic settings
- Import Grafana dashboards
- Setup Homarr homepage

**Week 2:** Automate
- Create n8n workflows
- Setup notifications
- Configure backup schedules
- Add Uptime Kuma monitors

**Week 3:** Optimize
- Review resource usage
- Adjust container limits
- Fine-tune configurations
- Add custom dashboards

**Week 4:** Secure & Scale
- Enable Authelia
- Configure CrowdSec
- Setup VPN access
- Plan future additions

---

**Version:** 1.0
**Updated:** December 2025
**Compatible:** CachyOS + Hyprland + Caelestia
**Hardware:** ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB

**Created with ❤️ for the Homelab Community**