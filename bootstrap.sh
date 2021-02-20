#!/bin/bash
set -euo pipefail

fail() {
  echo FAIL: "$@"
  exit 1
}

# Truncate the .env file if it already exists
:>$HOME/.env

# We need to set the following variables:

DB_NAME=$(echo $VCAP_SERVICES | jq -r '.["aws-rds"][] | .credentials.db_name')
DB_USER=$(echo $VCAP_SERVICES | jq -r '.["aws-rds"][] | .credentials.username')
DB_PASSWORD=$(echo $VCAP_SERVICES | jq -r '.["aws-rds"][] | .credentials.password')
DB_HOST=$(echo $VCAP_SERVICES | jq -r '.["aws-rds"][] | .credentials.host')
WP_ENV=production

for e in DB_NAME DB_USER DB_PASSWORD DB_HOST WP_ENV; do
  echo "$e=${!e}" >> $HOME/.env
done

uri=$(echo "$VCAP_APPLICATION" | jq -r '.uris[0]')
echo "WP_HOME=$uri" >> $HOME/..env

# This is probably dependent on configuration of server
# WP_SITEURL=https://data.gov/wp

# S3_BUCKET=$(echo $VCAP_SERVICES | jq -r '.["s3"]?[]? | .credentials.bucket')
# S3_ACCESS_KEY_ID=$(echo $VCAP_SERVICES | jq -r '.["s3"]?[]? | .credentials.access_key_id')
# S3_SECRET_ACCESS_KEY=$(echo $VCAP_SERVICES | jq -r '.["s3"]?[]? | .credentials.secret_access_key')
# for e in S3_BUCKET S3_PREFIX S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY; do
#   echo "$e=${!e}" >> $APP_DIR/.env
# done

# DBI_AWS_ACCESS_KEY_ID='{{ env_dbi_aws_access_key_id }}'
# DBI_AWS_SECRET_ACCESS_KEY='{{ env_dbi_aws_secret_access_key }}'

# # Generate your keys here: https://roots.io/salts.html
# Parse the entire secret user-provided service first...
SECRETS=$(echo $VCAP_SERVICES | jq -r '.["user-provided"][] | select(.name == "secrets") | .credentials') ||
  fail "Unable to parse SECRETS from VCAP_SERVICES"
# Now extract all of the necessary key value pairs...
AUTH_KEY=$(echo $SECRETS | jq --exit-status -r '.AUTH_KEY') ||
  fail "Unable to parse AUTH_KEY from SECRETS"
SECURE_AUTH_KEY=$(echo $SECRETS | jq --exit-status -r '.SECURE_AUTH_KEY') ||
  fail "Unable to parse SECURE_AUTH_KEY from SECRETS"
LOGGED_IN_KEY=$(echo $SECRETS | jq --exit-status -r '.LOGGED_IN_KEY') ||
  fail "Unable to parse LOGGED_IN_KEY from SECRETS"
NONCE_KEY=$(echo $SECRETS | jq --exit-status -r '.NONCE_KEY') ||
  fail "Unable to parse NONCE_KEY from SECRETS"
AUTH_SALT=$(echo $SECRETS | jq --exit-status -r '.AUTH_SALT') ||
  fail "Unable to parse AUTH_SALT from SECRETS"
SECURE_AUTH_SALT=$(echo $SECRETS | jq --exit-status -r '.SECURE_AUTH_SALT') ||
  fail "Unable to parse SECURE_AUTH_SALT from SECRETS"
LOGGED_IN_SALT=$(echo $SECRETS | jq --exit-status -r '.LOGGED_IN_SALT') ||
  fail "Unable to parse LOGGED_IN_SALT from SECRETS"
NONCE_SALT=$(echo $SECRETS | jq --exit-status -r '.NONCE_SALT') ||
  fail "Unable to parse NONCE_SALT from SECRETS"

# # We can parse them doing something like the following:
# AUTH_KEY=$(echo $VCAP_SERVICES | jq -r '.["user-provided"][] | select(.name == "secrets") | .credentials') ||
#   fail "Unable to parse SECRETS from VCAP_SERVICES"

for e in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
  echo "$e=${!e}" >> $HOME/..env
done