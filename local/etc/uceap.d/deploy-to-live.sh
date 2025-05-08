function deploy_to_live() {
	export TERMINUS_ENV="live"

	deploy_args=""
	
	_pantheon_deploy
}

_deploy_to_live_desc='deploys the local code to the Pantheon LIVE environment'
_deploy_to_live_help='
Deploys the local code to the Pantheon LIVE environment.

# Usage

```bash
uceap deploy-to-live
```

## Description

This command requires the `TERMINUS_SITE` and `DRUSH_TASK` environment variables to be set.
'