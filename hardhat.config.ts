import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import 'dotenv/config'

const deployer = process.env.PRIVATE_KEY || '';

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    'arb-goerli': {
      url: 'https://arbitrum-goerli.publicnode.com',
      chainId: 421613,
      accounts: [deployer]
    },
  }
};

export default config;
