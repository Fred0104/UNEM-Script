#!/bin/sh
echo “运行”
log_max_size=1024000
log_file="/tmp/unblockmusic.log"
log_size=0
cd `dirname $0`
./getmusicip.sh
sleep 5s

while true
do
  icount=`busybox ps -w | grep UnblockNeteaseMusic | grep -v grep | grep -v logcheck.sh`
	if [ -z "$icount" ]; then
      ./getmusicip.sh
      ./UnblockNeteaseMusic restart 
  fi
	if [ ! -f "$log_size" ]; then
 	touch "$log_size"
	echo "create a log"
	echo "$(date -R) # Start UnblockNeteaseMusic" >/tmp/unblockmusic.log
  else
	echo "$log_size"
	log_size=`ls -l $log_file | awk '{ print $5 }'`
	echo "$log_size"
	echo "$log_max_size"
	    if [ $log_size -lt $log_max_size ]; then
	    echo "$(date -R) # Start UnblockNeteaseMusic" >>/tmp/unblockmusic.log
	    echo "smaller"
	    else
	    echo "$(date -R) # Start UnblockNeteaseMusic" >/tmp/unblockmusic.log
	    echo "bigger"
        fi
  fi
	echo "check"
	sleep 29s
	logger -t "check"
done