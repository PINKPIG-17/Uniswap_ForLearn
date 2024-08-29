// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SimpleLiquidityPool.sol";
import "../src/token/token_a.sol";
import "../src/token/token_b.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PoolTest is Test{
    using Strings for uint256;

    TokenA tokena;
    TokenB tokenb;
    SimpleLiquidityPool pool;
    address user;

    function setUp() 
    public {
        uint256 initSupply = 1000 ;
        tokena = new TokenA(initSupply);
        tokenb = new TokenB(initSupply);

        pool = new SimpleLiquidityPool(address(tokena), address(tokenb));

        user = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        
        tokena.transfer(address(this), 100);
        tokenb.transfer(address(this), 100 );
        tokena.transfer(user, 100);
        tokenb.transfer(user, 100);
    }

    function testAddLiquidity() 
    public {
        tokena.approve(address(pool), 50);
        tokenb.approve(address(pool), 50);

        uint256 liquidity = pool.AddLiquidity(40, 10 );

        assertEq(liquidity, 20);
    }

    function testSwap() public {
    vm.startPrank(user);

    tokena.approve(address(pool), 50);
    tokenb.approve(address(pool), 50);

    pool.AddLiquidity(40 , 10);

    uint256 currentA = pool.reserveA();
    uint256 currentB = pool.reserveB(); 

    uint256 _amountOut = pool.getAmount(100 , currentB, currentA);  // 

    assertEq(currentA, 40);
    assertEq(currentB, 10);

    uint256 amountOut = pool.swap(10, address(tokenb),20);

    // string memory errorMessage = string(
    //     abi.encodePacked("Pool's tokens are not enough! Max is ", _amountOut.toString())
    // );

    // // 设置期望的 revert
    // vm.expectRevert(bytes(errorMessage));
    
    // // 调用会触发 revert 的函数
    // uint256 amountOut = pool.swap(100, address(tokenb));
    
    vm.stopPrank();

    emit log_named_uint("Amount is", amountOut);
    emit log_named_uint("AmountOut is", _amountOut);

    assertGt(amountOut, 0);
    }

}
