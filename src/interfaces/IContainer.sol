// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IContainer
/// @notice Contract that provides functionalities to store native token (ETH) value and any ERC-20 tokens, allowing
/// external modules to be executed by extending its core functionalities
interface IContainer is IERC165 {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
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

    /// @notice Emitted when a module execution is successful
    /// @param module The address of the module that was executed
    /// @param value The value sent to the module address required for the call
    /// @param data The ABI-encoded method called on the module
    event ModuleExecutionSucceded(address indexed module, uint256 value, bytes data);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the amount of native token (ETH) locked in the container for current/upcoming operations
    function nativeLocked() external view returns (uint256 balance);

    /// @notice Retrieves the amount of `asset` ERC-20 asset locked in the container for current/upcoming operations
    /// @param asset The address of the ERC-20 token
    /// @return balance The amount of ERC-20 token locked
    function erc20Locked(IERC20 asset) external view returns (uint256 balance);

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Executes a call on the `module` module, proving the `value` wei amount for the ABI-encoded `data` method
    /// @param module The address of the module to call
    /// @param value The amount of wei to provide
    /// @param data The ABI-encode definition of the method (+inputs) to call
    function execute(address module, uint256 value, bytes memory data) external returns (bool success);

    /// @notice Deposits an `amount` amount of `asset` ERC-20 token to the container
    ///
    /// Notes:
    /// - `msg.sender` IS NOT enforced to be the owner of the container
    ///
    /// @param asset The address of the ERC-20 token to deposit
    /// @param amount The amount of the ERC-20 token to deposit
    function depositERC20(IERC20 asset, uint256 amount) external;

    /// @notice Withdraws an `amount` amount of `asset` ERC-20 token from the container
    ///
    /// Requirements:
    /// - `msg.sender` must be the owner of the container
    ///
    /// @param asset The address of the ERC-20 token to withdraw
    /// @param amount The amount of the ERC-20 token to withdraw
    function withdrawERC20(IERC20 asset, uint256 amount) external;

    /// @notice Withdraws an `amount` amount of native token (ETH) from the container
    ///
    /// Requirements:
    /// - `msg.sender` must be the owner of the container
    ///
    /// @param amount The amount of the native token to withdraw
    function withdrawNative(uint256 amount) external;
}
