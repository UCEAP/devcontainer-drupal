function deploy_to_multidev() {
	_assert_terminus_vars
	_sftp_code

	terminus drush -- $DRUSH_TASK
}

_deploy_to_multidev_desc='deploys the local code to a Pantheon multidev'
_deploy_to_multidev_help='
Deploys the local code to a Pantheon multidev.

# Usage

```bash
TERMINUS_ENV=pr-1234 uceap deploy-to-multidev
```

## Description

This command requires the `TERMINUS_SITE` and `DRUSH_TASK` environment variables to be set.

It also requires the `TERMINUS_ENV` environment variable to be set.
'