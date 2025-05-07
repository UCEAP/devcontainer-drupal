function deploy_to_dev() {
	export TERMINUS_ENV="dev"

	_assert_terminus_vars
	_sftp_code
	terminus env:commit --force -y
	
	terminus drush -- $DRUSH_TASK
}

_deploy_to_dev_desc='deploys the local code to the Pantheon DEV environment'
_deploy_to_dev_help='
Deploys the local code to the Pantheon DEV environment.

# Usage

```bash
uceap deploy-to-dev
```

## Description

This command requires the `TERMINUS_SITE` and `DRUSH_TASK` environment variables to be set.
'