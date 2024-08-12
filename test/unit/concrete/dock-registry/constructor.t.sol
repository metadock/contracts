// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { DockRegistry } from "./../../../../src/DockRegistry.sol";
import { Base_Test } from "../../../Base.t.sol";
import { Events } from "../../../utils/Events.sol";

contract Constructor_DockRegistry_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function test_Constructor() external {
        vm.expectEmit();
        emit Events.Initialized({ version: type(uint64).max });

        // Run the test
        new DockRegistry();
    }
}
