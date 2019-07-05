#!/bin/sh

composer install --no-dev
exec "$@"
