function _cwd_workspace() {
	# ensure we're working in the workspace folder
	if [ -n "$WORKSPACE_FOLDER" ]; then
		cd $WORKSPACE_FOLDER
	else
		echo "[warning] No WORKSPACE_FOLDER environment variable set. This script assumes you're in a devcontainer."
		# as a transitional fallback, check to see if composer.json exists in the current directory, in which case we assume we're in the workspace folder
		if [ ! -f composer.json ]; then
			echo "[error] No composer.json found in the current directory, please run this script from the root of your project."
			exit 1
		fi
	fi
}
