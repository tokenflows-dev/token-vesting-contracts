// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title ILinearVestingProjectUpgradeable interface
 * @dev Linear Vesting project for linear vesting grants distribution.
 * Taken from https://github.com/dandelionlabs-io/linear-vesting-contracts/blob/master/contracts/linear-vesting/ILinearVestingProjectUpgradeable.sol
 */
interface ILinearVestingProjectUpgradeable {

    /// @notice Pool definition
    struct Pool {
        string name; // Name of the pool
        uint startTime; // Starting time of the vesting period in unix timestamp format
        uint endTime; // Ending time of the vesting period in unix timestamp format
        uint vestingDuration; // In seconds
        uint amount; // Total size of pool
        uint totalClaimed; // Total amount claimed till moment
        uint grants; // Amount of stakeholders
    }

    /// @notice Grant definition
    struct Grant {
        uint amount; // Total amount to claim
        uint totalClaimed; // Already claimed
        uint perSecond; // Reward per second
    }

    /// @notice Event emitted when a new pool is created
    event PoolAdded(uint indexed poolIndex);

    /// @notice Event emitted when a new grant is created
    event GrantAdded(uint indexed poolIndex, address indexed recipient, uint256 indexed amount);

    /// @notice Event emitted when tokens are claimed by a recipient from a grant
    event GrantClaimed(uint indexed poolIndex, address indexed recipient, uint indexed amountClaimed);

    /**
     * @notice Creates a new pool
     * @param _startTime starting time of the vesting period in timestamp format
     * @param _vestingDuration duration time of the vesting period in timestamp format
     */
    function createPool(string memory _name, uint256 _startTime, uint256 _vestingDuration) external;

    /**
     * @notice Add list of grants in batch.
     * @param _recipients list of addresses of the stakeholders
     * @param _amounts list of amounts to be assigned to the stakeholders
     */
    function addGrants(
        uint _poolIndex, address[] memory _recipients, uint256[] memory _amounts) external;

    /**
     * @notice Get token grant for recipient
     * @param _poolIndex The pool index
     * @param _recipient The address that has a grant
     * @return the grant
     */
    function getTokenGrant(uint _poolIndex, address _recipient) external view returns (Grant memory);

    /**
     * @notice Calculate the vested and unclaimed tokens available for `recipient` to claim
     * @dev Due to rounding errors once grant duration is reached, returns the entire left grant amount
     * @param _recipient The address that has a grant
     * @return The amount recipient can claim
     */
    function calculateGrantClaim(uint _poolIndex, address _recipient) external view returns (uint256);

    /**
     * @notice Calculate the vested (claimed + unclaimed) tokens for `recipient`
     * @param _recipient The address that has a grant
     * @return Total vested balance (claimed + unclaimed)
     */
    function vestedBalance(uint _poolIndex, address _recipient) external view returns (uint256);

    /**
     * @notice The balance claimed by `recipient`
     * @param _recipient The address that has a grant
     * @return the number of claimed tokens by `recipient`
     */
    function claimedBalance(uint _poolIndex, address _recipient) external view returns (uint256);

    /**
     * @notice Allows a grant recipient to claim their vested tokens
     * @dev Errors if no tokens have vested
     * @dev It is advised recipients check they are entitled to claim via `calculateGrantClaim` before calling this
     */
    function claimVestedTokens(uint _poolIndex) external;

    /**
     * @notice Calculate the number of tokens that will vest per day for the given recipient
     * @param _recipient The address that has a grant
     * @return Number of tokens that will vest per day
     */
    function tokensVestedPerDay(uint _poolIndex, address _recipient) external view returns (uint256);

    /**
     * @notice Calculate the number of tokens that will vest per day in the given period for an amount
     * @param _amount the amount to be checked
     * @return Number of tokens that will vest per day
     */
    function calculatePoolVesting(uint _poolIndex, uint256 _amount) external view returns (uint256);
}
