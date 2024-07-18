// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";

import { Types } from "./libraries/Types.sol";
import { Errors } from "./libraries/Errors.sol";
import { IInvoiceModule } from "./interfaces/IInvoiceModule.sol";
import { IContainer } from "./../../interfaces/IContainer.sol";
import { StreamManager } from "./sablier-v2/StreamManager.sol";
import { Helpers } from "./libraries/Helpers.sol";

/// @title InvoiceModule
/// @notice See the documentation in {IInvoiceModule}
contract InvoiceModule is IInvoiceModule, StreamManager {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  PRIVATE STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Array with invoice IDs created through the `container` container contract
    mapping(address container => uint256[]) private _invoicesOf;

    /// @dev Invoice details mapped by the `id` invoice ID
    mapping(uint256 id => Types.Invoice) private _invoices;

    /// @dev Counter to keep track of the next ID used to create a new invoice
    uint256 private _nextInvoiceId;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the {StreamManager} contract
    constructor(
        ISablierV2LockupLinear _sablierLockupLinear,
        ISablierV2LockupTranched _sablierLockupTranched,
        address _brokerAdmin
    ) StreamManager(_sablierLockupLinear, _sablierLockupTranched, _brokerAdmin) {}

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Allow only calls from contracts implementing the {IContainer} interface
    modifier onlyContainer() {
        // Checks: the sender is a valid non-zero code size contract
        if (msg.sender.code.length == 0) {
            revert Errors.ContainerZeroCodeSize();
        }

        // Checks: the sender implements the ERC-165 interface required by {IContainer}
        bytes4 interfaceId = type(IContainer).interfaceId;
        if (!IContainer(msg.sender).supportsInterface(interfaceId)) revert Errors.ContainerUnsupportedInterface();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IInvoiceModule
    function getInvoice(uint256 id) external view returns (Types.Invoice memory invoice) {
        return _invoices[id];
    }

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IInvoiceModule
    function createInvoice(Types.Invoice calldata invoice) external onlyContainer returns (uint256 id) {
        // Checks: the amount is non-zero
        if (invoice.payment.amount == 0) {
            revert Errors.ZeroPaymentAmount();
        }

        // Checks: the start time is stricly lower than the end time
        if (invoice.startTime > invoice.endTime) {
            revert Errors.StartTimeGreaterThanEndTime();
        }

        // Checks: end time is not in the past
        uint40 currentTime = uint40(block.timestamp);
        if (currentTime >= invoice.endTime) {
            revert Errors.EndTimeInThePast();
        }

        // Checks: the recurrence type is not equal to one-off if dealing with a tranched stream-based invoice
        if (invoice.payment.method == Types.Method.TranchedStream) {
            // The recurrence cannot be set to one-off
            if (invoice.payment.recurrence == Types.Recurrence.OneOff) {
                revert Errors.TranchedStreamInvalidOneOffRecurence();
            }
        }

        // Validates the invoice interval (endTime - startTime) and returns the number of payments of the invoice
        // based on the payment method, interval and recurrence type
        //
        // Notes:
        // - The number of payments is taken into account only for transfer-based invoices
        // - There should be only one payment when dealing with a one-off transfer-based invoice
        // - When dealing with a recurring transfer, the number of payments must be calculated based
        // on the payment interval (endTime - startTime) and recurrence type
        uint40 numberOfPayments;
        if (invoice.payment.method == Types.Method.Transfer && invoice.payment.recurrence == Types.Recurrence.OneOff) {
            numberOfPayments = 1;
        } else if (invoice.payment.method != Types.Method.LinearStream) {
            numberOfPayments = _checkIntervalPayments({
                recurrence: invoice.payment.recurrence,
                startTime: invoice.startTime,
                endTime: invoice.endTime
            });

            // Set the number of payments to zero if dealing with a tranched-based invoice
            if (invoice.payment.method == Types.Method.TranchedStream) numberOfPayments = 0;
        }

        // Checks: the asset is different than the native token if dealing with either a linear or tranched stream-based invoice
        if (invoice.payment.method != Types.Method.Transfer) {
            if (invoice.payment.asset == address(0)) {
                revert Errors.OnlyERC20StreamsAllowed();
            }
        }

        // Get the next invoice ID
        id = _nextInvoiceId;

        // Effects: create the invoice
        _invoices[id] = Types.Invoice({
            recipient: invoice.recipient,
            status: Types.Status.Pending,
            startTime: invoice.startTime,
            endTime: invoice.endTime,
            payment: Types.Payment({
                recurrence: invoice.payment.recurrence,
                method: invoice.payment.method,
                paymentsLeft: numberOfPayments,
                amount: invoice.payment.amount,
                asset: invoice.payment.asset,
                streamId: 0
            })
        });

        // Effects: increment the next invoice id
        // Use unchecked because the invoice id cannot realistically overflow
        unchecked {
            _nextInvoiceId = id + 1;
        }

        // Effects: add the invoice on the list of invoices generated by the container
        _invoicesOf[invoice.recipient].push(id);

        // Log the invoice creation
        emit InvoiceCreated({
            id: id,
            recipient: invoice.recipient,
            status: Types.Status.Pending,
            startTime: invoice.startTime,
            endTime: invoice.endTime,
            payment: invoice.payment
        });
    }

    /// @inheritdoc IInvoiceModule
    function payInvoice(uint256 id) external payable {
        // Load the invoice from storage
        Types.Invoice memory invoice = _invoices[id];

        // Checks: the invoice is not null
        if (invoice.recipient == address(0)) {
            revert Errors.InvoiceNull();
        }

        // Checks: the invoice is not already paid or canceled
        if (invoice.status == Types.Status.Paid) {
            revert Errors.InvoiceAlreadyPaid();
        } else if (invoice.status == Types.Status.Canceled) {
            revert Errors.InvoiceCanceled();
        }

        // Handle the payment workflow depending on the payment method type
        if (invoice.payment.method == Types.Method.Transfer) {
            // Effects: pay the invoice and update its status to `Paid` or `Ongoing` depending on the payment type
            _payByTransfer(id, invoice);
        } else {
            uint256 streamId;
            // Check to see whether the invoice must be paid through a linear or tranched stream
            if (invoice.payment.method == Types.Method.LinearStream) {
                streamId = _payByLinearStream(invoice);
            } else streamId = _payByTranchedStream(invoice);

            // Effects: update the status of the invoice to `Ongoing` and the stream ID
            // if dealing with a linear or tranched-based invoice
            _invoices[id].status = Types.Status.Ongoing;
            _invoices[id].payment.streamId = streamId;
        }

        // Log the payment transaction
        emit InvoicePaid({ id: id, payer: msg.sender, status: _invoices[id].status, payment: _invoices[id].payment });
    }

    /// @inheritdoc IInvoiceModule
    function cancelInvoice(uint256 id) external {
        // Load the invoice from storage
        Types.Invoice memory invoice = _invoices[id];

        // Checks: the invoice is paid or already canceled
        if (invoice.status == Types.Status.Paid) {
            revert Errors.CannotCancelPaidInvoice();
        } else if (invoice.status == Types.Status.Canceled) {
            revert Errors.CannotCancelCanceledInvoice();
        }

        // Checks: the `msg.sender` is the creator if dealing with a transfer-based invoice
        //
        // Notes:
        // - for a linear or tranched stream-based invoice, the `msg.sender` is checked in the
        // {SablierV2Lockup} `cancel` method
        if (invoice.payment.method == Types.Method.Transfer) {
            if (invoice.recipient != msg.sender) {
                revert Errors.InvoiceOwnerUnauthorized();
            }
        }

        // Effects: cancel the stream accordingly depending on its type
        if (invoice.payment.method == Types.Method.LinearStream) {
            cancelLinearStream({ streamId: invoice.payment.streamId });
        } else if (invoice.payment.method == Types.Method.TranchedStream) {
            cancelTranchedStream({ streamId: invoice.payment.streamId });
        }

        // Effects: mark the invoice as canceled
        _invoices[id].status = Types.Status.Canceled;

        // Log the invoice cancelation
        emit InvoiceCanceled(id);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    INTERNAL-METHODS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Pays the `id` invoice by transfer
    function _payByTransfer(uint256 id, Types.Invoice memory invoice) internal {
        // Effects: update the invoice status to `Paid` if the required number of payments has been made
        // Using unchecked because the number of payments left cannot underflow as the invoice status
        // will be updated to `Paid` once `paymentLeft` is zero
        unchecked {
            uint40 paymentsLeft = invoice.payment.paymentsLeft - 1;
            _invoices[id].payment.paymentsLeft = paymentsLeft;
            if (paymentsLeft == 0) {
                _invoices[id].status = Types.Status.Paid;
            } else if (invoice.status == Types.Status.Pending) {
                _invoices[id].status = Types.Status.Ongoing;
            }
        }

        // Check if the payment must be done in native token (ETH) or an ERC-20 token
        if (invoice.payment.asset == address(0)) {
            // Checks: the payment amount matches the invoice value
            if (msg.value < invoice.payment.amount) {
                revert Errors.PaymentAmountLessThanInvoiceValue({ amount: invoice.payment.amount });
            }

            // Interactions: pay the recipient with native token (ETH)
            (bool success, ) = payable(invoice.recipient).call{ value: invoice.payment.amount }("");
            if (!success) revert Errors.NativeTokenPaymentFailed();
        } else {
            // Interactions: pay the recipient with the ERC-20 token
            IERC20(invoice.payment.asset).safeTransferFrom({
                from: msg.sender,
                to: address(invoice.recipient),
                value: invoice.payment.amount
            });
        }
    }

    /// @dev Create the linear stream payment
    function _payByLinearStream(Types.Invoice memory invoice) internal returns (uint256 streamId) {
        streamId = StreamManager.createLinearStream({
            asset: IERC20(invoice.payment.asset),
            totalAmount: invoice.payment.amount,
            startTime: invoice.startTime,
            endTime: invoice.endTime,
            recipient: invoice.recipient
        });
    }

    /// @dev Create the tranched stream payment
    function _payByTranchedStream(Types.Invoice memory invoice) internal returns (uint256 streamId) {
        uint40 numberOfTranches = Helpers.computeNumberOfPayments(
            invoice.payment.recurrence,
            invoice.endTime - invoice.startTime
        );

        streamId = StreamManager.createTranchedStream({
            asset: IERC20(invoice.payment.asset),
            totalAmount: invoice.payment.amount,
            startTime: invoice.startTime,
            recipient: invoice.recipient,
            numberOfTranches: numberOfTranches,
            recurrence: invoice.payment.recurrence
        });
    }

    /// @notice Calculates the number of payments to be made for a recurring transfer and tranched stream-based invoice
    /// @dev Reverts if the number of payments is zero, indicating that either the interval or recurrence type was set incorrectly
    function _checkIntervalPayments(
        Types.Recurrence recurrence,
        uint40 startTime,
        uint40 endTime
    ) internal pure returns (uint40 numberOfPayments) {
        // Checks: the invoice payment interval matches the recurrence type
        // This cannot underflow as the start time is stricly lower than the end time when this call executes
        uint40 interval;
        unchecked {
            interval = endTime - startTime;
        }

        // Check and calculate the expected number of payments based on the invoice recurrence and payment interval
        numberOfPayments = Helpers.computeNumberOfPayments(recurrence, interval);

        // Revert if there are zero payments to be made since the payment method due to invalid interval and recurrence type
        if (numberOfPayments == 0) {
            revert Errors.PaymentIntervalTooShortForSelectedRecurrence();
        }
    }
}
