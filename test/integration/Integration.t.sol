// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Base_Test } from "../Base.t.sol";
import { InvoiceModule } from "./../../src/modules/invoice-module/InvoiceModule.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/src/SablierV2LockupLinear.sol";
import { SablierV2LockupTranched } from "@sablier/v2-core/src/SablierV2LockupTranched.sol";
import { NFTDescriptorMock } from "@sablier/v2-core/test/mocks/NFTDescriptorMock.sol";

abstract contract Integration_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    InvoiceModule internal invoiceModule;
    // Sablier V2 related test contracts
    NFTDescriptorMock internal mockNFTDescriptor;
    SablierV2LockupLinear internal sablierV2LockupLinear;
    SablierV2LockupTranched internal sablierV2LockupTranched;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Deploy the {InvoiceModule} modul
        deployInvoiceModule();

        // Make Eve the default caller to deploy a new {Container} contract
        vm.startPrank({ msgSender: users.eve });

        // Setup the initial {InvoiceModule} module to be initialized on the {Container}
        address[] memory modules = new address[](1);
        modules[0] = address(invoiceModule);

        // Deploy the {Container} contract with the {InvoiceModule} enabled by default
        container = deployContainer({ owner: users.eve, initialModules: modules });

        // Stop the prank to be able to start a different one in the test suite
        vm.stopPrank();

        // Label the test contracts so we can easily track them
        vm.label({ account: address(invoiceModule), newLabel: "InvoiceModule" });
        vm.label({ account: address(sablierV2LockupLinear), newLabel: "SablierV2LockupLinear" });
        vm.label({ account: address(sablierV2LockupTranched), newLabel: "SablierV2LockupTranched" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            DEPLOYMENT-RELATED FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Deploys the {InvoiceModule} module by initializing the Sablier v2-required contracts first
    function deployInvoiceModule() internal {
        mockNFTDescriptor = new NFTDescriptorMock();
        sablierV2LockupLinear = new SablierV2LockupLinear({
            initialAdmin: users.admin,
            initialNFTDescriptor: mockNFTDescriptor
        });
        sablierV2LockupTranched = new SablierV2LockupTranched({
            initialAdmin: users.admin,
            initialNFTDescriptor: mockNFTDescriptor,
            maxTrancheCount: 1000
        });
        invoiceModule = new InvoiceModule({
            _sablierLockupLinear: sablierV2LockupLinear,
            _sablierLockupTranched: sablierV2LockupTranched,
            _brokerAdmin: users.admin
        });
    }
}
