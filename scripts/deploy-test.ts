import { ethers, upgrades } from "hardhat";

require("dotenv").config();

async function main() {
  const LinearVestingProjectUpgradeable = await ethers.getContractFactory(
    "TestLinearVestingProjectUpgradeable"
  );
  const LinearVestingProjectFactoryUpgradeable =
    await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");
  const ERC20 = await ethers.getContractFactory("ERC20Mock");

  const erc20 = await ERC20.deploy();
  await erc20.deployed();

  console.log("ERC20 Mock token deployed to:", erc20.address);

  const projectBase = await LinearVestingProjectUpgradeable.deploy();

  console.log(
    "Vesting Project for beacon proxy deployed to:",
    projectBase.address
  );

  const projectFactory = await upgrades.deployProxy(
    LinearVestingProjectFactoryUpgradeable,
    [projectBase.address],
    { initializer: "__LinearVestingProjectFactory_initialize" }
  );
  await projectFactory.deployed();

  console.log("Vesting Project Factory deployed to:", projectFactory.address);

  let tx = await projectFactory.create(erc20.address);
  await tx.wait();

  const linearVestingProjectAddress = await projectFactory.getCollectionAddress(
    0
  );
  console.log(
    `New linear vesting project deployed to ${linearVestingProjectAddress}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
