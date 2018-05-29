# Docker for PHP Development
- Running a container will spawn an nginx at 9000 and a xdebug relay at 9001.
- nginx is running from /var/www/html
- running plain redis on default ports and with default config
- Help https://github.com/wsargent/docker-cheat-sheet
- a mysql tmpfs server to run unit tests against it without io issues

### XDEBUG Forward
```
docker run -d -p 9001:9001 -p 9000:9000 unikrn/php
npm install -g node-tcp-relay
tcprelayc --host localhost --port 9000 --relayHost localhost --relayPort 9001 --numConn 10 
```

### Run 
```
docker run -p 9001:9001 -p 9000:9000 -v /Users/xxxx/php:/var/www/html yyyyyyy
```

### Cheat Sheet
- build locally `docker build -t unikrn/php .`
- tag `docker tag xxx  unikrn/php`
- `docker run -it --entrypoint "/bin/bash" unikrn/php` 
- `docker push unikrn/php`

### TODO
- Make 9002 xcache adm work in the same mem as php-adm.
	Adm you need to run it in php-adm also.
	Dirty workaround for projects inside php-fpm
	```
    $data = $_REQUEST;
    ob_start();
    chdir('/var/www/htdocs/cacher/');
    global $module;
    global $config;
    global $strings;
    if ($data[0] == 'edit') {
        require_once './edit.php';
    } else {
        require_once './index.php';
    }
    $html = ob_get_contents();
    ob_end_clean();
    $html = str_replace('../common','http://localhost:9002/common',$html);
    $html = str_replace('cacher.css','http://localhost:9002/cacher/cacher.css',$html);
    $html = str_replace('.php','',$html);
    echo $html;
     ```

### Credits
- https://github.com/theasci/docker-mysql-tmpfs

