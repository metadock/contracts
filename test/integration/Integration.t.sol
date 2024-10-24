// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Base_Test } from "../Base.t.sol";
import { InvoiceModule } from "./../../src/modules/invoice-module/InvoiceModule.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/src/SablierV2LockupLinear.sol";
import { SablierV2LockupTranched } from "@sablier/v2-core/src/SablierV2LockupTranched.sol";
import { NFTDescriptorMock } from "@sablier/v2-core/test/mocks/NFTDescriptorMock.sol";
import { MockStreamManager } from "../mocks/MockStreamManager.sol";
import { MockBadWorkspace } from "../mocks/MockBadWorkspace.sol";
import { Workspace } from "./../../src/Workspace.sol";

abstract contract Integration_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    InvoiceModule internal invoiceModule;
    // Sablier V2 related test contracts
    NFTDescriptorMock internal mockNFTDescriptor;
    SablierV2LockupLinear internal sablierV2LockupLinear;
    SablierV2LockupTranched internal sablierV2LockupTranched;
    MockStreamManager internal mockStreamManager;
    MockBadWorkspace internal badWorkspace;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Deploy the {InvoiceModule} modul
        deployInvoiceModule();

        // Setup the initial {InvoiceModule} module to be initialized on the {Workspace}
        address[] memory modules = new address[](1);
        modules[0] = address(invoiceModule);

        // Deploy the {Workspace} contract with the {InvoiceModule} enabled by default
        workspace = deployWorkspace({ _owner: users.eve, _dockId: 0, _initialModules: modules });

        // Deploy a "bad" {Workspace} with the `mockBadReceiver` as the owner
        badWorkspace = deployBadWorkspace({ _owner: address(mockBadReceiver), _dockId: 0, _initialModules: modules });

        // Deploy the mock {StreamManager}
        mockStreamManager = new MockStreamManager(sablierV2LockupLinear, sablierV2LockupTranched, users.admin);

        // Label the test contracts so we can easily track them
        vm.label({ account: address(invoiceModule), newLabel: "InvoiceModule" });
        vm.label({ account: address(sablierV2LockupLinear), newLabel: "SablierV2LockupLinear" });
        vm.label({ account: address(sablierV2LockupTranched), newLabel: "SablierV2LockupTranched" });
        vm.label({ account: address(workspace), newLabel: "Eve's Workspace" });
        vm.label({ account: address(badWorkspace), newLabel: "Bad receiver's Workspace" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            DEPLOYMENT-RELATED FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Deploys the {InvoiceModule} module by initializing the Sablier v2-required contracts first
    function deployInvoiceModule() internal {
        mockNFTDescriptor = new NFTDescriptorMock();
        sablierV2LockupLinear =
            new SablierV2LockupLinear({ initialAdmin: users.admin, initialNFTDescriptor: mockNFTDescriptor });
        sablierV2LockupTranched = new SablierV2LockupTranched({
            initialAdmin: users.admin,
            initialNFTDescriptor: mockNFTDescriptor,
            maxTrancheCount: 1000
        });
        invoiceModule = new InvoiceModule({
            _sablierLockupLinear: sablierV2LockupLinear,
            _sablierLockupTranched: sablierV2LockupTranched,
            _brokerAdmin: users.admin,
            _URI: "ipfs://CID/"
        });
    }
}
