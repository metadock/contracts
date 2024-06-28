// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library InvoiceModuleTypes {
    enum Recurrence {
        OneTime,
        Daily,
        Weekly,
        Monthly,
        Yearly
    }

    enum Method {
        Transfer,
        Stream
    }

    struct Payment {
        // slot 0
        Method method;
        Recurrence recurrence;
        // slot 1
        uint256 amount;
        // slot 2
        address asset;
    }

    enum Frequency {
        Regular,
        Recurring
    }

    enum Status {
        Active,
        Paid,
        Expired,
        Canceled,
        Rejected
    }

    struct Invoice {
        // slot 0
        Status status; // 1 byte
        Frequency frequency; // 1 byte
        uint40 startTime; // 5 bytes
        uint40 endTime; // 5 bytes
        // slot 1
        address payer; // 32 bytes
        // slot 2, 3 and 4
        Payment payment;
    }
}
