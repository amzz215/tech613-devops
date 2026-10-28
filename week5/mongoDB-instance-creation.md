## MongoDB Instance creation 

## EC2 Creation 

1. First I create an Instance as normal 
2. In the security group however, I now add the port 27017
   - This allows internet web traffic to access the service at port 27017 assuming the source is all 0s 
3. Create the database instance. 
4. Once logged into the ubuntu database instance i run `sudo apt-get update -y` and `sudo apt-get upgrade -y`.
   - These two commands fetches all the packages and then checks if those packages are up-to-date, then the second command actually upgrades those packages to be up-to-date.
5. Once the environment is up-to-date I run the command `curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor`
6. Then I run the command `echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list` 
7. Now I update all packages again via `sudo apt-get update -y`
8. `sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
   mongodb-org=7.0.22 \
   mongodb-org-database=7.0.22 \
   mongodb-org-server=7.0.22 \
   mongodb-mongosh \
   mongodb-org-shell=7.0.22 \
   mongodb-org-mongos=7.0.22 \
   mongodb-org-tools=7.0.22 \
   mongodb-org-database-tools-extra=7.0.22` - 
9. Then `cd` into the root directory `/`
10. Within the root directory `cd` into the etc directory, this is usually where all the app configuration files are stored. 
11. Edit the mongod.conf file via `sudo nano mongod.conf`, and then within that file change the BindIp to `0.0.0.0`, allowing tarffic from any location in the internet. 
12. Save and exit that file then `cd` into the home directory using `~`
13. Then use `sudo sysetmctl start mongod` and `sudo systemctl enable mongod` subsequently to start and enable mogoDB. 