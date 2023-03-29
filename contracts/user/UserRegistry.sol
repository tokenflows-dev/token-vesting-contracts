// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IUserRegistry.sol";

/**
 * @title UserRegistry
 * @dev This contract holds a record of the url to the metadata and user profiles.
 */
contract UserRegistry is IUserRegistry, OwnableUpgradeable {

    // @dev mapping with ipfs urls to user metadata
    mapping(address => string) public metadataUrls;

    /**
     * @notice Construct a new User registry
     */
    function __UserRegistry_initialize() external initializer {
        __Ownable_init();
    }

    function updateMetadataUrl(address _addressTo, string calldata _metadataUrl) external virtual override {
        require(
            _addressTo == msg.sender || msg.sender == owner(),
            'UserRegistry::updateMetadataUrl: Sender must be owner or the same user to update metadata.'
        );
        metadataUrls[_addressTo] = _metadataUrl;
        emit MetadataUrlChanged(_addressTo, _metadataUrl);
    }

    uint256[49] private __gap;
}
