// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Types } from "./Types.sol";

/// @title Helpers
/// @notice Library with helpers used across the Invoice Module contracts
library Helpers {
    /// @dev Calculates the number of payments that must be done based on a Recurring invoice
    function computeNumberOfRecurringPayments(
        Types.Recurrence recurrence,
        uint40 startTime,
        uint40 endTime
    ) internal pure returns (uint40 numberOfPayments) {
        uint40 interval = endTime - startTime;

        if (recurrence == Types.Recurrence.Weekly) {
            numberOfPayments = interval / 1 weeks;
        } else if (recurrence == Types.Recurrence.Monthly) {
            numberOfPayments = interval / 4 weeks;
        } else if (recurrence == Types.Recurrence.Yearly) {
            numberOfPayments = interval / 48 weeks;
        }
    }
}
