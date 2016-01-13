#!/bin/sh

                                                                                                                                               
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

dns_iptables_add() {
	
	iptables -t nat -N $appname-mode
	iptables -t nat -N $appname-OUTPUT-mode
	iptables -t nat -N $appname-ppp-mode
	sed -i 's/^[ \t]*//;s/[ \t]*$//' /usr/bin/vendor/config/black_mac_list.conf
	local black_mac
	awk '{print $0}' /usr/bin/vendor/config/black_mac_list.conf |                                                                       
	while read black_mac; do                                                                                                       
		[ -z "$black_mac" ] && continue
  	iptables -t nat -I $appname-mode -m mac --mac-source $black_mac -j RETURN
	done                                                                                                                                   
    
    case $mode in
        game)
	    
            iptables -t nat -A $appname-mode -m salist --salist china --match-dip -j RETURN
            iptables -t nat -A $appname-mode -m salist --salist black_domain_list --match-dip -j RETURN
            iptables -t nat -A $appname-ppp-mode -m salist --salist china --match-dip -j RETURN
            iptables -t nat -A $appname-ppp-mode -m salist --salist black_domain_list --match-dip -j RETURN
            iptables -t nat -A $appname-OUTPUT-mode -m salist --salist china --match-dip -j RETURN
            iptables -t nat -A $appname-OUTPUT-mode -m salist --salist black_domain_list --match-dip -j RETURN

            iptables -t nat -A $appname-mode -p tcp -j DNAT --to-destination $lan_ip:$ss_local_port

	    iptables -t nat -A $appname-ppp-mode -p tcp -j DNAT --to-destination $lan_ip:$ss_local_port

	    iptables -t nat -A $appname-OUTPUT-mode -p tcp -j DNAT --to-destination $lan_ip:$ss_local_port
        ;;
        whole)
            iptables -t nat -A $appname-mode -p tcp -j DNAT --to-destination $lan_ip:$ss_local_port

            iptables -t nat -A $appname-ppp-mode -p tcp -j DNAT --to-destination $lan_ip:$ss_local_port

            iptables -t nat -A $appname-OUTPUT-mode -p tcp -j DNAT --to-destination $lan_ip:$ss_local_port
        ;;
        china)
            iptables -t nat -A $appname -p tcp --dport 80 -m salist --salist china --match-dip -j DNAT --to-destination $lan_ip:$ss_local_port
            iptables -t nat -A $appname -p tcp --dport 443 -m salist --salist china --match-dip -j DNAT --to-destination $lan_ip:$ss_local_port

            iptables -t nat -A $appname-ppp -p tcp --dport 80 -m salist --salist china --match-dip -j DNAT --to-destination $lan_ip:$ss_local_port
            iptables -t nat -A $appname-ppp -p tcp --dport 443 -m salist --salist china --match-dip -j DNAT --to-destination $lan_ip:$ss_local_port

            iptables -t nat -A $appname-OUTPUT -p tcp --dport 80 -m salist --salist china --match-dip -j DNAT --to-destination $lan_ip:$ss_local_port
            iptables -t nat -A $appname-OUTPUT -p tcp --dport 443 -m salist --salist china --match-dip -j DNAT --to-destination $lan_ip:$ss_local_port
            ;;

        exact)
            iptables -t nat -A $appname-mode -m salist --salist black_domain_list --match-dip -j RETURN
            iptables -t nat -A $appname-ppp-mode -m salist --salist black_domain_list --match-dip -j RETURN
            iptables -t nat -A $appname-OUTPUT-mode -m salist --salist black_domain_list --match-dip -j RETURN
           
	    iptables -t nat -A $appname-mode -p tcp -m salist --match-dip --salist gfw_list -j DNAT --to-destination $lan_ip:$ss_local_port
            iptables -t nat -A $appname-ppp-mode -p tcp -m salist --match-dip --salist gfw_list -j DNAT --to-destination $lan_ip:$ss_local_port
            iptables -t nat -A $appname-OUTPUT-mode -p tcp -m salist --match-dip --salist gfw_list -j DNAT --to-destination $lan_ip:$ss_local_port
        
            ;;
        *)

            iptables -t nat -A $appname-mode -m salist --salist china --match-dip -j RETURN
            iptables -t nat -A $appname-mode -m salist --salist black_domain_list --match-dip -j RETURN
            iptables -t nat -A $appname-ppp-mode -m salist --salist china --match-dip -j RETURN
            iptables -t nat -A $appname-ppp-mode -m salist --salist black_domain_list --match-dip -j RETURN
            iptables -t nat -A $appname-OUTPUT-mode -m salist --salist china --match-dip -j RETURN
            iptables -t nat -A $appname-OUTPUT-mode -m salist --salist black_domain_list --match-dip -j RETURN

            iptables -t nat -A $appname-mode -p tcp --dport 80 -j DNAT --to-destination $lan_ip:$ss_local_port
            iptables -t nat -A $appname-mode -p tcp --dport 443 -j DNAT --to-destination $lan_ip:$ss_local_port

            iptables -t nat -A $appname-ppp-mode -p tcp --dport 80 -j DNAT --to-destination $lan_ip:$ss_local_port
            iptables -t nat -A $appname-ppp-mode -p tcp --dport 443 -j DNAT --to-destination $lan_ip:$ss_local_port

            iptables -t nat -A $appname-OUTPUT-mode -p tcp --dport 80 -j DNAT --to-destination $lan_ip:$ss_local_port
            iptables -t nat -A $appname-OUTPUT-mode -p tcp --dport 443 -j DNAT --to-destination $lan_ip:$ss_local_port
        ;;
        esac
	
	iptables -t nat -A $appname -p tcp -j $appname-mode
	iptables -t nat -A $appname-OUTPUT -p tcp -j $appname-OUTPUT-mode                                                                                       
	iptables -t nat -A $appname-ppp -p tcp -j $appname-ppp-mode                                                                                                                                                                                                                              
}

