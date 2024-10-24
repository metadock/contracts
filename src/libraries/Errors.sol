// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                  DOCK-REGISTRY
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when `msg.sender` is not the dock owner
    error CallerNotDockOwner();

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTAINER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when `msg.sender` is not the {Workspace} contract owner
    error CallerNotWorkspaceOwner();

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

    /// @notice Thrown when `msg.sender` is not an approved target
    error CallerNotApprovedTarget();

    /// @notice Thrown when the provided `modules`, `values` or `data` arrays have different lengths
    error WrongArrayLengths();

    /*//////////////////////////////////////////////////////////////////////////
                                  MODULE-MANAGER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when a {Workspace} tries to execute a method on a non-enabled module
    error ModuleNotEnabled(address module);

    /// @notice Thrown when an attempt is made to enable a non-allowlisted module on a {Workspace}
    error ModuleNotAllowlisted();

    /*//////////////////////////////////////////////////////////////////////////
                                  MODULE-KEEPER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the requested module to be allowlisted is not a valid non-zero code size contract
    error InvalidZeroCodeModule();

    /*//////////////////////////////////////////////////////////////////////////
                                      OWNABLE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when attempting to transfer ownership to the zero address
    error InvalidOwnerZeroAddress();

    /// @notice Thrown when `msg.sender` is not the contract owner
    error Unauthorized();
}
