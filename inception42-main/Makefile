# Docker compose file
DOCKER_COMPOSE = ./srcs/docker-compose.yml

# Data path
DATA_PATH = $(HOME)/data

# Default: build and start containers
all: up

# Create directory for data
build_dirs:
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb

# Build and start containers
up: build_dirs
	docker compose -f $(DOCKER_COMPOSE) up -d --build

# Stop containers
down:
	docker compose -f $(DOCKER_COMPOSE) down

# Show running containers
ps:
	docker compose -f $(DOCKER_COMPOSE) ps

# Restart containers
restart:
	docker compose -f $(DOCKER_COMPOSE) restart

# View logs
logs:
	docker compose -f $(DOCKER_COMPOSE) logs -f

# Clean unused docker resources
clean: down
	docker system prune -af

# deep clean
fclean: clean
	docker volume prune -f
	@sudo rm -rf $(DATA_PATH)

# Rebuild everything
re: fclean all

.PHONY: all up down ps logs clean fclean re restart