// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/transferProxy.sol";
import "forge-std/console.sol";

contract DeployTransferProxyScript is Script {
    function setUp() public {}

    //run these commands to deploy to blockchain
    //source .env
    // forge script script/deploy.s.sol:DeployTransferProxyScript --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $RPC_URL --broadcast -vv
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        transferProxy TransferProxy = new transferProxy();
        console.log("transferProxy: ", address(TransferProxy));
    }
}