dns_iptables_del() {

    iptables -t nat -D $appname -p tcp -j $appname-mode 1>/dev/null 2>&1
    iptables -t nat -F $appname-mode 1>/dev/null 2>&1
    iptables -t nat -X $appname-mode 1>/dev/null 2>&1
    iptables -t nat -D $appname-ppp -p tcp -j $appname-ppp-mode 1>/dev/null 2>&1
    iptables -t nat -F $appname-ppp-mode 1>/dev/null 2>&1
    iptables -t nat -X $appname-ppp-mode 1>/dev/null 2>&1
    iptables -t nat -D $appname-OUTPUT -p tcp -j $appname-OUTPUT-mode 1>/dev/null 2>&1
    iptables -t nat -F $appname-OUTPUT-mode 1>/dev/null 2>&1
    iptables -t nat -X $appname-OUTPUT-mode 1>/dev/null 2>&1
    
    iptables -t nat -D PREROUTING -p udp -j dnsmask-PREROUTING 1>/dev/null 2>&1
    iptables -t nat -F dnsmask-PREROUTING 1>/dev/null 2>&1
    iptables -t nat -X dnsmask-PREROUTING 1>/dev/null 2>&1
}

dnsmask_start(){
	echo `date +%Y-%m-%d-%H:%M:%S`" 启动DNSMASK " >> /tmp/ss-redir.log
#    echo clear > /proc/nf_salist/gfw_list 1>/dev/null 2>&1
    mkdir -p /tmp/vendor/dnsmask.d
    cat > /tmp/vendor/dnsmask.conf <<EOF
conf-dir=/tmp/vendor/dnsmask.d
EOF
    [ -f /tmp/resolv.conf.auto ] && echo "resolv-file=/tmp/resolv.conf.auto" >> /tmp/vendor/dnsmask.conf
    
#    echo -gfw_list > /proc/nf_salist/control

    echo `date +%Y-%m-%d-%H:%M:%S`" 生成gfw_list " >> /tmp/ss-redir.log

    if [ ! -f /tmp/vendor/gfwlist-00.conf ]; then
        sed -i 's/^[ \t]*//;s/[ \t]*$//' /usr/bin/vendor/config/gfw_list.conf
        echo +gfw_list > /proc/nf_salist/control 2>/dev/null
        (
        local gfw_host
        awk '{print $0}' /usr/bin/vendor/config/gfw_list.conf |
        while read gfw_host; do
        [ -z "$gfw_host" ] && continue
            echo "server=/.$gfw_host/127.0.0.1#1053"
                        echo "ipset=/.$gfw_host/gfw_list"
        done
         ) > /tmp/vendor/dnsmask.d/00.conf
         cp -a /tmp/vendor/dnsmask.d/00.conf /tmp/vendor/gfwlist-00.conf
    else
         echo +gfw_list > /proc/nf_salist/control 2>/dev/null 
         cp -a /tmp/vendor/gfwlist-00.conf /tmp/vendor/dnsmask.d/00.conf
    fi

	echo `date +%Y-%m-%d-%H:%M:%S`" 生成白名单 " >> /tmp/ss-redir.log
         sed -i 's/^[ \t]*//;s/[ \t]*$//' /usr/bin/vendor/config/white_domain_list.conf
         (
         local white_domain_host
         awk '{print $0}' /usr/bin/vendor/config/white_domain_list.conf |                                                                       
         while read white_domain_host; do                                                                                                       
                [ -z "$white_domain_host" ] && continue
                echo "server=/.$white_domain_host/127.0.0.1#1053"
                echo "ipset=/.$white_domain_host/gfw_list"
        done                                                                                                                                   
          ) >> /tmp/vendor/dnsmask.d/00.conf                                                                                                      
#        echo clear > /proc/nf_salist/gfw_list 1>/dev/null 2>&1


	echo `date +%Y-%m-%d-%H:%M:%S`" 生成黑名单 " >> /tmp/ss-redir.log
        echo +black_domain_list > /proc/nf_salist/control 2>/dev/null
	sed -i 's/^[ \t]*//;s/[ \t]*$//' /usr/bin/vendor/config/black_domain_list.conf
        (
        local black_domain_host
        awk '{print $0}' /usr/bin/vendor/config/black_domain_list.conf |        while read black_domain_host; 
        do
                [ -z "$black_domain_host" ] && continue
                eval sed -i '/.${black_domain_host}/'d /tmp/vendor/dnsmask.d/00.conf  1>/dev/null 2>&1
                echo "ipset=/.$black_domain_host/black_domain_list"
		
                #eval sed -i '/.${black_domain_host}/'d /tmp/vendor/dnsmask.d/2_ss_white_domain_list.conf
        done
         ) >> /tmp/vendor/dnsmask.d/01.conf
        sed '/ipset=/'d /tmp/vendor/dnsmask.d/00.conf > /tmp/dnsmasq.d/00.conf
        sed -i 's/127.0.0.1#1053/127.0.0.1#1052/g' /tmp/dnsmasq.d/00.conf
        #sed '/ipset=/'d /tmp/vendor/dnsmask.d/1_ss_gfw_list.conf > /tmp/dnsmasq.d/1_ss_gfw_list.conf
	
	echo `date +%Y-%m-%d-%H:%M:%S`" 启动DNSMASK主程序并劫持dns查询 " >> /tmp/ss-redir.log
        iptables -t nat -N dnsmask-PREROUTING
        iptables -t nat -F dnsmask-PREROUTING
        iptables -t nat -A dnsmask-PREROUTING -p udp ! --dport 53 -j RETURN
        iptables -t nat -A dnsmask-PREROUTING -d $lan_ip -p udp -j REDIRECT --to 1052
        iptables -t nat -I PREROUTING -p udp -j dnsmask-PREROUTING
        /usr/bin/vendor/bin/dnsmask -C /tmp/vendor/dnsmask.conf -p 1052 -u root -x /var/run/dnsmask.pid
        /etc/init.d/dnsmasq restart
        echo `date +%Y-%m-%d-%H:%M:%S`" 根据模式添加对应的iptables规则 " >> /tmp/ss-redir.log
	dns_iptables_add  
        
}


