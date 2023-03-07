import { ethers } from "hardhat";

async function main() {

    const LinearVestingProjectFactoryUpgradeable = await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");
    const LinearVestingProjectUpgradeable = await ethers.getContractFactory("LinearVestingProjectUpgradeable");
    const LinearVestingProjectBeacon = await ethers.getContractFactory("LinearVestingProjectBeacon");

    const factory = LinearVestingProjectFactoryUpgradeable.attach(process.env.EXISTING_FACTORY)

    const beacon = LinearVestingProjectBeacon.attach(await factory.getBeacon());

    const deployedUpgrade = await LinearVestingProjectUpgradeable.deploy();
    await deployedUpgrade.deployed()

    console.log('Linear Vesting Project deployed upgrade at', deployedUpgrade.address)

    await beacon.upgradeTo(deployedUpgrade.address);

    console.log('Linear Vesting Project from factory', factory.address, ' upgraded to', deployedUpgrade.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
