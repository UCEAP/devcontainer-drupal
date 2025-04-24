FROM mcr.microsoft.com/devcontainers/php:8.3

# Change default umask and add user to web group so we can share write permission on web files
RUN sed -i 's/^UMASK\s*022/UMASK 002/' /etc/login.defs
RUN usermod -aG www-data vscode

# Install MariaDB and Redis and PHP (incl Apache) and Cypress dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y libpng-dev libzip-dev libicu-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql intl \
    && docker-php-ext-configure gd \
    && docker-php-ext-install gd \
    && pecl install redis zip \
    && docker-php-ext-enable redis zip \
    && apt-get install -y mariadb-client redis-tools \
    && apt-get install -y npm libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Configure PHP, make memory_limit and upload_max_filesize match Pantheon
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=100M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=100M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/variables_order\s*=.*/variables_order="EGPCS"/g' /usr/local/etc/php/php.ini

# Stop xdebug from spamming the console
RUN echo 'xdebug.log_level = 0' >> /usr/local/etc/php/conf.d/xdebug.ini

# Only use higher port for Apache, so that port forwarding is more consistent.
RUN sed -i 's/Listen\s*80$/# Listen 80/' /etc/apache2/ports.conf

# Install terminus
RUN curl -L https://github.com/pantheon-systems/terminus/releases/latest/download/terminus.phar --output /usr/local/bin/terminus
RUN chmod +x /usr/local/bin/terminus

# Copy devcontainer scripts
COPY uceap-drupal-dev-* /usr/local/bin/
RUN mkdir -p /usr/local/etc/uceap-dev
COPY example.drush.yml /usr/local/etc/uceap-dev
COPY vscode-*.json /usr/local/etc/uceap-dev

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
