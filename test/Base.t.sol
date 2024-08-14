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
import { DockRegistry } from "./../src/DockRegistry.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

abstract contract Base_Test is Test, Events {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    DockRegistry internal dockRegistry;
    Container internal container;
    ModuleKeeper internal moduleKeeper;
    MockERC20NoReturn internal usdt;
    MockModule internal mockModule;
    MockNonCompliantContainer internal mockNonCompliantContainer;
    MockBadReceiver internal mockBadReceiver;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    address[] internal mockModules;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Deploy the mock USDT contract to deal it to the users
        usdt = new MockERC20NoReturn("Tether USD", "USDT", 6);

        // Create test users
        users = Users({ admin: createUser("admin"), eve: createUser("eve"), bob: createUser("bob") });

        // Deploy test contracts
        moduleKeeper = new ModuleKeeper({ _initialOwner: users.admin });

        address implementation = address(new DockRegistry());
        bytes memory data = abi.encodeWithSelector(DockRegistry.initialize.selector, users.admin, moduleKeeper);
        dockRegistry = DockRegistry(address(new ERC1967Proxy(implementation, data)));

        mockModule = new MockModule();
        mockNonCompliantContainer = new MockNonCompliantContainer({ _owner: users.admin });
        mockBadReceiver = new MockBadReceiver();

        // Create a mock modules array
        mockModules.push(address(mockModule));

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
        uint256 _dockId,
        address[] memory _initialModules
    ) internal returns (Container _container) {
        vm.startPrank({ msgSender: users.admin });
        for (uint256 i; i < _initialModules.length; ++i) {
            allowlistModule(_initialModules[i]);
        }
        vm.stopPrank();

        vm.prank({ msgSender: _owner });
        _container =
            Container(payable(dockRegistry.createContainer({ dockId: _dockId, initialModules: _initialModules })));
        vm.stopPrank();
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

    /// @dev Predicts the address of the next contract that is going to be deployed by the `deployer`
    function computeDeploymentAddress(address deployer) internal view returns (address expectedAddress) {
        // Calculate the current nonce of the deployer account
        uint256 deployerNonce = vm.getNonce({ account: address(deployer) });

        // Pre-compute the address of the next contract to be deployed
        expectedAddress = vm.computeCreateAddress({ deployer: address(deployer), nonce: deployerNonce });
    }
}
