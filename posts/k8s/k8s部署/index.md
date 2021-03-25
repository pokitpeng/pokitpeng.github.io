# K8S部署


> 前言：目前公司部署k8s全部都是使用二进制方式安装，我们自己写了一套工具来实现快速部署，优点是出了什么问题都在我们掌控之中，可以随时修复，里面的各种配置，证书都可以自己生成，缺点就是需要一定的维护成本。早已听闻`kubeadm`作为k8s官方推荐的部署工具，这里也来尝尝鲜。

## 1. 环境准备

- centos 7.6+
- cpu core 2+
- mem 2GB+
- ip

## 2. 初始化工作

### 2.1. 设置hostname，同步时间

```bash
hostnamectl --static set-hostname <host_name>

date -s '2020-09-04 21:54:00' 

yum install -y chrony
systemctl enable chronyd  && systemctl start chronyd
chronyc sources
```

### 2.2. 设置/etc/hosts

该命令是幂等的

```bash
# 查看ip
ip=$(ip address show |grep global|grep -v inet6|awk -F '[/ ]' '{print $6}'|grep 192.168)
echo ${ip}

grep "${ip} $(hostname)" /etc/hosts \
&& sed -ir "s/.*\$(hostname)$/${ip}\ \$(hostname)/g" /etc/hosts \
|| echo "${ip} $(hostname)" >> /etc/hosts
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
yum list --showduplicates docker-ce
yum install -y docker-ce-20.10.5-3.el7
# 这里也可不指定版本号，安装最新版

# 此处最好再配置一下docker镜像源和cgroup信息
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": ["https://hxzfq25s.mirror.aliyuncs.com"],
    "exec-opts": ["native.cgroupdriver=systemd"],
    "data-root": "/var/lib/docker",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "30m",
        "max-file": "5",
        "labels": "production_status"
    }
}
EOF
sudo systemctl daemon-reload
systemctl start docker
systemctl enable docker 
systemctl status docker 

docker version
```

### 3.2. 安装kubelet，kubectl，kubeadm

```bash
yum list --showduplicates kubelet
version=1.19.8;yum install -y kubelet-${version} kubeadm-${version} kubectl-${version}

systemctl enable kubelet
```

### 3.3. 执行初始化

> apiserver-advertise-address: 本机网卡ip



```bash
# 查看ip：
ip=$(ip address show |grep global|grep -v inet6|awk -F '[/ ]' '{print $6}'|grep 192.168)
echo ${ip}

kubeadm init \
--kubernetes-version=${version} \
--apiserver-advertise-address=${ip} \
--image-repository registry.aliyuncs.com/google_containers \
--pod-network-cidr=10.244.0.0/16 # 可选参数
```

### 3.4. 保存配置文件

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 查看状态
kubectl get node

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
kubectl describe node $(hostname)

# Taints默认为node-role.kubernetes.io/master:NoSchedule
# 表示不允许被调度
```

删除taint

```bash
kubectl taint node $(hostname) node-role.kubernetes.io/master-
```

再次查看

```bash
kubectl describe node $(hostname)

# Taints为<none>
# 此时节点可被调度

# taint有三个值
# NoSchedule: 一定不能被调度
# PreferNoSchedule: 尽量不要调度
# NoExecute: 不仅不会调度, 还会驱逐Node上已有的Pod
```

恢复默认状态

```bash
kubectl taint nodes $(hostname) node-role.kubernetes.io/master=:NoSchedule
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

`apiserver`和`scheduler`健康状态：`connect refuse`

```bash
kubectl get cs
# connect refuse

vi /etc/kubernetes/manifests/kube-controller-manager.yaml
vi /etc/kubernetes/manifests/kube-scheduler.yaml

#注释 --port=0  即可
```

### 4.2. 证书

```bash
# 查看证书有效时间
kubeadm alpha certs check-expiration

# 方法一：升级集群自动轮换证书
kubeadm upgrade apply --certificate-renewal v1.19.9

# 方法二：使用 kubeadm 手动生成并替换证书
# Step 1): Backup old certs and kubeconfigs
mkdir /etc/kubernetes.bak
cp -r /etc/kubernetes/pki/ /etc/kubernetes.bak
cp /etc/kubernetes/*.conf /etc/kubernetes.bak

# Step 2): Renew all certs
kubeadm alpha certs renew all --config kubeadm.yaml
# Step 3): Renew all kubeconfigs
kubeadm alpha kubeconfig user --client-name=admin
kubeadm alpha kubeconfig user --org system:masters --client-name kubernetes-admin  > /etc/kubernetes/admin.conf
kubeadm alpha kubeconfig user --client-name system:kube-controller-manager > /etc/kubernetes/controller-manager.conf
kubeadm alpha kubeconfig user --org system:nodes --client-name system:node:$(hostname) > /etc/kubernetes/kubelet.conf
kubeadm alpha kubeconfig user --client-name system:kube-scheduler > /etc/kubernetes/scheduler.conf

# Another way to renew kubeconfigs
# kubeadm init phase kubeconfig all --config kubeadm.yaml

# Step 4): Copy certs/kubeconfigs and restart Kubernetes services
```
> 参考： [证书轮换](https://feisky.gitbooks.io/kubernetes/content/practice/certificate-rotation.html)

## 5. 卸载
```bash
kubeadm reset -f
version=$(kubectl get no|grep master|awk '{print $5}'|sed 's/v//')
yum -y remove \
kubeadm-${version} \
kubectl-${version} \
kubelet-${version}
```

