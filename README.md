# Full Working Example of Configuration Files for Counterparty Server and Client (with Bitcoin Core with addrindex patch)

This is a working example of Bitcoin Core and counterparty-cli configuration files **for testnet**. 
To modify for mainnet, remove `testnet=1` from files and commands and come up with a better username/password combination.

Tested with:

* Ubuntu 16.04 and Ubuntu 14.04 x86
* Bitcoin Core 0.12 (https://github.com/btcdrak/bitcoin/releases/tag/v0.12.0-addrindex)
* counterparty-cli 1.1.2 and counterparty-lib 9.55

```
$ counterparty-client --version
counterparty-client v1.1.1; counterparty-lib v9.54
$ bitcoin-0.12.0/bin/bitcoin-cli --version
Bitcoin Core RPC client version addrindex-0.12.0
```

## Download and Install

Follow the official documentation:

* Install Bitcoin Core 0.12 with addrindex patch: https://github.com/CounterpartyXCP/Documentation/blob/master/Installation/bitcoin_core.md 
* Install counterparty-cli (server + client package; `counterparty-lib` installs as their dependency)
* counterparty-cli can be installed with pip3 (`sudo pip3 install counterparty-cli`) or from the source. I used the latter approach here, but you may need to first install python3-dev and then upgrade Python 3 `requests` package to be able to do this. If you're having problems with building from source using the approach below, try `pip3 install --no-use-wheel counterparty-lib` and then install counterparty-cli. You must fix any dependency conflicts that arise when installing modules from requirements.txt.
 
 ```
 wget https://github.com/CounterpartyXCP/counterparty-lib/archive/master.zip
 mv master.zip lib.zip
 unzip lib.zip; cd counterparty-lib-master
 sudo pip3 install -r requirements.txt
 sudo python3 setup.py install
 cd ..
 wget https://github.com/CounterpartyXCP/counterparty-cli/archive/master.zip
 mv master.zip cli.zip
 unzip cli.zip; cd counterparty-cli-master
 sudo pip3 install -r requirements.txt
 sudo python3 setup.py install
 ```

## Configuration Files and Their Locations

### Bitcoin Core 0.12.0

Default location: `/home/USER/.bitcoin/bitcoin.conf` (if you have a separate config file for testnet, consider using `bitcoin.testnet.conf`; replace `USER` with your user name).

```
$ cd $HOME; cat .bitcoin/bitcoin.testnet.conf
rpcuser = bitcoin-rpc
rpcpassword = PaSS
txindex = 1
server = 1
addrindex = 1
# rpcthreads = 1000       # Counterparty Federated Node still has this, but it's not necessary in my opinion
rpctimeout = 300
testnet = 1
# maxmempool = 32         # Optional "RAM exhaustion protection" (the default is 300 MB) for small systems
# minrelaytxfee = 0.00005 # Now rather unnecessary since Bitcoin Core 0.12 manages this automatically
# limitfreerelay = 0      # Now rather unnecessary since Bitcoin Core 0.12 manages this automatically
```

If you only run Bitcoin Core on testnet (i.e. you have no need for `bitcoin.conf`), consider renaming the configuration file to `bitcoin.conf` - it's probably easier that way because then you can run Bitcoin Core without `-testnet`. 

### Counterparty Client and Server (counterparty-cli)

Although these are used on testnet I deliberately did not name the files like `server.testnet.conf` because then I would have to pass the config file path and name to `counterparty-client` every time I run any counterparty-cli command on testnet. Because I run testnet most of time, testnet config files named like this make it easier for me to use the CLI on testnet.

#### Server

Default location: `/home/USER/.config/counterparty/server.conf`

```
$ cd $HOME; sudo cat .config/counterparty/server.conf
[Default]
backend-name = addrindex
backend-user = bitcoin-rpc
backend-password = PaSS
rpc-host = localhost
rpc-user = counterparty-rpc
rpc-password = WoRD
testnet = 1
```

#### Client

Default location: `/home/USER/.config/counterparty/client.conf`

```
cd $HOME; sudo cat .config/counterparty/client.conf
[Default]
wallet-user = bitcoin-rpc
wallet-password = PaSS
wallet-connect = localhost
wallet-name = bitcoincore
counterparty-rpc-user = counterparty-rpc
counterparty-rpc-password = WoRD
testnet = 1
```

## Start Services

### Bitcoin Core

I assume your user name is `USER`. Change as required. If your config file is $HOME/.bitcoin/bitcoin.conf, it's enough to run `bitcoind` without any options.

`$ bitcoin-0.12.0/bin/bitcoind --conf=/home/USER/.bitcoin/bitcoin.testnet.conf`

NOTES: 
1) I downloaded statically compiled binaries from BTCDrak and extracted the archive in my home directory, that's why my path looks like it does:

