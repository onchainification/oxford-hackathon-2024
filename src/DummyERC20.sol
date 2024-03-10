// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DummyERC20 is ERC20 {
    constructor() ERC20("DummyERC20", "DUMMY") {
        this;
    }
}
