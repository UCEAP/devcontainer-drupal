FROM mcr.microsoft.com/devcontainers/php:8.2

# Change default umask and add user to web group so we can share write permission on web files
RUN sed -i 's/^UMASK\s*022/UMASK 002/' /etc/login.defs
RUN usermod -aG www-data vscode

# Install MariaDB and Redis and PHP (incl Apache)
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y libpng-dev libzip-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-configure gd \
    && docker-php-ext-install gd \
    && pecl install redis zip \
    && docker-php-ext-enable redis zip \
    && apt-get install -y mariadb-server mariadb-client redis-server redis-tools \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Configure PHP, make memory_limit and upload_max_filesize match Pantheon
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -i 's/memory_limit\s*=.*/memory_limit=2048M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=100M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=100M/g' /usr/local/etc/php/php.ini

# Stop xdebug from spamming the console
RUN echo 'xdebug.log_level = 0' >> /usr/local/etc/php/conf.d/xdebug.ini

# Only use higher port for Apache, so that port forwarding is more consistent.
RUN sed -i 's/Listen\s*80$/# Listen 80/' /etc/apache2/ports.conf

# Install drush
RUN curl -L https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar --output /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

# Install terminus
RUN curl -L https://github.com/pantheon-systems/terminus/releases/latest/download/terminus.phar --output /usr/local/bin/terminus
RUN chmod +x /usr/local/bin/terminus
