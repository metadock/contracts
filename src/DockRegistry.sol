// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { Ownable } from "./abstracts/Ownable.sol";
import { IDockRegistry } from "./interfaces/IDockRegistry.sol";
import { Container } from "./Container.sol";
import { ModuleKeeper } from "./ModuleKeeper.sol";
import { Errors } from "./libraries/Errors.sol";

/// @title DockRegistry
/// @notice See the documentation in {IDockRegistry}
contract DockRegistry is IDockRegistry, Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IDockRegistry
    ModuleKeeper public override moduleKeeper;

    /// @inheritdoc IDockRegistry
    mapping(uint256 dockId => address owner) public override ownerOfDock;

    /// @inheritdoc IDockRegistry
    mapping(address container => uint256 dockId) public override dockIdOfContainer;

    /// @inheritdoc IDockRegistry
    mapping(address container => address owner) public override ownerOfContainer;

    /*//////////////////////////////////////////////////////////////////////////
                                   PRIVATE STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Counter to keep track of the next dock ID
    uint256 private _dockNextId;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the address of the {ModuleKeeper} contract, registry owner and sets the next dock ID to start from 1
    constructor(address _initialOwner, ModuleKeeper _moduleKeeper) Ownable(_initialOwner) {
        _dockNextId = 1;
        moduleKeeper = _moduleKeeper;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IDockRegistry
    function createContainer(
        uint256 dockId,
        address owner,
        address[] calldata initialModules
    ) public returns (address container) {
        // Checks: a new dock must be created first
        if (dockId == 0) {
            // Store the ID of the next dock
            dockId = _dockNextId;

            // Effects: set the owner of the freshly created dock
            ownerOfDock[dockId] = msg.sender;

            // Effects: increment the next dock ID
            // Use unchecked because the dock ID cannot realistically overflow
            unchecked {
                _dockNextId++;
            }
        } else {
            // Checks: `msg.sender` is the dock owner
            if (ownerOfDock[dockId] != msg.sender) {
                revert Errors.CallerNotDockOwner();
            }
        }

        // Interactions: deploy a new {Container}
        container =
            address(new Container({ _dockRegistry: DockRegistry(address(this)), _initialModules: initialModules }));

        // Assign the ID of the dock to which the new container belongs
        dockIdOfContainer[container] = dockId;

        // Assign the owner of the container
        ownerOfContainer[container] = owner;

        // Log the {Container} creation
        emit ContainerCreated(owner, dockId, container, initialModules);
    }

    /// @inheritdoc IDockRegistry
    function transferContainerOwnership(address container, address newOwner) external {
        // Checks: `msg.sender` is the current owner of the {Container}
        address currentOwner = ownerOfContainer[container];
        if (msg.sender != currentOwner) {
            revert Errors.CallerNotContainerOwner();
        }

        // Checks: the new owner is not the zero address
        if (newOwner == address(0)) {
            revert Errors.InvalidOwnerZeroAddress();
        }

        // Effects: update container's ownership
        ownerOfContainer[container] = newOwner;

        // Log the ownership transfer
        emit ContainerOwnershipTransferred({ container: container, oldOwner: currentOwner, newOwner: newOwner });
    }

    /// @inheritdoc IDockRegistry
    function transferDockOwnership(uint256 dockId, address newOwner) external {
        // Checks: `msg.sender` is the current owner of the dock
        address currentOwner = ownerOfDock[dockId];
        if (msg.sender != currentOwner) {
            revert Errors.CallerNotDockOwner();
        }

        // Effects: update dock's ownership
        ownerOfDock[dockId] = newOwner;

        // Log the ownership transfer
        emit DockOwnershipTransferred({ dockId: dockId, oldOwner: currentOwner, newOwner: newOwner });
    }

    /// @inheritdoc IDockRegistry
    function updateModuleKeeper(ModuleKeeper newModuleKeeper) external onlyOwner {
        // Effects: update the {ModuleKeeper} address
        moduleKeeper = newModuleKeeper;

        // Log the update
        emit ModuleKeeperUpdated(newModuleKeeper);
    }
}
