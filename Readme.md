# Docker for PHP Development
- Running a container will spawn an nginx at 9000.
- nginx is running from /var/www/html
- running plain redis on default ports and with default config
- Help https://github.com/wsargent/docker-cheat-sheet
- a mysql tmpfs server to run unit tests against it without io issues


### Run 
```
docker run -p 9000:9000 -v /Users/xxxx/php:/var/www/html yyyyyyy
```

### Cheat Sheet
- build locally `docker build -t unikrn/php .`
- tag `docker tag xxx  unikrn/php`
- `docker run -it --entrypoint "/bin/bash" unikrn/php` 
- `docker push unikrn/php`

### Credits
- https://github.com/theasci/docker-mysql-tmpfs

