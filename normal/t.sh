#!/bin/sh
while read -r line
do
	echo aa$line
done < vpnup_custom
if [ -e a ]; then
	echo hello
fi
