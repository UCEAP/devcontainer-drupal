function deploy_to_dev() {
	export TERMINUS_ENV="dev"
	_terminus_login
	_deploy_code
	terminus env:commit --force -y
}

_deploy_to_dev_desc='deploys code from local filesystem to Pantheon DEV environment'
_deploy_to_dev_help='
Deploys code from local filesystem to the Pantheon DEV environment.

# Usage

```bash
uceap deploy-to-dev
```

## Description

This command requires the `TERMINUS_SITE` environment variable to be set.
'
