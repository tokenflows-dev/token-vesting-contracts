// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vesting.sol";

contract VestingPoolFactory is Ownable {
    using SafeMath for uint256;

    address[] public vestingPools;

    function createPool(
        string memory _name,
        address _token,
        uint256 _startTime,
        uint256 _vestingDuration
    ) external onlyOwner {
        VestingPeriod pool = new VestingPeriod(
            _name,
            _token,
            _startTime,
            _vestingDuration
        );

        pool.transferOwnership(msg.sender);
        vestingPools.push(address(pool));
    }

    function getPools() external view returns (address[] memory _pools) {
        _pools = vestingPools;
    }
}
