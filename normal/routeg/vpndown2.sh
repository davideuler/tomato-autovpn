#!/bin/sh
#
#   E-mail:admin@enjoydiy.com
#   http://bbs.enjoydiy.com
#

set -x
export PATH="/bin:/sbin:/usr/sbin:/usr/bin"


LOG='/tmp/autoddvpn.log'
LOCK='/tmp/autoddvpn.lock'
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"
CHINART='/jffs/openvpn/routeg/down.sh'
vpnserv='10.8.0.1'

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpndown.sh started" >> $LOG
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
#else
#	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $LOCK was released, let's continue." >> $LOG
fi
	
# create the lock
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup" >> $LOCK





OLDGW=$(nvram get zj_gateway)
echo "vpndown OLDGW=${OLDGW}" >> /jffs/opennvpn/test_log

case $1 in 
		"pptp")
			case "$(nvram get router_name)" in
				"tomato")
					#VPNSRV=$(nvram get pptpd_client_srvip)
					#VPNSRVSUB=$(nvram get pptpd_client_srvsub)
					#PPTPDEV=$(nvram get pptp_client_iface)
					VPNGW=$(nvram get pptp_client_gateway)
					VPNUPCUSTOM='/jffs/pptp/vpnup_custom'
					;;
				"DD-WRT")                                                                 
					PPTPSRV=$(nvram get pptpd_client_srvip)
					VPNUPCUSTOM='/jffs/pptp/vpnup_custom'
					VPNGW=$(nvram get pptp_gw)
					;;
			esac
			;;
		"openvpn")
			OPENVPNSRV=$(nvram get openvpncl_remoteip)
			OPENVPNDEV='tun0'
			VPNGW=$(ifconfig $OPENVPNDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
			VPNUPCUSTOM='/jffs/openvpn/vpnup_custom'
			;;
		*)
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") unknown vpndown.sh parameter, quit." >> $LOCK
			exit 1
			;;
esac
			


echo "[INFO] removing the static routes"

##### begin batch route #####
grep ^route $CHINART | /bin/sh -x 

if [ -f $VPNUPCUSTOM ]; then
grep ^route $VPNUPCUSTOM | sed -e 's/add/del/' | sed -e 's/ gw $OLDGW//' | sed -e 's/ gw $VPNGW//' | /bin/sh -x 
fi

opsrv=`nvram get openvpnsrv | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"`
if [[ `echo $opsrv | wc -m` -gt 7 ]]
then
	echo $opsrv
	vpnserv=$opsrv
	echo $opsrv
fi
route del -host $vpnserv
##### end batch route #####

#route del -host $PPTPSRV 
route del default gw $VPNGW
echo "$INFO add $OLDGW back as the default gw"
route add default gw $OLDGW

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpndown.sh ended" >> $LOG

# release the lock                                                                                
rm -f $LOCK

