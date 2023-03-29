import { ethers } from "hardhat";

const METADATA_URL = 'ipfs://QmUJEd7A6CnByhqrWK6KnjQYZa1CJ6Kdw1ZoQrLaHkF7uc';

async function main() {

    const UserRegistry = await ethers.getContractFactory("UserRegistry");

    const userRegistry = UserRegistry.attach(process.env.EXISTING_USER_REGISTRY)

    const tx = await userRegistry.updateMetadataUrl(process.env.DEPLOYER_ADDRESS, METADATA_URL)

    await tx.wait(1)

    console.log('User metadata has been updated for address: ', process.env.DEPLOYER_ADDRESS, ' with the value: ', METADATA_URL)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
