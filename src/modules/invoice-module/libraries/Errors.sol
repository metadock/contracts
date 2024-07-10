// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Errors
/// @notice Library containing all custom errors the {InvoiceModule} may revert with
library Errors {
    error ContainerZeroCodeSize();
    error ContainerUnsupportedInterface();
    error InvalidPayer();
    error EndTimeLowerThanCurrentTime();
    error StartTimeGreaterThanEndTime();
    error InvalidPaymentType();
    error PaymentAmountZero();
    error InvalidPaymentAmount(uint256 amount);
    error PaymentFailed();
    error InvalidNumberOfPayments(uint40 expectedNumber);
    error OnlyBrokerAdmin();
    error OnlyERC20StreamsAllowed();
    error InvoiceAlreadyPaid();
    error InvoiceCanceled();
}
