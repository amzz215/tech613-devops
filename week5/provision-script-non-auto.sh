#!/bin/bash

set -e

cd /home/ubuntu

sudo apt update
sudo apt upgrade -y

sudo apt install unzip curl -y

echo "Downloading the application..."

curl -fL "https://raw.githubusercontent.com/amzz215/tech613-scripts/main/nodejs20-sparta-tictactoe-v1.zip" \
    -o nodejs20-sparta-tictactoe-v1.zip

sudo unzip -o nodejs20-sparta-tictactoe-v1.zip

echo "Installing Nginx..."

sudo apt install nginx -y

sudo sed -i 's|try_files \$uri \$uri/ =404;|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default

sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "Installing Node.js..."

curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh

sudo bash nodesource_setup.sh

sudo apt install nodejs -y

cd /home/ubuntu/app

# Do not connect to the database while preparing the app image.
unset MONGODB_URI
unset STATEFUL_MODE

echo "Installing application dependencies..."

sudo npm install

echo "Installing PM2..."

sudo npm install -g pm2

echo "App preparation complete."