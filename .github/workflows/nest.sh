#!/bin/bash


set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 18
export PATH=/home/ubuntu/.nvm/versions/node/v18.10.0/bin:$PATH
cd realdeal-be/
rm -rf dist2
mv dist1/ dist2/
mv dist/ dist1/
cp -r /tmp/be/dist.zip .
cp -r /tmp/be/node.zip .
cp -r /tmp/be/package-lock.json .
cp -r /tmp/be/package.json .
unzip dist.zip
unzip node.zip
rm -rf dist.zip
rm -rf node.zip
pm2 restart 0
pm2 status
