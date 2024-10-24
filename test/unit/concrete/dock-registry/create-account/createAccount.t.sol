// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { DockRegistry_Unit_Concrete_Test } from "../DockRegistry.t.sol";
import { Workspace } from "./../../../../../src/Workspace.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { Events } from "../../../../utils/Events.sol";

contract CreateAccount_Unit_Concrete_Test is DockRegistry_Unit_Concrete_Test {
    function setUp() public virtual override {
        DockRegistry_Unit_Concrete_Test.setUp();
    }

    modifier whenDockIdZero() {
        _;
    }

    function test_CreateAccount_DockIdZero() external whenDockIdZero {
        // The {DockRegistry} contract deploys each new {Workspace} contract.
        // Therefore, we need to calculate the current nonce of the {DockRegistry}
        // to pre-compute the address of the new {Workspace} before deployment.
        (address expectedWorkspace, bytes memory data) =
            computeDeploymentAddressAndCalldata({ deployer: users.bob, dockId: 0, initialModules: mockModules });

        // Allowlist the mock modules on the {ModuleKeeper} contract from the admin account
        vm.startPrank({ msgSender: users.admin });
        for (uint256 i; i < mockModules.length; ++i) {
            allowlistModule(mockModules[i]);
        }
        vm.stopPrank();

        // Expect the {WorkspaceCreated} to be emitted
        vm.expectEmit();
        emit Events.WorkspaceCreated({
            owner: users.bob,
            dockId: 1,
            workspace: Workspace(payable(expectedWorkspace)),
            initialModules: mockModules
        });

        // Make Bob the caller in this test suite
        vm.prank({ msgSender: users.bob });

        // Run the test
        dockRegistry.createAccount({ _admin: users.bob, _data: data });

        // Assert the expected and actual owner of the dock
        address actualOwnerOfDock = dockRegistry.ownerOfDock({ dockId: 1 });
        assertEq(users.bob, actualOwnerOfDock);

        // Assert the expected and actual dock ID of the {Workspace}
        uint256 actualDockIdOfWorkspace = dockRegistry.dockIdOfWorkspace({ workspace: expectedWorkspace });
        assertEq(1, actualDockIdOfWorkspace);
    }

    modifier whenDockIdNonZero() {
        // Create & deploy a new workspace with Eve as the owner
        workspace = deployWorkspace({ _owner: users.bob, _dockId: 0, _initialModules: mockModules });
        _;
    }

    function test_RevertWhen_CallerNotDockOwner() external whenDockIdNonZero {
        // Construct the calldata to be used to initialize the {Workspace} smart account
        bytes memory data =
            computeCreateAccountCalldata({ deployer: users.eve, dockId: 1, initialModules: mockModules });

        // Make Eve the caller in this test suite
        vm.prank({ msgSender: users.eve });

        // Expect the {CallerNotDockOwner} to be emitted
        vm.expectRevert(Errors.CallerNotDockOwner.selector);

        // Run the test
        dockRegistry.createAccount({ _admin: users.bob, _data: data });
    }

    modifier whenCallerDockOwner() {
        _;
    }

    function test_CreateAccount_DockIdNonZero() external whenDockIdNonZero whenCallerDockOwner {
        // The {DockRegistry} contract deploys each new {Workspace} contract.
        // Therefore, we need to calculate the current nonce of the {DockRegistry}
        // to pre-compute the address of the new {Workspace} before deployment.
        (address expectedWorkspace, bytes memory data) =
            computeDeploymentAddressAndCalldata({ deployer: users.bob, dockId: 1, initialModules: mockModules });

        // Allowlist the mock modules on the {ModuleKeeper} contract from the admin account
        vm.startPrank({ msgSender: users.admin });
        for (uint256 i; i < mockModules.length; ++i) {
            allowlistModule(mockModules[i]);
        }
        vm.stopPrank();

        // Expect the {WorkspaceCreated} event to be emitted
        vm.expectEmit();
        emit Events.WorkspaceCreated({
            owner: users.bob,
            dockId: 1,
            workspace: Workspace(payable(expectedWorkspace)),
            initialModules: mockModules
        });

        // Make Bob the caller in this test suite
        vm.prank({ msgSender: users.bob });

        // Run the test
        dockRegistry.createAccount({ _admin: users.bob, _data: data });

        // Assert if the freshly deployed smart account is registered on the factory
        bool isRegisteredOnFactory = dockRegistry.isRegistered(expectedWorkspace);
        assertTrue(isRegisteredOnFactory);

        // Assert if the initial modules has been enabled on the {Workspace} smart account instance
        bool isModuleEnabled = Workspace(payable(expectedWorkspace)).isModuleEnabled(mockModules[0]);
        assertTrue(isModuleEnabled);

        // Assert the expected and actual owner of the dock
        address actualOwnerOfDock = dockRegistry.ownerOfDock({ dockId: 1 });
        assertEq(users.bob, actualOwnerOfDock);

        // Assert the expected and actual dock ID of the {Workspace}
        uint256 actualDockIdOfWorkspace = dockRegistry.dockIdOfWorkspace({ workspace: expectedWorkspace });
        assertEq(1, actualDockIdOfWorkspace);
    }
}
