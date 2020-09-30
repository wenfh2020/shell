#!/bin/sh
# https://wenfh2020.com/2020/09/27/sentinel-failover/

work_path=$(dirname $0)
cd $work_path
work_path=$(pwd)

kill_redis() {
    # kill old pids
    pids=$(ps -ef | grep redis | grep -v grep | awk '{print $2}')
    for p in $pids; do
        echo "kill $p"
        kill $p
    done
    sleep 1
}

kill_redis_server() {
    ps -ef | grep redis-server | grep $1 | awk '{print $2}' | xargs kill
}

redis_info() {
    echo '-----------'
    echo 'result:'
    ps -ef | grep $1 | grep -v grep | awk '{print $8 " " $9}'
}

shutdown_redis() {
    echo '-----------'
    echo "shut down master - $1"
    echo 'shutdown' | ../client/redis-cli -p $1
    sleep 1
}

start_redis() {
    echo '-----------'
    echo 'start redis:'

    cd $work_path/master
    ./redis-server redis.conf 2>&1 &
    sleep 1

    cd ../slave
    ./redis-server redis.conf 2>&1 &
    sleep 1

    cd ../slave2
    ./redis-server redis.conf 2>&1 &

    echo 'slaveof no one' | ../client/redis-cli -p 6379
    echo 'slaveof 127.0.0.1 6379' | ../client/redis-cli -p 6378
    echo 'slaveof 127.0.0.1 6379' | ../client/redis-cli -p 6377
    sleep 1
}

start_sentinels() {
    echo '-----------'
    echo 'start sentinels:'

    cd $work_path/sentinel
    rm -f sentinel.log
    ./redis-sentinel sentinel.conf 2>&1 &
    sleep 1

    cd ../sentinel2
    rm -f sentinel.log
    ./redis-sentinel sentinel.conf 2>&1 &
    sleep 1

    cd ../sentinel3
    rm -f sentinel.log
    ./redis-sentinel sentinel.conf 2>&1 &
    sleep 1
}

remaster() {
    echo '-----------'
    echo "remaster to $1:"
    echo 'sentinel remove mymaster' | ../client/redis-cli -p 26379
    echo 'sentinel remove mymaster' | ../client/redis-cli -p 26378
    echo 'sentinel remove mymaster' | ../client/redis-cli -p 26377

    # reset monitor info.
    echo "sentinel monitor mymaster 127.0.0.1 $1 2" | ../client/redis-cli -p 26379
    echo "sentinel monitor mymaster 127.0.0.1 $1 2" | ../client/redis-cli -p 26378
    echo "sentinel monitor mymaster 127.0.0.1 $1 2" | ../client/redis-cli -p 26377

    # failover-timeout.
    echo 'sentinel set mymaster failover-timeout 10000' | ../client/redis-cli -p 26379
    echo 'sentinel set mymaster failover-timeout 10000' | ../client/redis-cli -p 26378
    echo 'sentinel set mymaster failover-timeout 10000' | ../client/redis-cli -p 26377

    echo "sentinel flushconfig" | ../client/redis-cli -p 26379
    echo "sentinel flushconfig" | ../client/redis-cli -p 26378
    echo "sentinel flushconfig" | ../client/redis-cli -p 26377

    if [ $1 -eq 6379 ]; then
        echo 'slaveof no one' | ../client/redis-cli -p 6379
        echo "slaveof 127.0.0.1 $1" | ../client/redis-cli -p 6378
        echo "slaveof 127.0.0.1 $1" | ../client/redis-cli -p 6377
    elif [ $1 -eq 6378 ]; then
        echo 'slaveof no one' | ../client/redis-cli -p 6378
        echo "slaveof 127.0.0.1 $1" | ../client/redis-cli -p 6379
        echo "slaveof 127.0.0.1 $1" | ../client/redis-cli -p 6377
    elif [ $1 -eq 6377 ]; then
        echo 'slaveof no one' | ../client/redis-cli -p 6377
        echo "slaveof 127.0.0.1 $1" | ../client/redis-cli -p 6379
        echo "slaveof 127.0.0.1 $1" | ../client/redis-cli -p 6378
    else
        echo "invalid redis port $1"
        exit 1
    fi
    sleep 1
}

remaster_redis() {
    echo '-----------'
    echo "remaster_redis $1:"
    cd $work_path/master
    ./redis-server redis.conf 2>&1 &
    sleep 1
    echo "slaveof no one" | ../client/redis-cli -p $1
    echo "config rewrite" | ../client/redis-cli -p $1
}

get_master_info_from_sentinel() {
    echo '-----------'
    echo 'master info:'
    echo 'sentinel get-master-addr-by-name mymaster' | ../client/redis-cli -p $1
}

redis_role() {
    echo "---"
    echo "role: 6377"
    echo 'role' | ../client/redis-cli -p 6377

    echo "---"
    echo "role: 6378"
    echo 'role' | ../client/redis-cli -p 6378

    echo "---"
    echo "role: 6379"
    echo 'role' | ../client/redis-cli -p 6379
}

now_time() {
    begin_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo "---"
    printf "%-10s %-11s" "now time:" $begin_time
}

cd $work_path
rm -f test.log

kill_redis
start_sentinels
redis_info redis-sentinel
start_redis
redis_info redis-server
remaster 6379
redis_role
get_master_info_from_sentinel 26379
sleep 20
shutdown_redis 6379
echo 'failover wait for 200s...'
sleep 180
remaster_redis 6379
sleep 5
# kill_redis_server 6379

now_time

for (( ; ; )); do
    get_master_info_from_sentinel 26379
    now_time
    sleep 3
done
