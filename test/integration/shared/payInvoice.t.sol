// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Integration_Test } from "../Integration.t.sol";
import { CreateInvoice_Integration_Shared_Test } from "./createInvoice.t.sol";

abstract contract PayInvoice_Integration_Shared_Test is Integration_Test, CreateInvoice_Integration_Shared_Test {
    function setUp() public virtual override(Integration_Test, CreateInvoice_Integration_Shared_Test) {
        CreateInvoice_Integration_Shared_Test.setUp();
        createMockInvoices();
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
