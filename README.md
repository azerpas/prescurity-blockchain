# prescurity-blockchain

## Stack
### Code
- [Solidity](http://solidity.readthedocs.io)
### Blockchain emulator
- [Ganache](https://www.trufflesuite.com/ganache)
### Smartcontract helper
- [Truffle](https://www.trufflesuite.com/truffle)
### Wallet
- [Metamask](https://metamask.io/)

## How to use

- Install [requirements below](#requirements)
- `git pull https://github.com/azerpas/prescurity-blockchain.git`
- `cd prescurity-blockchain`
- `cp .env.example .env.local`
- Set the `OWNER_ADDRESS` to the Ganache address you want the Owner to have
- Import this account to MetaMask
- `npm run update`
- Copy the `build/contracts/*` contracts to the front-end repository `src/contracts/`
- [Setup the front-end project](https://github.com/azerpas/prescurity-dashboard#how-to-use) and use a compatible browser (Firefox, Brave, Chrome) to access http://localhost:3000/

## Requirements
### Ganache
- Init Ganache by creating a "New Workspace"
![image](https://user-images.githubusercontent.com/19282069/124558244-ac975380-de3a-11eb-83f8-9e1d6b51eb10.png)
- Then "Add Project"
![image](https://user-images.githubusercontent.com/19282069/124558297-bd47c980-de3a-11eb-90aa-201eb66e300c.png)
- Select `truffle-config.js` inside the folder cloned
- Set the "Account & Keys" balance to 300 and "Number of accounts" 20
- Save the workspace and note the RPC URL address
### MetaMask
- Create a wallet and **save your private key securely**
- Click on the network dropdown      
![image](https://user-images.githubusercontent.com/19282069/124569046-e0c44180-de45-11eb-8810-9f22e789ddca.png)
- Choose custom RPC
- Enter the URL from Ganache and fill the other fields
#### You can now import accounts from Ganache by importing their private key to MetaMask
![image](https://user-images.githubusercontent.com/19282069/124569418-3862ad00-de46-11eb-8041-19f0ac4b4f55.png)
![image](https://user-images.githubusercontent.com/19282069/124569653-6c3dd280-de46-11eb-81c8-4a35d59c5f82.png)
![image](https://user-images.githubusercontent.com/19282069/124569667-6f38c300-de46-11eb-871d-9077255deddb.png)
