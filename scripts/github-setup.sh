#!/bin/bash
apt update -y && apt install openssh-client -y
# SSH setup
echo "$GH_BOT_SSH_KEY" > ssh.key
chmod 600 ssh.key
eval "$(ssh-agent -s)"
ssh-add ssh.key
mkdir ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# GPG setup
echo "$GH_BOT_GPG_KEY" > private.key
gpg --import private.key
echo "$GH_BOT_GPG_TRUST" > trustdb
gpg --import-ownertrust trustdb

# git setup
git config user.email "$GH_EMAIL"
git config user.name "$GH_USERNAME"
git config commit.gpgSign true

# install GH cli
type -p curl >/dev/null || (apt update -y && apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& apt update -y \
&& apt install gh -y
gh config set prompt disabled
