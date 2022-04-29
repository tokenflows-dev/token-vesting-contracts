// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VestingBase.sol";

abstract contract VestingDeletable is VestingBase {
    /// @notice Event emitted when the grant investor is deleted
    event DeleteInvestor(address indexed);

    /**
     * @notice Deletes a grant from a pool by Id, refunds the remaining tokens from a grant.
     * @param _address existing address from the investor which we want to delete
     */
    function deleteInvestor(address _address) external onlyRole(OPERATORS) {
        uint256 refund = tokenGrants[_address].amount -
            tokenGrants[_address].totalClaimed;
        delete tokenGrants[_address];

        require(
            token.transferFrom(address(this), msg.sender, refund),
            "VestingDeletable::deleteInvestor: transfer failed"
        );

        emit DeleteInvestor(_address);
    }
}
