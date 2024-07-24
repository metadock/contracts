// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract MockBadReceiver {
    receive() external payable {
        revert();
    }
}
