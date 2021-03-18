# Golang设计模式之工厂模式


## 概述
> 目的：使一个类的实例化延迟到其子类, 定义一个用于创建对象的接口, 让子类决定将哪一个类实例化

工厂模式就是让子类实现工厂接口，返回一个抽象的产品，创建的过程在其子类中执行。工厂模式可以分为三种，简单工厂，工厂方法，抽象工厂。下面我们来看看具体怎么实现。
### 简单工厂模式
> 思路：创建一个工厂结构体，工厂接口，工厂可以创建产品，只要在工厂的某个方法中传入不同的参数，就可以返回实现产品接口的不同对象。

```golang
// factory_sample.go
package factory_sample

import "fmt"

// CarFactory 汽车工厂
type CarFactory struct{}

// Product 产品接口
type Product interface {
	Create()
}

// BaoMaCar 宝马车
type BaoMaCar struct{}

// Create 实现产品接口
func (bm *BaoMaCar) Create() {
	fmt.Println("制作好宝马车")
}

// BenChiCar 奔驰车
type BenChiCar struct{}

// Create 实现产品接口
func (bc *BenChiCar) Create() {
	fmt.Println("制作好奔驰车")
}

// 为工厂结构体添加一个生产汽车的方法，也就是实例化一个汽车对象
func (cf *CarFactory) Generate(name string) Product {
	switch name {
	case "baoma":
		return &BaoMaCar{}
	case "benchi":
		return &BenChiCar{}
	default:
		return nil
	}
}
```
测试：
```golang
// factory_sample_test.go
package factory_sample

import "testing"

func TestFactory(t *testing.T) {
	carFactory := new(CarFactory)

	baoma := carFactory.Generate("baoma")
	baoma.Create()

	benchi := carFactory.Generate("benchi")
	benchi.Create()

}
```

测试结果：
```bash
=== RUN   TestFactory
制作好宝马车
制作好奔驰车
--- PASS: TestFactory (0.00s)
PASS
ok      _/C_/Users/pokit/Desktop/codetest/factory_sample        0.188s
```
### 工厂方法模式
先来与简单工厂比较一下
简单工厂需要：
1. 工厂结构体
2. 产品接口
3. 产品结构体

工厂方法需要:
1. 工厂接口
2. 工厂结构体
3. 产品接口
4. 产品结构体

在 简单工厂 中，依赖于唯一的工厂对象，如果我们需要实例化一个产品，那么就要向工厂中传入一个参数获取对应对象，如果要增加一种产品，就要在工厂中修改创建产品的函数，耦合性过高
，而在 工厂方法 中，依赖工厂接口，我们可以通过实现工厂接口，创建多种工厂，将对象创建由一个对象负责所有具体类的实例化，变成由一群子类来负责对具体类的实例化，将过程解耦。

# 未完，待续...


参考：https://juejin.im/post/5bdede60518825171a180c44
