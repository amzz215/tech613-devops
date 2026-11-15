#!/bin/bash

set -e

cd /home/ubuntu/app

export MONGODB_URI="mongodb://DB-PRIVATE-IP:27017/tictactoe"

export PM2_HOME=/root/.pm2

pm2 restart tictactoe --update-env || pm2 start npm --name tictactoe -- start