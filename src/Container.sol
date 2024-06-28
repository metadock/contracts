// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IContainer } from "./interfaces/IContainer.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Container
/// @notice See the documentation in {IContainer}
contract Container is IContainer {
  using SafeERC20 for IERC20;

  address owner;
  uint256 nativeLocked;
  mapping(IERC20 asset => uint256) erc20Locked;

  event AssetDeposited(address indexed sender, address indexed asset, uint256 amount);
  event AssetWithdrawn(address indexed sender, address indexed asset, uint256 amount);

  error Unauthorized();
  error NativeWithdrawFailed();
  error InsufficientNativeToWithdraw();
  error InsufficientERC20ToWithdraw();

  constructor(address _owner) {
    _owner = owner;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) revert Unauthorized();
    _;
  }

  function execute() external onlyOwner {}

  /// @notice Deposits an `amount` amount of `asset` ERC-20 token to the container
  function depositERC20(IERC20 asset, uint256 amount) external {
    asset.safeTransferFrom({ from: msg.sender, to: address(this), value: amount });

    emit AssetDeposited({ sender: msg.sender, asset: address(asset), amount: amount });
  }

  /// @notice Withdraws an `amount` amount of `asset` ERC-20 token from the container
  function withdrawERC20(IERC20 asset, uint256 amount) external onlyOwner {
    // Checks: the ERC20 balance of the container minus the amount locked for operations is greater than the requested amount
    if (amount > asset.balanceOf(address(this)) - erc20Locked[asset]) revert InsufficientNativeToWithdraw();

    // Effects: withdraw to sender
    asset.safeTransferFrom({ from: address(this), to: msg.sender, value: amount });

    emit AssetWithdrawn({ sender: msg.sender, asset: address(asset), amount: amount });
  }

  /// @notice Withdraws an `amount` amount of native token (ETH) from the container
  function withdrawNative(uint256 amount) external onlyOwner {
    // Checks: the native balance of the container minus the amount locked for operations is greater than the requested amount
    if (amount > address(this).balance - nativeLocked) revert InsufficientNativeToWithdraw();

    // Effects: withdraw to sender
    (bool success, ) = payable(msg.sender).call{ value: amount }("");
    if (!success) revert NativeWithdrawFailed();
  }

  /// @dev Allow container to receive native token (ETH)
  receive() external payable {
    emit AssetDeposited({ sender: msg.sender, asset: address(0), amount: msg.value });
  }
}
