// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { Container } from "./../src/Container.sol";
import { InvoiceModule } from "./../src/modules/InvoiceModule.sol";
import { IModule } from "./../src/interfaces/IModule.sol";
import { InvoiceModuleTypes } from "./../src/libraries/InvoiceModuleTypes.sol";

contract ContainerTest is Test {
    Container container;
    InvoiceModule invoiceModule;

    address deployer = address(0x1);

    function setUp() public {
        invoiceModule = new InvoiceModule();

        IModule[] memory modules = new IModule[](1);
        modules[0] = invoiceModule;

        container = new Container({ _owner: address(this), _initialModules: modules });
    }

    function test_Execute() external {
        InvoiceModuleTypes.Invoice memory invoice = InvoiceModuleTypes.Invoice({
            status: InvoiceModuleTypes.Status.Active,
            frequency: InvoiceModuleTypes.Frequency.Regular,
            startTime: 0,
            endTime: uint40(block.timestamp) + 150,
            payer: address(0x2),
            payment: InvoiceModuleTypes.Payment({
                recurrence: InvoiceModuleTypes.Recurrence.OneTime,
                method: InvoiceModuleTypes.Method.Transfer,
                amount: 1 ether,
                asset: address(0)
            })
        });

        //vm.expectEmit();
        container.execute({
            module: invoiceModule,
            value: 0,
            data: abi.encodeWithSignature(
                "createInvoice((uint8,uint8,uint40,uint40,address,(uint8,uint8,uint256,address)))",
                invoice
            )
        });

        InvoiceModuleTypes.Invoice memory expectedInvoice = invoiceModule.getInvoice({ invoiceId: 0 });
        assertEq(expectedInvoice.payer, invoice.payer);
    }
}
