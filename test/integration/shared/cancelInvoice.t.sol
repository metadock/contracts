// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Integration_Test } from "../Integration.t.sol";
import { PayInvoice_Integration_Shared_Test } from "./payInvoice.t.sol";

abstract contract CancelInvoice_Integration_Shared_Test is Integration_Test, PayInvoice_Integration_Shared_Test {
    function setUp() public virtual override(Integration_Test, PayInvoice_Integration_Shared_Test) {
        PayInvoice_Integration_Shared_Test.setUp();
    }

    modifier whenInvoiceStatusNotPaid() {
        _;
    }

    modifier whenInvoiceStatusNotCanceled() {
        _;
    }

    modifier whenSenderInvoiceRecipient() {
        _;
    }

    modifier givenInvoiceStatusPending() {
        _;
    }

    modifier givenInvoiceStatusOngoing() {
        _;
    }

    modifier whenSenderInitialStreamSender() {
        _;
    }
}
