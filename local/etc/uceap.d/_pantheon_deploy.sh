function _pantheon_deploy() {
	_assert_terminus_vars
	terminus drush -- state-set system.maintenance_mode TRUE
	# No cache clear before env:deploy: if an earlier deploy stalled, the target
	# already has new code on the old schema, and a cache rebuild there can fail
	# before the database updates get a chance to run.
	terminus env:deploy $deploy_args
	_pantheon_complete_deployment
}

function _pantheon_complete_deployment() {
	# drush deploy runs updatedb before config:import and cache:rebuild. Don't
	# rebuild caches before it: new core code can't rebuild against a schema
	# its update hooks haven't migrated yet (e.g. 11.1 -> 11.4 adds router.alias).
	terminus drush -- deploy
	sleep 60
	terminus drush -- state-set system.maintenance_mode FALSE
	terminus env:clear-cache
}
