function devcontainer_post_start() {

	# we don't have any generic post-start tasks, but we still run any project-specific scripts

	# Run local devcontainer lifecycle scripts
	if [ -x .devcontainer/postStart.sh ]; then
		.devcontainer/postStart.sh
	fi
}

_devcontainer_post_start_desc='runs after the devcontainer is started'
_devcontainer_post_start_help='
This command implements the `postStartCommand` lifecycle event for dev containers.

# Usage

Add the following to your `devcontainer.json` file:

``` json
{
	"postStartCommand": "uceap devcontainer-post-start"
}
```

## Description


This command is run each time the container is successfully started.
'