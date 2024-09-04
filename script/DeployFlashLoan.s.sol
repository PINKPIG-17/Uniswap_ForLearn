pragma solidity ^0.8.0;

import "../src/FlashLoan.sol";
import "forge-std/Script.sol";

contract DeployFlashLoan is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        address _FlashLoan = address(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0);

        FlashLoan flashloan = new FlashLoan(_FlashLoan);

        vm.stopBroadcast();
    }
}
