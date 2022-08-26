---
title: "Ethereum Development"
date: 2018-06-07T14:01:30+08:00
draft: false
category: "blockchain"
tags: [ "ethereum", "evm", "blockchain" ]
---
## How to generate etheruem key pair
[key generate](https://kobl.one/blog/create-full-ethereum-keypair-and-address/#generating-the-ec-private-key)
## Ethereum Application Development
![](https://i.imgur.com/FHLFkSe.png)

## Enviriment
Ubuntu 16.04LTS server 
Geth 1.83 stable
Nodejs 8.11.1
web3.js 0.20.1

## eth-netstats
It look like there're two part one is netstats(監控端),and another one is client(客戶端)
https://kairen.github.io/2017/05/26/blockchain/geth-monitoring/

## Web3.js
go-ethereum和parity支援web3.js
:::warning
如果你要透過套件安裝web3.js 的library，要注意geth內的web3版本(web3.version)，之前使用1.X.X版本有問題，目前改為0.2X.X版
:::

可以[由此](https://www.versioneye.com/nodejs/web3/0.20.1)查看web3.js版本0.20.1
[API v0.2X.X](https://github.com/ethereum/wiki/wiki/JavaScript-API)

- Upadate 2018/6/4 : web3.js 1.0.0 is more efficient
### accounts.sign v.s eth.sign 
There's a little bit diff between accounts.sign & eth.sign, you can't encode by one of the and decode by another one. That's because they are encode with diff parameter.
[Web3.js : eth.sign() vs eth.accounts.sign() — producing different signatures?](https://ethereum.stackexchange.com/questions/35425/web3-js-eth-sign-vs-eth-accounts-sign-producing-different-signatures)

Old way : [eth.sign](https://medium.com/taipei-ethereum-meetup/用ecrecover來驗簽名-694fa8ae3638)
New way : [accounts.sign](https://web3js.readthedocs.io/en/1.0/web3-eth-accounts.html#sign)(more ez to use it can recover without contract)
## Geth
### how to add account into geth?
Copy keyfile(File name begin with UTC...) into floder which call keystore in the local of geth.

What is an Ethereum keystore file?
[Keystore file](https://medium.com/@julien.m./what-is-an-ethereum-keystore-file-86c8c5917b97)
### Link multi node together
https://github.com/OSE-Lab/learning-blockchain/blob/master/ethereum/docker-geth-multi-nodes.md
## Smart Contract-solidity
### how to return whole struct?
You can not return struct cuz the length of interface, but there is a solution. You can return them with chunks sperate them to the peices like example downblow.

```solidity
pragma solidity ^0.4.0;
contract Cloud2{
    struct Metadata{
        string fileName;
        address addr;
        bytes16 hashId;
        uint timestamp;
    }
    mapping(bytes16 => Metadata) public fileInfos;
    function setFile(string fileName, address addr,bytes16 hashId, uint timestamp) public returns(bytes16){
        fileInfos[hashId]=Metadata(fileName,addr,hashId,timestamp);
        return hashId;
    }
    function getFileWithHash(bytes16 hashId) public constant returns(string, address, uint) {
        return (fileInfos[hashId].fileName, fileInfos[hashId].addr, fileInfos[hashId].timestamp);
    }
}
```

### How to call the method?

There are few way to call. If you need to change the value in contract you should pay the gas(send the trancation to call)

**Contract Method**
```solidity
// Automatically determines the use of call or sendTransaction based on the method type
myContractInstance.myMethod(param1 [, param2, ...] [, transactionObject] [, defaultBlock] [, callback]);

// Explicitly calling this method
myContractInstance.myMethod.call(param1 [, param2, ...] [, transactionObject] [, defaultBlock] [, callback]);

// Explicitly sending a transaction to this method
myContractInstance.myMethod.sendTransaction(param1 [, param2, ...] [, transactionObject] [, callback]);

// Get the call data, so you can call the contract through some other means
// var myCallData = myContractInstance.myMethod.request(param1 [, param2, ...]);
var myCallData = myContractInstance.myMethod.getData(param1 [, param2, ...]);
// myCallData = '0x45ff3ff6000000000004545345345345..'
```
[web3.js 0.2x.x](https://github.com/ethereum/wiki/wiki/JavaScript-API#contract-methods)