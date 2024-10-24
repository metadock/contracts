// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { DockRegistry_Unit_Concrete_Test } from "../DockRegistry.t.sol";
import { MockModule } from "../../../../mocks/MockModule.sol";
import { Workspace } from "./../../../../../src/Workspace.sol";
import { Events } from "../../../../utils/Events.sol";
import { Errors } from "../../../../utils/Errors.sol";

contract TransferDockOwnership_Unit_Concrete_Test is DockRegistry_Unit_Concrete_Test {
    function setUp() public virtual override {
        DockRegistry_Unit_Concrete_Test.setUp();
    }

    modifier givenDockCreated() {
        // Create a new dock by creating & deploying a new workspace
        address[] memory modules = new address[](1);
        modules[0] = address(mockModule);

        workspace = deployWorkspace({ _owner: users.eve, _dockId: 0, _initialModules: modules });
        _;
    }

    function test_RevertWhen_CallerNotOwner() external givenDockCreated {
        // Make Bob the caller for this test suite who is not the owner of the dock
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the {CallerNotDockOwner} error
        vm.expectRevert(Errors.CallerNotDockOwner.selector);

        // Run the test
        dockRegistry.transferDockOwnership({ dockId: 1, newOwner: users.bob });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the dock
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_TransferDockOwnership() external givenDockCreated whenCallerOwner {
        // Expect the {DockOwnershipTransferred} to be emitted
        vm.expectEmit();
        emit Events.DockOwnershipTransferred({ dockId: 1, oldOwner: users.eve, newOwner: users.bob });

        // Run the test
        dockRegistry.transferDockOwnership({ dockId: 1, newOwner: users.bob });

        // Assert the actual and expected owner
        address actualOwner = dockRegistry.ownerOfDock({ dockId: 1 });
        assertEq(actualOwner, users.bob);
    }
}
