FROM php:7.3-fpm

ENV TERM=xterm
ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_SERVER_VERSION mysql-5.7

#Possible values for ext-name:
#bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl json ldap mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zend_test zip

RUN apt-get update && apt-get install -y wget gnupg iputils-ping iproute2 curl
RUN echo deb http://httpredir.debian.org/debian stable main contrib >>/etc/apt/sources.list \
    && echo deb http://security.debian.org/ stable/updates main contrib >>/etc/apt/sources.list \
    && apt-get update && apt-get install -y gnupg \
    && curl -sL https://d2buw04m05mirl.cloudfront.net/setup_11.x | sed "s/deb.nodesource.com/d2buw04m05mirl.cloudfront.net/" | sed "s/\(deb\(-src\)\? http\)s/\1/" | bash - \
    && apt-get install -y \
        debian-archive-keyring \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libmagickwand-dev libmagickcore-dev imagemagick \
        zlib1g-dev \
        libzip-dev \
        libgeoip-dev \
        python \
        locales \
        expect-dev \
        nodejs \
        libgmp-dev \
        git\
        redis-server redis-tools \
        procps nano mc\
    && apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5 \
    && curl -fsSL https://dev.mysql.com/get/mysql-apt-config_0.8.3-1_all.deb -o /tmp/mysql.deb \
    && dpkg -i /tmp/mysql.deb \
    && rm /tmp/mysql.deb\
    && apt-get update && apt-get install -y mysql-community-server \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli bcmath mbstring zip gmp soap intl\
    && apt-get upgrade -y\
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://unikrn-tools.s3.amazonaws.com/docker/geo.tgz | tar -xz -C /

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN pecl install apcu apcu_bc-beta && docker-php-ext-enable apcu  && docker-php-ext-enable apc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl install xdebug-beta && docker-php-ext-enable xdebug \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -rf /usr/share/GeoIP && ln -s /var/lib/geoip-database-contrib /usr/share/GeoIP \
    && update-alternatives --install /usr/share/GeoIP/GeoIPCity.dat GeoIPCity.dat /usr/share/GeoIP/GeoLiteCity.dat 50 \
    && pecl install geoip-beta && docker-php-ext-enable geoip \
    && echo "<?php var_dump(geoip_record_by_name('141.30.225.1')); " | php  | grep Dresden -cq || (echo "Geo not working" && exit 1) \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl install imagick && docker-php-ext-enable imagick \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY *.sh /
COPY .npmrc /root

RUN npm install pm2 -g

RUN echo -e "de_DE.UTF-8 UTF-8\nde_DE ISO-8859-1\nde_DE@euro ISO-8859-15\nen_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8


RUN mv /usr/local/etc/php/conf.d/docker-php-ext-apc.ini /usr/local/etc/php/conf.d/zz-docker-php-ext-apc.ini

VOLUME /var/lib/redis

EXPOSE 9000 6379

ADD zzz-unikrn-fpm.conf /usr/local/etc/php-fpm.d/
ADD unikrn-php.ini /usr/local/etc/php/conf.d/
ADD unikrn-xdebug.ini /usr/local/etc/php/conf.d/
ADD mysql-tmpfs.cnf /etc/mysql/mysql.conf.d/zzz-mysql-tmpfs.cnf
RUN chmod go-w /etc/mysql/mysql.conf.d/zzz-mysql-tmpfs.cnf && chown mysql /etc/mysql/mysql.conf.d/zzz-mysql-tmpfs.cnf

ENTRYPOINT [ "/run.sh" ]

#check APC caching and potentially other things
COPY tests.php / 
RUN php -d apc.enable_cli=1 /tests.php || exit 1

