// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { ModuleManager_Unit_Concrete_Test } from "../ModuleManager.t.sol";
import { Events } from "../../../../utils/Events.sol";
import { MockModule } from "../../../../mocks/MockModule.sol";

contract DisableModule_Unit_Concrete_Test is ModuleManager_Unit_Concrete_Test {
    function setUp() public virtual override {
        ModuleManager_Unit_Concrete_Test.setUp();
    }

    modifier givenModuleEnabled() {
        // Create a new mock module
        MockModule mockModule = new MockModule();

        // Enable the {MockModule} first
        moduleManager.enableModule({ module: address(mockModule) });
        _;
    }

    function test_DisableModule() external givenModuleEnabled {
        // Expect the {ModuleDisabled} to be emitted
        vm.expectEmit();
        emit Events.ModuleDisabled({ module: address(mockModule), owner: address(this) });

        // Run the test
        moduleManager.disableModule({ module: address(mockModule) });

        // Assert the module enablement state
        bool isModuleEnabled = moduleManager.isModuleEnabled({ module: address(mockModule) });
        assertFalse(isModuleEnabled);
    }
}
