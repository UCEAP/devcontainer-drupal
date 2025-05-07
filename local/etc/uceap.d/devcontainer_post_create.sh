function devcontainer_post_create() {
	# Authenticate to Pantheon iff the user set a token env var
	if [[ -n "$TERMINUS_TOKEN" ]]; then
		terminus -n auth:login --machine-token="$TERMINUS_TOKEN"
	fi

	# Install GitHub CLI Copilot Extension
	if [[ -n "$GH_TOKEN" ]] || [[ -n "$GITHUB_TOKEN" ]] ; then
		gh extension install github/gh-copilot
	fi

	# set global ServerName so that apachectl isn't chatty
	if [[ -n "$CODESPACE_NAME" ]]; then
		SERVER_NAME="$CODESPACE_NAME-8080.app.github.dev"
		HTTP_ADDRESS="$SERVER_NAME"
		HTTP_PROTOCOL="https"
	else
		SERVER_NAME="localhost"
		HTTP_ADDRESS="$SERVER_NAME:8080"
		HTTP_PROTOCOL="http"
	fi
	echo "ServerName $SERVER_NAME" | sudo tee /etc/apache2/conf-available/global-servername.conf
	sudo a2enconf global-servername

	# Setup drush
	mkdir -p drush
	export HTTP_ADDRESS
	export HTTP_PROTOCOL
	build/templater.sh /usr/local/share/drush/example.drush.yml > drush/drush.yml

	# Run local devcontainer lifecycle scripts
	if [ -x .devcontainer/postCreate.sh ]; then
		.devcontainer/postCreate.sh
	fi
}

_devcontainer_post_create_desc="Runs after the devcontainer is created"
_devcontainer_post_create_help="
"