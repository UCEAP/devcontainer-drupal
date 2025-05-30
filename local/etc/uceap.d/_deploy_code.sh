function _deploy_code() {
	_assert_terminus_vars
	terminus drush -- state-set system.maintenance_mode TRUE
	_sftp_code
	terminus drush -- deploy
	terminus drush -- state-set system.maintenance_mode FALSE
}