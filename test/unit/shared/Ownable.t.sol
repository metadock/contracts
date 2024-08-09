// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Base_Test } from "../../Base.t.sol";
import { OwnableMock } from "../../mocks/OwnableMock.sol";

contract Ownable_Shared_Test is Base_Test {
    OwnableMock ownableMock;

    function setUp() public virtual override {
        Base_Test.setUp();
        ownableMock = new OwnableMock({ _owner: users.admin });
    }
}
