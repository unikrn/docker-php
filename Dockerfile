FROM php:8.0.0RC5-fpm

ENV TERM=xterm
ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_SERVER_VERSION mysql-5.7
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /home/composer
ENV COMPOSER_PROCESS_TIMEOUT 600

#TODO - autoclean, clean dev libs - not possible atm as different steps

#Possible values for ext-name:
#bcmath bz2 calendar ctype curl dba dom enchant exif ffi fileinfo filter ftp gd gettext gmp hash iconv imap intl json ldap mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer xml xmlreader xmlrpc xmlwriter xsl zend_test zip

# add profiler
ARG INSTALL_PROFILER=true
ARG CLEAN_BINARIES=true

RUN apt-get update && apt-get install -y wget gnupg iputils-ping iproute2 curl \
#RUN 
    && echo deb http://httpredir.debian.org/debian stable main contrib >>/etc/apt/sources.list \
    && echo deb http://security.debian.org/ stable/updates main contrib >>/etc/apt/sources.list \
    && apt-get update && apt-get install -y gnupg \
    && apt-get upgrade -y\
    && curl -sL https://d2buw04m05mirl.cloudfront.net/setup_12.x | sed "s/deb.nodesource.com/d2buw04m05mirl.cloudfront.net/" | sed "s/\(deb\(-src\)\? http\)s/\1/" | bash - \
    && apt-get install -y \
        debian-archive-keyring \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libzip-dev libbz2-dev \
        libgeoip-dev \
        expect-dev \
        libgmp-dev \
        libmagickwand-dev libmagickcore-dev imagemagick \
        libsodium-dev \
        libhiredis-dev \
        python \
        locales \
        nodejs \
        git zip unzip \
        redis-server redis-tools \
        procps nano mc dnsutils \
    && apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5 \
    && curl -fsSL https://unikrn-tools.s3-accelerate.amazonaws.com/docker/mysql-apt-config_0.8.3-1_all.deb -o /tmp/mysql.deb \
        && dpkg -i /tmp/mysql.deb \
        && rm /tmp/mysql.deb\
        && apt-get update && apt-get install -y mysql-community-server \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && mkdir -p /tmp/oniguruma \
        && TMP_ORIG_PATH=$(pwd) \
        && cd /tmp/oniguruma \
        && curl -Ls https://unikrn-tools.s3-accelerate.amazonaws.com/docker/onig-6.9.4.tar.gz | tar xzC /tmp/oniguruma --strip-components=1 \
        && ./configure --prefix=/usr/local \
        && make -j $(nproc) \
        && make install \
        && cd "$TMP_ORIG_PATH" \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli bcmath mbstring bz2 zip gmp soap intl sodium sysvmsg sysvsem sysvshm ffi posix opcache shmop pcntl sockets exif \
    #for https://github.com/maxmind/MaxMind-DB-Reader-php
    && apt-get install software-properties-common -y && add-apt-repository ppa:maxmind/ppa && apt remove --purge software-properties-common -y \
    && apt install libmaxminddb0 libmaxminddb-dev mmdb-bin -y \
    && apt autoremove --purge -y \
    && apt-get upgrade -y\
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#RUN 
    && EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    mkdir /home/composer && \
    curl -s -f -L -o /tmp/composer-setup.php https://getcomposer.org/installer && \
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');") && \
    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then \
        >&2 echo 'ERROR: Invalid installer signature' && \
        rm /tmp/composer-setup.php && \
        exit 1; \
    fi && \
    php /tmp/composer-setup.php --no-ansi --install-dir=/usr/bin --filename=composer && \
    rm -rf /tmp/* /var/tmp/* && \
    composer --ansi --version --no-interaction \
#    && echo hi
#    
#RUN echo hi \
    && pecl install uuid && docker-php-ext-enable uuid \
#
#RUN echo hi\
    && cd /tmp && git clone https://github.com/nrk/phpiredis.git \
    && cd phpiredis && phpize && ./configure --enable-phpiredis \
    && make -j$(nproc) && make install && docker-php-ext-enable phpiredis \
    && cd /tmp && rm -rf /tmp/phpiredis \
#    && echo hi \
#
#RUN echo hi2\
#   && pecl install redis && docker-php-ext-enable redis \
    && cd /tmp && git clone https://github.com/phpredis/phpredis.git \
    && cd phpredis && phpize && ./configure \
    && make -j$(nproc) && make install && docker-php-ext-enable redis \
    && cd /tmp && rm -rf /tmp/phpredis \
#    && echo hi
#
#RUN echo hi3\
    && pecl install apcu && docker-php-ext-enable apcu \
#
#RUN 
    && cd /tmp && git clone https://github.com/xdebug/xdebug.git \
    && cd xdebug && phpize && ./configure \
    && make -j$(nproc) && make install && docker-php-ext-enable xdebug \
    && cd /tmp && rm -rf /tmp/xdebug \
#   && echo hi
#RUN echo hi4 \
    && curl -sS https://unikrn-tools.s3-accelerate.amazonaws.com/docker/g2.tgz | tar -xz -C / \
    && pecl install maxminddb && docker-php-ext-enable maxminddb \
    && echo "<?php \
use MaxMind\Db\Reader; \
\$ipAddress='141.30.225.1';\
\$databaseFile = '/GeoLite2-City.mmdb';\
\$reader = new Reader(\$databaseFile);\
print_r(\$reader->get(\$ipAddress));\
print_r(\$reader->getWithPrefixLen(\$ipAddress));\
\$reader->close();\
     " | php | grep Dresden -cq || (echo "Geo not working" && exit 1) \
#
#RUN 
    && cd /tmp && git clone https://github.com/Imagick/imagick.git \
    && cd imagick && phpize && ./configure \
    && make -j$(nproc) && make install && docker-php-ext-enable imagick \
    && cd /tmp && rm -rf /tmp/imagick \
#
#RUN 
#    
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#
#RUN 
    && if [ "${INSTALL_PROFILER}" = "true" ]; then \
        # install profiler
        TMP_ORIG_PATH=$(pwd) && \
        # build phpspy
        mkdir -p /tmp/phpspy && \
        cd /tmp/phpspy && \
        git clone https://github.com/adsr/phpspy.git . && \
        make && \
        cp ./phpspy /usr/bin/ && \
        chmod +x /usr/bin/phpspy && \
        cd "$TMP_ORIG_PATH" && \
        rm -rf /tmp/*; \
    fi \
    && apt-get remove "*-dev*" binutils cpp libbinutils x11-common  binutils-common cpp-8 libcairo-gobject2 libcairo-script-interpreter2 libcc1-0 libcroco3 -y --purge \
    && if [ "${INSTALL_PROFILER}" = "true" ]; then \
        TMP_ORIG_PATH=$(pwd) && \
        cd /usr/bin/ && rm mysql_embedded myisam* mysqlslap mysqladmin mysqlpump && \
        rm /usr/sbin/mysqld-debug && \
        cd "$TMP_ORIG_PATH" && \
        echo "binaries cleaned"; \
    fi

COPY *.sh /

RUN npm install pm2 -g

#set pm2 config after - faster install, no npm proxy
COPY .npmrc /root

RUN echo "de_DE.UTF-8 UTF-8\nde_DE ISO-8859-1\nde_DE@euro ISO-8859-15\nen_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

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
# -d apc.enable_cli=1
RUN php /tests.php || exit 1

