// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud60x18, UD60x18 } from "@prb/math/src/UD60x18.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ILockupStreamCreator } from "./interfaces/ILockupStreamCreator.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { Errors } from "./libraries/Errors.sol";

/// @title LockupStreamCreator
/// @dev See the documentation in {ILockupStreamCreator}
contract LockupStreamCreator is ILockupStreamCreator {
    /*//////////////////////////////////////////////////////////////////////////
                                  PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ILockupStreamCreator
    ISablierV2LockupLinear public immutable override LOCKUP_LINEAR;

    /// @inheritdoc ILockupStreamCreator
    address public override brokerAdmin;

    /// @inheritdoc ILockupStreamCreator
    UD60x18 public brokerFee;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the address of the {SablierV2LockupLinear} contract and the address of the broker admin account or contract
    constructor(address _sablierLockupDeployment, address _brokerAdmin) {
        LOCKUP_LINEAR = ISablierV2LockupLinear(_sablierLockupDeployment);
        brokerAdmin = _brokerAdmin;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if the `msg.sender` is not the broker admin account or contract
    modifier onlyBrokerAdmin() {
        if (msg.sender != brokerAdmin) revert Errors.OnlyBrokerAdmin();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Creates either a Lockup Linear or Dynamic stream
    function createStream(
        IERC20 asset,
        uint128 totalAmount,
        LockupLinear.Durations memory durations,
        address recipient
    ) public returns (uint256 streamId) {
        // Transfer the provided amount of ERC-20 tokens to this contract
        asset.transferFrom(msg.sender, address(this), totalAmount);

        // Approve the Sablier contract to spend the ERC-20 tokens
        asset.approve(address(LOCKUP_LINEAR), totalAmount);

        // Create the Lockup Linear stream
        streamId = _createLinearStream(asset, totalAmount, durations, recipient);
    }

    /// @dev Updates the fee charged by the broker
    function updateBrokerFee(UD60x18 newBrokerFee) public onlyBrokerAdmin {
        // Log the broker fee update
        emit BrokerFeeUpdated({ oldFee: brokerFee, newFee: newBrokerFee });

        // Update the fee charged by the broker
        brokerFee = newBrokerFee;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    INTERNAL-METHODS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Creates a Lockup Linear stream
    /// See https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-linear
    function _createLinearStream(
        IERC20 asset,
        uint128 totalAmount,
        LockupLinear.Durations memory durations,
        address recipient
    ) internal returns (uint256 streamId) {
        // Declare the params struct
        LockupLinear.CreateWithDurations memory params;

        // Declare the function parameters
        params.sender = msg.sender; // The sender will be able to cancel the stream
        params.recipient = recipient; // The recipient of the streamed assets
        params.totalAmount = totalAmount; // Total amount is the amount inclusive of all fees
        params.asset = asset; // The streaming asset
        params.cancelable = true; // Whether the stream will be cancelable or not
        params.transferable = true; // Whether the stream will be transferable or not
        params.durations = LockupLinear.Durations({
            cliff: durations.cliff, // Assets will be unlocked only after x period of time
            total: durations.total // Setting a total duration of x period of time
        });
        params.broker = Broker({ account: brokerAdmin, fee: brokerFee }); // Optional parameter for charging a fee

        // Create the LockupLinear stream using a function that sets the start time to `block.timestamp`
        streamId = LOCKUP_LINEAR.createWithDurations(params);
    }
}
