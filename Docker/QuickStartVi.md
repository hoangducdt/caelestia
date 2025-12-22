# 🚀 HƯỚNG DẪN NHANH - HOMELAB STACK

## Cài đặt nhanh trong 5 phút

### 1️⃣ Chuẩn bị
```bash
# Tạo thư mục homelab
mkdir -p ~/homelab
cd ~/homelab

# Copy tất cả files vào đây:
# - docker-compose.yml
# - .env.example
# - homelab.sh
# - README.md
# Và thư mục: prometheus/
```

### 2️⃣ Cấu hình
```bash
# Copy file .env mẫu
cp .env.example .env

# Tạo các khóa bảo mật
chmod +x homelab.sh
./homelab.sh keys

# Chỉnh sửa file .env với các khóa vừa tạo
nano .env  # hoặc code .env
```

**Cần thay đổi những gì trong .env:**
- ✅ `POSTGRES_PASSWORD` - Mật khẩu PostgreSQL
- ✅ `REDIS_PASSWORD` - Mật khẩu Redis  
- ✅ `MYSQL_ROOT_PASSWORD` - Mật khẩu MariaDB
- ✅ `N8N_BASIC_AUTH_PASSWORD` - Mật khẩu n8n
- ✅ `PAPERLESS_SECRET_KEY` - Khóa bí mật Paperless
- ✅ `PAPERLESS_ADMIN_PASSWORD` - Mật khẩu admin Paperless
- ⚠️ Các khóa còn lại dùng lệnh `openssl rand -base64 32` hoặc `openssl rand -base64 64`

### 3️⃣ Khởi động
```bash
# Khởi động tất cả services
./homelab.sh start

# Đợi 2-3 phút để các container khởi động hoàn toàn
# Kiểm tra trạng thái
./homelab.sh status
```

### 4️⃣ Truy cập
```bash
# Xem danh sách tất cả URLs
./homelab.sh urls
```

## 🎯 Cấu hình ban đầu

