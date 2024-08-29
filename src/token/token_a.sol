// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenA is ERC20, Ownable {
    constructor(uint256 initSupply) ERC20("TokenA", "TA") Ownable(msg.sender){
        _mint(msg.sender, initSupply);
    }

    function mint(address to, uint256 amount)
    public {
        _mint(to, amount);
    }

    function burn(uint256 amount)
    public {
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount)
    public
    override 
    returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
    public
    override
    returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
    public
    override
    returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "Your tokens are not enough!");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function getbalance(address account)
    public
    view
    returns(uint256){
        return balanceOf(account);
    }
}