// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IContainer } from "./interfaces/IContainer.sol";
import { ModuleManager } from "./ModuleManager.sol";
import { IModuleManager } from "./interfaces/IModuleManager.sol";
import { Errors } from "./libraries/Errors.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

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
    constructor(address _owner, IModule[] memory _initialModules) ModuleManager(_initialModules) {
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
    function enableModule(address module) public override onlyOwner {
        super.enableModule(module);
    }

    /// @inheritdoc IContainer
    function execute(address module, uint256 value, bytes memory data) external onlyOwner returns (bool success) {
        uint256 txGas = type(uint256).max;
        assembly {
            success := call(txGas, module, value, add(data, 0x20), mload(data), 0, 0)
        }

        if (success) emit ModuleExecutionSucceded(module, value, data);
        else emit ModuleExecutionFailed(module, value, data);
    }

    /// @inheritdoc IContainer
    function depositERC20(IERC20 asset, uint256 amount) external {
        asset.safeTransferFrom({ from: msg.sender, to: address(this), value: amount });

        emit AssetDeposited({ sender: msg.sender, asset: address(asset), amount: amount });
    }

    /// @inheritdoc IContainer
    function withdrawERC20(IERC20 asset, uint256 amount) external onlyOwner {
        // Checks: the ERC20 balance of the container minus the amount locked for operations is greater than the requested amount
        if (amount > asset.balanceOf(address(this)) - erc20Locked[asset]) revert Errors.InsufficientNativeToWithdraw();

        // Effects: withdraw to sender
        asset.safeTransferFrom({ from: address(this), to: msg.sender, value: amount });

        emit AssetWithdrawn({ sender: msg.sender, asset: address(asset), amount: amount });
    }

    /// @inheritdoc IContainer
    function withdrawNative(uint256 amount) external onlyOwner {
        // Checks: the native balance of the container minus the amount locked for operations is greater than the requested amount
        if (amount > address(this).balance - nativeLocked) revert Errors.InsufficientNativeToWithdraw();

        // Effects: withdraw to sender
        (bool success, ) = payable(msg.sender).call{ value: amount }("");
        if (!success) revert Errors.NativeWithdrawFailed();
    }

    /// @dev Allow container to receive native token (ETH)
    receive() external payable {
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
