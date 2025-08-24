.PHONY: deploy stop start restart logs health clean


deploy: 
	docker compose down
	docker compose pull
	docker compose up -d

stop:
	docker compose down

start:
	docker compose up -d

restart: stop start

logs:
	docker compose logs -f

logs-service:
	docker compose logs -f $(SERVICE)

health:
	docker compose ps
	@for service in plex qbittorrent homebridge portainer mealie kavita filestash; do \
		if docker compose ps $$service | grep -q "Up"; then \
			echo "✅ $$service is running"; \
		else \
			echo "❌ $$service is not running"; \
		fi; \
	done

clean:
	docker image prune -f
	docker system prune -f --volumes

update-service:
	docker compose pull $(SERVICE)
	docker compose up -d $(SERVICE)

stats:
	docker stats --no-stream


