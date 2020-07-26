---
title: "Golang中的接口"
date: 2020-07-26T10:43:54+08:00
draft: false
tags:
    - golang
categories: 
    - golang
---

## 接口介绍

### 现实中的接口

现实生活中手机、相机、U 盘都可以和电脑的`USB`接口建立连接。我们不需要关注 usb 卡槽 大小是否一样，因为所有的 USB 接口都是按照统一的标准来设计的。

### Golang中的接口

Golang 中的接口是一种抽象数据类型，Golang 中接口定义了对象的行为规范，只定义规范 不实现。接口中定义的规范由具体的对象来实现。通俗的讲接口就一个标准，它是对一个对象的行为和规范进行约定，约定实现接口的对象必 须得按照接口的规范。

## Golang接口定义

在 Golang 中接口（interface）是一种类型，一种抽象的类型。接口（interface）是一组 函数 method 的集合，Golang 中的接口不能包含任何变量。

在 Golang 中接口中的所有方法都没有方法体，接口定义了一个对象的行为规范，只定 义规范不实现。接口体现了程序设计的多态和`高内聚`,`低耦合`的思想。

Golang 中的接口也是一种数据类型，不需要显示实现。只需要一个变量含有接口类型 中的所有方法，那么这个变量就实现了这个接口。

Golang 中每个接口由数个方法组成，接口的定义格式如下：

```go
type 接口名 interface{ 
    方法名 1( 参数列表 1 ) 返回值列表 1 
    方法名 2( 参数列表 2 ) 返回值列表 2 
    … 
}
```

其中：

- **接口名**：使用 type 将接口定义为自定义的类型名。Go 语言的接口在命名时，一般会在 单词后面添加 `er`，如有写操作的接口叫`Writer`，有字符串功能的接口叫`Stringer`等。接 口名最好要能突出该接口的类型含义。
- **方法名**：当方法名首字母是大写且这个接口类型名首字母也是大写时，这个方法可以被 接口所在的包（package）之外的代码访问。
- **参数列表、返回值列表**：参数列表和返回值列表中的`参数变量名`可以省略。

示例1：定义一个`Usber`接口让`Phone`和`Mouse`结构体实现这个接口

```go
package main

import "fmt"

//Usber usb接口
type Usber interface {
	GetName() string
	PullIn()
	PullOut()
}

//Phone 手机结构体
type Phone struct {
	Name string
}

//手机类实现usb接口
func (p *Phone) GetName() string {
	return p.Name
}

func (p *Phone) PullIn() {
	fmt.Printf("%v 插入\n", p.Name)
}

func (p *Phone) PullOut() {
	fmt.Printf("%v 拔出\n", p.Name)
}

//Mouse 鼠标结构体
type Mouse struct {
	Name string
}

//鼠标类实现usb接口
func (m *Mouse) GetName() string {
	return m.Name
}

func (m *Mouse) PullIn() {
	fmt.Printf("%v 插入\n", m.Name)
}

func (m *Mouse) PullOut() {
	fmt.Printf("%v 拔出\n", m.Name)
}


func main() {
	var usb Usber

	xiaomi := &Phone{
		Name: "小米手机",
	}
	usb = xiaomi
	usb.PullIn()
	usb.PullOut()

	luoji := &Mouse{
		Name: "罗技鼠标",
	}
	usb = luoji
	usb.PullIn()
	usb.PullOut()
}

```

示例2：`Computer `结构体中的 `Work `方法必须传入一个 Usb 的接口

