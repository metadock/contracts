// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Workspace_Unit_Concrete_Test } from "../Workspace.t.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { MockModule } from "../../../../mocks/MockModule.sol";

contract ExecuteBatch_Unit_Concrete_Test is Workspace_Unit_Concrete_Test {
    address[] modules;
    uint256[] values;
    bytes[] data;

    function setUp() public virtual override {
        Workspace_Unit_Concrete_Test.setUp();

        // Construct the mock params to be used in this test suite
        modules = new address[](1);
        modules[0] = address(mockModule);

        values = new uint256[](1);
        values[0] = 0;

        data = new bytes[](1);
        data[0] = "";
    }

    function test_RevertWhen_CallerNotOwner() external {
        // Make Bob the caller for this test suite who is not the owner of the workspace
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the "Account: not admin or EntryPoint." error
        vm.expectRevert("Account: not admin or EntryPoint.");

        // Run the test
        workspace.executeBatch(modules, values, data);
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the workspace
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_WrongArrayLengths() external whenCallerOwner {
        // Push a new item to the modules array which will increase the items count to two
        // whereas values and data arrays still have only one item
        modules.push(address(0x1));

        // Expect the next call to revert with the {WrongArrayLength} error
        vm.expectRevert(Errors.WrongArrayLengths.selector);

        // Run the test
        workspace.executeBatch(modules, values, data);
    }

    modifier whenCorrectArrayLengths() {
        _;
    }

    function test_RevertWhen_ModuleNotEnabled() external whenCallerOwner whenCorrectArrayLengths {
        // Update the first module address to `0x0000000000000000000000000000000000000001` address which is not a valid one
        modules[0] = address(0x1);

        // Expect the next call to revert with the {ModuleNotEnabled} error
        vm.expectRevert(abi.encodeWithSelector(Errors.ModuleNotEnabled.selector, address(0x1)));

        // Run the test
        workspace.executeBatch(modules, values, data);
    }

    modifier whenModuleEnabled() {
        _;
    }

    function test_ExecuteBatch() external whenCallerOwner whenModuleEnabled {
        // Create the calldata for the mock module execution
        data[0] = abi.encodeWithSignature("createModuleItem()", "");
        data.push(abi.encodeWithSignature("createModuleItem()", ""));

        modules.push(address(mockModule));
        values.push(0);

        // Expect the first {ModuleItemCreated} event to be emitted
        vm.expectEmit();
        emit MockModule.ModuleItemCreated({ id: 0 });

        // Expect the second {ModuleItemCreated} event to be emitted
        vm.expectEmit();
        emit MockModule.ModuleItemCreated({ id: 1 });

        // Run the test
        workspace.executeBatch(modules, values, data);

        // Assert the actual and expected items stored for Eve due to the batch execution
        uint256[] memory itemsOf = mockModule.getItemsOf(users.eve);
        for (uint256 i; i < itemsOf.length; ++i) {
            assertEq(itemsOf[i], i);
        }

        // Alter the `createModuleItem` method signature by adding an invalid `uint256` field
        data[0] = abi.encodeWithSignature("createModuleItem(uint256)", 2);

        // Expect the call to be reverted due to invalid method signature
        vm.expectRevert();

        // Run the test
        workspace.executeBatch(modules, values, data);
    }
}
