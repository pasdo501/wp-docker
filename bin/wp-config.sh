#!/usr/bin/env bash
cd $(dirname $0)
cd ../app

# Parse .env file, make sure all the variables are set
[ -f ../.env ] || { echo "No .env file created. Exiting ..."; exit 1; }
DEV_URL=$(grep -oP '^DEV_URL=\K.*' ../.env)
LIVE_URL=$(grep -oP '^LIVE_URL=\K.*' ../.env)
TITLE=$(grep -oP '^TITLE=\K.*' ../.env)
ADMIN_NAME=$(grep -oP '^ADMIN_NAME=\K.*' ../.env)
ADMIN_PASSWORD=$(grep -oP '^ADMIN_PASSWORD=\K.*' ../.env)
ADMIN_EMAIL=$(grep -oP '^ADMIN_EMAIL=\K.*' ../.env)
[ -z "$DEV_URL" ] && { echo "DEV_URL not set in .env, exiting ..."; exit 1; }
[ -z "$LIVE_URL" ] && { echo "LIVE_URL not set in .env, exiting ..."; exit 1; }
[ -z "$TITLE" ] && { echo "TITLE not set in .env, exiting ..."; exit 1; }
[ -z "$ADMIN_NAME" ] && { echo "ADMIN_NAME not set in .env, exiting ..."; exit 1; }
[ -z "$ADMIN_PASSWORD" ] && { echo "ADMIN_PASSWORD not set in .env, exiting ..."; exit 1; }
[ -z "$ADMIN_EMAIL" ] && { echo "ADMIN_EMAIL not set in .env, exiting ..."; exit 1; }

echo 'Downloading WP-Core ...'
wp core download
echo 'Configuring WordPress ...'
wp config create \
    --dbname="DB_NAME_REPLACE" \
    --dbuser="DB_USER_REPLACE" \
    --dbpass="DB_PASS_REPLACE" \
    --dbhost="DB_HOST_REPLACE" \
    --dbcharset="utf8mb4" \
    --skip-check --extra-php <<PHP
define('WB_DEBUG', (bool) (\$_ENV['WP_DEBUG'] ?? false ));
define('WP_DEBUG_LOG', (bool) (\$_ENV['WP_DEBUG'] ?? false ));
PHP
sed -i \
    -e "s/'DB_NAME_REPLACE'/\$_SERVER\['DB_NAME'\] \?\? \$_ENV\['DB_NAME'\] \?\? null/g" \
    -e "s/'DB_USER_REPLACE'/\$_SERVER\['DB_USER'\] \?\? \$_ENV\['DB_USER'\] \?\? null/g" \
    -e "s/'DB_PASS_REPLACE'/\$_SERVER\['DB_PASSWORD'\] \?\? \$_ENV\['DB_PASSWORD'\] \?\? null/g" \
    -e "s/'DB_HOST_REPLACE'/\$_SERVER\['DB_HOST'\] \?\? \$_ENV\['DB_HOST'\] \?\? null/g" \
    wp-config.php

cd .. # Return to root app for docker environment file purposes
# Install DB Core
echo "Installing WordPress ..."

cmd="wp --allow-root core install --url="$DEV_URL" --title="$TITLE" --admin_user="$ADMIN_NAME" --admin_email="$ADMIN_EMAIL" --admin_password="$ADMIN_PASSWORD" --skip-email"
docker exec -i $(docker-compose ps -q wp) sh -c "$cmd" && echo "Success." || echo "Error during WP Core Install"

# Take control of the directory?
sudo chown -R $USER:$USER ./app

# Get rid of unnecessary themes / plugins
rm -f ./app/wp-content/hello.php
rm -rf ./app/wp-content/themes/{twentysixteen,twentyseventeen}

echo "Checking DB Connection ..."
# Check DB Connection
cmd='wp --allow-root db check'
docker exec -i $(docker-compose ps -q wp) sh -c "$cmd"

echo "WordPress successfully configured. Visit $DEV_URL and start developing!"