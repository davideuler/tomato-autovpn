#!/bin/sh
svn rm openvpn_normal.tar.gz
svn ci -m "`date` update"
cp grace/*.sh normal/
mkdir openvpn
cp -rf normal/* openvpn
tar -zcvf openvpn_normal.tar.gz openvpn
svn add openvpn_normal.tar.gz
svn ci -m "$(date) add"
rm -rf openvpn
