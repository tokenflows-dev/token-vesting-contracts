import { ethers, upgrades } from "hardhat";

async function deployProjectFactory() {
  const [owner, manager, user1, user2] = await ethers.getSigners();

  const LinearVestingProjectUpgradeable = await ethers.getContractFactory("LinearVestingProjectUpgradeable");
  const LinearVestingProjectFactoryUpgradeable = await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");
  const ERC20 = await ethers.getContractFactory("ERC20Mock");

  const projectBase = await LinearVestingProjectUpgradeable.connect(owner).deploy();

  const projectFactory = await upgrades.deployProxy(LinearVestingProjectFactoryUpgradeable, [projectBase.address], { initializer: '__LinearVestingProjectFactory_initialize' });
  await projectFactory.deployed()

  const erc20 = await ERC20.deploy();
  await erc20.deployed();

  return { projectFactory, projectBase, erc20, owner, manager, user1, user2 };
}

export { deployProjectFactory };
