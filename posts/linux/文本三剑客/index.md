# 文本三剑客


# 文本三剑客
> grep，sed，awk的功能非常强大，平时进行一些日志分析，进程管理等等非常有用，对于熟悉linux的小伙伴基本都会遇到他们的身影，这里列出自己所学，有些是非常常用的操作，有些用的比较少，所以做个记录，有需要的时候就当个工具书来查看。
## 三剑客之grep
```
grep是一个基于正则表达式的全局文本搜索工具，并能将匹配到的文本按行打印。
两种形式
grep [选项] 正则表达式 [目标文件]
linux command | grep [选项] 正则表达式

[option]选项
-i  在搜索的时候忽略大小写
-c  只输出匹配行的数量
-n  显示结果所在行号
-r  递归搜索
-E  支持拓展正则表达式
-w  匹配整个单词，如果是字符串中包含这个单词，则不作匹配
-l  只列出匹配的文件名
-F  不支持正则,按字符串字面意思进行匹配
-v  输出不带关键字的行（反向查询，反向匹配）
-o  只显示符合条件的字符串
-A2 显示包括搜索行的后面2行
-B2 显示包括搜索行的前面2行
```
## 三剑客之sed
```
sed本质是一个流编辑器，用来对文本进行增删改查。（偏向行处理）
两种形式
sed [option] "pattern command" filename
linux command | sed [option] "pattern command"

[option]选项
-n  经过sed处理过的行才会被列出来
-f  加载存放动作的文件
-r  支持拓展正则
-i  直接修改文件

pattern匹配模式
5   只处理第5行
5,10    只处理第5行到第10行
/pattern1/  只处理匹配到 poattern1 内容的行
/pattern1/,/pattern2/   只处理从匹配 pattern1的行到匹配 pattern2的行

command处理命令

查询
p   打印信息
示例：
    sed -n "/root/p" /etc/passwd #匹配文件中的root字段，并打印出来，等同：grep root /etc/passwd
    sed -n "5,10p" /etc/passwd #匹配第5到第10行，并打印
    sed -nr "/^s/p" /etc/passwd #匹配s开头的行
    sed -nr "/o{2}/p" /etc/passwd #匹配包含oo的行

新增
a   在匹配行后新增
i   在匹配行前新增
r   外部文件读入，行后新增
w   匹配行写入外部文件

示例：
    # 在 linetest 行后面追加一句话 This is test
    sed -i '/root/a This is test' file
    #向指定行前一行插入指定字符串
    sed -i '3i abc' test.sh  #表示向第三行插入字符串abc，原本的第三行编程第四行
    # 行前追加 在 root 和 nginx之间所有行之前追加 AAAAAAAAAAAAAAAAAAAA
    sed -i '/^root/,/^nginx/i AAAAAAAAAAAAAAAAAAAA' passwd
    # 查找passwd文件中所有root的行，读取 list.txt 文件的内容追加到其后面
    sed -n '/root/r list.txt' passwd
    # 在passwd文件中将匹配到的 /bin/bash 行写入到 /tmp/user_login.txt 文件中
    sed '/\/bin\/bash/w /tmp/user_login.txt' passwd


常用：
# 查找所有文件并替换
find . -type f -exec sed -i 's/befor/after/g' {} \;
# 查找当前目录，而忽略子目录
find . -maxdepth 1 -type f -exec sed -i -e 's/befor/after/g' {} \;

删除
d

示例：
    sed -i '1d' passwd  # 删除第1行
    sed -i '1,3d' passwd  # 删除1-3行
    sed -i '/\/sbin\/nologin/d' passwd.txt  # 删除文本中的 /sbin/nologin
    sed -i '/^mail/,/^ftp/d' passwd.txt  # 删除以mail开头一直到以 ftp开头的行

修改
s/old/new/  #只修改匹配行中的第一个old
s/old/new/2 #只替换匹配到的每一行的第二列old
s/old/new/g #修改匹配行中所有的old
s/old/new/2g    #同一行内，只替换前两个匹配到的，剩下的不替换
s/old/new/ig    #忽略大小写然后修改匹配行中所有的old
s/old/&ss/g  #把匹配到的所有内容保留下，并在后面增加ss

示例：
    sed -i 's/test1/test2/g' passwd  # 把test1全部替换为test2
    sed -i 's/root/ROOT/' passwd  # 只替换第一个root为ROOT
    sed -i 's/Hadoop/&ss/g' file.txt  # 把匹配到的内容保留下，并在后面增加ss
    sed -i "/elasticsearch/{n;s/a/b/;}" passwd # 匹配到的elasticsearch后面一行,替换第一个a为b
    sed -i "/elasticsearch/{n;s/a/b/g;}" passwd # 匹配到的elasticsearch后面一行,替换所有a为b
    sed -i '45,47 s/nologin/login/g' passwd # 将45到47行的nologin修改为login
    sed -i '45,47 s/nologin/login/ig' passwd # 将45到47行的nologin(忽略大小写)修改为login
    # 正则替换：
    sed -i "s/192.168.\(.*\)/192.168.50.67/g" install.conf # 替换192.168.*为192.168.50.67
```

