// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title IUserRegistry
 * @dev This contract holds a record of the url to the metadata and user profiles.
 */
interface IUserRegistry {

    // @dev event emited every time a metadata is changed
    event MetadataUrlChanged(address indexed _address, string _metadataUrl);

   /**
    * @dev function to allow users to update their urls
    * @param _addressTo address in the registry where the metadata url change will be performed
    * @param _metadataUrl new metadata url
    */
    function updateMetadataUrl(address _addressTo, string calldata _metadataUrl) external;
}
