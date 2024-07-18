// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract LiquidityToken is ERC20, AccessControl {

    // string public constant name = 'EmelSwap';
    // string public constant symbol = 'EMS';
    // uint8 public constant decimals = 18;
    // uint  public override totalSupply;
 

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function mint(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(to, amount);
    }

 


}