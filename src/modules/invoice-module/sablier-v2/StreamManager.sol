// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import { LockupLinear, LockupTranched } from "@sablier/v2-core/src/types/DataTypes.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud60x18, UD60x18 } from "@prb/math/src/UD60x18.sol";

import { IStreamManager } from "./interfaces/IStreamManager.sol";
import { Errors } from "./../libraries/Errors.sol";
import { Types } from "./../libraries/Types.sol";

/// @title StreamManager
/// @dev See the documentation in {IStreamManager}
contract StreamManager is IStreamManager {
    /*//////////////////////////////////////////////////////////////////////////
                                  PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamManager
    ISablierV2LockupLinear public immutable override LOCKUP_LINEAR;

    /// @inheritdoc IStreamManager
    ISablierV2LockupTranched public immutable override LOCKUP_TRANCHED;

    /// @inheritdoc IStreamManager
    address public override brokerAdmin;

    /// @inheritdoc IStreamManager
    UD60x18 public override brokerFee;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the address of the {SablierV2LockupLinear} and {SablierV2LockupTranched} contracts
    /// and the address of the broker admin account or contract
    constructor(
        ISablierV2LockupLinear _sablierLockupLinear,
        ISablierV2LockupTranched _sablierLockupTranched,
        address _brokerAdmin
    ) {
        LOCKUP_LINEAR = _sablierLockupLinear;
        LOCKUP_TRANCHED = _sablierLockupTranched;
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

    /// @inheritdoc IStreamManager
    function createLinearStream(
        IERC20 asset,
        uint128 totalAmount,
        uint40 startTime,
        uint40 endTime,
        address recipient
    ) public returns (uint256 streamId) {
        // Transfer the provided amount of ERC-20 tokens to this contract and approve the Sablier contract to spend it
        _transferFromAndApprove({ asset: asset, amount: totalAmount, spender: address(LOCKUP_LINEAR) });

        // Create the Lockup Linear stream
        streamId = _createLinearStream(asset, totalAmount, startTime, endTime, recipient);
    }

    /// @inheritdoc IStreamManager
    function createTranchedStream(
        IERC20 asset,
        uint128 totalAmount,
        uint40 startTime,
        address recipient,
        uint128 numberOfTranches,
        Types.Recurrence recurrence
    ) public returns (uint256 streamId) {
        // Transfer the provided amount of ERC-20 tokens to this contract and approve the Sablier contract to spend it
        _transferFromAndApprove({ asset: asset, amount: totalAmount, spender: address(LOCKUP_TRANCHED) });

        // Create the Lockup Linear stream
        streamId = _createTranchedStream(asset, totalAmount, startTime, recipient, numberOfTranches, recurrence);
    }

    /// @inheritdoc IStreamManager
    function updateStreamBrokerFee(UD60x18 newBrokerFee) public onlyBrokerAdmin {
        // Log the broker fee update
        emit BrokerFeeUpdated({ oldFee: brokerFee, newFee: newBrokerFee });

        // Update the fee charged by the broker
        brokerFee = newBrokerFee;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                WITHDRAW FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamManager
    function withdrawLinearStream(uint256 streamId, address to, uint128 amount) public {
        _withdrawStream({ sablier: LOCKUP_LINEAR, streamId: streamId, to: to, amount: amount });
    }

    /// @inheritdoc IStreamManager
    function withdrawTranchedStream(uint256 streamId, address to, uint128 amount) public {
        _withdrawStream({ sablier: LOCKUP_TRANCHED, streamId: streamId, to: to, amount: amount });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CANCEL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamManager
    function cancelLinearStream(uint256 streamId) public {
        _cancelStream({ sablier: LOCKUP_LINEAR, streamId: streamId });
    }

    /// @inheritdoc IStreamManager
    function cancelTranchedStream(uint256 streamId) public {
        _cancelStream({ sablier: LOCKUP_TRANCHED, streamId: streamId });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamManager
    function getLinearStream(uint256 streamId) public view returns (LockupLinear.StreamLL memory stream) {
        stream = LOCKUP_LINEAR.getStream(streamId);
    }

    /// @inheritdoc IStreamManager
    function getTranchedStream(uint256 streamId) public view returns (LockupTranched.StreamLT memory stream) {
        stream = LOCKUP_TRANCHED.getStream(streamId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
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
        address recipient,
        uint128 numberOfTranches,
        Types.Recurrence recurrence
    ) internal returns (uint256 streamId) {
        // Declare the params struct
        LockupTranched.CreateWithTimestamps memory params;

        // Declare the function parameters
        params.sender = msg.sender; // The sender will be able to cancel the stream
        params.recipient = recipient; // The recipient of the streamed assets
        params.totalAmount = totalAmount; // Total amount is the amount inclusive of all fees
        params.asset = asset; // The streaming asset
        params.cancelable = true; // Whether the stream will be cancelable or not
        params.transferable = true; // Whether the stream will be transferable or not

        // Calculate the duration of each tranche based on the payment recurrence
        uint40 durationPerTranche = _computeDurationPerTrache(recurrence);

        // Calculate the amount that must be unlocked with each tranche
        uint128 amountPerTranche = totalAmount / numberOfTranches;

        // Create the tranches array
        params.tranches = new LockupTranched.Tranche[](numberOfTranches);
        for (uint256 i; i < numberOfTranches; ++i) {
            params.tranches[i] = LockupTranched.Tranche({
                amount: amountPerTranche,
                timestamp: startTime + durationPerTranche
            });

            // Jump to the next tranche by adding the duration per tranche timestamp to the start time
            startTime += durationPerTranche;
        }

        // Optional parameter for charging a fee
        params.broker = Broker({ account: brokerAdmin, fee: brokerFee });

        // Create the LockupTranched stream
        streamId = LOCKUP_TRANCHED.createWithTimestamps(params);
    }

    /// @dev Withdraws from either a linear or tranched stream
    function _withdrawStream(ISablierV2Lockup sablier, uint256 streamId, address to, uint128 amount) internal {
        sablier.withdraw(streamId, to, amount);
    }

    /// @dev Cancels the `streamId` stream
    function _cancelStream(ISablierV2Lockup sablier, uint256 streamId) internal {
        sablier.cancel(streamId);
    }

    /// @dev Transfers the `amount` of `asset` tokens to this address (or the contract inherting from)
    /// and approves either the `SablierV2LockupLinear` or `SablierV2LockupTranched` to spend the amount
    function _transferFromAndApprove(IERC20 asset, uint128 amount, address spender) internal {
        // Transfer the provided amount of ERC-20 tokens to this contract
        asset.transferFrom(msg.sender, address(this), amount);

        // Approve the Sablier contract to spend the ERC-20 tokens
        asset.approve(spender, amount);
    }

    /// @dev Calculates the duration of each tranches from a tranched stream based on a recurrence
    function _computeDurationPerTrache(Types.Recurrence recurrence) internal pure returns (uint40 duration) {
        if (recurrence == Types.Recurrence.Weekly) duration = 1 weeks;
        else if (recurrence == Types.Recurrence.Monthly) duration = 4 weeks;
        else if (recurrence == Types.Recurrence.Yearly) duration = 48 weeks;
    }
}
