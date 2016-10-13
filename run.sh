#!/bin/bash
echo "starting redis"
/etc/init.d/redis-server start

#http://unix.stackexchange.com/questions/55558/how-can-i-kill-and-wait-for-background-processes-to-finish-in-a-shell-script-whe
custom()
{
    run 'tcprelays' '--relayPort' '9001' '--servicePort' '8000'
    run 'php-fpm'
    run 'php' '-S' '0.0.0.0:9002' '-t' '/var/www/htdocs/'
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
