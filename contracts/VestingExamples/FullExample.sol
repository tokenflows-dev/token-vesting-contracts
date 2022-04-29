// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../VestingDeletable.sol";
import "../VestingTransferable.sol";

contract FullExample is VestingDeletable, VestingTransferable {
    constructor(
        string memory _name,
        address _token,
        uint256 _startTime,
        uint256 _vestingDuration,
        address _admin
    ) VestingBase(_name, _token, _startTime, _vestingDuration, _admin) {}

    function addTokenGrants(
        address[] memory _recipients,
        uint256[] memory _amounts
    ) public override(VestingBase, VestingTransferable) onlyRole(OPERATORS) {
        super.addTokenGrants(_recipients, _amounts);
    }
}
