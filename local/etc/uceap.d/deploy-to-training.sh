function deploy_to_training() {
	export TERMINUS_ENV="training"

	deploy_args=""
	_terminus_login
	terminus multidev:delete --delete-branch -y
	sleep 60
	terminus multidev:create $TERMINUS_SITE.dev $TERMINUS_ENV
	terminus drush -- state-set system.maintenance_mode TRUE
	_pantheon_complete_deployment
}

_deploy_to_training_desc='deploys the code on Pantheon to TRAINING'
_deploy_to_training_help='
Deploys the code on Pantheon to TRAINING.

# Usage

```bash
uceap deploy-to-training
```

## Description

Creates a new training environment with the latest code and data from DEV.

This command requires the `TERMINUS_SITE` environment variable to be set.
'