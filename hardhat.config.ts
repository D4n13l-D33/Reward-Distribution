// import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import '@openzeppelin/hardhat-upgrades';

const {vars} = require("hardhat/config");

const ALCHEMY_MAINNET_API_KEY_URL = vars.get("ALCHEMY_MAINNET_API_KEY_URL");

const ALCHEMY_SEPOLIA_API_KEY_URL = vars.get("ALCHEMY_SEPOLIA_API_KEY_URL");

const ALCHEMY_MUMBAI_API_KEY_URL = vars.get("ALCHEMY_MUMBAI_API_KEY_URL");

const ACCOUNT_PRIVATE_KEY = vars.get("ACCOUNT_PRIVATE_KEY");

const API_KEY = vars.get("API_KEY");

module.exports = {
  solidity: "0.8.24",
  networks: {
    hardhat: {
      
      forking: {
        url: ALCHEMY_MAINNET_API_KEY_URL,
      }
    },
    sepolia: {
      url: ALCHEMY_SEPOLIA_API_KEY_URL,
      accounts: [ACCOUNT_PRIVATE_KEY],
    },
    mumbai: {
      url: ALCHEMY_MUMBAI_API_KEY_URL,
      accounts: [ACCOUNT_PRIVATE_KEY],
    }
    
    
  },

  etherscan: {
    apiKey: {
      sepolia: API_KEY
    }
  },
  
  lockGasLimit: 200000000000,
  gasPrice: 10000000000,
};