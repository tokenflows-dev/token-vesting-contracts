import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import {deployUserRegistry} from "./util/fixtures";
import {expect} from "chai";

const INITIAL_METADATA_URL = 'ipfs://hola';

describe("Update UserRegistry", function () {

  let userRegistry, owner, user1, user2;

  beforeEach(async () => {
    ({userRegistry, owner, user1, user2 } = await loadFixture(deployUserRegistry));
  });

  it("normal user can update his own profile", async function () {
    await expect(
      userRegistry.connect(user1).updateMetadataUrl(user1.address, INITIAL_METADATA_URL)
    ).to.emit(userRegistry, "MetadataUrlChanged").withArgs(user1.address, INITIAL_METADATA_URL)

    expect(await userRegistry.metadataUrls(user1.address)).to.equal(INITIAL_METADATA_URL);
  });

  it("owner can update any profile", async function () {
    await expect(
        userRegistry.connect(owner).updateMetadataUrl(user2.address, INITIAL_METADATA_URL)
    ).to.emit(userRegistry, "MetadataUrlChanged").withArgs(user2.address, INITIAL_METADATA_URL)

    expect(await userRegistry.metadataUrls(user2.address)).to.equal(INITIAL_METADATA_URL);
  });

  it("normal user cannot update others profile", async function () {
    await expect(
        userRegistry.connect(user2).updateMetadataUrl(user1.address, INITIAL_METADATA_URL)
    ).to.rejectedWith("UserRegistry::updateMetadataUrl: Sender must be owner or the same user to update metadata.");

    expect(await userRegistry.metadataUrls(user1.address)).to.equal("");
  });
});