dnsmask_stop(){
	echo `date +%Y-%m-%d-%H:%M:%S`" 停止DNSMASK" >> /tmp/ss-redir.log
        dns_iptables_del 1>/dev/null 2>&1
        iptables -t nat -D PREROUTING -p udp -j dnsmask-PREROUTING 1>/dev/null 2>&1
        iptables -t nat -F dnsmask-PREROUTING 1>/dev/null 2>&1
        iptables -t nat -X dnsmask-PREROUTING 1>/dev/null 2>&1
        
        echo `date +%Y-%m-%d-%H:%M:%S`" 停止DNSMASK主程序 " >> /tmp/ss-redir.log
	rm -rf /tmp/vendor/dnsmask.d
        if [ -f /var/run/dnsmask.pid ]; then
                kill -9 `cat /var/run/dnsmask.pid`
                rm -f /var/run/dnsmask.pid
        fi
	echo `date +%Y-%m-%d-%H:%M:%S`" 重新启动DNSMASQ " >> /tmp/ss-redir.log
        rm -rf /tmp/dnsmasq.d/*
        /etc/init.d/dnsmasq restart 1>/dev/null 2>&1
	echo -gfw_list > /proc/nf_salist/control        
	echo -black_domain_list > /proc/nf_salist/control 2>/dev/null        
}

dnsmask_restart(){
	pdnsd_stop
        dnsmask_stop
        sleep 2
        dnsmask_start
	pdnsd_start
}

pdnsd_start(){
    echo `date +%Y-%m-%d-%H:%M:%S`" 启动PDNSD " >> /tmp/ss-redir.log
    cat > /etc/pdnsd.conf <<EOF
global {
    perm_cache=256;
    cache_dir="/var/pdnsd";
    pid_file = /var/run/pdnsd.pid;
    run_as="nobody";
    server_ip = 127.0.0.1;
    server_port = 1053;
    status_ctl = on;
    query_method = tcp_only;
    min_ttl=15m;       # Retain cached entries at least 15 minutes.
    max_ttl=1w;        # One week.
    timeout=10;        # Global timeout option (10 seconds).
    neg_domain_pol=on;
    proc_limit=2;
    procq_limit=8;
}

server {
    label= "antixxx";
    timeout=6;         # Server timeout; this may be much shorter
    uptest=none;         # Test if the network interface is active.
    interval=10m;      # Check every 10 minutes.
    purge_cache=off;   # Keep stale cache entries in case the ISP's
    ip =$antixxx_dns_server_ip;
}
EOF

        /etc/init.d/pdnsd restart 1>/dev/null 2>&1

}

pdnsd_stop(){
     echo `date +%Y-%m-%d-%H:%M:%S`" 停止PDNSD " >> /tmp/ss-redir.log
     /etc/init.d/pdnsd stop 1>/dev/null 2>&1    
     rm -rf /etc/pdnsd.conf
}

ss_getconfig
case "$1" in
    "restart")
        pdnsd_stop
        dnsmask_stop
        sleep 1
        dnsmask_start
        pdnsd_start     
        exit 0;
        ;;
    "start")
        dnsmask_start;
	pdnsd_start
        exit 0;
        ;;
    "stop")
        dnsmask_stop;
	pdnsd_stop;
        exit 0;
        ;;
esac
