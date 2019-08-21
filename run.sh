#!/bin/bash
echo "starting redis"
/etc/init.d/redis-server start

HOST_DOMAIN="host.docker.internal"
ping -q -c1 $HOST_DOMAIN > /dev/null 2>&1
if [ $? -ne 0 ]; then
  HOST_IP=$(ip route | awk 'NR==1 {print $3}')
  echo -e "$HOST_IP\t$HOST_DOMAIN" >> /etc/hosts
fi

#http://unix.stackexchange.com/questions/55558/how-can-i-kill-and-wait-for-background-processes-to-finish-in-a-shell-script-whe
custom()
{
    run 'php-fpm'
    #run 'php' '-S' '0.0.0.0:9002' '-t' '/var/www/htdocs/'
    func()
    {
        local i=0
        while :
        do
            echo "Iter $i"
            let i+=1
            sleep 0.25
        done
    }
    export -f func
}

# [ Setup ]
run()
{
    "$@" &
    # Give process some time to start up so windows are sequential
    sleep 0.05
}
finish()
{
    procs="$(jobs -p)"
    echo "Kill: $procs"
    # Ignore process that are already dead
    kill $procs 2> /dev/null
}
trap 'finish' 2

custom

echo 'Press <Ctrl+C> to kill...'
wait
