// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Container_Unit_Concrete_Test } from "../Container.t.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { Events } from "../../../../utils/Events.sol";

contract WithdrawNative_Unit_Concrete_Test is Container_Unit_Concrete_Test {
    function setUp() public virtual override {
        Container_Unit_Concrete_Test.setUp();
    }

    function test_RevertWhen_CallerNotOwner() external {
        // Make Bob the caller for this test suite who is not the owner of the container
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the {Unauthorized} error
        vm.expectRevert(Errors.Unauthorized.selector);

        // Run the test
        container.withdrawNative({ amount: 2 ether });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the container
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_InsufficientNativeToWithdraw() external whenCallerOwner {
        // Expect the next call to revert with the {InsufficientNativeToWithdraw} error
        vm.expectRevert(Errors.InsufficientNativeToWithdraw.selector);

        // Run the test
        container.withdrawNative({ amount: 2 ether });
    }

    modifier whenSufficientNativeToWithdraw() {
        // Deposit sufficient native tokens (ETH) into the container to enable the withdrawal
        (bool success, ) = payable(container).call{ value: 2 ether }("");
        if (!success) revert();
        _;
    }

    function test_WithdrawNative() external whenCallerOwner whenSufficientNativeToWithdraw {
        // Store the ETH balance of Eve and {Container} contract before withdrawal
        uint256 balanceOfContainerBefore = address(container).balance;
        uint256 balanceOfEveBefore = address(users.eve).balance;
        uint256 ethToWithdraw = 1 ether;

        // Expect the {AssetWithdrawn} event to be emitted
        vm.expectEmit();
        emit Events.AssetWithdrawn({ sender: users.eve, asset: address(0x0), amount: ethToWithdraw });

        // Run the test
        container.withdrawNative({ amount: ethToWithdraw });

        // Assert the ETH balance of the {Container} contract
        uint256 actualBalanceOfContainer = address(container).balance;
        assertEq(actualBalanceOfContainer, balanceOfContainerBefore - ethToWithdraw);

        // Assert the ETH balance of Eve
        uint256 actualBalanceOfEve = address(users.eve).balance;
        assertEq(actualBalanceOfEve, balanceOfEveBefore + ethToWithdraw);
    }
}
