

const hre = require("hardhat");

async function main() {
  const Ballot = await hre.ethers.getContractFactory("Ballot");
  const ballot = await Ballot.deploy();

  await ballot.deployed();

  console.log(
    `Ballot deployed to ${ballot.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});