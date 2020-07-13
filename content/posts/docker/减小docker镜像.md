---
title: "减小docker镜像体积"
date: 2020-07-13T13:27:39+08:00
draft: false
tags:
    - docker
categories: 
    - docker
---

> 之前在构建docker镜像的时候，发现自己构建的镜像体积非常大，有时候我只需要用一个几MB的可执行文件，但是构建出来的镜像居然能达到GB级别，真是有点蛋疼。这里记录下我是怎么一步步缩小镜像体积的。

## 普通构建
普通构建也是新手使用最多的构建方式，同时也是最容易把镜像体积搞得非常大的方式，这里拿一个简单的示例演示一下。
```golang
/* hello.go */
package main

import (
	"fmt"
	"time"
)

func main() {
	for i := 0; i < 20; i++ {
		fmt.Printf("hello %v\n", i)
		time.Sleep(time.Second)
	}
}
```
然后使用以下的`Dockerfile`进行构建
```Dockerfile
FROM golang:1.13.12

WORKDIR /root

COPY hello.go .

RUN go build -o hello hello.go

CMD ["./hello"]
```
执行构建：`docker build -t alpine-hello:1.0 .`
然后再来看一下构建出来的镜像大小
```
REPOSITORY      TAG  IMAGE ID         CREATED         SIZE
golang-hello    1.0  6c10ea37cab0     5 seconds ago   805MB
```
居然达到了`805MB`，主要是这个镜像里面包含了golang编译器，实际可执行文件的大小我们来看一下
```
[root@n73 dockerfile]# ls -lh hello
-rwxr-xr-x. 1 root root 2.0M Jul 13 13:41 hello
```
只有`2MB`，所以为了较小镜像大小，所以就有了以下方法。
## 多阶段构建
要想大幅度减少镜像的体积，多阶段构建是必不可少的。多阶段构建的想法很简单：“我不想在最终的镜像中包含一堆Go 编译器和整个编译工具链，我只要一个编译好的可执行文件！”

多阶段构建可以由多个`FROM`指令识别，每一个`FROM`语句表示一个新的构建阶段，阶段名称可以用`AS`参数指定，例如：
```Dockerfile
FROM golang:1.13.12 as buildenv

WORKDIR /root

COPY hello.go .

RUN go build -o hello hello.go

FROM alpine:3.7

COPY --from=buildenv /root/hello .

CMD ["./hello"]
```
构建完我们看一下镜像大小
```
REPOSITORY      TAG     IMAGE ID        CREATED         SIZE
alpine-hello    1.0     296e9ef7f6a3    8 seconds ago   6.23MB
```
只有`6.23MB`了，比之前的`805MB`较少了`99%`!
另外需要注意以下几点：
#### 构建阶段
在声明构建阶段时，可以不必使用关键词 AS，最终阶段拷贝文件时可以直接使用序号表示之前的构建阶段（从零开始）。也就是说，下面两行是等效的
```
COPY --from=buildenv /root/hello . 
COPY --from=0 /root/hello . 
```
如果 Dockerfile 内容不是很复杂，构建阶段也不是很多，可以直接使用序号表示构建阶段。一旦 Dockerfile 变复杂了，构建阶段增多了，最好还是通过关键词 AS 为每个阶段命名，这样也便于后期维护。
#### 使用经典的基础镜像
一般在构建的第一阶段使用经典的基础镜像，这里经典的镜像指的是 CentOS，Debian，Fedora 和 Ubuntu 之类的镜像，也可以使用官方提供的基础镜像，可自行在[dockerhub](https://hub.docker.com/)查看
#### COPY --from 使用绝对路径
从上一个构建阶段拷贝文件时，使用的路径是相对于上一阶段的根目录的。如果你使用`golang`镜像作为构建阶段的基础镜像，就会遇到类似的问题。
因为`COPY`命令想要拷贝的是`/hello`，而`golang`镜像的`WORKDIR`是`/go`，所以可执行文件的真正路径是`/go/hello`。所以上面的示例我都是使用绝对路径，并且在第一阶段指定`WORKDIR`，这样就能保证万无一失。

到这里，我们的镜像体积已经非常小了，还能做到更小吗？当然是可以的，但是代价是，几乎没法调试，如果没有特殊需求，上面的方案是比较推荐的。
## 最小构建
将多阶段构建的第二阶段的基础镜像改为`scratch`就能做到更小的镜像，
```Dockerfile
FROM golang:1.13.12 as buildenv

WORKDIR /root

COPY hello.go .

RUN go build -o hello hello.go

FROM scratch

COPY --from=buildenv /root/hello .

CMD ["./hello"]
```
构建完看一下大小
```
REPOSITORY      TAG     IMAGE ID        CREATED         SIZE
scratch-hello    1.0    2e58c9f0f4a4    4 seconds ago   2.03MB
```
到这，镜像体积基本达到最小了，已经无限接近于可执行文件的大小了。但是有几个缺陷
- 缺少shell
- 缺少调试工具
- 缺少 libc

所以缺点也是非常明显的，没法调试，可能程序还会出现部分问题。

## 总结
使用`scratch`会将镜像体积降低到接近可执行文件的大小，但是由于调试麻烦，所以推荐第二种方案，使用`alpine`,`busybox`,虽然它们多了那么几 MB，但从整体来看，这只是牺牲了少量的空间来换取调试的便利性，还是很值得的。
