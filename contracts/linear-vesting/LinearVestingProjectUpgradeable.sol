// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "../access/ManageableUpgradeable.sol";

/**
 * @title LinearVestingProjectUpgradeable
 * @dev Linear Vesting project for linear vesting grants distribution.
 * Taken from https://github.com/dandelionlabs-io/linear-vesting-contracts/blob/master/contracts/LinearVestingProjectUpgradeable.sol
 */
contract LinearVestingProjectUpgradeable is ManageableUpgradeable {
    using SafeMathUpgradeable for uint;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    /// @dev Used to translate vesting periods specified in days to seconds
    uint internal constant SECONDS_PER_DAY = 86400;

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
    event GrantClaimed(
        uint indexed poolIndex,
        address indexed recipient,
        uint indexed amountClaimed
    );

    /// @notice ERC20 token
    IERC20Upgradeable public token;

    /// @dev Each Linear Vesting project has many pools
    Pool[] public pools;

    /// @notice Mapping of recipient address > token grant
    mapping(uint => mapping(address => Grant)) public grants;

    /**
     * @notice Construct a new Vesting contract
     * @param _token Address of ERC20 token
     */
    function __LinearVestingProject_initialize(address _token) external initializer {
        __ManageableUpgradeable_init(msg.sender);

        require(
            _token != address(0),
            "LinearVestingProject::__init_LinearVestingProject: _token must be valid token address"
        );

        token = IERC20Upgradeable(_token);
    }


    /**
     * @notice Creates a new pool
     * @param _startTime starting time of the vesting period in timestamp format
     * @param _vestingDuration duration time of the vesting period in timestamp format
     */
    function createPool(
        string memory _name,
        uint256 _startTime,
        uint256 _vestingDuration
    ) public onlyManager {
        require(
            _startTime > 0 && _vestingDuration > 0,
            "LinearVestingProject::createPool: One of the time parameters is 0"
        );
        require(
            _startTime > block.timestamp,
            "LinearVestingProject::createPool: Starting time shall be in a future time"
        );
        require(
            _vestingDuration > 0,
            "LinearVestingProject::createPool: Duration of the period must be > 0"
        );
        if (_vestingDuration < SECONDS_PER_DAY) {
            require(
                _vestingDuration <= SECONDS_PER_DAY.mul(10).mul(365),
                "LinearVestingProject::createPool: Duration should be less than 10 years"
            );
        }

        pools.push(Pool({
            name: _name,
            startTime: _startTime,
            vestingDuration: _vestingDuration,
            endTime: _startTime.add(_vestingDuration),
            amount: 0,
            totalClaimed: 0,
            grants: 0
        }));

        emit PoolAdded(pools.length.sub(1));
    }

    /**
     * @notice Add list of grants in batch.
     * @param _recipients list of addresses of the stakeholders
     * @param _amounts list of amounts to be assigned to the stakeholders
     */
    function addGrants(
        uint _poolIndex,
        address[] memory _recipients,
        uint256[] memory _amounts
    ) public virtual onlyManager {
        require(
            _recipients.length > 0,
            "LinearVestingProject::addTokenGrants: no recipients"
        );
        require(
            _recipients.length <= 100,
            "LinearVestingProject::addTokenGrants: too many grants, it will probably fail"
        );
        require(
            _recipients.length == _amounts.length,
            "LinearVestingProject::addTokenGrants: invalid parameters length (they should be same)"
        );
        require(
            _poolIndex < pools.length,
            "LinearVestingProject::addTokenGrants: invalid pool index"
        );

        Pool memory pool = pools[_poolIndex];

        uint256 amountSum = 0;
        for (uint16 i = 0; i < _recipients.length; i++) {
            require(
                _recipients[i] != address(0),
                "LinearVestingProject:addTokenGrants: there is an address with value 0"
            );
            require(
                grants[_poolIndex][_recipients[i]].amount == 0,
                "LinearVestingProject::addTokenGrants: a grant already exists for one of the accounts"
            );
            require(
                _amounts[i] > 0,
                "LinearVestingProject::addTokenGrant: amount == 0"
            );
            amountSum = amountSum.add(_amounts[i]);
        }

        // Transfer the grant tokens under the control of the vesting contract
        require(
            token.transferFrom(msg.sender, address(this), amountSum),
            "LinearVestingProject::addTokenGrants: transfer failed"
        );

        for (uint16 i = 0; i < _recipients.length; i++) {
            Grant memory grant = Grant({
                amount: _amounts[i],
                totalClaimed: 0,
                perSecond: _amounts[i].div(pool.vestingDuration)
            });
            grants[_poolIndex][_recipients[i]] = grant;
            emit GrantAdded(_poolIndex, _recipients[i], _amounts[i]);
        }

        pool.amount = pool.amount.add(amountSum);
        pool.grants = pool.grants.add(_recipients.length);
    }

    /**
     * @notice Get token grant for recipient
     * @param _poolIndex The pool index
     * @param _recipient The address that has a grant
     * @return the grant
     */
    function getTokenGrant(uint _poolIndex, address _recipient)
        external
        view
        returns (Grant memory)
    {
        return grants[_poolIndex][_recipient];
    }

    /**
     * @notice Calculate the vested and unclaimed tokens available for `recipient` to claim
     * @dev Due to rounding errors once grant duration is reached, returns the entire left grant amount
     * @param _recipient The address that has a grant
     * @return The amount recipient can claim
     */
    function calculateGrantClaim(uint _poolIndex, address _recipient)
        public
        view
        returns (uint256)
    {
        require(
            _poolIndex < pools.length,
            "LinearVestingProject::calculateGrantClaim: invalid pool index"
        );
        Pool memory pool = pools[_poolIndex];
        // For grants created with a future start date, that hasn't been reached, return 0, 0
        if (block.timestamp < pool.startTime) {
            return 0;
        }

        uint256 cap = block.timestamp;
        if (cap > pool.endTime) {
            cap = pool.endTime;
        }
        uint256 elapsedTime = cap.sub(pool.startTime);

        // If over vesting duration, all tokens vested
        if (elapsedTime >= pool.vestingDuration) {
            uint256 remainingGrant = grants[_poolIndex][_recipient].amount.sub(
                grants[_poolIndex][_recipient].totalClaimed
            );
            return remainingGrant;
        } else {
            uint256 amountVested = grants[_poolIndex][_recipient].perSecond.mul(
                elapsedTime
            );
            uint256 claimableAmount = amountVested.sub(
                grants[_poolIndex][_recipient].totalClaimed
            );
            return claimableAmount;
        }
    }

    /**
     * @notice Calculate the vested (claimed + unclaimed) tokens for `recipient`
     * @param _recipient The address that has a grant
     * @return Total vested balance (claimed + unclaimed)
     */
    function vestedBalance(uint _poolIndex, address _recipient) external view returns (uint256) {
        require(
            _poolIndex < pools.length,
            "LinearVestingProject::calculateGrantClaim: invalid pool index"
        );
        Pool memory pool = pools[_poolIndex];

        // For grants created with a future start date, that hasn't been reached, return 0, 0
        if (block.timestamp < pool.startTime) {
            return 0;
        }

        uint256 cap = block.timestamp;
        if (cap > pool.endTime) {
            cap = pool.endTime;
        }

        // If over vesting duration, all tokens vested
        if (cap == pool.endTime) {
            return grants[_poolIndex][_recipient].amount;
        } else {
            uint256 elapsedTime = cap.sub(pool.startTime);
            uint256 amountVested = grants[_poolIndex][_recipient].perSecond.mul(
                elapsedTime
            );
            return amountVested;
        }
    }

    /**
     * @notice The balance claimed by `recipient`
     * @param _recipient The address that has a grant
     * @return the number of claimed tokens by `recipient`
     */
    function claimedBalance(uint _poolIndex, address _recipient)
        external
        view
        returns (uint256)
    {
        return grants[_poolIndex][_recipient].totalClaimed;
    }

    /**
     * @notice Allows a grant recipient to claim their vested tokens
     * @dev Errors if no tokens have vested
     * @dev It is advised recipients check they are entitled to claim via `calculateGrantClaim` before calling this
     */
    function claimVestedTokens(uint _poolIndex) external {
        require(
            _poolIndex < pools.length,
            "LinearVestingProject::calculateGrantClaim: invalid pool index"
        );
        Pool memory pool = pools[_poolIndex];

        uint256 amountVested = calculateGrantClaim(_poolIndex, msg.sender);
        require(
            amountVested > 0,
            "VestingPeriod::claimVestedTokens: amountVested is 0"
        );
        require(
            token.transfer(msg.sender, amountVested),
            "VestingPeriod::claimVestedTokens: transfer failed"
        );

        Grant storage grant = grants[_poolIndex][msg.sender];

        grant.totalClaimed = uint256(
            grant.totalClaimed.add(amountVested)
        );
        pool.totalClaimed = pool.totalClaimed.add(amountVested);

        emit GrantClaimed(_poolIndex, msg.sender, amountVested);
    }

    /**
     * @notice Calculate the number of tokens that will vest per day for the given recipient
     * @param _recipient The address that has a grant
     * @return Number of tokens that will vest per day
     */
    function tokensVestedPerDay(uint _poolIndex, address _recipient)
        external
        view
        returns (uint256)
    {
        require(
            _poolIndex < pools.length,
            "LinearVestingProject::calculateGrantClaim: invalid pool index"
        );
        Pool memory pool = pools[_poolIndex];
        return
            grants[_poolIndex][_recipient].amount.div(
                pool.vestingDuration.div(SECONDS_PER_DAY)
            );
    }

    /**
     * @notice Calculate the number of tokens that will vest per day in the given period for an amount
     * @param _amount the amount to be checked
     * @return Number of tokens that will vest per day
     */
    function calculatePoolVesting(uint _poolIndex, uint256 _amount)
        external
        view
        returns (uint256)
    {
        require(
            _poolIndex < pools.length,
            "LinearVestingProject::calculateGrantClaim: invalid pool index"
        );
        Pool memory pool = pools[_poolIndex];
        return _amount.div(pool.vestingDuration.div(SECONDS_PER_DAY));
    }
}
