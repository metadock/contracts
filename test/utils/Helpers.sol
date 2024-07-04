// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types as InvoiceModulesTypes } from "./../../src/modules/invoice-module/libraries/Types.sol";

library Helpers {
    function createInvoiceDataType(address recipient) public view returns (InvoiceModulesTypes.Invoice memory) {
        return
            InvoiceModulesTypes.Invoice({
                recipient: recipient,
                status: InvoiceModulesTypes.Status.Active,
                frequency: InvoiceModulesTypes.Frequency.Regular,
                startTime: 0,
                endTime: uint40(block.timestamp) + 150,
                payment: InvoiceModulesTypes.Payment({
                    recurrence: InvoiceModulesTypes.Recurrence.OneTime,
                    method: InvoiceModulesTypes.Method.Transfer,
                    amount: 1 ether,
                    asset: address(0),
                    paymentsLeft: 1
                })
            });
    }
}
