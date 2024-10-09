// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

/// @notice Namespace for the structs used across the Invoice Module contracts
library Types {
    /// @notice Enum representing the different recurrences a payment can have
    /// @custom:value OneOff One single payment that must be made either as a single transfer or through a linear stream
    /// @custom:value Weekly Multiple weekly payments that must be made either by transfer or a tranched stream
    /// @custom:value Monthly Multiple weekly payments that must be made either by transfer or tranched stream
    /// @custom:value Yearly Multiple weekly payments that must be made either by transfer or tranched stream
    enum Recurrence {
        OneOff,
        Weekly,
        Monthly,
        Yearly
    }

    /// @notice Enum representing the different payment methods an invoice can have
    /// @custom:value Transfer Payment method must be made through a transfer
    /// @custom:value LinearStream Payment method must be made through a linear stream
    /// @custom:value TranchedStream Payment method must be made through a tranched stream
    enum Method {
        Transfer,
        LinearStream,
        TranchedStream
    }

    /// @notice Struct encapsulating the different values describing a payment
    /// @param method The payment method
    /// @param recurrence The payment recurrence
    /// @param paymentsLeft The number of payments required to fully settle the invoice (only for transfer or tranched stream based invoices)
    /// @param asset The address of the payment asset
    /// @param amount The amount that must be paid
    /// @param streamId The ID of the linear or tranched stream if payment method is either `LinearStream` or `TranchedStream`, otherwise 0
    struct Payment {
        // slot 0
        Method method;
        Recurrence recurrence;
        uint40 paymentsLeft;
        address asset;
        // slot 1
        uint128 amount;
        // slot 2
        uint256 streamId;
    }

    /// @notice Enum representing the different statuses an invoice can have
    /// @custom:value Pending Invoice waiting to be paid
    /// @custom:value Ongoing Invoice is being paid; if the payment method is a One-Off Transfer, the invoice status will
    /// automatically be set to `Paid`. Otherwise, it will remain `Ongoing` until the invoice is fully paid.
    /// @custom:value Canceled Invoice cancelled by the recipient (if Transfer-based) or stream sender
    enum Status {
        Pending,
        Ongoing,
        Paid,
        Canceled
    }

    /// @notice Struct encapsulating the different values describing an invoice
    /// @param recipient The address of the payee
    /// @param status The status of the invoice
    /// @param startTime The unix timestamp indicating when the invoice payment starts
    /// @param endTime The unix timestamp indicating when the invoice payment ends
    /// @param payment The payment struct describing the invoice payment
    struct Invoice {
        // slot 0
        Status status;
        uint40 startTime;
        uint40 endTime;
        // slot 1, 2 and 3
        Payment payment;
    }
}
