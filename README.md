# Full Working Example of Configuration Files for Counterparty Server and Client (with Bitcoin Core with addrindex patch)

This is a working example of Bitcoin Core and counterparty-cli configuration files **for testnet**. 
To modify for mainnet, remove `testnet=1` from files and commands and come up with a better username/password combination.

Tested with:

* Bitcoin Core 0.10.2 (0.11 should work the same)
* counterparty-cli 1.1.1 and counterparty-lib 9.51.3

```
$ counterparty-client --version
counterparty-client v1.1.1; counterparty-lib v9.51.3
$ bitcoin-0.10.2/bin/bitcoin-cli --version
Bitcoin Core RPC client version addrindex-0.10.2
```

## Download and Install

Follow official documentation:

* Bitcoin Core with addrindex patch: https://github.com/CounterpartyXCP/Documentation/blob/master/Installation/bitcoin_core.md
* counterparty-cli (server + client; counterparty-lib installs as dependency): https://github.com/CounterpartyXCP/Documentation/blob/master/CLI/counterparty-cli.md

counterparty-cli can be installed with pip3 (`sudo pip3 install counterparty-cli`) or from source. I used the latter approach because currently the pip approach does not pre-create configuration directories and paths (see https://github.com/CounterpartyXCP/counterparty-cli/issues/60).
 
 ```
 wget https://github.com/CounterpartyXCP/counterparty-lib/archive/master.zip
 mv master.zip lib.zip
 unzip lib.zip; cd counterparty-lib-master
 sudo python3 setup.py install
 cd ..
 wget https://github.com/CounterpartyXCP/counterparty-cli/archive/master.zip
 mv master.zip cli.zip
 unzip cli.zip; cd counterparty-cli-master
 sudo python3 setup.py install

 ```

## Configuration Files and Their Locations

### Bitcoin Core 0.10.2 (and soon 0.11)

Default location: `/home/USER/.bitcoin/bitcoin.conf` (or optionally `bitcoin.testnet.conf`)

```
$ cd $HOME; cat .bitcoin/bitcoin.testnet.conf
rpcuser = bitcoin-rpc
rpcpassword = PaSS
txindex = 1
server = 1
addrindex = 1
rpcthreads = 1000
rpctimeout = 300
minrelaytxfee = 0.00005
limitfreerelay = 0
testnet = 1
```

If you only run Bitcoin Core on testnet (i.e. you have no `bitcoin.conf`), consider renaming the configuration file to `bitcoin.conf` - it's probably easier that way. 

### Counterparty Client and Server (counterparty-cli)

I made my configuration files to require `sudo` because they contain wallet password(s). For testnet this doesn't necessarily has to be done this way. 

Although these are used on testnet I deliberately did not name the files like `server.testnet.conf` because then I would have to pass the config file name to `counterparty-client`.  Because I run testnet most of the time, this makes it easier to use the CLI.

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

I assume your user name is `USER`. Change as required.

`$ sudo bitcoin-0.10.2/bin/bitcoind --conf=/home/USER/.bitcoin/bitcoin.testnet.conf`

NOTES: 
1) For additional security it's good to require the user to be a sudoer.
2) I downloaded statically compiled binaries from BTCDrak and extracted the archive in my home directory: 
```
$ cd $HOME; dir bitcoin-0.10.2/bin/
bitcoin-cli  bitcoind  bitcoin-qt  bitcoin-tx  test_bitcoin  test_bitcoin-qt
```

### Counterparty Server

`$ sudo counterparty-server start`

No additional arguments are required if `server.conf` is in its default location.

## Test Clients

### Bitcoin Client

If your config file has a non-default name, use `--conf` to tell bitcoin-cli where to find it.

```
$ bitcoin-0.10.2/bin/bitcoin-cli --conf=/home/USER/.bitcoin/bitcoin.testnet.conf getinfo
{
    "version" : 100200,
    "protocolversion" : 70002,
    "walletversion" : 60000,
    "balance" : 0.00000000,
    "blocks" : 800,
    "timeoffset" : 0,
    "connections" : 8,
    "proxy" : "",
    "difficulty" : 1.00000000,
    "testnet" : true,
    "keypoololdest" : 1438597749,
    "keypoolsize" : 101,
    "paytxfee" : 0.00000000,
    "relayfee" : 0.00005000,
    "errors" : ""
}
```

### Counterparty Client

No additional arguments are required if `client.conf` is in its default location. Otherwise use `--config-file=` to tell the client where to find it. Use `counterparty-client --help` to see other options.

```
$ sudo counterparty-client getinfo
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

Above error means the local instance of bitcoind is running behind, but the client is working fine.

## Counterparty Cheat Sheet

I put together a cheat sheet that applies to counterparty-lib 9.51.3 and Bitcoin Core 0.10.2 (as well as 0.11). It cointains above information for Ubuntu 14.04 and Windows 7 x64:

https://www.dropbox.com/s/7mx7uphhf12fmga/counterparty-lib-cheatsheet_9.51.3.pdf
