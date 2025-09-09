FROM mcr.microsoft.com/devcontainers/php:8.3

# Change default umask and add user to web group so we can share write permission on web files
RUN sed -i 's/^UMASK\s*022/UMASK 002/' /etc/login.defs
RUN usermod -aG www-data vscode

# Add glow for formatting command usage output (and because it's just nice)
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list

# Install MariaDB and Redis and PHP (incl Apache) and Cypress dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y libpng-dev libzip-dev libicu-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql intl \
    && docker-php-ext-configure gd \
    && docker-php-ext-install gd \
    && pecl install redis zip \
    && docker-php-ext-enable redis zip \
    && apt-get install -y mariadb-client redis-tools mkdocs-material mkdocs-material-extensions \
    && apt-get install -y npm libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
    && apt-get install -y dnsutils glow pv \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Configure PHP, make memory_limit and upload_max_filesize match Pantheon
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /usr/local/etc/php/php.ini \
    && sed -i 's/;max_input_vars\s*=.*/max_input_vars=10000/g' /usr/local/etc/php/php.ini \
    && sed -i 's/post_max_size\s*=.*/post_max_size=100M/g' /usr/local/etc/php/php.ini \
    && sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=100M/g' /usr/local/etc/php/php.ini \
    && sed -i 's/variables_order\s*=.*/variables_order="EGPCS"/g' /usr/local/etc/php/php.ini

# Stop xdebug from spamming the console
RUN echo 'xdebug.log_level = 0' >> /usr/local/etc/php/conf.d/xdebug.ini

# Only use higher port for Apache, so that port forwarding is more consistent.
RUN sed -i 's/Listen\s*80$/# Listen 80/' /etc/apache2/ports.conf

# Enable Apache modules
RUN a2enmod expires headers rewrite

# Install terminus
RUN curl -L https://github.com/pantheon-systems/terminus/releases/latest/download/terminus.phar --output /usr/local/bin/terminus \
  && chmod +x /usr/local/bin/terminus \
	&& terminus self:plugin:install terminus-secrets-manager-plugin

# Install 1password-cli, see https://developer.1password.com/docs/cli/get-started/
RUN curl -sS https://downloads.1password.com/linux/keys/1password.asc \
  | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" \
	| tee /etc/apt/sources.list.d/1password.list \
	&& mkdir -p /etc/debsig/policies/AC2D62742012EA22/ \
	&& curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
	| tee /etc/debsig/policies/AC2D62742012EA22/1password.pol \
	&& mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 \
	&& curl -sS https://downloads.1password.com/linux/keys/1password.asc \
	| gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg \
	&& apt update && apt install 1password-cli

# Install starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Install atuin
#
# # The recommended way to install atuin is to use cargo, but that takes *forever*:
# USER vscode
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# RUN PATH="$HOME/.cargo/bin:$PATH" cargo install atuin
#
# # So instead we download the latest precompiled binary for our cpu architecture:
RUN curl -sL $(curl -s https://api.github.com/repos/atuinsh/atuin/releases/latest | jq -r '.assets[] | select(.name == "atuin-'`uname -m`'-unknown-linux-gnu.tar.gz") | .browser_download_url') | tar zx --no-same-owner --wildcards --absolute-names --transform 's,[^/]*,/usr/local/bin,' '*/atuin'

# Our base image has an ancient version of gh cli in apt, so we download the latest version instead
RUN curl -sL $(curl -s https://api.github.com/repos/cli/cli/releases/latest | jq -r '.assets[] | select(.name | endswith("_linux_'`uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/`'.tar.gz")) | .browser_download_url') | tar zx --no-same-owner --wildcards --absolute-names --transform 's,[^/]*,/usr/local,' '*/gh'

# Copy our scripts and template files
COPY local /usr/local/
