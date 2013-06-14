#!/bin/sh
#
# Author:zijiao E-mail:admin@enjoydiy.com aefskw@gmail.com
# Web: http://blog.enjoydiy.com http://bbs.enjoydiy.com
#
# USAGE: visit web.
#

#The VPN Server IP
vpnserv='10.8.0.1'

#The config path of openvpn
config='/jffs/openvpn/vpn1.ovpn'

#openvpn device
od='tun0'

#deal opensrv
opsrv=`nvram get openvpnsrv | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"`
if [[ `echo $opsrv | wc -m` -gt 7 ]]
then
	echo $opsrv
	vpnserv=$opsrv
	echo $opsrv
fi

#find best line
find_best_line() {
	time="99999";
	s='';

	if [ -e /jffs/openvpn/enable_best_line ]; then
		while read -r line
			do
				PING=`ping -q -c2 ${line} | grep received |awk '{print $4}'`
				if [[ $PING -lt 1 ]]
				then
					continue
				fi

				time_new=`ping -q -c2 ${line} |sed -n 's#^round-trip min/avg/max = \([0-9]*\)\..*/.*/.*#\1#pg'`				
				if [[ $time_new -lt $time ]]
				then
					s=$line
				fi
				echo "time $time_new server $line"
				time=$time_new
			done < /jffs/openvpn/server_list
	else
		return
	fi
	echo "final server $s"
	if [ -e /jffs/openvpn/like_server ]; then
		tmp_ser=`head -n1 /jffs/openvpn/like_server`
		ping_val=`ping -q -c2 ${tmp_ser}`
		PING=`echo $ping_val | grep received |awk '{print $4}'`
		if [[ -n $PING ]] && [[ $PING -gt 1 ]]
		then
			s=$tmp_ser
		fi
	fi
	
	if [ $s = 'vpn.enjoydiy.com' ]; then
		/jffs/openvpn/tools.sh 7 vpn.enjoydiy.com 53 udp
	else
		/jffs/openvpn/tools.sh 7 $s
	fi
}
#0 or more than 1 daemon deal
ISRUN=`ps | grep "openvpn --config" | grep -v "grep" | wc -l`
if [[ $ISRUN -ne 1 ]]
then
	killall openvpn
	while [ `ps | grep "openvpn --config" | grep -v "grep" | wc -l` -ne 0 ]
	do                                                              
        	echo "open is running,waiting for exiting..."
        	sleep 5                                      
		PING=`ping -q -c8 $vpnserv | grep received |awk '{print $4}'`
		if [ $PING -gt 0 ]; then
			exit;
		fi
	done   
	echo $(date)normal >> /tmp/openvpnlog
	echo "Not running, start!"
	find_best_line
	openvpn --config $config --daemon
exit
fi

#openvpn daemon running error
echo "will ping test"
PING=`ping -q -c8 ${vpnserv} | grep received |awk '{print $4}'`
if [[ $PING -lt 1 ]]
then
	echo "PING TIMEOUT"
	killall openvpn
	while [ `ps | grep "openvpn --config" | grep -v "grep" | wc -l` -ne 0 ]
	do
		echo "open is running,waiting for exiting..."
		sleep 5
		PING=`ping -q -c8 $vpnserv | grep received |awk '{print $4}'`
		if [[ $PING -gt 0 ]]
		then
			exit;
		fi
	done
	echo "start openvpn..."
	echo $(date)timeout >> /tmp/openvpnlog
	find_best_line
	openvpn --config $config --daemon
	echo "PING TIMEOUT, RESTARTED..."
else
	natnum=`iptables -t nat -vnL | grep tun | wc -l`
	if [[ $natnum -eq 0 ]]
	then
		`iptables -A POSTROUTING -t nat -o ${od} -j MASQUERADE`
		PING=`ping -q -c8 $vpnserv | grep received |awk '{print $4}'`
		if [[ $PING -gt 0 ]]
		then
			exit;
		fi
	fi

	natnum=`route -n | wc -l`
	if [[ $natnum -lt 80 ]]
	then
		/jffs/openvpn/routeg/vpnup.sh openvpn
	fi

	PING=`ping -q -c4 twitter.com | grep received |awk '{print $4}'`
	if [ $PING -lt 1 ]; then
		service dnsmasq restart
	fi
	echo "Openvp is already running ..."
fi
exit
