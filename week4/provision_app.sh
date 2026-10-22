#!/bin/bash
set -e

echo "Unzipping and downloading NodeJs for you..."

cd /home/ubuntu

sudo apt update

sudo apt upgrade -y

sudo apt install unzip curl -y

curl -fL "https://raw.githubusercontent.com/amzz215/tech613-scripts/main/nodejs20-sparta-tictactoe-v1.zip" \
    -o nodejs20-sparta-tictactoe-v1.zip

sudo unzip -o nodejs20-sparta-tictactoe-v1.zip

sudo apt install nginx -y

sudo sed -i 's|try_files \$uri \$uri/ =404;|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default

sudo nginx -t

sudo systemctl reload nginx

echo "File has been unzipped and Nginx has been installed, downloading NodeJs..."

curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh

sudo bash nodesource_setup.sh

sudo apt install nodejs -y

mkdir -p /home/ubuntu/app

cd /home/ubuntu/app

npm install

sudo npm install -g pm2

pm2 restart tictactoe || pm2 start npm --name tictactoe -- start

pm2 save

sudo env PATH="$PATH" pm2 startup systemd -u root --hp /root

echo "View the app at http://<instance-public-ip>"
