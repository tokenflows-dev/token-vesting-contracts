// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../ILinearVestingProjectUpgradeable.sol";

/**
 * @title ILinearVestingProjectRemovableUpgradeable interface
 * @dev Linear Vesting project for linear vesting grants distribution.
 * Taken from https://github.com/dandelionlabs-io/linear-vesting-contracts/blob/master/contracts/linear-vesting/ILinearVestingProjectRemovableUpgradeable.sol
 */
interface ILinearVestingProjectRemovableUpgradeable is ILinearVestingProjectUpgradeable {

    /// @notice Event emitted when the grant stakeholder is deleted
    event GrantRemoved(uint indexed poolIndex, address indexed stakeHolderAddress);

    /**
     * @notice Deletes a grant from a pool by Id, refunds the remaining tokens from a grant.
     * @param _address existing address from the investor which we want to delete
     */
    function removeGrant(uint _poolIndex, address _address) external;
}
