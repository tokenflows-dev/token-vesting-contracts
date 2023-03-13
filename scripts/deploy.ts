import {ethers, upgrades} from "hardhat";

require('dotenv').config()

async function main() {

    const LinearVestingProjectUpgradeable = await ethers.getContractFactory("LinearVestingProjectUpgradeable");
    const LinearVestingProjectFactoryUpgradeable = await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");

    const projectBase = await LinearVestingProjectUpgradeable.deploy();

    console.log("Vesting Project for beacon proxy deployed to:", projectBase.address);

    const projectFactory = await upgrades.deployProxy(LinearVestingProjectFactoryUpgradeable, [projectBase.address], {initializer: '__LinearVestingProjectFactory_initialize'});
    await projectFactory.deployed()

    console.log("Vesting Project Factory deployed to:", projectFactory.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
