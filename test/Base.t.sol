// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Events } from "./utils/Events.sol";
import { Users } from "./utils/Types.sol";
import { Test } from "forge-std/Test.sol";
import { MockERC20NoReturn } from "./mocks/MockERC20NoReturn.sol";
import { MockNonCompliantContainer } from "./mocks/MockNonCompliantContainer.sol";
import { MockModule } from "./mocks/MockModule.sol";
import { MockBadReceiver } from "./mocks/MockBadReceiver.sol";
import { Container } from "./../src/Container.sol";
import { ModuleKeeper } from "./../src/ModuleKeeper.sol";

abstract contract Base_Test is Test, Events {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    Container internal container;
    ModuleKeeper internal moduleKeeper;
    MockERC20NoReturn internal usdt;
    MockModule internal mockModule;
    MockNonCompliantContainer internal mockNonCompliantContainer;
    MockBadReceiver internal mockBadReceiver;

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
        mockNonCompliantContainer = new MockNonCompliantContainer({ _owner: users.admin });
        mockBadReceiver = new MockBadReceiver();
        moduleKeeper = new ModuleKeeper({ _initialOwner: users.admin });

        // Label the test contracts so we can easily track them
        vm.label({ account: address(usdt), newLabel: "USDT" });
        vm.label({ account: address(mockModule), newLabel: "MockModule" });
        vm.label({ account: address(mockNonCompliantContainer), newLabel: "MockNonCompliantContainer" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            DEPLOYMENT-RELATED FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Deploys a new {Container} contract based on the provided `owner`, `moduleKeeper` and `initialModules` input params
    function deployContainer(
        address _owner,
        ModuleKeeper _moduleKeeper,
        address[] memory _initialModules
    ) internal returns (Container _container) {
        vm.startPrank({ msgSender: users.admin });
        for (uint256 i; i < _initialModules.length; ++i) {
            allowlistModule(_initialModules[i]);
        }
        vm.stopPrank();

        _container = new Container(_owner, _moduleKeeper, _initialModules);
    }

    function allowlistModule(address _module) internal {
        moduleKeeper.addToAllowlist({ module: _module });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    OTHER HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Generates a user, labels its address, and funds it with test assets
    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({ account: user, newBalance: 100 ether });
        deal({ token: address(usdt), to: user, give: 10_000_000e18 });

        return user;
    }
}
