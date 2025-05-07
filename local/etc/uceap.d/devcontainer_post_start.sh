function devcontainer_post_start() {

	# we don't have any generic post-start tasks, but we still run any project-specific scripts

	# Run local devcontainer lifecycle scripts
	if [ -x .devcontainer/postStart.sh ]; then
		.devcontainer/postStart.sh
	fi
}

_devcontainer_post_start_desc="Runs after the devcontainer is started"
_devcontainer_post_start_help="
"