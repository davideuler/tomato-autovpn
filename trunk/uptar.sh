#!/bin/sh
svn rm openvpn.tar.gz
svn ci -m "`date` update"
cp -rf grace/* openvpn
tar -zcvf openvpn.tar.gz openvpn
svn add openvpn.tar.gz
svn ci -m "$(date) add"
