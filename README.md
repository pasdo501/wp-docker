# WordPress & Docker

WordPress with Docker development. Initially based on the article [found here](https://akrabat.com/developing-wordpress-sites-with-docker/).

## Installation

For first time usage, do the following in the project root directory:
1. Create a `.env` file in the project root (e.g run `cp .env.example .env`)
1. Set your env variables as needed. Note: `Title` refers to the site's title.
1. Run `docker-compose up`
1. Wait for docker to start up
1. Run `bin/wp-config.sh`

**Prerequisits**: You will need to have [docker](https://www.docker.com/) and the [wp cli tool](https://wp-cli.org/) installed.

## Usage

- Start up: `docker-compose up`
- Shut down (if running detached): `docker-compose down`
- Rebuild containers: `docker-compose up --force-recreate --build`
- Delete the db_data volume: `docker-compose down -v`
- Export the database (to `./data/dump.sql`): `./bin/export-db.sh` (make sure export-db has execution permission)
- Restore database: `./bin/restore-db.sh <dump-file-name>` (make sure restore-db has execution permission)
- [WP CLI](https://wp-cli.org/): `./bin/docker-wp.sh [options]`
- Deploy*: Run `bin/deploy.sh <remote-username> <remote-address> <theme-name>` from the root directory. Note that you will first need to run the database export script.

***Caveats**: The deploy script currently has a fairly narrow working range. It'll only transfer a single theme (and there always has to be a theme) and the following needs to be true about your web server:
- Your web server is running Linux
- Your wordpress folder is sitting at /var/www/html
- Wordpress core is already present
- Wordpress' `wp-config.php` file exists, and defines the constants for DB_USER, DB_NAME, and DB_PASSWORD
- Your web user is www-data
- Your web server has the [wp cli tool](https://wp-cli.org/) installed
- Your web server is using mysql

## Todo
- [x] Better (or any, really) error checking in the wp-config script (done-ish)
- [x] Removal of unnecessary themes etc
- [x] Configurable ~~DB_NAME, etc, as well as~~ admin name, email, password
- [x] Add Mailhog
- [ ] Find a better way to handle permissions
- [x] Deploy script
- [ ] Consider su to not use wp as container's root user