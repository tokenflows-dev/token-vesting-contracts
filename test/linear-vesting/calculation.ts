import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { mine } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import {deployProjectFactoryWithProjectAndPool} from "./util/fixtures";
import {setNextBlockTimestamp} from "./util/time";

describe("Claims calculation", function () {

  let poolVestingTime, startingPeriodTime, amount, projectFactory, erc20, project, owner, manager, user1, user2;

  beforeEach(async () => {
    ({startingPeriodTime, poolVestingTime, amount, projectFactory, erc20, project, owner, manager, user1, user2 } = await loadFixture(deployProjectFactoryWithProjectAndPool));
  });

  it("claimed & vested balance calculation", async function () {

    const nextTs = startingPeriodTime + (poolVestingTime / 2); // elapsed half-time
    await setNextBlockTimestamp(nextTs);

    let claimTx = await project.connect(user1).claimVestedTokens(0)
    await claimTx.wait()

    let grant = await project.grants(0, user1.address)
    expect(grant.totalClaimed).to.equal(amount.div(2));

    const finalTs = nextTs + (poolVestingTime / 4); // elapsed
    await setNextBlockTimestamp(finalTs - 1); // last second was already claimed --

    await mine()

    claimTx = await project.connect(user1).claimVestedTokens(0)
    await claimTx.wait()
    grant = await project.grants(0, user1.address)
    expect(grant.totalClaimed).to.equal(amount.mul(3).div(4));
  });

  it("claimable balance calculation", async function () {

    const nextTs = startingPeriodTime + (poolVestingTime / 2); // elapsed half-time
    await setNextBlockTimestamp(nextTs);

    await mine()

    expect(await project.calculateGrantClaim(0, user1.address)).to.equal(amount.div(2));
  });
});
