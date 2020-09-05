---
title: "K8S部署"
date: 2020-09-05T09:07:40+08:00
draft: false
tags:
    - k8s
categories: 
    - k8s
---


## 1. 环境准备

- centos 7.6+
- cpu core 2+
- mem 2GB+
- ip

## 2. 初始化工作

### 2.1. 设置hostname，同步时间

```bash
hostnamectl --static set-hostname n66

date -s '2020-09-04 21:54:00' 

yum install -y chrony
systemctl enable chronyd  && systemctl start chronyd
chronyc sources
```

### 2.2. 设置/etc/hosts

该命令是幂等的

```bash
grep "192.168.50.66 n66" /etc/hosts && sed -ir "s/.*n66$/192.168.50.66\ n66/g" /etc/hosts || echo "192.168.50.66 n66" >> /etc/hosts
```

### 2.3. 关闭防火墙、selinux和swap

```bash
systemctl stop firewalld

systemctl disable firewalld

setenforce 0

sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

swapoff -a

sed -i 's/.*swap.*/#&/' /etc/fstab
```

### 2.4. 配置内核参数

将桥接的IPv4流量传递到iptables的链

```bash
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#生效
sysctl --system
```

### 2.5. 配置yum源

```bash
yum install -y wget

mkdir /etc/yum.repos.d/bak && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo

wget -O /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo

yum clean all && yum makecache
```

### 2.6. 配置docker源

```bash
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo 
```

### 2.7. 配置Kubernetes源

```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

## 3. 开始部署

### 3.1. 安装docker

> 技巧：使用`yum list --showduplicates xxx`命令查看需要安装的软件版本

```bash
yum install -y docker-ce-19.03.12-3.el7 
# 这里也可不指定版本号，安装最新版

systemctl start docker
systemctl enable docker 

docker version
```

此处最好再配置以下docker镜像源和cgroup信息

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://hxzfq25s.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 3.2. 安装kubelet，kubectl，kubeadm

```bash
yum install -y kubelet-1.19.0 kubeadm-1.19.0 kubectl-1.19.0

systemctl start kubelet
systemctl enable kubelet
```

### 3.3. 执行初始化

> apiserver-advertise-address: 本机网卡ip

```bash
kubeadm init --kubernetes-version=1.19.0 --apiserver-advertise-address=192.168.50.66 --image-repository registry.aliyuncs.com/google_containers

# 可选参数
--pod-network-cidr=10.244.0.0/16
```

### 3.4. 保存配置文件

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 该文件是添加集群的认证文件
kubeadm join 192.168.50.66:6443 --token f5tpkb.s2afvo0ucr39w2vv \
    --discovery-token-ca-cert-hash sha256:655259c2004973875e2e963adce1b11386db0c65420c6a7687b8887b228ab5c7
```

### 3.5. token相关

```bash
# 查看token
kubeadm token list

# 获取ca证书sha256编码hash值
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

# 加入node
kubeadm join <ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash_value>

kubeadm token create --print-join-command # 默认有效期24小时,若想久一些可以结合--ttl参数,设为0则用不过期
kubeadm token create --ttl 0 --print-join-command
```

### 3.6. 安装网络插件

以下两个网络插件二选一

```bash
# flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# calico 这个貌似稳定点
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### 3.7. 开启单机模式

查看当前taint情况

```bash
kubectl describe node n66

# Taints默认为node-role.kubernetes.io/master:NoSchedule
# 表示不允许被调度
```

删除taint

```bash
kubectl taint n66 pokit node-role.kubernetes.io/master-
```

再次查看

```bash
kubectl describe node n66

# Taints为<none>
# 此时节点可被调度

# taint有三个值
# NoSchedule: 一定不能被调度
# PreferNoSchedule: 尽量不要调度
# NoExecute: 不仅不会调度, 还会驱逐Node上已有的Pod
```

恢复默认状态

```bash
kubectl taint nodes n66 node-role.kubernetes.io/master=:NoSchedule
```

### 3.8. 创建一个测试程序

```bash
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
```

### 3.9. 查看状态

```bash
kubectl get all --all-namespaces
```

## 4. 问题及解决方案

### 4.1. connect refuse

apiserver

scheduler

```bash
kubectl get cs
# connect refuse

vi /etc/kubernetes/manifests/kube-apiserver.yaml
vi /etc/kubernetes/manifests/kube-scheduler.yaml

#注释 --port=0  即可
```

