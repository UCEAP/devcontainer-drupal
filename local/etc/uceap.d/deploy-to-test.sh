function deploy_to_test() {
	export TERMINUS_ENV="test"

	deploy_args="$deploy_args --sync-content"
	if [ $# -eq 1 ]; then
		if [ "$1" = "--no-sync" ]; then
			deploy_args=""
		else
			echo "Error: Unsupported argument $1" >&2
			exit 1
		fi
	fi
	
	_pantheon_deploy
}

_deploy_to_test_desc='deploys the local code to the Pantheon TEST environment'
_deploy_to_test_help='
Deploys the local code to the Pantheon TEST environment.

# Usage

```bash
uceap deploy-to-test
```

## Description

This command requires the `TERMINUS_SITE` and `DRUSH_TASK` environment variables to be set.
'