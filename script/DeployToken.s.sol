// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "../src/token/token_a.sol";
import "../src/token/token_b.sol";
import "forge-std/Script.sol";

contract DeployToken is Script{
    function run() 
    external{
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 initSupplyA = 1000;
        uint256 initSupplyB = 1000;

        TokenA tokenA = new TokenA(initSupplyA);
        TokenB tokenB = new TokenB(initSupplyB);

        vm.stopBroadcast();     
    }   
}
