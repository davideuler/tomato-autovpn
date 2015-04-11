tautovpn是从chnroutes和autoddvpn启发而来的一套完整的解决方案。他可以让Tomato路由器达到自动翻墙的效果。让连接到路由器上的设备能够自动翻墙墙，客户端无论是Windows，IPhone，IPad还是MAC等都感觉不到任何麻烦直接访问全球所有的网站，完全感觉不到墙的存在。

# 项目位置： #

Google Code托管地址：

http://code.google.com/p/tomato-autovpn/

GitHub 托管地址：

https://github.com/enjoydiy/ttautovpn

具体的安装方法请参考：
http://blog.enjoydiy.com/2012/10/897.html

一键安装tar包下载地址：

http://tomato-autovpn.googlecode.com/svn/trunk/openvpn.tar.gz

tomato系统缺陷带来的影响：（官方已经在协助解决，详见 [issue 1](https://code.google.com/p/tomato-autovpn/issues/detail?id=1) ）

主要是由于DNSMASQ程序运行极其的不稳定，经常自动重启，每次重启都会导致NAT表丢失，路由丢失或者默认网关丢失，给我们带来很多的麻烦，已经向官方提出，但官方好像并不注重我们的问题，tomato的这个bug会导致网络数据不能走VPN，所以在脚本中我们已经尽量去弥补这个不足，这些功能主要靠那个循环运行的脚本实现。（



# 关键文件说明： #

1、startopenvpn.sh 这个是openvpn的启动和检测纠错脚本，建议每隔3分钟运行一下，开机启动运行一下。

2、tools.sh 这个是管理工具，主要有如下功能：

```
 The functions lists: 
———————————————- 
1.Set openvpn account and password (设置VPN的账号和密码) 
2.Set a IP through VPN    （将一个ip强迫走VPN） 
3.Set a IP through your network （将一个ip强迫走本地网络） 
4.Clean up the your own network routes lists （清除自定义的路由表） 
5.Start the openvpn daemon （启动openvpn程序） 
6.Update routes from network （从网络下载最新的路由表） 
7.Set openvpn server address （设置OPENVPN服务器地址） 
8.Update the tools  （更新本工具） 
9.exit and enjoy your life 
———————————————-
```
你可以在终端里直接运行： 输入 /jffs/openvpn/tools.sh

然后按照提示输入相应的数字即可。（[tools.sh的具体功能访问这里](http://code.google.com/p/tomato-autovpn/wiki/tools)）

3、ca.crt 是证书文件，需要将服务商证书覆盖

4、ca.key是私钥文件

5、vpn1.ovpn 是VPN的配置文件

6、passwd.txt 是openvpn的账号和密码

# 使用说明： #
1、首先需要打开jffs

2、在诊断工具-系统命令中输入
```
wget http://tomato-autovpn.googlecode.com/svn/trunk/openvpn.tar.gz -O /jffs/openvpn.tar.gz
cd /jffs/
tar -zxvf openvpn.tar.gz
chmod 777 -R *
```

3、一键包默认是提供我的服务器证书和key文件，需要你的服务商的文件覆盖，如果没有openvpn账号可以联系我购买。
这里采用的是账号密码认证，需要一个证书和key文件
还是这个那个命令框里输入：
```
/jffs/openvpn/tools.sh 1 你的账号 你的密码
```
执行，这一步将账号和密码写入了配置文件，

然后下一步将证书写入：
```
cat >>/jffs/openvpn/ca.crt <<
这里写证书内容
EOF
```
然后点执行。

下一步写入key：
```
cat >>/jffs/openvpn/ca.key <<
key内容
EOF
```
然后是服务器地址和连接类型
举个例子吧，比如服务器的IP是vpn.enjoydiy.com 端口为53 协议类型为tcp
执行这个命令：
```
/jffs/openvpn/tools.sh 7 vpn.enjoydiy.com 53 tcp
```
返回ok即可。

4、文件都准备好了，接下来就很简单了
到高级设置-DNCP/DNS里面 dnsmasq添加：
```
address=/www.facebook.com/66.220.146.94
address=/www.youtube.com/72.14.203.190
address=/twitter.com/199.59.148.82
address=/www.twitter.com/199.59.148.82
address=/api.twitter.com/199.59.148.87
address=/mobile.twitter.com/199.59.148.96
address=/platform.twitter.com/23.59.181.55
address=/encrypted.google.com/72.14.203.100
address=/s.nexttv.com.tw/203.69.138.24
address=/av.vimeo.com/64.211.21.119
address=/attachment.fbsbx.com/69.63.189.81
address=/www.fbsbx.com/69.63.189.81
server=/google.com/8.8.8.8
server=/appspot.com/8.8.8.8
server=/facebook.com/8.8.8.8
server=/fbcdn.net/8.8.8.8
server=/twitter.com/8.8.8.8
server=/youtube.com/8.8.8.8
server=/ytimg.com/8.8.8.8
server=/imageshack.us/8.8.8.8
server=/books.com.tw/8.8.8.8
server=/book.com.tw/8.8.8.8
server=/nownews.com/8.8.8.8
server=/gov.tw/8.8.8.8
```
这些内容可以参考http://code.google.com/p/tomato-autovpn/source/browse/trunk/grace/routeg/dnsmasq

5、然后到系统管理-定时任务里输入
```
sh /jffs/openvpn/startopenvpn.sh 
```
设置每隔3分钟或者1分钟执行一下即可

6、然后到系统管理-脚本设置里输入：
```
insmod /lib/modules/2.6.22.19/kernel/drivers/net/tun.ko
date -s "2012-10-10 12:12:12" 
```
7、当WAN联机输入：
```
sh /jffs/openvpn/startopenvpn.sh 
```

# 重要提示： #

目前还无法在tomato上面找到一个稳定的方法获取openvpn服务器端的内网IP，一般为10.8.0.1，目前的做法是在openvpn连接时候server会将该信息push下来，我们从log中找到了这个IP，但不保证所有的openvpn的服务商都能满足，如果获取不到这个IP，我们的检测程序将无法正常运行，检测方法是：

在终端中运行：
```
nvram get openvpnsrv
```
如果能返回一个IP地址，然后你ping下这个地址，如果能通，说明已经能获取到了。

如果不通或者无法获取到IP，则需要你问下你的服务商，服务器的内网IP是多少，然后做如下设置：
```
nvram set openvpnsrv=服务商给你的服务器内网ip
nvram commit
```

该项目一个人费了很多精力去完成，免费提供给网友，请大家转载注明出处:http://blog.enjoydiy.com http://bbs.enjoydiy.com

作者E-mail:admin@enjoydiy.com aefskw@gmail.com

为了方便没有openvpn账号的网友，我的服务器限量提供openvpn账号，仅仅是为了付服务器的费用才收费的，价格不高，请体谅，网址http://auction1.paipai.com/2C2F760300000000002C3B5B082759B7
或者http://bbs.enjoydiy.com 可以自助注册和续费（支付宝）