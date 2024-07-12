// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

/// @title IStreamManager
/// @notice Contract responsible to handle multiple management actions such as withdraw, cancel or renounce stream and transfer ownership
/// @dev This interface is a subset of the {ISablierV2Lockup} interface
interface IStreamManager {
    /*//////////////////////////////////////////////////////////////////////////
                                CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the {SablierV2Lockup} contract used to handle streams management
    function sablier() external view returns (ISablierV2Lockup);

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice See the documentation in {ISablierV2Lockup}
    function withdraw(uint256 streamId, address to, uint128 amount) external;

    /// @notice See the documentation in {ISablierV2Lockup}
    function withdrawableAmountOf(uint256 streamId) external view returns (uint128 withdrawableAmount);

    /// @notice See the documentation in {ISablierV2Lockup}
    function withdrawMax(uint256 streamId, address to) external returns (uint128 withdrawnAmount);

    /// @notice See the documentation in {ISablierV2Lockup}
    function withdrawMultiple(uint256[] calldata streamIds, uint128[] calldata amounts) external;

    /// @notice See the documentation in {ISablierV2Lockup}
    function withdrawMaxAndTransfer(uint256 streamId, address newRecipient) external returns (uint128 withdrawnAmount);

    /// @notice See the documentation in {ISablierV2Lockup}
    function cancel(uint256 streamId) external;

    /// @notice See the documentation in {ISablierV2Lockup}
    function cancelMultiple(uint256[] calldata streamIds) external;

    /// @notice See the documentation in {ISablierV2Lockup}
    function renounce(uint256 streamId) external;
}
