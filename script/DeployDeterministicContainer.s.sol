// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { BaseScript } from "./Base.s.sol";
import { Container } from "../src/Container.sol";
import { ModuleKeeper } from "./../src/ModuleKeeper.sol";

/// @notice Deploys at deterministic addresses across chains an instance of {Container} and enables initial module(s)
/// @dev Reverts if any contract has already been deployed
contract DeployDeterministicContainer is BaseScript {
    /// @dev By using a salt, Forge will deploy the contract via a deterministic CREATE2 factory
    /// https://book.getfoundry.sh/tutorials/create2-tutorial?highlight=deter#deterministic-deployment-using-create2
    function run(
        string memory create2Salt,
        address initialOwner,
        ModuleKeeper moduleKeeper,
        address[] memory initialModules
    ) public virtual broadcast returns (Container container) {
        bytes32 salt = bytes32(abi.encodePacked(create2Salt));

        // Deterministically deploy a {Container} contract
        container = new Container{ salt: salt }(initialOwner, moduleKeeper, initialModules);
    }
}
