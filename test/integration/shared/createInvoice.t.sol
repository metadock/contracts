// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Integration_Test } from "../Integration.t.sol";
import { Types } from "./../../../src/modules/invoice-module/libraries/Types.sol";

abstract contract CreateInvoice_Integration_Shared_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
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
    function createInvoiceWithOneOffTransfer(
        address asset,
        address recipient
    ) internal view returns (Types.Invoice memory invoice) {
        invoice.recipient = recipient;
        invoice.status = Types.Status.Pending;

        invoice.startTime = uint40(block.timestamp);
        invoice.endTime = uint40(block.timestamp) + 4 weeks;

        invoice.payment = Types.Payment({
            method: Types.Method.Transfer,
            recurrence: Types.Recurrence.OneOff,
            paymentsLeft: 1,
            asset: asset,
            amount: 100e18,
            streamId: 0
        });
    }

    /// @dev Creates an invoice with a recurring transfer payment
    function createInvoiceWithRecurringTransfer(
        Types.Recurrence recurrence,
        address recipient
    ) internal view returns (Types.Invoice memory invoice) {
        invoice.recipient = recipient;
        invoice.status = Types.Status.Pending;

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
    function createInvoiceWithLinearStream(address recipient) internal view returns (Types.Invoice memory invoice) {
        invoice.recipient = recipient;
        invoice.status = Types.Status.Pending;

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
    function createInvoiceWithTranchedStream(
        Types.Recurrence recurrence,
        address recipient
    ) internal view returns (Types.Invoice memory invoice) {
        invoice.recipient = recipient;
        invoice.status = Types.Status.Pending;

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

    function executeCreateInvoice(Types.Invoice memory invoice, address user) public {
        // Make the `user` account the caller who must be the owner of the {Container} contract
        vm.startPrank({ msgSender: user });

        // Create the invoice
        bytes memory data = abi.encodeWithSignature(
            "createInvoice((address,uint8,uint40,uint40,(uint8,uint8,uint40,address,uint128,uint256)))",
            invoice
        );
        container.execute({ module: address(invoiceModule), value: 0, data: data });

        // Stop the active prank
        vm.stopPrank();
    }
}
