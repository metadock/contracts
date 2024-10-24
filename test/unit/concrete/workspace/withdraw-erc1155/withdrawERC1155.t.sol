// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Workspace_Unit_Concrete_Test } from "../Workspace.t.sol";
import { Errors } from "../../../../utils/Errors.sol";
import { Events } from "../../../../utils/Events.sol";
import { IERC1155 } from "@openzeppelin/contracts/interfaces/IERC1155.sol";

contract WithdrawERC1155_Unit_Concrete_Test is Workspace_Unit_Concrete_Test {
    uint256[] ids;
    uint256[] amounts;

    function setUp() public virtual override {
        Workspace_Unit_Concrete_Test.setUp();

        ids = new uint256[](2);
        amounts = new uint256[](2);

        ids[0] = 1;
        ids[1] = 2;
        amounts[0] = 100;
        amounts[1] = 200;
    }

    function test_RevertWhen_CallerNotAdminOrEntryPoint() external {
        // Make Bob the caller for this test suite who is not the owner of the workspace
        vm.startPrank({ msgSender: users.bob });

        // Expect the next call to revert with the "Account: not admin or EntryPoint." error
        vm.expectRevert("Account: not admin or EntryPoint.");

        // Run the test
        workspace.withdrawERC1155({ collection: IERC1155(address(0x0)), ids: ids, amounts: amounts });
    }

    modifier whenCallerOwner() {
        // Make Eve the caller for the next test suite as she's the owner of the workspace
        vm.startPrank({ msgSender: users.eve });
        _;
    }

    function test_RevertWhen_InsufficientERC1155Balance() external whenCallerOwner {
        // Expect the next call to revert with the {ERC1155InsufficientBalance} error
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ERC1155InsufficientBalance.selector, address(workspace), 0, amounts[0], ids[0]
            )
        );

        // Run the test by attempting to withdraw a nonexistent ERC1155 token
        workspace.withdrawERC1155({ collection: mockERC1155, ids: ids, amounts: amounts });
    }

    modifier whenExistingERC1155Token() {
        // Mint 100 ERC1155 tokens to the workspace contract
        mockERC1155.mintBatch({ to: address(workspace), amounts: amounts });
        _;
    }

    function test_WithdrawERC1155() external whenCallerOwner whenExistingERC1155Token {
        uint256[] memory idsToWithdraw = new uint256[](1);
        uint256[] memory amountsToWithdraw = new uint256[](1);
        idsToWithdraw[0] = 1;
        amountsToWithdraw[0] = 100;

        // Expect the {ERC721Withdrawn} event to be emitted
        vm.expectEmit();
        emit Events.ERC1155Withdrawn({
            to: users.eve,
            collection: address(mockERC1155),
            ids: idsToWithdraw,
            amounts: amountsToWithdraw
        });

        // Run the test
        workspace.withdrawERC1155({ collection: mockERC1155, ids: idsToWithdraw, amounts: amountsToWithdraw });

        // Assert the actual and expected token type 1 ERC1155 balance of Eve
        uint256 actualBalanceOfEve = mockERC1155.balanceOf(users.eve, idsToWithdraw[0]);
        assertEq(actualBalanceOfEve, amountsToWithdraw[0]);
    }

    function test_WithdrawERC1155_Batch() external whenCallerOwner whenExistingERC1155Token {
        // Expect the {ERC721Withdrawn} event to be emitted
        vm.expectEmit();
        emit Events.ERC1155Withdrawn({ to: users.eve, collection: address(mockERC1155), ids: ids, amounts: amounts });

        // Run the test
        workspace.withdrawERC1155({ collection: mockERC1155, ids: ids, amounts: amounts });

        // Assert the actual and expected balance of any ERC1155 tokens
        uint256 numberOfTokens = ids.length;
        for (uint256 i; i < numberOfTokens; ++i) {
            uint256 actualBalanceOfEve = mockERC1155.balanceOf(users.eve, ids[i]);
            assertEq(actualBalanceOfEve, amounts[i]);
        }
    }
}
