// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "./Types.sol";

/// @title Errors
/// @notice Library containing all custom errors the {InvoiceModule} may revert with
library Errors {
    error NotContainer();
    error InvalidPayer();
    error InvalidInvoiceId();
    error InvalidTimeInterval();
    error InvalidPaymentType();
    error PaymentFailed();
    error InvalidInvoiceStatus(Types.Status currentStatus);
}
