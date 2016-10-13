#!/bin/bash
echo "setting up tmpfs mysql server, creating test database"
mysql_install_db --datadir /dev/shm/mysql
/etc/init.d/mysql start
mysql -e "CREATE DATABASE test"
#for some reason the config entry is ignored, workaround
mysql -e 'set global sql_mode=NO_ENGINE_SUBSTITUTION'

