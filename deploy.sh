#!/usr/bin/env bash

# 安装
# go get github.com/gohugoio/hugo@v0.69.0

# 常用命令：
# hugo serve 调试
# hugo serve -D 显示草稿
# hugo new posts/...

# 确保脚本抛出遇到的错误
# set -e

git config --local user.name "pokitpeng"
git config --local user.email "ahpp1001@163.com"

# src分支更新
git add .

git commit -m "update src"

git push origin src:src

# 生成静态文件
hugo

# 进入生成的文件夹
cd public/

git init
git add .
git commit -m 'deploy'

git remote add origin https://github.com/pokitpeng/pokitpeng.github.io.git
# git pull
git push --force origin HEAD:master

cd -