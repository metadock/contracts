// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Container_Unit_Concrete_Test } from "../Container.t.sol";
import { MockModule } from "../../../../mocks/MockModule.sol";
import { Events } from "../../../../utils/Events.sol";
import { Errors } from "../../../../utils/Errors.sol";

contract TransferOwnership_Unit_Concrete_Test is Container_Unit_Concrete_Test {
    function setUp() public virtual override {
        Container_Unit_Concrete_Test.setUp();
    }

    function test_RevertWhen_CallerNotOwner() external {
        // Make Bob the caller for this test suite who is not the owner of the container
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the {Unauthorized} error
        vm.expectRevert(Errors.Unauthorized.selector);

        // Run the test
        container.transferOwnership({ newOwner: users.eve });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the container
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_InvalidOwnerZeroAddress() external whenCallerOwner {
        // Expect the next call to revert with the {InvalidOwnerZeroAddress}
        vm.expectRevert(Errors.InvalidOwnerZeroAddress.selector);

        // Run the test
        container.transferOwnership({ newOwner: address(0) });
    }

    modifier whenNonZeroOwnerAddress() {
        _;
    }

    function test_TransferOwnership() external whenCallerOwner whenNonZeroOwnerAddress {
        // Expect the {OwnershipTransferred} to be emitted
        vm.expectEmit();
        emit Events.OwnershipTransferred({ oldOwner: users.eve, newOwner: users.bob });

        // Run the test
        container.transferOwnership({ newOwner: users.bob });

        // Assert the actual and expected owner
        address actualOwner = container.owner();
        assertEq(actualOwner, users.bob);
    }
}
