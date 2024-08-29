// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./SimpleLiquidityPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashLoan{
    SimpleLiquidityPool public liquiditypool;

    // error InvalidToken(string tokenName);
    // error NotEnoughToken(string tokenName);

    constructor(address _liquiditypool){
        liquiditypool =SimpleLiquidityPool(_liquiditypool);
    }

    function excuteFlashLoan(address borrower,address token,uint256 amount,bytes calldata data)
    external{
        IERC20 LoanToken =IERC20(token);

        require(token == address(liquiditypool.tokenA()) || token == address(liquiditypool.tokenB()),"Not Support Token!");

        uint256 iniBalance = LoanToken.balanceOf(address(this));

        require(LoanToken.balanceOf(address(liquiditypool)) >= amount,"Not Enough Token To Lean!");

        require(LoanToken.transfer(borrower,amount),"fail to transfer!");

        (bool success,) =borrower.call(data);
        require(success,"fail to external call");

        uint256 fee = (amount *5) /1000;
        uint256 repayamount = fee +amount;

        require(LoanToken.balanceOf(address(this)) >= iniBalance +fee,"fee has not paid!");
        require(LoanToken.transfer(address(liquiditypool),repayamount),"fail to repay!");

    }
}


