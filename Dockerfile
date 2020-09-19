ARG PHP_VERSION="7.4"
FROM php:${PHP_VERSION}-apache-buster

# set document root by env
ENV APACHE_DOCUMENT_ROOT /var/www/html

# install composer, node and npm
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=node:10.21.0-buster-slim /usr/local /usr/local

# install another bunch of tools we need
RUN apt update && apt install -y \
    telnet traceroute \
    git \
    nano \
    iputils-ping \
    sudo \
    curl \
    zip \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# fix configuration
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN sed -ri -e 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# install some needed php extensions

RUN docker-php-ext-install mysqli pdo_mysql bcmath gd zip

# enable apache mod rewrite
RUN a2enmod rewrite
