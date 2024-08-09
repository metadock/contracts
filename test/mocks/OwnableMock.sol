// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Ownable } from "./../../src/abstracts/Ownable.sol";

/// @title OwnableMock
/// @notice A mock implementation that uses the `onlyOwner` auth mechanism
contract OwnableMock is Ownable {
    constructor(address _owner) Ownable(_owner) { }
}
