// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Container_Unit_Concrete_Test } from "../Container.t.sol";
import { Events } from "../../../../utils/Events.sol";

contract Receive_Unit_Concrete_Test is Container_Unit_Concrete_Test {
    function setUp() public virtual override {
        Container_Unit_Concrete_Test.setUp();
    }

    function test_Receive() external {
        // Make Bob the caller for this test suite
        vm.startPrank({ msgSender: users.bob });

        // Expect the {AssetDeposited} event to be emitted upon ETH deposit
        vm.expectEmit();
        emit Events.AssetDeposited({ sender: users.bob, asset: address(0), amount: 1 ether });

        // Run the test
        (bool success, ) = address(container).call{ value: 1 ether }("");
        if (!success) revert();

        // Assert the {Container} contract balance
        assertEq(address(container).balance, 1 ether);
    }
}
