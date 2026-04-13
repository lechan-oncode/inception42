#!/bin/bash
WP_PATH="/var/www/html"
SITE_URL="https://lechan.42.fr"
DB_NAME="${WORDPRESS_DB_NAME:-${MYSQL_DATABASE}}"
DB_USER="${WORDPRESS_DB_USER:-${MYSQL_USER}}"
DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-${MYSQL_PASSWORD}}"
DB_HOST="${WORDPRESS_DB_HOST:-mariadb}"

# Don't start WordPress setup until MariaDB is ready
# mysqladmin ping - Try to connect to database
# -h"mariadb" - Connect to host named "mariadb" (container name)
# ${MYSQL_ROOT_PASSWORD} - Read password from environment variable
# sleep 1 - Wait 1 second between attempts
while ! mysqladmin ping -h"mariadb" -u"root" --password="${MYSQL_ROOT_PASSWORD}" --silent; do
    sleep 1
done

# Install WP-CLI (WP-CLI = Tool to manage WordPress from terminal)
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
chmod +x /usr/local/bin/wp

# If the shared volume was seeded with a default page, initialize WordPress core files.
if [ ! -f "${WP_PATH}/wp-load.php" ]; then
    rm -f "${WP_PATH}/index.html" "${WP_PATH}/index.nginx-debian.html"
    wp core download --path="${WP_PATH}" --allow-root
fi

#  if [ ! -f ... ] - If config file DOESN'T exist (first run only)
# Create wp-config.php (WordPress configuration file)
# Sets database connection details
if [ ! -f ${WP_PATH}/wp-config.php ]; then
    wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" \
        --path="${WP_PATH}" \
        --allow-root

    # Install WordPress (create database tables, set up site)
    # Create admin account with username "hheng"
    # Site title: "Inception"
    # Only runs once (protected by the if check)    
    wp core install \
        --url="${SITE_URL}" \
        --title="Inception" \
        --admin_user="lechan" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="admin@lechan.42.fr" \
        --path="${WP_PATH}" \
        --allow-root
fi

wp core is-installed --path="${WP_PATH}" --allow-root && wp option update home "${SITE_URL}" --path="${WP_PATH}" --allow-root && wp option update siteurl "${SITE_URL}" --path="${WP_PATH}" --allow-root

# Create second user with author role (can write posts but not admin)
    if ! wp user get wpuser2 --path="${WP_PATH}" --allow-root > /dev/null 2>&1; then
    wp user create wpuser2 user@lechan.42.fr \
        --role=author \
        --user_pass="${DB_PASSWORD}" \
        --path="${WP_PATH}" \
        --allow-root
fi

# Give ownership of all WordPress files to web server user (so PHP-FPM can read/write them)
    chown -R www-data:www-data "${WP_PATH}"


# Nginx and wordpress currently run in different containers
# PHP-FPM (in WordPress container) listens on port 9000 for PHP requests
# unix socket (default) only works within same container. Cannot cross containers communication
# change PHP-FPM to listen on port 9000 instead
# in nginx.conf, we set fastcgi_pass to wordpress:9000

# Nginx sends to: wordpress:9000 ➡️
# PHP-FPM listens on: 9000 ✅
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
sed -i "s|listen = .*|listen = 9000|" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

#exec "$@" - Execute the CMD from Dockerfile
exec "$@"