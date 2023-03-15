import {loadFixture} from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import {deployProjectFactoryWithProject} from "./util/fixtures";
import {BigNumber} from "ethers";
import {getLastBlockTimestamp} from "./util/time";

describe("Pools creation", function () {

  const poolVestingTime = 100
  const poolName = 'Pool 1'

  let amount, projectFactory, erc20, project, owner, manager, user1, user2;

  beforeEach(async () => {
    ({projectFactory, erc20, project, owner, manager, user1, user2 } = await loadFixture(deployProjectFactoryWithProject));
  });

  it("create pool with grants should work for manager", async function () {
    const poolVestingTime = 100
    const amount = BigNumber.from("100000000000000000000")
    const poolName = 'Pool 1'

    const allowTx = await erc20.increaseAllowance(project.address, amount)
    await allowTx.wait()

    const currentTimeStamp = await getLastBlockTimestamp();

    let startingPeriodTime = currentTimeStamp + 100

    await expect(
        project.createPoolWithGrants(poolName, startingPeriodTime, poolVestingTime, [user1.address], [amount])
    ).to.emit(project, "PoolAdded").withArgs(owner.address, poolName, startingPeriodTime, startingPeriodTime + poolVestingTime)
  });

  it("create pool without grants should work for manager", async function () {

    const currentTimeStamp = await getLastBlockTimestamp();
    let startingPeriodTime = currentTimeStamp + 100
    await expect(
        project.createPool(poolName, startingPeriodTime, poolVestingTime)
    ).to.emit(project, "PoolAdded").withArgs(owner.address, poolName, startingPeriodTime, startingPeriodTime + poolVestingTime)
  });

  it("user without manager role create pool should fail", async function () {

    const currentTimeStamp = await getLastBlockTimestamp();

    let startingPeriodTime = currentTimeStamp + 100

    await expect(
        project.connect(user1).createPool(poolName, startingPeriodTime, poolVestingTime)
    ).to.rejectedWith("ManageableUpgradeable::onlyManager: the caller is not an manager.");
  });
});
