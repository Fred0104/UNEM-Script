#!/bin/sh
#-------------检查是否已经运行-------------------------------
function check_if_already_running(){
	running_tasks="$(ps |grep "unblockneteasemusic" |grep "UNEM_update" |grep -v "grep" |awk '{print $1}' |wc -l)"
	[ "${running_tasks}" -gt "2" ] && echo -e "$(date -R) # A task is already running." >>/tmp/unblockmusic_update.log && exit 2
}
#--------------更新日志---------------------------------
function clean_log(){
	echo "" > /tmp/unblockmusic_update.log
}
#------------检查更新-----------------------------------
function check_latest_version(){
	latest_ver="$(wget --no-check-certificate -O- https://github.com/Fred0104/UNEM-Script/commits/main |tr -d '\n' |grep -Eo 'commit\/[0-9a-z]+' |sed -n 1p |sed 's#commit/##g')"
	[ -z "${latest_ver}" ] && echo -e "\nFailed to check latest version, please try again later." >>/tmp/unblockmusic_update.log && exit 1
	if [ ! -e "/opt/storage/UnblockNeteaseMusic/local_ver" ]; then
		clean_log
		echo -e "Local version: NOT FOUND, cloud version: ${latest_ver}." >>/tmp/unblockmusic_update.log
		update
	else
		if [ "$(cat /opt/storage/UnblockNeteaseMusic/local_ver)" != "${latest_ver}" ]; then
			clean_log
			echo -e "Local version: $(cat /opt/storage/UnblockNeteaseMusic/local_ver 2>/dev/null), cloud version: ${latest_ver}." >>/tmp/unblockmusic_update.log
			update
		else
			echo -e "\nLocal version: $(cat /opt/storage/UnblockNeteaseMusic/local_ver 2>/dev/null), cloud version: ${latest_ver}." >>/tmp/unblockmusic_update.log
			echo -e "You're already using the latest version." >>/tmp/unblockmusic_update.log
			[ "${luci_update}" == "n" ] && /etc/init.d/unblockmusic restart
			exit 3
		fi
	fi
}
#-----------更新-----------------------------------------
function update(){
	echo -e "Updating ..." >>/tmp/unblockmusic_update.log

	if [ ! -x "/opt/storage/UnblockNeteaseMusic/"]; then
	mkdir -p "/opt/storage/UnblockNeteaseMusic/"
	fi

	if[ -e "/opt/storage/UnblockNeteaseMusic/unblockmusic.sh"];then
    /opt/storage/UnblockNeteaseMusic/unblockmusic.sh stop
	fi

	mkdir -p "/tmp/unblockneteasemusic/" >/dev/null 2>&1
	rm -rf /tmp/unblockneteasemusic/* >/dev/null 2>&1

	wget --no-check-certificate -t 1 -T 10 -O  /tmp/unblockneteasemusic/UNEM.tar.gz "https://github.com/Fred0104/UNEM-Script/archive/main.tar.gz"  >/dev/null 2>&1
	tar -zxf "/tmp/unblockneteasemusic/UNEM.tar.gz" -C "/tmp/unblockneteasemusic/" >/dev/null 2>&1
	if [ -e "/opt/storage/UnblockNeteaseMusic/ca.crt" ] && [ -e "/opt/storage/UnblockNeteaseMusic/server.crt" ] && [ -e "/opt/storage/UnblockNeteaseMusic/server.key" ] ; then
		rm -f /tmp/unblockneteasemusic/UNEM-Script-main/UNEM/ca.crt /tmp/unblockneteasemusic/UNEM-Script-main/UNEM/UNEM/server.crt /tmp/unblockneteasemusic/UNEM-Script-main/UNEM/server.key
	fi
	cp -a /tmp/unblockneteasemusic/UNEM-Script-main/UNEM/* "/opt/storage/UnblockNeteaseMusic/"
    
	rm -rf "/tmp/unblockneteasemusic" >/dev/null 2>&1

	if [ ! -e "/opt/storage/UnblockNeteaseMusic/UnblockNeteaseMusic" ]; then
		echo -e "Failed to download core." >>/tmp/unblockmusic_update.log
		exit 1
	else
		echo -e "${latest_ver}" > /opt/storage/UnblockNeteaseMusic/local_ver
	fi

	echo -e "Succeeded in updating." >/tmp/unblockmusic_update.log
	echo -e "Local version: $(cat /opt/storage/UnblockNeteaseMusic/local_ver 2>/dev/null), cloud version: ${latest_ver}.\n" >>/tmp/unblockmusic_update.log
	chmod 777 /opt/storage/UnblockNeteaseMusic/*
	/opt/storage/UnblockNeteaseMusic/unblockmusic.sh start
}

function main(){
	check_if_already_running
	check_latest_version
}
    main