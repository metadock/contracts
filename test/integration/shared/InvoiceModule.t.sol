// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Integration_Test } from "../Integration.t.sol";
import { Types } from "./../../../src/modules/invoice-module/libraries/Types.sol";

abstract contract InvoiceModule_Integration_Shared_Test is Integration_Test {
    Types.Invoice invoice;

    function setUp() public virtual override {
        Integration_Test.setUp();

        invoice.recipient = users.eve;
        invoice.status = Types.Status.Pending;
    }

    modifier whenCallerContract() {
        _;
    }

    modifier whenCompliantContainer() {
        _;
    }

    modifier whenNonZeroPaymentAmount() {
        _;
    }

    modifier whenStartTimeLowerThanEndTime() {
        _;
    }

    modifier whenEndTimeInTheFuture() {
        _;
    }

    modifier whenPaymentIntervalLongEnough() {
        _;
    }

    modifier whenTranchedStreamWithGoodRecurring() {
        _;
    }

    modifier whenPaymentAssetNotNativeToken() {
        _;
    }

    modifier givenPaymentMethodOneOffTransfer() {
        _;
    }

    modifier givenPaymentMethodRecurringTransfer() {
        _;
    }

    modifier givenPaymentMethodTranchedStream() {
        _;
    }

    modifier givenPaymentMethodLinearStream() {
        _;
    }

    /// @dev Creates an invoice with a one-off transfer payment
    function createInvoiceWithOneOffTransfer() internal {
        invoice.startTime = uint40(block.timestamp);
        invoice.endTime = uint40(block.timestamp) + 4 weeks;

        invoice.payment = Types.Payment({
            method: Types.Method.Transfer,
            recurrence: Types.Recurrence.OneOff,
            paymentsLeft: 1,
            asset: address(usdt),
            amount: 100e18,
            streamId: 0
        });
    }

    /// @dev Creates an invoice with a recurring transfer payment
    function createInvoiceWithRecurringTransfer(Types.Recurrence recurrence) internal {
        invoice.startTime = uint40(block.timestamp);
        invoice.endTime = uint40(block.timestamp) + 4 weeks;

        invoice.payment = Types.Payment({
            method: Types.Method.Transfer,
            recurrence: recurrence,
            paymentsLeft: 0,
            asset: address(usdt),
            amount: 100e18,
            streamId: 0
        });
    }

    /// @dev Creates an invoice with a linear stream-based payment
    function createInvoiceWithLinearStream() internal {
        invoice.startTime = uint40(block.timestamp);
        invoice.endTime = uint40(block.timestamp) + 4 weeks;

        invoice.payment = Types.Payment({
            method: Types.Method.LinearStream,
            recurrence: Types.Recurrence.Weekly, // doesn't matter
            paymentsLeft: 0,
            asset: address(usdt),
            amount: 100e18,
            streamId: 0
        });
    }

    /// @dev Creates an invoice with a tranched stream-based payment
    function createInvoiceWithTranchedStream(Types.Recurrence recurrence) internal {
        invoice.startTime = uint40(block.timestamp);
        invoice.endTime = uint40(block.timestamp) + 4 weeks;

        invoice.payment = Types.Payment({
            method: Types.Method.TranchedStream,
            recurrence: recurrence,
            paymentsLeft: 0,
            asset: address(usdt),
            amount: 100e18,
            streamId: 0
        });
    }
}
