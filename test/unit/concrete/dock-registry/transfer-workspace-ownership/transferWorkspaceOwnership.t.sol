// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { DockRegistry_Unit_Concrete_Test } from "../DockRegistry.t.sol";
import { MockModule } from "../../../../mocks/MockModule.sol";
import { Workspace } from "./../../../../../src/Workspace.sol";
import { Events } from "../../../../utils/Events.sol";
import { Errors } from "../../../../utils/Errors.sol";

contract TransferWorkspaceOwnership_Unit_Concrete_Test is DockRegistry_Unit_Concrete_Test {
    function setUp() public virtual override {
        DockRegistry_Unit_Concrete_Test.setUp();
    }

    modifier givenWorkspaceCreated() {
        // Create & deploy a new workspace with Eve as the owner
        address[] memory modules = new address[](1);
        modules[0] = address(mockModule);

        workspace = deployWorkspace({ _owner: users.eve, _dockId: 0, _initialModules: modules });
        _;
    }

    function test_RevertWhen_CallerNotOwner() external givenWorkspaceCreated {
        // Make Bob the caller for this test suite who is not the owner of the workspace
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the {CallerNotWorkspaceOwner} error
        vm.expectRevert(Errors.CallerNotWorkspaceOwner.selector);

        // Run the test
        dockRegistry.transferWorkspaceOwnership({ workspace: address(workspace), newOwner: users.eve });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the workspace
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_InvalidOwnerZeroAddress() external givenWorkspaceCreated whenCallerOwner {
        // Expect the next call to revert with the {InvalidOwnerZeroAddress}
        vm.expectRevert(Errors.InvalidOwnerZeroAddress.selector);

        // Run the test
        dockRegistry.transferWorkspaceOwnership({ workspace: address(workspace), newOwner: address(0) });
    }

    modifier whenNonZeroOwnerAddress() {
        _;
    }

    function test_TransferWorkspaceOwnership() external givenWorkspaceCreated whenCallerOwner whenNonZeroOwnerAddress {
        // Expect the {WorkspaceOwnershipTransferred} to be emitted
        vm.expectEmit();
        emit Events.WorkspaceOwnershipTransferred({ workspace: workspace, oldOwner: users.eve, newOwner: users.bob });

        // Run the test
        dockRegistry.transferWorkspaceOwnership({ workspace: address(workspace), newOwner: users.bob });

        // Assert the actual and expected owner
        address actualOwner = dockRegistry.ownerOfWorkspace(address(workspace));
        assertEq(actualOwner, users.bob);
    }
}
