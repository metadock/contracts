// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { DockRegistry_Unit_Concrete_Test } from "./DockRegistry.t.sol";
import { MockDockRegistryV2 } from "../../../mocks/MockDockRegistryV2.sol";
import { Events } from "../../../utils/Events.sol";
import { Errors } from "../../../utils/Errors.sol";

contract UpgradeToAndCall_DockRegistry_Test is DockRegistry_Unit_Concrete_Test {
    address newImplementation;

    function setUp() public virtual override {
        DockRegistry_Unit_Concrete_Test.setUp();
        newImplementation = address(new MockDockRegistryV2());
    }

    function test_RevertWhen_CallerNotRegistryOwner() external {
        // Make Bob the caller for this test suite who is not the owner of the registry
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the {OwnableUnauthorizedAccount} error
        vm.expectRevert(abi.encodeWithSelector(Errors.OwnableUnauthorizedAccount.selector, users.bob));

        // Run the test
        dockRegistry.upgradeToAndCall({ newImplementation: newImplementation, data: "" });
    }

    modifier whenCallerRegistryOwner() {
        _;
    }

    function test_UpgradeToAndCall() external whenCallerRegistryOwner {
        // Make Admin the caller for this test suite
        vm.startPrank({ msgSender: users.admin });

        // Expect the next call to emit an {Upgraded} event
        vm.expectEmit();
        emit Events.Upgraded(newImplementation);

        // Run the test
        dockRegistry.upgradeToAndCall({ newImplementation: newImplementation, data: "" });

        // Assert the actual and expected version
        assertEq(dockRegistry.VERSION(), "2.0.0");
    }
}
