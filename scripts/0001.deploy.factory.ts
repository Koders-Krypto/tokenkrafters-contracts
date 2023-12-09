import hre from "hardhat";

async function main() {
  const swapRouter = process.env.SWAP_ROUTER_ADDRESS;
  if (!swapRouter) throw Error('Swap router not defined');
  const tokenKrafterFactory = await hre.viem.deployContract('TokenKrafterFactory', [swapRouter as `0x${string}`]);
  console.log({ tokenKrafterFactory: tokenKrafterFactory.address });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
