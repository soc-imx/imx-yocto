# Declare phony targets to avoid conflicts with files of the same name
.PHONY: build run stop clean exec logs rebuild update-compose

# Build the Docker container
# This command will build the Docker image as specified in the Dockerfile
build:
	docker-compose build

# Run the Docker container in detached mode
# This command will start the Docker container in the background
run:
	docker-compose up -d

# Stop the Docker container
# This command will stop and remove the Docker container
stop:
	docker-compose down

# Clean up Docker containers, images, and volumes
# This command will stop and remove all containers, images, and volumes associated with the project
clean:
	docker-compose down --rmi all --volumes --remove-orphans
	docker system prune -a --volumes

# Execute a command in the running container
# This command will open a bash shell in the running container
exec:
	docker-compose exec app bash

# View logs from the running container
# This command will display and follow the logs from the running container
logs:
	docker-compose logs -f

# Rebuild the Docker container without using cache
# This command will rebuild the Docker image without using the cache, ensuring a fresh build
rebuild:
	docker-compose build --no-cache

# Update Docker Compose to the latest version
# This command will remove the current Docker Compose, download the latest version, and set the appropriate permissions
update-compose:
	sudo rm /usr/local/bin/docker-compose
	sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	docker-compose --version