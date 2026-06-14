.PHONY: help setup up down logs restart clean ps

help:
	@echo "N8N Docker Makefile commands:"
	@echo "  make setup          - Setup environment and SSL certificates"
	@echo "  make up             - Start all services"
	@echo "  make down           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make logs           - View logs from all services"
	@echo "  make logs-n8n       - View n8n service logs"
	@echo "  make ps             - Show running containers"
	@echo "  make clean          - Clean up containers and volumes"
	@echo "  make ssl-generate   - Generate self-signed SSL certificates"

setup: .env ssl-generate
	@echo "Setup complete. Edit .env file with your configuration."
	@echo "Run 'make up' to start the services."

.env:
	@cp .env.example .env
	@echo ".env file created. Please edit it with your configuration."

ssl-generate:
	@mkdir -p ssl
	@if [ ! -f ssl/cert.pem ]; then \
		echo "Generating self-signed SSL certificates..."; \
		openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes \
			-subj "/C=US/ST=State/L=City/O=Organization/CN=n8n.example.com"; \
		echo "SSL certificates generated in ssl/ directory"; \
	else \
		echo "SSL certificates already exist."; \
	fi

up:
	docker-compose up -d

down:
	docker-compose down

restart: down up

logs:
	docker-compose logs -f

logs-n8n:
	docker-compose logs -f n8n

ps:
	docker-compose ps

clean:
	docker-compose down -v
	@echo "All containers and volumes have been removed."

migrate-db:
	docker-compose exec n8n n8n db:migrate

# Access n8n CLI
cli:
	docker-compose exec n8n n8n

# View database
db-shell:
	docker-compose exec postgres psql -U n8n -d n8n

# Redis CLI
redis-cli:
	docker-compose exec redis redis-cli -a n8n_redis_password
