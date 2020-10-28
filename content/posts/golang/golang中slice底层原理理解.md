---
title: "Golang中slice底层原理理解"
date: 2020-10-28T15:53:43+08:00
draft: false
tags:
    - golang
categories: 
    - golang
---
## 1. 前言
我们知道数组在初始化的时候会声明数组长度，使用的时候难免会有不方便的地方，于是就有了`slice`，所谓的切片其实就是动态数组，本质上是基于数组实现的，主要特点是定义完一个slice变量之后，不需要为它的容量而担心。
## 2. slice 结构
slice源码：[https://golang.org/src/runtime/slice.go?h=type%20slice%20struct#L13](https://golang.org/src/runtime/slice.go?h=type%20slice%20struct#L13)
```go
type slice struct {
	array unsafe.Pointer // 用来存储实际数据的数组指针，指向一块连续的内存
	len   int // 切片中元素的数量
	cap   int // 切片的容量
}
```
可以看到slice是由一个指针，len和cap组成，其中指针指向的是一个array。
## 3. 初始化
Go 语言中的切片有以下几种初始化的方式：
```go
arr[0:3] or slice[0:3]  // 使用下标截取
slice := make([]int, 0) // make关键字初始化一个空切片
slice := []int{} // 字面量初始化一个空切片
var slice []int // 声明一个nil切片
var slice []int = []int{1,2,3} // 声明并赋值
```
这里注意一下，其中make关键字初始化一个空切片`slice := make([]int, 0)`和字面量初始化一个空切片`slice := []int{}`两种方式几乎是等价的，他们底层数组为空，但是底层数组指针非空。对于`var slice []int`声明的切片，指针为`nil`，不会分配内存空间。但是，不管是空切片还是nil切片，对其调用内置函数`append()`、`len`和`cap`的效果都是一样的，感受不到任何区别。
## 4. 扩容
切片扩容有以下两个规则：

- 如果切片的容量小于1024个元素，那么扩容的时候slice的cap就翻番，乘以2；一旦元素个数超过1024个元素，增长因子就变成1.25，即每次增加原来容量的四分之一。
- 如果扩容之后，还没有触及原数组的容量，那么，切片中的指针指向的位置，就还是原数组，如果扩容之后，超过了原数组的容量，那么，Go就会开辟一块新的内存，把原来的值拷贝过来，这种情况丝毫不会影响到原数组。

我们来看下几个示例：
```go
// example1
s1 := []int{1, 2, 3}
s2 := s1
s2[0] = 10
fmt.Println(s1) // [10 2 3]
fmt.Println(s2) // [10 2 3] 
```
example1解析：切片是引用类型，传递的都是原始值的引用，会改变原始值
```go
// example2
s1 := [3]int{1, 2, 3}
s2 := s1
s2[0] = 10
fmt.Println(s1) // [1 2 3]
fmt.Println(s2) // [10 2 3] 
```
example2解析：数组是值类型，传递的是原始值的拷贝，不会改变原始值
```go
// example3
s1 := []int{1, 2, 3}
s2 := make([]int, 3)
copy(s2, s1)
s2[0] = 10
fmt.Println(s1) // [1 2 3]
fmt.Println(s2) // [10 2 3] 
```
example3解析：`copy`会进行深拷贝，将s1拷贝给s2，因此s2的改变不会改变原始值

```go
// example4
s1:=[3]int{1,2,3}
s2:=s1[:]
s2[0]=10
fmt.Println(s1) // [10 2 3]
fmt.Println(s2) // [10 2 3]
```
example4解析：新的切片s2底层数组是s1，改变s2的值会改变原始值

```go
// example5
s1 := [5]int{1, 2, 3, 4, 5}
s2 := make([]int, 4)
s2 = s1[0:3]        // s2 长度为3，容量为4
s2 = append(s2, 10) // 没有超出底层数组容量
s2[0] = 10          // 会改变底层数组
fmt.Println(s1)     // [10 2 3 10 5]
fmt.Println(s2)     // [10 2 3 10]

// ---------------------------------------
s1 := [5]int{1, 2, 3, 4, 5}
s2 := make([]int, 4)
s2 = s1[0:3]                // s2 长度为3，容量为4
s2 = append(s2, 10, 20, 30) // 超出底层数组容量，s2发生拷贝，此时s2是一个全新切片
s2[0] = 10                  // 不会改变底层数组
fmt.Println(s1)             // [1 2 3 4 5]
fmt.Println(s2)             // [10 2 3 10 20 30]

```
example5解析：只要知道超出底层数组容量的切片会拷贝出一个全新的切片，不影响原始底层数组。


以上，就是对go语言中切片的一些经验总结。

**参考**

[Go 语言切片的实现原理 | Go 语言设计与实现 (draveness.me)](https://draveness.me/golang/docs/part2-foundation/ch03-datastructure/golang-array-and-slice/#使用下标)

[快速理解Go数组和切片的内部实现原理 - 菜刚RyuGou的博客 (i6448038.github.io)](https://i6448038.github.io/2018/08/11/array-and-slice-principle/)

[如何避开 Go 中的各种陷阱 · NewtonIO (newt0n.github.io)](https://newt0n.github.io/2016/11/07/如何避开-Go-中的各种陷阱/)


