# Iptables


# iptables常用操作
## iptables的基本语法格式
iptables [-t 表名] {-A|-D|-I|-F|-L|-Z|-P} 规则链名 [规则号] {-i/o 网卡名} -p 协议名 {-s 源IP/源子网} --sport 源端口 {-d 目标IP|目标子网} --dport 目标端口 -j 动作

## 参数说明
- -t：指定要操纵的表
- -A：向规则链中添加条目
- -D：从规则链中删除条目
- -I：向规则链中插入条目
- -R：替换规则链中的条目
- -L：显示规则链中已有的条目
- -E：重命名用户定义的链，不改变链本身
- -F：清空规则链中已有的条目
- -Z：清空规则链中的数据包计算器和字节计数器
- -N：创建新的用户自定义规则链
- -P：定义规则链中的默认策略
- -n  使用数字形式（numeric）显示输出结果
- -h：显示帮助信息
- -p：指定要匹配的数据包协议类型
- -s：指定要匹配的数据包源ip地址
- -j<目标>：指定要跳转的目标
- -i<网络接口>：指定数据包进入本机的网络接口
- -o<网络接口>：指定数据包要离开本机所使用的网络接口
- -v  查看规则表详细信息（verbose）的信息

### 表名包括
- raw：高级功能，如：网址过滤
- mangle：数据包修改（QOS），用于实现服务质量
- net：地址转换，用于网关路由器
- filter：包过滤，用于防火墙规则

### 规则链名包括
- INPUT链：处理输入数据包
- OUTPUT链：处理输出数据包
- PORWARD链：处理转发数据包
- PREROUTING链：用于目标地址转换（DNAT）
- POSTOUTING链：用于源地址转换（SNAT）

### 动作包括
- accept：接收数据包。
- DROP：丢弃数据包。
- REDIRECT：重定向、映射、透明代理。
- SNAT：源地址转换。
- DNAT：目标地址转换。
- MASQUERADE：IP伪装（NAT），用于ADSL。
- LOG：日志记录。

## 备份与恢复
```
#规则备份
iptables-save > /opt/iptables.txt

#清空规则
iptables -t nat -F

#查看
iptables -nL --line-number

#规则恢复
iptables-restore < /opt/iptables.txt
```

## 常用操作
```
# 查看所有规则
iptables -nL --line-number
# 只查看INPUT表
iptables -nL INPUT --line-number
# 删除规则
iptables -D INPUT 3  # 3为num号

# 开放所有输出入
iptables -P INPUT ACCEPT
#关闭所有输入，同时开启远程机和本机白名单
iptables -P INPUT DROP \
&& iptables -A INPUT -s 192.168.30.171 -p all -j ACCEPT \
&& iptables -A INPUT -s 192.168.50.97 -p all -j ACCEPT

#开启80端口
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#屏蔽单个IP的命令
iptables -I INPUT -s 123.45.6.7 -j DROP    
#封整个段即从123.0.0.1到123.255.255.254的命令
iptables -I INPUT -s 123.0.0.0/8 -j DROP      
#允许所有本机向外的访问
iptables -A OUTPUT -j ACCEPT    
#禁止其他未允许的规则访问
iptables -A INPUT -j reject  
#只允许192.168.0.3的机器进行SSH连接
iptables -A INPUT -s 192.168.0.3 -p tcp --dport 22 -j ACCEPT

#丢弃从外网接口（eth1）进入防火墙本机的源地址为私网地址的数据包
iptables -A INPUT -i eth1 -s 192.168.0.0/16 -j DROP
iptables -A INPUT -i eth1 -s 172.16.0.0/12 -j DROP
iptables -A INPUT -i eth1 -s 10.0.0.0/8 -j DROP

#封堵网段（192.168.1.0/24），两小时后解封
[root@server ~]$ iptables -I INPUT -s 10.20.30.0/24 -j DROP
[root@server ~]$ iptables -I FORWARD -s 10.20.30.0/24 -j DROP
[root@server ~]$ at now +2 hours
at> iptables -D INPUT 1
at> iptables -D FORWARD 1

#允许本机开放从TCP端口20-1024提供的应用服务
iptables -A INPUT -p tcp --dport 20:1024 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 20:1024 -j ACCEPT

#允许转发来自192.168.0.0/24局域网段的DNS解析请求数据包
iptables -A FORWARD -s 192.168.0.0/24 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -d 192.168.0.0/24 -p udp --sport 53 -j ACCEPT

#禁止其他主机ping防火墙主机，但是允许从防火墙上ping其他主机
iptables -I INPUT -p icmp --icmp-type Echo-Request -j DROP
iptables -I INPUT -p icmp --icmp-type Echo-Reply -j ACCEPT
iptables -I INPUT -p icmp --icmp-type destination-Unreachable -j ACCEPT

#禁止转发来自MAC地址为00：0C：29：27：55：3F的和主机的数据包
iptables -A FORWARD -m mac --mac-source 00:0c:29:27:55:3F -j DROP
#禁止转发源IP地址为192.168.1.20-192.168.1.99的TCP数据包
iptables -A FORWARD -p tcp -m iprange --src-range 192.168.1.20-192.168.1.99 -j DROP
#禁止转发与正常TCP连接无关的非—syn请求数据包
iptables -A FORWARD -m state --state NEW -p tcp ! --syn -j DROP

#只开放本机的web服务（80）、FTP(20、21、20450-20480)，放行外部主机发住服务器其它端口的应答数据包，
#将其他入站数据包均予以丢弃处理
iptables -I INPUT -p tcp -m multiport --dport 20,21,80 -j ACCEPT
iptables -I INPUT -p tcp --dport 20450:20480 -j ACCEPT
iptables -I INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
iptables -P INPUT DROP
```
