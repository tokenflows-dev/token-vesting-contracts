import {ethers} from "hardhat";

require('dotenv').config()

async function main() {
    const ERC20 = await ethers.getContractFactory("ERC20Mock");

    const erc20 = await ERC20.deploy();
    await erc20.deployed();

    console.log("ERC20 Mock token deployed to:", erc20.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
