import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deployProjectFactory } from "./util/fixtures";
import { ethers, upgrades } from "hardhat";
import { BigNumber } from "ethers";

describe("Factory", function () {
  let projectFactory, erc20, owner, manager, user1, user2;

  beforeEach(async () => {
    ({ projectFactory, erc20, owner, manager, user1, user2 } =
      await loadFixture(deployProjectFactory));
  });

  it("deploy factory should succeed", async function () {
    const LinearVestingProjectRemovableUpgradeable =
      await ethers.getContractFactory(
        "LinearVestingProjectRemovableUpgradeable"
      );
    const LinearVestingProjectFactoryUpgradeable =
      await ethers.getContractFactory("LinearVestingProjectFactoryUpgradeable");

    const projectBase = await LinearVestingProjectRemovableUpgradeable.connect(
      owner
    ).deploy();

    const projectFactory = await upgrades.deployProxy(
      LinearVestingProjectFactoryUpgradeable,
      [projectBase.address],
      { initializer: "__LinearVestingProjectFactory_initialize" }
    );
    await projectFactory.deployed();
  });

  it("create new project should succeed", async function () {
    expect(await projectFactory.projectsCount()).to.equal(BigNumber.from(0));

    await expect(
      projectFactory.createProject(erc20.address, "Project Example", "asd")
    ).to.emit(projectFactory, "ProjectCreated");

    expect(await projectFactory.projectsCount()).to.equal(BigNumber.from(1));
  });

  it.skip("upgrade beacon should succeed", async function () {});
});
