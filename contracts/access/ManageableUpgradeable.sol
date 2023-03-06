// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title ManageableUpgradeable
 * @dev This contract keeps the information about the managers of a contract.
 */
contract ManageableUpgradeable is OwnableUpgradeable {

    mapping (address => bool) managers;

    function __ManageableUpgradeable_init(address _owner) public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        _transferOwnership(_owner);
    }

    function addManager(address manager) external onlyOwner {
        _addManager(manager);
    }

    function _addManager(address manager) internal {
        managers[manager] = true;
    }

    function removeManager(address manager) external onlyOwner {
        managers[manager] = false;
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
