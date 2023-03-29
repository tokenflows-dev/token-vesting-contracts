import { ethers, upgrades } from "hardhat";

async function deployUserRegistry() {
  const [owner, user1, user2] = await ethers.getSigners();

  const UserRegistry = await ethers.getContractFactory("UserRegistry");

  const userRegistry = await upgrades.deployProxy(UserRegistry, { initializer: '__UserRegistry_initialize' });
  await userRegistry.deployed()

  return { userRegistry, owner, user1, user2 };
}

export { deployUserRegistry };
