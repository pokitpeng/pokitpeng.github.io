---
title: "Golang命令行解析之flag"
date: 2020-08-17T21:59:50+08:00
draft: false
tags:
    - golang
categories: 
    - golang
---

## 简介
在`Golang`程序中有很多种方法来处理命令行参数，主要有以下三种方案：
1. `os.Args`：能达到目的但是不太友好
2. golang标准库`flag`：简单实用，轻量使用
3. 开源库`Cobra`：便捷强大，快速构建CLI应用程序
这章主要围绕golang标准库`flag`来展开，后面会分享`Cobra`的使用和项目上的一些示例。

## flag基础用法
下面编写一个简单的示例，帮助我们了解标准库flag的基本使用，代码如下:
```golang
package main

import (
	"flag"
	"fmt"
)

func main() {
	var (
		host string
		port int
	)

	flag.StringVar(&host, "host", "127.0.0.1", "Server startup address")
	flag.IntVar(&port, "port", 8080, "Server startup port")
	flag.Parse()

	fmt.Printf("host:%s\n", host)
	fmt.Printf("port:%d\n", port)
}
```
使用方法：
```bash
[root@n29 tmp]# ./flag -h
Usage of ./flag:
  -host string
    	Server startup address (default "127.0.0.1")
  -port int
    	Server startup port (default 8080)

[root@n29 tmp]# ./flag
host:127.0.0.1
port:8080

[root@n29 tmp]# ./flag -host 0.0.0.0 -port 9090
host:0.0.0.0
port:9090
```
上面就是flag包的常见使用方法，是不是非常简单？
## flag进阶用法
但是在日常使用的CLI应用程序中，最常见的功能是子命令的使用。一个工具可能包含了大量相关联的功能命令，以此形成工具集，可以说是刚需，那么这个功能在标准库flag中是如何实现的呢？示例如下：
```golang
package main

import (
    "flag"
    "fmt"
)

func main() {
	var (
		name string
		age int
	)
	flag.Parse()
	addCmd:=flag.NewFlagSet("add",flag.ExitOnError)
	addCmd.StringVar(&name,"name","tom","add student name")
	addCmd.IntVar(&age,"age",18,"add student age")
	
	listCmd := flag.NewFlagSet("list",flag.ExitOnError)
	listCmd.StringVar(&name,"name","pokit","list student info by name")

	args:=flag.Args()
	if len(args)<1{
		fmt.Println("expected 'add' or 'list' subcommands")
		return
	}
	switch args[0]{
	case "add":
		_=addCmd.Parse(args[1:])
	case "list":
		_=listCmd.Parse(args[1:])
	default:
		fmt.Println("expected 'add' or 'list' subcommands")
		return
	}
	fmt.Println("name:"+name)
}
```
使用方法：
```bash
[root@n29 tmp]# ./flag 
expected 'add' or 'list' subcommands

[root@n29 tmp]# ./flag add
name:tom
age:18

[root@n29 tmp]# ./flag add -h
Usage of add:
  -age int
    	add student age (default 18)
  -name string
    	add student name (default "tom")

[root@n29 tmp]# ./flag add -name pokit
name:pokit
age:18

[root@n29 tmp]# ./flag log -enable false
enable log:true

[root@n29 tmp]# ./flag log -enable=false
enable log:false
```
可以看到`bool`类型的解析还有一点小坑，稍不注意就会弄错。

## 多阶段解析
<!-- TODO -->

## 总结
以上就对标准库flag进行了简要的介绍，在日常开发过程中，flag扮演着不可或缺的角色。