```
$ cd $HOME; dir bitcoin-0.12.0/bin/
bitcoin-cli  bitcoind  bitcoin-qt  bitcoin-tx  test_bitcoin  test_bitcoin-qt
```
2) If you built from source or installed someone's binaries or modified your `$PATH`, you wouldn't use full paths to Bitcoin Core binaries.

### Counterparty Server

`$ sudo counterparty-server start`

No additional arguments are required if `server.conf` is in its default location. If your config file is `server.testnet.conf`, then `--config-file <FULL-PATH-TO-COUNTERPARTY-SERVER.CONF>` have to be specified when starting.

## Test Clients

### Bitcoin Client

If your config file has a non-default name, use `--conf` to tell bitcoin-cli where to find it.

```
$ bitcoin-0.12.0/bin/bitcoin-cli -conf=/home/USER/.bitcoin/bitcoin.testnet.conf getinfo
{
  "version": 120000,
  "protocolversion": 70012,
  "walletversion": 60000,
  "balance": 0.00000000,
  "blocks": 403306,
  "timeoffset": -1,
  "connections": 8,
  "proxy": "",
  "difficulty": 165496835118.2263,
  "testnet": false,
  "keypoololdest": 1456568065,
  "keypoolsize": 101,
  "paytxfee": 0.00000000,
  "relayfee": 0.00001000,
  "errors": "WARNING: check your network connection, 5 blocks received in the last 4 hours (24 expected)"
}
```

### Counterparty Client

No additional arguments are required if `client.conf` is in its default location. Otherwise use `--config-file=` and/or `--testnet` to tell the client where to find it and to use testnet if necessary. Use `counterparty-client --help` to see other options.

```
$ counterparty-client getinfo
[INFO] Running v1.1.1 of counterparty-client.
Unhandled Exception
Traceback (most recent call last):
  File "/usr/local/bin/counterparty-client", line 9, in <module>
    load_entry_point('counterparty-cli==1.1.1', 'console_scripts', 'counterparty-client')()
  File "/usr/local/lib/python3.4/dist-packages/counterpartycli/__init__.py", line 12, in client_main
    client.main()
  File "/usr/local/lib/python3.4/dist-packages/counterpartycli/client.py", line 257, in main
    view = console.get_view(args.action, args)
  File "/usr/local/lib/python3.4/dist-packages/counterpartycli/console.py", line 16, in get_view
    return util.api('get_running_info')
  File "/usr/local/lib/python3.4/dist-packages/counterpartycli/util.py", line 92, in api
    return rpc(config.COUNTERPARTY_RPC, method, params=params, ssl_verify=config.COUNTERPARTY_RPC_SSL_VERIFY)
  File "/usr/local/lib/python3.4/dist-packages/counterpartycli/util.py", line 82, in rpc
    raise RPCError(str(response.status_code) + ' ' + response.reason + ' ' + response.text)
counterpartycli.util.RPCError: 503 SERVICE UNAVAILABLE {"code": -32000, "data": "Bitcoind is running about 26293 hours behind.", "message": "Server error"}
```

The error means the local instance of bitcoind is running behind, but otherwise client can clearly connect to counterparty-server and is working fine.

## Counterparty Cheat Sheet

I put together a cheat sheet that applies to counterparty-lib and Bitcoin Core 0.12.0 addrindex. It cointains a condensed (1 page) information for Ubuntu 14.04/16.04 and Windows 7/8/10 x64 and applies to counterparty-lib 9.55 and counterparty-cli 1.1.2:

* Current version: https://www.dropbox.com/s/4gyjnp32abb3elt/counterparty-lib-cheatsheet_9.55.pdf
