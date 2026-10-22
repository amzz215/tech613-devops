## App Installation Within a Server 

### Create Appropriate Instance 

Instance must contain ports for 22, 80 and 3000
1. 22 port is the default port for ssh which is a secure way to connect to a rmeote shell via encryptions. 
2. 80 port is for Http 
3. 3000 port is for web apps like node.js

### Connect to Instance 

Connect to the instance using the public DNS 
1. `cd` into the .ssh file then run the command given by aws to connect to the public DNS. 

### Move the file from the local machine into the ubuntu machine 

1. Use the `scp` command to move the file to the ubuntu machine 
2. First we want to `cd` into where the filewe want to move is in and in this scenario it's in downloads.
3.  `scp -i ~/.ssh/tech613-ameen-aws-key.pem nodejs20-sparta-tictactoe-v1.zip ubuntu@34.245.218.237:/home/ubuntu/` - from the home directory go into the .ssh folder and get my key stored in the .pem file and use that key to authenticate that I can access that ubuntu machine. Then I usa a space and provide the file i want to move to the ubuntu machine in this case that is the nodejs-naughts and crosses file and then i provide another space and i provide which ubuntu machine i am reting to move my file to i do this by adding `ubuntu@` then the public IP address that can be found at my aws instance summary followed by a `:`followed by `/home/ubuntu/`
4.  I should be prompted to confirm that I am trying to add ubuntu as a known host. This is because it is my first time doing so but if i was to theoretically add to the same host again i shouldn't get that message. 
5.  To confirm that the command worked and that my file is at my host i should `ls` on the git bash of my ubuntu host and i should see the file there. 

### Download the file into the Ubuntu host server 
1. `sudo apt update` - check that all the packages are up to date
2. `sudo apt upgrade -y` - this actually downlaods those up to date packages saying yes to all prompts
3. `sudo apt install unzip -y`
4. `sudo unzip filename.zip` - this and the previous step is only done if the file is azip file.
5. `sudo apt install nginx -y` - this opens on port 80 because its a web app. Check if nginx is open by coping the public ip into an browser then change https into http and nginx should welcome me. 
6. `curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh` - installs a specific version of nodejs
7. `sudo bash nodesource_setup.sh` - 
8. `sudo apt install nodejs -y`
9. `node -v` - gets the version of nodejs we're using
10. `cd app`
11. `npm install`
12. `npm start`

### Bash Script: NPM start v1

#!/bin/bash

echo "Unzipping and downloading NodeJs for you..."

cd ~

sudo apt update

sudo apt upgrade -y

sudo apt install unzip -y

sudo unzip -o nodejs20-sparta-tictactoe-v1.zip

sudo apt install nginx -y

echo "File has been unzipped and NginX has been instated, downloading NodeJs..."

curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh

sudo bash nodesource_setup.sh

sudo apt install nodejs -y

mkdir -p ~/app

cd ~/app

npm install

npm start

echo "NodeJs has started, append ":3000" to the servers IP address to view."


### Bash Script: PM2 start v2

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