// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { WithdrawLinearStream_Integration_Shared_Test } from "../../../shared/withdrawLinearStream.t.sol";
import { Types } from "./../../../../../src/modules/invoice-module/libraries/Types.sol";

contract WithdrawLinearStream_Integration_Concret_Test is WithdrawLinearStream_Integration_Shared_Test {
    function setUp() public virtual override {
        WithdrawLinearStream_Integration_Shared_Test.setUp();
    }

    function test_WithdrawStream_LinearStream() external givenPaymentMethodLinearStream givenInvoiceStatusOngoing {
        // Set current invoice as a linear stream-based one
        uint256 invoiceId = 4;
        uint256 streamId = 1;

        // The invoice must be paid in order to update its status to `Ongoing`
        // Make Bob the payer of the invoice (also Bob will be the initial stream sender)
        vm.startPrank({ msgSender: users.bob });

        // Approve the {InvoiceModule} to transfer the USDT tokens on Bob's behalf
        usdt.approve({ spender: address(invoiceModule), amount: invoices[invoiceId].payment.amount });

        // Pay the invoice first (status will be updated to `Ongoing`)
        invoiceModule.payInvoice{ value: invoices[invoiceId].payment.amount }({ id: invoiceId });

        // Advance the timestamp by 5 weeks to simulate the withdrawal
        vm.warp(block.timestamp + 5 weeks);

        // Store Eve's container balance before withdrawing the USDT tokens
        uint256 balanceOfBefore = usdt.balanceOf(address(container));

        // Get the maximum withdrawable amount from the stream
        uint128 maxWithdrawableAmount =
            invoiceModule.withdrawableAmountOf({ streamType: Types.Method.LinearStream, streamId: streamId });

        // Make Eve's container the caller in this test suite as his container is the recipient of the invoice
        vm.startPrank({ msgSender: address(container) });

        // Run the test
        invoiceModule.withdrawInvoiceStream(invoiceId);

        // Assert the current and expected USDT balance of Eve
        assertEq(balanceOfBefore + maxWithdrawableAmount, usdt.balanceOf(address(container)));
    }

    function test_WithdrawStream_TranchedStream() external givenPaymentMethodTranchedStream givenInvoiceStatusOngoing {
        // Set current invoice as a tranched stream-based one
        uint256 invoiceId = 5;
        uint256 streamId = 1;

        // The invoice must be paid for its status to be updated to `Ongoing`
        // Make Bob the payer of the invoice (also Bob will be the initial stream sender)
        vm.startPrank({ msgSender: users.bob });

        // Approve the {InvoiceModule} to transfer the USDT tokens on Bob's behalf
        usdt.approve({ spender: address(invoiceModule), amount: invoices[invoiceId].payment.amount });

        // Pay the invoice first (status will be updated to `Ongoing`)
        invoiceModule.payInvoice{ value: invoices[invoiceId].payment.amount }({ id: invoiceId });

        // Advance the timestamp by 5 weeks to simulate the withdrawal
        vm.warp(block.timestamp + 5 weeks);

        // Store Eve's container balance before withdrawing the USDT tokens
        uint256 balanceOfBefore = usdt.balanceOf(address(container));

        // Get the maximum withdrawable amount from the stream
        uint128 maxWithdrawableAmount =
            invoiceModule.withdrawableAmountOf({ streamType: Types.Method.TranchedStream, streamId: streamId });

        // Make Eve's container the caller in this test suite as her container is the owner of the invoice
        vm.startPrank({ msgSender: address(container) });

        // Run the test
        invoiceModule.withdrawInvoiceStream(invoiceId);

        // Assert the current and expected USDT balance of Eve's container
        assertEq(balanceOfBefore + maxWithdrawableAmount, usdt.balanceOf(address(container)));
    }
}
