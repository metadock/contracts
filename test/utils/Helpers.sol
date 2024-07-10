// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types as InvoiceModulesTypes } from "./../../src/modules/invoice-module/libraries/Types.sol";

library Helpers {
    function createInvoiceDataType(address recipient) public view returns (InvoiceModulesTypes.Invoice memory) {
        return
            InvoiceModulesTypes.Invoice({
                recipient: recipient,
                status: InvoiceModulesTypes.Status.Pending,
                frequency: InvoiceModulesTypes.Frequency.Regular,
                startTime: 0,
                endTime: uint40(block.timestamp) + 1 weeks,
                payment: InvoiceModulesTypes.Payment({
                    method: InvoiceModulesTypes.Method.Transfer,
                    recurrence: InvoiceModulesTypes.Recurrence.OneTime,
                    paymentsLeft: 1,
                    asset: address(0),
                    amount: uint128(1 ether)
                })
            });
    }
}
