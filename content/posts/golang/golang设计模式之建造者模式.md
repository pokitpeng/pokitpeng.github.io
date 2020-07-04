---
title: "Golang设计模式之建造者模式"
date: 2020-07-04T18:51:43+08:00
draft: false
tags:
    - golang
    - 技术
    - 设计
categories: 
    - golang
---

## 概述
> wiki: Builder Pattern 是一种设计模式，又名：建造模式，是一种对象构建模式。它可以将复杂对象的建造过程抽象出来（抽象类别），使这个抽象过程的不同实现方法可以构造出不同表现（属性）的对象。

建造模式一般用于对象比较复杂的情况，将之拆分成小的对象，然后在实现过程中组装成一个大的对象，建造过程对外部是隐藏的。
## 结构
- `Builder` 抽象的一个东西， 主要是用来规范我们的建造者的，对应golang中的接口
- `ConcreteBuilder` 具体的Builder实现
- `Director` 规范复杂对象的创建流程 
## 示例
```golang
// builder.go
package builder

// Pizza 披萨制作材料
type Pizza struct {
	Dough   string //面团
	Sauce   string //酱料
	Fixings string //配料
}

// PotatoCheesePizza 土豆芝士披萨
type PotatoCheesePizza struct {
	pizza Pizza
}

// Builder 建造者，做披萨的规范
type Builder interface {
	JoinDough() Builder
	JoinSauce() Builder
	JoinFixings() Builder
	GetPizza() Pizza
}

// Director 主管，理事，这里可以认为是厨师
type Director struct {
	builder Builder
}

// Cook 厨师按照菜谱做菜
func (cooker *Director) Cook() {
	cooker.builder.JoinDough().JoinSauce().JoinFixings() //链式调用
}

// SetBuilder 厨师设定一个菜谱
func (cooker *Director) SetBuilder(menu Builder) {
	cooker.builder = menu
}

// JoinDough 加入面团
func (p *PotatoCheesePizza) JoinDough() Builder {
	p.pizza.Dough = "面团"
	return p
}

// JoinSauce 加入酱料
func (p *PotatoCheesePizza) JoinSauce() Builder {
	p.pizza.Sauce = "土豆酱"
	return p
}

// JoinFixings 加入配料
func (p *PotatoCheesePizza) JoinFixings() Builder {
	p.pizza.Fixings = "芝士"
	return p
}

// GetPizza 得到成品披萨
func (p *PotatoCheesePizza) GetPizza() Pizza {
	return p.pizza
}
```
## 测试
```golang
// builder_test.go
package builder

import (
	"testing"
)

func TestBuilder(t *testing.T) {
	cooker := Director{}                      // 创建一个厨师实例
	potatoCheesePizza := &PotatoCheesePizza{} // 准备做一个土豆芝士披萨
	cooker.SetBuilder(potatoCheesePizza)      // 创建一个菜单
	cooker.Cook()                             // 制作披萨
	pizza := cooker.builder.GetPizza()        // 获取成品披萨
	t.Logf("%+v", pizza)                      // 验收
}
```
## 结果
```bash
=== RUN   TestBuilder
--- PASS: TestBuilder (0.00s)
    builder_test.go:13: {Dough:面团 Sauce:土豆酱 Fixings:芝士}
PASS
ok      _/C_/Users/pokit/Desktop/codetest       0.176s
```

