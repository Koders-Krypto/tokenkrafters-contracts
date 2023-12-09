import hre from "hardhat";

async function main() {
  const swapRouter = process.env.SWAP_ROUTER_ADDRESS as `0x${string}`;
  const rewardToken = process.env.REWARD_ADDRESS as `0x${string}`;
  const linkToken = process.env.LINK_ADDRESS as `0x${string}`;
  const wrapper = process.env.WRAPPER_ADDRESS as `0x${string}`;
  if (!swapRouter) throw Error('Swap router not defined');
  if (!rewardToken) throw Error('Reward token not defined');
  if (!linkToken) throw Error('LINK token not defined');
  if (!wrapper) throw Error('Wrapper not defined');
  const tokenKrafterRaffle = await hre.viem.deployContract('TokenKrafterRaffle', [swapRouter, rewardToken, linkToken, wrapper]);
  console.log({ tokenKrafterRaffle: tokenKrafterRaffle.address });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
