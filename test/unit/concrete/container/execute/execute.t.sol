// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Container_Unit_Concrete_Test } from "../Container.t.sol";
import { Types as InvoiceModuleTypes } from "./../../../../../src/modules/invoice-module/libraries/Types.sol";
import { Helpers } from "../../../../utils/Helpers.sol";
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
        container.execute({ module: address(invoiceModule), value: 0, data: "" });
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
        // Create the mock invoice and calldata for the module execution
        InvoiceModuleTypes.Invoice memory invoice = Helpers.createInvoiceDataType({ recipient: address(container) });
        bytes memory data = abi.encodeWithSignature(
            "createInvoice((address,uint8,uint8,uint40,uint40,(uint8,uint8,uint24,address,uint256)))",
            invoice
        );

        // Expect the {ModuleExecutionSucceded} event to be emitted
        vm.expectEmit();
        emit Events.ModuleExecutionSucceded({ module: address(invoiceModule), value: 0, data: data });

        // Run the test
        container.execute({ module: address(invoiceModule), value: 0, data: data });

        // Alter the `createInvoice` method signature by removing the `payment.amount` field
        bytes memory wrongData = abi.encodeWithSignature(
            "createInvoice((address,uint8,uint8,uint40,uint40,(uint8,uint8,uint24,address)))",
            invoice
        );

        // Expect the {ModuleExecutionFailed} event to be emitted
        vm.expectEmit();
        emit Events.ModuleExecutionFailed({ module: address(invoiceModule), value: 0, data: wrongData });

        // Run the test
        container.execute({ module: address(invoiceModule), value: 0, data: wrongData });
    }
}
