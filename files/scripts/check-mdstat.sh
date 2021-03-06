#!/bin/bash
#template from http://www.juliux.de/nagios-plugin-vorlage-bash

WARN_LIMIT=1
CRIT_LIMIT=3

DATA=0
if [ "x$1" == "x" ]; then
  DEVID="*"
else
  DEVID=$1 
fi

for file in /sys/block/md$DEVID/md/mismatch_cnt; do
        cat $file | grep 0 > /dev/null
        if [ $? -ne 0 ]; then
                DATA=`cat $file`
        fi
        MD_NAME=`echo $file | awk 'BEGIN { FS = "/" } ; { print $4 }'`
        PERF_DATA+="$MD_NAME=`cat $file` "
done
if [ $DATA -lt $WARN_LIMIT ]; then
        echo "OK - all software raid mismatch_cnts are smaller than $WARN_LIMIT | $PERF_DATA"
        exit 0;
fi
if [ $DATA -ge $WARN_LIMIT ] && [ $DATA -lt $CRIT_LIMIT ]; then
        echo "WARNING - software raid mismatch_cnts are greater or equal than $WARN_LIMIT | $PERF_DATA"
        exit 1;
fi
if [ $DATA -ge $CRIT_LIMIT ]; then
        echo "CRITICAL - software raid mismatch_cnts are greater or equal than $CRIT_LIMIT | $PERF_DATA"
        exit 2;
fi
