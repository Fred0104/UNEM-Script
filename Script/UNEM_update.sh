#!/bin/sh
#-------------参数设定--------------------------------------
ip1="www.baidu.com"
ip2="222.5.5.5"
#-------------检查是否已经运行-------------------------------
function check_if_already_running(){
	running_tasks="$(ps |grep "unblockneteasemusic" |grep "UNEM_update" |grep -v "grep" |awk '{print $1}' |wc -l)"
	[ "${running_tasks}" -gt "2" ] && echo -e "$(date -R) # A task is already running." >>/tmp/unblockmusic.log && exit 2
}
#--------------更新日志---------------------------------
function clean_log(){
	echo "" >> /tmp/unblockmusic.log
}
#------------检查网络状态-------------------------------
function check_network_status()
{
	ping -c 3 -w 5 $ip1
	if [ $? -ne 0 ];then
		ping -c 3 -w 5 $ip2
		if [ $? -ne 0 ];then
		return -1
		fi
	else
		return 0
	fi
}
#------------检查更新-----------------------------------
function check_latest_version(){
	latest_ver="$(wget --no-check-certificate -O- https://github.com/Fred0104/UNEM-Script/commits/main |tr -d '\n' |grep -Eo 'commit\/[0-9a-z]+' |sed -n 1p |sed 's#commit/##g')"
	[ -z "${latest_ver}" ] && echo -e "\nFailed to check latest version, please try again later." >>/tmp/unblockmusic.log && exit 1
	if [ ! -e "/opt/storage/UNEM/local_ver" ]; then
		echo -e "Local version: NOT FOUND, cloud version: ${latest_ver}." >>/tmp/unblockmusic.log
		update
	else
		if [ "$(cat /opt/storage/UNEM/local_ver)" != "${latest_ver}" ]; then
			echo -e "$(date -R) # Local version: $(cat /opt/storage/UNEM/local_ver 2>/dev/null), cloud version: ${latest_ver}." >>/tmp/unblockmusic.log
			update
		else
			echo -e "$(date -R) # Local version: $(cat /opt/storage/UNEM/local_ver 2>/dev/null), cloud version: ${latest_ver}." >>/tmp/unblockmusic.log
			echo -e "$(date -R) # You're already using the latest version." >>/tmp/unblockmusic.log
			logger -t "【音乐解锁】" "当前已是最新版本，无需更新"
			/opt/storage/UNEM/unblockmusic.sh restart
			exit 3
		fi
	fi
}
#-----------更新-----------------------------------------
function update(){
	echo -e "Updating ..." >>/tmp/unblockmusic.log
	logger -t "【音乐解锁】" "检查到新版本，更新中..."
	if [ ! -x "/opt/storage/UNEM/" ]; then
	mkdir -p "/opt/storage/UNEM/"
	echo "/opt/storage/UNEM/ not found!"
	fi

	if [ -f "/opt/storage/UNEM/unblockmusic.sh" ]; then
	/opt/storage/UNEM/unblockmusic.sh stop
	fi

	mkdir -p "/tmp/UNEM/" >/dev/null 2>&1
	rm -rf /tmp/UNEM/* >/dev/null 2>&1

	wget --no-check-certificate -t 1 -T 10 -O  /tmp/UNEM/UNEM.tar.gz "https://github.com/Fred0104/UNEM-Script/archive/main.tar.gz"  >/dev/null 2>&1
	tar -zxf "/tmp/UNEM/UNEM.tar.gz" -C "/tmp/UNEM/" >/dev/null 2>&1
	if [ -e "/opt/storage/UNEM/ca.crt" ] && [ -e "/opt/storage/UNEM/server.crt" ] && [ -e "/opt/storage/UNEM/server.key" ] ; then
		rm -f /tmp/UNEM/UNEM-Script-main/UNEM/ca.crt /tmp/UNEM/UNEM-Script-main/UNEM/UNEM/server.crt /tmp/UNEM/UNEM-Script-main/UNEM/server.key
	fi
	cp -a /tmp/UNEM/UNEM-Script-main/UNEM/* "/opt/storage/UNEM/"
    
	rm -rf "/tmp/unblockneteasemusic" >/dev/null 2>&1

	if [ ! -e "/opt/storage/UNEM/UnblockNeteaseMusic" ]; then
		echo -e "$(date -R) # Failed to download." >>/tmp/unblockmusic.log
		logger -t "【音乐解锁】" "更新失败"
		exit 1
	else
		echo -e "${latest_ver}" > /opt/storage/UNEM/local_ver
	fi

	echo -e "$(date -R) # Succeeded in updating." >/tmp/unblockmusic.log
	echo -e "$(date -R) # Local version: $(cat /opt/storage/UNEM/local_ver 2>/dev/null), cloud version: ${latest_ver}.\n" >>/tmp/unblockmusic.log
	chmod 777 /opt/storage/UNEM/*
	/opt/storage/UNEM/unblockmusic.sh start
	logger -t "【音乐解锁】" "更新成功"
	exit 0
}

function main(){
	logger -t "【音乐解锁】" "开始检查更新"
	while true
	do
		check_network_status
		if [ $? -eq 0 ];then
			check_if_already_running
			check_latest_version
		else
			echo -e "$(date -R) # Network Status Error, try again after 20 sec.\n" >/tmp/unblockmusic.log
			logger -t "【音乐解锁】" "检测到网络问题，等待20秒后重新检查更新"
			sleep 20s
		fi
	done
}
    main