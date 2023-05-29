// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "../access/ManageableUpgradeable.sol";
import "./ITestLinearVestingProjectUpgradeable.sol";

/**
 * @title LinearVestingProjectUpgradeable
 * @dev Linear Vesting project for linear vesting grants distribution.
 * Taken from https://github.com/dandelionlabs-io/linear-vesting-contracts/blob/master/contracts/LinearVestingProjectUpgradeable.sol
 */
contract TestLinearVestingProjectUpgradeable is
    ManageableUpgradeable,
    ITestLinearVestingProjectUpgradeable
{
    using SafeMathUpgradeable for uint;

    /// @dev Used to translate vesting periods specified in days to seconds
    uint internal constant SECONDS_PER_DAY = 86400;

    /// @notice ERC20 token
    IERC20Upgradeable public token;

    /// @dev Each Organization has many vesting schedules
    VestingSchedule[] public vestingSchedules;

    /// @notice Mapping of recipient address > token grant
    mapping(uint => mapping(address => Grant)) public grants;

    /// @dev metadata url
    string public metadataUrl;

    /**
     * @notice Construct a new Vesting contract
     * @param _token Address of ERC20 token
     */
    function __LinearVestingProject_initialize(
        address _token,
        string calldata _metadataUrl
    ) external initializer {
        __ManageableUpgradeable_init();

        require(
            _token != address(0),
            "LinearVestingProject::__init_LinearVestingProject: _token must be valid token address"
        );

        token = IERC20Upgradeable(_token);
        metadataUrl = _metadataUrl;
    }

    /**
     * @notice Creates a new pool
     * @param _startTime starting time of the vesting period in timestamp format
     * @param _vestingDuration duration time of the vesting period in timestamp format
     */
    function createVestingSchedule(
        address _token,
        string memory _metadataUrl,
        uint256 _startTime,
        uint256 _vestingDuration
    ) public override onlyManager returns (uint256) {
        require(
            _startTime > 0 && _vestingDuration > 0,
            "LinearVestingProject::createVestingSchedule: One of the time parameters is 0"
        );
        require(
            _startTime > block.timestamp,
            "LinearVestingProject::createVestingSchedule: Starting time shall be in a future time"
        );
        require(
            _vestingDuration > 0,
            "LinearVestingProject::createVestingSchedule: Duration of the period must be > 0"
        );
        if (_vestingDuration < SECONDS_PER_DAY) {
            require(
                _vestingDuration <= SECONDS_PER_DAY.mul(10).mul(365),
                "LinearVestingProject::createVestingSchedule: Duration should be less than 10 years"
            );
        }

        uint256 vestingIndex = vestingSchedules.length;

        vestingSchedules.push(
            VestingSchedule({
                token: _token,
                metadataUrl: _metadataUrl,
                startTime: _startTime,
                vestingDuration: _vestingDuration,
                endTime: _startTime.add(_vestingDuration),
                amount: 0,
                totalClaimed: 0,
                grants: 0
            })
        );

        emit VestingScheduleAdded(
            _token,
            _metadataUrl,
            vestingIndex,
            msg.sender,
            _startTime,
            _startTime.add(_vestingDuration)
        );
        return vestingIndex;
    }

    function createVestingScheduleWithGrants(
        address _token,
        string memory _metadataUrl,
        uint256 _startTime,
        uint256 _vestingDuration,
        address[] memory _recipients,
        uint256[] memory _amounts
    ) public override onlyManager returns (uint) {
        uint vestingIndex = createVestingSchedule(
            _token,
            _metadataUrl,
            _startTime,
            _vestingDuration
        );
        addGrants(vestingIndex, _recipients, _amounts);
        return vestingIndex;
    }

    /**
     * @notice Add list of grants in batch.
     * @param _recipients list of addresses of the stakeholders
     * @param _amounts list of amounts to be assigned to the stakeholders
     */
    function addGrants(
        uint _vestingIndex,
        address[] memory _recipients,
        uint256[] memory _amounts
    ) public virtual override onlyManager {
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
            _vestingIndex < vestingSchedules.length,
            "LinearVestingProject::addTokenGrants: invalid pool index"
        );

        VestingSchedule memory vesting = vestingSchedules[_vestingIndex];

        uint256 amountSum = 0;
        for (uint16 i = 0; i < _recipients.length; i++) {
            require(
                _recipients[i] != address(0),
                "LinearVestingProject:addTokenGrants: there is an address with value 0"
            );
            require(
                grants[_vestingIndex][_recipients[i]].totalClaimed == 0,
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
                perSecond: _amounts[i].div(vesting.vestingDuration)
            });
            grants[_vestingIndex][_recipients[i]] = grant;
            emit GrantAdded(
                _vestingIndex,
                msg.sender,
                _recipients[i],
                _amounts[i]
            );
        }

        vesting.amount = vesting.amount.add(amountSum);
        vesting.grants = vesting.grants.add(_recipients.length);
    }

    /**
     * @notice Calculate the vested and unclaimed tokens available for `recipient` to claim
     * @dev Due to rounding errors once grant duration is reached, returns the entire left grant amount
     * @param _recipient The address that has a grant
     * @return The amount recipient can claim
     */
    function calculateGrantClaim(
        uint _vestingIndex,
        address _recipient
    ) public view override returns (uint256) {
        require(
            _vestingIndex < vestingSchedules.length,
            "LinearVestingProject::calculateGrantClaim: invalid pool index"
        );
        VestingSchedule memory vesting = vestingSchedules[_vestingIndex];
        // For grants created with a future start date, that hasn't been reached, return 0, 0
        if (block.timestamp < vesting.startTime) {
            return 0;
        }

        uint256 cap = block.timestamp;
        if (cap > vesting.endTime) {
            cap = vesting.endTime;
        }
        uint256 elapsedTime = cap.sub(vesting.startTime);

        // If over vesting duration, all tokens vested
        if (elapsedTime >= vesting.vestingDuration) {
            uint256 remainingGrant = grants[_vestingIndex][_recipient]
                .totalClaimed
                .sub(grants[_vestingIndex][_recipient].amount);
            return remainingGrant;
        } else {
            uint256 amountVested = grants[_vestingIndex][_recipient]
                .perSecond
                .mul(elapsedTime);
            uint256 claimableAmount = amountVested.sub(
                grants[_vestingIndex][_recipient].totalClaimed
            );
            return claimableAmount;
        }
    }

    /**
     * @notice Allows a grant recipient to claim multiple vested tokens
     * @dev Errors if no tokens have vested
     * @dev It is advised recipients check they are entitled to claim via `calculateGrantClaim` before calling this
     */
    function claimMultipleVestings(
        uint[] memory _vestingIndexes
    ) external override {
        for (uint i = 0; i < _vestingIndexes.length; i++) {
            claimVestedTokens(_vestingIndexes[i]);
        }
    }

    /**
     * @notice Allows a grant recipient to claim their vested tokens
     * @dev Errors if no tokens have vested
     * @dev It is advised recipients check they are entitled to claim via `calculateGrantClaim` before calling this
     */
    function claimVestedTokens(uint _vestingIndex) public override {
        require(
            _vestingIndex < vestingSchedules.length,
            "LinearVestingProject::calculateGrantClaim: invalid vesting index"
        );
        VestingSchedule memory vesting = vestingSchedules[_vestingIndex];

        uint256 amountVested = calculateGrantClaim(_vestingIndex, msg.sender);
        require(
            amountVested > 0,
            "VestingPeriod::claimVestedTokens: amountVested is 0"
        );
        require(
            token.transfer(msg.sender, amountVested),
            "VestingPeriod::claimVestedTokens: transfer failed"
        );

        Grant storage grant = grants[_vestingIndex][msg.sender];

        grant.totalClaimed = uint256(grant.totalClaimed.add(amountVested));
        vesting.totalClaimed = vesting.totalClaimed.add(amountVested);

        emit GrantClaimed(_vestingIndex, msg.sender, amountVested);
    }

    function setMetadataUrl(
        string calldata _metadataUrl
    ) external override onlyManager {
        metadataUrl = _metadataUrl;
        emit MetadataUrlChanged(msg.sender, _metadataUrl);
    }

    uint256[49] private __gap;
}
