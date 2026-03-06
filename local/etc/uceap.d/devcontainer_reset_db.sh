function devcontainer_reset_db() {
	# Detect the compose project by inspecting the current container
	CURRENT_CONTAINER=$(hostname)
	echo "Running from container: $CURRENT_CONTAINER"

	# Get the compose project name from the current container's labels
	COMPOSE_PROJECT=$(docker inspect "$CURRENT_CONTAINER" --format '{{index .Config.Labels "com.docker.compose.project"}}' 2>/dev/null)

	if [ -z "$COMPOSE_PROJECT" ]; then
		echo "Warning: Could not detect compose project from container labels"
		echo "Falling back to workspace-based detection..."
		# Fallback to the old method
		if [ -n "$WORKSPACE_FOLDER" ]; then
			WORKSPACE_NAME=$(basename "$WORKSPACE_FOLDER")
		else
			WORKSPACE_NAME=$(basename "$(pwd)")
		fi
		COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-${WORKSPACE_NAME}_devcontainer}"
	fi

	echo "Using compose project: $COMPOSE_PROJECT"

	# Find the mariadb container in the same compose project
	CONTAINER_NAME=$(docker ps -a --filter "label=com.docker.compose.project=$COMPOSE_PROJECT" --filter "label=com.docker.compose.service=mariadb" --format "{{.Names}}" | head -n 1)

	if [ -z "$CONTAINER_NAME" ]; then
		echo "Error: Could not find mariadb container for project '$COMPOSE_PROJECT'"
		echo "Available mariadb containers:"
		docker ps -a --filter "name=mariadb" --format "table {{.Names}}\t{{.Label \"com.docker.compose.project\"}}"
		return 1
	fi

	echo "Found container: $CONTAINER_NAME"

	# Get the volume name from the mariadb container before stopping it
	VOLUME_NAME=$(docker inspect "$CONTAINER_NAME" --format '{{range .Mounts}}{{if eq .Destination "/var/lib/mysql"}}{{.Name}}{{end}}{{end}}')

	if [ -z "$VOLUME_NAME" ]; then
		echo "Error: Could not find mariadb volume"
		return 1
	fi

	echo "Found volume: $VOLUME_NAME"

	# Stop and remove the container
	docker compose -p "$COMPOSE_PROJECT" -f .devcontainer/docker-compose.yml stop mariadb
	docker compose -p "$COMPOSE_PROJECT" -f .devcontainer/docker-compose.yml rm -f mariadb

	# Remove the volume
	echo "Removing volume: $VOLUME_NAME"
	docker volume rm "$VOLUME_NAME"

	# Start the container with a fresh volume
	docker compose -p "$COMPOSE_PROJECT" -f .devcontainer/docker-compose.yml up -d mariadb

	echo "Waiting for database to be ready..."
	sleep 5

	# Clear Drupal cache since the database was reset
	echo "Clearing Drupal cache..."
	_cwd_workspace
	drush cache-rebuild

	echo "Database reset complete!"
}

_devcontainer_reset_db_desc='resets devcontainer database to original state'
_devcontainer_reset_db_help='
Resets the devcontainer database to its original state by recreating the mariadb container and removing its data volume.

# Usage

``` bash
uceap devcontainer-reset-db
```

## Description

This command is faster than `uceap refresh-content` when you only need to reset the database to its original seeded state. It works by:

1. Stopping and removing the mariadb container
2. Removing the anonymous volume that contains the modified database data
3. Recreating the container from the image with baked-in seed data

This is useful after running e2e tests that modify the database (e.g., submitting an application). The database container image has seed data pre-baked, so resetting to a clean state is much faster than downloading and importing a SQL dump from Pantheon.

**Note:** This command only works in devcontainers and will not work in CI or other environments.
'
