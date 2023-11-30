#!/bin/bash


set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 18
export PATH=/home/ubuntu/.nvm/versions/node/v18.10.0/bin:$PATH
cd realdeal-fe/
rm -rf build2
mv build1/ build2/
mv build/ build1/
cp -r /tmp/fe/build.zip .
cp -r /tmp/fe/node.zip .
cp -r /tmp/fe/package-lock.json .
cp -r /tmp/fe/package.json .
unzip build.zip
unzip node.zip
rm -rf dist.zip
rm -rf node.zip
pm2 restart 3
pm2 status
