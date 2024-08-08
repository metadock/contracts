// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Container_Unit_Concrete_Test } from "../Container.t.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { Events } from "../../../../utils/Events.sol";

contract Execute_Unit_Concrete_Test is Container_Unit_Concrete_Test {
    function setUp() public virtual override {
        Container_Unit_Concrete_Test.setUp();
    }

    function test_RevertWhen_CallerNotOwner() external {
        // Make Bob the caller for this test suite who is not the owner of the container
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the {Unauthorized} error
        vm.expectRevert(Errors.Unauthorized.selector);

        // Run the test
        container.execute({ module: address(mockModule), value: 0, data: "" });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the container
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_ModuleNotEnabled() external whenCallerOwner {
        // Expect the next call to revert with the {ModuleNotEnabled} error
        vm.expectRevert(Errors.ModuleNotEnabled.selector);

        // Run the test by trying to execute a module at `0x0000000000000000000000000000000000000001` address
        container.execute({ module: address(0x1), value: 0, data: "" });
    }

    modifier whenModuleEnabled() {
        _;
    }

    function test_Execute() external whenCallerOwner whenModuleEnabled {
        // Create the calldata for the mock module execution
        bytes memory data = abi.encodeWithSignature("createModuleItem()", "");

        // Expect the {ModuleExecutionSucceded} event to be emitted
        vm.expectEmit();
        emit Events.ModuleExecutionSucceded({ module: address(mockModule), value: 0, data: data });

        // Run the test
        container.execute({ module: address(mockModule), value: 0, data: data });

        // Alter the `createModuleItem` method signature by adding an invalid `uint256` field
        bytes memory wrongData = abi.encodeWithSignature("createModuleItem(uint256)", 1);

        // Expect the call to be reverted due to invalid method signature
        vm.expectRevert();

        // Run the test
        container.execute({ module: address(mockModule), value: 0, data: wrongData });
    }
}
