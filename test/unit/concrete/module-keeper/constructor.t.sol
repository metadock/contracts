// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { ModuleKeeper } from "./../../../../src/ModuleKeeper.sol";
import { Base_Test } from "../../../Base.t.sol";

contract Constructor_ModuleKeeper_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function test_Constructor() external {
        // Run the test
        ModuleKeeper moduleKeeper = new ModuleKeeper({ _initialOwner: users.admin });

        // Assert the actual and expected owner
        address owner = moduleKeeper.owner();
        assertEq(owner, users.admin);
    }
}
