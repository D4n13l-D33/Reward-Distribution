import { ethers } from "hardhat";

async function main() {

  const NFTAddress = "0x32AA24E69E41b66EF4cc74dD5281Be42c75D3B9d";
  const TokenAddress = "0xd64a71d6722cc84324fe95b4bb79bf631aa7d15b";
  const maxNoEntries = 2;
  const subscriptionId = 9779;
  const noOfWinners = 4;
  const totalRewards = 100000;
  
  const rewardDistribution = await ethers.deployContract("RewardDistribution", [NFTAddress, TokenAddress, totalRewards, maxNoEntries, subscriptionId, noOfWinners]);

  await rewardDistribution.waitForDeployment();

  console.log(
    `Reward Distribution Contract deployed to ${rewardDistribution.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
