import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import {deployProjectFactory} from "./util/fixtures";

describe("Claims calculation", function () {

  let projectFactory, erc20, owner, manager, user1, user2;

  beforeEach(async () => {
    ({projectFactory, erc20, owner, manager, user1, user2 } = await loadFixture(deployProjectFactory));
  });

  it("claimed balance calculation", async function () {

  });

  it("vested balance calculation", async function () {

  });

  it("claimable balance calculation", async function () {

  });
});
