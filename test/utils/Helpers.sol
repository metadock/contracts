// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types as InvoiceModuleTypes } from "./../../src/modules/invoice-module/libraries/Types.sol";

library Helpers {
    function createInvoiceDataType(address recipient) public view returns (InvoiceModuleTypes.Invoice memory) {
        return
            InvoiceModuleTypes.Invoice({
                recipient: recipient,
                status: InvoiceModuleTypes.Status.Pending,
                startTime: 0,
                endTime: uint40(block.timestamp) + 1 weeks,
                payment: InvoiceModuleTypes.Payment({
                    method: InvoiceModuleTypes.Method.Transfer,
                    recurrence: InvoiceModuleTypes.Recurrence.OneOff,
                    paymentsLeft: 1,
                    asset: address(0),
                    amount: uint128(1 ether),
                    streamId: 0
                })
            });
    }

    /// @dev Calculates the number of payments that must be done based on a Recurring invoice
    function computeNumberOfRecurringPayments(
        InvoiceModuleTypes.Recurrence recurrence,
        uint40 interval
    ) internal pure returns (uint40 numberOfPayments) {
        if (recurrence == InvoiceModuleTypes.Recurrence.Weekly) {
            numberOfPayments = interval / 1 weeks;
        } else if (recurrence == InvoiceModuleTypes.Recurrence.Monthly) {
            numberOfPayments = interval / 4 weeks;
        } else if (recurrence == InvoiceModuleTypes.Recurrence.Yearly) {
            numberOfPayments = interval / 48 weeks;
        }
    }
}
