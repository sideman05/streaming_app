FROM php:8.2-apache

RUN docker-php-ext-install pdo pdo_mysql \
    && a2enmod rewrite headers

COPY backend/apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY backend /var/www/html

WORKDIR /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
