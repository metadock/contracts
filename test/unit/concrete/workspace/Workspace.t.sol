// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Base_Test } from "../../../Base.t.sol";

contract Workspace_Unit_Concrete_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();

        address[] memory modules = new address[](1);
        modules[0] = address(mockModule);

        workspace = deployWorkspace({ _owner: users.eve, _dockId: 0, _initialModules: modules });
    }
}
