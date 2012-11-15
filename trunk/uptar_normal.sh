#!/bin/sh
svn rm openvpn_normal.tar.gz
svn ci -m "`date` update"
cp grace/*.sh normal/
mkdir openvpn
cp -rf normal/* openvpn
rm -rf openvpn/.svn
rm -rf openvpn/routeg/.svn
tar -zcvf openvpn_normal.tar.gz openvpn
svn add openvpn_normal.tar.gz
svn ci -m "$(date) add"
rm -rf openvpn
