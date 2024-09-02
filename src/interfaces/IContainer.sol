// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

/// @title IContainer
/// @notice Contract that provides functionalities to store native token (ETH) value and any ERC-20 tokens, allowing
/// external modules to be executed by extending its core functionalities
interface IContainer is IERC165, IERC721Receiver, IERC1155Receiver {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an `amount` amount of `asset` native tokens (ETH) is deposited on the container
    /// @param from The address of the depositor
    /// @param amount The amount of the deposited ERC-20 token
    event NativeReceived(address indexed from, uint256 amount);

    /// @notice Emitted when an ERC-721 token is received by the container
    /// @param from The address of the depositor
    /// @param tokenId The ID of the received token
    event ERC721Received(address indexed from, uint256 indexed tokenId);

    /// @notice Emitted when an ERC-1155 token is received by the container
    /// @param from The address of the depositor
    /// @param id The ID of the received token
    /// @param value The amount of tokens received
    event ERC1155Received(address indexed from, uint256 indexed id, uint256 value);

    /// @notice Emitted when an `amount` amount of `asset` ERC-20 asset or native ETH is withdrawn from the container
    /// @param to The address to which the tokens were transferred
    /// @param asset The address of the ERC-20 token or zero-address for native ETH
    /// @param amount The withdrawn amount
    event AssetWithdrawn(address indexed to, address indexed asset, uint256 amount);

    /// @notice Emitted when an ERC-721 token is withdrawn from the container
    /// @param to The address to which the token was transferred
    /// @param collection The address of the ERC-721 collection
    /// @param tokenId The ID of the token
    event ERC721Withdrawn(address indexed to, address indexed collection, uint256 tokenId);

    /// @notice Emitted when an ERC-1155 token is withdrawn from the container
    /// @param to The address to which the tokens were transferred
    /// @param id The ID of the token
    /// @param value The amount of the tokens withdrawn
    event ERC1155Withdrawn(address indexed to, address indexed collection, uint256 id, uint256 value);

    /// @notice Emitted when a module execution is successful
    /// @param module The address of the module
    /// @param value The value sent to the module required for the call
    /// @param data The ABI-encoded method called on the module
    event ModuleExecutionSucceded(address indexed module, uint256 value, bytes data);

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Executes a call on the `module` module, proving the `value` wei amount for the ABI-encoded `data` method
    /// @param module The address of the module to call
    /// @param value The amount of wei to provide
    /// @param data The ABI-encode definition of the method (+inputs) to call
    function execute(address module, uint256 value, bytes memory data) external returns (bool success);

    /// @notice Withdraws an `amount` amount of `asset` ERC-20 token from the container
    ///
    /// Requirements:
    /// - `msg.sender` must be the owner of the container
    ///
    /// @param asset The address of the ERC-20 token to withdraw
    /// @param amount The amount of the ERC-20 token to withdraw
    function withdrawERC20(IERC20 asset, uint256 amount) external;

    /// @notice Withdraws the `tokenId` token from the ERC-721 `collection` collection
    ///
    /// Requirements:
    /// - `msg.sender` must be the owner of the container
    ///
    /// @param collection The address of the ERC-721 collection
    /// @param tokenId The ID of the token to withdraw
    function withdrawERC721(IERC721 collection, uint256 tokenId) external;

    /// @notice Withdraws an `amount` amount of native token (ETH) from the container
    ///
    /// Requirements:
    /// - `msg.sender` must be the owner of the container
    ///
    /// @param amount The amount of the native token to withdraw
    function withdrawNative(uint256 amount) external;
}
