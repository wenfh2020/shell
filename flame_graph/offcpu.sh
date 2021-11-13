#!/bin/sh

work_path=$(dirname $0)
cd $work_path

if [ $# -lt 1 ]; then
    echo 'pls input pid!'
    exit 1
fi

# 采集了某个进程，10 秒数据。
perf record -e sched:sched_stat_sleep -e sched:sched_switch \
	-e sched:sched_process_exit -a -g -o perf.data -p $1 -- sleep 10

perf script -i perf.data | stackcollapse-perf.pl | \
	flamegraph.pl --countname=ms --colors=io \
	--title="off-cpu Time Flame Graph" > perf.svg
