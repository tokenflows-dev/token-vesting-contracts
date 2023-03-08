// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../LinearVestingProjectUpgradeable.sol";
import "./ILinearVestingProjectRemovableUpgradeable.sol";

contract LinearVestingProjectRemovableUpgradeable is LinearVestingProjectUpgradeable, ILinearVestingProjectRemovableUpgradeable {

    /**
     * @notice Deletes a grant from a pool by Id, refunds the remaining tokens from a grant.
     * @param _address existing address from the investor which we want to delete
     */
    function removeGrant(uint _poolIndex, address _address) external override onlyManager {
        Grant memory grant = grants[_poolIndex][_address];
        require(
            grant.amount > 0,
            "LinearVestingProjectRemovable::removeGrant: grant not active"
        );

        uint256 refund = grant.amount - grant.totalClaimed;
        delete grant;

        require(
            token.transferFrom(address(this), msg.sender, refund),
            "LinearVestingProjectRemovable::removeGrant: transfer failed"
        );

        emit GrantRemoved(_poolIndex, msg.sender, _address);
    }
}
