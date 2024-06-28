// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IContainer {
  function depositERC20(IERC20 asset, uint256 amount) external;

  function withdrawERC20(IERC20 asset, uint256 amount) external;

  function withdrawNative(uint256 amount) external;
}
