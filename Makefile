all: create_folder build start

# create folders required by subject
create_folder:
	mkdir -p /home/nchok/data/mariadb
	mkdir -p /home/nchok/data/wordpress

# ! BUILD IMAGES (a.k.a Compile)
# docker compose -f: file flag tell Docker exactly where configuration file is located/
#						without this flag, docker will look for "docker-compose.yaml"
#						since subject requires file to be in srcs, this flag is MANDATORY
# build: a subcommand to reads "yaml file" and build the images in the sections of services (MariaDB, WordPress, NGINX)
build:
	@docker compose -f ./srcs/docker-compose.yaml build

# ! START RUNNING CONTAINERS
# up: This subcommand creates and starts the containers defined in your compose file.
# -d: This stands for Detached mode. It runs the containers in the background. 
#		Without this, your terminal would be stuck displaying the logs of the containers, 
#		and closing the terminal would kill the containers.
start:
	@docker compose -f ./srcs/docker-compose.yaml up -d

# ! STOP RUNNING CONTAINER (NO CONTAINER REMOVAL)
# stop: This stops the running containers without removing them. 
# 		The data in the container's writable layer is preserved, 
#		and the containers can be started again later.
stop:
	@docker compose -f ./srcs/docker-compose.yaml stop

# ! SHUT DOWN CONTAINER AND REMOVE THEM
# down: This stops the containers and removes them.
#		It also removes the internal network created by Docker Compose. 
#		It does not remove volumes by default (so your database data stays safe).
down:
	@docker compose -f ./srcs/docker-compose.yaml down

# ! VIEWING LOGS
# logs: fetches the output (logs) from the containers.
# -f: This stands for Follow. It keeps the stream open,
#		so you see new log messages in real-time as they happen (similar to tail -f). 
#		Press Ctrl+C to exit this view
logs:
	@docker compose -f ./srcs/docker-compose.yaml logs -f

# ! CLEANING IN HOST
# Cleaning Scope: Projects Only
# - Reads your docker-compose yaml files, find out exactly which containers, networks, 
#		and volumes belong to this specific project.
# - It will not touch other Docker containers or images you might have on your compute
clean:
	@docker-compose -f ./srcs/docker-compose.yaml down --rmi all -v

# ! CLEANING IN VM
# Cleaning Scope: The entire machine
# - It asks Docker to list every single container, image, volume, and network on your computer 
#		and forces them to be deleted.
# - If you run this on your personal laptop and you have other Docker projects 
#	(e.g., a personal database, a Plex server, another school project), they will be deleted instantly.
# clean:
#	@docker stop $$(docker ps -qa) 2>/dev/null; \
    docker rm $$(docker ps -qa) 2>/dev/null; \
    docker rmi -f $$(docker images -qa) 2>/dev/null; \
    docker volume rm $$(docker volume ls -q) 2>/dev/null; \
    docker network rm $$(docker network ls -q) 2>/dev/null

# ! System Prune (Deep Clean)
# docker system prune: A built-in Docker command to remove unused data.
# -a (all): Remove all unused images, not just "dangling" ones (images with no name).
# -f (force): Do not ask for confirmation (Yes/No prompt).
# --volumes: Also remove unused volumes. 
#			This is critical because standard prune often skips volumes to preserve data.
prune:
	@docker system prune -af --volumes

# Dangerous: Deletes all data
fclean: prune
	@rm -rf /home/login/data/mariadb/*
	@rm -rf /home/login/data/wordpress/*


.PHONY: all build start stop down logs clean prune fclean re