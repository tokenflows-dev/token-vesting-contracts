// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "./LinearVestingProjectUpgradeable.sol";
import "./LinearVestingProjectBeacon.sol";

contract LinearVestingProjectFactoryUpgradeable is OwnableUpgradeable {

    address[] private projects;
    uint public projectsCount;
    LinearVestingProjectBeacon beacon;

    /**
    * @dev Emitted when a new project is created.
     */
    event ProjectCreated(
        uint indexed index,
        address indexed projectAddress,
        address indexed tokenAddress,
        string name
    );

    function __LinearVestingProjectFactory_initialize(address _initBlueprint) public initializer onlyInitializing {
        __Ownable_init();
        __LinearVestingProjectFactory_initialize_unchained(_initBlueprint);
    }

    function __LinearVestingProjectFactory_initialize_unchained(address _initBlueprint) public onlyInitializing {
        beacon = new LinearVestingProjectBeacon(_initBlueprint);
    }

    function createProject(
        address _token,
        string calldata _name
    ) external returns (address) {
        BeaconProxy project = new BeaconProxy(
            address(beacon),
            abi.encodeWithSelector(
                LinearVestingProjectUpgradeable(address(0)).__LinearVestingProject_initialize.selector,
                _token
            )
        );
        address newProjectAddress = address(project);
        projects.push(newProjectAddress);
        projectsCount++;

        emit ProjectCreated(
            projectsCount,
            newProjectAddress,
            _token,
            _name
        );

        return newProjectAddress;
    }

    function getImplementation() public view returns (address) {
        return beacon.implementation();
    }

    function getBeacon() public view returns (address) {
        return address(beacon);
    }

    function getProjectAddress(uint projectIndex) external view returns (address) {
        return projects[projectIndex];
    }

    function getProjects() external view returns (address[] memory) {
        return projects;
    }

    uint256[50] private __gap;
}
