// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./LinearVestingProjectUpgradeable.sol";

abstract contract LinearVestingProjectRemovableUpgradeable is LinearVestingProjectUpgradeable {

    /// @notice Event emitted when the grant stakeholder is deleted
    event GrantRemoved(address indexed);

    /**
     * @notice Deletes a grant from a pool by Id, refunds the remaining tokens from a grant.
     * @param _address existing address from the investor which we want to delete
     */
    function removeGrant(uint _poolIndex, address _address) external onlyManager {
        require(
            grants[_poolIndex][_address].amount > 0,
            "LinearVestingProjectRemovable::removeGrant: grant not active"
        );

        uint256 refund = grants[_poolIndex][_address].amount -
            grants[_poolIndex][_address].totalClaimed;
        delete grants[_poolIndex][_address];

        require(
            token.transferFrom(address(this), msg.sender, refund),
            "LinearVestingProjectRemovable::removeGrant: transfer failed"
        );

        emit GrantRemoved(_address);
    }
}
