// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base_Test } from "../../../Base.t.sol";
import { InvoiceModule } from "./../../../../src/modules/invoice-module/InvoiceModule.sol";

contract Container_Unit_Concrete_Test is Base_Test {
    InvoiceModule invoiceModule;

    function setUp() public virtual override {
        Base_Test.setUp();

        invoiceModule = new InvoiceModule();
        address[] memory modules = new address[](1);
        modules[0] = address(invoiceModule);

        container = deployContainer({ owner: users.eve, initialModules: modules });
    }
}
