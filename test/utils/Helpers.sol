// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { Types } from "./../../src/modules/invoice-module/libraries/Types.sol";
import { Test } from "forge-std/Test.sol";

library Helpers {
    function createInvoiceDataType(address recipient) public view returns (Types.Invoice memory) {
        return Types.Invoice({
            recipient: recipient,
            status: Types.Status.Pending,
            startTime: 0,
            endTime: uint40(block.timestamp) + 1 weeks,
            payment: Types.Payment({
                method: Types.Method.Transfer,
                recurrence: Types.Recurrence.OneOff,
                paymentsLeft: 1,
                asset: address(0),
                amount: uint128(1 ether),
                streamId: 0
            })
        });
    }

    /// @dev Calculates the number of payments that must be done based on a Recurring invoice
    function computeNumberOfRecurringPayments(
        Types.Recurrence recurrence,
        uint40 interval
    ) internal pure returns (uint40 numberOfPayments) {
        if (recurrence == Types.Recurrence.Weekly) {
            numberOfPayments = interval / 1 weeks;
        } else if (recurrence == Types.Recurrence.Monthly) {
            numberOfPayments = interval / 4 weeks;
        } else if (recurrence == Types.Recurrence.Yearly) {
            numberOfPayments = interval / 48 weeks;
        }
    }
}
