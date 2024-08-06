// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { DockRegistry_Unit_Concrete_Test } from "../DockRegistry.t.sol";
import { MockModule } from "../../../../mocks/MockModule.sol";
import { Container } from "./../../../../../src/Container.sol";
import { Events } from "../../../../utils/Events.sol";
import { Errors } from "../../../../utils/Errors.sol";

contract TransferContainerOwnership_Unit_Concrete_Test is DockRegistry_Unit_Concrete_Test {
    function setUp() public virtual override {
        DockRegistry_Unit_Concrete_Test.setUp();
    }

    modifier givenContainerCreated() {
        // Create & deploy a new container with Eve as the owner
        address[] memory modules = new address[](1);
        modules[0] = address(mockModule);

        container = deployContainer({ _owner: users.eve, _dockId: 0, _initialModules: modules });
        _;
    }

    function test_RevertWhen_CallerNotOwner() external givenContainerCreated {
        // Make Bob the caller for this test suite who is not the owner of the container
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the {CallerNotContainerOwner} error
        vm.expectRevert(Errors.CallerNotContainerOwner.selector);

        // Run the test
        dockRegistry.transferContainerOwnership({ container: address(container), newOwner: users.eve });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the container
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_InvalidOwnerZeroAddress() external givenContainerCreated whenCallerOwner {
        // Expect the next call to revert with the {InvalidOwnerZeroAddress}
        vm.expectRevert(Errors.InvalidOwnerZeroAddress.selector);

        // Run the test
        dockRegistry.transferContainerOwnership({ container: address(container), newOwner: address(0) });
    }

    modifier whenNonZeroOwnerAddress() {
        _;
    }

    function test_transferContainerOwnership() external givenContainerCreated whenCallerOwner whenNonZeroOwnerAddress {
        // Expect the {ContainerOwnershipTransferred} to be emitted
        vm.expectEmit();
        emit Events.ContainerOwnershipTransferred({ container: container, oldOwner: users.eve, newOwner: users.bob });

        // Run the test
        dockRegistry.transferContainerOwnership({ container: address(container), newOwner: users.bob });

        // Assert the actual and expected owner
        address actualOwner = dockRegistry.ownerOfContainer(address(container));
        assertEq(actualOwner, users.bob);
    }
}
