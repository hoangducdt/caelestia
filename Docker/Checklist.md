# ✅ CHECKLIST CÀI ĐẶT HOMELAB

## 📦 Các file đã cung cấp

✅ **docker-compose.yml** - File cấu hình chính (35 services)
✅ **.env.example** - Mẫu biến môi trường
✅ **homelab.sh** - Script quản lý (đã chmod +x)
✅ **README.md** - Hướng dẫn đầy đủ (English)
✅ **QUICK_START_VI.md** - Hướng dẫn nhanh (Tiếng Việt)
✅ **DIRECTORY_STRUCTURE.md** - Cấu trúc thư mục & volumes
✅ **.gitignore** - Git ignore file
✅ **prometheus/** - Thư mục cấu hình Prometheus
  └── **prometheus.yml** - File config Prometheus

## 🚀 Các bước cài đặt

### Bước 1: Chuẩn bị môi trường
- [x] CachyOS + Hyprland đã cài
- [x] Docker & Docker Compose đã cài (qua install.sh)
- [x] NVIDIA Container Toolkit đã cài (qua install.sh)
- [ ] Kiểm tra GPU: `nvidia-smi`
- [ ] Kiểm tra Docker: `docker info`
- [ ] Có ít nhất 100GB dung lượng trống

### Bước 2: Setup thư mục
```bash
# Tạo thư mục homelab
mkdir -p ~/homelab
cd ~/homelab

# Copy tất cả files vào đây
# Hoặc clone từ repository nếu có
```

### Bước 3: Cấu hình
```bash
# Copy .env.example thành .env
cp .env.example .env

# Tạo các khóa bảo mật
chmod +x homelab.sh
./homelab.sh keys

# Chỉnh sửa .env với khóa vừa tạo
nano .env  # hoặc editor khác
```

### Bước 4: Khởi động
```bash
# Khởi động tất cả
./homelab.sh start

# Đợi 2-3 phút
# Kiểm tra trạng thái
./homelab.sh status
```

## 🔧 Cấu hình bắt buộc trong .env

Đánh dấu khi đã cấu hình:

### Core Services
- [ ] `POSTGRES_PASSWORD` - Mật khẩu PostgreSQL
- [ ] `REDIS_PASSWORD` - Mật khẩu Redis
- [ ] `MYSQL_ROOT_PASSWORD` - Mật khẩu MariaDB root
- [ ] `MYSQL_PASSWORD` - Mật khẩu MariaDB user

### Applications
- [ ] `N8N_BASIC_AUTH_PASSWORD` - Mật khẩu n8n
- [ ] `PAPERLESS_SECRET_KEY` - Khóa bí mật Paperless
- [ ] `PAPERLESS_ADMIN_PASSWORD` - Mật khẩu admin Paperless
- [ ] `PAPERLESS_ADMIN_MAIL` - Email admin Paperless

### Security (tạo bằng openssl)
- [ ] `AUTHELIA_JWT_SECRET` - 64 chars
- [ ] `AUTHELIA_SESSION_SECRET` - 64 chars
- [ ] `AUTHELIA_STORAGE_ENCRYPTION_KEY` - 64 chars
- [ ] `OPEN_WEBUI_SECRET_KEY` - 32 chars

### Optional (nếu dùng)
- [ ] `CF_API_KEY` - Cloudflare API key
- [ ] `CF_ZONE` - Domain của bạn
- [ ] `OPENAI_API_KEY` - OpenAI API key
- [ ] `WATCHTOWER_NOTIFICATION_URL` - Notification URL

## 🎯 Cấu hình ban đầu từng service

### 1. Nginx Proxy Manager (:81)
- [ ] Truy cập http://localhost:81
- [ ] Login: admin@example.com / changeme
- [ ] Đổi mật khẩu admin
- [ ] Thêm proxy hosts
- [ ] Cấu hình SSL

### 2. Portainer (:9000)
- [ ] Truy cập http://localhost:9000
- [ ] Tạo admin account
- [ ] Connect local environment

### 3. Grafana (:3000)
- [ ] Truy cập http://localhost:3000
- [ ] Login: admin / admin
- [ ] Đổi mật khẩu
- [ ] Add Prometheus: http://prometheus:9090
- [ ] Import dashboards: 10619, 1860, 2701

### 4. Uptime Kuma (:3001)
- [ ] Truy cập http://localhost:3001
- [ ] Tạo admin account
- [ ] Add monitors cho services

### 5. n8n (:5678)
- [ ] Truy cập http://localhost:5678
- [ ] Login với credentials từ .env
- [ ] Test connection với databases

### 6. Open WebUI (:3030)
- [ ] Cài Ollama: `curl -fsSL https://ollama.com/install.sh | sh`
- [ ] Pull model: `ollama pull llama3.2`
- [ ] Truy cập http://localhost:3030
- [ ] Register account

### 7. Homarr (:7575)
- [ ] Truy cập http://localhost:7575
- [ ] Add tiles cho services
- [ ] Customize layout

### 8. File Browser (:8081)
- [ ] Truy cập http://localhost:8081
- [ ] Login: admin / admin
- [ ] Đổi mật khẩu
- [ ] Configure root directory

### 9. Paperless-ngx (:8010)
- [ ] Truy cập http://localhost:8010
- [ ] Login với credentials từ .env
- [ ] Configure consumption folder
- [ ] Setup document types

### 10. Duplicati (:8200)
- [ ] Truy cập http://localhost:8200
- [ ] Configure backup jobs
- [ ] Setup cloud storage
- [ ] Test backup/restore

## 🔍 Kiểm tra sau khi cài

### Container Status
```bash
./homelab.sh status
# Tất cả containers phải có trạng thái "Up"
```

### Logs Check
```bash
./homelab.sh logs | grep -i error
# Không có lỗi nghiêm trọng
```

### Resource Usage
```bash
./homelab.sh stats
# CPU < 80%, Memory < 80%
```

### Network Check
```bash
docker network ls | grep homelab
# Network homelab_homelab tồn tại
```

### Volume Check
```bash
docker volume ls | grep homelab
# Tất cả volumes được tạo
```

### GPU Check (cho AI services)
```bash
docker exec -it comfyui nvidia-smi
# GPU được detect
```

## 🔐 Security Checklist

- [ ] Tất cả mật khẩu mặc định đã đổi
- [ ] .env file có permissions 600
- [ ] SSL certificates đã setup (NPM)
- [ ] Authelia đã cấu hình (nếu dùng)
- [ ] CrowdSec đã chạy
- [ ] Firewall đã cấu hình (UFW/firewalld)
- [ ] Backup strategy đã setup
- [ ] Monitoring đã setup (Uptime Kuma)

## 📊 Monitoring Setup

- [ ] Grafana dashboards imported
- [ ] Prometheus targets healthy
- [ ] Netdata connected (nếu dùng cloud)
- [ ] Uptime Kuma monitors added
- [ ] Dozzle accessible
- [ ] Alerts configured

## 💾 Backup Setup

- [ ] PostgreSQL auto-backup working
- [ ] Duplicati configured
- [ ] Manual backup tested: `./homelab.sh backup`
- [ ] Backup restore tested
- [ ] Backup schedule configured

## 🌐 Network Setup

- [ ] Static IP configured (192.168.1.2)
- [ ] DNS working (Cloudflare)
- [ ] DDNS working (nếu dùng)
- [ ] Port forwarding (nếu cần)
- [ ] VPN setup (khuyến nghị)

## 📝 Documentation

- [ ] README.md đã đọc
- [ ] QUICK_START_VI.md đã đọc
- [ ] DIRECTORY_STRUCTURE.md đã đọc
- [ ] Service URLs noted
- [ ] Admin credentials saved (securely)

## 🚨 Troubleshooting Ready

Đã biết cách:
- [ ] Xem logs: `./homelab.sh logs [service]`
- [ ] Restart service: `./homelab.sh restart [service]`
- [ ] Check resource: `./homelab.sh stats`
- [ ] Backup: `./homelab.sh backup`
- [ ] Update: `./homelab.sh update`
- [ ] Cleanup: `./homelab.sh cleanup`

## 🎓 Next Steps

Sau khi setup xong:

1. **Tuần 1: Làm quen**
   - Explore tất cả services
   - Test basic functions
   - Configure theo nhu cầu

2. **Tuần 2: Tự động hóa**
   - Setup n8n workflows
   - Configure notifications
   - Automate backups

3. **Tuần 3: Tối ưu**
   - Monitor performance
   - Adjust resources
   - Fine-tune configurations

4. **Tuần 4: Bảo mật**
   - Review security
   - Setup Authelia
   - Enable 2FA where possible

## 📈 Metrics to Track

- [ ] Container uptime (Uptime Kuma)
- [ ] Resource usage (Grafana)
- [ ] Backup success rate (Duplicati)
- [ ] Update frequency (Watchtower)
- [ ] Error rates (Logs via Dozzle)
- [ ] Disk usage (Netdata)

## 🎉 Success Criteria

Homelab được coi là thành công khi:

✅ Tất cả services chạy stable > 24h
✅ Không có errors trong logs
✅ Monitoring hoạt động
✅ Backups tự động
✅ SSL certificates valid
✅ GPU services working
✅ Có thể access từ mọi thiết bị trong network
✅ Notifications working
✅ Resource usage < 70%

## 📞 Support Resources

- **Docker:** https://docs.docker.com/
- **Compose:** https://docs.docker.com/compose/
- **Services:** Check each service's official docs
- **Community:** CachyOS, Hyprland forums
- **AI:** Open WebUI, ComfyUI communities

## 🔄 Maintenance Schedule

### Hàng ngày
- Kiểm tra Uptime Kuma
- Review Grafana dashboards
- Check Dozzle logs

### Hàng tuần
```bash
./homelab.sh update
./homelab.sh cleanup
```

### Hàng tháng
```bash
./homelab.sh backup
# Review disk usage
# Review security logs
```

### Hàng quý
- Full backup test
- Security audit
- Performance review
- Update documentation

---

**Chúc mừng bạn đã setup thành công Homelab Stack!** 🎊

Nếu gặp vấn đề, check:
1. Logs: `./homelab.sh logs [service]`
2. Status: `./homelab.sh status`
3. Resources: `./homelab.sh stats`
4. Documentation trong README.md

**Hardware specs:** ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB
**OS:** CachyOS + Hyprland + Caelestia
**Updated:** December 2025