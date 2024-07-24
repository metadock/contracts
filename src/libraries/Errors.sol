// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONTAINER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when `msg.sender` is not the {Container} contract owner
    error Unauthorized();

    /// @notice Thrown when a native token (ETH) withdrawal fails
    error NativeWithdrawFailed();

    /// @notice Thrown when the available native token (ETH) balance is lower than
    /// the amount requested to be withdrawn
    error InsufficientNativeToWithdraw();

    /// @notice Thrown when the available ERC-20 token balance is lower than
    /// the amount requested to be withdrawn
    error InsufficientERC20ToWithdraw();

    /// @notice Thrown when the deposited ERC-20 token address is zero
    error InvalidAssetZeroAddress();

    /// @notice Thrown when the deposited ERC-20 token amount is zero
    error InvalidAssetZeroAmount();

    /*//////////////////////////////////////////////////////////////////////////
                                  MODULE-MANAGER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the requested module to be enabled is not a contract
    error InvalidZeroCodeModule();

    /// @notice Thrown when a container tries to execute a method on a non-enabled module
    error ModuleNotEnabled();
}
