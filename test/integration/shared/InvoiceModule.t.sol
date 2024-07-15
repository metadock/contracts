// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base_Test } from "../../Base.t.sol";
import { Types } from "./../../../src/modules/invoice-module/libraries/Types.sol";
import { Helpers } from "../../utils/Helpers.sol";

abstract contract InvoiceModule_Integration_Shared_Test is Base_Test {
    Types.Invoice _invoice;

    function setUp() public virtual override {
        Base_Test.setUp();

        _invoice.recipient = users.eve;
        _invoice.status = Types.Status.Pending;
    }

    /// @dev Creates an invoice with a one-off transfer payment
    function createInvoiceWithOneOffTransfer() internal {
        _invoice.startTime = uint40(block.timestamp);
        _invoice.endTime = uint40(block.timestamp) + 4 weeks;
        _invoice.payment = Types.Payment({
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
        _invoice.startTime = uint40(block.timestamp);
        _invoice.endTime = uint40(block.timestamp) + 4 weeks;

        uint40 interval = _invoice.endTime - _invoice.startTime;
        uint40 numberOfPayments = Helpers.computeNumberOfRecurringPayments(recurrence, interval);

        _invoice.payment = Types.Payment({
            method: Types.Method.Transfer,
            recurrence: recurrence,
            paymentsLeft: numberOfPayments,
            asset: address(usdt),
            amount: 100e18,
            streamId: 0
        });
    }
}
