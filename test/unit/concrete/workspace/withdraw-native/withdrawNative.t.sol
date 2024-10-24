// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { MockBadReceiver } from "../../../../mocks/MockBadReceiver.sol";
import { Workspace_Unit_Concrete_Test } from "../Workspace.t.sol";
import { Workspace } from "./../../../../../src/Workspace.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { Events } from "../../../../utils/Events.sol";

contract WithdrawNative_Unit_Concrete_Test is Workspace_Unit_Concrete_Test {
    address badReceiver;
    Workspace badWorkspace;

    function setUp() public virtual override {
        Workspace_Unit_Concrete_Test.setUp();

        // Create a bad receiver contract as the owner of the `badWorkspace` to test for the `NativeWithdrawFailed` error
        badReceiver = address(new MockBadReceiver());
        vm.deal({ account: badReceiver, newBalance: 100 ether });

        // Deploy the `badWorkspace` workspace
        address[] memory modules = new address[](1);
        modules[0] = address(mockModule);
        badWorkspace = deployWorkspace({ _owner: address(badReceiver), _dockId: 0, _initialModules: modules });
    }

    function test_RevertWhen_CallerNotOwner() external {
        // Make Bob the caller for this test suite who is not the owner of the workspace
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the "Account: not admin or EntryPoint." error
        vm.expectRevert("Account: not admin or EntryPoint.");

        // Run the test
        workspace.withdrawNative({ amount: 2 ether });
    }

    modifier whenCallerOwner(address caller) {
        // Make `caller` the caller for the next test suite as she's the owner of the workspace
        vm.startPrank({ msgSender: caller });
        _;
    }

    function test_RevertWhen_InsufficientNativeToWithdraw() external whenCallerOwner(users.eve) {
        // Expect the next call to revert with the {InsufficientNativeToWithdraw} error
        vm.expectRevert(Errors.InsufficientNativeToWithdraw.selector);

        // Run the test
        workspace.withdrawNative({ amount: 2 ether });
    }

    modifier whenSufficientNativeToWithdraw(Workspace workspace) {
        // Deposit sufficient native tokens (ETH) into the workspace to enable the withdrawal
        (bool success,) = payable(workspace).call{ value: 2 ether }("");
        if (!success) revert();
        _;
    }

    function test_RevertWhen_NativeWithdrawFailed()
        external
        whenCallerOwner(badReceiver)
        whenSufficientNativeToWithdraw(badWorkspace)
    {
        // Expect the next call to revert with the {NativeWithdrawFailed} error
        vm.expectRevert(Errors.NativeWithdrawFailed.selector);

        // Run the test
        badWorkspace.withdrawNative({ amount: 1 ether });
    }

    modifier whenNativeWithdrawSucceeds() {
        _;
    }

    function test_WithdrawNative()
        external
        whenCallerOwner(users.eve)
        whenSufficientNativeToWithdraw(workspace)
        whenNativeWithdrawSucceeds
    {
        // Store the ETH balance of Eve and {Workspace} contract before withdrawal
        uint256 balanceOfWorkspaceBefore = address(workspace).balance;
        uint256 balanceOfEveBefore = address(users.eve).balance;
        uint256 ethToWithdraw = 1 ether;

        // Expect the {AssetWithdrawn} event to be emitted
        vm.expectEmit();
        emit Events.AssetWithdrawn({ to: users.eve, asset: address(0x0), amount: ethToWithdraw });

        // Run the test
        workspace.withdrawNative({ amount: ethToWithdraw });

        // Assert the ETH balance of the {Workspace} contract
        uint256 actualBalanceOfWorkspace = address(workspace).balance;
        assertEq(actualBalanceOfWorkspace, balanceOfWorkspaceBefore - ethToWithdraw);

        // Assert the ETH balance of Eve
        uint256 actualBalanceOfEve = address(users.eve).balance;
        assertEq(actualBalanceOfEve, balanceOfEveBefore + ethToWithdraw);
    }
}
