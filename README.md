[![CircleCI](https://circleci.com/gh/GSA/datagov-wp-boilerplate.svg?style=svg)](https://circleci.com/gh/GSA/datagov-wp-boilerplate)

# [Datagov-wp-boilerplate]

WordPress boilerplate based on [Bedrock](https://github.com/roots/bedrock)

Bedrock is a modern WordPress stack that helps you get started with the best development tools and project structure.

Much of the philosophy behind Bedrock is inspired by the [Twelve-Factor App](http://12factor.net/) methodology including the [WordPress specific version](https://roots.io/twelve-factor-wordpress/).


## Community

Most of Data.gov discussions happen at [Data.gov github](https://github.com/gsa/data.gov/issues)


## Development

### Prerequisites

- [Docker](https://docs.docker.com/install/) v18+
- [Docker Compose](https://docs.docker.com/compose/)

### Setup

Build the docker containers.

    $ docker-compose build

Run the docker containers.

    $ docker-compose up

Activate all the installed plugins and theme.

    $ docker-compose exec app wp core install --url=http://localhost:8000 --title=Data.gov --admin_user=admin --admin_email=admin@example.com --allow-root
    $ docker-compose exec app wp plugin activate --all --allow-root
    $ docker-compose exec app wp theme activate roots-nextdatagov --allow-root

Open your browser to [localhost:8000](http://localhost:8000/).


### Updating WP and plugin versions

Updating your WordPress version (or any plugin) is just a matter of changing the version number in the `composer.json` file.

Then running `composer update` will pull down the new version. Run
docker-compose in "local" mode so changes persist to your local filesystem.

    $ docker-compose -f docker-compose.yml -f docker-compose.local.yml run --rm app composer update

Rebuild the docker images with updated dependencies.

    $ docker-compose build

Commit the updated `composer.json` and `composer.lock` to version control.
