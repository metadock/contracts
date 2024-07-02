// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IModuleManager {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a module is enabled on the container
    /// @param module The address of the enabled module
    event ModuleEnabled(address indexed module);

    /// @notice Emitted when a module is disabled on the container
    /// @param module The address of the disabled module
    event ModuleDisabled(address indexed module);

    /*//////////////////////////////////////////////////////////////////////////
                                 CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Checks whether the `module` module is enabled on the container
    function isModuleEnabled(address module) external view returns (bool isEnabled);

    /*//////////////////////////////////////////////////////////////////////////
                                NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Enables a module deployed at `module` address
    /// @param module The address of the module to enable
    function enableModule(address module) external;
}
