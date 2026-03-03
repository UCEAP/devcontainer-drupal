function devcontainer_reset_db() {
	# Determine the compose project name from the workspace folder
	# Use WORKSPACE_FOLDER env var if set by devcontainer, otherwise derive from pwd
	if [ -n "$WORKSPACE_FOLDER" ]; then
		WORKSPACE_NAME=$(basename "$WORKSPACE_FOLDER")
	else
		WORKSPACE_NAME=$(basename "$(pwd)")
	fi
	COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-${WORKSPACE_NAME}_devcontainer}"

	echo "Using compose project: $COMPOSE_PROJECT"

	# Get the container name
	CONTAINER_NAME="${COMPOSE_PROJECT}-mariadb-1"

	# Verify the container exists
	if ! docker inspect "$CONTAINER_NAME" &>/dev/null; then
		echo "Error: Container $CONTAINER_NAME not found"
		echo "Available mariadb containers:"
		docker ps -a --filter "name=mariadb" --format "{{.Names}}"
		return 1
	fi

	# Get the volume name from the mariadb container before stopping it
	VOLUME_NAME=$(docker inspect "$CONTAINER_NAME" --format '{{range .Mounts}}{{if eq .Destination "/var/lib/mysql"}}{{.Name}}{{end}}{{end}}')

	if [ -z "$VOLUME_NAME" ]; then
		echo "Error: Could not find mariadb volume"
		return 1
	fi

	echo "Found container: $CONTAINER_NAME"
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
