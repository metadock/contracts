// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Events } from "./utils/Events.sol";
import { Users } from "./utils/Types.sol";
import { Test } from "forge-std/Test.sol";
import { MockERC20NoReturn } from "./mocks/MockERC20NoReturn.sol";
import { Container } from "./../src/Container.sol";
import { InvoiceModule } from "./../src/modules/invoice-module/InvoiceModule.sol";

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

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Deploy test contracts
        usdt = new MockERC20NoReturn("Tether USD", "USDT", 6);
        invoiceModule = new InvoiceModule();

        // Label the test contracts so we can easily track them
        vm.label({ account: address(usdt), newLabel: "USDT" });
        vm.label({ account: address(invoiceModule), newLabel: "InvoiceModule" });

        // Create test users
        users = Users({ eve: createUser("eve"), bob: createUser("bob") });
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
        deal({ token: address(usdt), to: user, give: 1000000e16 });

        return user;
    }
}
