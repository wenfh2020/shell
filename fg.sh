#!/bin/sh

work_path=$(dirname $0)
cd $work_path

if [ $# -lt 1 ]; then
    echo 'pls input pid!'
    exit 1
fi

[ -f perf_with_stack.data ] && rm -f perf_with_stack.data
perf record -g -o perf_with_stack.data -p $1 -- sleep 20
perf script -i perf_with_stack.data | stackcollapse-perf.pl | flamegraph.pl > perf.svg
