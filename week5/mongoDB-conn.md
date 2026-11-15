## Database Connection 

## App Connection to Database 
1. `sudo apt-get update -y` and `sudo apt-get upgrade -y`, to update packages and download those updated packages into the VM 
2. Within the app directory I use `export MONGODB_URI=mongodb://DB-PUBLIC-IP-ADDRESS:27017/tictactoe` and replace ip-address with my actual private ip-address
3. I check that the environment was created using the command `printenv MONGODB_URI` 
   - Should output something similar to `mongodb://18.201.25.107:27017/tictactoe`
4. I `cd` into the app directory and within the app directory kill the process via `sudo pm2 kill` with my application must use `sudo` because it's running on root 
5. Then I run `sudo -E npm install` 
6. This should work but if it doesnt then I continue with the next commands. 
7. After that I run `sudo -E node seeds/seed.js`
8. I run this command afterwards `sudo -E pm2 restart tictactoe --update-env || sudo -E pm2 start npm --name tictactoe -- start`
9. `sudo env PM2_HOME=/home/ubuntu/.pm2 pm2 save`, saves the process for the next command cd week5