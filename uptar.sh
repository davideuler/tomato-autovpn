#!/bin/sh
svn rm openvpn.tar.gz
svn ci -m "`date` update"
mkdir openvpn
cp -rf grace/* openvpn
rm -rf openvpn/.svn
tar -zcvf openvpn.tar.gz openvpn
svn add openvpn.tar.gz
svn ci -m "$(date) add"
rm -rf openvpn
