function devcontainer_update_content() {
	_cwd_workspace

	# during first run, the new PATH from the on-create script is not yet in effect
	if ( ! command -v drush > /dev/null ); then
		export PATH="`pwd`/vendor/bin:$PATH"
	fi

	# the first time we run this script the default umask is still in effect,
	# which messes up permissions on the profiler directory that gets created when the caches are rebuilt by db-rebuild.sh
	umask 002

	# Run local devcontainer lifecycle scripts
	if [ -x .devcontainer/updateContent.sh ]; then
		.devcontainer/updateContent.sh
	fi
}

_devcontainer_update_content_desc='Runs when the devcontainer needs to update content'
_devcontainer_update_content_help='
This command implements the `updateContentCommand` lifecycle event for dev containers.

This is the second of three that finalizes container setup when a dev container is created. It executes inside the container after `onCreateCommand` whenever new content is available in the source tree during the creation process.

It will execute at least once, but cloud services will also periodically execute the command to refresh cached or prebuilt containers. Like cloud services using `onCreateCommand`, it can only take advantage of repository and org scoped secrets or permissions.
'