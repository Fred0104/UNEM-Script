#!/bin/sh

ipt_n="iptables -t nat"
add_rule()
{
	echo "add_rule"
	ipset -! -N music hash:ip
  	ipset -! -N music_http hash:ip
  	ipset -! -N music_https hash:ip
	$ipt_n -N CLOUD_MUSIC
	$ipt_n -A CLOUD_MUSIC -d 0.0.0.0/8 -j RETURN
	$ipt_n -A CLOUD_MUSIC -d 10.0.0.0/8 -j RETURN
	$ipt_n -A CLOUD_MUSIC -d 127.0.0.0/8 -j RETURN
	$ipt_n -A CLOUD_MUSIC -d 169.254.0.0/16 -j RETURN
	$ipt_n -A CLOUD_MUSIC -d 172.16.0.0/12 -j RETURN
	$ipt_n -A CLOUD_MUSIC -d 192.168.0.0/16 -j RETURN
	$ipt_n -A CLOUD_MUSIC -d 224.0.0.0/4 -j RETURN
	$ipt_n -A CLOUD_MUSIC -d 240.0.0.0/4 -j RETURN

 	$ipt_n -A CLOUD_MUSIC -p tcp -m set ! --match-set music_http src --dport 80 -j REDIRECT --to-ports 5200
    	$ipt_n -A CLOUD_MUSIC -p tcp -m set ! --match-set music_https src --dport 443 -j REDIRECT --to-ports 5201
	$ipt_n -I PREROUTING -p tcp -m set --match-set music dst -j CLOUD_MUSIC
	iptables -I OUTPUT -d 223.252.199.10 -j DROP
	
}

del_rule(){
	echo "del_rule"
	$ipt_n -D PREROUTING -p tcp -m set --match-set music dst -j CLOUD_MUSIC 2>/dev/null
	$ipt_n -F CLOUD_MUSIC  2>/dev/null
	$ipt_n -X CLOUD_MUSIC  2>/dev/null

	ipset -X music_http 2>/dev/null
	ipset -X music_https 2>/dev/null

	iptables -D OUTPUT -d 223.252.199.10 -j DROP 2>/dev/null
	
	sed -i '/dnsmasq.music/d' /etc/storage/dnsmasq/dnsmasq.conf
	chmod 777 /tmp/dnsmasq.music	
	rm -rf /tmp/dnsmasq.music
	/sbin/restart_dhcpd
	
}

set_firewall(){
	echo "set_firewall"
	rm -f /tmp/dnsmasq.music/dnsmasq-163.conf
	mkdir -p /tmp/dnsmasq.music
  	cat <<-EOF > "/tmp/dnsmasq.music/dnsmasq-163.conf"
	ipset=/.music.163.com/music
	ipset=/interface.music.163.com/music
	ipset=/interface3.music.163.com/music
	ipset=/apm.music.163.com/music
	ipset=/apm3.music.163.com/music
	ipset=/clientlog.music.163.com/music
	ipset=/clientlog3.music.163.com/music
	EOF
	sed -i '/dnsmasq.music/d' /etc/storage/dnsmasq/dnsmasq.conf
	cat >> /etc/storage/dnsmasq/dnsmasq.conf << EOF
	conf-dir=/tmp/dnsmasq.music
	EOF
	add_rule
	/sbin/restart_dhcpd
}

wyy_start()
{
    echo "start"
    cd `dirname $0`
    ./UnblockNeteaseMusic -p 5200 -sp 5201 -m 0 -e -l "/tmp/unblockmusic.log" >/dev/null 2>&1 &
    logger -t "音乐解锁" "启动 Golang Version (http:5200, https:5201)"    	
    set_firewall
    ./logcheck.sh >/dev/null 2>&1 &
}

wyy_close()
{	
	kill -9 $(busybox ps -w | grep UnblockNeteaseMusic | grep -v grep | awk '{print $1}') >/dev/null 2>&1
	kill -9 $(busybox ps -w | grep logcheck.sh | grep -v grep | awk '{print $1}') >/dev/null 2>&1
	
	del_rule
}

case $1 in
start)
	wyy_close
	wyy_start
	;;
stop)
	wyy_close
	logger -t "音乐解锁" "已关闭"
	;;
restart)
	logger -t "音乐解锁" "重启中..."
	wyy_close
	wyy_start
	;;
*)
	echo "check"
	#exit 0
	;;
esac
