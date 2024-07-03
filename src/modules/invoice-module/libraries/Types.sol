// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library Types {
    // frequency: recurring between 1 January - 1 March (2 months)
    // recurrence: weekly
    // method: transfer
    enum Recurrence {
        OneTime,
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
        uint24 paymentsLeft;
        address asset;
        // slot 1
        uint256 amount;
    }

    enum Frequency {
        Regular,
        Recurring
    }

    enum Status {
        Active,
        Paid,
        Canceled
    }

    struct Invoice {
        // slot 0
        address recipient;
        Status status;
        Frequency frequency;
        uint40 startTime;
        uint40 endTime;
        // slot 1 and 2
        Payment payment;
    }
}
