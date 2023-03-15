import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import {deployProjectFactoryWithProjectAndPool} from "./util/fixtures";
import {setNextBlockTimestamp} from "./util/time";

describe("Claims", function () {

  let poolVestingTime, startingPeriodTime, amount, projectFactory, erc20, project, owner, manager, user1, user2;

  beforeEach(async () => {
    ({startingPeriodTime, poolVestingTime, amount, projectFactory, erc20, project, owner, manager, user1, user2 } = await loadFixture(deployProjectFactoryWithProjectAndPool));
  });

  it("ongoing grant claim should succeed", async function () {
    const nextTs = startingPeriodTime + (poolVestingTime / 2); // elapsed half-time
    await setNextBlockTimestamp(nextTs);

    await expect(
        project.connect(user1).claimVestedTokens(0)
    ).to.emit(project, "GrantClaimed").withArgs(0, user1.address, amount.div(2))

    expect(await project.claimedBalance(0, user1.address)).to.equal(amount.div(2));
    expect(await project.vestedBalance(0, user1.address)).to.equal(amount.div(2));
  });

  it("invalid pool index should fail", async function () {
    const nextTs = startingPeriodTime + (poolVestingTime / 2); // elapsed half-time
    await setNextBlockTimestamp(nextTs);

    await expect(
        project.connect(user1).claimVestedTokens(1)
    ).to.rejectedWith("LinearVestingProject::calculateGrantClaim: invalid pool index");
  });

  it("invalid grantee should fail", async function () {
    const nextTs = startingPeriodTime + (poolVestingTime / 2); // elapsed half-time
    await setNextBlockTimestamp(nextTs);

    await expect(
        project.connect(user2).claimVestedTokens(0)
    ).to.rejectedWith("VestingPeriod::claimVestedTokens: amountVested is 0'");
  });

  it("claimable balance 0 should fail", async function () {
    await expect(
        project.connect(user1).claimVestedTokens(0)
    ).to.rejectedWith("VestingPeriod::claimVestedTokens: amountVested is 0'");
  });
});
