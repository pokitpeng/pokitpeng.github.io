# Vim打造golang开发环境

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
" leader按键
let mapleader = "\<space>"
" 检测文件类型
filetype on
" 针对不同的文件类型采用不同的缩进格式
filetype indent on
" 允许插件
filetype plugin on
" 启动自动补全
filetype plugin indent on


" 在上下移动光标时，光标的上方或下方至少会保留显示的行数
set scrolloff=7

" 切换paste模式
set pastetoggle=<F3>

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
" other config 
"==============================================================================
" vimrc文件修改之后自动加载, windows
autocmd! bufwritepost _vimrc source %
" vimrc文件修改之后自动加载, linux
autocmd! bufwritepost .vimrc source %

" 自动补全配置
" 让Vim的补全菜单行为与一般IDE一致(参考VimTip1228)
set completeopt=longest,menu

" 增强模式中的命令行自动完成操作
set wildmenu
" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.class

" 离开插入模式后自动关闭预览窗口
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" 回车即选中当前项
inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"

" In the quickfix window, <CR> is used to jump to the error under the
" cursor, so undefine the mapping there.
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
" quickfix window  s/v to open in split window,  ,gd/,jd => quickfix window => open it
autocmd BufReadPost quickfix nnoremap <buffer> v <C-w><Enter><C-w>L
autocmd BufReadPost quickfix nnoremap <buffer> s <C-w><Enter><C-w>K

" command-line window
autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>


" 上下左右键的行为 会显示其他信息
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"

" 打开自动定位到最后编辑的位置, 需要确认 .viminfo 当前用户可写
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
```
### 3.2. 插件配置
#### 3.2.1. 目录管理
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
#### 3.2.2. 状态栏美化

```vim
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
```
#### 3.2.3. 开屏美化
```vim
Plug 'mhinz/vim-startify'
```
#### 3.2.4. go语言必备
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

#### 3.2.5. 代码补全

依赖环境：nodejs
```
curl -sL install-node.now.sh/lts | bash
curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
```
代码补全插件
```vim
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
```
安装补全插件

```
CocInstall coc-go coc-json coc-snippets coc-yaml
```



## 4. 最终配置
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

