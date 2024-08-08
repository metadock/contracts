// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { BaseScript } from "./Base.s.sol";
import { Container } from "../src/Container.sol";
import { ModuleKeeper } from "./../src/ModuleKeeper.sol";

/// @notice Deploys an instance of {Container} and enables initial module(s)
contract DeployContainer is BaseScript {
    function run(
        address initialOwner,
        ModuleKeeper moduleKeeper,
        address[] memory initialModules
    ) public virtual broadcast returns (Container container) {
        // Ddeploy the {InvoiceModule} contracts
        container = new Container(initialOwner, moduleKeeper, initialModules);
    }
}
