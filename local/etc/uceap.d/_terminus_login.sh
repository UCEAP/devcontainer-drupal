function _terminus_login() {
	if [ -z "$TERMINUS_TOKEN" ]; then
		# Fallback to DEVOPS_TERMINUS_TOKEN if personal token is not set (intended for Codespaces).
		if [ -z "$DEVOPS_TERMINUS_TOKEN" ]; then
			echo "Please set the TERMINUS_TOKEN environment variable."
			exit 1
		fi
		export TERMINUS_TOKEN=$DEVOPS_TERMINUS_TOKEN
	fi
	terminus auth:login --machine-token=$TERMINUS_TOKEN
}
