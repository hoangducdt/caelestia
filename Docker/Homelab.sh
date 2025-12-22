#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║  $1${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}"
}

# Check if .env exists
check_env() {
    if [ ! -f "$ENV_FILE" ]; then
        print_error ".env file not found!"
        print_info "Creating .env from .env.example..."
        if [ -f "$ENV_EXAMPLE" ]; then
            cp "$ENV_EXAMPLE" "$ENV_FILE"
            print_warning "Please edit .env file with your configuration before starting!"
            print_info "Generate secure keys with: openssl rand -base64 32"
            exit 1
        else
            print_error ".env.example not found!"
            exit 1
        fi
    fi
}

# Check if docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running!"
        exit 1
    fi
}

# Function to show service status
show_status() {
    print_header "HOMELAB SERVICES STATUS"
    docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
}

# Function to show logs
show_logs() {
    local service=$1
    if [ -z "$service" ]; then
        docker compose logs --tail=50 -f
    else
        docker compose logs --tail=50 -f "$service"
    fi
}

# Function to start all services
start_all() {
    print_header "STARTING ALL SERVICES"
    check_env
    check_docker
    
    print_info "Starting core services first..."
    docker compose up -d redis postgres mariadb
    sleep 10
    
    print_info "Starting remaining services..."
    docker compose up -d
    
    print_success "All services started!"
    echo ""
    show_status
}

# Function to stop all services
stop_all() {
    print_header "STOPPING ALL SERVICES"
    docker compose down
    print_success "All services stopped!"
}

# Function to restart services
restart_service() {
    local service=$1
    if [ -z "$service" ]; then
        print_info "Restarting all services..."
        docker compose restart
    else
        print_info "Restarting $service..."
        docker compose restart "$service"
    fi
    print_success "Service(s) restarted!"
}

# Function to update services
update_all() {
    print_header "UPDATING ALL SERVICES"
    print_info "Pulling latest images..."
    docker compose pull
    
    print_info "Recreating containers..."
    docker compose up -d --remove-orphans
    
    print_info "Removing unused images..."
    docker image prune -f
    
    print_success "Update completed!"
}

# Function to backup volumes
backup_volumes() {
    print_header "BACKING UP VOLUMES"
    local backup_dir="./backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    print_info "Creating backup in $backup_dir..."
    
    # List all volumes
    docker volume ls --format "{{.Name}}" | grep "$(basename $(pwd))" | while read volume; do
        print_info "Backing up $volume..."
        docker run --rm -v "$volume":/data -v "$backup_dir":/backup alpine tar czf "/backup/${volume}.tar.gz" -C /data .
    done
    
    print_success "Backup completed in $backup_dir"
}

# Function to show resource usage
show_stats() {
    print_header "CONTAINER RESOURCE USAGE"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Function to show service URLs
show_urls() {
    print_header "SERVICE ACCESS URLS"
    cat << EOF

${CYAN}Reverse Proxy & Networking:${NC}
  • Nginx Proxy Manager:     http://localhost:81
  
${CYAN}Management & Monitoring:${NC}
  • Portainer:               http://localhost:9000
  • Grafana:                 http://localhost:3000
  • Prometheus:              http://localhost:9090
  • Netdata:                 http://localhost:19999
  • Uptime Kuma:             http://localhost:3001
  • Dozzle (Logs):           http://localhost:8888
  • Homarr (Dashboard):      http://localhost:7575

${CYAN}Security:${NC}
  • CrowdSec:                http://localhost:8080
  • Authelia:                http://localhost:9091

${CYAN}Databases:${NC}
  • PostgreSQL:              localhost:5432
  • MariaDB:                 localhost:3306
  • Redis:                   localhost:6379

${CYAN}Automation & Workflows:${NC}
  • n8n:                     http://localhost:5678

${CYAN}Utilities & Tools:${NC}
  • IT-Tools:                http://localhost:8282
  • File Browser:            http://localhost:8081
  • Snippet Box:             http://localhost:5000
  • Change Detection:        http://localhost:5050
  • Wetty (Terminal):        http://localhost:3002

${CYAN}AI & ML:${NC}
  • Open WebUI:              http://localhost:3030
  • ComfyUI:                 http://localhost:8188
  • Stable Diffusion WebUI:  http://localhost:7860

${CYAN}Backup & Sync:${NC}
  • Duplicati:               http://localhost:8200
  • Syncthing:               http://localhost:8384

${CYAN}Document Management:${NC}
  • Paperless-ngx:           http://localhost:8010

EOF
}

# Function to clean up everything
cleanup() {
    print_header "CLEANING UP DOCKER ENVIRONMENT"
    print_warning "This will remove all stopped containers, unused networks, and dangling images!"
    read -p "Are you sure? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        docker system prune -f
        print_success "Cleanup completed!"
    else
        print_info "Cleanup cancelled."
    fi
}

# Function to generate secure keys
generate_keys() {
    print_header "GENERATING SECURE KEYS"
    echo ""
    print_info "32-character key (for most secrets):"
    openssl rand -base64 32
    echo ""
    print_info "64-character key (for JWT/storage encryption):"
    openssl rand -base64 64
    echo ""
    print_warning "Save these keys securely and add them to your .env file!"
}

# Function to show help
show_help() {
    cat << EOF
${MAGENTA}╔════════════════════════════════════════════════════════════╗
║         HOMELAB DOCKER COMPOSE MANAGEMENT SCRIPT           ║
╚════════════════════════════════════════════════════════════╝${NC}

${CYAN}Usage:${NC} $0 [command] [options]

${CYAN}Commands:${NC}
  ${GREEN}start${NC}           Start all services
  ${GREEN}stop${NC}            Stop all services
  ${GREEN}restart${NC} [name]  Restart service(s) (all if no name provided)
  ${GREEN}status${NC}          Show service status
  ${GREEN}logs${NC} [name]     Show logs (all if no name provided)
  ${GREEN}update${NC}          Pull latest images and update services
  ${GREEN}backup${NC}          Backup all volumes
  ${GREEN}stats${NC}           Show resource usage
  ${GREEN}urls${NC}            Show service access URLs
  ${GREEN}cleanup${NC}         Clean up Docker environment
  ${GREEN}keys${NC}            Generate secure keys for .env
  ${GREEN}help${NC}            Show this help message

${CYAN}Examples:${NC}
  $0 start                 # Start all services
  $0 logs nginx-proxy-manager  # Show logs for specific service
  $0 restart grafana       # Restart Grafana
  $0 stats                 # Show resource usage

${CYAN}Service Names:${NC}
  nginx-proxy-manager, cloudflare-ddns, portainer, watchtower,
  autoheal, diun, grafana, crowdsec, authelia, prometheus,
  netdata, n8n, redis, postgres, mariadb, it-tools, homarr,
  dozzle, uptime-kuma, open-webui, comfyui, stable-diffusion-webui,
  filebrowser, snippet-box, playwright-chrome, changedetection,
  wetty, postgres-backup, duplicati, paperless-ngx, syncthing

EOF
}

# Main script logic
case "$1" in
    start)
        start_all
        ;;
    stop)
        stop_all
        ;;
    restart)
        restart_service "$2"
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    update)
        update_all
        ;;
    backup)
        backup_volumes
        ;;
    stats)
        show_stats
        ;;
    urls)
        show_urls
        ;;
    cleanup)
        cleanup
        ;;
    keys)
        generate_keys
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac