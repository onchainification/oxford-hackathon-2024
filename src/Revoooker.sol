// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC7579ExecutorBase } from "modulekit/Modules.sol";
import { ExecutionLib } from "erc7579/lib/ExecutionLib.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { IERC7579Account } from "modulekit/Accounts.sol";
import { ModeLib } from "erc7579/lib/ModeLib.sol";

contract Revoooker is ERC7579ExecutorBase {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONFIG
    //////////////////////////////////////////////////////////////////////////*/

    /* Initialize the module with the given data
    * @param data The data to initialize the module with
    */
    function onInstall(bytes calldata data) external override { }

    /* De-initialize the module with the given data
    * @param data The data to de-initialize the module with
    */
    function onUninstall(bytes calldata data) external override { }

    /*
    * Check if the module is initialized
    * @param smartAccount The smart account to check
    * @return true if the module is initialized, false otherwise
    */
    function isInitialized(address smartAccount) external view returns (bool) { }

    /*//////////////////////////////////////////////////////////////////////////
                                     MODULE LOGIC
    //////////////////////////////////////////////////////////////////////////*/

    /*
    * Revoke an approval for a specific ERC20 token and spender
    * @param token The token to revoke the approval for
    * @param spender The spender to revoke the approval for
    */
    function revoke(address token, address spender) external {
        // TODO: confirm msg.sender is a signer
        bytes memory data = abi.encodeCall(IERC20.approve, (spender, 0));
        bytes memory transaction = ExecutionLib.encodeSingle(token, 0, data);
        IERC7579Account(msg.sender).executeFromExecutor(ModeLib.encodeSimpleSingle(), transaction);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     METADATA
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * The name of the module
     * @return name The name of the module
     */
    function name() external pure returns (string memory) {
        return "Revoooker";
    }

    /**
     * The version of the module
     * @return version The version of the module
     */
    function version() external pure returns (string memory) {
        return "0.0.1";
    }

    /*
    * Check if the module is of a certain type
    * @param typeID The type ID to check
    * @return true if the module is of the given type, false otherwise
    */
    function isModuleType(uint256 typeID) external pure override returns (bool) {
        return typeID == TYPE_EXECUTOR;
    }
}
