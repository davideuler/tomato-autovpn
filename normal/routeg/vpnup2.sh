#!/bin/sh
#   TT-AUTOVPN
#   E-mail:admin@enjoydiy.com
#   http://bbs.enjoydiy.com
set -x
export PATH="/bin:/sbin:/usr/sbin:/usr/bin"

LOG='/tmp/autoddvpn.log'
LOCK='/tmp/autoddvpn.lock'
PID=$$
EXROUTEDIR='/jffs/exroute.d'
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"
CHINART='/jffs/openvpn/routeg/up.sh'
opsrvdefault='10.8.0.1'

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup.sh started" >> $LOG
for i in 1 2 3 4 5 6
do
	if [ -f $LOCK ]; then
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") got $LOCK , sleep 10 secs. #$i/6" >> $LOG
		sleep 10
	else
		break
	fi
done

if [ -f $LOCK ]; then
   echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") still got $LOCK , I'm aborted. Fix me." >> $LOG
   exit 0
fi
#else
#	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $LOCK was released, let's continue." >> $LOG
#fi

# create the lock
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup" >> $LOCK
	
OLDGW=$(nvram get zj_gateway)
if [ `echo $OLDGW | wc -m` -lt 8 ]; then
	GW=$(route -n | grep ^0.0.0.0 | awk '{print $2}')
	OLDGW=$GW
	`nvram set zj_gateway=$OLDGW`
fi
echo "GW = ${GW}, OLDGW = ${OLDGW}" >> /jffs/openvpn/test_log
#OLDGW=$(nvram get wan_gateway)

case $1 in
	"pptp")
		case "$(nvram get router_name)" in
			"tomato")
				echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") router type: tomato" >> $LOG
				VPNSRV=$(nvram get pptpd_client_srvip)
				VPNSRVSUB=$(nvram get pptpd_client_srvsub)
				PPTPDEV=$(nvram get pptp_client_iface)
				VPNGW=$(nvram get pptp_client_gateway)
				VPNUPCUSTOM='/jffs/pptp/vpnup_custom'
				;;
			*)
				# assume it to be a DD-WRT
				echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") router type: DD-WRT" >> $LOG
				VPNSRV=$(nvram get pptpd_client_srvip)
				VPNSRVSUB=$(nvram get pptpd_client_srvsub)
				#PPTPDEV=$(route -n | grep ^$VPNSRVSUB | awk '{print $NF}')
				PPTPDEV=$(route -n | grep ^${VPNSRVSUB%.[0-9]*} | awk '{print $NF}' | head -n 1)
				VPNGW=$(ifconfig $PPTPDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
				VPNUPCUSTOM='/jffs/pptp/vpnup_custom'
				;;
		esac
		;;
	"openvpn")
		VPNSRV=$(nvram get openvpncl_remoteip)
		#OPENVPNSRVSUB=$(nvram get OPENVPNd_client_srvsub)
		#OPENVPNDEV=$(route | grep ^$OPENVPNSRVSUB | awk '{print $NF}')
		OPENVPNDEV='tun0'
		VPNGW=$(ifconfig $OPENVPNDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
		VPNUPCUSTOM='/jffs/openvpn/vpnup_custom'
		;;
	*)
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") unknown vpnup.sh parameter,quit." >> $LOCK
		exit 1
esac



if [ $OLDGW == '' ]; then
	echo "$ERROR OLDGW is empty, is the WAN disconnected?" >> $LOG
	exit 0
else
	echo "$INFO OLDGW is $OLDGW" 
fi

#vpnsrv ip address deal
opsrv=`nvram get openvpnsrv | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"`
if [ `echo $opsrv | wc -m` -lt 8 ]; then
#       opsrv_1=`cat /var/log/message* | sed -n 's#^.*route\ \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\),.*#\1#pg' | sed q`
	opsrv_1=`grep 'route 1' /var/log/message* | sed -n '1,1p' | awk -F, '{i=1;while(i<=NF){if(match($i,/^route\ 1/)){print $i; exit;};i++}}' | awk -F' ' '{print $2}' |grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"`
	if [ `echo $opsrv_1 | wc -m` -gt 7 ]; then
		`nvram set openvpnsrv=$opsrv_1`
		opsrv=$opsrv_1
	else
		echo " can't get the value of openvpnsrv,please write to nvram by hand,thank you!" >> $LOG
		opsrv=$opsrvdefault
	fi
