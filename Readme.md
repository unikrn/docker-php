# Docker for PHP Development
- Running a container will spawn an nginx at 9000.
- nginx is running from /var/www/html
- running plain redis on default ports and with default config
- Help https://github.com/wsargent/docker-cheat-sheet
- a mysql tmpfs server to run unit tests against it without io issues


### Run 
```
docker run -p 9000:9000 -v /Users/xxxx/php:/var/www/html yyyyyyy

run  with --cap-add SYS_PTRACE for phpspy
```

### Cheat Sheet
- build locally `docker build -t unikrn/php .`
- tag `docker tag xxx  unikrn/php`
- `docker run -it --entrypoint "/bin/bash" unikrn/php` 
- `docker push unikrn/php`
- watch sudo ps -f -g`ps -ef | awk '/\/bin\/sh/{print $2}'` 
- docker run --rm -it --entrypoint=/bin/bash b0172b56c46a 
- docker run --rm -it --entrypoint=/bin/bash `docker images | awk '{print $3}' | awk 'NR==2'`

### Credits
- https://github.com/theasci/docker-mysql-tmpfs
- https://git.software-sl.de/Docker/Docker-Development/blob/master/Dockerfiles/Php/Dockerfile
