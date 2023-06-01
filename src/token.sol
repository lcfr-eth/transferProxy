// SPDX-License-Identifier: MIT
// stolen from wentokens / pop-punk.eth for testing
pragma solidity ^0.8.13;

import "@openzeppelin/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 constant _initial_supply = (10**9) * (10**18);

    constructor() ERC20("AYYLMAO", "AYY") {
        _mint(msg.sender, _initial_supply);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}