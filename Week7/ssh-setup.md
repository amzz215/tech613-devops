[CI/CD overview and contents](./CICD.md) | [Jobs 1-3 and webhook setup](./cicd-setup.md)

## Setting Up SSH for GitHub

I use SSH to authenticate with GitHub when I push from Git Bash. I set it up locally first so I can check that SSH works before using it in Jenkins.

I create an RSA key pair in my `~/.ssh` folder. When prompted for a filename, I enter `ameen-github-key`.

```bash
mkdir -p ~/.ssh
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -C "my-github-email@example.com"
```

I use `cat ~/.ssh/ameen-github-key.pub` to display my public key. In GitHub, I go to **Settings → SSH and GPG keys → New SSH key** and paste the public key. I keep the private key, `ameen-github-key`, on my machine.

I start the SSH agent, load my private key and test the connection. GitHub’s message that I’ve successfully authenticated but don’t have shell access means the test worked.

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/ameen-github-key
ssh -T git@github.com
```

In my local repo, I copy the **SSH URL** from GitHub. If the repo already has an `origin`, I use `set-url` to switch it to SSH, then push my `main` branch.

```bash
git remote set-url origin git@github.com:USERNAME/REPO.git
git push -u origin main
```

If the repo doesn’t have an `origin` yet, I use `git remote add origin git@github.com:USERNAME/REPO.git` instead.