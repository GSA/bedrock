FROM php:7.0-fpm

ARG WWW_DIR=/var/www

RUN apt-get update && apt-get install -y \
  git \
  libxml2-dev \
  subversion \
  unzip

RUN docker-php-ext-install mysqli
#RUN docker-php-ext-install \
#  dom \
#  mbstring \
#  pdo_mysql

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer

# Copy app
COPY . $WWW_DIR

RUN useradd wp -m


WORKDIR $WWW_DIR

# Install php dependencies
RUN composer install --no-dev


# Install wp cli
USER wp
RUN composer global require wp-cli/wp-cli-bundle \
  && ln -s ~/.composer/vendor/bin/wp /usr/local/bin/wp
