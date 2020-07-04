#!/usr/bin/env bash

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
hugo

# 进入生成的文件夹
cd public/

git init
git add -A
git commit -m 'deploy'

git remote add origin https://github.com/pokitpeng/pokitpeng.github.io.git
# git pull
git push --force origin HEAD:master

# 如果发布到 https://<USERNAME>.github.io/<REPO>
# git push -f git@github.com:<USERNAME>/<REPO>.git master:gh-pages

cd -