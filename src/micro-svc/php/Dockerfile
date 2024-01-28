#FROM php:8.2-fpm-alpine
FROM php:8.3.2-fpm-alpine3.19

RUN apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS \
        && pecl install apcu \
        && docker-php-ext-enable apcu \
        && pecl clear-cache \
        && apk del .build-dependencies

ADD api.php /var/www/html
