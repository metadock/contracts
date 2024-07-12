// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
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
        ISablierV2LockupLinear _sablierLockupLinearDeployment,
        ISablierV2LockupTranched _sablierLockupTranchedDeployment,
        address _brokerAdmin
    ) StreamManager(_sablierLockupLinearDeployment, _sablierLockupTranchedDeployment, _brokerAdmin) {}

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
        if (!IERC165(msg.sender).supportsInterface(interfaceId)) revert Errors.ContainerUnsupportedInterface();
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
            revert Errors.PaymentAmountZero();
        }

        // Checks: the start time is stricly lower than the end time
        if (invoice.startTime >= invoice.endTime) {
            revert Errors.StartTimeGreaterThanEndTime();
        }

        // Checks: end time is not in the past
        uint40 currentTime = uint40(block.timestamp);
        if (currentTime >= invoice.endTime) {
            revert Errors.EndTimeLowerThanCurrentTime();
        }

        // Checks: validate the input parameters if the invoice must be paid in even transfers
        if (invoice.payment.method == Types.Method.Transfer) {
            // Checks: validate the input parameters if the invoice is recurring
            if (invoice.payment.paymentsLeft > 1) {
                _checkRecurringTransferInvoiceParams({
                    recurrence: invoice.payment.recurrence,
                    paymentsLeft: invoice.payment.paymentsLeft,
                    startTime: invoice.startTime,
                    endTime: invoice.endTime
                });
            }
            // Or by using a linear or tranched stream in which case allow only ERC-20 assets
        } else if (invoice.payment.asset == address(0)) {
            revert Errors.OnlyERC20StreamsAllowed();
        }

        // Get the next invoice ID
        id = _nextInvoiceId;

        // Effects: create the invoice
        _invoices[id] = Types.Invoice({
            recipient: msg.sender,
            status: Types.Status.Pending,
            startTime: invoice.startTime,
            endTime: invoice.endTime,
            payment: Types.Payment({
                recurrence: invoice.payment.recurrence,
                method: invoice.payment.method,
                paymentsLeft: invoice.payment.paymentsLeft,
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
        _invoicesOf[msg.sender].push(id);

        // Log the invoice creation
        emit InvoiceCreated({
            id: id,
            recipient: msg.sender,
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

        // Checks: the invoice is not already paid or canceled
        if (invoice.status == Types.Status.Paid) {
            revert Errors.InvoiceAlreadyPaid();
        } else if (invoice.status == Types.Status.Canceled) {
            revert Errors.InvoiceCanceled();
        }

        // Handle the payment workflow depending on the payment method type
        if (invoice.payment.method == Types.Method.Transfer) {
            _payByTransfer(id, invoice);
        } else {
            uint256 streamId;
            // Check to see wether to pay by creating a linear or tranched stream
            if (invoice.payment.method == Types.Method.LinearStream) {
                streamId = _payByLinearStream(invoice);
            } else streamId = _payByTranchedStream(invoice);
        }

        // Log the payment transaction
        emit InvoicePaid({ id: id, payer: msg.sender, status: invoice.status, payment: invoice.payment });
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
            uint24 paymentsLeft = invoice.payment.paymentsLeft - 1;
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
                revert Errors.InvalidPaymentAmount({ amount: invoice.payment.amount });
            }

            // Interactions: pay the recipient with native token (ETH)
            (bool success, ) = payable(invoice.recipient).call{ value: invoice.payment.amount }("");
            if (!success) revert Errors.PaymentFailed();
        } else {
            // Interactions: pay the recipient with the ERC-20 token
            IERC20(invoice.payment.asset).safeTransfer({
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
        streamId = StreamManager.createTranchedStream({
            asset: IERC20(invoice.payment.asset),
            totalAmount: invoice.payment.amount,
            startTime: invoice.startTime,
            endTime: invoice.endTime,
            recipient: invoice.recipient,
            recurrence: invoice.payment.recurrence
        });
    }

    /// @dev Validates the input parameters if the invoice is recurring and must be paid in even transfers
    function _checkRecurringTransferInvoiceParams(
        Types.Recurrence recurrence,
        uint40 paymentsLeft,
        uint40 startTime,
        uint40 endTime
    ) internal pure {
        // Calculate the expected number of payments based on the invoice recurrence and payment interval
        uint40 numberOfPayments = Helpers.computeNumberOfRecurringPayments(recurrence, startTime, endTime);

        // Checks: the specified number of payments is valid
        if (paymentsLeft != numberOfPayments) {
            revert Errors.InvalidNumberOfPayments({ expectedNumber: numberOfPayments });
        }
    }
}
