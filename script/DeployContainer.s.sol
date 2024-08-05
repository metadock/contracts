// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { BaseScript } from "./Base.s.sol";
import { Container } from "../src/Container.sol";
import { DockRegistry } from "./../src/DockRegistry.sol";

/// @notice Deploys an instance of {Container} and enables initial module(s)
contract DeployContainer is BaseScript {
    function run(
        DockRegistry dockRegistry,
        address initialOwner,
        uint256 dockId,
        address[] memory initialModules
    ) public virtual broadcast returns (Container container) {
        // Deploy a new {Container} through the {DockRegistry}
        container = dockRegistry.createContainer(dockId, initialOwner, initialModules);
    }
}
