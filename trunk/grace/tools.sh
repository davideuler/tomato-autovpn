#!/bin/sh
#
# Author:zijiao E-mail:admin@enjoydiy.com aefskw@gmail.com
#
# Web: http://blog.enjoydiy.com http://bbs.enjoydiy.com
#
# USAGE: visit up web.
#
echo "##################################################"
echo "#        Thanks for using VPN from EnjoyDiy      #"
echo "#              welecom to visit our websit       #"
echo "#                       http://bbs.enjoydiy.com  #"
echo "#         Email: admin@enjoydiy.com              #"
echo "##################################################"
OPENVPNDEV='tun0'
VPNGW=$(ifconfig $OPENVPNDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
OLDGW=$(nvram get wan_gateway)
echo "The functions lists:"
echo "---------------------------------------------- "
echo "1.Set openvpn account and password"
echo "2.Set a IP through VPN"
echo "3.Set a IP through your network"
echo "4.Clean up the your own network routes lists"
echo "5.Start the openvpn daemon"
echo "6.Update routes from network"
echo "7.Set openvpn server ip port connection type(tcp or udp)"
echo "8.Update the tools and startopenvpn.sh"
echo "9.exit and enjoy your life"
echo "----------------------------------------------"
if [ -z $1 ]; then
  read -p "Please type a number: " fun
else
  fun=$1
fi
case "$fun" in
  1)
   if [[ -n "$2" ]] && [[ -n "$3" ]]; then
      a=$2;
      b=$3;
      echo "account:${a}   password:${b}"
      echo $a > /jffs/openvpn/passwd.txt
      echo $b >> /jffs/openvpn/passwd.txt
      echo "OK!"
      exit
   else
      read -p "Please your Openvpn account: " a
      read -p "Please your Openvpn password: " b
      echo "account:${a}   password:${b}"
      echo $a > /jffs/openvpn/passwd.txt
      echo $b >> /jffs/openvpn/passwd.txt
      echo "OK!"
   fi
  ;;
  2)
   if [ -n "$2" ]; then
        ip=$2
        echo "route add -host $ip gw \$VPNGW" >> /jffs/openvpn/vpnup_custom
        route add -host $ip gw $VPNGW		
        exit
     fi
     read -p "Please type in the ip address:" ip
     echo "The ip:$ip"
     read -p "The ip is right? y or n:" y
     if [ "$y" = "y" ];then
        echo "route add -host $ip gw \$VPNGW" >> /jffs/openvpn/vpnup_custom
        route add -host $ip gw $VPNGW		
        echo "OK!"
        sleep 1
     fi
  ;;
  3)
   if [ -n "$2" ]; then
      ip=$2
      echo "route add -host $ip gw \$OLDGW" >> /jffs/openvpn/vpnup_custom
      route add -host $ip gw $OLDGW		
      exit
   fi
   read -p "Please type in the ip address:" ip
   echo "The ip:$ip"
   read -p "The ip is right? y or n:" y
   if [ "$y" = "y" ];then
      echo "route add -host $ip gw \$OLDGW" >> /jffs/openvpn/vpnup_custom
      route add -host $ip gw $OLDGW		
      echo "OK!"
      sleep 1
      exit
   fi
  ;;
  4)
   cat /jffs/openvpn/vpnup_custom.bak > /jffs/openvpn/vpnup_custom
   echo "OK!"
   sleep 1
   if [ $1 ]; then
      echo $1
      exit 1
   fi
  ;;
  5)
     sh /jffs/openvpn/startopenvpn.sh $*
  ;;
  6)
   PING=PING=`ping -q -c4 googlecode.com | grep received |awk '{print $4}'`
   if [[ $PING -lt 1 ]]
   then
      echo "bad network! update fail!"
   else
      #wget http://raw.github.com/enjoydiy/ttautovpn/master/up.sh -O /jffs/up.sh
      #wget http://raw.github.com/enjoydiy/ttautovpn/master/down.sh -O /jffs/down.sh
      rm /jffs/openvpn/routeg/route.bak
      wget http://tomato-autovpn.googlecode.com/svn/trunk/grace/routeg/route -O /jffs/openvpn/routeg/route.bak
      if [ `cat /jffs/openvpn/routeg/route.bak | wc -l` -gt 100 ]; then
         mv /jffs/openvpn/routeg/route.bak /jffs/openvpn/routeg/route
         echo "success!"
      else
         echo "fail!"
      fi
   fi
  ;;
  7)
   if [ -n "$2" ]; then
      sed -e "s/enjoydiy.com/${2}/" /jffs/openvpn/vpn1.ovpn.bak > /jffs/openvpn/vpn1.ovpn
   if [ -n "$3" ] && [ -n "$4" ]; then
      IP=$2
      PORT=$3
      XIEYI=$4
      sed -e "s/remote enjoydiy.com 53/remote $IP $PORT/" /jffs/openvpn/vpn1.ovpn.bak | sed -e "s/proto tcp/proto $XIEYI/" > /jffs/openvpn/vpn1.ovpn
      echo "OK"
   fi
      echo "OK"
      exit
   else
      read -p "Enter openvpn server ip:" IP
      read -p "Enter openvpn server port:" PORT
      read -p  "Enter openvpn server is tcp or udp:" XIEYI
      sed -e "s/remote enjoydiy.com 53/remote $IP $PORT/" /jffs/openvpn/vpn1.ovpn.bak | sed -e "s/proto tcp/proto $XIEYI/" > /jffs/openvpn/vpn1.ovpn
      echo "OK"
   fi
  ;;
  8)
   wget http://tomato-autovpn.googlecode.com/svn/trunk/grace/tools.sh -O /jffs/openvpn/tools.sh.bak
   wget http://tomato-autovpn.googlecode.com/svn/trunk/grace/startopenvpn.sh -O /jffs/openvpn/startopenvpn.sh.bak
   chmod 777 /jffs/openvpn/tools.sh.bak
   chmod 777 /jffs/openvpn/startopenvpn.sh.bak
   if [ `cat /jffs/openvpn/tools.sh.bak | wc -l` -gt 100 ]; then
      mv /jffs/openvpn/tools.sh.bak /jffs/openvpn/tools.sh
      echo "UPDATE tools.sh OK!"
   fi
   if [ `cat /jffs/openvpn/startopenvpn.sh.bak | wc -l` -gt 10 ]; then
      mv /jffs/openvpn/startopenvpn.sh.bak /jffs/openvpn/startopenvpn.sh
      echo "UPDATE startopenvpn.sh OK!"
   fi
  ;;
  9)
     echo "Good Bye!"
     exit
  ;;
  *)
     echo "The wrong num!"
esac
