// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

/// @title IOwnable
/// @notice Contract that provides owner-based management permissions
interface IOwnable {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the address of the owner is updated
    /// @param oldOwner The address of the previous owner
    /// @param newOwner The address of the new owner
    event OwnershipTransferred(address indexed oldOwner, address newOwner);

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the account that has owner-based management permissions
    function owner() external view returns (address owner);

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Transfers the ownership from the current owner to the `newOwner` address
    ///
    /// Notes:
    /// - Reverts if the `newOwner` is the zero address
    ///
    /// Requirements:
    /// - `msg.sender` must be the current owner
    ///
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external;
}
