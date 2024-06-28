// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IModuleManager } from "./interfaces/IModuleManager.sol";
import { IModule } from "./interfaces/IModule.sol";

contract ModuleManager is IModuleManager {
    mapping(IModule module => bool) public override isModuleEnabled;

    event ModuleEnabled(IModule indexed module);

    constructor(IModule[] memory _initialModules) {
        _enableBatchModules(_initialModules);
    }

    function enableModule(IModule module) public {
        isModuleEnabled[module] = true;

        emit ModuleEnabled({ module: module });
    }

    function _enableBatchModules(IModule[] memory modules) internal {
        for (uint256 i; i < modules.length; ++i) {
            enableModule(modules[i]);
        }
    }
}
