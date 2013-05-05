#!/bin/sh
cd /root/google_code/tomato-autovpn/trunk
cd grace/routeg
#python gfwlist.py
cd ../../
svn rm openvpn.tar.gz
svn ci -m "`date` update"
mkdir openvpn
cp -rf grace/* openvpn
rm -rf openvpn/.svn
rm -rf openvpn/routeg/.svn
tar -zcvf openvpn.tar.gz openvpn
svn add openvpn.tar.gz
svn ci -m "$(date) add"
rm -rf openvpn
lftp h.enjoydiy.com <<EOF
user ttpublic 'Public123!'
rm openvpn.tar.gz
put openvpn.tar.gz
rm route-grace
put grace/routeg/route-grace
put grace/routeg/vpnupadsl.sh
put grace/routeg/vpndownadsl.sh
bye
EOF
