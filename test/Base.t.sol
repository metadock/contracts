// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Events } from "./utils/Events.sol";
import { Users } from "./utils/Types.sol";
import { Test } from "forge-std/Test.sol";
import { MockERC20NoReturn } from "./mocks/MockERC20NoReturn.sol";
import { MockModule } from "./mocks/MockModule.sol";
import { Container } from "./../src/Container.sol";
import { InvoiceModule } from "./../src/modules/invoice-module/InvoiceModule.sol";
import { SablierV2LockupLinear } from "@sablier/v2-core/src/SablierV2LockupLinear.sol";
import { SablierV2LockupTranched } from "@sablier/v2-core/src/SablierV2LockupTranched.sol";
import { SablierV2Lockup } from "@sablier/v2-core/src/abstracts/SablierV2Lockup.sol";
import { NFTDescriptorMock } from "@sablier/v2-core/test/mocks/NFTDescriptorMock.sol";

abstract contract Base_Test is Test, Events {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    InvoiceModule internal invoiceModule;
    Container internal container;
    MockERC20NoReturn internal usdt;
    MockModule internal mockModule;

    // Sablier V2 related test contracts
    NFTDescriptorMock internal mockNFTDescriptor;
    SablierV2LockupLinear internal sablierV2LockupLinear;
    SablierV2LockupTranched internal sablierV2LockupTranched;
    SablierV2Lockup internal sablier;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Deploy the mock USDT contract to deal it to the users
        usdt = new MockERC20NoReturn("Tether USD", "USDT", 6);

        // Create test users
        users = Users({ admin: createUser("admin"), eve: createUser("eve"), bob: createUser("bob") });

        // Deploy test contracts
        mockModule = new MockModule();

        // Label the test contracts so we can easily track them
        vm.label({ account: address(usdt), newLabel: "USDT" });
        vm.label({ account: address(mockModule), newLabel: "MockModule" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            DEPLOYMENT-RELATED FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Deploys a new {Container} contract based on the provided `owner` and `initialModules` input params
    function deployContainer(address owner, address[] memory initialModules) internal returns (Container _container) {
        _container = new Container(owner, initialModules);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    OTHER HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Generates a user, labels its address, and funds it with test assets
    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({ account: user, newBalance: 100 ether });
        deal({ token: address(usdt), to: user, give: 1000000e6 });

        return user;
    }
}
