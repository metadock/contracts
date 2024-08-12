// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { CreateInvoice_Integration_Shared_Test } from "../../shared/createInvoice.t.sol";
import { Types } from "./../../../../src/modules/invoice-module/libraries/Types.sol";
import { Helpers } from "./../../../../src/modules/invoice-module/libraries/Helpers.sol";
import { Events } from "../../../utils/Events.sol";

contract CreateInvoice_Transfer_Integration_Fuzz_Test is CreateInvoice_Integration_Shared_Test {
    Types.Invoice invoice;

    function setUp() public virtual override {
        CreateInvoice_Integration_Shared_Test.setUp();

        // Make Eve the caller in this test suite as she's the owner of the {Container} contract
        vm.startPrank({ msgSender: users.eve });
    }

    function testFuzz_CreateInvoice_Transfer(
        uint8 recurrence,
        address recipient,
        uint40 startTime,
        uint40 endTime,
        uint128 amount
    )
        external
        whenCallerContract
        whenCompliantContainer
        whenNonZeroPaymentAmount
        whenStartTimeLowerThanEndTime
        whenEndTimeInTheFuture
        givenPaymentMethodLinearStream
        whenPaymentAssetNotNativeToken
    {
        // Discard the bad fuzz inputs
        recurrence = uint8(bound(recurrence, uint8(Types.Recurrence.OneOff), uint8(Types.Recurrence.Yearly)));
        vm.assume(recipient != address(0) && recipient != address(this));
        vm.assume(startTime >= uint40(block.timestamp) && startTime < endTime);
        vm.assume(amount > 0);

        // Check if the interval is too short for the fuzzed recurrence
        uint40 numberOfPayments =
            Helpers.computeNumberOfPayments({ recurrence: Types.Recurrence(recurrence), interval: endTime - startTime });
        if (numberOfPayments == 0) return;

        // Create a new invoice with a linear stream payment
        invoice = createFuzzedInvoice(
            Types.Method.Transfer, Types.Recurrence(recurrence), recipient, startTime, endTime, amount
        );

        // Create the calldata for the Invoice Module execution
        bytes memory data = abi.encodeWithSignature(
            "createInvoice((address,uint8,uint40,uint40,(uint8,uint8,uint40,address,uint128,uint256)))", invoice
        );

        // Expect the module call to emit an {InvoiceCreated} event
        vm.expectEmit();
        emit Events.InvoiceCreated({
            id: 0,
            recipient: recipient,
            status: Types.Status.Pending,
            startTime: invoice.startTime,
            endTime: invoice.endTime,
            payment: invoice.payment
        });

        // Expect the {Container} contract to emit a {ModuleExecutionSucceded} event
        vm.expectEmit();
        emit Events.ModuleExecutionSucceded({ module: address(invoiceModule), value: 0, data: data });

        // Run the test
        container.execute({ module: address(invoiceModule), value: 0, data: data });

        // Assert the actual and expected invoice state
        Types.Invoice memory actualInvoice = invoiceModule.getInvoice({ id: 0 });
        assertEq(actualInvoice.recipient, recipient);
        assertEq(uint8(actualInvoice.status), uint8(Types.Status.Pending));
        assertEq(actualInvoice.startTime, invoice.startTime);
        assertEq(actualInvoice.endTime, invoice.endTime);
        assertEq(uint8(actualInvoice.payment.method), uint8(invoice.payment.method));
        assertEq(uint8(actualInvoice.payment.recurrence), uint8(invoice.payment.recurrence));
        assertEq(actualInvoice.payment.asset, invoice.payment.asset);
        assertEq(actualInvoice.payment.amount, invoice.payment.amount);
        assertEq(actualInvoice.payment.streamId, 0);
    }
}
