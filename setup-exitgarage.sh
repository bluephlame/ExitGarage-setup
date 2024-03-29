#!/bin/bash
# This script setups for exit garage to run on a Raspberry pi.

# echo "Boot strapping ExitGarage."
sudo wget -O /usr/local/bin/rmate https://raw.githubusercontent.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/rmate

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install git make


sudo apt update
sudo apt install -y mosquitto mosquitto-clients
sudo systemctl enable mosquitto.service

#install node
ARCH=`uname -m`
echo "${ARCH}"
URL=https://nodejs.org/dist/v10.16.0/node-v10.16.0-linux-${ARCH}.tar.xz
echo "downloading ${URL}"
filename=$(basename "${URL}")
wget -N "${URL}"

#untar and setup node
tar -xJf ${filename}
directory="${filename%.*.*}"
sudo cp -R ${directory}/* /usr/local/
sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}

#install homebridge
sudo npm install -g --unsafe-perm homebridge
sudo npm install -g pm2


#install plugins
npm install -g --unsafe-perm @bluephlame/homebridge-gpio-garagedoor
npm install -g --unsafe-perm homebridge-izone3-aircon-platform
npm install -g --unsafe-perm @bluephlame/homebridge-mqtt-switch-tasmota

#get dtb file and load into config.txt

sudo wget -N https://github.com/bluephlame/ExitGarage-setup/raw/master/mygpio-overlay.dtb -O /boot/overlays/mygpio-overlay.dtb
sudo echo  "device_tree_overlay=overlays/mygpio-overlay.dtb" >> /boot/config.txt

sudo wget -N https://raw.githubusercontent.com/bluephlame/ExitGarage-setup/master/config.json -O ~/.homebridge/config.json
pm2 startup
pm2 start homebridge
pm2 save
