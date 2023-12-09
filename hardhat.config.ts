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
    'mumbai': {
      url: 'https://rpc.ankr.com/polygon_mumbai',
      chainId: 80001,
      accounts: [deployer]
    },
    'scroll-sepolia': {
      url: 'https://sepolia-rpc.scroll.io',
      chainId: 534351,
      accounts: [deployer]
    },
    celo: {
      url: 'https://alfajores-forno.celo-testnet.org',
      chainId: 44787,
      accounts: [deployer]
    },
    base: {
      url: 'https://goerli.base.org',
      chainId: 84531,
      accounts: [deployer]
    }
  }
};

export default config;
