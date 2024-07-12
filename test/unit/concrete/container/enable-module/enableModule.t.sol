// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Container_Unit_Concrete_Test } from "../Container.t.sol";
import { MockModule } from "../../../../mocks/MockModule.sol";
import { Events } from "../../../../utils/Events.sol";
import { Errors } from "../../../../utils/Errors.sol";

contract EnableModule_Unit_Concrete_Test is Container_Unit_Concrete_Test {
    function setUp() public virtual override {
        Container_Unit_Concrete_Test.setUp();
    }

    function test_RevertWhen_CallerNotOwner() external {
        // Make Bob the caller for this test suite who is not the owner of the container
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the {Unauthorized} error
        vm.expectRevert(Errors.Unauthorized.selector);

        // Run the test
        container.enableModule({ module: address(0x1) });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the container
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_InvalidZeroCodeModule() external whenCallerOwner {
        // Expect the next call to revert with the {InvalidZeroCodeModule}
        vm.expectRevert(Errors.InvalidZeroCodeModule.selector);

        // Run the test
        container.enableModule({ module: address(0x1) });
    }

    modifier whenNonZeroCodeModule() {
        _;
    }

    function test_EnableModule() external whenCallerOwner whenNonZeroCodeModule {
        // Create a new mock module
        MockModule mockModule = new MockModule();

        // Expect the {ModuleEnabled} to be emitted
        vm.expectEmit();
        emit Events.ModuleEnabled({ module: address(mockModule) });

        // Run the test
        container.enableModule({ module: address(mockModule) });

        // Assert the module enablement state
        bool isModuleEnabled = container.isModuleEnabled({ module: address(mockModule) });
        assertTrue(isModuleEnabled);
    }
}
