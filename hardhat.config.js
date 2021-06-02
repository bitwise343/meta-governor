require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require('./scripts/hardhat.tasks.js')


const kovanAccounts = {
  mnemonic: process.env.KOVAN_TEST_MNEMONIC,
  path: "m/44'/60'/0'/0",
  initialIndex: 0,
  count: 10,
};

const mainnetUrl = process.env.ETH_MAINNET_RPC;
const kovanUrl = process.env.ETH_KOVAN_RPC;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // forking: {
      //   url: mainnetUrl
      // },
      loggingEnabled: true
    },
    kovan: {
        accounts: kovanAccounts,
        url: kovanUrl,
    }
  },
  paths: {
    sources: "./contracts",
    cache: "./build/cache",
    artifacts: "./build/artifacts",
    tests: "./test",
  },
  solidity: {
    compilers: [
      { version: "0.8.0" },
    ]
  }
};
