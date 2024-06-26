import {ethers} from "hardhat";

async function main() {

    const LinearVestingProjectFactoryUpgradeable = await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");

    const factory = LinearVestingProjectFactoryUpgradeable.attach(process.env.EXISTING_FACTORY)

    const tx = await factory.createProject(process.env.EXISTING_TOKEN, 'Dandelion Labs Test 2', 'https://ipfs.io/ipfs/QmRnuKeoL9qFShGYb8n2fHi9YADq9HxaBBy2og7mx7PbhE')

    await tx.wait(1)

    const projects = await factory.getProjects()

    const newProjectAddress = projects[projects.length - 1]

    console.log('Linear Vesting Project from factory', factory.address, ' created at ', newProjectAddress)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
