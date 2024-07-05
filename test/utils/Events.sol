// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @notice Abstract contract to store all the events emitted in the tested contracts
abstract contract Events {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONTAINER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an `amount` amount of `asset` ERC-20 asset is deposited on the container
    /// @param sender The address of the depositor
    /// @param asset The address of the deposited ERC-20 token
    /// @param amount The amount of the deposited ERC-20 token
    event AssetDeposited(address indexed sender, address indexed asset, uint256 amount);

    /// @notice Emitted when an `amount` amount of `asset` ERC-20 asset is withdrawn from the container
    /// @param sender The address to which the tokens were transferred
    /// @param asset The address of the withdrawn ERC-20 token
    /// @param amount The amount of the withdrawn ERC-20 token
    event AssetWithdrawn(address indexed sender, address indexed asset, uint256 amount);

    /// @notice Emitted when a module execution fails
    /// @param module The address of the module that was executed
    /// @param value The value sent to the module address required for the call
    /// @param data The ABI-encoded method called on the module
    event ModuleExecutionFailed(address indexed module, uint256 value, bytes data);

    /// @notice Emitted when a module execution is successful
    /// @param module The address of the module that was executed
    /// @param value The value sent to the module address required for the call
    /// @param data The ABI-encoded method called on the module
    event ModuleExecutionSucceded(address indexed module, uint256 value, bytes data);

    /*//////////////////////////////////////////////////////////////////////////
                                MODULE-MANAGER
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a module is enabled on the container
    /// @param module The address of the enabled module
    event ModuleEnabled(address indexed module);

    /// @notice Emitted when a module is disabled on the container
    /// @param module The address of the disabled module
    event ModuleDisabled(address indexed module);
}
