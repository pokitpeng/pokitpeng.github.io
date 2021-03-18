# Golang中tag使用技巧




> 本文将介绍go在使用`json`序列化过程中的一些常用技巧，以及一些隐蔽的坑

## 1. 基本序列化

```go
type User struct {
	Email    string
	Password string
}
u1 := &User{
	Email:    "pokit@qq.com",
	Password: "123456",
}
res, _ := json.Marshal(u1)
fmt.Println(string(res))

// output
{"Email":"pokit@qq.com","Password":"123456"}
```



## 2. tag标签

`Tag`是结构体的元信息，可以在运行的时候通过反射的机制读取出来。

```go
type User struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
u1 := &User{
	Email:    "pokit@qq.com",
	Password: "123456",
}
res, _ := json.Marshal(u1)
fmt.Println(string(res))

// output
{"email":"pokit@qq.com","password":"123456"}
```

上述序列化后的`json`数据，`key`是我们先前定义的`tag`，这是最广泛的一种使用方法。

## 3. 忽略某个字段

如果你想在`json`序列化/反序列化的时候忽略掉结构体中的某个字段，可以按如下方式在tag中添加`-`

```go
type User struct {
	Email    string `json:"email"`
    // 此处使用-，该字段就会被忽略
	Password string `json:"-"`
}
u1 := &User{
	Email:    "pokit@qq.com",
	Password: "123456",
}
res, _ := json.Marshal(u1)
fmt.Println(string(res))

// output
{"email":"pokit@qq.com"}
```

## 4. 忽略空值字段

当 `struct` 中的字段没有值时， `json.Marshal()` 序列化的时候不会忽略这些字段，而是默认输出字段的类型`零值`，如果想要在序列序列化时忽略这些没有值的字段时，可以在对应字段添加`omitempty` tag。

```go
type User struct {
	Email    string `json:"email"`
	Password string `json:"password,omitempty"`
}
u1 := &User{
	Email:    "pokit@qq.com",
}
res, _ := json.Marshal(u1)
fmt.Println(string(res))

// output
{"email":"pokit@qq.com"}
```

可以看到`Password`并没有传值，序列化的结果就会直接忽略。

## 5. 忽略嵌套结构体空值字段

这里有两个坑，我们根据实例看一下

**坑一**：当嵌套结构体`Others`没有写tag，内部元素就不会做嵌套处理，所以我们还是老老实实的每个元素都写一下tag。

```go
type Others struct {
	Language string `json:"language"`
}

type User struct {
	Email    string `json:"email,omitempty"`
	Password string `json:"password,omitempty"`
    // 这里Others嵌套结构体没有写tag，序列化后的数据就不会有嵌套结构
	Others
}

u1 := &User{
	Email:    "pokit@qq.com",
}
res, _ := json.Marshal(u1)
fmt.Println(string(res))

// output
{"email":"pokit@qq.com","language":""}
```

```go
type Others struct {
	Language string `json:"language"`
}

type User struct {
	Email    string `json:"email,omitempty"`
	Password string `json:"password,omitempty"`
    // 加上tag，输出正常
	Others `json:"others"`
}

u1 := &User{
	Email:    "pokit@qq.com",
}
res, _ := json.Marshal(u1)
fmt.Println(string(res))

// output
{"email":"pokit@qq.com","others":{"language":""}}
```

**坑二**：想要忽略嵌套结构体的字段，仅仅加上`omitempty`字段还不够，嵌套结构体需要使用指针。

```go
type Others struct {
	Language string `json:"language"`
}

type User struct {
	Email    string `json:"email,omitempty"`
	Password string `json:"password,omitempty"`
    // 嵌套结构体不使用指针，omitempty不会生效
	Others `json:"others,omitempty"`
}

u1 := &User{
	Email:    "pokit@qq.com",
}
res, _ := json.Marshal(u1)
fmt.Println(string(res))

// output
{"email":"pokit@qq.com","others":{"language":""}}
```

```go
type Others struct {
	Language string `json:"language"`
}

type User struct {
	Email    string `json:"email,omitempty"`
	Password string `json:"password,omitempty"`
    // 使用指针后生效
	*Others `json:"others,omitempty"`
}

u1 := &User{
	Email:    "pokit@qq.com",
}
res, _ := json.Marshal(u1)
fmt.Println(string(res))

// output
{"email":"pokit@qq.com"}
```

## 6. 不修改原结构体忽略空值字段

我们需要`json`序列化`User`，但是不想把密码也序列化，又不想修改`User`结构体，这个时候我们就可以使用创建另外一个结构体`PublicUser`匿名嵌套原`User`，同时指定`Password`字段为匿名结构体指针类型，并添加`omitempty`tag

```go
type User struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
type UserNoPassword struct{
	*User // 匿名嵌套
	// 直接忽略Password字段，注意不要跟上述"-"搞混
	Password *struct{} `json:"password,omitempty"`
}

u1 := &User{
	Email:    "pokit@qq.com",
	Password: "123456",
}
res, _ := json.Marshal(UserNoPassword{User: u1})
fmt.Println(string(res))

// output
{"email":"pokit@qq.com"}
```

## 7. 类型转换

有时候`json`传过来的某个字段是`string`类型，但是反序列化到结构体中需要是`int`类型，就可以使用tag做类型转换

```go
type User struct {
	Age    int     `json:"age,string"`
	Height float32 `json:"height,string"`
}
s := `{"age":"18","height":"172.3"}`
var u User
if err := json.Unmarshal([]byte(s), &u); err != nil {
	log.Panicf("Unmarshal failed:%s", err)
}
fmt.Printf("%+v",u)

// output
{Age:18 Height:172.3}
```

但是这里有个坑，如果要转换类型，但是传过来的类型不是指定类型，例如上述`age`在`json`里是字符串，若果传`int`，就会报错，所以这个技巧慎用。



以上，就是常用的`tag`使用技巧，后续遇到其他需求再进行补充。



**参考:**

[[转\]Golang 中使用 JSON 的小技巧 | 鸟窝 (colobu.com)](https://colobu.com/2017/06/21/json-tricks-in-Go/)

[Partly JSON unmarshal into a map in Go - Stack Overflow (stackoverflow.com)](https://stackoverflow.com/questions/11066946/partly-json-unmarshal-into-a-map-in-go)

[你需要知道的那些go语言json技巧 | 李文周的博客 (liwenzhou.com)](https://www.liwenzhou.com/posts/Go/json_tricks_in_go/)
