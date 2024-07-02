// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with
library Errors {
    error Unauthorized();
    error NativeWithdrawFailed();
    error InsufficientNativeToWithdraw();
    error InsufficientERC20ToWithdraw();
}
