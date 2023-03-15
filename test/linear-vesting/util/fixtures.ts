import { ethers, upgrades } from "hardhat";
import {getLastBlockTimestamp} from "./time";
import {BigNumber} from "ethers";

async function deployProjectFactory() {
  const [owner, manager, user1, user2] = await ethers.getSigners();

  const LinearVestingProjectRemovableUpgradeable = await ethers.getContractFactory("LinearVestingProjectRemovableUpgradeable");
  const LinearVestingProjectFactoryUpgradeable = await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");

  const projectBase = await LinearVestingProjectRemovableUpgradeable.connect(owner).deploy();

  const projectFactory = await upgrades.deployProxy(LinearVestingProjectFactoryUpgradeable, [projectBase.address], { initializer: '__LinearVestingProjectFactory_initialize' });
  await projectFactory.deployed()

  const ERC20 = await ethers.getContractFactory("ERC20Mock");

  const erc20 = await ERC20.deploy();
  await erc20.deployed();

  return { projectFactory, projectBase, erc20, owner, manager, user1, user2 };
}


async function deployProjectFactoryWithProject() {
  const { projectFactory, projectBase, owner, erc20, manager, user1, user2 } = await deployProjectFactory()

  const LinearVestingProjectRemovableUpgradeable = await ethers.getContractFactory("LinearVestingProjectRemovableUpgradeable");


  const tx = await projectFactory.createProject(erc20.address, 'Project Example')
  await tx.wait(1)

  const address = await projectFactory.getProjectAddress(0)

  const project = LinearVestingProjectRemovableUpgradeable.attach(address)

  return { projectFactory, projectBase, project, erc20, owner, manager, user1, user2 };
}

async function deployProjectFactoryWithProjectAndPool() {
  const { projectFactory, projectBase, owner, project, erc20, manager, user1, user2 } = await deployProjectFactoryWithProject()

  const poolVestingTime = 100
  const amount = BigNumber.from("100000000000000000000")

  const allowTx = await erc20.increaseAllowance(project.address, amount)
  await allowTx.wait()

  const currentTimeStamp = await getLastBlockTimestamp();

  let startingPeriodTime = currentTimeStamp + 100

  let tx = await project.createPoolWithGrants('Pool 1', startingPeriodTime, poolVestingTime, [user1.address], [amount]);
  await tx.wait()

  return { projectFactory, projectBase, project, erc20, owner, manager, user1, user2, poolVestingTime, amount, startingPeriodTime };
}

export { deployProjectFactory, deployProjectFactoryWithProject, deployProjectFactoryWithProjectAndPool };
