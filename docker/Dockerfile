FROM php:7.3.10-fpm

ARG WWW_DIR=/var/www

RUN apt-get update && apt-get install -y \
  git \
  libxml2-dev \
  subversion \
  unzip \
  wget

RUN docker-php-ext-install mysqli
#RUN docker-php-ext-install \
#  dom \
#  mbstring \
#  pdo_mysql

# Install composer
COPY docker/install-composer.sh /tmp/
RUN /tmp/install-composer.sh

# Install php dependencies
COPY composer.json $WWW_DIR
COPY composer.lock $WWW_DIR
# Use COMPOSER_PROCESS_TIMEOUT to avoid timing out on the slow subversion
# checkout for outdated packages. See
# https://github.com/GSA/datagov-deploy/issues/612#issuecomment-508871678
RUN cd $WWW_DIR && COMPOSER_PROCESS_TIMEOUT=600 composer install --no-dev

# Make the wp CLI available
RUN ln -s /var/www/vendor/wp-cli/wp-cli/bin/wp /usr/bin/wp

WORKDIR $WWW_DIR
