#!/bin/sh
echo “运行”
log_max_size=1024000
log_file="/tmp/unblockmusic.log"
log_size=0
cd `dirname $0`
running_tasks="$(ps |grep "unblockneteasemusic" |grep "logcheck" |grep -v "grep" |awk '{print $1}' |wc -l)"
[ "${running_tasks}" -gt "2" ] && echo -e "$(date -R) # A task is already running." >>/tmp/unblockmusic.log && exit 2
./getmusicip.sh
sleep 5s

while true
do
  	icount=`busybox ps -w | grep UnblockNeteaseMusic | grep -v grep | grep -v logcheck.sh`
	if [ -z "$icount" ]; then
    	./getmusicip.sh
    	./unblockmusic.sh restart 
	fi
	if [ ! -f "$log_file" ]; then
 		touch "$log_file"
		echo "create a log"
		echo "$(date -R) # Start UnblockNeteaseMusic" >/tmp/unblockmusic.log
  	else
		echo "$log_size"
		log_size=`ls -l $log_file | awk '{ print $5 }'`
		echo "$log_size"
		echo "$log_max_size"
			if [ $log_size -gt $log_max_size ]; then
				echo "$(date -R) # Log is full,clear the log." >/tmp/unblockmusic.log
				logger -t "【音乐解锁】" "日志太大了"
			fi
  	fi
	if [  -z "$( grep "dnsmasq.music"  /etc/storage/dnsmasq/dnsmasq.conf )" ]; then
	logger -t "【音乐解锁】" "dnsmasq conf-dir is missing, trying to repair it."
	cat >> /etc/storage/dnsmasq/dnsmasq.conf << EOF
conf-dir=/tmp/dnsmasq.music
EOF
	fi
	
	echo "check"
	sleep 29s
done
