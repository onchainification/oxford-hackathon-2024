// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "modulekit/ModuleKit.sol";
import "modulekit/Mocks.sol";
import { MODULE_TYPE_EXECUTOR } from "modulekit/external/ERC7579.sol";
import { ExecutionLib } from "erc7579/lib/ExecutionLib.sol";
import { Revoooker } from "src/Revoooker.sol";

contract RevoookerTest is RhinestoneModuleKit, Test {
    using ModuleKitHelpers for *;

    // account and modules
    AccountInstance internal instance;
    Revoooker internal revoker;
    MockERC20 internal mock;

    function setUp() public {
        // Initialize the RhinestoneModuleKit
        init();

        // Create the revoker
        revoker = new Revoooker();
        vm.label(address(revoker), "Revoooker");

        // Deploy a mock erc20
        mock = new MockERC20();
        vm.label(address(mock), "MockERC20");

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

        // Set up an allowance for spender on the mock erc20
        address spender = makeAddr("spender");
        assertEq(mock.allowance(instance.account, spender), 0);
        mock.approve(spender, 1 ether);
        assertGt(mock.allowance(instance.account, spender), 0);

        // Get rid of the allowance using the revoooker
        instance.exec({
            target: address(revoker),
            value: 0,
            callData: abi.encodeCall(Revoooker.revoke, (address(mock), spender))
        });
        assertEq(mock.allowance(instance.account, spender), 0);
    }
}
