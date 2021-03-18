# Golang如何写出gc友好的代码


## 1. GO中的GC
常见的垃圾回收方法有引用计数和标记清除，这里简单介绍下go语言中的三色标记法。我们直接看下GC的几个重要阶段：
### 1.1. 标记开始 - STW
当回收开始，首先执行的动作是打开写屏障。写屏障的目的是允许回收器在收集过程保持堆上的数据完整性，因为回收器和应用程序的 Goroutine 会并发执行。为了打开写屏障，必须停止应用运行的所有 Goroutine 。这个动作通常非常快，平均在 10~30 微秒之间
### 1.2. 标记中 - 并发
标记阶段会将大概25%(gcBackgroundUtilization)的P用于标记对象，逐个扫描所有G的堆栈，执行三色标记，在这个过程中，所有新分配的对象都是黑色，被扫描的G会被暂停，扫描完成后恢复，这部分工作叫后台标记([gcBgMarkWorker](https://github.com/golang/go/blob/dev.boringcrypto.go1.13/src/runtime/mgc.go#L1817))。
### 1.3. 标记结束 - STW
一旦标记工作完成，下阶段就是标记结束了。到这个阶段，写屏障会被停止，各样的清洁工作会被执行，然后计算好下一次的回收目标。
### 1.4. 并发清除
在回收完成之后有另一个叫清除的动作发生。清除是指回收堆内存中，未标记为使用中的值所关联的内存。该动作会在应用程序 Goroutine 尝试分配新值到堆内存时发生。清除的延迟被算到在堆内存中执行分配的成本中，与垃圾回收相关的任何延迟无关。
### 1.5. 总体过程如下：

1. 起初所有对象都是白色。
1. 从根出发扫描所有可达对象，标记为灰色，放入待处理队列。
1. 从队列取出灰色对象，将其引用对象标记为灰色放入队列，自身标记为黑色。
1. 重复 3，直到灰色对象队列为空。此时白色对象即为垃圾，进行回收。

![](https://raw.githubusercontent.com/pokitpeng/picture-bed/master/golang/2732449449-5c66324354fa8_articlex.gif)
## 2. 实践
### 2.1. 传值与传指针
我们根据示例分析
```go
package gc_friendly

import (
	"testing"
)

const Num = 1000

type BigArray struct {
	Content [10000]int
}

func withValue(arr [Num]BigArray) int {
	return 0
}

func withReference(arr *[Num]BigArray) int {
	return 0
}

func Benchmark_withValue(b *testing.B) {
	var arr [Num]BigArray

	b.ResetTimer() // b.ResetTimer是重置计时器，这样可以避免for循环之前的初始化代码的干扰
	for i := 0; i < b.N; i++ {
		withValue(arr)
	}
	b.StopTimer()
}

func Benchmark_withReference(b *testing.B) {
	var arr [Num]BigArray

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		withReference(&arr)
	}
	b.StopTimer()
}
```
执行测试：`go test -bench=.`
执行结果：
```
goos: windows
goarch: amd64
Benchmark_withValue-6                103          12064520 ns/op
Benchmark_withReference-6       1000000000               0.258 ns/op
PASS
```
可以看到性能差距非常大。另外我们可以打开GC日志，进行具体分析。例如：
```
GOGEBUG=gctrace=1 go test -bench=.
GOGEBUG=gctrace=1 go run main.go
```


除此之外，还可以使用`go tool trace`进行分析，首先生成trace文件
```bash
go test -bench=Benchmark_withValue -trace=trace_val.out
go test -bench=Benchmark_withReference -trace=trace_ref.out
```
然后生成可视化图标
```bash
go tool trace trace_val.out
go tool trace trace_ref.out
```
传值trace结果：
![](https://raw.githubusercontent.com/pokitpeng/picture-bed/master/golang/20201031112238.png)


传指针trace结果：

![](https://raw.githubusercontent.com/pokitpeng/picture-bed/master/golang/20201031112306.png)

可以看出传指值的gc非常频繁。


### 2.2. 初始化切片大小
示例
```go
package gc_friendly

import "testing"

const Num = 10000

func Benchmark_SliceAutoGrow(b *testing.B) {
	for i := 0; i < b.N; i++ {
		var s []int
		for j := 0; j < Num; j++ {
			s = append(s, j)
		}
	}
}

func Benchmark_SliceProperInit(b *testing.B) {
	for i := 0; i < b.N; i++ {
		var s = make([]int, 0, Num)
		for j := 0; j < Num; j++ {
			s = append(s, j)
		}
	}
}

func Benchmark_SliceBigInit(b *testing.B) {
	for i := 0; i < b.N; i++ {
		var s = make([]int, 0, 80000)
		for j := 0; j < Num; j++ {
			s = append(s, j)
		}
	}
}
```
测试运行：`go test -bench=^Benchmark_Slice`
运行结果：
```
goos: windows
goarch: amd64
Benchmark_SliceAutoGrow-6          26917             43721 ns/op
Benchmark_SliceProperInit-6        97821             12347 ns/op
Benchmark_SliceBigInit-6           23005             50506 ns/op
PASS
```
可以发现，切片初始化太大和太小都会影响内存分配效率。初始化太大，内存占用高，初始化太小，每次执行`append`函数时，当容量不足就会自动扩容，此时会拷贝出一个全新的切片，影响程序性能。
## 3. 结论

1. 当结构体较大时使用指针传递（不是所有的指针传递都比值传递效率高，当结构体较小时，可能会分配到栈中，而指针会分配到堆中，此时值传递效率高于指针传递）
1. 尽量初始化合适大小的容量
1. 尽量做到复用内存



**参考**

[Go 语言垃圾收集器的实现原理 | Go 语言设计与实现 (draveness.me)](https://draveness.me/golang/docs/part3-runtime/ch07-memory/golang-garbage-collector/)

[Go语言实战笔记（二十二）| Go 基准测试 | 飞雪无情的博客 (flysnow.org)](https://www.flysnow.org/2017/05/21/go-in-action-go-benchmark-test.html)

[(...) GO GC 垃圾回收机制_golang开发笔记 - SegmentFault 思否](https://segmentfault.com/a/1190000018161588)

[Golang GC核心要点和度量方法 | wudaijun's blog](https://wudaijun.com/2020/01/go-gc-keypoint-and-monitor/)



