import {loadFixture, mine} from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import {deployProjectFactoryWithProjectAndPool} from "./util/fixtures";

describe("Grants management", function () {

  let poolVestingTime, startingPeriodTime, amount, projectFactory, erc20, project, owner, manager, user1, user2;

  beforeEach(async () => {
    ({startingPeriodTime, poolVestingTime, amount, projectFactory, erc20, project, owner, manager, user1, user2 } = await loadFixture(deployProjectFactoryWithProjectAndPool));
  });

  describe("Adding new grants", function () {

    it("add new grants by a manager should succeed", async function () {

      const allowTx = await erc20.increaseAllowance(project.address, amount)
      await allowTx.wait()

      await expect(
          project.addGrants(0, [user2.address], [amount])
      ).to.emit(project, "GrantAdded").withArgs(0, owner.address, user2.address, amount)

      const newGrant = await project.grants(0, user2.address)
      expect(newGrant.amount).to.equal(amount);
    });

    it("user without manager role adding should fail", async function () {

      await expect(
          project.connect(user1).addGrants(0, [], [])
      ).to.rejectedWith("ManageableUpgradeable::onlyManager: the caller is not an manager.");
    });

    it("no grantees should fail", async function () {

      await expect(
          project.addGrants(0, [], [])
      ).to.rejectedWith("LinearVestingProject::addTokenGrants: no recipients");
    });

    it("more than 100 grantees should fail", async function () {

      const grantAddresses = []
      const grantAmounts = []
      for (let i = 0; i < 101; i++){
        grantAddresses.push(user1.address)
        grantAmounts.push(amount)
      }
      await expect(
          project.addGrants(0, grantAddresses, grantAmounts)
      ).to.rejectedWith("LinearVestingProject::addTokenGrants: too many grants, it will probably fail");
    });

    it("different quantity of grantees and amounts should fail", async function () {

      await expect(
          project.addGrants(0, [user1.address], [])
      ).to.rejectedWith("LinearVestingProject::addTokenGrants: invalid parameters length (they should be same)");
    });

    it("invalid pool index should fail", async function () {

      await expect(
          project.addGrants(1, [user1.address], [amount])
      ).to.rejectedWith("LinearVestingProject::addTokenGrants: invalid pool index");
    });
  });

  describe("Remove existing grants", function () {
    it("remove existing grants by a manager should succeed", async function () {
      const newGrant = await project.grants(0, user1.address)
      expect(newGrant.amount).to.equal(amount);

      await expect(
          project.removeGrant(0, user1.address)
      ).to.emit(project, "GrantRemoved").withArgs(0, owner.address, user1.address)

      const removedGrant = await project.grants(0, user1.address)
      expect(removedGrant.amount).to.equal(0);
    });

    it("user without manager role remove should fail", async function () {

      await expect(
          project.connect(user1).removeGrant(0, user1.address)
      ).to.rejectedWith("ManageableUpgradeable::onlyManager: the caller is not an manager.");
    });

    it("invalid grant or without funds available should fail", async function () {

      await expect(
          project.removeGrant(0, user2.address)
      ).to.rejectedWith("LinearVestingProjectRemovable::removeGrant: grant not active");
    });

    it("invalid pool index should fail", async function () {

      await expect(
          project.removeGrant(1, user1.address)
      ).to.rejectedWith("LinearVestingProjectRemovable::removeGrant: grant not active");
    });
  });
});
