function _pantheon_deploy() {
	_assert_terminus_vars
	if [ -z "$deploy_args" ]; then
		echo "Error: deploy_args is not set." >&2
		exit 1
	fi
	terminus drush -- state-set system.maintenance_mode TRUE
	terminus env:clear-cache
	terminus env:deploy $deploy_args
	_pantheon_complete_deployment
}

function _pantheon_complete_deployment() {
	terminus drush -- cache-rebuild
	terminus drush -- $DRUSH_TASK
	sleep 60
	terminus env:clear-cache
}