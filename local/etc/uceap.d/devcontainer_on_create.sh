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

	# Setup drush and other vendor binaries
	echo "export PATH=\"`pwd`/vendor/bin:\$PATH\"" | tee -a ~/.bashrc ~/.zshrc ~/.zshrc.local

	# Setup VS Code
	mkdir -p $WORKSPACE_FOLDER/.vscode
	cp /usr/local/share/vscode/* $WORKSPACE_FOLDER/.vscode/

	# Run local devcontainer lifecycle scripts
	if [ -x .devcontainer/onCreate.sh ]; then
		.devcontainer/onCreate.sh
	fi
}

_devcontainer_on_create_desc='Runs when the devcontainer is created'
_devcontainer_on_create_help='
This command implements the `onCreateCommand` lifecycle event for dev containers.

This command is the first of three (along with `updateContentCommand` and `postCreateCommand`) that finalizes container setup when a dev container is created. It and subsequent commands execute **inside** the container immediately after it has started for the first time.

Cloud services can use this command when caching or prebuilding a container. This means that it will not typically have access to user-scoped assets or secrets.
'