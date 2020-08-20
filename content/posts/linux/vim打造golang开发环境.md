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

## 安装
### 安装neovim
> 官方文档：https://github.com/neovim/neovim/wiki/Installing-Neovim#Linux

```bash
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y neovim python3-neovim
# you might need python2-neovim as well on older Fedora releases
```
### 插件管理
> 官方文档：https://github.com/junegunn/vim-plug
```bash
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
