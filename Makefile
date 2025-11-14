SHELL := /bin/bash
COMPOSE ?= docker compose
HOMELAB_NETWORK := homelab
STACK_DIRS := apps access/homepage access/tunnel smart_home_hub smart_home_satellite

.PHONY: help network up down restart ps logs env-check clean

help:
	@echo "Available targets:"
	@echo "  make network        # create the shared homelab network if missing"
	@echo "  make up             # bring up all stacks (after ensuring network exists)"
	@echo "  make down           # stop all stacks"
	@echo "  make restart        # down then up"
	@echo "  make ps             # show compose status for each stack"
	@echo "  make logs STACK=<dir> [SERVICE=<name>]  # tail logs for a specific stack/service"
	@echo "  make env-check      # verify required .env files exist"
	@echo "  make clean          # remove stopped containers, unused networks, dangling images"

network:
	@docker network inspect $(HOMELAB_NETWORK) >/dev/null 2>&1 \
		&& echo "Network $(HOMELAB_NETWORK) already exists" \
		|| (echo "Creating $(HOMELAB_NETWORK) network" && docker network create $(HOMELAB_NETWORK))

up: network
	@for dir in $(STACK_DIRS); do \
		echo "==> $$dir"; \
		(cd $$dir && $(COMPOSE) up -d); \
	done

down:
	@for dir in $(STACK_DIRS); do \
		echo "==> $$dir"; \
		(cd $$dir && $(COMPOSE) down); \
	done

restart: down up

ps:
	@for dir in $(STACK_DIRS); do \
		echo "==> $$dir"; \
		(cd $$dir && $(COMPOSE) ps); \
	done

logs:
	@if [ -z "$(STACK)" ]; then \
		echo "Please provide STACK=<directory> (e.g., STACK=access/tunnel)"; exit 1; \
	fi
	@(cd $(STACK) && $(COMPOSE) logs -f $(SERVICE))

env-check:
	@missing=0; \
	for file in $(STACK_DIRS:%=%/.env); do \
		if [ ! -f $$file ]; then \
			echo "Missing $$file"; missing=1; \
		else \
			echo "Found $$file"; \
		fi; \
	 done; \
	if [ $$missing -ne 0 ]; then \
		echo "One or more env files are missing"; exit 1; \
	fi

clean:
	@docker system prune -f
