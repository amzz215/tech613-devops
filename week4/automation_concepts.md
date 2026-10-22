## Automation 

### Foreground vs background processes

Foreground and background describe how a program runs in relation to the terminal. 

| | Foreground | Background |
|---|---|---|
| Terminal | Waits for the program to finish | Lets you enter more commands |
| Output | Usually appears directly in the terminal | Can be redirected or managed through logs |
| Example | Running `npm start` directly | Running the app through PM2 |

### PM2 

PM2 is a process manager. It runs your app in the background and can restart it if it crashes. 

PM2 keeps the app managed after you disconnect SSH. Restoring it afer a VM reboot also requires startup configuration and a saved process list. 

### Idempotency 

An operation is idempotent if repeating it leaves the same  intended state as running it once. 
For your provisioning script, the gol is: the app is installed and one managed instance is running.

Running setup again should leave a working setup, without unwanted duplicates or broken state.

### Proxies and forward proxies

A proxy acts on behalf of someone or something else.
A forward proxy acts on behalf of the client, such as your laptop. Your requests go through it before reaching the destination server. 

### Reverse proxies — acting on behalf of the server

A reverse proxy receives requests from clients and forwards them to the appropriate application or server. 

| Proxy type | Represents |
|---|---|
| **Forward proxy** | The client requesting something |
| **Reverse proxy** | The server providing something |

1. Your browser requests http://<VM-public-IP> on port 80
2. Nginx receives the request
3. Nginx forwards it to your Tic-Tac-Toe app on port 3000
4. The app’s response returns through Nginx to your browser

`proxy_pass`- Specifies the destination for forwarded requests.

### Automating file edits with sed

`sudo sed -i 's|try_files \$uri \$uri/ =404;|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default`

| Part | Meaning |
|---|---|
| `sudo` | Run with permission to edit the system file |
| `sed` | Process and transform text |
| `-i` | Save changes directly into the file |
| `s|old|new|` | Substitute matching old text with new text |
| `\$uri` | Match the literal text `$uri` |
| `/etc/nginx/sites-available/default` | File to edit |

### Load balancing — sharing requests across servers

Local balancing distirbutes incoming requests across multiple servers running your application. 

| Request | Illustrative destination |
|---|---|
| Player A opens the website | Server 1 |
| Player B opens the website | Server 2 |
| Player C opens the website | Server 3 | 

This is advantageous because:
1. Spread traffic: reduce the work each server handles
2. Support horizontal scaling: distribute requests to added servers
3. Improve availability: with health checks configured, route requests away from unhealthy servers

### Caching — reusing a stored response

Caching means keeping a copy of something dso future requests can reuse it, instead of fetching or calculating it again. 

Caching avoids repeating some work. 

### HTTPS termination — handling encryption at the reverse proxy

Https termination is when the reverse proxy handles the browser's encrytped HTTPS connection.

“Termination” refers to where that TLS connection ends. You can also encrypt the separate connection from the proxy to the backend when needed. 





