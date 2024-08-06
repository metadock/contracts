// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { DockRegistry_Unit_Concrete_Test } from "../DockRegistry.t.sol";
import { Container } from "./../../../../../src/Container.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { Events } from "../../../../utils/Events.sol";

contract CreateContainer_Unit_Concrete_Test is DockRegistry_Unit_Concrete_Test {
    function setUp() public virtual override {
        DockRegistry_Unit_Concrete_Test.setUp();
    }

    modifier whenDockIdZero() {
        _;
    }

    function test_CreateContainer_DockIdZero() external whenDockIdZero {
        // The {DockRegistry} contract deploys each new {Container} contract.
        // Therefore, we need to calculate the current nonce of the {DockRegistry}
        // to pre-compute the address of the new {Container} before deployment.
        address expectedContainer = computeDeploymentAddress({ deployer: address(dockRegistry) });

        // Allowlist the mock modules on the {ModuleKeeper} contract from the admin account
        vm.startPrank({ msgSender: users.admin });
        for (uint256 i; i < mockModules.length; ++i) {
            allowlistModule(mockModules[i]);
        }
        vm.stopPrank();

        // Expect the {ContainerCreated} to be emitted
        vm.expectEmit();
        emit Events.ContainerCreated({
            owner: users.bob,
            dockId: 1,
            container: Container(payable(expectedContainer)),
            initialModules: mockModules
        });

        // Run the test
        dockRegistry.createContainer({ owner: users.bob, dockId: 0, initialModules: mockModules });

        // Assert the expected and actual owner of the dock
        address actualOwnerOfDock = dockRegistry.ownerOfDock({ dockId: 1 });
        assertEq(address(this), actualOwnerOfDock);

        // Assert the expected and actual owner of the {Container}
        address actualOwnerOfContainer = dockRegistry.ownerOfContainer({ container: expectedContainer });
        assertEq(users.bob, actualOwnerOfContainer);

        // Assert the expected and actual dock ID of the {Container}
        uint256 actualDockIdOfContainer = dockRegistry.dockIdOfContainer({ container: expectedContainer });
        assertEq(1, actualDockIdOfContainer);
    }

    modifier whenDockIdNonZero() {
        // Create & deploy a new container with Eve as the owner
        address[] memory modules = new address[](1);
        modules[0] = address(mockModule);

        container = deployContainer({ _owner: users.eve, _dockId: 0, _initialModules: modules });
        _;
    }

    modifier whenCallerNotDockOwner() {
        // Make Bob the caller in this test suite as he's not the owner of the dock #1
        vm.startPrank({ msgSender: users.bob });
        _;
    }

    function test_RevertWhen_CallerNotDockOwner() external whenDockIdNonZero whenCallerNotDockOwner {
        // Create a mock modules array
        address[] memory modules = new address[](1);
        modules[0] = address(mockModule);

        // Expect the {CallerNotDockOwner} to be emitted
        vm.expectRevert(Errors.CallerNotDockOwner.selector);

        // Run the test
        dockRegistry.createContainer({ owner: users.bob, dockId: 1, initialModules: modules });
    }

    modifier whenCallerDockOwner() {
        _;
    }

    function test_CreateContainer_DockIdNonZero() external whenDockIdNonZero whenCallerDockOwner {
        // The {DockRegistry} contract deploys each new {Container} contract.
        // Therefore, we need to calculate the current nonce of the {DockRegistry}
        // to pre-compute the address of the new {Container} before deployment.
        address expectedContainer = computeDeploymentAddress({ deployer: address(dockRegistry) });

        // Allowlist the mock modules on the {ModuleKeeper} contract from the admin account
        vm.startPrank({ msgSender: users.admin });
        for (uint256 i; i < mockModules.length; ++i) {
            allowlistModule(mockModules[i]);
        }
        vm.stopPrank();

        // Expect the {ContainerCreated} event to be emitted
        vm.expectEmit();
        emit Events.ContainerCreated({
            owner: users.bob,
            dockId: 1,
            container: Container(payable(expectedContainer)),
            initialModules: mockModules
        });

        // Run the test
        dockRegistry.createContainer({ owner: users.bob, dockId: 1, initialModules: mockModules });

        // Assert the expected and actual owner of the dock
        address actualOwnerOfDock = dockRegistry.ownerOfDock({ dockId: 1 });
        assertEq(address(this), actualOwnerOfDock);

        // Assert the expected and actual owner of the {Container}
        address actualOwnerOfContainer = dockRegistry.ownerOfContainer({ container: expectedContainer });
        assertEq(users.bob, actualOwnerOfContainer);

        // Assert the expected and actual dock ID of the {Container}
        uint256 actualDockIdOfContainer = dockRegistry.dockIdOfContainer({ container: expectedContainer });
        assertEq(1, actualDockIdOfContainer);
    }
}
