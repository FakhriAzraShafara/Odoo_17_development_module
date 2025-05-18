WEB_DB_NAME = odoo_development
DOCKER = docker
DOCKER_COMPOSE = $(DOCKER) compose
CONTAINER_ODOO = odoo
CONTAINER_POSTGRES = odoo-postgres
CONTAINER_DB = odoo-postgres

help:
	@echo "Makefile for Odoo development environment"
	@echo "Usage:"
	@echo "  make start                		Start the Odoo and PostgreSQL containers"
	@echo "  make stop              		Stop and remove the containers"
	@echo "  make restart             		Restart the compose"
	@echo "  make addons <addon_names>  		Restart instance and upgrade addons (comma-separated)"
	@echo "  make console 				Odoo interactive console"
	@echo "  make psql 				PostgreSQL interactive shell"
	@echo "  make logs odoo             		View the logs of the Odoo container"
	@echo "  make logs db               		View the logs of the PostgreSQL container"

start:
	@echo "Starting Odoo and PostgreSQL containers..."
	@$(DOCKER_COMPOSE) up -d

stop:
	@echo "Stopping and removing containers..."
	@$(DOCKER_COMPOSE) down

restart:
	@echo "Restarting containers..."
	@$(DOCKER_COMPOSE) restart

psql:
	@echo "Starting PostgreSQL interactive shell..."
	@$(DOCKER) exec -it $(CONTAINER_DB) psql -U $(CONTAINER_ODOO) -d $(WEB_DB_NAME)
	
console:
	@echo "Starting Odoo interactive console..."
	@$(DOCKER) exec -it $(CONTAINER_ODOO) odoo shell --db_host=$(CONTAINER_DB) -d $(WEB_DB_NAME) -r $(CONTAINER_ODOO) -w $(CONTAINER_ODOO)


define log_target
	@if [ "$(1)" = "odoo" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_ODOO); \
	elif [ "$(1)" = "db" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_DB); \
	else \
		echo "Invalid target. Use 'make logs odoo' or 'make logs db'"; \
	fi
endef

logs:
	@echo "Viewing logs of the $(word 2,$(MAKECMDGOALS)) container..."
	$(call log_target,$(word 2,$(MAKECMDGOALS)))

.PHONY: start stop restart console psql logs odoo db help
