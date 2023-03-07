// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title ManageableUpgradeable
 * @dev This contract keeps the information about the managers of a contract.
 */
contract ManageableUpgradeable is OwnableUpgradeable {

    mapping (address => bool) managers;

    event ManagerChanged(address indexed manager, bool indexed isActive);

    function __ManageableUpgradeable_init() public initializer {
        _transferOwnership(tx.origin);
        _addManager(tx.origin);
    }

    function addManager(address manager) external onlyOwner {
        _addManager(manager);
    }

    function _addManager(address manager) internal {
        managers[manager] = true;
        emit ManagerChanged(manager, true);
    }

    function removeManager(address manager) external onlyOwner {
        managers[manager] = false;
        emit ManagerChanged(manager, false);
    }

    function isManager(address _user) public view returns (bool) {
        return managers[_user];
    }

    modifier onlyManager() {
        require(managers[_msgSender()], "ManageableUpgradeable::onlyManager: the caller is not an manager.");
        _;
    }

    uint256[50] private __gap;
}
