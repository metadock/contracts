// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONTAINER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when `msg.sender` is not the {Container} contract owner
    error Unauthorized();

    /// @notice Thrown when a native token (ETH) withdrawal fails
    error NativeWithdrawFailed();

    /// @notice Thrown when the available native token (ETH) balance is lower than
    /// the amount requested to be withdrawn
    error InsufficientNativeToWithdraw();

    /// @notice Thrown when the available ERC-20 token balance is lower than
    /// the amount requested to be withdrawn
    error InsufficientERC20ToWithdraw();

    /// @notice Thrown when the deposited ERC-20 token address is zero
    error InvalidAssetZeroAddress();

    /// @notice Thrown when the deposited ERC-20 token amount is zero
    error InvalidAssetZeroAmount();

    /*//////////////////////////////////////////////////////////////////////////
                                  MODULE-MANAGER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the requested module to be enabled is not a contract
    error InvalidZeroCodeModule();

    /// @notice Thrown when a container tries to execute a method on a non-enabled module
    error ModuleNotEnabled();

    /*//////////////////////////////////////////////////////////////////////////
                                    INVOICE-MODULE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the caller is an invalid zero code contract or EOA
    error ContainerZeroCodeSize();

    /// @notice Thrown when the caller is a contract that does not implement the {IContainer} interface
    error ContainerUnsupportedInterface();

    /// @notice Thrown when the end time of an invoice is in the past
    error EndTimeLowerThanCurrentTime();

    /// @notice Thrown when the start time is later than the end time
    error StartTimeGreaterThanEndTime();

    /// @notice Thrown when the payment amount set for a new invoice is zero
    error ZeroPaymentAmount();

    /// @notice Thrown when the payment amount is less than the invoice value
    error PaymentAmountLessThanInvoiceValue(uint256 amount);

    /// @notice Thrown when a payment in the native token (ETH) fails
    error NativeTokenPaymentFailed();

    /// @notice Thrown when the number of recurring payments set for a recurring transfer invoice is invalid
    error InvalidNumberOfPayments(uint40 expectedNumber);

    /// @notice Thrown when a linear or tranched stream is created with the native token as the payment asset
    error OnlyERC20StreamsAllowed();

    /// @notice Thrown when a payer attempts to pay an invoice that has already been paid
    error InvoiceAlreadyPaid();

    /// @notice Thrown when a payer attempts to pay a canceled invoice
    error InvoiceCanceled();

    /*//////////////////////////////////////////////////////////////////////////
                                    STREAM-MANAGER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the caller is not the broker admin
    error OnlyBrokerAdmin();
}
