function _pantheon_deploy() {
	_assert_terminus_vars
	local major_upgrade=false
	if _drupal_major_upgrade_pending; then
		major_upgrade=true
	fi
	terminus drush -- state-set system.maintenance_mode TRUE
	terminus env:clear-cache
	terminus env:deploy $deploy_args
	if $major_upgrade; then
		# A new major version of core can't rebuild its cache against the old
		# schema, so the database updates must run before cache-rebuild.
		terminus drush -- updatedb -y
	fi
	_pantheon_complete_deployment
}

# Succeeds when the code being deployed runs a newer Drupal major version than
# the database that will end up in the target environment.
function _drupal_major_upgrade_pending() {
	local code_env db_env code_version db_version
	case "$TERMINUS_ENV" in
		test) code_env="dev" ;;
		live) code_env="test" ;;
		*) return 1 ;;
	esac
	# --sync-content replaces the target's database with LIVE's.
	if [[ " $deploy_args " == *" --sync-content "* ]]; then
		db_env="live"
	else
		db_env="$TERMINUS_ENV"
	fi
	code_version=$(terminus drush "$TERMINUS_SITE.$code_env" -- status --field=drupal-version) || return 1
	db_version=$(terminus drush "$TERMINUS_SITE.$db_env" -- status --field=drupal-version) || return 1
	echo "Drupal core: $code_version on $code_env, $db_version on $db_env"
	if [ "${code_version%%.*}" -gt "${db_version%%.*}" ]; then
		echo "Major version upgrade detected; database updates will run before cache-rebuild."
		return 0
	fi
	return 1
}

function _pantheon_complete_deployment() {
	terminus drush -- cache-rebuild
	terminus drush -- deploy
	sleep 60
	terminus drush -- state-set system.maintenance_mode FALSE
	terminus env:clear-cache
}
