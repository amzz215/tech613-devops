[CI/CD overview and contents](./CICD.md) | [SSH authentication setup](./ssh-setup.md)

## Jenkins Job 1: Build and Test

1. I created a Freestyle job called `tech613-ameen-job1-build-test`. Under **Source Code Management → Git**, I entered my repo’s SSH URL, selected my GitHub SSH credential and set the branch to `*/dev` so Jenkins tests the development branch.

2. Under **Build Steps → Execute shell**, I added:

   ```bash
   set -e
   cd app
   npm ci
   npm test
   ```

I use `cd app` to enter the app folder, `npm ci` to install the versions in `package-lock.json`, and `npm test` to run the tests. `set -e` stops the script if a command fails.

3. I left **Build Triggers** and **Build Environment** unchecked for the manual run. I used **Build Now** and checked **Console Output** for `Finished: SUCCESS` before moving on to Job 2.

## Set Up the GitHub Webhook for Job 1

I set up a webhook so GitHub notifies Jenkins when I push code. Job 1 checks for changes on `dev`, so I don’t have to click **Build Now** after every push.

1. In Jenkins, I open **Job 1 -> Configure -> Build Triggers**, tick **GitHub hook trigger for GITScm polling**, and save. I keep the branch specifier set to `*/dev`.

2. In GitHub, I open my repository and go to **Settings -> Webhooks -> Add webhook**. I set the **Payload URL** to my course Jenkins URL followed by `/github-webhook/`, including the trailing slash. I select `application/json`, choose **Just the push event**, and leave **Active** checked.

3. To test it, I push a new commit to `dev`. I check **Recent Deliveries** in GitHub to confirm Jenkins received the webhook, then check **Job 1 -> Build History** to confirm the job started automatically.

### Why I Set Up Job 1

I set up Job 1 to test changes on `dev` before they reach `main`. Jenkins runs the same checks each time, so I can catch problems early and stop failed changes from moving on to Job 2, which handles the merge.

I used `npm ci` so Jenkins installs the dependency versions recorded in `package-lock.json`. I ran the job manually first to confirm Jenkins could access the repository, check out `dev` and pass the tests before setting up automatic triggers.

## Jenkins Job 2: Merge dev into main

I set up Job 2 to run only after Job 1 passes its tests. Job 2 takes the changes from `dev`, merges them into `main`, and pushes the result back to GitHub.

1. Under **Source Code Management**, I used the same SSH repo URL and Jenkins credential as Job 1. I kept `*/dev` as the branch to build and added **Merge before build** with `origin` as the repository and `main` as the merge target.

2. Under **Build Triggers**, I selected **Build after other projects are built**, chose Job 1, and set it to trigger only if the build is stable. Job 2 doesn’t need its own webhook or npm commands because Job 1 handles the trigger and tests.

3. Under **Post-build Actions**, I added **Git Publisher** and ticked **Merge Results** and **Push Only If Build Succeeds**. My first run merged locally but failed to push because I used an HTTPS URL with an SSH key. I switched the repo URL to SSH so Jenkins could use the key to push.

4. To check the full setup, I push a small change to `dev`, check that both jobs finish with `SUCCESS`, then confirm the change appears on `main` in GitHub.

### Why I Set Up Job 2

I set up Job 2 so Jenkins merges changes from `dev` into `main` only after Job 1 passes. This saves me from merging and pushing manually after every successful test run.

### What Happens After a Push

When I push to `dev`, Job 1 runs the tests. If the tests fail, Job 2 doesn’t start, so that change stays on `dev`. If they pass, Job 2 merges the changes and uses Git Publisher to update `main` on GitHub. This gives Job 3 a branch to deploy from later. Job 2 itself doesn’t deploy the app.

## Jenkins Job 3: Deploy Application

I created `tech613-ameen-job3-cd-deploy` to deploy my app after Job 2 successfully merges the changes into `main`.

### Jenkins setup

- **General:** I set Jenkins to keep the last 5 builds and added my GitHub project URL as a shortcut.
- **Source Code Management:** I selected Git, used my GitHub SSH credential, and set the branch to `*/main`. Jenkins checks out `main` into Job 3’s workspace.
- **Build Triggers:** I selected **Build after other projects are built**, entered `tech613-ameen-job2-merge`, and chose **Trigger only if build is stable**.
- **Build Environment:** I selected Node.js 20 and enabled **SSH Agent** with my EC2 SSH credential. I used separate SSH credentials for GitHub and EC2. The deployment script uses the npm already installed on EC2.

Worker nodes is what copies the updated code into the app instance 

### Deployment script

I added this under **Build Steps → Execute shell**:

```bash
set -e
EC2=ubuntu@108.130.142.18

rsync -avz --no-perms --no-owner --no-group --omit-dir-times \
  --rsync-path="sudo -n rsync" --exclude node_modules \
  -e "ssh -o StrictHostKeyChecking=no" app/ "$EC2:/home/ubuntu/app/"

ssh -T -o StrictHostKeyChecking=no "$EC2" 'sudo -n sh -s' << 'EOF'
set -e
export PM2_HOME=/root/.pm2
cd /home/ubuntu/app
npm install
pm2 restart tictactoe || pm2 start npm --name tictactoe -- start
pm2 save
EOF
```

I use `rsync` to copy the contents of `app/` from Jenkins to `/home/ubuntu/app/` on EC2. I skip `node_modules` because I install the dependencies on EC2. After running into permission errors, I configured `rsync` to run as root on EC2 and skip preserving the source owner, group, permissions, and directory timestamps.

I connect as `ubuntu` and use `sudo -n sh -s` to run the whole `EOF` block as root. If `sudo` needs a password, it fails instead of prompting Jenkins. I set `PM2_HOME` to `/root/.pm2` because root’s PM2 manages my app. I install the dependencies, restart `tictactoe` or start it if the restart fails, then save the PM2 process list.

This means I can push a change to `dev` and have Jenkins test it, merge it into `main`, and deploy it to EC2 without manually copying files or restarting the app.

[Final result: homepage updated through CI/CD](./CICD.md#final-result)
