import { ethers, upgrades } from "hardhat";

async function main() {

    const LinearVestingProjectFactoryUpgradeable = await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");
    const upgraded = await upgrades.upgradeProxy(process.env.EXISTING_FACTORY, LinearVestingProjectFactoryUpgradeable);

    console.log('Linear Vesting Project factory', process.env.EXISTING_FACTORY, ' upgraded to', upgraded.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
