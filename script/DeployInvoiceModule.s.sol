// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import { BaseScript } from "./Base.s.sol";
import { InvoiceModule } from "../src/modules/invoice-module/InvoiceModule.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";

/// @notice Deploys and initializes the {InvoiceModule} contracts
/// @dev Reverts if any contract has already been deployed.
contract DeployInvoiceModule is BaseScript {
    function run(
        string memory create2Salt,
        ISablierV2LockupLinear sablierLockupLinear,
        ISablierV2LockupTranched sablierLockupTranched,
        address brokerAdmin
    ) public virtual broadcast returns (InvoiceModule invoiceModule) {
        bytes32 salt = bytes32(abi.encodePacked(create2Salt));

        // Deterministically deploy the {InvoiceModule} contracts
        invoiceModule = new InvoiceModule{ salt: salt }(sablierLockupLinear, sablierLockupTranched, brokerAdmin);
    }
}
