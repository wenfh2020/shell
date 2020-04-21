#!/bin/bash

cd `dirname $0`
work_path=`pwd`
cd $work_path

cf_file='redis.conf'
cf_threads_file='redis.conf.ths'
cf_un_threads_file='redis.conf.unths'

packs='10 500 1000 5000 10000 50000'
clients='10 50 100 200 500 1000 1500'

persistent_file='dump.rdb'

close_target() {
    ps -ef | grep -i $1 | grep -v grep | awk '{if ($1 > 0) print $2;}' | xargs kill >/dev/null
    _count=`ps -ef | grep -i $1 | grep -v grep | awk '{if ($1 > 0) print $2;}' |wc -l`
    while :
    do
        if [ $_count -ne 0 ]; then
            sleep 2s
            # echo 'retry close again'
            ps -ef | grep -i $1 | grep -v grep | awk '{if ($1 > 0) print $2;}' | xargs kill >/dev/null
            _count=`ps -ef | grep -i $1 | grep -v grep | awk '{if ($1 > 0) print $2;}' |wc -l`
        else
            break
        fi
    done
}

close_server() {
    close_target 'redis-server'
}

start_server() {
    ./src/redis-server $cf_file >/dev/null &
    _pid=`ps -ef | grep -i redis-server | grep -v grep | awk '{if ($1 > 0) print $2;}'`
    # echo "-server pid: $_pid"
}

restart_server_threads() {
    # echo $1
    # reconfig
    if [ "$1" -eq '0' ]; then
        echo '-threads'
        cp $cf_threads_file  $cf_file
    else
        echo '-single'
        cp $cf_un_threads_file  $cf_file
    fi

    close_server
    rm -f $persistent_file
    start_server
}


benchmark_targets() {
    for _target in $*
    do
        echo '---------'
        echo "-$_target"
        for i in 0 1
        do
            restart_server_threads $i
            sleep 2s

            # benchmark
            ./src/redis-benchmark -c 256 -r 1000000 -n 1000000 -t set,get -q --threads 2  -d $_target
        done
    done
}

benchmark_packs() {
    benchmark_targets `echo $packs`
}

benchmark_clents() {
    benchmark_targets `echo $clients`
}

if [ "$1" == '0' ]; then
    echo '-benchmark_packs'
    benchmark_packs
elif [ "$1" == '1' ]; then
    echo '-benchmark_clents'
    benchmark_clents
else
    echo '-benchmark_packs & benchmark_clents'
    echo '------------------------------------'
    echo '-benchmark_packs'
    benchmark_packs
    echo '-benchmark_clents'
    benchmark_clents
fi
