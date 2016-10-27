FROM php:7-fpm

RUN curl -sL http://www.debian.or.jp/using/apt/sources.list.http.ftp.jp.debian.org > /etc/apt/sources.list \
  && apt-get update

RUN apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    mysql-client

RUN docker-php-ext-install -j$(nproc) \
    curl \
    dom \
    mbstring \
    mcrypt \
    mysqli \
    simplexml \
    zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

VOLUME ["/var/run/php-fpm"]

RUN mkdir /usr/src/php/
RUN mkdir /usr/src/php/ext/

# xdebug
RUN curl -L http://pecl.php.net/get/xdebug-2.4.1.tgz >> /usr/src/php/ext/xdebug.tgz
RUN tar -xf /usr/src/php/ext/xdebug.tgz -C /usr/src/php/ext/
RUN rm /usr/src/php/ext/xdebug.tgz
RUN docker-php-ext-install xdebug-2.4.1
RUN docker-php-ext-install pcntl

# phpredis
ENV PHPREDIS_VERSION php7

RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis