#Raspberry Pi Readout System
Lets try makefile deployment.
##Setting Up a new server
It starts with flashing a raspberry pi image and then expanding the file system with raspi-config.
```bash
sudo raspi-config
```
Then make a bash script `nano setup.sh`, and add the following.
```bash
#!/bin/bash
#Check if running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

read -e -p "Change hostname to: " host
read -e -s -p "Root (pi) Password :" rootPasswd
echo ""
read -e -p "Username :" userName
read -e -s -p "$userName Password :" userPasswd
echo ""

#We need a newer version of node, this adds that link
curl -sLS https://apt.adafruit.com/add | sudo bash

#Update/upgrade
apt-get update && apt-get -y upgrade

#Install webserver, node, node package manager, sqlServer
apt-get -y install nginx
apt-get -y install node
apt-get -y install npm
apt-get install -y postgresql

#Change root (pi) password
echo "pi:$rootPasswd" | chpasswd

#Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)

#change hostname in /etc/hosts & /etc/hostname
sudo sed -i "s/$hostn/$host/g" /etc/hosts
sudo sed -i "s/$hostn/$host/g" /etc/hostname

#Create the user
useradd -m -G docker sudo $userName
echo "$userName:$userPasswd" | chpasswd
```
And then run it, and reboot
```bash
chmod 755 setup.sh
sudo ./setup.sh
sudo reboot
```

Then from the local machine, append the remote aurthorized_keys your public key.
```bash
ssh-copy-id userName@remoteIPaddr
```
