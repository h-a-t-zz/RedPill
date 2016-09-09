FROM php:5.0-apache
RUN apt-get update && apt-get install -y php5-mysql
COPY src/php/ /var/www/html/
