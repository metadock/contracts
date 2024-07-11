// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IStreamManager } from "./interfaces/IStreamManager.sol";
import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

/// @title StreamManager
/// @notice See the documentation in {IStreamManager}
contract StreamManager is IStreamManager {
    /*//////////////////////////////////////////////////////////////////////////
                                  PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamManager
    ISablierV2Lockup public immutable override sablier;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Initializes the {ISablierV2Lockup} contract address
    constructor(ISablierV2Lockup _sablier) {
        sablier = _sablier;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamManager
    function withdraw(uint256 streamId, address to, uint128 amount) external {
        sablier.withdraw(streamId, to, amount);
    }

    /// @inheritdoc IStreamManager
    function withdrawableAmountOf(uint256 streamId) external view returns (uint128 withdrawableAmount) {
        withdrawableAmount = sablier.withdrawableAmountOf(streamId);
    }

    /// @inheritdoc IStreamManager
    function withdrawMax(uint256 streamId, address to) external returns (uint128 withdrawnAmount) {
        withdrawnAmount = sablier.withdrawMax(streamId, to);
    }

    /// @inheritdoc IStreamManager
    function withdrawMultiple(uint256[] calldata streamIds, uint128[] calldata amounts) external {
        sablier.withdrawMultiple({ streamIds: streamIds, amounts: amounts });
    }
}
