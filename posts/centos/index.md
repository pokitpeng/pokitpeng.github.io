# linux


# Centos常用操作

### 代理
```shell
# 设置当前终端代理
export ALL_PROXY=http://192.168.30.106:1080

# 取消代理
unset ALL_RPOXY

# git添加代理
git config --global http.proxy http://192.168.30.106:1080
git config --global https.proxy http://192.168.30.106:1080 

# 检查
git config --list

# 取消
git config --global --unset http.proxy
git config --global --unset https.proxy
```

### 永久关闭防火墙
```shell
systemctl stop firewalld.service && systemctl disable firewalld.service
```

### 更改ip
```shell
vi /etc/sysconfig/network-scripts/ifcfg-*
# 修改内容：
BOOTPROTO=static #dhcp改为static（修改）
ONBOOT=yes #开机启用本配置，一般在最后一行（修改）
IPADDR=192.168.50.121
GATEWAY=192.168.50.1
NETMASK=255.255.255.0

# 万兆网卡：
IPADDR=10.0.241.41
NETMASK=255.255.255.0
PREFIX=24
```

### 生效ip
```shell
service network restart 

#或者
systemctl restart network
```

### hostname
hostname设置： 
```shell
hostnamectl --static set-hostname n121
```

### 设置DNS
vi /etc/resolv.conf
nameserver 8.8.8.8
```shell
echo "nameserver 114.114.114.114 " >> /etc/resolv.conf
```

### 时间修改
```shell
date -s '2020-01-21 14:54:00'
```

### 网络时间同步
1. chrony
```shell
yum install -y chrony
/etc/chrony.conf

systemctl enable chronyd
systemctl start chronyd
# 检查时间同步
chronyc sources
```

2. rdate命令来同步时间
```shell
yum -y install rdate && rdate -s time-b.nist.gov 
```

3. 安装ntpdate工具：
```shell
yum -y install ntp ntpdate

设置系统时间与网络时间同步
ntpdate cn.pool.ntp.org

ntpdate ntp.aliyun.com     #阿里云镜像

yum -y install ntp ntpdate && ntpdate ntp.aliyun.com

#如果the NTP socket is in use, exiting
service ntpd stop && ntpdate ntp.aliyun.com   

#修改时区：
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

timedatectl set-timezone Asia/Shanghai
timedatectl status
#选择时区：
tzselect
```

### SELinux
```
#查看SELinux状态
/usr/sbin/sestatus -v 或者 getenforce
#临时关闭（不用重启机器）
setenforce 0
#永久关闭，修改配置文件需要重启机器
#修改/etc/selinux/config 文件
#将SELINUX=enforcing改为SELINUX=disabled
sed -ri 's#(SELINUX=).*#\1disabled#' /etc/selinux/config

#重启机器即可
```

### scp免密码传文件
```shell
sshpass -p 'dana.com2018' scp `ls` root@192.168.50.4:/mnt/data/55_gitlab_backup/

-o StrictHostKeyChecking=no 避免第一次登录出现公钥检查。
https://blog.csdn.net/typa01_kk/article/details/42239553
gitlab定时更新并传到指定节点
cd /gitlab-data/gitlab_back \
&& rm -rf `ls -t |grep backup.tar|tail -n +3` \
&& sshpass -p 'dana.com2018' scp `ls` root@192.168.50.4:/mnt/data/55_gitlab_backup/
```

### ssh互通
生成公钥和私钥：`ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''`

将公钥拷贝到44节点上实现互通 （其实就是把公钥放到远端~/.ssh/authorized_keys中）
```shell
ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@192.168.3.44
```

### 添加用户和组
```shell
groupadd elsearch

useradd elsearch -g elsearch -p elasticsearch

chown -R elsearch:elsearch elasticsearch

su elsearch
```

### 文件统计
统计当前路径下文件的个数：
```
ls -l |grep "^-"|wc -l
```

统计当前路径下文件夹的个数：
```
ls -l |grep "^d"|wc -l
```
统计当前路径下文件的个数（包括子文件夹夹里面的）：
```
ls -lR|grep "^-"|wc -l
```

统计当前路径下文件夹的个数（包括子文件夹夹里面的）：
```
ls -lR |grep "^d"|wc -l
```

如统计/home/han目录(包含子目录)下的所有js文件则：
```ls -lR /home/han|grep js|wc -l 或 ls -l "/home/han"|grep "js"|wc -l
```

### yum下载离线 RPM 包及其所有依赖
```shell
yum install --downloaddir=/tmp/whj/ --downloadonly glibc-devel.i686
--downloadonly只下载不安装
--downloaddir下载的rpm包的存放路径
yum reinstall -y --downloadonly --downloaddir=/tmp/rpmpkg/neovim neovim  //重新安装，并指定路径

通过这种方法，可以把绝大部分需要安装的rpm包保存下来.将所需rpm包拷贝到目的主机，文件目录下执行
rpm -ivhU *  --nodeps --force

命令即可实现服务安装。
```
### 小技巧
执行命令自动输入yes：
```
echo yes | yum install wget
```
安装保存日志
```
./install.sh | tee log.txt
```
分割文件:
```
split -b 100M nginx.log -d -a 3 split_file
#把nginx.log文件分割成100MB大小 , 新文件已split开头,2位长度的数字结尾
```
glances监控安装
```shell
yum install epel* -y
yum install python-pip python-devel -y
yum install glances -y
```


查看系统版本：
```
cat /etc/*release
```
查看系统所有服务：
```
1、service --status-all
2、chkconfig --list
3、进入init.d目录查看 （/etc/init.d/leopardservices status）
4、netstat -lntp
5、ps aux
6、ntsysv （其中*号表示开机启动。空格选择或者取消，tab选择退出，如果想让某个服务开机启动，可以使用chkconfig mysql on）
```

查看指定目录大小：
```
du -sh /root
```
杀进程：
```
pkill -f name
ps -elf |grep -v grep|grep $1|awk '{print $4}'
```
只保留当前文件夹最近的2个文件
```
rm -rf `ls -t |tail -n +3`
```



