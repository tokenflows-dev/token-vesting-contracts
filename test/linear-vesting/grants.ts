import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import {deployProjectFactory} from "./util/fixtures";

describe("Grants management", function () {

  let projectFactory, erc20, owner, manager, user1, user2;

  beforeEach(async () => {
    ({projectFactory, erc20, owner, manager, user1, user2 } = await loadFixture(deployProjectFactory));
  });

  describe("Adding new grants", function () {

    it("add new grants by a manager should succeed", async function () {
      // todo check emitted events if many
    });

    it("no grantees should fail", async function () {

    });

    it("more than 100 grantees should fail", async function () {

    });

    it("different quantity of grantees and amounts should fail", async function () {

    });

    it("invalid pool index should fail", async function () {

    });
  });

  describe("Remove existing grants", function () {
    it("remove existing grants by a manager should succeed", async function () {
      // todo check emitted event
    });

    it("invalid grant or without funds available should fail", async function () {

    });

    it("invalid pool index should fail", async function () {

    });
  });
});
