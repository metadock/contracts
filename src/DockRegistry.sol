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
    ModuleKeeper public immutable override moduleKeeper;

    /// @inheritdoc IDockRegistry
    mapping(uint256 dockId => address owner) public override ownerOfDock;

    /// @inheritdoc IDockRegistry
    mapping(Container container => uint256 dockId) public override dockIdOfContainer;

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

    /// @dev Initializes the address of the {ModuleKeeper} contract and sets the next dock ID to start from 1
    constructor(address initialAdmin, ModuleKeeper _moduleKeeper) Ownable(initialAdmin) {
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
        address[] memory initialModules
    ) public returns (Container container) {
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
                revert Errors.SenderNotDockOwner();
            }
        }

        // Interactions: deploy a new {Container}
        container = new Container({ _dockRegistry: DockRegistry(address(this)), _initialModules: initialModules });

        // Assign the ID of the dock to which the new container belongs
        dockIdOfContainer[container] = _dockNextId;

        // Assign the owner of the container
        ownerOfContainer[address(container)] = owner;

        // Log the {Container} creation
        emit ContainerCreated(owner, dockId, container, initialModules);
    }

    /// @inheritdoc IDockRegistry
    function transferContainerOwnership(Container container, address newOwner) external {
        // Checks: `msg.sender` is the current owner of the {Container}
        if (msg.sender != ownerOfContainer[address(container)]) {
            revert Errors.SenderNotContainerOwner();
        }

        // Effects: store the current owner to emit in the event
        // and update in the ownership mapping
        address owner = ownerOfContainer[address(container)];
        ownerOfContainer[address(container)] = newOwner;

        // Log the ownership transfer
        emit ContainerOwnershipTransferred({ container: container, oldOwner: owner, newOwner: newOwner });
    }
}
