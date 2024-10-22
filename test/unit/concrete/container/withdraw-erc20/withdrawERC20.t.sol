// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Container_Unit_Concrete_Test } from "../Container.t.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { Events } from "../../../../utils/Events.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract WithdrawERC20_Unit_Concrete_Test is Container_Unit_Concrete_Test {
    function setUp() public virtual override {
        Container_Unit_Concrete_Test.setUp();
    }

    function test_RevertWhen_CallerNotOwner() external {
        // Make Bob the caller for this test suite who is not the owner of the container
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the "Account: not admin or EntryPoint." error
        vm.expectRevert("Account: not admin or EntryPoint.");

        // Run the test
        container.withdrawERC20({ asset: IERC20(address(0x0)), amount: 100e6 });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the container
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_InsufficientERC20ToWithdraw() external whenCallerOwner {
        // Expect the next call to revert with the {InsufficientERC20ToWithdraw} error
        vm.expectRevert(Errors.InsufficientERC20ToWithdraw.selector);

        // Run the test
        container.withdrawERC20({ asset: IERC20(address(usdt)), amount: 100e6 });
    }

    modifier whenSufficientERC20ToWithdraw() {
        // Approve the {Container} contract to spend USDT tokens on behalf of Eve
        usdt.approve({ spender: address(container), amount: 100e6 });

        // Deposit enough ERC-20 tokens into the container to enable the withdrawal
        usdt.transfer({ recipient: address(container), amount: 100e6 });
        _;
    }

    function test_WithdrawERC20() external whenCallerOwner whenSufficientERC20ToWithdraw {
        // Store the USDT balance of Eve before withdrawal
        uint256 balanceOfEveBefore = usdt.balanceOf(users.eve);

        // Expect the {AssetWithdrawn} event to be emitted
        vm.expectEmit();
        emit Events.AssetWithdrawn({ to: users.eve, asset: address(usdt), amount: 10e6 });

        // Run the test
        container.withdrawERC20({ asset: IERC20(address(usdt)), amount: 10e6 });

        // Assert the USDT balance of the {Container} contract
        uint256 actualBalanceOfContainer = usdt.balanceOf(address(container));
        assertEq(actualBalanceOfContainer, 90e6);

        // Assert the USDT balance of Eve
        uint256 actualBalanceOfEve = usdt.balanceOf(users.eve);
        assertEq(actualBalanceOfEve, balanceOfEveBefore + 10e6);
    }
}
