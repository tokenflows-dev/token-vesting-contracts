import {ethers, upgrades} from "hardhat";

require('dotenv').config()

async function main() {
    const UserRegistry = await ethers.getContractFactory("UserRegistry");

    const userRegistry = await upgrades.deployProxy(UserRegistry, { initializer: '__UserRegistry_initialize' });
    await userRegistry.deployed()

    console.log("User registry deployed to:", userRegistry.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
