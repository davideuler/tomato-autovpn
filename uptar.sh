#!/bin/sh
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
bye
EOF