```go
package main

import "fmt"

//Usber usb接口
type Usber interface {
	GetName() string
	PullIn()
	PullOut()
}

//Phone 手机结构体
type Phone struct {
	Name string
}

//手机类实现usb接口
func (p *Phone) GetName() string {
	return p.Name
}

func (p *Phone) PullIn() {
	fmt.Printf("%v 插入\n", p.Name)
}

func (p *Phone) PullOut() {
	fmt.Printf("%v 拔出\n", p.Name)
}

//Mouse 鼠标结构体
type Mouse struct {
	Name string
}

//鼠标类实现usb接口
func (m *Mouse) GetName() string {
	return m.Name
}

func (m *Mouse) PullIn() {
	fmt.Printf("%v 插入\n", m.Name)
}

func (m *Mouse) PullOut() {
	fmt.Printf("%v 拔出\n", m.Name)
}

//Computer 电脑结构体
type Computer struct {
	Name string
}

//Worker 方法传入一个usb接口
func (c *Computer) Worker(usb Usber) {
	usb.PullIn()
	fmt.Printf("%v 拷贝文件到 %v\n", c.Name, usb.GetName())
	usb.PullOut()
}

func main() {
	var usb Usber

	xiaomi := &Phone{
		Name: "小米手机",
	}
	usb = xiaomi
	usb.PullIn()
	usb.PullOut()

	luoji := &Mouse{
		Name: "罗技鼠标",
	}
	usb = luoji
	usb.PullIn()
	usb.PullOut()

	fmt.Println("========")

	apple := &Computer{
		Name: "苹果电脑",
	}
	apple.Worker(xiaomi)
}

```



## 空接口

Golang 中的接口可以不定义任何方法，没有定义任何方法的接口就是空接口。空接口表示 没有任何约束，因此任何类型变量都可以实现空接口。 空接口在实际项目中用的是非常多的，用空接口可以表示`任意数据类型`。

### 空接口作为函数的参数

```go
func show(a interface{}) {
	fmt.Printf("type:%T value:%v\n", a, a)
}
```

### map 的值实现空接口

```go
m := make(map[string]interface{})
m["name"] = "tom"
m["age"] = 20
fmt.Println(m) // map[age:20 name:tom]
```

### 切片实现空接口

```go
 var s []interface{}
s = append(s, "tom")
s = append(s, 123)
s = append(s, true)
fmt.Println(s) // [tom 123 true]
```

## 类型空接口作为函数的参数断言

```go
x.(T)
```

`x`必须为`interface{}`类型的变量， `T`表示断言 `x` 可能是的类型，返回一个布尔值

```go
func AssetType(x interface{}) {
	switch v := x.(type) {
	case string:
		fmt.Printf("x is a string，value is %v\n", v)
	case int:
		fmt.Printf("x is a int is %v\n", v)
	case bool:
		fmt.Printf("x is a bool is %v\n", v)
	default:
		fmt.Println("unsupport type！")
	}
}
```

**关于接口需要注意的是**：只有当有`两个或两个以上的具体类型必须以相同的方式进行处理`时 才需要定义接口。不要为了接口而写接口，那样只会增加不必要的抽象，导致不必要的运行 时损耗。

## 结构体值接收者和指针接收者实现接口的区别

**值接收者**：如果结构体中的方法是值接收者，那么实例化后的结构体值类型和结构体指针类型都可以赋 值给接口变量

**指针接收者**：如果结构体中的方法是指针接收者，那么实例化后结构体指针类型都可以赋值给接口变量， 结构体值类型没法赋值给接口变量。

## 一个结构体实现多个接口

```go
package main

import "fmt"

type A interface {
	SetName(string)
}

type B interface {
	GetName() string
}

type Human struct {
	Name string
}

func (h *Human) SetName(name string) {
	h.Name = name
}

func (h *Human) GetName() string {
	return h.Name
}

func main() {
	tom := &Human{}
	
	// Human既实现了A接口也实现了B接口
	
	var a A = tom
	a.SetName("tom")

	var b B = tom
	result := b.GetName()
	fmt.Println(result)
}

```

## 接口嵌套

```go
package main

import "fmt"

type Sayer interface {
	Say()
}

type Mover interface {
	Move()
}

type Animal interface {
	Sayer
	Mover
}

type Cat struct {
	Name string
}

// 实现了Sayer和Mover接口，即实现了Animal接口
func (c *Cat) Say() {
	fmt.Printf("%v 会喵喵叫\n", c.Name)
}

func (c *Cat) Move() {
	fmt.Printf("%v 会跳起来\n", c.Name)
}

func main() {
	tom := &Cat{
		Name: "tom",
	}
	
	var x Animal = tom
	x.Say()
	x.Move()

}

```

