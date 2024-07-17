// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Integration_Test } from "../Integration.t.sol";
import { CreateInvoice_Integration_Shared_Test } from "./createInvoice.t.sol";
import { Types } from "./../../../src/modules/invoice-module/libraries/Types.sol";

abstract contract PayInvoice_Integration_Shared_Test is Integration_Test, CreateInvoice_Integration_Shared_Test {
    mapping(uint256 invoiceId => Types.Invoice) invoices;

    function setUp() public virtual override(Integration_Test, CreateInvoice_Integration_Shared_Test) {
        CreateInvoice_Integration_Shared_Test.setUp();
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
