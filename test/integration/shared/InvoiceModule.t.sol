// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Integration_Test } from "../Integration.t.sol";
import { Types } from "./../../../src/modules/invoice-module/libraries/Types.sol";
import { Helpers } from "../../utils/Helpers.sol";

abstract contract InvoiceModule_Integration_Shared_Test is Integration_Test {
    Types.Invoice invoice;

    function setUp() public virtual override {
        Integration_Test.setUp();

        invoice.recipient = users.eve;
        invoice.status = Types.Status.Pending;
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

        uint40 interval = invoice.endTime - invoice.startTime;
        uint40 numberOfPayments = Helpers.computeNumberOfRecurringPayments(recurrence, interval);

        invoice.payment = Types.Payment({
            method: Types.Method.Transfer,
            recurrence: recurrence,
            paymentsLeft: numberOfPayments,
            asset: address(usdt),
            amount: 100e18,
            streamId: 0
        });
    }
}