### Nginx Proxy Manager (Reverse Proxy)
1. Truy cập: http://localhost:81
2. Đăng nhập: `admin@example.com` / `changeme`
3. ⚠️ **ĐỔI MẬT KHẨU NGAY**
4. Thêm proxy hosts cho các service khác
5. Cấu hình SSL (Let's Encrypt)

### Portainer (Quản lý Docker)
1. Truy cập: http://localhost:9000
2. Tạo tài khoản admin
3. Kết nối local Docker environment

### Grafana (Giám sát)
1. Truy cập: http://localhost:3000
2. Đăng nhập: `admin` / `admin`
3. Thêm Prometheus data source:
   - URL: `http://prometheus:9090`
4. Import dashboard: 10619, 1860, 2701

### Homarr (Dashboard trang chủ)
1. Truy cập: http://localhost:7575
2. Thêm các tile cho services
3. Tùy chỉnh layout theo ý bạn

### Open WebUI (Chat với AI)
```bash
# Cài Ollama trên máy chủ
curl -fsSL https://ollama.com/install.sh | sh

# Tải model
ollama pull llama3.2

# Truy cập: http://localhost:3030
# Đăng ký tài khoản và bắt đầu chat
```

## 📋 Các lệnh thường dùng

```bash
# Xem trạng thái
./homelab.sh status

# Xem logs
./homelab.sh logs                    # Tất cả
./homelab.sh logs nginx-proxy-manager # Một service

# Khởi động lại
./homelab.sh restart                 # Tất cả
./homelab.sh restart grafana         # Một service

# Cập nhật
./homelab.sh update

# Backup
./homelab.sh backup

# Thống kê tài nguyên
./homelab.sh stats

# Dọn dẹp
./homelab.sh cleanup
```

## 🔥 Services quan trọng nhất

| Service | URL | Mô tả |
|---------|-----|-------|
| 🌐 Nginx Proxy Manager | :81 | Quản lý reverse proxy & SSL |
| 🐳 Portainer | :9000 | Quản lý container |
| 📊 Grafana | :3000 | Dashboard monitoring |
| 🏠 Homarr | :7575 | Trang chủ dashboard |
| 📝 Dozzle | :8888 | Xem logs real-time |
| ⏰ Uptime Kuma | :3001 | Giám sát uptime |
| 🤖 n8n | :5678 | Tự động hóa workflow |
| 💬 Open WebUI | :3030 | Chat với AI |
| 🎨 ComfyUI | :8188 | Tạo hình ảnh AI |
| 📄 Paperless-ngx | :8010 | Quản lý tài liệu |

## ⚠️ Lưu ý quan trọng

### Hiệu năng
- **RAM tối thiểu:** 16GB (khuyến nghị 32GB)
- **CPU:** Ryzen 7 5800X (8C/16T) - đã tối ưu
- **GPU:** RTX 3060 12GB - cho AI services
- **Ổ cứng:** SSD khuyến nghị, cần ít nhất 100GB trống

### Bảo mật
1. ✅ Đổi TẤT CẢ mật khẩu mặc định
2. ✅ Sử dụng khóa mạnh (dùng `./homelab.sh keys`)
3. ✅ Cấu hình SSL qua Nginx Proxy Manager
4. ✅ Bật Authelia cho SSO
5. ✅ Cấu hình firewall (UFW)

### Backup
```bash
# Backup thủ công
./homelab.sh backup

# PostgreSQL tự động backup hàng ngày
# Kiểm tra trong volume postgres_backup_data

# Cấu hình Duplicati cho backup lên cloud
# Truy cập: http://localhost:8200
```

## 🐛 Xử lý sự cố

### Container không khởi động
```bash
# Xem logs
./homelab.sh logs [tên-service]

# Xem trạng thái
docker compose ps -a

# Khởi động lại
./homelab.sh restart [tên-service]
```

### Lỗi kết nối database
```bash
# Khởi động lại databases
docker compose restart postgres redis mariadb

# Đợi 30 giây rồi khởi động lại service khác
./homelab.sh restart [tên-service]
```

### GPU không hoạt động
```bash
# Kiểm tra GPU
nvidia-smi

# Kiểm tra trong container
docker exec -it comfyui nvidia-smi

# Nếu không có, cài lại nvidia-container-toolkit
sudo pacman -S nvidia-container-toolkit
sudo systemctl restart docker
```

### Port bị xung đột
```bash
# Kiểm tra port đang dùng
sudo netstat -tlnp | grep [số-port]

# Đổi port trong docker-compose.yml nếu cần
```

## 📞 Hỗ trợ

### Xem logs chi tiết
```bash
./homelab.sh logs [service-name]
```

### Xem tài nguyên đang dùng
```bash
./homelab.sh stats
```

### Kiểm tra kết nối mạng
```bash
docker network ls
docker network inspect homelab_homelab
```

## 🔄 Cập nhật thường xuyên

```bash
# Cập nhật hàng tuần
./homelab.sh update

# Dọn dẹp hàng tuần
./homelab.sh cleanup

# Backup hàng tháng
./homelab.sh backup
```

## 💡 Tips & Tricks

### 1. Monitoring toàn diện
- Dùng Grafana để xem metrics
- Dùng Uptime Kuma để nhận thông báo
- Dùng Dozzle để xem logs real-time

### 2. Tối ưu hiệu năng
```bash
# Xem container nào dùng nhiều tài nguyên nhất
./homelab.sh stats

# Giới hạn tài nguyên trong docker-compose.yml nếu cần
```

### 3. Tự động hóa với n8n
- Backup tự động
- Thông báo khi service down
- Tích hợp với Discord/Telegram
- Tự động cập nhật

### 4. Dashboard đẹp với Homarr
- Thêm tất cả services
- Tùy chỉnh icons
- Sắp xếp theo category
- Thêm widgets hữu ích

### 5. AI & ML
```bash
# Ollama models phổ biến
ollama pull llama3.2        # Chat
ollama pull codellama       # Code
ollama pull mistral         # Đa năng
ollama pull llava           # Vision

# Stable Diffusion models
# Tải qua ComfyUI Manager
```

## ✨ Tính năng nổi bật

- ✅ **35 services** trong 1 stack
- ✅ **GPU support** cho AI/ML
- ✅ **Auto-update** với Watchtower
- ✅ **Auto-healing** với Autoheal
- ✅ **Monitoring** đầy đủ
- ✅ **Backup** tự động
- ✅ **SSL** dễ dàng với NPM
- ✅ **Tối ưu** cho CachyOS + RTX 3060

---

**Tác giả:** Based on CachyOS + Hyprland + Caelestia Setup
**Hardware:** ROG STRIX B550-XE | Ryzen 7 5800X | RTX 3060 12GB
**Cập nhật:** December 2025