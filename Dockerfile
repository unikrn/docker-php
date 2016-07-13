FROM php:5.5-fpm

RUN echo deb http://httpredir.debian.org/debian stable main contrib >/etc/apt/sources.list \
    && DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev \
        libgeoip-dev \
        python \
        nodejs \
        npm \
        geoip-bin geoip-database-contrib \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysql mysqli bcmath mbstring zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
    && mkdir -p xcache \
    && tar -xf xcache.tar.gz -C xcache --strip-components=1 \
    && rm xcache.tar.gz \
    && ( \
        cd xcache \
        && cp -vr htdocs /var/www/ \
        && phpize \
        && ./configure --enable-xcache \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r xcache \
    && docker-php-ext-enable xcache

RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN pecl install geoip && docker-php-ext-enable geoip \
    && echo "<?php var_dump(geoip_record_by_name('141.30.225.1')); " | php  | grep Dresden -cq || (echo "Geo not working" && exit 1)

RUN ln -s /usr/bin/nodejs /usr/bin/node \
    && npm install node-tcp-relay pm2 less grunt gulp -g

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9000
EXPOSE 9001
EXPOSE 9002

ADD zzz-unikrn-fpm.conf /usr/local/etc/php-fpm.d/
ADD unikrn-php.ini /usr/local/etc/php/conf.d/
ADD unikrn-xdebug.ini /usr/local/etc/php/conf.d/

COPY run.sh /run.sh
COPY install_tools.sh /install_tools.sh

RUN chmod u+rwx /*.sh

ENTRYPOINT [ "/run.sh" ]

