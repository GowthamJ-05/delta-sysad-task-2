FROM php:8.3-apache-bookworm

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
docker-php-ext-install mysqli pdo pdo_mysql && \
docker-php-ext-enable mysqli pdo pdo_mysql

COPY ./www /var/www/html

WORKDIR /var/www/html/

EXPOSE 80

CMD ["apache2-foreground"]



