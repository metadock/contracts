// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { ModuleManager_Unit_Concrete_Test } from "../ModuleManager.t.sol";
import { Events } from "../../../../utils/Events.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { MockModule } from "../../../../mocks/MockModule.sol";

contract EnableModule_Unit_Concrete_Test is ModuleManager_Unit_Concrete_Test {
    function setUp() public virtual override {
        ModuleManager_Unit_Concrete_Test.setUp();
    }

    function test_RevertWhen_InvalidZeroCodeModule() external {
        // Expect the next call to revert with the {InvalidZeroCodeModule}
        vm.expectRevert(Errors.InvalidZeroCodeModule.selector);

        // Run the test
        moduleManager.enableModule({ module: address(0x1) });
    }

    modifier whenNonZeroCodeModule() {
        _;
    }

    function test_EnableModule() external whenNonZeroCodeModule {
        // Create a new mock module
        MockModule mockModule = new MockModule();

        // Expect the {ModuleEnabled} to be emitted
        vm.expectEmit();
        emit Events.ModuleEnabled({ module: address(mockModule) });

        // Run the test
        moduleManager.enableModule({ module: address(mockModule) });

        // Assert the module enablement state
        bool isModuleEnabled = moduleManager.isModuleEnabled({ module: address(mockModule) });
        assertTrue(isModuleEnabled);
    }
}
