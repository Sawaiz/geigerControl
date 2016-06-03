#Running with docker
Docker is container system for Linux that allows easy deployment of web applications.
##Install Docker
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

#First Update/upgrade
apt-get update && apt-get -y upgrade

#Install docker 1.5.07
wget https://downloads.hypriot.com/docker-hypriot_1.10.3-1_armhf.deb
dpkg -i docker-hypriot_1.10.3-1_armhf.deb
rm docker-hypriot_1.10.3-1_armhf.deb

systemctl unmask docker.service
systemctl unmask docker.socket
systemctl start docker.service
systemctl enable docker

sudo apt-get install docker.io

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
