import hre from "hardhat";
import { parseUnits } from "viem";

const tokens = [
  { name: 'Wrapped Bitcoin', symbol: "WBTC", decimals: 8 },
  { name: 'Wrapped Ether', symbol: "WETH", decimals: 18 },
  { name: 'Wrapped BNB', symbol: "WBNB", decimals: 18 },
  { name: 'Dai Stablecoin', symbol: "DAI", decimals: 18 },
  { name: 'Tether', symbol: "USDT", decimals: 6 },
  { name: 'USDCoin', symbol: "USDC", decimals: 6 },
  { name: 'Arbitrum', symbol: 'ARB', decimals: 18 },
  { name: 'Wrapped Matic', symbol: 'WMATIC', decimals: 18 },
  { name: 'Optimism', symbol: 'OP', decimals: 18 },
  { name: 'Mantle', symbol: 'MNT', decimals: 18 },
  { name: 'AAVE', symbol: 'AAVE', decimals: 18 },
  { name: 'Staked Ether', symbol: 'stETH', decimals: 18 },
  { name: 'Rocket Pool Ether', symbol: 'rETH', decimals: 18 },
  { name: 'Lido', symbol: 'LDO', decimals: 18 },
  { name: 'Rocket Pool', symbol: 'RPL', decimals: 18 },
];


async function main() {
  const deployments: { [name: string]: string } = {};
  const publicClient = await hre.viem.getPublicClient();
  const [deployer] = await hre.viem.getWalletClients();
  for (const { name, symbol, decimals } of tokens) {
    const deployment = await hre.viem.deployContract('Token', [name, symbol, decimals]);
    const hash = await deployment.write.mint([deployer.account.address, parseUnits('1000000', decimals)]);
    await publicClient.waitForTransactionReceipt({ hash });
    deployments[symbol] = deployment.address
  }

  console.log(deployments)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
