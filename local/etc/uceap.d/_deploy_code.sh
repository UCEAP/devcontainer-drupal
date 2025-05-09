function _deploy_code() {
	_assert_terminus_vars
	_sftp_code
	terminus drush -- $DRUSH_TASK
}