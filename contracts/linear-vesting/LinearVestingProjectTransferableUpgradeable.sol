// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.4;

// import "./LinearVestingProjectUpgradeable.sol";

// abstract contract LinearVestingProjectTransferableUpgradeable is LinearVestingProjectUpgradeable {
//    using SafeMathUpgradeable for uint256;

//    /// @notice Event emitted when the grant investor is changed
//    event GrantChanged(address indexed oldOwner, address indexed newOwner);

//    /// @notice List of investors who got blacklist tokens.
//    /// @dev Structure of the map: investor => new address
//    mapping(address => address) public blacklist;

//    /**
//     * @notice In case if the user doesn't want to change the grant.
//     * @param _oldAddress existing address from the investor which we want to change
//     * @param _newAddress new address from the investor which we want to give
//     */
//    function changeInvestor(address _oldAddress, address _newAddress)
//        external
//        onlyRole(OPERATORS)
//    {
//        require(
//            blacklist[_oldAddress] == address(0),
//            "VestingPeriod::changeInvestor: oldaddress already in the blacklist"
//        );
//        require(
//            blacklist[_newAddress] == address(0),
//            "VestingPeriod::changeInvestor: new address is a blacklisted address"
//        );
//        require(
//            tokenGrants[_newAddress].amount == 0,
//            "VestingPeriod::changeInvestor: requires a different address than existing granted"
//        );
//        require(
//            tokenGrants[_oldAddress].amount > 0,
//            "VestingPeriod::changeInvestor: oldAddress has no remaining balance"
//        );

//        tokenGrants[_newAddress] = Grant(
//            tokenGrants[_oldAddress].amount,
//            tokenGrants[_oldAddress].totalClaimed,
//            tokenGrants[_oldAddress].perSecond
//        );
//        delete tokenGrants[_oldAddress];

//        blacklist[_oldAddress] = _newAddress;

//        emit GrantChanged(_oldAddress, _newAddress);
//    }

//    function addTokenGrants(
//        address[] memory _recipients,
//        uint256[] memory _amounts
//    ) public virtual override onlyRole(OPERATORS) {
//        require(
//            _recipients.length > 0,
//            "VestingPeriod::addTokenGrants: no recipients"
//        );
//        require(
//            _recipients.length <= 100,
//            "VestingPeriod::addTokenGrants: too many grants, it will probably fail"
//        );
//        require(
//            _recipients.length == _amounts.length,
//            "VestingPeriod::addTokenGrants: invalid parameters length (they should be same)"
//        );

//        uint256 amountSum = 0;
//        for (uint16 i = 0; i < _recipients.length; i++) {
//            require(
//                _recipients[i] != address(0),
//                "VestingPeriod:addTokenGrants: there is an address with value 0"
//            );
//            require(
//                tokenGrants[_recipients[i]].amount == 0,
//                "VestingPeriod::addTokenGrants: a grant already exists for one of the accounts"
//            );
//            require(
//                blacklist[_recipients[i]] == address(0),
//                "VestingPeriod:addTOkenGrants: Blacklisted address"
//            );

//            require(
//                _amounts[i] > 0,
//                "VestingPeriod::addTokenGrant: amount == 0"
//            );
//            amountSum = amountSum.add(_amounts[i]);
//        }

//        // Transfer the grant tokens under the control of the vesting contract
//        require(
//            token.transferFrom(msg.sender, address(this), amountSum),
//            "VestingPeriod::addTokenGrants: transfer failed"
//        );

//        for (uint16 i = 0; i < _recipients.length; i++) {
//            Grant memory grant = Grant({
//                amount: _amounts[i],
//                totalClaimed: 0,
//                perSecond: _amounts[i].div(pool.vestingDuration)
//            });
//            tokenGrants[_recipients[i]] = grant;
//            emit GrantAdded(_recipients[i], _amounts[i]);
//        }

//        pool.amount = pool.amount.add(amountSum);
//    }
// }
