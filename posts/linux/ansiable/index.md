# Ansiable自动化运维


> 前段时间公司测试环境一直在更换，而每次更换环境都是一件非常痛苦的事情，因为新的操作系统都要做很多的初始化工作，一个节点两个节点还没什么，一旦节点多了，每次做重复的事情就显得很浪费时间而且容器出错，于是就花了几个小时研究一了下`ansiable`这款工具，虽然研究的不深，但是满足自己的日常所需了。

## 简介

`Ansible`是一款简单的运维自动化工具，使用ssh协议连接来进行系统管理、自动化执行命令、部署等任务，因此不需要单独安装客户端，也不需要启动任何服务。而且`ansible`有个很厉害的特性就是`幂等性`，允许多次重复执行，再也不用担心用多了把系统搞乱了。

## Ansible组成结构

- Ansible

Ansible的命令工具，核心执行工具；一次性或临时执行的操作都是通过该命令执行。

- Ansible Playbook

又称任务集，编排定义Ansible任务集的配置文件，由Ansible顺序依次执行，yaml格式。

- Inventory

Ansible管理主机的清单，默认是/etc/ansible/hosts文件。

- Modules

Ansible执行命令的功能模块，到Ansible 2.3版本为止，共有1039个模块，支持自定义模块，常用模块有command、shell、copy、fetch、file、yum、service、mount、cron、group、user等。

- Plugins

插件部分（对模块功能的补充），常有连接类型插件、循环插件、变量插件、过滤插件，插件功能用的较少。

- API

提供给第三方程序调用的应用程序编程接口。

## 使用

#### 安装

```bash
yum install -y epel-release ansible
```

#### 检查

```bash
rpm -qa|grep ansible
```

#### 生成私钥和秘钥

```bash
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
```

#### 配置远程机器，默认配置文件是`/etc/ansible/hosts`

```
# 方式一：每个节点单独的用户名密码
[remote]
192.168.50.200 ansible_ssh_user='root' ansible_ssh_pass='daemon'
192.168.50.29 ansible_ssh_user='root' ansible_ssh_pass='gj2019'

# 方式二：所有的节点都是同一个用户名密码
[remote]
192.168.50.200
192.168.50.201
[remote:vars]
ansible_ssh_pass='daemon'
ansible_ssh_user='root'

# 方式三：以上两种模式混合
[remote]
192.168.50.200
192.168.50.29 ansible_ssh_user='root' ansible_ssh_pass='gj2019'
[remote:vars]
ansible_ssh_pass='daemon'
ansible_ssh_user='root'
```

#### 去除密码检查

默认配置文件是`/etc/ansible/ansible.cfg`（71行）

```ini
#host_key_checking = False      # 去掉注释即可
```



#### ansiable常用选项

```bash
-a 后面跟着要执行的模块参数。
-k 输入SSH的登录密码
-K sudo提权的密码
-B SECONDS：后台运行超时时间
-f 指定要使用的并行进程数，default = 5
-i 指定库存主机文件，default = /etc/ansible/hosts
-m 要执行的模块名称，default = command
-s 运行sudo（nopasswd）
-T 指定SSH默认超时时间，default = 10
--version 显示程序版本号并退出
```

#### ansiable配置文件

默认配置文件路径为/etc/ansible/ansible.cfg，常用参数如下：

```bash
inventory   = /etc/ansible/hosts      #被控制的主机配置文件
library    = /usr/share/my_modules/  #Ansible默认搜寻模块的位置
remote_tmp   = ~/.ansible/tmp      #远程主机缓存目录
local_tmp   = ~/.ansible/tmp        #本地缓存目录
forks     = 5                     #这个选项设置在与主机通信时的默认并行进程数
poll_interval = 15                   #轮询时间
sudo_user   = root                #默认sudo用户
ask_sudo_pass = True               #默认sudo用户是否需要输入密码
ask_pass    = Fales                #每次执行都需要询问ssh密码
remote_port  = 22                 #被控主机默认端口
module_lang  = C                 #ansible默认语言
timeout    = 10                  #默认ssh尝试连接超时时间
```

#### 主机操作

```bash
# 远程操作所有主机
ansible all -m ping
# 远程操作某个分组主机
ansible <分组名> -m ping
# 远程操作某个主机
ansible <主机清单中的ip> -m ping
```

#### 模块应用

ansible命令格式：

```bash
ansible <主机清单中的ip或者分组名> -m <模块> -a "<参数>"
```

cron模块示例:

```bash
# 检查连通性
ansible remote -m ping

#同步当前主机时间
ntpdate ntp.aliyun.com

#cron模块示例
#每小时与时钟源同步一次
ansible remote -m cron -a 'name="test cron" job="ntpdate ntp.aliyun.com" minute=0 hour=*/1'

# copy模块示例
ansible remote -m copy -a 'src="/root/anaconda-ks.cfg" dest="/root/anaconda-ks.cfg"'
```

#### 执行shell命令

```bash
# -m shell -a
ansible remote -m shell -a  "netstat -anp|grep 80"

# -m raw -a 
ansible remote -m raw  -a "ifconfig|head -n 5"
```

#### 执行ansible-playbook

这里使用一个初始化操作系统的示例演示：

`init.yaml`文件内容如下：

```yaml
---
- hosts: remote
  # remote_usr: root
  # remote_pwd: daemon
  # gather_facts: no #开启debug

  tasks:
    - name: copy init file
      copy: src=~/init.sh dest=~/init.sh
    - name: exec init shell
      shell: bash ~/init.sh
      register: log
    - debug: var=log.stdout_lines   
```

`init.sh`文件内容如下：

```bash
#!/usr/bin/env bash

ip=`ip addr | grep 'state UP' -A2|grep 192.168|head -n 1|awk '{print $2}'|awk -F "/" '{print $1}'`
num=`echo ${ip}|awk -F "." '{print $4}'`

#设置hostname
hostnamectl --static set-hostname n${num}
echo "set hostname success"
echo hostname:`hostname`

#设置nameserver
echo "nameserver 114.114.114.114" > /etc/resolv.conf
echo "set nameserver success"

#安装基础工具
yum -y install vim rdate git > /dev/null 2>&1 && echo "install tools success" || echo "install tools field"

#vim基础配置
cat <<EOF >~/.vimrc
set number
set syntax=on
set tabstop=4
set autoindent
EOF

echo "alias vi='vim'" >> ~/.bashrc
source ~/.bashrc
echo "set vim success"

#时间同步
rdate -s time.nist.gov
echo "sync date success"
echo date:`date`

#关闭防火墙
systemctl stop firewalld && systemctl disable firewalld
echo "stop firewalld success"

#临时关闭SElinux
setenforce 0 2>1 /dev/null && echo "close SElinux success" || echo "close SElinux field"

#永久关闭SElinux(重启生效)
sed -ri 's#(SELINUX=).*#\1disabled#' /etc/selinux/config
echo "disabled SElinux success"
```

执行检查：`ansible-playbook init.yaml -C`

执行操作：`ansible-playbook init.yaml`

OK大功告成！

## 参考

https://ansible-tran.readthedocs.io/en/latest/docs/intro_installation.html

https://www.cnblogs.com/tongyishu/p/12918052.html

https://www.cnblogs.com/linuxk/p/11866765.html
