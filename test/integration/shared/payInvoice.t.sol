// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Integration_Test } from "../Integration.t.sol";
import { CreateInvoice_Integration_Shared_Test } from "./createInvoice.t.sol";
import { Types } from "./../../../src/modules/invoice-module/libraries/Types.sol";

abstract contract PayInvoice_Integration_Shared_Test is Integration_Test, CreateInvoice_Integration_Shared_Test {
    mapping(uint256 invoiceId => Types.Invoice) invoices;

    function setUp() public virtual override(Integration_Test, CreateInvoice_Integration_Shared_Test) {
        CreateInvoice_Integration_Shared_Test.setUp();
    }

    function createMockInvoices() internal {
        // Create a mock invoice with a one-off USDT transfer
        Types.Invoice memory invoice = createInvoiceWithOneOffTransfer({ asset: address(usdt), recipient: users.eve });
        invoices[1] = invoice;
        executeCreateInvoice({ invoice: invoice, user: users.eve });

        // Create a mock invoice with a one-off ETH transfer
        invoice = createInvoiceWithOneOffTransfer({ asset: address(0), recipient: users.eve });
        invoices[2] = invoice;
        executeCreateInvoice({ invoice: invoice, user: users.eve });

        // Create a mock invoice with a recurring USDT transfer
        invoice = createInvoiceWithRecurringTransfer({ recurrence: Types.Recurrence.Weekly, recipient: users.eve });
        invoices[3] = invoice;
        executeCreateInvoice({ invoice: invoice, user: users.eve });

        // Create a mock invoice with a linear stream payment
        invoice = createInvoiceWithLinearStream({ recipient: users.eve });
        invoices[4] = invoice;
        executeCreateInvoice({ invoice: invoice, user: users.eve });

        // Create a mock invoice with a tranched stream payment
        invoice = createInvoiceWithTranchedStream({ recurrence: Types.Recurrence.Weekly, recipient: users.eve });
        invoices[5] = invoice;
        executeCreateInvoice({ invoice: invoice, user: users.eve });
    }

    modifier whenInvoiceNotNull() {
        _;
    }

    modifier whenInvoiceNotAlreadyPaid() {
        _;
    }

    modifier whenInvoiceNotCanceled() {
        _;
    }

    modifier givenPaymentMethodTransfer() {
        _;
    }

    modifier givenPaymentAmountInNativeToken() {
        _;
    }

    modifier givenPaymentAmountInERC20Tokens() {
        _;
    }

    modifier whenPaymentAmountEqualToInvoiceValue() {
        _;
    }

    modifier whenNativeTokenPaymentSucceeds() {
        _;
    }
}
