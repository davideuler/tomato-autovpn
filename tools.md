tools.sh是一个管理工具，利用他可以完成控制和更新等功能，如果在终端中不加参数执行会有详细的功能介绍和引导界面。
[http://tomato-autovpn.googlecode.com/files/tomato-tools.sh.JPG](http://blog.enjoydiy.com)

终端中运行会有如下提示
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
9.Enable auto select fastest server
10.Set a prior server
11.Change the mode to normal
12.Change the mode to grace
13.exit and enjoy your life
———————————————-
```
这个可能不是最新的，由于tools.sh一直在更新。
运行这个脚本可以带参数，也可以不带参数，不带参数每一步都会有提示的。

带参数使用方法：
1、 设置账户和密码
```
/jffs/openvpn/tools.sh 1 账号 密码
```
> 输入这条命令既可设置openvpn的账号和密码
2、 将某个IP强制走VPN
```
/jffs/openvpn/tools.sh 2 ip地址
```
> 这个是立即生效的，并且下次重启后还会生效。

3、 强制走本地网络
> 这个用法和2一样的

4、 清除用户设置的路由信息
```
/jffs/openvpn/tools.sh 4
```
> 这样直接执行既可不用带任何参数，会清除掉你添加的路由信息

5、 启动openvpn
```
/jffs/oenvpn/tools.sh 5
```

6、 更新GFW list到本地
```
/jffs/openvpn/tools.sh 6
```

7、 设置openvpn服务器的地址、端口、协议类型
```
/jffs/openvpn/tools.sh 7 服务器地址 端口 协议（tcp或者udp）
```

8、 更新本工具和openvpn的启动脚本
```
/jffs/openvpn/tools.sh 8
```
> 有时候会有新的功能加入，执行这条命令即可更新到最新版本

9、 自动寻找最快的服务器
> 开启：
```
/jffs/openvpn/tools.sh 9 y
```
> 关闭：
```
/jffs/openvpn/tools.sh 9 n
```

10、 设置优先使用的服务器
```
/jffs/openvpn/tools.sh 10 服务器地址
```
> 当9号功能打开时候有效

11、 切换到normal模式
```
/jffs/openvpn/tools.sh 11
```
> 这个模式特点：所有国外的网站都走VPN

12、 切换到grace模式
```
/jffs/openvpn/tools.sh 12
```
> 切换到grace模式，这个模式特点：国内不能访问的网站走VPN，其他都走本地网络