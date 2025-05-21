function deploy_to_live() {
	export TERMINUS_ENV="live"

	deploy_args=""
	_terminus_login
	_pantheon_deploy
}

_deploy_to_live_desc='deploys the code on Pantheon from TEST to LIVE'
_deploy_to_live_help='
Deploys the code on Pantheon from TEST to LIVE.

# Usage

```bash
uceap deploy-to-live
```

## Description

This command requires the `TERMINUS_SITE` environment variable to be set.
'