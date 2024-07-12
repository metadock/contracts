// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { LockupLinear, LockupTranched } from "@sablier/v2-core/src/types/DataTypes.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud60x18, UD60x18 } from "@prb/math/src/UD60x18.sol";

import { IStreamCreator } from "./interfaces/IStreamCreator.sol";
import { StreamManager } from "./StreamManager.sol";
import { Helpers } from "./../libraries/Helpers.sol";
import { Errors } from "./../libraries/Errors.sol";
import { Types } from "./../libraries/Types.sol";

/// @title StreamCreator
/// @dev See the documentation in {IStreamCreator}
contract StreamCreator is IStreamCreator, StreamManager {
    /*//////////////////////////////////////////////////////////////////////////
                                  PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamCreator
    ISablierV2LockupLinear public immutable override LOCKUP_LINEAR;

    /// @inheritdoc IStreamCreator
    ISablierV2LockupTranched public immutable override LOCKUP_TRANCHED;

    /// @inheritdoc IStreamCreator
    address public override brokerAdmin;

    /// @inheritdoc IStreamCreator
    UD60x18 public override brokerFee;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the address of the {SablierV2LockupLinear} contract and the address of the broker admin account or contract
    constructor(
        ISablierV2Lockup _sablier,
        ISablierV2LockupLinear _sablierLockupLinearDeployment,
        ISablierV2LockupTranched _sablierLockupTranchedDeployment,
        address _brokerAdmin
    ) StreamManager(_sablier) {
        LOCKUP_LINEAR = _sablierLockupLinearDeployment;
        LOCKUP_TRANCHED = _sablierLockupTranchedDeployment;
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

    /// @inheritdoc IStreamCreator
    function createLinearStream(
        IERC20 asset,
        uint128 totalAmount,
        uint40 startTime,
        uint40 endTime,
        address recipient
    ) public returns (uint256 streamId) {
        // Transfer the provided amount of ERC-20 tokens to this contract and approve the Sablier contract to spend it
        _transferFromAndApprove({ asset: asset, spender: address(LOCKUP_LINEAR), amount: totalAmount });

        // Create the Lockup Linear stream
        streamId = _createLinearStream(asset, totalAmount, startTime, endTime, recipient);
    }

    /// @inheritdoc IStreamCreator
    function createTranchedStream(
        IERC20 asset,
        uint128 totalAmount,
        uint40 startTime,
        uint40 endTime,
        address recipient,
        Types.Recurrence recurrence
    ) public returns (uint256 streamId) {
        // Transfer the provided amount of ERC-20 tokens to this contract and approve the Sablier contract to spend it
        _transferFromAndApprove({ asset: asset, spender: address(LOCKUP_TRANCHED), amount: totalAmount });

        // Create the Lockup Linear stream
        streamId = _createTranchedStream(asset, totalAmount, startTime, endTime, recipient, recurrence);
    }

    /// @inheritdoc IStreamCreator
    function updateBrokerFee(UD60x18 newBrokerFee) public onlyBrokerAdmin {
        // Log the broker fee update
        emit BrokerFeeUpdated({ oldFee: brokerFee, newFee: newBrokerFee });

        // Update the fee charged by the broker
        brokerFee = newBrokerFee;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    INTERNAL-METHODS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a Lockup Linear stream
    /// See https://docs.sablier.com/concepts/protocol/stream-types#lockup-linear
    /// @dev See https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-linear
    function _createLinearStream(
        IERC20 asset,
        uint128 totalAmount,
        uint40 startTime,
        uint40 endTime,
        address recipient
    ) internal returns (uint256 streamId) {
        // Declare the params struct
        LockupLinear.CreateWithTimestamps memory params;

        // Declare the function parameters
        params.sender = msg.sender; // The sender will be able to cancel the stream
        params.recipient = recipient; // The recipient of the streamed assets
        params.totalAmount = totalAmount; // Total amount is the amount inclusive of all fees
        params.asset = asset; // The streaming asset
        params.cancelable = true; // Whether the stream will be cancelable or not
        params.transferable = true; // Whether the stream will be transferable or not
        params.timestamps = LockupLinear.Timestamps({ start: startTime, cliff: 0, end: endTime });
        params.broker = Broker({ account: brokerAdmin, fee: brokerFee }); // Optional parameter for charging a fee

        // Create the LockupLinear stream using a function that sets the start time to `block.timestamp`
        streamId = LOCKUP_LINEAR.createWithTimestamps(params);
    }

    /// @notice Creates a Lockup Tranched stream
    /// See https://docs.sablier.com/concepts/protocol/stream-types#unlock-monthly
    /// @dev See https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-linear
    function _createTranchedStream(
        IERC20 asset,
        uint128 totalAmount,
        uint40 startTime,
        uint40 endTime,
        address recipient,
        Types.Recurrence recurrence
    ) internal returns (uint256 streamId) {
        // Declare the params struct
        LockupTranched.CreateWithDurations memory params;

        // Declare the function parameters
        params.sender = msg.sender; // The sender will be able to cancel the stream
        params.recipient = recipient; // The recipient of the streamed assets
        params.totalAmount = totalAmount; // Total amount is the amount inclusive of all fees
        params.asset = asset; // The streaming asset
        params.cancelable = true; // Whether the stream will be cancelable or not
        params.transferable = true; // Whether the stream will be transferable or not

        // Calculate the number of tranches based on the payment interval and the type of recurrence
        uint128 numberOfTranches = Helpers.computeNumberOfRecurringPayments(recurrence, startTime, endTime);

        // Calculate the duration of each tranche based on the payment recurrence
        uint40 durationPerTranche = _computeDurationPerTrache(recurrence);

        // Calculate the amount that must be unlocked with each tranche
        uint128 amountPerTranche = totalAmount / numberOfTranches;

        // Create the tranches array
        params.tranches = new LockupTranched.TrancheWithDuration[](numberOfTranches);
        for (uint256 i; i < numberOfTranches; ++i) {
            params.tranches[i] = LockupTranched.TrancheWithDuration({
                amount: amountPerTranche,
                duration: durationPerTranche
            });
        }

        // Optional parameter for charging a fee
        params.broker = Broker({ account: brokerAdmin, fee: brokerFee });

        // Create the LockupTranched stream
        streamId = LOCKUP_TRANCHED.createWithDurations(params);
    }

    function _transferFromAndApprove(IERC20 asset, uint128 amount, address spender) internal {
        // Transfer the provided amount of ERC-20 tokens to this contract
        asset.transferFrom(msg.sender, address(this), amount);

        // Approve the Sablier contract to spend the ERC-20 tokens
        asset.approve(spender, amount);
    }

    function _computeDurationPerTrache(Types.Recurrence recurrence) internal pure returns (uint40 duration) {
        if (recurrence == Types.Recurrence.Weekly) duration = 1 weeks;
        else if (recurrence == Types.Recurrence.Monthly) duration = 4 weeks;
        else if (recurrence == Types.Recurrence.Yearly) duration = 48 weeks;
    }
}
