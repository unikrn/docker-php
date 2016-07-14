# Docker for PHP Development
- Running a container will spawn an nginx at 9000 and a xdebug relay at 9001.
- nginx is running from /var/www/html

### XDEBUG Forward
```
docker run -d -p 9001:9001 -p 9000:9000 unikrn/php
npm install -g tcprelayc
tcprelayc --host localhost --port 9000 --relayHost localhost --relayPort 9001 --numConn 10 
```

### Cheat Sheet
- build locally `docker build -t unikrn/php .`
- tag `docker tag xxx  unikrn/php`

# Run 
```
docker run -p 9001:9001 -p 9000:9000 -v /Users/xxxx/php:/var/www/html yyyyyyy
```
