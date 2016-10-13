#!/bin/bash
echo "starting tmpfs mysql server, creating test database"
mkdir /dev/shm/mysql/
cp -R /var/lib/mysql/* /dev/shm/mysql/
chown mysql:mysql -R /dev/shm/mysql/

/etc/init.d/mysql start 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
    echo "db start failed"
    cat /var/log/mysql/error.log
fi
mysql -e "CREATE DATABASE test"
#for some reason the config entry is ignored, workaround
mysql -e 'set global sql_mode=NO_ENGINE_SUBSTITUTION'

