// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Errors
/// @notice Library containing all custom errors the {InvoiceModule} and {StreamManager} may revert with
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                    INVOICE-MODULE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the caller is an invalid zero code contract or EOA
    error ContainerZeroCodeSize();

    /// @notice Thrown when the caller is a contract that does not implement the {IContainer} interface
    error ContainerUnsupportedInterface();

    /// @notice Thrown when the end time of an invoice is in the past
    error EndTimeInThePast();

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

    /// @notice Thrown when the payment interval (endTime - startTime) is too short for the selected recurrence
    /// i.e. recurrence is set to weekly but interval is shorter than 1 week
    error PaymentIntervalTooShortForSelectedRecurrence();

    /*//////////////////////////////////////////////////////////////////////////
                                    STREAM-MANAGER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the caller is not the broker admin
    error OnlyBrokerAdmin();
}
