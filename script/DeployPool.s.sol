// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "../src/SimpleLiquidityPool.sol";

import "forge-std/Script.sol";

contract DeployPool is Script{
    function run()
    external{
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        address tokenA =address(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        address tokenB =address(0x5FbDB2315678afecb367f032d93F642f64180aa3);

        SimpleLiquidityPool pool =new SimpleLiquidityPool(tokenA,tokenB);

        vm.stopBroadcast();
    }
}