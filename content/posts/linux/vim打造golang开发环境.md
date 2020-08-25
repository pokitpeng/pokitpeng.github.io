---
title: "Vim打造golang开发环境"
date: 2020-08-20T22:59:29+08:00
draft: false
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
yum install -y neovim python3-neovim git
# you might need python2-neovim as well on older Fedora releases
```
以上安装的是0.3.0，与后面插件有兼容性问题，建议安装最新版最新版：[https://github.com/neovim/neovim/releases/tag/v0.4.4](https://github.com/neovim/neovim/releases/tag/v0.4.4)
```bash
wget https://github.com/neovim/neovim/releases/download/v0.4.4/nvim.appimage -P /usr/local/

cd /usr/local/

chmod +x nvim.appimage

./nvim.appimage --appimage-extract

ln -s $(pwd)/squashfs-root/usr/bin/nvim /usr/local/bin/nvim

rm -rf nvim.appimage
```

### 2.2. 插件管理
> 官方文档：[https://github.com/junegunn/vim-plug](https://github.com/junegunn/vim-plug)
```bash
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
之后打开 `~/.config/nvim/init.vim` ，添加：
```vim
call plug#begin('~/.vim/plugged')

call plug#end()
```
begin括号里面的意思就是之后安装的插件全放在这个目录下，可根据个人情况修改。

Reload .vimrc and `:PlugInstall` to install plugins，其他常用命名：

```
:PlugUpdate
:PlugClean
:PlugStatus
```

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
#### 3.2.1. nerdtree
一个老牌的目录管理插件
```vim
Plug 'scrooloose/nerdtree'

 " NERDTree config
 " F2键快速调出和隐藏它
 map <F2> :NERDTreeToggle<CR>
 " 关闭vim时，如果打开的文件除了NERDTree没有其他文件时，它自动关闭，减少多次按:q!
 autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
 " 打开vim时自动打开NERDTree
 autocmd vimenter * NERDTree
 "设定 NERDTree 视窗大小
 let g:NERDTreeWinSize = 25 
```
常用快捷键：
```
ctrl w w 光标自动在左右侧窗口切换
o        展开左侧某个目录，再按一下就是合并目录 
t        在新 Tab 中打开选中文件/书签，并跳到新 Tab
T        在新 Tab 中打开选中文件/书签，但不跳到新 Tab
P        跳到根结点
p        跳到父结点
q        关闭 NerdTree 窗口
```
#### 3.2.2. airline
状态栏美化
```vim
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
```
#### 3.2.3. vim-startify
开屏美化插件

vim开屏页美化插件，可以记录最近编辑的文件，使用对应数字编号就可以快速打开文件，使用起来非常方便。

```vim
Plug 'mhinz/vim-startify'
```
#### 3.2.4. vim-go
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

#### 3.2.5. coc.nvim
依赖环境：nodejs
```
curl -sL install-node.now.sh/lts | bash
curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
```
代码补全插件
```vim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
```
coc.nvim 使用 :CocConfig 打开配置文件，默认路径 `~/.config/nvim/coc-settings.json` ,这里只介绍golang的配置，配置文件添加:
```json
{
    "languageserver": {
        "golang": {
            "command": "gopls",
            "rootPatterns": ["go.mod"],
            "trace.server": "verbose",
            "filetypes": ["go"]
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
小问题可以用改命令解决: `call coc#util#install()`

## 最终配置
`~/.config/nvim/init.vim`
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

"==============================================================================
" vim plug 
"==============================================================================

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mhinz/vim-startify'
Plug 'fatih/vim-go'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

"==============================================================================
" vim plug config 
"==============================================================================



"----------------------------------------------------------------------------
" NERDTree config
"----------------------------------------------------------------------------
 " F2键快速调出和隐藏它
 map <F2> :NERDTreeToggle<CR>
 " 关闭vim时，如果打开的文件除了NERDTree没有其他文件时，它自动关闭，减少多次按:q!
 autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
 " 打开vim时自动打开NERDTree
 autocmd vimenter * NERDTree
 "设定 NERDTree 视窗大小
 let g:NERDTreeWinSize = 25

"----------------------------------------------------------------------------
" vim-go config
"----------------------------------------------------------------------------
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


"----------------------------------------------------------------------------
" coc.vim config
"----------------------------------------------------------------------------
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
```

`~/.config/nvim/coc-settings.json`
```json
{
    "languageserver": {
        "golang": {
            "command": "gopls",
            "rootPatterns": ["go.mod"],
            "trace.server": "verbose",
            "filetypes": ["go"]
        }
    },
    "suggest.noselect": false,
    "coc.preferences.diagnostic.displayByAle": true,
    "suggest.floatEnable": true
}
```