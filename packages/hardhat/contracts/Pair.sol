// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./LiquidityToken.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Pair {

    using SafeMath for uint;
    using Math for uint;

    address public token1;
    address public token2;
    uint256 public reserve1;
    uint256 public reserve2;

    uint256 public constantK;

    LiquidityToken public liquidityToken;

    event Swap(address indexed sender, uint256 amountIn, uint256 amountOut, address tokenIn, address tokenOut);


    constructor(address _token1, address _token2, string memory _liquidityTokenName, string memory _liquidityTokenSymbol) {
        token1 = _token1;
        token2 = _token2;
        liquidityToken = new LiquidityToken(_liquidityTokenName, _liquidityTokenSymbol);
    }

    function addLiquidity(uint amountToken1, uint amountToken2) external {
        uint256 liquidity;
        uint256 totalSupplyOfToken = liquidityToken.totalSupply();

        if(totalSupplyOfToken == 0) {
            liquidity = amountToken1.mul(amountToken2).sqrt();
        } else {
            liquidity = amountToken1.mul(totalSupplyOfToken).div(reserve1).min(amountToken2.mul(totalSupplyOfToken).div(reserve2));
        }

        liquidityToken.mint(msg.sender, liquidity);
        require(IERC20(token1).transferFrom(msg.sender, address(this), amountToken1), "Transfer of token1 failed");
        require(IERC20(token2).transferFrom(msg.sender, address(this), amountToken2), "Transfer of token2 failed");

        reserve1 += amountToken1;
        reserve2 += amountToken2;

        _updateConstantFormula();
    }
 
    function removeLiquidity(uint256 amountOfLiquidity) external {
        uint256 totalSupply = liquidityToken.totalSupply();

        require(amountOfLiquidity <= totalSupply, "Liquidity is more than the total supply");
        liquidityToken.burn(msg.sender, amountOfLiquidity);

        uint256 amount1 = (reserve1 * amountOfLiquidity) / totalSupply;
        uint256 amount2 = (reserve2 * amountOfLiquidity) / totalSupply;

        require(IERC20(token1).transfer(msg.sender, amount1), "Transfer of token1 failed");
        require(IERC20(token2).transfer(msg.sender, amount2), "Transfer of token2 failed");

        reserve1 -= amount1;
        reserve2 -= amount2;

        _updateConstantFormula();
    }

    function swapTokens(address fromToken, address toToken, uint256 amountIn, uint256 amountOut) external {
        require(amountIn > 0, "Amount must be greater than 0");
        require((fromToken == token1 && toToken == token2) || (fromToken == token2&& toToken == token1), "Tokens need to be pair tokens");
        IERC20 fromTokenContract = IERC20(fromToken);
        IERC20 toTokenContract = IERC20(toToken);

        require(fromTokenContract.balanceOf(msg.sender) > amountIn, "Insufficient balance of tokenFrom");
        require(toTokenContract.balanceOf(address(this)) > amountOut, "Insufficient balance of tokenTo");

        uint256 expectedAmountOut;

        if(fromToken == token1 && toToken == token2) {
            expectedAmountOut = reserve2.mul(amountIn).div(reserve1);
        } else {
            expectedAmountOut = reserve1.mul(amountIn).div(reserve2);
        }

        require(amountOut <= expectedAmountOut, "Swap does not conserve constant formula");

        require(fromTokenContract.transferFrom(msg.sender, address(this), amountIn), "Transfer of token failed");
        require(toTokenContract.transfer(msg.sender, expectedAmountOut), "Transfer of token failed");

        if(fromToken == token1 && toToken == token2) {
            reserve1 += amountIn;
            reserve2 -= expectedAmountOut;
        } else {
            reserve1 -= expectedAmountOut;
            reserve2 += amountIn;
        }

        require(reserve1.mul(reserve2) == constantK, "Swap does not conserve constant formula");

        emit Swap(msg.sender, amountIn, expectedAmountOut, fromToken, toToken);


    }

    function _updateConstantFormula() internal {
        constantK = reserve1.mul(reserve2);
        require(constantK > 0, "Constant formula not updated");
    }


}