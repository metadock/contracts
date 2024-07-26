// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { IModuleManager } from "../interfaces/IModuleManager.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title ModuleManager
/// @notice See the documentation in {IModuleManager}
abstract contract ModuleManager is IModuleManager {
    /*//////////////////////////////////////////////////////////////////////////
                                  PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IModuleManager
    mapping(address module => bool) public override isModuleEnabled;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the `_initialModules` initial module(s) enabled on a container
    constructor(address[] memory _initialModules) {
        _enableBatchModules(_initialModules);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Reverts if the `module` module is not enabled on the container
    modifier onlyEnabledModule(address module) {
        if (!isModuleEnabled[module]) {
            revert Errors.ModuleNotEnabled();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IModuleManager
    function enableModule(address module) public virtual {
        _enableModule(module);
    }

    /// @inheritdoc IModuleManager
    function disableModule(address module) public virtual {
        _disableModule(module);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Enables multiple modules at the same time
    function _enableBatchModules(address[] memory modules) internal {
        for (uint256 i; i < modules.length; ++i) {
            _enableModule(modules[i]);
        }
    }

    /// @dev Enables one single module at a time
    function _enableModule(address module) internal {
        // Check: invalid module due to zero-code size
        if (module.code.length == 0) {
            revert Errors.InvalidZeroCodeModule();
        }

        // Effect: enable the module
        isModuleEnabled[module] = true;

        // Log the module enablement
        emit ModuleEnabled({ module: module, owner: msg.sender });
    }

    /// @dev Disables one single module at a time
    function _disableModule(address module) internal {
        // Effect: disable the module
        isModuleEnabled[module] = false;

        // Log the module disablement
        emit ModuleDisabled({ module: module, owner: msg.sender });
    }
}
