// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IContainer } from "./../../src/interfaces/IContainer.sol";
import { Errors } from "./../../src/modules/invoice-module/libraries/Errors.sol";

/// @notice A mock implementation of a boilerplate module that creates multiple items and
/// associates them with the corresponding {Container} contract
contract MockModule {
    mapping(address container => uint256[]) private _moduleItemsOf;

    uint256 private _nextModuleItemId;

    event ModuleItemCreated(uint256 indexed id);

    /// @dev Allow only calls from contracts implementing the {IContainer} interface
    modifier onlyContainer() {
        // Checks: the sender is a valid non-zero code size contract
        if (msg.sender.code.length == 0) {
            revert Errors.ContainerZeroCodeSize();
        }

        // Checks: the sender implements the ERC-165 interface required by {IContainer}
        bytes4 interfaceId = type(IContainer).interfaceId;
        if (!IERC165(msg.sender).supportsInterface(interfaceId)) revert Errors.ContainerUnsupportedInterface();
        _;
    }

    function createModuleItem() external onlyContainer returns (uint256 id) {
        // Get the next module item ID
        id = _nextModuleItemId;

        _moduleItemsOf[msg.sender].push(id);

        unchecked {
            _nextModuleItemId = id + 1;
        }

        emit ModuleItemCreated(id);
    }
}
