FROM php:7.1-fpm-stretch

ENV WP_ENV=production

WORKDIR /var/www

# Install OS dependencies
RUN apt-get update && apt-get install -y \
    git \
    libxml2-dev \
    subversion \
    unzip

# Instal php extensions
RUN docker-php-ext-install \
    dom \
    mbstring \
    mysqli \
    simplexml

# Install composer
RUN cd /tmp \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

# Setup /var/www with app code
COPY . /var/www/

RUN [ "$WP_ENV" = "production" ] && composer_flags=--no-dev; \
  composer install $composer_flags
