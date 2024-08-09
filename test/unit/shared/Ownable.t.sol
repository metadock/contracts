// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Base_Test } from "../../Base.t.sol";
import { MockOwnable } from "../../mocks/MockOwnable.sol";

contract Ownable_Shared_Test is Base_Test {
    MockOwnable ownableMock;

    function setUp() public virtual override {
        Base_Test.setUp();
        ownableMock = new MockOwnable({ _owner: users.admin });
    }

    modifier whenCallerCurrentOwner() {
        // Make Admin the caller for the next test suite
        vm.startPrank({ msgSender: users.admin });
        _;
    }

    modifier whenNewOwnerNotZeroAddress() {
        _;
    }
}
