#!/bin/bash

# OS: Ubuntu 16.04 (64-bit)
# Author: unsystemizer (on Github)
# Date: October 23, 2016
#
# This simple script installs Counterparty-lib, counterparty-client and
#  overwrites default configuration files for Counterparty and Bitcoin.
# Configuration files use default locations.

# NOTE: for Mainnet uses you MUST change the passwords!!!

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
echo ""
sleep 6

# If you already have a copy of blockchain somewhere on the network
#  just change "rpc-host"

# Server
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

# Client
cat << EOF > $HOME/.config/counterparty/client.conf
[Default]
wallet-name = bitcoincore # Only "Bitcoin Core addrindex" is suported
# Where's my bitcoin?
wallet-connect = localhost
wallet-user = bitcoin-rpc
wallet-password = PaSS
# Where's my counterparty-server?
counterparty-rpc-connect = localhost
# How do I connect to its RPC service?
counterparty-rpc-user = counterparty-rpc
counterparty-rpc-password = WoRD
# Should this run on testnet?
testnet = 0
EOF

# Bitcoin Core addrindex
# Download from https://github.com/btcdrak/bitcoin/releases
cat << EOF > $HOME/.bitcoin/bitcoin.conf
# My Bitcoin RPC credentials
rpcuser = bitcoin-rpc
rpcpassword = PaSS
# I need these 2 indexes (and can't use a pruned blockchain)
txindex = 1
addrindex = 1
# Is this Bitcoin Core going to serve RPC clients? Of course
server = 1
# Should it run in background (1=yes, 0=no)
daemon = 1 # With this you need to stop bitcoind with "bitcoin-cli stop"
rpctimeout = 300
# Should this run on testnet?
testnet = 0
# maxmempool = 32         # Optional "RAM exhaustion protection" (the default is 300 MB) for small systems
# minrelaytxfee = 0.00005 # Now rather unnecessary since Bitcoin Core 0.12 manages this automatically
# limitfreerelay = 0      # Now rather unnecessary since Bitcoin Core 0.12 manages this automatically
EOF

# These configuration files should not be readable by other users
# Ownership should belong to the user who will run these services
# - do this by yourself
# 
chmod 700 $HOME/.config/counterparty/server.conf
chmod 700 $HOME/.config/counterparty/client.conf
chmod 700 $HOME/.bitcoin/bitcoin.conf

echo "You may want to recursively change the ownership of "
echo ".bitcoin and .config/counterparty if the owner is not"
echo "supposed to be " `whoami`
echo ""
echo "Please note these config files are for mainnet (testnet=1 to use testnet)"
echo "Change both the usernames and passwords as soon as you get the services to work!"

# Now you can start services **AS THE USER WHO OWNS THIS DATA** or sudo-er.
# 1) If you created the xcp account to run, you need to "su - xcp" before
#    you do this. If using your own, just run the commands. If you owned
#    these files by the root account, you would have to use "sudo" to run.
# 2) If you run bitcoind with "daemon = 1", it goes into background and
#    to stop it you need to run "bitcoin-cli stop" or
#    "bitcoin-cli -conf $HOME/.bitcoin/bitcoin.conf stop" (as the owning
#    user). If you chown-ed the directory by root, add sudo before the command.
# 3) If you changed testnet to 1, add '-testnet' in front of each bitcoin command
#    and '--testnet' in front of each counterparty-client and counterparty-server command
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
# If it stops like that, just re-run it after Bitcoin Core has downloaded block XXXXX
# You can stop counterparty-server with CTRL+C if you need to.
#
# counterparty-server start
#
# After counterparty-server has caught up with the, counterparty-client can work.
#
# counterparty-client getinfo
