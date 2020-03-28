#!/bin/bash

ps -ef | grep -i redis | grep -v grep | awk '{if ($3 > 1) print $3;}' | xargs sudo kill -9
num=`ps -ef | grep -i redis | grep -v grep | awk '{if ($3 > 1) print $3;}' | wc -l`
echo "redis instances: $num"