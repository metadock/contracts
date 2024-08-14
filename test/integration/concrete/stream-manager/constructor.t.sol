// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Integration_Test } from "../../Integration.t.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";
import { MockStreamManager } from "../../../mocks/MockStreamManager.sol";

contract Constructor_StreamManager_Integration_Concret_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();
    }

    function test_Constructor() external {
        // Run the test
        mockStreamManager = new MockStreamManager(sablierV2LockupLinear, sablierV2LockupTranched, users.admin);

        assertEq(UD60x18.unwrap(mockStreamManager.brokerFee()), 0);
        assertEq(mockStreamManager.brokerAdmin(), users.admin);
        assertEq(address(mockStreamManager.LOCKUP_TRANCHED()), address(sablierV2LockupTranched));
        assertEq(address(mockStreamManager.LOCKUP_LINEAR()), address(sablierV2LockupLinear));
    }
}
