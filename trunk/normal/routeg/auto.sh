#!/bin/sh
cd /root/google_code/tomato-autovpn/trunk/normal/routeg
python chnroutes.py -p linux
echo "#$(date "+%Y/%m/%d") created by http://bbs.enjoydiy.com" > up.sh
echo "#QQ:58076972 E-mail:admin@enjoydiy.com" >> up.sh
echo "#$(date "+%Y/%m/%d") created by http://bbs.enjoydiy.com" > down.sh
echo "#QQ:58076972 E-mail:admin@enjoydiy.com" >> down.sh
grep ^route ip-pre-up >> up.sh
grep ^route ip-down >> down.sh
rm ip-pre-up ip-down
svn ci -m aa
