#!/bin/bash
#
# About: This stupid script installs counterparty-lib and counterparty-client on
# a clean Ubuntu 16.04 system/VM. Run it as a non-root user, but with sudo:
#
# sudo bash install.sh 
#
# Author: unsystemizer (on Github)
# Bugs: https://github.com/unsystemizer/counterparty-config-example/
#       Please do not submit bugs for other OS/version; such issues 
#       can be discussed on counterpartytalk.org.


# Update the OS
sudo apt-get update; sudo apt-get upgrade -y
# Install necessary files and upgrade pip
sudo apt-get install openssh-server unzip wget build-essential python3-dev -y
wget https://bootstrap.pypa.io/get-pip.py; sudo python3 get-pip.py
sudo apt-get install python3-setuptools

# A reboot is recommended but sometimes not strictly necessary
# sudo reboot 
# If you've rebooted, delete the part above and re-run (or copy-paste
# the part below into Bash shell)

# Server 
wget https://github.com/CounterpartyXCP/counterparty-lib/archive/master.zip
mv master.zip lib.zip
apt-get install unzip -y
sudo apt-get install -y
unzip lib.zip
cd counterparty-lib-master/
sudo pip3 install -r requirements.txt
sudo python3 setup.py install
cd ..

# Client 
wget https://github.com/CounterpartyXCP/counterparty-cli/archive/master.zip
mv master.zip cli.zip
unzip cli.zip
cd counterparty-cli-master/
sudo pip3 install -r requirements.txt
sudo python3 setup.py install

# Remove the downloaded stuff if you don't need it:
# rm -rf counterparty-client counterparty-server cli.zip lib.zip get-pip.py

# After that... 
echo "-------------------------------------------------------------------------"
echo ""
echo "Now ensure that your configuration files are correct."
echo ""
echo "You can find a sample here:"
echo "https://github.com/unsystemizer/counterparty-config-example"
echo ""
echo "On the same page there's also a dumb script that can overwrite"
echo "existing (default) config files for you."