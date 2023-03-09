import { ethers, upgrades } from "hardhat";

async function deployProjectFactory() {
  const [owner, manager, user1, user2] = await ethers.getSigners();

  const LinearVestingProjectRemovableUpgradeable = await ethers.getContractFactory("LinearVestingProjectRemovableUpgradeable");
  const LinearVestingProjectFactoryUpgradeable = await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");
  const ERC20 = await ethers.getContractFactory("ERC20Mock");

  const projectBase = await LinearVestingProjectRemovableUpgradeable.connect(owner).deploy();

  const projectFactory = await upgrades.deployProxy(LinearVestingProjectFactoryUpgradeable, [projectBase.address], { initializer: '__LinearVestingProjectFactory_initialize' });
  await projectFactory.deployed()

  const erc20 = await ERC20.deploy();
  await erc20.deployed();

  const tx = await projectFactory.createProject(erc20.address)
  await tx.wait(1)

  const address = await projectFactory.getProjectAddress(0)

  const project = LinearVestingProjectRemovableUpgradeable.attach(address)

  return { projectFactory, projectBase, project, erc20, owner, manager, user1, user2 };
}

export { deployProjectFactory };
