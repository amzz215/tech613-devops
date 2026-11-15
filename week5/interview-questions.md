# AWS App Deployment — Interview Revision Notes

## 1. I want to deploy the tic-tac-toe app on AWS. What do I need?

First, I clarify whether the application needs a database.

For the app alone, I need:

| Component | Purpose |
|---|---|
| EC2 instance | Provides the virtual machine to host the app. |
| Ubuntu | Provides the operating system. |
| Security group | Controls which network traffic can reach the instance. |
| SSH and a key pair | Allow secure remote access to configure the instance. |
| Application files | Provide the code to run. |
| Node.js | Runs the JavaScript application. |
| Application dependencies | Provide the packages the app needs, installed using `npm install`. |
| PM2 | Manages the application process in the background. |
| Nginx | Acts as a reverse proxy, forwarding requests to the app. |

**Why am I learning this?**  
To understand what each component contributes to a working cloud deployment, rather than only memorising installation commands.

**Transcript reference:** Week 6 — Main call recording 1, 00:34:28–00:38:19.

## 2. On a clean Ubuntu instance, what must I install or configure for a monolithic deployment, and why?

For this exercise, the deployment runs the app on one instance without a separate database.

### Step 1: Update the package list

```bash
sudo apt-get update
```

This refreshes information about available packages. It does not upgrade installed packages.

### Step 2: Install Node.js

Node.js runs the application’s JavaScript code.

### Step 3: Transfer or download the application

The application files must be available on the instance before they can be run.

### Step 4: Install application dependencies

Inside the application directory:

```bash
npm install
```

This installs the packages required by the application.

### Step 5: Install PM2 and start the app

```bash
sudo npm install -g pm2

pm2 start npm --name tictactoe -- start
```

- `-g` installs PM2 globally.
- `--name tictactoe` gives the managed process a recognisable name.
- `-- start` passes `start` to npm, running the application’s `npm start` command.
- PM2 manages the app in the background.

### Step 6: Install and configure Nginx

I configure Nginx as a reverse proxy:

- Nginx receives HTTP requests on port **80**.
- It forwards those requests to the app on port **3000**.

Example configuration inside the appropriate Nginx location block:

```nginx
proxy_pass http://localhost:3000;
```

### Step 7: Allow HTTP traffic

The app instance’s security group must allow incoming traffic on port **80** from the intended users.

### Does the app need Nginx to run?

No. Node.js runs the application.

Nginx provides the reverse proxy so users can access the app through the standard HTTP port without adding `:3000` to the address.

Opening port 80 in the security group only permits traffic. It does not configure Nginx to forward requests to the app.

**Why am I learning this?**  
To understand the difference between running an application, managing its process, allowing network traffic and forwarding requests.

**Transcript reference:** Week 6 — Main call recording 1, 00:38:30–00:50:14.

## 3. What does a two-tier deployment mean?

A two-tier deployment separates the application and database into two tiers.

In my exercise:

| Tier | What runs there |
|---|---|
| Application tier | The tic-tac-toe app on an EC2 instance. |
| Database tier | MongoDB on a separate EC2 instance. |

The app connects to MongoDB over the network.

### Why am I learning this?

To understand how an application uses a separate database and what additional networking and configuration that requires.

Separating the tiers also allows me to manage the app and database independently.

**Transcript reference:** Week 6 — Main call recording 1, 00:51:14–01:02:46 and 01:21:58–01:23:17.

## 4. What extra steps are needed to change my app deployment into a two-tier deployment?

### Step 1: Create the database instance

I create a separate EC2 instance and install MongoDB on it.

### Step 2: Configure MongoDB to accept remote connections

In `/etc/mongod.conf`, my exercise uses:

```yaml
net:
  port: 27017
  bindIp: 0.0.0.0
```

- `27017` is the MongoDB port.
- `0.0.0.0` makes MongoDB listen on all IPv4 network interfaces.
- The security group still controls which sources can reach it.

After changing the configuration:

```bash
sudo systemctl restart mongod
```

### Step 3: Enable MongoDB on boot

```bash
sudo systemctl enable mongod
```

- `restart` applies the configuration by restarting the service now.
- `enable` configures the service to start when the instance boots.

### Step 4: Configure the database security group

I allow incoming **TCP port 27017** from the app’s security group.

The database does not need port 80 for the app’s MongoDB connection.

### Step 5: Set the app’s database connection variable

On the app instance, before starting the app:

```bash
export MONGODB_URI="mongodb://DB-PRIVATE-IP:27017/tictactoe"
```

I replace `DB-PRIVATE-IP` with the database instance’s actual private IP.

| Part | Meaning |
|---|---|
| `export` | Makes the variable available to processes started from this shell. |
| `MONGODB_URI` | The environment variable this app reads for its database connection. |
| `mongodb://` | The MongoDB connection scheme. |
| `DB-PRIVATE-IP` | The database instance’s private network address. |
| `27017` | The database port. |
| `tictactoe` | The database name. |

### Step 6: Start the app with the variable available

The connection variable must be available to the app process when it starts.

For my ASG exercise, launch-template user data sets the variable before starting the app through PM2.

### Step 7: Seed the database once, if needed

Seeding adds initial scoreboard records.

From the app directory:

```bash
export MONGODB_URI="mongodb://DB-PRIVATE-IP:27017/tictactoe"

sudo -E node seeds/seed.js
```

- I replace the placeholder with the actual database private IP.
- `sudo -E` asks sudo to preserve the environment, including the connection variable.
- The command runs on the app instance but writes records to the database instance.
- I skip this step if the database already contains the data I want.

### Why keep seeding out of ASG startup?

All ASG app instances connect to the same database.

Launching another app instance should not reset the scoreboard. Therefore, my ASG user data starts the app without running the seed script or `npm install`, which invokes seeding in this project.

### Step 8: Verify the connection

I check that the application is using MongoDB, rather than only confirming that the webpage loads.

### Why am I learning this?

To understand that a working database connection requires several things together:

- MongoDB must be running.
- MongoDB must listen for connections from the app.
- Security groups must allow the traffic.
- The app must use the correct database address and port.
- The connection variable must be available when the app starts.

**Transcript references:**

- Week 6 — Main call recording 1, 01:10:47–01:33:57: database setup, connectivity and security.
- Tech 613 — Week 5 Call (4), 02:43–02:49: dependencies, seeding and ASG startup.