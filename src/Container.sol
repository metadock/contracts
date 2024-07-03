// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { IContainer } from "./interfaces/IContainer.sol";
import { ModuleManager } from "./ModuleManager.sol";
import { IModuleManager } from "./interfaces/IModuleManager.sol";
import { Errors } from "./libraries/Errors.sol";

/// @title Container
/// @notice See the documentation in {IContainer}
contract Container is IContainer, ModuleManager {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  PRIVATE STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The address of the account that deployed this container
    address private owner;

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
    constructor(address _owner, address[] memory _initialModules) ModuleManager(_initialModules) {
        owner = _owner;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if the `msg.sender` is not the owner of the container
    modifier onlyOwner() {
        if (msg.sender != owner) revert Errors.Unauthorized();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IContainer
    function execute(address module, uint256 value, bytes memory data) external onlyOwner returns (bool _success) {
        // Allocate all the gas to the executed module method
        uint256 txGas = gasleft();

        // Execute the call via assembly to avoid returnbomb attacks
        // See https://github.com/nomad-xyz/ExcessivelySafeCall
        //
        // Do not account for the returned data but only for the `_success` boolean
        assembly {
            // See https://www.evm.codes/#f1?fork=cancun
            _success := call(txGas, module, value, add(data, 0x20), mload(data), 0, 0)
        }

        // Log the corresponding event whether the call was successful or not
        if (_success) emit ModuleExecutionSucceded(module, value, data);
        else emit ModuleExecutionFailed(module, value, data);
    }

    /// @inheritdoc IContainer
    function depositERC20(IERC20 asset, uint256 amount) external {
        // Checks: against the non-zero token address
        if (address(asset) == address(0)) {
            revert Errors.InvalidAssetZeroAddress();
        }

        // Checks: the amount is non-zero
        if (amount == 0) {
            revert Errors.InvalidAssetZeroAmount();
        }

        // Interactions: deposit by transferring the amount to the container address
        asset.safeTransferFrom({ from: msg.sender, to: address(this), value: amount });

        // Log the successful deposit
        emit AssetDeposited({ sender: msg.sender, asset: address(asset), amount: amount });
    }

    /// @inheritdoc IContainer
    function withdrawERC20(IERC20 asset, uint256 amount) external onlyOwner {
        // Checks: the available ERC20 balance of the container is greater enough to support the withdrawal
        if (amount > asset.balanceOf(address(this)) - erc20Locked[asset]) revert Errors.InsufficientNativeToWithdraw();

        // Interactions: withdraw by transferring the amount to the sender
        asset.safeTransferFrom({ from: address(this), to: msg.sender, value: amount });

        // Log the successful ERC-20 token withdrawal
        emit AssetWithdrawn({ sender: msg.sender, asset: address(asset), amount: amount });
    }

    /// @inheritdoc IContainer
    function withdrawNative(uint256 amount) external onlyOwner {
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

    /// @dev Allow container to receive native token (ETH)
    receive() external payable {
        // Log the successful native token deposit
        emit AssetDeposited({ sender: msg.sender, asset: address(0), amount: msg.value });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return
            interfaceId == type(IContainer).interfaceId ||
            interfaceId == type(IModuleManager).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
