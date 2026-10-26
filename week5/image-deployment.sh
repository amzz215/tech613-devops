#!/bin/bash
set -e

cd /home/ubuntu/app

pm2 restart tictactoe || pm2 start npm --name tictactoe -- start

pm2 save