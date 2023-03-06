import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';

dotenv.config();

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    goerli: {
      network: 5,
      url: process.env.RPC_URL,
      accounts: process.env.DEPLOYER_KEY ? [process.env.DEPLOYER_KEY] : []
    },
    mainnet: {
      network: 1,
      url: process.env.RPC_URL,
      accounts: process.env.DEPLOYER_KEY ? [process.env.DEPLOYER_KEY] : []
    }
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  gasReporter: {
    coinmarketcap: 'b5aa6c8e-e54a-4291-b372-6afac549d9fc',
    currency: 'USD',
    enabled: true,
    token: 'ETH'
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY ?? "",
      goerli: process.env.ETHERSCAN_API_KEY ?? ""
    }
  }
};

export default config;
