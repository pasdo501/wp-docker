# WordPress & Docker

WordPress with Docker development. Based on the article [found here](https://akrabat.com/developing-wordpress-sites-with-docker/).

## Installation

For first time usage, do the following in the project root directory:
1. Create a `.env` file in the project root (e.g run `cp .env.example .env`)
1. Set your env variables as needed. Note: `Title` referes to the site's title. `LIVE_URL` is not really used properly at the moment
1. Run `docker-compose up`
1. Wait for docker to start up
1. Run `bin/wp-config.sh`

## Usage

- Start up: `docker-compose up`
- Shut down: `docker-compose down`
- Rebuild containers: `docker-compose up --force-recreate --build`
- Delete the db_data volume: `docker-compose down -v`
- Export the database (to `./data/dump.sql`): `./bin/export-db.sh` (make sure export-db has execution permission)
- Restore database: `./bin/restore-db.sh <dump-file-name>` (make sure restore-db has execution permission)

## Todo
- [ ] Better (or any, really) error checking in the wp-config script?
- [x] Removal of unnecessary themes etc
- [ ] Configurable DB_NAME, etc, as well as admin name, email, password
- [x] Add Mailhog
- [ ] Find a better way to handle permissions
- [ ] Deploy script