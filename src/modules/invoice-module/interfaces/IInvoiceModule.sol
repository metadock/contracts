// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "./../libraries/Types.sol";

/// @title IInvoiceModule
/// @notice Contract module that provides functionalities to issue and pay an on-chain invoice
interface IInvoiceModule {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a regular or recurring invoice is created
    /// @param id The ID of the invoice
    /// @param invoice The details of the invoice following the {Invoice} struct format
    event InvoiceCreated(uint256 indexed id, Types.Invoice invoice);

    /// @notice Emitted when a regular or recurring invoice is paid
    /// @param id The ID of the invoice
    /// @param payer The address of the payer
    event InvoicePaid(uint256 indexed id, address indexed payer);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the details of the `id` invoice
    /// @param id The ID of the invoice for which to get the details
    function getInvoice(uint256 id) external view returns (Types.Invoice memory invoice);

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new invoice
    ///
    /// Requirements:
    /// - `msg.sender` must be a contract implementing the {IContainer} interface
    ///
    /// Notes:
    /// - `recipient` is not checked because the call is enforced to be made through a {Container} contract
    ///
    /// @param invoice The details of the invoice following the {Invoice} struct format
    /// @return id The on-chain ID of the invoice
    function createInvoice(Types.Invoice calldata invoice) external returns (uint256 id);

    /// @notice Pays a transfer-based invoice
    ///
    /// Notes:
    /// - `msg.sender` is enforced to be a specific payer address
    ///
    /// @param id The ID of the invoice to pay
    function payInvoice(uint256 id) external payable;
}
