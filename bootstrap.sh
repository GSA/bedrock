#!/bin/bash
set -euo pipefail

fail() {
  echo FAIL: "$@"
  exit 1
}

# Truncate the .env file if it already exists
:>$HOME/.env

# We need to set the following variables:

export DB_NAME=$(echo $VCAP_SERVICES | jq -r '.["aws-rds"][] | .credentials.db_name')
export DB_USER=$(echo $VCAP_SERVICES | jq -r '.["aws-rds"][] | .credentials.username')
export DB_PASSWORD=$(echo $VCAP_SERVICES | jq -r '.["aws-rds"][] | .credentials.password')
export DB_HOST=$(echo $VCAP_SERVICES | jq -r '.["aws-rds"][] | .credentials.host')

for e in DB_NAME DB_USER DB_PASSWORD DB_HOST WP_ENV; do
  echo "$e=${!e}" >> $HOME/.env
done

export WP_HOME=https://$(echo "$VCAP_APPLICATION" | jq -r '.uris[0]')
export WP_SITEURL=$WP_HOME/wp
echo "WP_HOME=$WP_HOME" >> $HOME/.env
echo "WP_SITEURL=$WP_SITEURL" >> $HOME/.env

export AWS_BUCKET=$(echo $VCAP_SERVICES | jq -r '.["s3"]?[]? | .credentials.bucket')
export AWS_ACCESS_KEY_ID=$(echo $VCAP_SERVICES | jq -r '.["s3"]?[]? | .credentials.access_key_id')
export AWS_SECRET_ACCESS_KEY=$(echo $VCAP_SERVICES | jq -r '.["s3"]?[]? | .credentials.secret_access_key')
for e in AWS_BUCKET AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; do
  echo "$e=${!e}" >> $HOME/.env
done

# DBI_AWS_ACCESS_KEY_ID='{{ env_dbi_aws_access_key_id }}'
# DBI_AWS_SECRET_ACCESS_KEY='{{ env_dbi_aws_secret_access_key }}'

# # Generate your keys here: https://roots.io/salts.html
# Parse the entire secret user-provided service first...
SECRETS=$(echo $VCAP_SERVICES | jq -r '.["user-provided"][] | select(.name == "wordpress-secrets") | .credentials') ||
  fail "Unable to parse SECRETS from VCAP_SERVICES"
# Now extract all of the necessary key value pairs...
export AUTH_KEY=$(echo $SECRETS | jq --exit-status -r '.AUTH_KEY') ||
  fail "Unable to parse AUTH_KEY from SECRETS"
export SECURE_AUTH_KEY=$(echo $SECRETS | jq --exit-status -r '.SECURE_AUTH_KEY') ||
  fail "Unable to parse SECURE_AUTH_KEY from SECRETS"
export LOGGED_IN_KEY=$(echo $SECRETS | jq --exit-status -r '.LOGGED_IN_KEY') ||
  fail "Unable to parse LOGGED_IN_KEY from SECRETS"
export NONCE_KEY=$(echo $SECRETS | jq --exit-status -r '.NONCE_KEY') ||
  fail "Unable to parse NONCE_KEY from SECRETS"
export AUTH_SALT=$(echo $SECRETS | jq --exit-status -r '.AUTH_SALT') ||
  fail "Unable to parse AUTH_SALT from SECRETS"
export SECURE_AUTH_SALT=$(echo $SECRETS | jq --exit-status -r '.SECURE_AUTH_SALT') ||
  fail "Unable to parse SECURE_AUTH_SALT from SECRETS"
export LOGGED_IN_SALT=$(echo $SECRETS | jq --exit-status -r '.LOGGED_IN_SALT') ||
  fail "Unable to parse LOGGED_IN_SALT from SECRETS"
export NONCE_SALT=$(echo $SECRETS | jq --exit-status -r '.NONCE_SALT') ||
  fail "Unable to parse NONCE_SALT from SECRETS"

for e in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
  echo "$e='${!e}'" >> $HOME/.env
done