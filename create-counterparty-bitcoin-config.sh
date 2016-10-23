#!/bin/bash

# OS: Ubuntu 16.04 (64-bit)
# Author: unsystemizer (on Github)
# Date: October 23, 2016
#
# This simple script installs Counterparty-lib, counterparty-client and
#  overwrites default configuration files for Counterparty and Bitcoin.
# Configuration files use default locations.

# Set this to $HOME of user who will run Counterparty and Bitcoin
# 1) If you don't have enough space on /home and want to create xcp's home in
#    /external/xcp, run "sudo useradd --create-home /external/xcp".
#    Then change HOME to /external/xcp.
# 2) You can use your own username, but it's "cleaner" to create another user
#    separate from yours. If you plan to use this not for development but
#    for own use of BTC/XCP/etc. it's probably easier to use your own account
# Replace this with output of "echo $HOME" to run as the current user.

HOME=(/home/`whoami`)

clear

echo ""
echo ""
echo "You need to modify the HOME variable to point to correct location"
echo "for the user who will run these services"
echo ""
echo "User's HOME is detected to be :" $HOME
echo ""
echo "If you don't press CTRL+C within 5 seconds, the script will continue"
sleep 6
clear
# If you already have these directories, nothing will happen to them

mkdir $HOME/.bitcoin/; mkdir -p $HOME/.config/counterparty/

# If you already have these files, they will be overwritten!
# Maybe they are default (non-working) configs in which case it doesn't matter

echo "If you have existing Counterparty and Bitcoin files they will be "
echo " overwritten"
echo ""
echo "To interrupt this script press CTRL+C echo within 5 seconds"

sleep 6

# If you already have a copy of blockchain somewhere on the network
#  just change "rpc-host"

cat << EOF > $HOME/.config/counterparty/server.conf
[Default]
# What kind of bitcoin server am I using?
backend-name = addrindex # Only "Bitcoin Core addrindex" is suported now
backend-user = bitcoin-rpc
backend-password = PaSS
# Which IP's can access this Counterparty server?
rpc-host = localhost # if you want to allow other hosts use a LAN address
# What are the server's RPC credentials?
rpc-user = counterparty-rpc
rpc-password = WoRD
# Should this run on testnet?
testnet = 0
EOF

cat << EOF > $HOME/.config/counterparty/client.conf
[Default]
wallet-name = bitcoincore # Only "Bitcoin Core addrindex" is suported
# Where's my bitcoin?
wallet-connect = localhost
wallet-user = bitcoin-rpc
wallet-password = PaSS
# Where's my counterparty-server?
counterparty-rpc-connect = localhost

# These configuration files should not be readable by other users
# Ownership should belong to the user who will run these services
# - do this by yourself
# 
chmod 700 $HOME/.config/counterparty/server.conf
chmod 700 $HOME/.config/counterparty/client.conf
chmod 700 $HOME/.bitcoin/bitcoin.conf

echo "You may want to recursively change the ownership of 
echo ".bitcoin and .config/counterparty if the owner is not"
echo "supposed to be " `whoami`

# Now you can start services **AS THE USER WHO OWNS THIS DATA** or sudo-er.
# 1) If you created the xcp account to run, you need to "su - xcp" before
#    you do this. If using your own, just run the commands. If you owned
#    these files by the root account, you would have to use "sudo" to run.
# 2) If you run bitcoind with "daemon = 1", it goes into background and
#    to stop it you need to run "bitcoin-cli stop" or
#    "bitcoin-cli -conf $HOME/.bitcoin/bitcoin.conf stop" (as the owning
#    user). If you chown-ed the directory by root, add sudo before the command.
#
# bitcoind -conf $HOME/.bitcoin/bitcoin.conf
#
# Wait 1-2 days or longer. If you have existing bitcoin blockchain,
#  you can possibly reuse it - see instructions and considerations here:
#  https://github.com/CounterpartyXCP/Documentation/blob/master/Installation/bitcoin_core.md
#
# You can watch the current status using the usual CLI commands:
# bitcoin-cli getinfo # as the user who runs bitcoind
# tail -f $HOME/.bitcoin/debug.log
#
# At the same time you can download - as the user who will run this - a copy of
#  recent counterparty DB to avoid having to reparse the blockchain.
#
# counterparty-server bootstrap # do this just once
#
# Note that the boostrap command extracts the DB to default location:
# /home/$USER/.local/share/counterparty/
# Move the *.db file to elsewhere if user's $HOME doesn't begin with "/home/":
# mv /home/$USER/.local/share/counterparty/ /external/$USER/.local/share/...
#
# After this is finished you can start counterparty-server. It will seem
#  unresponsive for a long time - that's because it has to rescan its own DB
# If bitcoind hasn't caught up yet, it may err catching up with it:
# "First block in database is not block XXXXX"
# This means you need to wait until Bitcoin Core has downloaded more blocks.
# If it stops like that, just re-run it after Bitcoin Core is pasat block XXXXX
# You can counterparty-server with CTRL+C if you need to.
#
# counterparty-server start
#
# After counterparty-server has caught up with the, counterparty-client can work.
#
# counterparty-client getinfo
