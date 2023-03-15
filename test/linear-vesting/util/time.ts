import {ethers} from 'hardhat';
import { time } from "@nomicfoundation/hardhat-network-helpers";

async function getLastBlockTimestamp(): Promise<number> {
    const blockNumber = await ethers.provider.getBlockNumber();
    return (await ethers.provider.getBlock(blockNumber)).timestamp;
}

async function setNextBlockTimestamp(timestamp: number) {
    await time.setNextBlockTimestamp(timestamp);
}

export { getLastBlockTimestamp, setNextBlockTimestamp };