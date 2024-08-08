// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Options } from "./../lib/openzeppelin-foundry-upgrades/src/Options.sol";
import { Core } from "./../lib/openzeppelin-foundry-upgrades/src/internal/Core.sol";

import { BaseScript } from "./Base.s.sol";
import { DockRegistry } from "./../src/DockRegistry.sol";
import { ModuleKeeper } from "./../src/ModuleKeeper.sol";

/// @notice Deploys at deterministic addresses across chains an instance of {DockRegistry}
/// @dev Reverts if any contract has already been deployed
contract DeployDeterministicDockRegistry is BaseScript {
    /// @dev By using a salt, Forge will deploy the contract via a deterministic CREATE2 factory
    /// https://book.getfoundry.sh/tutorials/create2-tutorial?highlight=deter#deterministic-deployment-using-create2
    function run(
        string memory create2Salt,
        address initialOwner,
        ModuleKeeper moduleKeeper
    ) public virtual broadcast returns (DockRegistry dockRegistry) {
        bytes32 salt = bytes32(abi.encodePacked(create2Salt));

        // Deterministically deploy a {DockRegistry} contract
        dockRegistry = DockRegistry(
            deployDetermisticUUPSProxy(
                salt, "DockRegistry.sol", abi.encodeCall(DockRegistry.initialize, (initialOwner, moduleKeeper))
            )
        );
    }

    /// @dev Deploys a UUPS proxy at deterministic addresses across chains based on a provided salt
    /// @param salt Salt to use for deterministic deployment
    /// @param contractName The name of the implementation contract
    /// @param initializerData The ABI encoded call to be made to the initialize method
    function deployDetermisticUUPSProxy(
        bytes32 salt,
        string memory contractName,
        bytes memory initializerData
    ) internal returns (address) {
        Options memory opts;
        address impl = Core.deployImplementation(contractName, opts);

        return address(new ERC1967Proxy{ salt: salt }(impl, initializerData));
    }
}