fi
echo "$ZJ the value of openvpnsrv is $opsrv" >> $LOG
route add -host $opsrv gw $VPNGW
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") make $opsrv gw $OLDGW"  >> $LOG
#route add -host $VPNSRV gw $OLDGW
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") delete default gw $OLDGW"  >> $LOG
route del default gw $OLDGW

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") add default gw $VPNGW"  >> $LOG
route add default gw $VPNGW

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding the static routes, this may take a while." >> $LOG

##### begin batch route #####
export VPNGW=$VPNGW
export OLDGW=$OLDGW
grep ^route $CHINART | /bin/sh -x
##### end batch route #####

if [ -f $VPNUPCUSTOM ]; then
grep ^route $VPNUPCUSTOM | /bin/sh -x
fi

# prepare for the exceptional routes, see http://code.google.com/p/autoddvpn/issues/detail?id=7
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") preparing the exceptional routes" >> $LOG
if [ $(nvram get exroute_enable) -eq 1 ]; then
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying the exceptional routes" >> $LOG
	if [ ! -d $EXROUTEDIR ]; then
		EXROUTEDIR='/tmp/exroute.d'
		mkdir $EXROUTEDIR
	fi
	for i in $(nvram get exroute_list)
	do
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") fetching exceptional routes for $i"  >> $LOG
		if [ -d $EXROUTEDIR -a ! -f $EXROUTEDIR/$i ]; then
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") missing $EXROUTEDIR/$i, wget it now."  >> $LOG
			wget http://autoddvpn.googlecode.com/svn/trunk/exroute.d/$i -O $EXROUTEDIR/$i 
		fi
		if [ ! -f $EXROUTEDIR/$i ]; then
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $EXROUTEDIR/$i not found, skip."  >> $LOG
			continue
		fi
		for r in $(grep -v ^# $EXROUTEDIR/$i)
		do
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding $r via wan_gateway"  >> $LOG
			# check the item is a subnet or a single ip address
			echo $r | grep "/" > /dev/null
			if [ $? -eq 0 ]; then
				route add -net $r gw $(nvram get wan_gateway) 
			else
				route add $r gw $(nvram get wan_gateway) 
			fi
		done 
	done
	#route | grep ^default | awk '{print $2}' >> $LOG
	# for custom list of exceptional routes
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying custom exceptional routes if available" >> $LOG
	for i in $(nvram get exroute_custom)
	do
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding custom host/subnet $i via wan_gateway"  >> $LOG
		# check the item is a subnet or a single ip address
		echo $i | grep "/" > /dev/null
		if [ $? -eq 0 ]; then
			route add -net $i gw $(nvram get wan_gateway) 
		else
			route add $i gw $(nvram get wan_gateway) 
		fi
	done
else
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") exceptional routes disabled."  >> $LOG
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") exceptional routes features detail:  http://goo.gl/fYfJ"  >> $LOG
fi

# final check again
echo "$INFO final check the default gw"
while true
do
	GW=$(route -n | grep ^0.0.0.0 | awk '{print $2}')
	echo "$DEBUG my current gw is $GW"
	#route | grep ^default | awk '{print $2}'
	if [ "$GW" == "$OLDGW" ]; then 
		echo "$DEBUG still got the OLDGW, why?"
		echo "$INFO delete default gw $OLDGW" 
		route del default gw $OLDGW
		echo "$INFO add default gw $VPNGW again" 
		route add default gw $VPNGW
		sleep 3
	else
		break
	fi
done

echo "$INFO static routes added"
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup.sh ended" >> $LOG
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") restarting DNS" >> $LOG
restart_dns
# release the lock

#For enjoydiy server
route add -host  69.85.87.167 gw $OLDGW
route add -host  116.251.210.208 gw $OLDGW
route add -host  69.85.86.64 gw $OLDGW
route add -host  184.170.244.109 gw $OLDGW
route add -host 216.172.132.89 gw $OLDGW
rm -f $LOCK
