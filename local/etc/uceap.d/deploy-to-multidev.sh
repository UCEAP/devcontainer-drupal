function deploy_to_multidev() {
	_terminus_login
	_deploy_code
}

_deploy_to_multidev_desc='deploys code from local filesystem to a Pantheon multidev'
_deploy_to_multidev_help='
Deploys code from local filesystem to a Pantheon multidev.

# Usage

```bash
TERMINUS_ENV=pr-1234 uceap deploy-to-multidev
```

## Description

This command requires the `TERMINUS_SITE` and `TERMINUS_ENV` environment variables to be set.
'