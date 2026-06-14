# n8n Docker Setup

A complete Docker Compose setup for running **n8n** (workflow automation platform) with PostgreSQL, Redis, and Nginx reverse proxy.

## Features

- **n8n**: Latest n8n workflow automation engine
- **PostgreSQL**: Database backend for data persistence
- **Redis**: Caching and queue management
- **Nginx**: Reverse proxy with SSL/TLS support
- **Health Checks**: All services include health checks
- **Volume Management**: Data persistence across restarts
- **Security**: SSL/TLS encryption, security headers, container isolation

## Prerequisites

- Docker and Docker Compose installed
- 4GB+ RAM available
- Ports 80, 443 available (or configure custom ports)

## Quick Start

### 1. Clone and Setup

```bash
# Copy environment configuration
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### 2. Generate SSL Certificates

```bash
# Option A: Using Makefile (recommended)
make ssl-generate

# Option B: Manual self-signed certificate
mkdir -p ssl
openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes
```

### 3. Start Services

```bash
# Using Makefile
make up

# Or using docker-compose directly
docker-compose up -d
```

### 4. Access n8n

- **URL**: https://localhost (via nginx) or http://localhost:5678 (direct)
- Wait 30-60 seconds for services to fully initialize
- Check health: `docker-compose ps`

## Configuration

### Environment Variables

Edit `.env` file to configure:

- **Database**: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- **Redis**: `REDIS_PASSWORD`
- **N8N**: `N8N_HOST`, `N8N_PORT`, `WEBHOOK_URL`
- **Security**: `N8N_ENCRYPTION_KEY` (generate a random 32+ character string)
- **Timezone**: `TIMEZONE` (e.g., UTC, America/New_York)

**⚠️ Important**: Generate a secure encryption key for production:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### SSL/TLS Certificates

- **Self-signed**: For development/testing (already included)
- **Let's Encrypt**: For production, use Certbot or similar:

```bash
certbot certonly --standalone -d n8n.example.com
# Update nginx/conf.d/n8n.conf with certificate paths
```

### Webhook URL

Update `WEBHOOK_URL` in `.env` to match your domain:

```env
WEBHOOK_URL=https://n8n.example.com
```

## Usage

### Makefile Commands

```bash
make help              # Show all available commands
make up                # Start all services
make down              # Stop all services
make restart           # Restart services
make logs              # View logs from all services
make logs-n8n          # View n8n logs only
make ps                # Show running containers
make clean             # Remove containers and volumes
make ssl-generate      # Generate SSL certificates
make db-shell          # Access PostgreSQL CLI
make redis-cli         # Access Redis CLI
```

### Docker Compose Commands

```bash
# View logs
docker-compose logs -f n8n

# Execute command in container
docker-compose exec n8n n8n --help

# Database backup
docker-compose exec postgres pg_dump -U n8n -d n8n > backup.sql

# Database restore
docker-compose exec -T postgres psql -U n8n -d n8n < backup.sql
```

## Services

### n8n (Port 5678)
- Main workflow automation platform
- Accessible via: `http://localhost:5678` (direct) or `https://n8n.example.com` (via nginx)

### PostgreSQL (Port 5432)
- Database container (not exposed externally by default)
- Volume: `postgres_data`

### Redis (Port 6379)
- Cache and queue management (not exposed externally)
- Volume: `redis_data`

### Nginx (Ports 80, 443)
- Reverse proxy with SSL/TLS
- Redirects HTTP to HTTPS
- Proxies requests to n8n service

## Monitoring and Troubleshooting

### Check Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f n8n
docker-compose logs -f postgres
docker-compose logs -f redis
```

### Test Services

```bash
# Check n8n health
curl http://localhost:5678/healthz

# Access databases
make db-shell        # PostgreSQL
make redis-cli       # Redis
```

### Common Issues

**Services won't start:**
- Check ports 80, 443, 5678 are available
- Ensure Docker daemon is running
- Check logs: `docker-compose logs`

**Can't connect to n8n:**
- Wait 60 seconds for startup
- Check health: `docker-compose ps`
- Verify network: `docker network ls`

**Database connection error:**
- Ensure PostgreSQL is running: `docker-compose logs postgres`
- Check credentials in `.env`
- Verify health checks passed

**SSL certificate issues:**
- Regenerate certificates: `make ssl-generate`
- For production: Use proper certificates from Let's Encrypt

## Backup and Restore

### Backup Database

```bash
docker-compose exec postgres pg_dump -U n8n -d n8n > backup.sql
```

### Restore Database

```bash
docker-compose exec -T postgres psql -U n8n -d n8n < backup.sql
```

### Backup n8n Data

```bash
docker cp n8n-app:/home/node/.n8n ./n8n_backup
```

## Production Deployment

### Security Checklist

- [ ] Change default PostgreSQL and Redis passwords
- [ ] Generate strong `N8N_ENCRYPTION_KEY`
- [ ] Use valid SSL/TLS certificates (Let's Encrypt)
- [ ] Update `WEBHOOK_URL` with your domain
- [ ] Configure firewall to restrict access
- [ ] Set up log rotation
- [ ] Enable automated backups
- [ ] Monitor resource usage
- [ ] Keep Docker images updated

### Performance Tuning

```yaml
# In docker-compose.yml for production:
services:
  n8n:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

## Volume Management

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect n8n-docker_n8n_data

# Remove unused volumes
docker volume prune
```

## Updating n8n

```bash
# Pull latest image
docker-compose pull n8n

# Restart service
docker-compose up -d n8n
```

## Documentation

- [n8n Documentation](https://docs.n8n.io)
- [n8n Docker Hub](https://hub.docker.com/r/n8nio/n8n)
- [PostgreSQL Documentation](https://www.postgresql.org/docs)
- [Redis Documentation](https://redis.io/documentation)

## Support

For issues and support:
- [n8n Community](https://community.n8n.io)
- [n8n GitHub Issues](https://github.com/n8n-io/n8n/issues)
- [Docker Documentation](https://docs.docker.com)

## License

This project is provided as-is. See LICENSE file for details.

