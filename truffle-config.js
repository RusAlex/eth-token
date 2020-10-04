require('dotenv').config()
const HDWalletProvider = require('truffle-hdwallet-provider')

module.exports = {
    compilers: {
    solc: {
      version: "0.6.2", // A version or constraint - Ex. "^0.5.0"
      docker: true, // Use a version obtained through docker
      parser: "solcjs",  // Leverages solc-js purely for speedy parsing
    }
    },
      networks: {
    dev: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
          ropsten: {
      provider: () => new HDWalletProvider(
        process.env.MNEMONIC,
        process.env.ROPSTEN_URL),
      network_id: 3
    },
  }
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
};
