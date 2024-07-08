// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base_Test } from "../../../../Base.t.sol";
import { Events } from "../../../../utils/Events.sol";
import { ModuleManager } from "./../../../../../src/ModuleManager.sol";

contract Constructor_Unit_Concrete_Test is Base_Test {
    ModuleManager internal moduleManager;

    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function test_Constructor() external {
        // Expect the {ModuleEnabled} event to be emitted
        vm.expectEmit();
        emit Events.ModuleEnabled({ module: address(invoiceModule) });

        // Expect the {ModuleEnabled} event to be emitted
        vm.expectEmit();
        emit Events.ModuleEnabled({ module: address(mockModule) });

        // Create the initial modules array
        address[] memory modules = new address[](2);
        modules[0] = address(invoiceModule);
        modules[1] = address(mockModule);

        // Deploy the {ModuleManager} with the `modules` initial modules enabled
        moduleManager = new ModuleManager({ _initialModules: modules });

        // Assert the modules enablement state
        assertTrue(moduleManager.isModuleEnabled({ module: address(invoiceModule) }));
        assertTrue(moduleManager.isModuleEnabled({ module: address(mockModule) }));
    }
}