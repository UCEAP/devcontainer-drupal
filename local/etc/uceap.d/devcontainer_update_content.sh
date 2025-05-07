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

_devcontainer_update_content_desc="Runs when the devcontainer needs to update content"
_devcontainer_update_content_help="
"