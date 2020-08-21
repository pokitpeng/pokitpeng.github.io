---
title: "Vim打造golang开发环境"
date: 2020-08-20T22:59:29+08:00
draft: true
tags:
    - golang
    - vim
categories: 
    - vim
---
<!-- 参考：https://www.mrsong.me/2019/12/29/nvim/ -->

## 1. 前言
之前一直使用jetbrains家族的各个IDE,用起来也非常的方便，前几天刚好激活码也过期了，懒得找激活，就想趁着这股劲就想把vim搞起来，其实也试过目前挺火的 vacode 但是使用起来 总是感觉差点什么，常用快捷键也和goland的变化太大，又得重新去记快捷键，有点学习成本还麻烦，既然学习那为什么不学vim呢？学习成本越大的，往往后面收益越大，而且vim 的很多快捷键和 shell，git下的快捷键是通用的。网上也从未停止过vim与其他编辑器或IDE的讨论,例如 最早的eclipse 和 vim 那个更强大，后来的sublime和vim的比较等等，这两年vscode又火了，都拿来和vim来作比较，没准过个几年某乎又会出现 xxx编辑器和vim那个更强大！所以学会学好使用vim还是很有必要的。好多资深大佬也都强烈推荐学习，毕竟都是过来人。

## 2. 安装
### 2.1. 安装neovim
> 官方文档：[https://github.com/neovim/neovim/wiki/Installing-Neovim#Linux](https://github.com/neovim/neovim/wiki/Installing-Neovim#Linux)

```bash
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y neovim python3-neovim
# you might need python2-neovim as well on older Fedora releases
```
以上安装的是0.3.0，与后面插件有兼容性问题，建议安装最新版最新版：[https://github.com/neovim/neovim/releases/tag/v0.4.4](https://github.com/neovim/neovim/releases/tag/v0.4.4)
```bash
wget https://github.com/neovim/neovim/releases/download/v0.4.4/nvim.appimage \ 
&& ./nvim.appimage --appimage-extract \ 
&& cp ./squashfs-root/usr/bin/nvim /usr/local/bin/
```

### 2.2. 插件管理
> 官方文档：[https://github.com/junegunn/vim-plug](https://github.com/junegunn/vim-plug)
```bash
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
之后打开init.vim ，添加：
```vim
call plug#begin('~/.vim/plugged')

call plug#end()
```
begin括号里面的意思就是之后安装的插件全放在这个目录下，可根据个人情况修改。

Reload .vimrc and `:PlugInstall` to install plugins，其他常用命名：

`:PlugUpdate`
`:PlugClean`
`:PlugStatus`

## 3. 配置
### 3.1. 基础配置
基础配置如下：
```vim
"==============================================================================
" vim 基础配置 
"==============================================================================
"显示行号
set number

"开启语法高亮
set syntax=on

"设置以unix的格式保存文件"
set fileformat=unix

"设置table长度
set tabstop=4

"同上
set shiftwidth=4

"文件编码
set fenc=utf-8

"启用鼠标
set mouse=a

"突出显示当前行
"set cursorline

"文件编码
set encoding=utf-8

"自动缩进
set autoindent

set softtabstop=4

"自动缩进所使用的空白长度指示
set shiftwidth=4
set expandtab
```
### 3.2. 插件配置
#### nerdtree
一个老牌的目录管理插件
```vim
Plug 'scrooloose/nerdtree'

nnoremap <leader>v :NERDTreeFind<cr>
nnoremap <leader>g :NERDTreeToggle<cr>
```
快捷键g：打开侧边栏目录，j k进行上下选择，o或回车打开文件目录， w可以切换窗口， 再次使用 ,重复g可关闭侧边栏目录
快捷键v：快速跳到当前文件在目录位置

#### airline
状态栏美化
```vim
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
```
#### vim-startify
开屏美化插件

vim开屏页美化插件，可以记录最近编辑的文件，使用对应数字编号就可以快速打开文件，使用起来非常方便。

```vim
Plug 'mhinz/vim-startify'
```
#### vim-go
vim-go 提供了大量的功能
```vim
Plug 'fatih/vim-go'
```
安装完vim-go之后，打开nvim 使用 `:GoInstallBinaries` 安装依赖包，需要配置在环境变量PATH配置GOBIN

默认打开go文件，语法高亮是不全的，也没有像vscode 一样保存自动格式化，所以还需做简单配置：
```vim
" vim-go
let g:go_fmt_command = 'goimports'
let g:go_autodetect_gopath = 1
" let g:go_bin_path = '$GOBIN'

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_generate_tags = 1

" Open :GoDeclsDir with ctrl-g
nmap <C-g> :GoDeclsDir<cr>
imap <C-g> <esc>:<C-u>GoDeclsDir<cr>

augroup go
  autocmd!
  autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4
augroup END
```
这里参考vim-go 作者的vim配置，vim-go-tutorial，配置非常精简，非常值得借鉴学习。配置完成之后就可以使用vim愉快的编写go代码了。
用的比较多的，gd 跳转到代码定义 < C-i > < C-o > 后退/前进，保存代码就会自动格式化。其他的使用方法看文档就行。

#### coc.nvim
代码补全插件
```vim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
```
coc.nvim 使用 :CocConfig 打开配置文件，默认路径 `~/.config/nvim/coc-settings.json`,这里只介绍golang的配置，配置文件添加:
```json
{
    "languageserver": {
        "golang": {
            "command": "gopls",
            "rootPatterns": [
                "go.mod"
            ],
            "filetypes": [
                "go"
            ]
        }
    },
    "suggest.noselect": false,
    "coc.preferences.diagnostic.displayByAle": true,
    "suggest.floatEnable": true
}
```
init.vim 添加配置，也可不配置不常用到：
```vim
" Remap keys for gotos
" nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gm <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
```
正确配置之后，就可以使用代码补全了 例如我们输入 fmt. 就会提示fmt包中的方法，默认选择第一个，使用< C-n > < C-p > 上下选车，回车选择，nvim下可以使用悬浮窗功能。
