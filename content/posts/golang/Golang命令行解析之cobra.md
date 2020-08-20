---
title: "Golang命令行解析之cobra"
date: 2020-08-19T21:42:43+08:00
draft: true
tags:
    - golang
categories: 
    - golang
---

## 前言
在前一篇文章，我们讲到了golang的命令行解析工具`flag`和`pflag`，这次继续介绍一下`cobra`，`Cobra`是一个创建`CLI`命令行的 golang 库它提供了简单的接口来创建命令行程序。同时，`Cobra`也是一个应用程序，用来生成应用框架，市面上比较有名的`docker`，`kubectl`都是基于此工具开发。另外提一句，Cobra的作者[spf13](https://github.com/spf13)非常的牛掰，很多优秀的库都有这位大佬的身影，有兴趣的可以去看看。

## 简单使用
安装的方法比较简单：`go get -u github.com/spf13/cobra/cobra`，下载不了的，直接把git clone仓库到`GOPATH`下面，然后进入`cobra`目录直接`go build && go install`即可，然后使用`cobra`自带的`generator`生成项目。
```bash
pName=demo \
pPath=/home/pokit/demo/ \
&& mkdir -p ${pPath} \
&& cd  ${pPath} \
&& cobra init --pkg-name ${pName} \
&& go mod init ${pName}
```
这样就在当前目录下面生成了一个项目框架
```bash
├── cmd
│   └── root.go
├── go.mod
├── go.sum
├── LICENSE
└── main.go
```

## 进阶使用

## 总结

