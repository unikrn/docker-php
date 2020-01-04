# Docker for PHP Development
- Running a container will spawn an nginx at 9000.
- nginx is running from /var/www/html
- running plain redis on default ports and with default config
- Help https://github.com/wsargent/docker-cheat-sheet
- a mysql tmpfs server to run unit tests against it without io issues
- smaller image - https://www.dropbox.com/s/noro58qlp7ng3by/screenshot_2020-01-04-02%3A06.png?dl=0
-- saves around 100MB
-- no build environment anymore (advantage (?))


### Run 
```
docker run -p 9000:9000 -v /Users/xxxx/php:/var/www/html yyyyyyy

run  with --cap-add SYS_PTRACE for phpspy
```

### Cheat Sheet
- build locally `docker build -t unikrn/php .`
- tag `docker tag xxx  unikrn/php`
- `docker run -it --entrypoint "/bin/bash" unikrn/php` 
- `docker push unikrn/phppoppler-data`
- watch sudo ps -f -g`ps -ef | awk '/\/bin\/sh/{print $2}'` 
- docker run --rm -it --entrypoint=/bin/bash b0172b56c46a 
- docker run --rm -it --cap-add SYS_PTRACE --entrypoint=/bin/bash `docker images | awk '{print $3}' | awk 'NR==2'`
- docker tag `docker images | awk '{print $3}' | awk 'NR==2'`  unikrn/php:php74

### Credits
- https://github.com/theasci/docker-mysql-tmpfs
- https://git.software-sl.de/Docker/Docker-Development/blob/master/Dockerfiles/Php/Dockerfile
- https://github.com/wagoodman/dive
