# Installation guide for rhel fedora

**Download this git**
```bash
sudo yum install git -y
git config --global user.name $USER
git config --global user.email "email@domain.com"
git init
git remote add origin https://github.com/wittrup/piawarebash.git
git fetch --all
rm .bashrc
git reset --hard origin/master
```

**Tunnel users creation**
```bash
sudo groupadd sshtungrp
sudo mkdir /etc/ssh/tunnelkeys
# Add users without /home
while read p; do sudo useradd $p -r -s /bin/true -g sshtungrp; done < users.txt;
# Copy key file with: sudo vim /etc/ssh/tunnelkeys/%u (where %u is replaced by the username)
```

**sshd_config Match block**
```bash
Match Group sshtungrp
        AuthorizedKeysFile /etc/ssh/tunnelkeys/%u
```

**sshd testing**
```bash
(echo "Port 2222"; grep -v '^#' /etc/ssh/sshd_config) | sudo tee /etc/ssh/sshd_config-port2222 >> /dev/null
while true; do sudo /usr/sbin/sshd -d -f /etc/ssh/sshd_config-port2222; printf "\n\n\n"; sleep 1; done;
sudo service sshd restart
```

**Tunnel users cleanup**
```bash
while read p; do sudo userdel -rf $p; done < users.txt;
sudo userdel -rf sshtunnel
sudo groupdel sshtungrp
```
