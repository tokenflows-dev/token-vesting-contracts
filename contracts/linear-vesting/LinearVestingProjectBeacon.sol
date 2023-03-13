// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

/**
 * @title LinearVestingProjectBeacon
 * @dev This contract is a the Beacon to proxy Linear Vesting projects.
 */
contract LinearVestingProjectBeacon is UpgradeableBeacon {
    constructor(address _initBlueprint) UpgradeableBeacon(_initBlueprint) {
        transferOwnership(tx.origin);
    }
}
