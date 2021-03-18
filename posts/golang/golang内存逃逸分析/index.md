# Golang内存逃逸分析

**题外**

好久都没更新博客了，这段时间一直在捣鼓语雀，发现真是个优秀的东西（所见即所得，所得即所想），忍不住想吹一波。。。 我把很多自己积累的知识都搬到了上面，现在比较乱， 所以还没公开。

## 1.1. 前言
之前看过一些java的教程，经常会看到“new出来的东西都在堆上，栈上存的是它的引用”，而自己在使用go的过程中却很少关注过堆栈的分配情况，只是在程序panic的时候抛出一些堆栈信息，现在我们就来仔细研究一下go的逃逸分析。
## 1.2. 关于堆栈
堆栈是计算机基础的中的内容，我们简单回顾一下：

- 堆（Heap）：一般来讲是人为手动进行管理，手动申请、分配、释放。堆适合不可预知大小的内存分配，这也意味着为此付出的代价是分配速度较慢，而且会形成内存碎片。
- 栈（Stack）：由编译器进行管理，自动申请、分配、释放。一般不会太大，因此栈的分配和回收速度非常快；我们常见的函数参数（不同平台允许存放的数量不同），局部变量等都会存放在栈上。

栈分配内存只需要两个CPU指令：“PUSH”和“RELEASE”，分配和释放；而堆分配内存首先需要去找到一块大小合适的内存块，之后要通过垃圾回收才能释放。
通俗比喻的说，`栈`就如我们去饭馆吃饭，只需要点菜（发出申请）--》吃吃吃（使用内存）--》吃饱就跑剩下的交给饭馆（操作系统自动回收），而`堆`就如在家里做饭，大到家，小到买什么菜，每一个环节都需要自己来实现，自由度会大很多，但是也会耗费更多的时间和精力。
## 1.3. 为何需要逃逸分析
所谓逃逸分析（Escape analysis）是指由编译器决定内存分配的位置，不需要程序员指定。

- 栈上分配内存比在堆中分配内存有更高的效率
- 栈上分配的内存不需要GC处理
- 堆上分配的内存使用完毕会交给GC处理，会影响性能
- 逃逸分析目的是决定内分配地址是栈还是堆
- 逃逸分析在编译阶段完成，因此利于我们进行分析
## 1.4. 分析方法
在`Go`中通过逃逸分析日志来确定变量是否逃逸，开启逃逸分析日志：
```bash
go run -gcflags '-m -l' main.go
```

- `-m` 会打印出逃逸分析的优化策略，实际上最多总共可以用 4 个 `-m`，但是信息量较大，一般用 1 就可以了。
- `-l` 会禁用函数内联，在这里禁用掉`内联`能更好的观察逃逸情况，减少干扰。
## 1.5. 逃逸场景
> 以下通过go version1.15.2 windows/amd64进行测试，不同的版本或平台可能有所差异，毕竟go的编译器也是在不断地进行优化。

### 1.5.1. 指针逃逸
Go可以返回局部变量指针，这其实是一个典型的变量逃逸案例，示例代码如下：
```go
type Person struct {
	Name string
	Age  int
}

func NewPerson() *Person {
	p := new(Person) // 此处发生内存逃逸
	return p
}

func main() {
	p := NewPerson()
	fmt.Println(p)
}
```
分析结果：
```
.\demo.go:11:10: new(Person) escapes to heap
.\demo.go:17:13: ... argument does not escape
```
虽然p在函数NewPerson()中是局部变量，他的值通过函数返回值返回，但是p是一个指针，其指向的内存地址不会是栈而是堆。
### 1.5.2. 栈空间不足逃逸（空间开辟过大）
```go
func main() {
	s := make([]int, 10000, 10000) // 空间过大 逃逸
	fmt.Println(len(s))
}
```
分析结果：
```
.\demo.go:11:10: new(Person) escapes to heap
.\demo.go:16:11: make([]int, 10000, 10000) escapes to heap
.\demo.go:17:13: ... argument does not escape
.\demo.go:17:17: len(s) escapes to heap
```
当切片长度扩大到一定数量时就会逃逸，实际上当栈空间不足以存放当前对象时或无法判断当前切片长度时会将对象分配到堆中。
### 1.5.3. 动态类型逃逸（不确定长度大小）
```go
func main() {
	_ = make([]int, 0, 20)
	_ = make([]int, 0, 20000) // 空间过大 逃逸

	c := 20
	_ = make([]int, 0, c) // 动态分配不定空间 逃逸
}
```
分析结果：
```
.\demo.go:15:10: make([]int, 0, 20) does not escape
.\demo.go:16:10: make([]int, 0, 20000) escapes to heap
.\demo.go:19:10: make([]int, 0, c) escapes to heap
```
### 1.5.4. 闭包引用对象逃逸
```go
func Fibonacci() func() int {
	a, b := 0, 1
	return func() int {
		a, b = b, a+b
		return a
	}
}

func main() {
	f := Fibonacci()
	for i := 0; i < 5; i++ {
		fmt.Printf("Fibonacci=%d\n", f())
	}
}
```
分析结果：
```
.\demo.go:6:2: moved to heap: a
.\demo.go:6:5: moved to heap: b
.\demo.go:7:9: func literal escapes to heap
.\demo.go:16:13: ... argument does not escape
.\demo.go:16:33: f() escapes to heap
```
Fibonacci()函数中原本属于局部变量的a和b由于闭包的引用，不得不将二者放到堆上，所以了产生逃逸。
## 1.6. 总结
不要盲目使用变量的指针作为函数参数，虽然它会减少复制操作。但其实当参数为变量自身的时候，复制是在栈上完成的操作，开销远比变量逃逸后动态地在堆上分配内存少的多。
有时候在分析性能瓶颈一筹莫展的时候，堆栈分析未尝不是一种新的途径，虽然它很难给程序带来质的变化，但是这是作为一名优秀程序员必备的技能。



**参考**

[golang 逃逸分析详解 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/91559562)

[Go 1.14中值得关注的几个变化 | Tony Bai](https://tonybai.com/2020/03/08/some-changes-in-go-1-14/)

[Golang内存分配逃逸分析 (driverzhang.github.io)](https://driverzhang.github.io/post/golang内存分配逃逸分析/)

[Go 逃逸分析 - Go语言中文网 - Golang中文社区 (studygolang.com)](https://studygolang.com/articles/21880)
