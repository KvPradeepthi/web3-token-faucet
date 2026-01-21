async function main() {
  console.log("Starting deployment...");

  // Get the contract factory
  const SimpleToken = await ethers.getContractFactory("SimpleToken");
  const TokenFaucet = await ethers.getContractFactory("TokenFaucet");

  // Deploy SimpleToken
  console.log("Deploying SimpleToken...");
  const initialSupply = ethers.parseEther("1000000"); // 1 million tokens
  const token = await SimpleToken.deploy(initialSupply);
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log("SimpleToken deployed to:", tokenAddress);

  // Deploy TokenFaucet
  console.log("Deploying TokenFaucet...");
  const faucetAmount = ethers.parseEther("10"); // 10 tokens per claim
  const cooldownTime = 24 * 60 * 60; // 24 hours in seconds
  const faucet = await TokenFaucet.deploy(tokenAddress, faucetAmount, cooldownTime);
  await faucet.waitForDeployment();
  const faucetAddress = await faucet.getAddress();
  console.log("TokenFaucet deployed to:", faucetAddress);

  // Transfer tokens to faucet
  console.log("Transferring tokens to faucet...");
  const transferAmount = ethers.parseEther("100000"); // 100,000 tokens
  const tx = await token.transfer(faucetAddress, transferAmount);
  await tx.wait();
  console.log("Transferred", ethers.formatEther(transferAmount), "tokens to faucet");

  // Log deployment info
  console.log("\n--- Deployment Summary ---");
  console.log("SimpleToken Address:", tokenAddress);
  console.log("TokenFaucet Address:", faucetAddress);
  console.log("Faucet Amount per claim:", ethers.formatEther(faucetAmount), "tokens");
  console.log("Cooldown Time:", cooldownTime / 3600, "hours");
  console.log("Tokens in faucet:", ethers.formatEther(transferAmount), "tokens");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
