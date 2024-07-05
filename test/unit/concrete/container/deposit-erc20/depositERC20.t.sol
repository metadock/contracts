// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Container_Unit_Concrete_Test } from "../Container.t.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { Events } from "../../../../utils/Events.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract DepositERC20_Unit_Concrete_Test is Container_Unit_Concrete_Test {
    function setUp() public virtual override {
        Container_Unit_Concrete_Test.setUp();

        // Make Bob the caller for this test suite as anyone can deposit ERC-20 assets
        vm.startPrank({ msgSender: users.bob });

        // Approve the {Container} contract to spend USDT tokens on behalf of Bob
        usdt.approve({ spender: address(container), amount: 1000000e6 });
    }

    function test_RevertWhen_AssetZeroAddress() external {
        // Expect the next call to revert with the {InvalidAssetZeroAddress} error
        vm.expectRevert(Errors.InvalidAssetZeroAddress.selector);

        // Run the test
        container.depositERC20({ asset: IERC20(address(0x0)), amount: 100e6 });
    }

    modifier whenAssetNonZeroAddress() {
        _;
    }

    function test_RevertWhen_AssetZeroAmount() external whenAssetNonZeroAddress {
        // Expect the next call to revert with the {InvalidAssetZeroAmount} error
        vm.expectRevert(Errors.InvalidAssetZeroAmount.selector);

        // Run the test
        container.depositERC20({ asset: IERC20(address(usdt)), amount: 0 });
    }

    modifier whenAssetGtZeroAmount() {
        _;
    }

    function test_DepositERC20() external whenAssetNonZeroAddress whenAssetGtZeroAmount {
        // Store the USDT balance of Bob before the deposit
        uint256 balanceOfBobBefore = usdt.balanceOf(users.bob);

        // Expect the {AssetDeposited} event to be emitted
        vm.expectEmit();
        emit Events.AssetDeposited({ sender: users.bob, asset: address(usdt), amount: 100e6 });

        // Run the test
        container.depositERC20({ asset: IERC20(address(usdt)), amount: 100e6 });

        // Assert the USDT balance of the {Container} contract
        uint256 actualBalanceOfContainer = usdt.balanceOf(address(container));
        assertEq(actualBalanceOfContainer, 100e6);

        // Assert the USDT balance of Bob after the deposit
        uint256 actualBalanceOfBob = usdt.balanceOf(users.bob);
        assertEq(actualBalanceOfBob, balanceOfBobBefore - 100e6);
    }
}
