## Database Connection 

## App Connection to Database 
1. `sudo apt-get update -y` and `sudo apt-get upgrade -y`, to update packages and download those updated packages into the VM 
2. Within the app directory use `export MONGODB_URI=mongodb://DB-PUBLIC-IP-ADDRESS:27017/tictactoe` and replace ip-address with my actual private ip-address
3. Check that the environment was created using the command `printenv MONGODB_URI` 
   - Should output something similar to `mongodb://18.201.25.107:27017/tictactoe`
4. `cd` into the app directory and within the app diretory kill the process via `sudo pm2 kill` with my application must use `sudo` because it's running on root 
5. Then run `sudo -E npm install` 
6. This should work but if it doesnt then Continue with the next commands. 
7. After that run `sudo -E node seeds/seed.js`
8. Run this command afterwards `sudo -E pm2 restart tictactoe --update-env || sudo -E pm2 start npm --name tictactoe -- start`
9. `sudo env PM2_HOME=/home/ubuntu/.pm2 pm2 save`, saves the process for the next command 