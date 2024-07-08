// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Base_Test } from "../Base.t.sol";

abstract contract Integration_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Make Eve the default caller to deploy a new {Container} contract
        vm.startPrank({ msgSender: users.eve });

        // Setup the initial {InvoiceModule} module
        address[] memory modules = new address[](1);
        modules[0] = address(invoiceModule);

        // Deploy the {Container} contract with the {InvoiceModule} enabled by default
        container = deployContainer({ owner: users.eve, initialModules: modules });

        // Stop the prank to be able to start a different one in the test suite
        vm.stopPrank();
    }
}
