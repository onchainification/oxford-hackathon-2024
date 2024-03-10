// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";
import {
    RhinestoneModuleKit,
    ModuleKitHelpers,
    ModuleKitUserOp,
    AccountInstance
} from "modulekit/ModuleKit.sol";
import { MODULE_TYPE_EXECUTOR } from "modulekit/external/ERC7579.sol";
import { ExecutionLib } from "erc7579/lib/ExecutionLib.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { Revoooker } from "src/Revoooker.sol";
import { DummyERC20 } from "src/DummyERC20.sol";

contract RevoookerTest is RhinestoneModuleKit, Test {
    using ModuleKitHelpers for *;
    using ModuleKitUserOp for *;

    uint256 mainnetFork;

    // account and modules
    AccountInstance internal instance;
    Revoooker internal revoker;
    DummyERC20 internal dummy;

    function setUp() public {
        // Initialize the RhinestoneModuleKit
        init();

        // Create the revoker
        revoker = new Revoooker();
        vm.label(address(revoker), "Revoooker");

        // Deploy a dummy erc20
        dummy = new DummyERC20();
        vm.label(address(dummy), "DummyERC20");

        // Create the account and install the revoker
        instance = makeAccountInstance("Revoooker");
        instance.installModule({
            moduleTypeId: MODULE_TYPE_EXECUTOR,
            module: address(revoker),
            data: ""
        });
    }

    function testRevoke() public {
        // Make all calls from the account instance
        vm.startPrank(instance.account);

        // Confirm the revoker is installed
        assert(instance.isModuleInstalled(MODULE_TYPE_EXECUTOR, address(revoker), ""));

        // Set up an allowance for spender on the dummy erc20
        address spender = makeAddr("spender");
        assertEq(dummy.allowance(instance.account, spender), 0);
        dummy.approve(spender, 1 ether);
        assertGt(dummy.allowance(instance.account, spender), 0);

        // Get rid of the allowance using the revoooker
        instance.exec({
            target: address(revoker),
            value: 0,
            callData: abi.encodeCall(Revoooker.revoke, (address(dummy), spender))
        });
        assertEq(dummy.allowance(instance.account, spender), 0);
    }
}
