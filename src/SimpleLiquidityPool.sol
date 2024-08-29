// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SimpleLiquidityPool {
    using Strings for uint256;
    
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public totalLiquidity;

    mapping(address => uint256) public liquidity;

    constructor(address _tokenA,address _tokenB) {
        tokenA =IERC20(_tokenA);
        tokenB =IERC20(_tokenB);
    }

    function AddLiquidity(uint256 amountA,uint256 amountB)
    public
    returns(uint256){
        uint256 liquidityMinted;

        require(amountA >0&&amountB >0,"Invalid Data!");

        require(tokenA.transferFrom(msg.sender,address(this),amountA),"fail to transfer from tokenA");
        require(tokenB.transferFrom(msg.sender,address(this),amountB),"fail to transfer from tokenB");

        if(totalLiquidity ==0){
            liquidityMinted =Math.sqrt(amountA*amountB);
            reserveA =amountA;
            reserveB =amountB;
            totalLiquidity =liquidityMinted;
            liquidity[msg.sender] =liquidityMinted;
        }else {
            uint256 amountAliquidity =amountA *totalLiquidity/reserveA;
            uint256 amountBliquidity =amountB *totalLiquidity/reserveB;
            liquidityMinted = amountAliquidity < amountBliquidity ? amountAliquidity :amountBliquidity;

            require(liquidityMinted >0,"LiquidityMinted must greater than 0!");

            uint256 actualAmountA = liquidityMinted * reserveA / totalLiquidity;
            uint256 actualAmountB = liquidityMinted * reserveB / totalLiquidity;

            reserveA += actualAmountA;
            reserveB += actualAmountB;
            totalLiquidity += liquidityMinted;
            liquidity[msg.sender] += liquidityMinted;

            if(amountA >actualAmountA){
                require(tokenA.transfer(msg.sender,amountA -actualAmountA),"fail to refund excess tokenA");
            }

            if (amountB >actualAmountB){
                require(tokenB.transfer(msg.sender,amountB -actualAmountB),"fail to  refund excess tokenB");
            }
        }

        return liquidityMinted;
    }

    function removeliquidity(uint256 liquidityAmount)
    public
    returns(uint256 amountA,uint256 amountB){
        require(liquidity[msg.sender] >=liquidityAmount,"liquidity is not enough");

        amountA =(liquidityAmount *reserveA)/totalLiquidity;
        amountB=(liquidityAmount *reserveB)/totalLiquidity;

        reserveA -=amountA;
        reserveB -=amountB;
        totalLiquidity -=liquidityAmount;
        liquidity[msg.sender] -=liquidityAmount;

        require(tokenA.transfer(msg.sender,amountA),"fail to transfer tokenA");
        require(tokenB.transfer(msg.sender,amountB),"fail to transfer tokenB");
        
        return (amountA,amountB);
    }

    function swap(uint256 amountIn,address tokenIn,uint256 minAmount)
    public
    returns(uint256 amountOut){
        require(tokenIn == address(tokenA) || tokenIn == address(tokenB),"Invalid token! Please choose the right token");

        bool istokenA = tokenIn ==address(tokenA);

        IERC20 inputToken =istokenA ?tokenA :tokenB;
        IERC20 outputToken =istokenA ?tokenB :tokenA;

        uint256 inputReserve =istokenA ?reserveA :reserveB;
        uint256 outputReserve =istokenA ?reserveB :reserveA;

        amountOut =getAmount(amountIn,inputReserve,outputReserve);

        require(amountOut >= minAmount,"Slippage is too high");
        require(inputToken.transferFrom(msg.sender,address(this),amountIn),"fail to transfer in");
        require(outputToken.transfer(msg.sender,amountOut),"fail to transfer out");

        if (istokenA) {
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            reserveA -= amountOut;
            reserveB += amountIn;
        }
        
        return amountOut;
        }   

    function getAmount(uint256 amountIn,uint256 reserveIn,uint256 reserveOut)
    public
    pure
    returns(uint256 amountOut){
        uint256 amountInWithFee =amountIn *995;
        uint256 numerator =amountInWithFee *reserveOut;
        uint256 denominator =(reserveIn *1000) +amountIn;
        amountOut =numerator /denominator;

        return amountOut;
    }

    function getLiquidity(address account)
    public
    view
    returns(uint256){
        return liquidity[account];
    }
}
