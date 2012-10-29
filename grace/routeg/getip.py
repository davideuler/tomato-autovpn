#!/usr/bin/env python

import urllib
import base64
import string
#from socket import gethostbyname
import dns.resolver
import sys
import re

def isipaddr(hostname=''): 
        pat = re.compile(r'[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
        if re.match(pat, hostname):
                return 0
        else:
                return -1

def getip(hostname=''):
        _ip = []
        if isipaddr(hostname) == 0:
                print hostname + " is IP address"
                _ip.append(hostname)
                return
        r = dns.resolver.get_default_resolver()
        r.nameservers=['8.8.8.8']
        #answers = dns.resolver.query(hostname, 'A')
        try:
                answers = r.query(hostname, 'A')
		print "querying "+hostname
                for rdata in answers:
                        print rdata.address
                        _ip.append(rdata.address)
        except dns.resolver.NoAnswer:
                print "no answer"

        if hostname.find("www.") != 0:
                hostname = "www."+hostname
                print "querying "+hostname
                try:
                        answers = dns.resolver.query(hostname, 'A')
                        for rdata in answers:
                                print rdata.address
                                _ip.append(rdata.address)
                except dns.resolver.NoAnswer:
                        print "no answer"

        return list(set(_ip))

ip = []
for i in range(1, len(sys.argv)):  
	ip += getip(sys.argv[i])

iplist = list(set(ip))
iplist.sort()

print "----------------------------------------------------"
for ip in iplist:
	print "route add -host "+ip+" gw $VPNGW"

print "----------------------------------------------------"
#print sys.argv[1]
