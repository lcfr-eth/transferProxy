// SPDX-License-Identifier: UNLICENSED
// fork test to verify the approval check + calling is working

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/transferProxy.sol";

contract transferProxyTest is Test {
    transferProxy public proxy;

    function setUp() public {
        proxy = new transferProxy();
    }

    function testTransfer() public {
        bytes[] memory data = new bytes[](1);
        // data[0] = "\x41\x42\x41\x42";
        address _contract = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;
        address _from = 0x10D0d49AeB4e06d5bbbE6Efe352aDb11045e89f7;
        address _caller = 0x1eAcA5cEc385A6C876D8A56f6c776Bb5857AcCbc;

        vm.startPrank(_from);
        vm.deal(_from, 1 ether);
        
        data[0] = abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _caller, 1);
        proxy.approvedtransfer(data, _contract, _from, _caller);
        vm.endPrank();
    }
}