## 三剑客之awk
```
awk命令的作用是进行日志文本扫描、处理以及报表的生成。（偏向列处理）

3.1 awk命令格式和选项
awk [-F  field-separator]  'commands'  input-file(s)
其中，commands 是真正awk命令，[-F域分隔符]是可选的。 input-file(s) 是待处理的文件。

awk 'BEGIN{ print "start" } pattern{ commands } END{ print "end" }' file.txt
BEGIN{}     处理数据之前执行
pattern     匹配模式
{commands}  处理的命令
END{}       处理数据之后执行

命令选项：[-F  field-separator] 
-F fs           fs指定输入分隔符，fs可以是字符串或正则表达式，如-F :
-v var=value    赋值一个用户定义变量，将外部变量传递给awk
-f scripfile    从脚本文件中读取awk命令
模式 pattern：
/正则表达式/：使用通配符的扩展集。
关系表达式：使用运算符进行操作，可以是字符串或数字的比较测试。
模式匹配表达式：用运算符~（匹配）和!~（不匹配）。
BEGIN语句块、pattern语句块、END语句块：参见awk的工作原理
print与printf 格式符
%s      字符串
%d      十进制数字
%f      浮点数
%+20s   20个占位符（不够的填空格）右对齐(默认不写)
%-20s   20个占位符（不够的填空格）左对齐

内置变量
$0                          整行内容
$1~$n                       当前行的第1~n个字段 
NF (Number Field)           当前行的总字段数,即列数
    示例：head passwd|awk -F ':' '{print $NF}' # 按照:进行分割，打印passwd前十行最后一列的内容
NR (Number Row)             当前行的行号，从1开始
    示例：head passwd|awk -F ':' '{print NR,$1}' # 按照:进行分割，打印passwd前十行第1列的内容,并带上行号
FS (Field Separator)        输入字段分割符，默认为空格或tab键
    示例：head passwd|awk 'BEGIN{FS=":"} {print $3}' # 按照:进行分割，打印passwd前十行第3列的内容
            head passwd|awk -F ':' '{print NR,$1}'|sed -n '2,5p' # 按照:进行分割，打印passwd第2行到第5行，第3列的内容
RS (Row Separator)          输入行分割符,默认为回车符
OFS (Output Field Separator)    输出字段分割符，默认为空格
ORS (Output Row Separator)      输出行分割符，默认为回车符

快捷使用命令例子：
awk -F ',' '{print $1}' test.txt # 打印所有行的第一个列
awk -F ',' 'NR>1 {print $1}' test.txt # 打印第二行开始的第一个列
awk -F ',' '$3>10 {print $1}' test.txt # 打印第3列大于10的行的第一个列
awk -F ',' '/sth/{print $1}' test.txt # 打印匹配sth的行的第一个列
awk -F ',' '!/sth/{print $1}' test.txt # 打印不匹配sth的行的第一个列


规范使用命令例子：
1、指定分隔符为  : ，输出第一列和最后一列，并且格式化输出结果为每列占位20字符，左对齐
awk 'BEGIN{FS=":"}{printf "%-20s%-20s\n",$1,$NF}' /etc/passwd

2、指定分隔符为  : ，输出第4列，格式化输出结果为每列占位20字符并且保留小数点后两位，左对齐
awk 'BEGIN{FS=":"}{printf "%-20.2f\n",$4}' /etc/passwd

3、打印倒数第二列
awk 'BEGIN{FS=":"}{printf $(NF-1)}' /etc/passwd

4、带匹配模式的awk，这里匹配模式可以做运算
4.1、指定分隔符为  : ，匹配带有mail的行，输出第1列到最后一列，格式化输出每列占位20字符，左对齐 
awk 'BEGIN{FS=":"} /mail/ {printf "%-20s%-20s\n",$1,$NF}' /etc/passwd

4.2、指定分隔符为  : ，匹配games开头的行到dbus开头的行，输出第1列到最后一列，格式化输出每列占位20字符，左对齐
awk 'BEGIN{FS=":"} /^games/,/^www/ {printf "%-20s%-20s\n",$1,$NF}' /etc/passwd

4.3、指定分隔符为  : ，匹配第6列含有/bin字符串的所有行，输出第1列到最后一列，格式化输出每列占位20字符，左对齐
awk 'BEGIN{FS=":"} $6=="/bin" {printf "%-20s%-20s\n",$1,$NF}' /etc/passwd

3.2 awk脚本编写格式
awk -f test.awk file  # awk处理逻辑写到test.awk文件中

"
2019-08-17 16:19:51,032 CRITICAL pokit Fail 充值成功-1位小数 generate_logs.py 42
2019-08-17 16:19:51,032 CRITICAL pokit Fail 充值成功-1位小数 generate_logs.py 42
2019-08-17 16:19:51,032 CRITICAL pokit Fail 充值成功-1位小数 generate_logs.py 42
2019-08-17 16:19:51,034 INFO pokit Pass 充值成功-整数 generate_logs.py 42
2019-08-17 16:19:51,034 INFO pokit Pass 充值成功-整数 generate_logs.py 42
2019-08-17 16:19:51,034 INFO pokit Pass 充值成功-整数 generate_logs.py 42
2019-08-17 16:19:51,034 INFO pokit Pass 充值成功-整数 generate_logs.py 42
2019-08-17 16:19:51,034 CRITICAL peng Fail 成功注册-无昵称 generate_logs.py 42
2019-08-17 16:19:51,034 CRITICAL peng Fail 成功注册-无昵称 generate_logs.py 42
2019-08-17 16:19:51,035 INFO tom Pass 充值金额-非数字 generate_logs.py 42
2019-08-17 16:19:51,035 INFO tom Pass 充值金额-非数字 generate_logs.py 42
2019-08-17 16:19:51,035 INFO tom Pass 充值金额-非数字 generate_logs.py 42
"
实例日志分析脚本：
1、计算每位测试人员的执行用例次数
test.awk脚本内容：

BEGIN{
printf "%-10s%-10s\n", "Tester", "TotalTestcases"
}
{
USERS[$4] += 1;
}
END{
for (u in USERS)
printf "%-10s%-10d\n", u, USERS[u];
}

执行分析：
awk -f test.awk test.log

分析结果：
Tester    TotalTestcases
pokit     7         
peng    2         
tom     3 

2、分别统计每位测试人员执行用例成功和失败总数
BEGIN{
printf "%-10s%-10s%-10s\n", "Tester","PassTotal","FailTotal"
}
{
if ($5 == "Pass")
{
    SUCCESS[$4] += 1;
}else
{
    FAIL[$4] += 1;
}
USERS[$4] +=1;
}
END{
for (u in USERS)
{printf "%-10s%-10d%-10d\n", u, SUCCESS[u],FAIL[u];
}
}

分析结果：
Tester    PassTotal FailTotal 
pokit     4         3         
peng      0         2         
tom       3         0

3、将1、2合并，同时分别统计每位测试人员执行用例CRITICAL、ERROR日志等级数以及所有测试人员每项总数
BEGIN{
printf "%-10s%-12s%-18s%-12s%-12s\n", "Tester","ErrorTotal","CriticalTotal","PassTotal","FailTotal"
}
{
if ($5 == "Pass")
{
    SUCCESS[$4] += 1;
}else
{
    FAIL[$4] += 1;
}
if ($3 == "CRITICAL")
{
    CRITICAL[$4] += 1;
}
USERS[$4] +=1;
}
END{
for (u in USERS)
{
    ALL_ERRORS+=ERROR[u];
    ALL_CRITICALS+=CRITICAL[u];
    ALL_SUCCESSS+=SUCCESS[u];
    ALL_FAILS+=FAIL[u];
    printf "%-10s%-12d%-18d%-12d%-12d\n",u,ERROR[u],CRITICAL[u],SUCCESS[u],FAIL[u];
}
printf "%-10s%-12d%-18d%-12d%-12d\n","Total",ALL_ERRORS,ALL_CRITICALS,ALL_SUCCESSS,ALL_FAILS;
}

分析结果：
Tester    ErrorTotal  CriticalTotal     PassTotal   FailTotal   
pokit      0           3                 4           3           
peng       0           2                 0           2           
tom        0           0                 3           0           
Total      0           5                 7           5
```
