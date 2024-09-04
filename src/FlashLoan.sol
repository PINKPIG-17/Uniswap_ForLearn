// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./SimpleLiquidityPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";  

contract FlashLoan is ReentrancyGuard {
    SimpleLiquidityPool public liquiditypool;

    constructor(address _liquiditypool) {
        liquiditypool = SimpleLiquidityPool(_liquiditypool);
    }

    function executeFlashLoan(
        address borrower,
        address token,
        uint256 amount,
        bytes calldata data
    ) external nonReentrant {  
        IERC20 LoanToken = IERC20(token);
        uint256 fee = (amount * 5) / 1000;

        require(
            token == address(liquiditypool.tokenA()) || token == address(liquiditypool.tokenB()),
            "Not Support Token!"
        );

        uint256 iniBalance = LoanToken.balanceOf(address(this));

        require(
            LoanToken.balanceOf(address(liquiditypool)) >= amount,
            "Not Enough Token To Loan!"
        );
        require(
            LoanToken.balanceOf(borrower) >= fee,
            "Not Enough Token To Pay Fee"
        );

        require(LoanToken.transfer(borrower, amount), "Fail to transfer!");

        (bool success, ) = borrower.call(data);
        require(success, "Fail to external call");

        uint256 repayAmount = fee + amount;

        require(
            LoanToken.balanceOf(address(this)) >= iniBalance + fee,
            "Fee has not been paid!"
        );
        require(
            LoanToken.transfer(address(liquiditypool), repayAmount),
            "Fail to repay!"
        );
    }
}
