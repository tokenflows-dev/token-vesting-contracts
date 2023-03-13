import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import {deployProjectFactory} from "./util/fixtures";

describe("Claims", function () {

  let projectFactory, erc20, owner, manager, user1, user2;

  beforeEach(async () => {
    ({projectFactory, erc20, owner, manager, user1, user2 } = await loadFixture(deployProjectFactory));
  });

  it("ongoing grant claim should succeed", async function () {
    // todo check emitted event
  });

  it("invalid pool index should fail", async function () {

  });

  it("invalid grant should fail", async function () {

  });

  it("claimable balance 0 should fail", async function () {

  });
});
