FROM php:5.5-fpm

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev \
        python \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mysql mysqli bcmath mbstring zip

RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
    && mkdir -p xcache \
    && tar -xf xcache.tar.gz -C xcache --strip-components=1 \
    && rm xcache.tar.gz \
    && ( \
        cd xcache \
        && phpize \
        && ./configure --enable-xcache \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r xcache \
    && docker-php-ext-enable xcache

#optional
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD unikrn-php.ini /usr/local/etc/php/conf.d/
ADD zzz-unikrn-fpm.conf /usr/local/etc/php-fpm.d/

RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
    && mkdir -p xcache \
    && tar -xf xcache.tar.gz -C xcache --strip-components=1 \
    && rm xcache.tar.gz \
    && ( \
        cd xcache \
        && phpize \
        && ./configure --enable-xcache \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r xcache \
    && docker-php-ext-enable xcache

RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
ADD unikrn-xdebug.ini /usr/local/etc/php/conf.d/

RUN curl -fsSL 'http://downloads.activestate.com/Komodo/releases/10.0.1/remotedebugging/Komodo-PythonRemoteDebugging-10.0.1-89237-linux-x86_64.tar.gz' -o pdebug.tar.gz \
    && mkdir -p pdebug \
    && tar -xf pdebug.tar.gz -C pdebug --strip-components=1 \
    && rm pdebug.tar.gz \
        && ( \
        cd pdebug \
        && echo "copy pydbgp" \
        && cp -rv pythonlib/* /usr/lib/python2.7/  \
        && cp -v pydbgp /usr/bin/ \
        && cp -v pydbgpproxy /usr/bin/ \
    ) \
    && rm -r pdebug


RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


EXPOSE 9000
EXPOSE 9001

COPY run.sh /run.sh
RUN chmod u+rwx /run.sh

ENTRYPOINT [ "/run.sh" ]

