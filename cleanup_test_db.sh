#!/bin/bash
echo "stopping  mysql server"
/etc/init.d/mysql stop 1>/dev/null 2>/dev/null
/etc/init.d/redis-server stop
