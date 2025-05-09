function refresh_content() {
	_cwd_workspace
	composer install
	composer compile-theme

	# download pantheon backups
	export TERMINUS_ENV="dev"
	FILES_BACKUP=$(mktemp --dry-run files-XXXXXX.tar.gz)
	DATABASE_BACKUP=$(mktemp --dry-run database-XXXXXX.sql.gz)
	terminus backup:get --element=files --to=$FILES_BACKUP
	terminus backup:get --element=db --to=$DATABASE_BACKUP

	rm -rf web/sites/default/files
	mkdir web/sites/default/files
	chgrp www-data web/sites/default/files
	chmod 2775 web/sites/default/files
	tar zx --no-same-permissions --strip-components 1 -C web/sites/default/files -f $FILES_BACKUP
	# no-same-permissions doesn't seem to work so we fix it here
	sudo find web/sites/default/files -type d -exec chmod g+ws {} +
	sudo find web/sites/default/files -type f -exec chmod g+w {} +

	build/db-rebuild.sh $DATABASE_BACKUP

	rm $FILES_BACKUP
	rm $DATABASE_BACKUP
}

_refresh_content_desc='refreshes code, files, and database in devcontainer'
_refresh_content_help='
Refreshes local code, files, and database in devcontainer.

# Usage

``` bash
uceap refresh-content
```

## Description

This command is useful when switching branches.

First it runs composer install, in case the new branch has updated dependencies.

It also compiles the theme, in case there are any changes to the theme between branches.

Then it downloads the latest backups from DEV and replaces the local files and database with them.

Finally, it rebuilds the database using the new database backup.
'