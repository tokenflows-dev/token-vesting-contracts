import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import {deployProjectFactory} from "./util/fixtures";

describe("Factory", function () {

  let projectFactory, erc20, owner, manager, user1, user2;

  beforeEach(async () => {
    ({projectFactory, erc20, owner, manager, user1, user2 } = await loadFixture(deployProjectFactory));
  });

  it("deploy factory should succeed", async function () {

  });

  it("create new project should succeed", async function () {
    // todo check if event has been emitted
  });

  it("create project should fail if token address is not ERC20", async function () {

  });

  it("not owner shouldn't be able to create new projects", async function () {

  });

  it("upgrade beacon should succeed", async function () {

  });
});
