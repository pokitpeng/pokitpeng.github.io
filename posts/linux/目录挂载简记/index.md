# 目录挂载简记


# 目录挂载简记
> 平时使用linux过程中，经常遇到各种目录挂载的问题，这里记录下自己平时遇到的几种场景

## 挂载磁盘到目录
首先对磁盘进行格式化
```bash
mkfs -t ext4 /dev/sdf
```
如果磁盘被使用，出现以下报错
```
/dev/sdf is apparently in use by the system; will not make a filesystem here! 
```
则需要通过dm解决问题，首先查看dm状态，显示dm设备信息
```bash
dmsetup status
```
删除dm信息，并再次查看dm状态信息
```
dmsetup remove_all dmsetup status 
```
再进行格式化，挂盘
```bash
mkfs -t ext4 /dev/sdf
mount /dev/sdf /mnt
```
## 开机自动挂载磁盘到目录
查看需要挂载磁盘的UUID和TYPE
```bash
lsblk
blkid /dev/sdx
```
将需要添加的磁盘信息添加到开机自启中
/etc/fstab

## 挂载目录到另一个目录
注意：不要在挂载路径操作，不然会出错
```
mount --bind [挂载源] [挂载点]
mount --bind /home /root/tmp
umount /root/tmp
```
将挂载源挂载到挂载点上，挂载后，挂载点上的文件会被隐藏，取消挂载后，文件会显示出来

## 将windows上的目录挂载到linux上
> 前提要在windows上设置共享文件，添加用户和密码
```bash
mkdir -p /mnt/share && mount -t cifs -o username=Guest //192.168.30.106/Share /mnt/share
# 取消挂载:(切换到其他目录)
umount /mnt/share
```

umount 时提示错误 target is busy. (In some cases useful info about processes that use the device is found by lsof(8) or fuser(1)) , 可以先切换到别的目录再试一次 , 原因也可能是其他进程可能在使用目录 , 可以先关闭使用该目录的进程 , 然后再 umount , 命令如下 (使用 fuser 需安装 psmisc # yum install psmisc) :

```
# fuser -m /usr/local/bin/code
/usr/local/bin/code:  2806c

# ps aux | grep 2806
root      2806  0.0  0.5 116040  2836 pts/0    Ss   11:31   0:00 -bash
root      2925  0.0  0.1 112648   960 pts/0    S+   14:36   0:00 grep --color=auto 2806

# kill -9 2806

# umount /usr/local/bin/code
```
