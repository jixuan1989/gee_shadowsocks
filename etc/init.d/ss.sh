#!/bin/sh  /etc/rc.common
# Copyright (C) 2014-2099 SanLiuHuo
START=99
STOP=99

APP=ss-redir
appname=ssgoabroad
ss_getconfig() {
    lan_ip=$(uci get network.lan.ipaddr)
	source /lib/functions/network.sh
	network_get_ipaddr wanip wan
	local_ip=127.0.0.1
	mode=$(uci get $APP.$appname.mode)
	antixxx_dns_server_ip=$(uci get $APP.$appname.antixxx_dns_server_ip)
	ss_server_name=$(uci get $APP.$appname.ss_server_name)
	ss_server_ip=$(uci get $APP.$ss_server_name.ss_server_ip)
	ss_server_port=$(uci get $APP.$ss_server_name.ss_server_port)
	ss_server_password=$(uci get $APP.$ss_server_name.ss_password)
	ss_local_port=$(uci get $APP.ssgoabroad.ss_local_port)
	ss_server_method=$(uci get $APP.$ss_server_name.ss_method)
	
}

CreatSsConfigFile(){
	rm -rf /usr/bin/vendor/config/shadowsocks.json
	echo '{"server":"'$ss_server_ip'","server_port":'$ss_server_port',"local_port":'$ss_local_port',"local_addr":"'$local_ip'","password":"'$ss_server_password'","timeout":600,"method":"'$ss_server_method'"}' > /usr/bin/vendor/config/shadowsocks.json
}


ss_iptables_add() {
	iptables -t nat -N $appname
	iptables -t nat -A PREROUTING -i br-lan -j $appname
	iptables -t nat -A $appname -m salist --salist local --match-dip -j RETURN
	iptables -t nat -A $appname -m salist --salist hiwifi --match-dip -j RETURN
	iptables -t nat -A $appname -d $lan_ip/24 -j RETURN
	iptables -t nat -A $appname -d $wanip/24 -j RETURN
	iptables -t nat -A $appname -d $ss_server_ip/32 -j RETURN

	iptables -t nat -N $appname-ppp
	iptables -t nat -A PREROUTING -i ppp+ -j $appname-ppp
	iptables -t nat -A $appname-ppp -i pppoe-wan -j RETURN
        iptables -t nat -A $appname-ppp -m salist --salist local --match-dip -j RETURN
	iptables -t nat -A $appname-ppp -m salist --salist hiwifi --match-dip -j RETURN
	iptables -t nat -A $appname-ppp -d $lan_ip/24 -j RETURN
	iptables -t nat -A $appname-ppp -d $wanip/24 -j RETURN
	iptables -t nat -A $appname-ppp -d $ss_server_ip/32 -j RETURN

	iptables -t nat -N $appname-OUTPUT
	iptables -t nat -A OUTPUT -p tcp -j $appname-OUTPUT
	iptables -t nat -A $appname-OUTPUT -m salist --salist local --match-dip -j RETURN
	iptables -t nat -A $appname-OUTPUT -m salist --salist hiwifi --match-dip -j RETURN
	iptables -t nat -A $appname-OUTPUT -d $lan_ip/24 -j RETURN
	iptables -t nat -A $appname-OUTPUT -d $wanip/24 -j RETURN
	iptables -t nat -A $appname-OUTPUT -d $ss_server_ip/32 -j RETURN
	iptables -t nat -A $appname-OUTPUT -d $antixxx_dns_server_ip -p tcp --dport 53 -j DNAT --to-destination $lan_ip:$ss_local_port
	echo `date +%Y-%m-%d-%H:%M:%S`" 启动DNSMASK和PDNSD " >> /tmp/ss-redir.log
	/usr/bin/vendor/bin/dnsmask.sh start
}

ss_iptables_del() {
     echo `date +%Y-%m-%d-%H:%M:%S`" 停止DNSMASK和PDNSD " >> /tmp/ss-redir.log
    /usr/bin/vendor/bin/dnsmask.sh stop
    echo `date +%Y-%m-%d-%H:%M:%S`" 清除iptables ss主规则  " >> /tmp/ss-redir.log
    iptables -t nat -D PREROUTING -i br-lan -j $appname 1>/dev/null 2>&1
    iptables -t nat -F $appname 1>/dev/null 2>&1
    iptables -t nat -X $appname 1>/dev/null 2>&1
    iptables -t nat -D PREROUTING -i ppp+ -j $appname-ppp 1>/dev/null 2>&1
    iptables -t nat -F $appname-ppp 1>/dev/null 2>&1
    iptables -t nat -X $appname-ppp 1>/dev/null 2>&1
    iptables -t nat -D OUTPUT -p tcp -j $appname-OUTPUT 1>/dev/null 2>&1
    iptables -t nat -F $appname-OUTPUT 1>/dev/null 2>&1
    iptables -t nat -X $appname-OUTPUT 1>/dev/null 2>&1
    iptables -t nat -D PREROUTING -p udp -j dnsmask-PREROUTING 1>/dev/null 2>&1
    iptables -t nat -F dnsmask-PREROUTING 1>/dev/null 2>&1
    iptables -t nat -X dnsmask-PREROUTING 1>/dev/null 2>&1
}


ss_getconfig

start() {
    insmod ipt_REDIRECT 2>/dev/null
    touch /tmp/ss-redir.error
    echo `date +%Y-%m-%d-%H:%M:%S`" 开始启动SS " >> /tmp/ss-redir.log

    CreatSsConfigFile
    echo `date +%Y-%m-%d-%H:%M:%S`" 启动SS主程序 " >> /tmp/ss-redir.log
    /usr/bin/vendor/bin/ss-redir -c /usr/bin/vendor/config/shadowsocks.json -f /var/run/shadowsocks.pid
    echo `date +%Y-%m-%d-%H:%M:%S`" 添加iptables规则 " >> /tmp/ss-redir.log
    ss_iptables_add
       
    echo `date +%Y-%m-%d-%H:%M:%S`" SS启动完成 " >> /tmp/ss-redir.log
    echo "----------------------------------------------------------------------" >> /tmp/ss-redir.log
}

stop() {
	echo `date +%Y-%m-%d-%H:%M:%S`" 开始停止SS " >> /tmp/ss-redir.log
	echo `date +%Y-%m-%d-%H:%M:%S`" 删除iptables规则 " >> /tmp/ss-redir.log
	ss_iptables_del 1>/dev/null 2>&1
 	echo `date +%Y-%m-%d-%H:%M:%S`" 删除相关配置文件 " >> /tmp/ss-redir.log	
	rm -rf /usr/bin/vendor/config/shadowsocks.json
	
	echo `date +%Y-%m-%d-%H:%M:%S`" 停止SS主程序 " >> /tmp/ss-redir.log
	if [ -f /var/run/shadowsocks.pid ]; then 
		kill -9 `cat /var/run/shadowsocks.pid`                                                                                             
	        rm -f /var/run/shadowsocks.pid                                                                                                     
	fi  
	kill -9 `ps | grep "/usr/bin/vendor/bin/ss-redir -c /usr/bin/vendor/config/shadowsocks.json" | grep -v grep | awk '{print $1}'` 1>/dev/null 2>&1

	
	echo `date +%Y-%m-%d-%H:%M:%S`" 停止SS 完毕 " >> /tmp/ss-redir.log
}

	
