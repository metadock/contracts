// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { Types } from "./../../src/modules/invoice-module/libraries/Types.sol";

/// @notice Abstract contract to store all the events emitted in the tested contracts
abstract contract Events {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONTAINER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an `amount` amount of `asset` native tokens (ETH) is deposited on the container
    /// @param sender The address of the depositor
    /// @param amount The amount of the deposited ERC-20 token
    event NativeDeposited(address indexed sender, uint256 amount);

    /// @notice Emitted when an `amount` amount of `asset` ERC-20 asset is withdrawn from the container
    /// @param sender The address to which the tokens were transferred
    /// @param asset The address of the withdrawn ERC-20 token
    /// @param amount The amount of the withdrawn ERC-20 token
    event AssetWithdrawn(address indexed sender, address indexed asset, uint256 amount);

    /// @notice Emitted when a module execution is successful
    /// @param module The address of the module that was executed
    /// @param value The value sent to the module address required for the call
    /// @param data The ABI-encoded method called on the module
    event ModuleExecutionSucceded(address indexed module, uint256 value, bytes data);

    /*//////////////////////////////////////////////////////////////////////////
                                MODULE-MANAGER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a module is enabled on the container
    /// @param module The address of the enabled module
    event ModuleEnabled(address indexed module, address indexed owner);

    /// @notice Emitted when a module is disabled on the container
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
