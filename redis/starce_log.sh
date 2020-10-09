#!/bin/sh
# remove strace log info in logfile.
# strace -s 512 -o /tmp/sentinel.log ./redis-sentinel sentinel.conf
sed -e '/fstat/d' -e '/gettimeofday/d' -e '/wait4/d' -e '/epoll_wait(5, \[\]/d' /tmp/sentinel.log >/tmp/sentinel.log.2
