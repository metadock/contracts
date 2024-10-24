// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { Types } from "./../../src/modules/invoice-module/libraries/Types.sol";
import { Workspace } from "./../../src/Workspace.sol";
import { ModuleKeeper } from "./../../src/ModuleKeeper.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";

/// @notice Abstract contract to store all the events emitted in the tested contracts
abstract contract Events {
    /*//////////////////////////////////////////////////////////////////////////
                                    DOCK-REGISTRY
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new {Workspace} contract gets deployed
    /// @param owner The address of the owner
    /// @param dockId The ID of the dock to which this {Workspace} belongs
    /// @param workspace The address of the {Workspace}
    /// @param initialModules Array of initially enabled modules
    event WorkspaceCreated(
        address indexed owner, uint256 indexed dockId, Workspace workspace, address[] initialModules
    );

    /// @notice Emitted when the ownership of a {Workspace} is transferred to a new owner
    /// @param workspace The address of the {Workspace}
    /// @param oldOwner The address of the current owner
    /// @param newOwner The address of the new owner
    event WorkspaceOwnershipTransferred(Workspace indexed workspace, address oldOwner, address newOwner);

    /// @notice Emitted when the ownership of a {Dock} is transferred to a new owner
    /// @param dockId The address of the {Dock}
    /// @param oldOwner The address of the current owner
    /// @param newOwner The address of the new owner
    event DockOwnershipTransferred(uint256 indexed dockId, address oldOwner, address newOwner);

    /// @notice Emitted when the {ModuleKeeper} address is updated
    /// @param newModuleKeeper The new address of the {ModuleKeeper}
    event ModuleKeeperUpdated(ModuleKeeper newModuleKeeper);

    /// @dev Emitted when the contract has been initialized or reinitialized
    event Initialized(uint64 version);

    /// @dev Emitted when the implementation is upgraded
    event Upgraded(address indexed implementation);

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTAINER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an `amount` amount of `asset` native tokens (ETH) is deposited on the workspace
    /// @param from The address of the depositor
    /// @param amount The amount of the deposited ERC-20 token
    event NativeReceived(address indexed from, uint256 amount);

    /// @notice Emitted when an ERC-721 token is received by the workspace
    /// @param from The address of the depositor
    /// @param tokenId The ID of the received token
    event ERC721Received(address indexed from, uint256 indexed tokenId);

    /// @notice Emitted when an ERC-1155 token is received by the workspace
    /// @param from The address of the depositor
    /// @param id The ID of the received token
    /// @param value The amount of tokens received
    event ERC1155Received(address indexed from, uint256 indexed id, uint256 value);

    /// @notice Emitted when an `amount` amount of `asset` ERC-20 asset or native ETH is withdrawn from the workspace
    /// @param to The address to which the tokens were transferred
    /// @param asset The address of the ERC-20 token or zero-address for native ETH
    /// @param amount The withdrawn amount
    event AssetWithdrawn(address indexed to, address indexed asset, uint256 amount);

    /// @notice Emitted when an ERC-721 token is withdrawn from the workspace
    /// @param to The address to which the token was transferred
    /// @param collection The address of the ERC-721 collection
    /// @param tokenId The ID of the token
    event ERC721Withdrawn(address indexed to, address indexed collection, uint256 tokenId);

    /// @notice Emitted when an ERC-1155 token is withdrawn from the workspace
    /// @param to The address to which the tokens were transferred
    /// @param ids The IDs of the tokens
    /// @param amounts The amounts of the tokens
    event ERC1155Withdrawn(address indexed to, address indexed collection, uint256[] ids, uint256[] amounts);

    /// @notice Emitted when a module execution is successful
    /// @param module The address of the module
    /// @param value The value sent to the module required for the call
    /// @param data The ABI-encoded method called on the module
    event ModuleExecutionSucceded(address indexed module, uint256 value, bytes data);

    /*//////////////////////////////////////////////////////////////////////////
                                MODULE-MANAGER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a module is enabled on the workspace
    /// @param module The address of the enabled module
    event ModuleEnabled(address indexed module, address indexed owner);

    /// @notice Emitted when a module is disabled on the workspace
    /// @param module The address of the disabled module
    event ModuleDisabled(address indexed module, address indexed owner);

    /*//////////////////////////////////////////////////////////////////////////
                                    INVOICE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a regular or recurring invoice is created
    /// @param id The ID of the invoice
    /// @param recipient The address receiving the payment
    /// @param status The status of the invoice
    /// @param startTime The timestamp when the invoice takes effect
    /// @param endTime The timestamp by which the invoice must be paid
    /// @param payment Struct representing the payment details associated with the invoice
    event InvoiceCreated(
        uint256 id,
        address indexed recipient,
        Types.Status status,
        uint40 startTime,
        uint40 endTime,
        Types.Payment payment
    );

    /// @notice Emitted when an invoice is paid
    /// @param id The ID of the invoice
    /// @param payer The address of the payer
    /// @param status The status of the invoice
    /// @param payment Struct representing the payment details associated with the invoice
    event InvoicePaid(uint256 indexed id, address indexed payer, Types.Status status, Types.Payment payment);

    /// @notice Emitted when an invoice is canceled
    /// @param id The ID of the invoice
    event InvoiceCanceled(uint256 indexed id);

    /// @notice Emitted when the broker fee is updated
    /// @param oldFee The old broker fee
    /// @param newFee The new broker fee
    event BrokerFeeUpdated(UD60x18 oldFee, UD60x18 newFee);

    /*//////////////////////////////////////////////////////////////////////////
                                    OWNABLE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the address of the owner is updated
    /// @param oldOwner The address of the previous owner
    /// @param newOwner The address of the new owner
    event OwnershipTransferred(address indexed oldOwner, address newOwner);

    /*//////////////////////////////////////////////////////////////////////////
                                  MODULE-KEEPER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new module is allowlisted
    /// @param owner The address of the {ModuleKeeper} owner
    /// @param module The address of the module to be allowlisted
    event ModuleAllowlisted(address indexed owner, address indexed module);

    /// @notice Emitted when a module is removed from the allowlist
    /// @param owner The address of the {ModuleKeeper} owner
    /// @param module The address of the module to be removed
    event ModuleRemovedFromAllowlist(address indexed owner, address indexed module);
}
