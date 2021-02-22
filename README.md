[![CircleCI](https://circleci.com/gh/GSA/datagov-wp-boilerplate.svg?style=svg)](https://circleci.com/gh/GSA/datagov-wp-boilerplate)

# [Datagov-wp-boilerplate]

WordPress boilerplate based on [Bedrock](https://github.com/roots/bedrock)

Bedrock is a modern WordPress stack that helps you get started with the best development tools and project structure.

Much of the philosophy behind Bedrock is inspired by the [Twelve-Factor App](http://12factor.net/) methodology including the [WordPress specific version](https://roots.io/twelve-factor-wordpress/).

## Updating WP and plugin versions

Updating your WordPress version (or any plugin) is just a matter of changing the version number in the `composer.json` file.

Then running `composer update` will pull down the new version.

## Community

Most of Data.gov discussions happen at [Data.gov github](https://github.com/gsa/data.gov/issues)


## Development

### Prerequisites

- [Docker](https://docs.docker.com/install/) v18+
- [Docker Compose](https://docs.docker.com/compose/) v1.24+

### Setup

Build the docker containers.

    $ make build

Run the docker containers.

    $ make up

Activate all the installed plugins and theme.

    $ make setup

The admin password is in the output of the above command.

Open your browser to [localhost:8000](http://localhost:8000/).

_TODO: initialize the database with seed data so the theme loads properly._

Clean local directories and containers.

    $ make clean


### Update dependencies

Build the containers and run composer update within the container.

    $ make update


### Restoring database dumps

You don't need a database dump for most development tasks. If you need
a database dump, you can create one following instructions from the
[Runbook](https://github.com/GSA/datagov-deploy/wiki/Runbook#wwwdatagov).

Once you have the database dump, you can restore it for your local development
environment.

    $ docker-compose exec -T db mysql -u root -pmysql-dev-password datagov \
      < <(gzip --to-stdout --decompress databasedump.sql.gz)

### Wordpress CLI

Wordpress cli is installed [via composer](https://make.wordpress.org/cli/handbook/guides/installing/#installing-via-composer)

## Admin dashboard

In order to access the admin dashboard for development, you must first disable
saml and update the admin password.

First, deactivate the saml plugin.

    $ docker-compose exec app /var/www/lib/vendor/wp-cli/wp-cli/bin/wp --allow-root plugin deactivate saml-20-single-sign-on

Reset the admin password to `password`.

    $ docker-compose run --rm app /var/www/lib/vendor/wp-cli/wp-cli/bin/wp --allow-root user update admin --user_pass=password

Open the login page
[localhost:8000/wp/wp-login.php](http://localhost:8000/wp/wp-login.php). Login
with the user `admin` password `password`.

## Deployment

In order to deploy to cloud.gov, the following will need to be setup.

Copy `vars.yml.template` to `vars.yml`, and customize the values in that file. Then, assuming you're logged in for the Cloud Foundry CLI:

_For ease of use, you might want to run `export app_name=wordpress`, instead of editing all the next commands._

Create the database used by wordpress.

    $ cf create-service aws-rds small-mysql ${app_name}-db

You have to wait a bit for the DB to be available (see [the cloud.gov instructions on how to know when it's up](https://cloud.gov/docs/services/relational-database/#instance-creation-time)).

Create the s3 bucket for data storage.

    $ cf create-service s3 basic-sandbox ${app_name}-s3

Create the secrets service that will contain various necessary environment secrets (create new ones for a new environment [here](Generate your keys here: https://roots.io/salts.html))

    $ cf cups ${app_name}-secrets -p "AUTH_KEY, SECURE_AUTH_KEY, LOGGED_IN_KEY, NONCE_KEY, AUTH_SALT, SECURE_AUTH_SALT, LOGGED_IN_SALT, NONCE_SALT"

_Note if you need to update the secrets, please see our [wiki](https://github.com/GSA/datagov-deploy/wiki/Cloud.gov-Cheat-Sheet#secrets-management)

Once these are created, start up the app:

    $ cf push --vars-file vars.yml ${app_name}

You will then need to initialize the install:
    $ cf run-task ${app_name} --command "wp core install --title=Data.gov --admin_user=admin --admin_email=admin@example.com --url=<(echo $VCAP_APPLICATION | jq -r '.uris[0]') && wp plugin activate --all && wp theme activate roots-nextdatagov" --name wordpress-init
    