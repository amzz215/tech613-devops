#!/bin/bash

echo "Unzipping and downloading NodeJs for you..."

cd ~

sudo apt update

sudo apt upgrade -y

sudo apt install unzip -y

sudo unzip -o nodejs20-sparta-tictactoe-v1.zip

sudo apt install nginx -y

echo "File has been unzipped and NginX has been installed, downloading NodeJs..."

curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh

sudo bash nodesource_setup.sh

sudo apt install nodejs -y

mkdir -p ~/app

cd ~/app

npm install

sudo npm install -g pm2

pm2 restart tictactoe || pm2 start npm --name tictactoe -- start

pm2 save

echo "NodeJs has started, append ':3000' to the server's IP address to view."
