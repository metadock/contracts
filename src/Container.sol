// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { IContainer } from "./interfaces/IContainer.sol";
import { ModuleManager } from "./abstracts/ModuleManager.sol";
import { Ownable } from "./abstracts/Ownable.sol";
import { IModuleManager } from "./interfaces/IModuleManager.sol";
import { Errors } from "./libraries/Errors.sol";
import { ExcessivelySafeCall } from "@nomad-xyz/excessively-safe-call/src/ExcessivelySafeCall.sol";

/// @title Container
/// @notice See the documentation in {IContainer}
contract Container is IContainer, Ownable, ModuleManager {
    using SafeERC20 for IERC20;
    using ExcessivelySafeCall for address;

    /*//////////////////////////////////////////////////////////////////////////
                                  PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IContainer
    uint256 public override nativeLocked;

    /// @inheritdoc IContainer
    mapping(IERC20 asset => uint256) public override erc20Locked;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the address of the container owner and enables the initial module(s)
    constructor(address _owner, address[] memory _initialModules) Ownable(_owner) ModuleManager(_initialModules) {}

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
        } else emit ModuleExecutionSucceded(module, value, data);
    }

    /// @inheritdoc IContainer
    function withdrawERC20(IERC20 asset, uint256 amount) public onlyOwner {
        // Checks: the available ERC20 balance of the container is greater enough to support the withdrawal
        if (amount > asset.balanceOf(address(this)) - erc20Locked[asset]) revert Errors.InsufficientERC20ToWithdraw();

        // Interactions: withdraw by transferring the amount to the sender
        asset.safeTransfer({ to: msg.sender, value: amount });

        // Log the successful ERC-20 token withdrawal
        emit AssetWithdrawn({ sender: msg.sender, asset: address(asset), amount: amount });
    }

    /// @inheritdoc IContainer
    function withdrawNative(uint256 amount) public onlyOwner {
        // Checks: the native balance of the container minus the amount locked for operations is greater than the requested amount
        if (amount > address(this).balance - nativeLocked) revert Errors.InsufficientNativeToWithdraw();

        // Interactions: withdraw by transferring the amount to the sender
        (bool success, ) = payable(msg.sender).call{ value: amount }("");
        // Revert if the call failed
        if (!success) revert Errors.NativeWithdrawFailed();

        // Log the successful native token withdrawal
        emit AssetWithdrawn({ sender: msg.sender, asset: address(0), amount: amount });
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
        emit NativeDeposited({ sender: msg.sender, amount: msg.value });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(IContainer).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
