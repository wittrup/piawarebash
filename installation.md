**Expand for lagre SD**
```bash
sudo raspi-config
```

**Vim text editor**
```bash
sudo apt-get update -y
sudo apt-get install vim -y
select-editor
```

**Change hostname**
```bash
sudo vim /etc/hosts
sudo vim /etc/hostname
sudo /etc/init.d/hostname.sh
sudo reboot
```

**WiFi setup**
```bash
piaware-config wireless-network yes
piaware-config wireless-ssid MyWifiNetwork
piaware-config wireless-password s3cr3t
```

**Automatic ssh login using ssh keys**
```bash
cd ~/.ssh
ssh-keygen -t rsa
cat id_rsa.pub >> authorized_keys
vim authorized_keys
# and copy paste them into your receiving server, and test with:
ssh -N -R 2222:localhost:22 -p <port> <user>@<hostname>
```

**Download this git**
```bash
sudo apt-get install git -y
git config --global user.name "your name"
git config --global user.email "email@domain.com"
git init
git remote add origin https://github.com/wittrup/piawarebash.git
rm .bashrc
git fetch --all
git reset --hard origin/master
```

**Setup scripts: Reverse SSH tunnel (persistent)**
```bash
# Give execution privileges 
chmod 700 setupbin.sh
setupbin.sh
chmod 700 bin/*.sh

vim ssh_tunnel_home.cfg
# Add your destination=<user>@<hostname>:<port>

crontab -e
### Add jobs (found at file picrontabs)
```
LINK: [picrontabs](https://github.com/wittrup/piawarebash/blob/master/picrontabs)
