# 📁 CẤU TRÚC THỨ MỤC HOMELAB

## Cấu trúc đề xuất

```
~/homelab/
├── docker-compose.yml          # File cấu hình chính
├── .env                        # Biến môi trường (TẠO TỪ .env.example)
├── .env.example               # Mẫu biến môi trường
├── .gitignore                 # Git ignore file
├── homelab.sh                 # Script quản lý (chmod +x)
├── README.md                  # Hướng dẫn đầy đủ (English)
├── QUICK_START_VI.md          # Hướng dẫn nhanh (Tiếng Việt)
├── DIRECTORY_STRUCTURE.md     # File này
│
├── prometheus/                # Cấu hình Prometheus
│   └── prometheus.yml         # File config Prometheus
│
├── backups/                   # Thư mục backup (tự động tạo)
│   └── YYYYMMDD_HHMMSS/      # Backup theo thời gian
│
└── logs/                      # Logs (optional)
    └── *.log
```

## Docker Volumes

Tất cả data được lưu trong Docker volumes:

### Core Services
- `npm_data` - Nginx Proxy Manager data
- `npm_ssl` - SSL certificates
- `portainer_data` - Portainer data

### Databases
- `postgres_data` - PostgreSQL database
- `postgres_backup_data` - PostgreSQL backups
- `mariadb_data` - MariaDB database
- `redis_data` - Redis data

### Monitoring
- `grafana_data` - Grafana dashboards & configs
- `prometheus_data` - Prometheus metrics
- `netdata_config` - Netdata configuration
- `netdata_cache` - Netdata cache
- `uptime-kuma_data` - Uptime Kuma data

### Security
- `crowdsec_config` - CrowdSec configuration
- `crowdsec_data` - CrowdSec data
- `authelia_data` - Authelia configuration

### Applications
- `n8n_data` - n8n workflows
- `homarr_config` - Homarr configuration
- `homarr_icons` - Homarr icons
- `homarr_data` - Homarr data
- `filebrowser_data` - File Browser data
- `snippet-box_data` - Snippet Box data
- `changedetection_data` - Change Detection data
- `open-webui_data` - Open WebUI data
- `paperless_data` - Paperless-ngx data
- `paperless_media` - Paperless-ngx media
- `paperless_export` - Paperless-ngx exports
- `paperless_consume` - Paperless-ngx inbox

### AI/ML (GPU)
- `comfyui_data` - ComfyUI models & outputs
- `sd-webui_data` - Stable Diffusion WebUI

### Backup & Sync
- `duplicati_config` - Duplicati configuration
- `duplicati_data` - Duplicati backups
- `syncthing_data` - Syncthing data

### Utilities
- `dozzle_data` - Dozzle configuration
- `wetty_data` - Wetty home directory
- `it-tools_data` - IT-Tools data

## Vị trí Docker Volumes

Xem vị trí thực tế của volumes:
```bash
docker volume ls
docker volume inspect [volume_name]
```

Thông thường volumes được lưu tại:
```
/var/lib/docker/volumes/[project]_[volume_name]/_data/
```

Ví dụ:
```
/var/lib/docker/volumes/homelab_postgres_data/_data/
/var/lib/docker/volumes/homelab_grafana_data/_data/
```

## Backup Volumes

### Phương pháp 1: Dùng script có sẵn
```bash
./homelab.sh backup
```

Backup sẽ được lưu tại: `./backups/YYYYMMDD_HHMMSS/`

### Phương pháp 2: Backup thủ công một volume
```bash
# Tạo thư mục backup
mkdir -p ~/backups/volumes

# Backup volume cụ thể
docker run --rm \
  -v homelab_postgres_data:/data \
  -v ~/backups/volumes:/backup \
  alpine \
  tar czf /backup/postgres_data_$(date +%Y%m%d).tar.gz -C /data .
```

### Phương pháp 3: Dùng Duplicati
1. Truy cập: http://localhost:8200
2. Cấu hình backup tự động
3. Chọn volumes cần backup
4. Thiết lập lịch backup
5. Chọn đích (local, cloud storage, etc.)

## Restore Volumes

### Từ backup script
```bash
# Stop services
./homelab.sh stop

# Extract backup
cd backups/YYYYMMDD_HHMMSS/
docker run --rm \
  -v homelab_postgres_data:/data \
  -v $(pwd):/backup \
  alpine \
  tar xzf /backup/homelab_postgres_data.tar.gz -C /data

# Start services
./homelab.sh start
```

## Quản lý dung lượng

### Kiểm tra dung lượng
```bash
# Tổng dung lượng Docker
docker system df

# Chi tiết từng volume
docker system df -v

# Dung lượng volumes
du -sh /var/lib/docker/volumes/homelab_*
```

### Dọn dẹp
```bash
# Dọn dẹp an toàn (containers stopped, images unused)
./homelab.sh cleanup

# Dọn dẹp sâu (CẢNH BÁO: Xóa tất cả unused)
docker system prune -a --volumes
```

## Cấu hình nâng cao

### Mount thư mục host vào container

Ví dụ: Mount thư mục download vào File Browser
```yaml
filebrowser:
  volumes:
    - filebrowser_data:/database
    - /home/user/Downloads:/srv/downloads    # Thêm dòng này
    - /mnt/storage:/srv/storage              # Hoặc ổ đĩa khác
```

### Sử dụng external volumes

Nếu muốn dùng volume đã tồn tại:
```yaml
volumes:
  postgres_data:
    external: true
    name: my_existing_postgres_volume
```

## Tips quan trọng

1. **LUÔN backup trước khi update**
   ```bash
   ./homelab.sh backup
   ./homelab.sh update
   ```

2. **Giám sát dung lượng thường xuyên**
   ```bash
   # Thêm vào crontab
   0 0 * * 0 docker system df -v > ~/docker-size-report.txt
   ```

3. **Sử dụng bind mounts cho data quan trọng**
   - Dễ backup
   - Dễ truy cập
   - Dễ migrate

4. **Named volumes cho ứng dụng**
   - Quản lý tốt hơn
   - Docker tự động quản lý
   - Dễ scale

5. **Logs rotation**
   ```bash
   # Thêm vào docker daemon.json
   {
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "10m",
       "max-file": "3"
     }
   }
   ```

## Monitoring Storage

### Grafana Dashboard
Import dashboard ID: 11074 (Node Exporter)
- Hiển thị disk usage
- Alert khi đầy disk
- Tracking growth rate

### Netdata
Truy cập: http://localhost:19999
- Real-time disk monitoring
- I/O statistics
- Alert tự động

## Kế hoạch Storage

Dung lượng đề xuất cho từng loại service:

| Service Type | Dung lượng | Note |
|-------------|-----------|------|
| Databases | 10-50 GB | Tùy thuộc data |
| AI Models | 50-200 GB | ComfyUI, SD models |
| Media | 100+ GB | Paperless, uploads |
| Backups | = 2x Data | Ít nhất 2 bản |
| Logs | 5-10 GB | Với rotation |
| System | 10 GB | Docker overhead |

**Tổng đề xuất:** 200-500 GB trên SSD

---

**Lưu ý:** Cấu trúc này được thiết kế cho CachyOS + Hyprland với RTX 3060 12GB