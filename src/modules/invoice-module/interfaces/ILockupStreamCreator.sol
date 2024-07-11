// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { ISablierV2LockupTranched } from "@sablier/v2-core/src/interfaces/ISablierV2LockupTranched.sol";
import { UD60x18 } from "@prb/math/src/UD60x18.sol";

/// @title ILockupStreamCreator
/// @notice Contract used to create Sablier V2 compatible streams
/// @dev This code is referenced in the docs: https://docs.sablier.com/contracts/v2/guides/create-stream/lockup-linear
interface ILockupStreamCreator {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the broker fee is updated
    /// @param oldFee The old broker fee
    /// @param newFee The new broker fee
    event BrokerFeeUpdated(UD60x18 oldFee, UD60x18 newFee);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the {SablierV2LockupLinear} contract used to create linear streams
    /// @dev This is initialized at construction time and it might be different depending on the deployment chain
    /// See https://docs.sablier.com/contracts/v2/deployments
    function LOCKUP_LINEAR() external view returns (ISablierV2LockupLinear);

    /// @notice The address of the {SablierV2LockupTranched} contract used to create tranched streams
    /// @dev This is initialized at construction time and it might be different depending on the deployment chain
    /// See https://docs.sablier.com/contracts/v2/deployments
    function LOCKUP_TRANCHED() external view returns (ISablierV2LockupTranched);

    /// @notice The address of the broker admin account or contract managing the broker fee
    function brokerAdmin() external view returns (address);

    /// @notice The broker fee charged to create Sablier V2 stream
    /// @dev See the `UD60x18` type definition in the `@prb/math/src/ud60x18/ValueType.sol file`
    function brokerFee() external view returns (UD60x18);
}
