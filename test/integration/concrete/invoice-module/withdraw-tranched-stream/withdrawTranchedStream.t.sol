// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { WithdrawTranchedStream_Integration_Shared_Test } from "../../../shared/withdrawTranchedStream.t.sol";

contract WithdrawTranchedStream_Integration_Concret_Test is WithdrawTranchedStream_Integration_Shared_Test {
    function setUp() public virtual override {
        WithdrawTranchedStream_Integration_Shared_Test.setUp();
    }

    function test_WithdrawTranchedStream() external givenPaymentMethodTranchedStream givenInvoiceStatusOngoing {
        // Set current invoice as a tranched stream-based one
        uint256 invoiceId = 4;
        uint256 streamId = 1;

        // The invoice must be paid for its status to be updated to `Ongoing`
        // Make Bob the payer of the invoice (also Bob will be the initial stream sender)
        vm.startPrank({ msgSender: users.bob });

        // Approve the {InvoiceModule} to transfer the USDT tokens on Bob's behalf
        usdt.approve({ spender: address(invoiceModule), amount: invoices[invoiceId].payment.amount });

        // Pay the invoice first (status will be updated to `Ongoing`)
        invoiceModule.payInvoice{ value: invoices[invoiceId].payment.amount }({ id: invoiceId });

        // Advance the timestamp by 3 weeks to simulate the withdrawal
        vm.warp(block.timestamp + 3 weeks);

        // Store Eve's balance before withdrawing the USDT tokens
        uint256 balanceOfBefore = usdt.balanceOf(users.eve);

        // Get the maximum withdrawable amount from the stream
        uint128 maxWithdrawableAmount = sablierV2LockupTranched.withdrawableAmountOf(streamId);

        // Make Eve the caller in this test suite as she's the recipient of the invoice
        vm.startPrank({ msgSender: users.eve });

        // Run the test
        invoiceModule.withdrawTranchedStream({ streamId: streamId, to: users.eve });

        // Assert the current and expected USDT balance of Eve
        assertEq(balanceOfBefore + maxWithdrawableAmount, usdt.balanceOf(users.eve));
    }
}
