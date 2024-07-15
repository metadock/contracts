// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ExcessivelySafeCall } from "@nomad-xyz/excessively-safe-call/src/ExcessivelySafeCall.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title Container
/// @notice A mock non-compliant container contract that do not support the {IContainer} interface
contract MockNonCompliantContainer is IERC165 {
    using ExcessivelySafeCall for address;

    address public owner;

    event ModuleExecutionSucceded(address module, uint256 value, bytes data);
    event ModuleExecutionFailed(address module, uint256 value, bytes data, bytes error);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        _;
    }

    function execute(address module, uint256 value, bytes memory data) external onlyOwner returns (bool success) {
        // Allocate all the gas to the executed module method
        uint256 txGas = gasleft();

        // Execute the call via assembly to avoid returnbomb attacks
        // See https://github.com/nomad-xyz/ExcessivelySafeCall
        //
        // Account for the returned data only if the `_success` boolean is false
        // in which case revert with the error message
        bytes memory result;
        (success, result) = module.excessivelySafeCall({ _gas: txGas, _value: 0, _maxCopy: 4, _calldata: data });

        if (!success) {
            emit ModuleExecutionFailed(module, value, data, result);

            // Revert with the error
            assembly {
                revert(add(result, 0x20), result)
            }
        } else emit ModuleExecutionSucceded(module, value, data);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
