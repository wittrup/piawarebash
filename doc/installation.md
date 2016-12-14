**Expand for lagre SD**
```bash
sudo raspi-config
```

**Download this git**
```bash
sudo apt-get install git -y
git config --global user.name "your name"
git config --global user.email "email@domain.com"
git init
git remote add origin https://github.com/wittrup/piawarebash.git
git fetch --all
rm .bashrc
git reset --hard origin/master
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
ssh-keygen -t rsa
cd ~/.ssh
cat id_rsa.pub >> authorized_keys
vim authorized_keys
# and copy paste them into your receiving server, and test with:
ssh -N -R 2222:localhost:22 -p <port> <user>@<hostname>
```

**Setup scripts: Reverse SSH tunnel (persistent)**
```bash
# Give execution privileges 
chmod 700 setupbin.sh
./setupbin.sh
chmod 700 bin/*.sh

vim ssh_tunnel_home.cfg
# Add your destination=<user>@<hostname>:<port>

crontab -e
### Add jobs (found at file picrontabs)
```
LINK: [picrontabs](https://github.com/wittrup/piawarebash/blob/master/picrontabs)

**samba**
```bash
sudo apt-get install samba

smbpasswd -a <user_name>

sudo vi /etc/samba/smb.conf

#Scroll down to the end of the file and add these lines:

[<folder_name>]
path = /home/<user_name>/<folder_name>
available = yes
valid users = <user_name>
read only = no
browsable = yes
public = yes
writable = yes

sudo service smbd restart
```
