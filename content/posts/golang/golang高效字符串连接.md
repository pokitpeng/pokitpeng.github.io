---
title: "Golang高效字符串连接"
date: 2020-08-05T17:37:25+08:00
draft: false
tags:
    - golang
categories: 
    - golang
---
> 字符串拼接在日常开发中是很常见的需求，而且有多种选择，今天我们就来研究研究哪种性能最好。

拼接方式有以下几种：

- `+`
- fmt.Sprintf
- strings.Join
- bytes.Buffer
- strings.Builder



直接上代码
```go
package string_join

import (
	"bytes"
	"fmt"
	"strings"
)

var a = "hello"
var b = "world"

var c = []string{a, b}

func StringAdd() string {
	return a + "," + b
}

func StringSprintf() string {
	return fmt.Sprintf("%s,%s", a, b)
}

func StringJoin() string {
	return strings.Join(c, ",")
}

func StringBufferWrite() string {
	var buf bytes.Buffer
	buf.WriteString(a)
	buf.WriteString(",")
	buf.WriteString(b)
	return buf.String()
}

func StringBuilder() string {
	var bul strings.Builder
	bul.WriteString(a)
	bul.WriteString(",")
	bul.WriteString(b)
	return bul.String()
}

```


测试代码
```go
package string_join

import "testing"

func Benchmark_StringAdd(b *testing.B) {
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		StringAdd()
	}
	b.StopTimer()
}

func Benchmark_StringSprintf(b *testing.B) {
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		StringSprintf()
	}
	b.StopTimer()
}

func Benchmark_StringJoin(b *testing.B) {
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		StringJoin()
	}
	b.StopTimer()
}

func Benchmark_StringBufferWrite(b *testing.B) {
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		StringBufferWrite()
	}
	b.StopTimer()
}

func Benchmark_StringBuilder(b *testing.B) {
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		StringBuilder()
	}
	b.StopTimer()
}
```
开测：`go test -benchmem -run=^$ -bench ^Benchmark_`
```
$ go test -benchmem -run=^$ -bench ^Benchmark_
goos: windows
goarch: amd64
Benchmark_StringAdd-4                   23530102                52.7 ns/op             0 B/op          0 allocs/op
Benchmark_StringSprintf-4                3409042               390 ns/op              48 B/op          3 allocs/op
Benchmark_StringJoin-4                  12766201                87.6 ns/op            16 B/op          1 allocs/op
Benchmark_StringBufferWrite-4            7593292               153 ns/op              80 B/op          2 allocs/op
Benchmark_StringBuilder-4                8633098               131 ns/op              24 B/op          2 allocs/op
PASS
ok      _/D_/code_exercises/tmp 7.210s
```
可以看出来使用`+`来拼接字符串是性能最优的，然后刨除`strings.Join`，剩下`strings.Builder`是最优的选择。
当然上述测试的字符串是很简短的，当字符串变得很长的时候，推荐使用`strings.Builder`，至于Sprintf能不用就不要用了。

