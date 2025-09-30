function devcontainer_on_create() {
	# Change default umask and add user to web group so we can share write permission on web files
	sed -i 's/^#umask\s*022/umask 002/' ~/.profile
	echo "umask 002" >> ~/.zshrc
	echo "umask 002" >> ~/.bashrc

	sudo sh -c "cat >> /etc/apache2/sites-available/000-default.conf" <<-EOF
	<Directory /var/www/html>
		AllowOverride All
	</Directory>
	EOF

	# This is how the example codespace changes the docroot. If it's good enough for them, it's good enough for me.
	sudo chmod a+x "$(pwd)" && sudo rm -rf /var/www/html && sudo ln -s "$(pwd)/web" /var/www/html

	# Setup database if MYSQL_HOST = 127.0.0.1
	cat > ~/.my.cnf <<-EOF
	[client]
	host="$MYSQL_HOST"
	user="$MYSQL_USER"
	password="$MYSQL_PASSWORD"
	EOF

	# translate mysql env vars to our template vars
	export DB_HOST="$MYSQL_HOST" DB_PORT="$MYSQL_TCP_PORT" DB_USER="$MYSQL_USER" DB_PASSWORD="$MYSQL_PASSWORD" DB_NAME="$MYSQL_DATABASE"

	# Setup our Drupal app
	composer dev-initialize-local
	cat >> web/sites/default/settings.local.php <<-EOF
	\$settings['trusted_host_patterns'] = [];

	# make drupal play nice with codespace proxy
	\$settings['reverse_proxy'] = TRUE;
	\$settings['reverse_proxy_addresses'] = array(\$_SERVER['REMOTE_ADDR']);
	EOF

	composer install
	composer compile-theme

	# Set file permissions so both httpd and user can write to files
	chgrp www-data web/sites/default/files
	chmod g+s web/sites/default/files

	# Download files
	_terminus_login
	TERMINUS_ENV="dev" terminus backup:get --element=files --to=files.tar.gz
	tar zx --no-same-permissions --strip-components 1 -C web/sites/default/files -f files.tar.gz
	rm files.tar.gz
	# no-same-permissions doesn't seem to work so we fix it here
	sudo find web/sites/default/files -type d -exec chmod g+ws {} +
	sudo find web/sites/default/files -type f -exec chmod g+w {} +

	# The database image might be out of date so deploy any new changes from code
	vendor/bin/drush deploy

	# Setup drush and other vendor binaries
	echo "export PATH=\"`pwd`/vendor/bin:\$PATH\"" | tee -a ~/.bashrc ~/.zshrc ~/.zshrc.local

	# Setup VS Code
	mkdir -p $WORKSPACE_FOLDER/.vscode
	cp /usr/local/share/vscode/* $WORKSPACE_FOLDER/.vscode/

	# Install Claude Code
	sudo npm install -g @anthropic-ai/claude-code

	# Setup shell completion
	uceap completion bash | sudo sh -c "cat > /etc/bash_completion.d/uceap"
	gh completion --shell bash | sudo sh -c "cat > /etc/bash_completion.d/gh"
	uceap completion zsh | sudo sh -c "cat > /usr/local/share/zsh/site-functions/_uceap"
	gh completion --shell zsh | sudo sh -c "cat > /usr/local/share/zsh/site-functions/_gh"
	# Force loading of the completion script because I can't get it to autoload
	echo "autoload -Uz _uceap && compdef _uceap uceap" | tee -a ~/.zshrc ~/.zshrc.local

	# Run local devcontainer lifecycle scripts
	if [ -x .devcontainer/onCreate.sh ]; then
		.devcontainer/onCreate.sh
	fi
}

_devcontainer_on_create_desc='runs when the devcontainer is created'
_devcontainer_on_create_help='
This command implements the `onCreateCommand` lifecycle event for dev containers.

# Usage

Add the following to your `devcontainer.json` file:

``` json
{
	"onCreateCommand": "uceap devcontainer-on-create"
}
```

## Description

This command is the first of three (along with `updateContentCommand` and `postCreateCommand`) that finalizes container setup when a dev container is created. It and subsequent commands execute **inside** the container immediately after it has started for the first time.

Cloud services can use this command when caching or prebuilding a container. This means that it will not typically have access to user-scoped assets or secrets.
'
