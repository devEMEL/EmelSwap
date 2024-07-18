// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Pair.sol";

contract Factory {


    mapping(address => mapping(address => Pair)) public getPair;
    address[] public allPairs;

    event pairCreated(address indexed token1, address indexed token2, address indexed pair);



    function createPair(address token1, address token2, string calldata token1Name, string calldata token2Name) external returns (address) {

        require(token1 != token2, "IDENTICAL_ADDRESSES");
        require(token1 != address(0), "ZERO_ADDRESS");
        require(token2 != address(0), "ZERO_ADDRESS");
        require(address(getPair[token1][token2]) == address(0), "PAIR_EXISTS");
        require(address(getPair[token2][token1]) == address(0), "PAIR_EXISTS");

        string memory liquidityTokenName = string(abi.encodePacked("Liquidity-", token1Name, "-", token2Name));
        string memory liquidityTokenSymbol = string(abi.encodePacked("LP-", token1Name, "-", token2Name));
        Pair _pair = new Pair(token1, token2, liquidityTokenName, liquidityTokenSymbol);
        getPair[token1][token2] = _pair;
        getPair[token2][token1] = _pair;

        emit pairCreated(token1, token2, address(_pair));

        return address(_pair);

    }

     function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getPairs() external view returns (address[] memory) {
        return allPairs;
    }
}