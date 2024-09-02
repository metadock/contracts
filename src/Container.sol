// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import { ExcessivelySafeCall } from "@nomad-xyz/excessively-safe-call/src/ExcessivelySafeCall.sol";

import { IContainer } from "./interfaces/IContainer.sol";
import { ModuleManager } from "./abstracts/ModuleManager.sol";
import { IModuleManager } from "./interfaces/IModuleManager.sol";
import { Errors } from "./libraries/Errors.sol";
import { ModuleKeeper } from "./ModuleKeeper.sol";
import { DockRegistry } from "./DockRegistry.sol";

/// @title Container
/// @notice See the documentation in {IContainer}
contract Container is IContainer, ModuleManager {
    using SafeERC20 for IERC20;
    using ExcessivelySafeCall for address;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the address of the {Container} owner, {ModuleKeeper} and enables the initial module(s)
    constructor(
        DockRegistry _dockRegistry,
        address[] memory _initialModules
    ) ModuleManager(_dockRegistry, _initialModules) {
        dockRegistry = _dockRegistry;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if the `msg.sender` is not the owner of the {Container} assigned in the registry
    modifier onlyOwner() {
        if (msg.sender != dockRegistry.ownerOfContainer(address(this))) revert Errors.CallerNotContainerOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IContainer
    function execute(
        address module,
        uint256 value,
        bytes memory data
    ) public onlyOwner onlyEnabledModule(module) returns (bool success) {
        // Allocate all the gas to the executed module method
        uint256 txGas = gasleft();

        // Execute the call via assembly and get only the first 4 bytes of the returndata
        // which will be the selector of the error in case of a revert in the module contract
        // See https://github.com/nomad-xyz/ExcessivelySafeCall
        bytes memory result;
        (success, result) = module.excessivelySafeCall({ _gas: txGas, _value: 0, _maxCopy: 4, _calldata: data });

        // Revert with the same error returned by the module contract if the call failed
        if (!success) {
            assembly {
                revert(add(result, 0x20), 4)
            }
            // Otherwise log the execution success
        } else {
            emit ModuleExecutionSucceded(module, value, data);
        }
    }

    /// @inheritdoc IContainer
    function withdrawERC20(IERC20 asset, uint256 amount) public onlyOwner {
        // Checks: the available ERC20 balance of the container is greater enough to support the withdrawal
        if (amount > asset.balanceOf(address(this))) revert Errors.InsufficientERC20ToWithdraw();

        // Interactions: withdraw by transferring the amount to the sender
        asset.safeTransfer({ to: msg.sender, value: amount });

        // Log the successful ERC-20 token withdrawal
        emit AssetWithdrawn({ to: msg.sender, asset: address(asset), amount: amount });
    }

    /// @inheritdoc IContainer
    function withdrawERC721(IERC721 collection, uint256 tokenId) public onlyOwner {
        // Interactions: withdraw by transferring the token to the sender
        // We're using `safeTransferFrom` as the owner can be an ERC-4337 smart account
        // therefore the `onERC721Received` hook must be implemented
        collection.safeTransferFrom(address(this), msg.sender, tokenId);

        // Log the successful ERC-721 token withdrawal
        emit ERC721Withdrawn({ to: msg.sender, collection: address(collection), tokenId: tokenId });
    }

    /// @inheritdoc IContainer
    function withdrawNative(uint256 amount) public onlyOwner {
        // Checks: the native balance of the container minus the amount locked for operations is greater than the requested amount
        if (amount > address(this).balance) revert Errors.InsufficientNativeToWithdraw();

        // Interactions: withdraw by transferring the amount to the sender
        (bool success,) = msg.sender.call{ value: amount }("");
        // Revert if the call failed
        if (!success) revert Errors.NativeWithdrawFailed();

        // Log the successful native token withdrawal
        emit AssetWithdrawn({ to: msg.sender, asset: address(0), amount: amount });
    }

    /// @inheritdoc IModuleManager
    function enableModule(address module) public override onlyOwner {
        super.enableModule(module);
    }

    /// @inheritdoc IModuleManager
    function disableModule(address module) public override onlyOwner {
        super.disableModule(module);
    }

    /// @dev Allow container to receive native token (ETH)
    receive() external payable {
        // Log the successful native token deposit
        emit NativeReceived({ from: msg.sender, amount: msg.value });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(IContainer).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    /// @inheritdoc IERC721Receiver
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // Log the successful ERC-721 token receipt
        emit ERC721Received(from, tokenId);

        return this.onERC721Received.selector;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155Received(
        address,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata
    ) external override returns (bytes4) {
        // Log the successful ERC-1155 token receipt
        emit ERC1155Received(from, id, value);

        return this.onERC1155Received.selector;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata
    ) external override returns (bytes4) {
        for (uint256 i; i < ids.length; ++i) {
            // Log the successful ERC-1155 token receipt
            emit ERC1155Received(from, ids[i], values[i]);
        }

        return this.onERC1155BatchReceived.selector;
    }
}
