#!/bin/bash

# purpose of this script: run on fresh ubuntu 24.04, install nginx

# update 

# upgrade 

# install nginx
sudo apt-get install nginx -y 
# restart nginx
sudo systemctl restart nginx
# enable nginx
sudo systemctl enable nginx


