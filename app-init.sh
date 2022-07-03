#!/bin/bash
sudo apt-get update && \
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install pm2@latest -g && \
mkdir -p ~/app && \
mv /tmp/index.js ~/app && \
mv /tmp/package.json ~/app && \
mv /tmp/package-lock.json ~/app && \
cd ~/app && \
sudo npm ci
sudo pm2 start npm -- start && \
sudo pm2 startup systemd && \
sudo pm2 save