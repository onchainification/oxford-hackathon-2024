// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

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

contract RevoookerTest is RhinestoneModuleKit, Test {
    using ModuleKitHelpers for *;
    using ModuleKitUserOp for *;

    uint256 mainnetFork;

    // account and modules
    AccountInstance internal instance;
    Revoooker internal revoker;

    function setUp() public {
        init();
        mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"));

        // Create the executor
        revoker = new Revoooker();
        vm.label(address(revoker), "Revoooker");

        // Create the account and install the revoker
        instance = makeAccountInstance("Revoooker");
        instance.installModule({
            moduleTypeId: MODULE_TYPE_EXECUTOR,
            module: address(revoker),
            data: ""
        });
    }

    function testRevoke() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);

        // Approve WETH for some spender
        address spender = makeAddr("spender");
        IERC20 weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        assertEq(weth.allowance(address(this), spender), 0);
        weth.approve(spender, 1 ether);
        assertGt(weth.allowance(address(this), spender), 0);
    }
}
